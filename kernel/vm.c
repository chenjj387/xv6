#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

#ifdef LAB_NET
  // PCI-E ECAM (configuration space), for pci.c
  kvmmap(kpgtbl, 0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);

  // pci.c maps the e1000's registers here.
  kvmmap(kpgtbl, 0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
#endif  

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// Initialize the one kernel_pagetable
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
#ifdef LAB_PGTBL
      if(PTE_LEAF(*pte)) {
        return pte;
      }
#endif
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

#ifdef LAB_PGTBL
pte_t *
superwalk(pagetable_t pagetable, uint64 va, int alloc, int *level_ptr)
{
  if(va >= MAXVA)
    panic("superwalk: va too high");

  int current_level = 2;
  while (current_level > *level_ptr) {
    pte_t *entry = &pagetable[PX(current_level, va)];
    if(*entry & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*entry);
      if(PTE_LEAF(*entry)) {
        *level_ptr = current_level;
        return entry;
      }
    } else {
      if(!alloc) return 0;
      pagetable_t new_table = (pde_t*)kalloc();
      if(!new_table) return 0;
      memset(new_table, 0, PGSIZE);
      *entry = PA2PTE(new_table) | PTE_V;
      pagetable = new_table;
    }
    current_level--;
  }
  return &pagetable[PX(*level_ptr, va)];
}
#endif

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}


// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    panic("mappages: size not aligned");

  if(size == 0)
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  
  for(;;){
#ifdef LAB_PGTBL
    int use_super = 0;
    int sz = PGSIZE;
    
    // 重构超级页条件判断
    if((perm & PTE_U) && 
       (a % SUPERPGSIZE == 0) && 
       ((last - a + PGSIZE) >= SUPERPGSIZE)) {
      use_super = 1;
      sz = SUPERPGSIZE;
      int level = 1;
      if((pte = superwalk(pagetable, a, 1, &level)) == 0)
        return -1;
    } else {
      if((pte = walk(pagetable, a, 1)) == 0)
        return -1;
    }
#else
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
#endif
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    
    if(a + sz == last + PGSIZE)
      break;
    
    if(use_super) {
      a += SUPERPGSIZE;
      pa += SUPERPGSIZE;
    } else {
      a += PGSIZE;
      pa += PGSIZE;
    }
  }
  return 0;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  if((va % PGSIZE) != 0)
    panic("uvmunmap: address not page-aligned");

  uint64 current = va;
  const uint64 limit = va + npages * PGSIZE;
  
  while(current < limit) {
    int size = PGSIZE;
    pte_t *pte = 0;
    
#ifdef LAB_PGTBL
    int level = 0;
    pte = superwalk(pagetable, current, 0, &level);
#else
    pte = walk(pagetable, current, 0);
#endif

    if(!pte) 
      panic("uvmunmap: page table entry missing");
    
    if(!(*pte & PTE_V)) {
      printf("Address: 0x%lx, PTE: 0x%lx\n", current, *pte);
      panic("uvmunmap: page not present");
    }
    
    if(PTE_FLAGS(*pte) == PTE_V)
      panic("uvmunmap: invalid leaf entry");
    
    uint64 pa = PTE2PA(*pte);
    *pte = 0;  // 清除页表项
    
    if(do_free) {
#ifdef LAB_PGTBL
      if(level == 1) {
        size = SUPERPGSIZE;
        
        // 处理超级页不对齐的情况
        if(current % SUPERPGSIZE != 0) {
          uint64 base = SUPERPGROUNDDOWN(current);
          uint64 end = base + SUPERPGSIZE;
          uint32 perm_flags = *pte & 0xFFF;
          
          // 只处理当前解映射范围内的部分
          uint64 process_end = (limit < end) ? limit : end;
          
          // 拆分超级页为小页
          for(uint64 i = base; i < process_end; i += PGSIZE) {
            // 跳过已经处理的部分
            if(i < current) continue;
            
            char *new_page = kalloc();
            if(!new_page) panic("uvmunmap: page allocation error");
            
            // 复制原始数据
            uint64 offset = i - base;
            memmove(new_page, (char*)pa + offset, PGSIZE);
            
            // 创建新映射
            if(mappages(pagetable, i, PGSIZE, (uint64)new_page, perm_flags) != 0) {
              kfree(new_page);
              panic("uvmunmap: remapping failed");
            }
          }
          
          // 跳过整个超级页范围
          current = end;
          continue;
        }
        
        // 对齐的超级页直接释放
        superfree((void*)pa);
      } else {
        kfree((void*)pa);
      }
#else
      kfree((void*)pa);
#endif
    }
    
    current += size;
  }
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("uvmfirst: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
  memmove(mem, src, sz);
}


// Allocate PTEs and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 old_size, uint64 new_size, int extra_perm)
{
  if(new_size < old_size) return old_size;
  
  old_size = PGROUNDUP(old_size);
  uint64 current_va = old_size;
  
  while(current_va < new_size) {
    uint64 alloc_size = PGSIZE;
    char *new_mem = 0;
    
#ifdef LAB_PGTBL
    // 优化超级页分配条件
    uint64 remaining = new_size - current_va;
    if(remaining >= SUPERPGSIZE && (current_va % SUPERPGSIZE == 0)) {
      alloc_size = SUPERPGSIZE;
      new_mem = superalloc();
    } else {
      new_mem = kalloc();
    }
#else
    new_mem = kalloc();
#endif
    
    if(!new_mem) {
      uvmdealloc(pagetable, current_va, old_size);
      return 0;
    }
    
#ifndef LAB_SYSCALL
    memset(new_mem, 0, alloc_size);
#endif
    
    int map_result = mappages(pagetable, current_va, alloc_size, 
                             (uint64)new_mem, PTE_R|PTE_U|extra_perm);
    
    if(map_result != 0) {
#ifdef LAB_PGTBL
      if(alloc_size == SUPERPGSIZE) 
        superfree(new_mem);
      else 
#endif
        kfree(new_mem);
        
      uvmdealloc(pagetable, current_va, old_size);
      return 0;
    }
    
    current_va += alloc_size;
  }
  
  return new_size;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t src_pg, pagetable_t dst_pg, uint64 size)
{
  uint64 current_va = 0;
  
  while(current_va < size) {
    uint64 copy_size = PGSIZE;
    pte_t *src_pte = 0;
    
#ifdef LAB_PGTBL
    int page_level = 0;
    src_pte = superwalk(src_pg, current_va, 0, &page_level);
#else
    src_pte = walk(src_pg, current_va, 0);
#endif
    
    if(!src_pte) panic("uvmcopy: pte missing");
    if(!(*src_pte & PTE_V)) panic("uvmcopy: page absent");
    
    uint64 phys_src = PTE2PA(*src_pte);
    uint flags = PTE_FLAGS(*src_pte);
    char *new_mem = 0;
    
#ifdef LAB_PGTBL
    if(page_level == 1) {
      copy_size = SUPERPGSIZE;
      new_mem = superalloc();
      if(!new_mem) goto error;
      memmove(new_mem, (char*)phys_src, copy_size);
      
      if(mappages(dst_pg, current_va, copy_size, (uint64)new_mem, flags)) {
        superfree(new_mem);
        goto error;
      }
    } else {
#endif
      new_mem = kalloc();
      if(!new_mem) goto error;
      memmove(new_mem, (char*)phys_src, PGSIZE);
      
      if(mappages(dst_pg, current_va, PGSIZE, (uint64)new_mem, flags)) {
        kfree(new_mem);
        goto error;
      }
#ifdef LAB_PGTBL
    }
#endif
    
    current_va += copy_size;
  }
  
  return 0;

error:
  uvmunmap(dst_pg, 0, current_va / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if (va0 >= MAXVA)
      return -1;
    if((pte = walk(pagetable, va0, 0)) == 0) {
      // printf("copyout: pte should exist 0x%x %d\n", dstva, len);
      return -1;
    }


    // forbid copyout over read-only user text pages.
    if((*pte & PTE_W) == 0)
      return -1;
    
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  
  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}


static void
vmprint_(pagetable_t pagetable, int level)
{
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if(pte & PTE_V) {  // 检查页表项是否有效
      // 打印缩进（根据页表层级）
      for(int j = 0; j < level; j++) {
        printf("..");
      }
      
      // 打印页表项信息
      printf("%d: pte %p ", i, (void *)pte);
      
      // 打印权限标志（带括号）
      printf("(");
      if(pte & PTE_R) printf("R");
      if(pte & PTE_W) printf("W");
      if(pte & PTE_X) printf("X");
      if(pte & PTE_U) printf("U");
      printf(") ");
      
      // 计算物理页帧号
      uint64 pa = PTE2PA(pte);
      printf("pa %d\n",(int)(pa >> 12));  // 右移12位得到页帧号
      
      // 递归打印下一级页表（如果是非叶子节点）
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
        uint64 child = PTE2PA(pte);
        vmprint_((pagetable_t)child, level + 1);
      }
    }
  }
}



#ifdef LAB_PGTBL
void
vmprint(pagetable_t pagetable) {
  // your code here
  printf("page table %p\n", pagetable);
  vmprint_(pagetable, 0);
}
#endif



#ifdef LAB_PGTBL
pte_t*
pgpte(pagetable_t pagetable, uint64 va) {
  return walk(pagetable, va, 0);
}
#endif
