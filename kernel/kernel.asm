
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00019117          	auipc	sp,0x19
    80000004:	cb010113          	addi	sp,sp,-848 # 80018cb0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	160050ef          	jal	ra,80005176 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00021797          	auipc	a5,0x21
    80000034:	d8078793          	addi	a5,a5,-640 # 80020db0 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	1f2000ef          	jal	ra,8000023a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00008917          	auipc	s2,0x8
    80000050:	a2490913          	addi	s2,s2,-1500 # 80007a70 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	339050ef          	jal	ra,80005b8e <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	3c1050ef          	jal	ra,80005c26 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00007517          	auipc	a0,0x7
    8000007a:	f9a50513          	addi	a0,a0,-102 # 80007010 <etext+0x10>
    8000007e:	7f4050ef          	jal	ra,80005872 <panic>

0000000080000082 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000082:	1101                	addi	sp,sp,-32
    80000084:	ec06                	sd	ra,24(sp)
    80000086:	e822                	sd	s0,16(sp)
    80000088:	e426                	sd	s1,8(sp)
    8000008a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000008c:	00008497          	auipc	s1,0x8
    80000090:	9e448493          	addi	s1,s1,-1564 # 80007a70 <kmem>
    80000094:	8526                	mv	a0,s1
    80000096:	2f9050ef          	jal	ra,80005b8e <acquire>
  r = kmem.freelist;
    8000009a:	6c84                	ld	s1,24(s1)
  if(r)
    8000009c:	c485                	beqz	s1,800000c4 <kalloc+0x42>
    kmem.freelist = r->next;
    8000009e:	609c                	ld	a5,0(s1)
    800000a0:	00008517          	auipc	a0,0x8
    800000a4:	9d050513          	addi	a0,a0,-1584 # 80007a70 <kmem>
    800000a8:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    800000aa:	37d050ef          	jal	ra,80005c26 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800000ae:	6605                	lui	a2,0x1
    800000b0:	4595                	li	a1,5
    800000b2:	8526                	mv	a0,s1
    800000b4:	186000ef          	jal	ra,8000023a <memset>
  return (void*)r;
}
    800000b8:	8526                	mv	a0,s1
    800000ba:	60e2                	ld	ra,24(sp)
    800000bc:	6442                	ld	s0,16(sp)
    800000be:	64a2                	ld	s1,8(sp)
    800000c0:	6105                	addi	sp,sp,32
    800000c2:	8082                	ret
  release(&kmem.lock);
    800000c4:	00008517          	auipc	a0,0x8
    800000c8:	9ac50513          	addi	a0,a0,-1620 # 80007a70 <kmem>
    800000cc:	35b050ef          	jal	ra,80005c26 <release>
  if(r)
    800000d0:	b7e5                	j	800000b8 <kalloc+0x36>

00000000800000d2 <superfree>:

#ifdef LAB_PGTBL
void
superfree(void *pa)
{
    800000d2:	1101                	addi	sp,sp,-32
    800000d4:	ec06                	sd	ra,24(sp)
    800000d6:	e822                	sd	s0,16(sp)
    800000d8:	e426                	sd	s1,8(sp)
    800000da:	e04a                	sd	s2,0(sp)
    800000dc:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % SUPERPGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800000de:	02b51793          	slli	a5,a0,0x2b
    800000e2:	e7b1                	bnez	a5,8000012e <superfree+0x5c>
    800000e4:	84aa                	mv	s1,a0
    800000e6:	00021797          	auipc	a5,0x21
    800000ea:	cca78793          	addi	a5,a5,-822 # 80020db0 <end>
    800000ee:	04f56063          	bltu	a0,a5,8000012e <superfree+0x5c>
    800000f2:	47c5                	li	a5,17
    800000f4:	07ee                	slli	a5,a5,0x1b
    800000f6:	02f57c63          	bgeu	a0,a5,8000012e <superfree+0x5c>
    panic("superfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, SUPERPGSIZE);
    800000fa:	00200637          	lui	a2,0x200
    800000fe:	4585                	li	a1,1
    80000100:	13a000ef          	jal	ra,8000023a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000104:	00008917          	auipc	s2,0x8
    80000108:	96c90913          	addi	s2,s2,-1684 # 80007a70 <kmem>
    8000010c:	854a                	mv	a0,s2
    8000010e:	281050ef          	jal	ra,80005b8e <acquire>
  r->next = kmem.superfreelist;
    80000112:	02093783          	ld	a5,32(s2)
    80000116:	e09c                	sd	a5,0(s1)
  kmem.superfreelist = r;
    80000118:	02993023          	sd	s1,32(s2)
  release(&kmem.lock);
    8000011c:	854a                	mv	a0,s2
    8000011e:	309050ef          	jal	ra,80005c26 <release>
}
    80000122:	60e2                	ld	ra,24(sp)
    80000124:	6442                	ld	s0,16(sp)
    80000126:	64a2                	ld	s1,8(sp)
    80000128:	6902                	ld	s2,0(sp)
    8000012a:	6105                	addi	sp,sp,32
    8000012c:	8082                	ret
    panic("superfree");
    8000012e:	00007517          	auipc	a0,0x7
    80000132:	eea50513          	addi	a0,a0,-278 # 80007018 <etext+0x18>
    80000136:	73c050ef          	jal	ra,80005872 <panic>

000000008000013a <freerange>:
{
    8000013a:	7139                	addi	sp,sp,-64
    8000013c:	fc06                	sd	ra,56(sp)
    8000013e:	f822                	sd	s0,48(sp)
    80000140:	f426                	sd	s1,40(sp)
    80000142:	f04a                	sd	s2,32(sp)
    80000144:	ec4e                	sd	s3,24(sp)
    80000146:	e852                	sd	s4,16(sp)
    80000148:	e456                	sd	s5,8(sp)
    8000014a:	0080                	addi	s0,sp,64
    8000014c:	89ae                	mv	s3,a1
  char *superp = (char*)SUPERPGROUNDUP((uint64)pa_end - superpg_num * SUPERPGSIZE);
    8000014e:	f8a004b7          	lui	s1,0xf8a00
    80000152:	14fd                	addi	s1,s1,-1
    80000154:	94ae                	add	s1,s1,a1
    80000156:	ffe007b7          	lui	a5,0xffe00
    8000015a:	8cfd                	and	s1,s1,a5
  p = (char*)PGROUNDUP((uint64)pa_start);
    8000015c:	6785                	lui	a5,0x1
    8000015e:	fff78913          	addi	s2,a5,-1 # fff <_entry-0x7ffff001>
    80000162:	992a                	add	s2,s2,a0
    80000164:	757d                	lui	a0,0xfffff
    80000166:	00a97933          	and	s2,s2,a0
  for(; p + PGSIZE <= superp ; p += PGSIZE)
    8000016a:	993e                	add	s2,s2,a5
    8000016c:	0124eb63          	bltu	s1,s2,80000182 <freerange+0x48>
    kfree(p);
    80000170:	7afd                	lui	s5,0xfffff
  for(; p + PGSIZE <= superp ; p += PGSIZE)
    80000172:	6a05                	lui	s4,0x1
    kfree(p);
    80000174:	01590533          	add	a0,s2,s5
    80000178:	ea5ff0ef          	jal	ra,8000001c <kfree>
  for(; p + PGSIZE <= superp ; p += PGSIZE)
    8000017c:	9952                	add	s2,s2,s4
    8000017e:	ff24fbe3          	bgeu	s1,s2,80000174 <freerange+0x3a>
  for(; superp + SUPERPGSIZE <= (char *)pa_end ; superp += SUPERPGSIZE)
    80000182:	002007b7          	lui	a5,0x200
    80000186:	94be                	add	s1,s1,a5
    80000188:	0099ed63          	bltu	s3,s1,800001a2 <freerange+0x68>
    superfree(superp);
    8000018c:	ffe00a37          	lui	s4,0xffe00
  for(; superp + SUPERPGSIZE <= (char *)pa_end ; superp += SUPERPGSIZE)
    80000190:	00200937          	lui	s2,0x200
    superfree(superp);
    80000194:	01448533          	add	a0,s1,s4
    80000198:	f3bff0ef          	jal	ra,800000d2 <superfree>
  for(; superp + SUPERPGSIZE <= (char *)pa_end ; superp += SUPERPGSIZE)
    8000019c:	94ca                	add	s1,s1,s2
    8000019e:	fe99fbe3          	bgeu	s3,s1,80000194 <freerange+0x5a>
}
    800001a2:	70e2                	ld	ra,56(sp)
    800001a4:	7442                	ld	s0,48(sp)
    800001a6:	74a2                	ld	s1,40(sp)
    800001a8:	7902                	ld	s2,32(sp)
    800001aa:	69e2                	ld	s3,24(sp)
    800001ac:	6a42                	ld	s4,16(sp)
    800001ae:	6aa2                	ld	s5,8(sp)
    800001b0:	6121                	addi	sp,sp,64
    800001b2:	8082                	ret

00000000800001b4 <kinit>:
{
    800001b4:	1141                	addi	sp,sp,-16
    800001b6:	e406                	sd	ra,8(sp)
    800001b8:	e022                	sd	s0,0(sp)
    800001ba:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800001bc:	00007597          	auipc	a1,0x7
    800001c0:	e6c58593          	addi	a1,a1,-404 # 80007028 <etext+0x28>
    800001c4:	00008517          	auipc	a0,0x8
    800001c8:	8ac50513          	addi	a0,a0,-1876 # 80007a70 <kmem>
    800001cc:	143050ef          	jal	ra,80005b0e <initlock>
  freerange(end, (void*)PHYSTOP);
    800001d0:	45c5                	li	a1,17
    800001d2:	05ee                	slli	a1,a1,0x1b
    800001d4:	00021517          	auipc	a0,0x21
    800001d8:	bdc50513          	addi	a0,a0,-1060 # 80020db0 <end>
    800001dc:	f5fff0ef          	jal	ra,8000013a <freerange>
}
    800001e0:	60a2                	ld	ra,8(sp)
    800001e2:	6402                	ld	s0,0(sp)
    800001e4:	0141                	addi	sp,sp,16
    800001e6:	8082                	ret

00000000800001e8 <superalloc>:

void *
superalloc(void)
{
    800001e8:	1101                	addi	sp,sp,-32
    800001ea:	ec06                	sd	ra,24(sp)
    800001ec:	e822                	sd	s0,16(sp)
    800001ee:	e426                	sd	s1,8(sp)
    800001f0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    800001f2:	00008497          	auipc	s1,0x8
    800001f6:	87e48493          	addi	s1,s1,-1922 # 80007a70 <kmem>
    800001fa:	8526                	mv	a0,s1
    800001fc:	193050ef          	jal	ra,80005b8e <acquire>
  r = kmem.superfreelist;
    80000200:	7084                	ld	s1,32(s1)
  if(r)
    80000202:	c48d                	beqz	s1,8000022c <superalloc+0x44>
    kmem.superfreelist = r->next;
    80000204:	609c                	ld	a5,0(s1)
    80000206:	00008517          	auipc	a0,0x8
    8000020a:	86a50513          	addi	a0,a0,-1942 # 80007a70 <kmem>
    8000020e:	f11c                	sd	a5,32(a0)
  release(&kmem.lock);
    80000210:	217050ef          	jal	ra,80005c26 <release>

  if(r)
    memset((char*)r, 5, SUPERPGSIZE); // fill with junk
    80000214:	00200637          	lui	a2,0x200
    80000218:	4595                	li	a1,5
    8000021a:	8526                	mv	a0,s1
    8000021c:	01e000ef          	jal	ra,8000023a <memset>
  return (void*)r;
}
    80000220:	8526                	mv	a0,s1
    80000222:	60e2                	ld	ra,24(sp)
    80000224:	6442                	ld	s0,16(sp)
    80000226:	64a2                	ld	s1,8(sp)
    80000228:	6105                	addi	sp,sp,32
    8000022a:	8082                	ret
  release(&kmem.lock);
    8000022c:	00008517          	auipc	a0,0x8
    80000230:	84450513          	addi	a0,a0,-1980 # 80007a70 <kmem>
    80000234:	1f3050ef          	jal	ra,80005c26 <release>
  if(r)
    80000238:	b7e5                	j	80000220 <superalloc+0x38>

000000008000023a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000023a:	1141                	addi	sp,sp,-16
    8000023c:	e422                	sd	s0,8(sp)
    8000023e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000240:	ce09                	beqz	a2,8000025a <memset+0x20>
    80000242:	87aa                	mv	a5,a0
    80000244:	fff6071b          	addiw	a4,a2,-1
    80000248:	1702                	slli	a4,a4,0x20
    8000024a:	9301                	srli	a4,a4,0x20
    8000024c:	0705                	addi	a4,a4,1
    8000024e:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000250:	00b78023          	sb	a1,0(a5) # 200000 <_entry-0x7fe00000>
  for(i = 0; i < n; i++){
    80000254:	0785                	addi	a5,a5,1
    80000256:	fee79de3          	bne	a5,a4,80000250 <memset+0x16>
  }
  return dst;
}
    8000025a:	6422                	ld	s0,8(sp)
    8000025c:	0141                	addi	sp,sp,16
    8000025e:	8082                	ret

0000000080000260 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000260:	1141                	addi	sp,sp,-16
    80000262:	e422                	sd	s0,8(sp)
    80000264:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000266:	ca05                	beqz	a2,80000296 <memcmp+0x36>
    80000268:	fff6069b          	addiw	a3,a2,-1
    8000026c:	1682                	slli	a3,a3,0x20
    8000026e:	9281                	srli	a3,a3,0x20
    80000270:	0685                	addi	a3,a3,1
    80000272:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000274:	00054783          	lbu	a5,0(a0)
    80000278:	0005c703          	lbu	a4,0(a1)
    8000027c:	00e79863          	bne	a5,a4,8000028c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000280:	0505                	addi	a0,a0,1
    80000282:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000284:	fed518e3          	bne	a0,a3,80000274 <memcmp+0x14>
  }

  return 0;
    80000288:	4501                	li	a0,0
    8000028a:	a019                	j	80000290 <memcmp+0x30>
      return *s1 - *s2;
    8000028c:	40e7853b          	subw	a0,a5,a4
}
    80000290:	6422                	ld	s0,8(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
  return 0;
    80000296:	4501                	li	a0,0
    80000298:	bfe5                	j	80000290 <memcmp+0x30>

000000008000029a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000029a:	1141                	addi	sp,sp,-16
    8000029c:	e422                	sd	s0,8(sp)
    8000029e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800002a0:	ca0d                	beqz	a2,800002d2 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800002a2:	00a5f963          	bgeu	a1,a0,800002b4 <memmove+0x1a>
    800002a6:	02061693          	slli	a3,a2,0x20
    800002aa:	9281                	srli	a3,a3,0x20
    800002ac:	00d58733          	add	a4,a1,a3
    800002b0:	02e56463          	bltu	a0,a4,800002d8 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800002b4:	fff6079b          	addiw	a5,a2,-1
    800002b8:	1782                	slli	a5,a5,0x20
    800002ba:	9381                	srli	a5,a5,0x20
    800002bc:	0785                	addi	a5,a5,1
    800002be:	97ae                	add	a5,a5,a1
    800002c0:	872a                	mv	a4,a0
      *d++ = *s++;
    800002c2:	0585                	addi	a1,a1,1
    800002c4:	0705                	addi	a4,a4,1
    800002c6:	fff5c683          	lbu	a3,-1(a1)
    800002ca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800002ce:	fef59ae3          	bne	a1,a5,800002c2 <memmove+0x28>

  return dst;
}
    800002d2:	6422                	ld	s0,8(sp)
    800002d4:	0141                	addi	sp,sp,16
    800002d6:	8082                	ret
    d += n;
    800002d8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800002da:	fff6079b          	addiw	a5,a2,-1
    800002de:	1782                	slli	a5,a5,0x20
    800002e0:	9381                	srli	a5,a5,0x20
    800002e2:	fff7c793          	not	a5,a5
    800002e6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800002e8:	177d                	addi	a4,a4,-1
    800002ea:	16fd                	addi	a3,a3,-1
    800002ec:	00074603          	lbu	a2,0(a4)
    800002f0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800002f4:	fef71ae3          	bne	a4,a5,800002e8 <memmove+0x4e>
    800002f8:	bfe9                	j	800002d2 <memmove+0x38>

00000000800002fa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800002fa:	1141                	addi	sp,sp,-16
    800002fc:	e406                	sd	ra,8(sp)
    800002fe:	e022                	sd	s0,0(sp)
    80000300:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000302:	f99ff0ef          	jal	ra,8000029a <memmove>
}
    80000306:	60a2                	ld	ra,8(sp)
    80000308:	6402                	ld	s0,0(sp)
    8000030a:	0141                	addi	sp,sp,16
    8000030c:	8082                	ret

000000008000030e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000030e:	1141                	addi	sp,sp,-16
    80000310:	e422                	sd	s0,8(sp)
    80000312:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000314:	ce11                	beqz	a2,80000330 <strncmp+0x22>
    80000316:	00054783          	lbu	a5,0(a0)
    8000031a:	cf89                	beqz	a5,80000334 <strncmp+0x26>
    8000031c:	0005c703          	lbu	a4,0(a1)
    80000320:	00f71a63          	bne	a4,a5,80000334 <strncmp+0x26>
    n--, p++, q++;
    80000324:	367d                	addiw	a2,a2,-1
    80000326:	0505                	addi	a0,a0,1
    80000328:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000032a:	f675                	bnez	a2,80000316 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000032c:	4501                	li	a0,0
    8000032e:	a809                	j	80000340 <strncmp+0x32>
    80000330:	4501                	li	a0,0
    80000332:	a039                	j	80000340 <strncmp+0x32>
  if(n == 0)
    80000334:	ca09                	beqz	a2,80000346 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000336:	00054503          	lbu	a0,0(a0)
    8000033a:	0005c783          	lbu	a5,0(a1)
    8000033e:	9d1d                	subw	a0,a0,a5
}
    80000340:	6422                	ld	s0,8(sp)
    80000342:	0141                	addi	sp,sp,16
    80000344:	8082                	ret
    return 0;
    80000346:	4501                	li	a0,0
    80000348:	bfe5                	j	80000340 <strncmp+0x32>

000000008000034a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000034a:	1141                	addi	sp,sp,-16
    8000034c:	e422                	sd	s0,8(sp)
    8000034e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000350:	872a                	mv	a4,a0
    80000352:	8832                	mv	a6,a2
    80000354:	367d                	addiw	a2,a2,-1
    80000356:	01005963          	blez	a6,80000368 <strncpy+0x1e>
    8000035a:	0705                	addi	a4,a4,1
    8000035c:	0005c783          	lbu	a5,0(a1)
    80000360:	fef70fa3          	sb	a5,-1(a4)
    80000364:	0585                	addi	a1,a1,1
    80000366:	f7f5                	bnez	a5,80000352 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000368:	00c05d63          	blez	a2,80000382 <strncpy+0x38>
    8000036c:	86ba                	mv	a3,a4
    *s++ = 0;
    8000036e:	0685                	addi	a3,a3,1
    80000370:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000374:	fff6c793          	not	a5,a3
    80000378:	9fb9                	addw	a5,a5,a4
    8000037a:	010787bb          	addw	a5,a5,a6
    8000037e:	fef048e3          	bgtz	a5,8000036e <strncpy+0x24>
  return os;
}
    80000382:	6422                	ld	s0,8(sp)
    80000384:	0141                	addi	sp,sp,16
    80000386:	8082                	ret

0000000080000388 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000388:	1141                	addi	sp,sp,-16
    8000038a:	e422                	sd	s0,8(sp)
    8000038c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000038e:	02c05363          	blez	a2,800003b4 <safestrcpy+0x2c>
    80000392:	fff6069b          	addiw	a3,a2,-1
    80000396:	1682                	slli	a3,a3,0x20
    80000398:	9281                	srli	a3,a3,0x20
    8000039a:	96ae                	add	a3,a3,a1
    8000039c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000039e:	00d58963          	beq	a1,a3,800003b0 <safestrcpy+0x28>
    800003a2:	0585                	addi	a1,a1,1
    800003a4:	0785                	addi	a5,a5,1
    800003a6:	fff5c703          	lbu	a4,-1(a1)
    800003aa:	fee78fa3          	sb	a4,-1(a5)
    800003ae:	fb65                	bnez	a4,8000039e <safestrcpy+0x16>
    ;
  *s = 0;
    800003b0:	00078023          	sb	zero,0(a5)
  return os;
}
    800003b4:	6422                	ld	s0,8(sp)
    800003b6:	0141                	addi	sp,sp,16
    800003b8:	8082                	ret

00000000800003ba <strlen>:

int
strlen(const char *s)
{
    800003ba:	1141                	addi	sp,sp,-16
    800003bc:	e422                	sd	s0,8(sp)
    800003be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800003c0:	00054783          	lbu	a5,0(a0)
    800003c4:	cf91                	beqz	a5,800003e0 <strlen+0x26>
    800003c6:	0505                	addi	a0,a0,1
    800003c8:	87aa                	mv	a5,a0
    800003ca:	4685                	li	a3,1
    800003cc:	9e89                	subw	a3,a3,a0
    800003ce:	00f6853b          	addw	a0,a3,a5
    800003d2:	0785                	addi	a5,a5,1
    800003d4:	fff7c703          	lbu	a4,-1(a5)
    800003d8:	fb7d                	bnez	a4,800003ce <strlen+0x14>
    ;
  return n;
}
    800003da:	6422                	ld	s0,8(sp)
    800003dc:	0141                	addi	sp,sp,16
    800003de:	8082                	ret
  for(n = 0; s[n]; n++)
    800003e0:	4501                	li	a0,0
    800003e2:	bfe5                	j	800003da <strlen+0x20>

00000000800003e4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800003e4:	1141                	addi	sp,sp,-16
    800003e6:	e406                	sd	ra,8(sp)
    800003e8:	e022                	sd	s0,0(sp)
    800003ea:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800003ec:	5cd000ef          	jal	ra,800011b8 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800003f0:	00007717          	auipc	a4,0x7
    800003f4:	65070713          	addi	a4,a4,1616 # 80007a40 <started>
  if(cpuid() == 0){
    800003f8:	c51d                	beqz	a0,80000426 <main+0x42>
    while(started == 0)
    800003fa:	431c                	lw	a5,0(a4)
    800003fc:	2781                	sext.w	a5,a5
    800003fe:	dff5                	beqz	a5,800003fa <main+0x16>
      ;
    __sync_synchronize();
    80000400:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000404:	5b5000ef          	jal	ra,800011b8 <cpuid>
    80000408:	85aa                	mv	a1,a0
    8000040a:	00007517          	auipc	a0,0x7
    8000040e:	c3e50513          	addi	a0,a0,-962 # 80007048 <etext+0x48>
    80000412:	1ac050ef          	jal	ra,800055be <printf>
    kvminithart();    // turn on paging
    80000416:	1a6000ef          	jal	ra,800005bc <kvminithart>
    trapinithart();   // install kernel trap vector
    8000041a:	159010ef          	jal	ra,80001d72 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000041e:	756040ef          	jal	ra,80004b74 <plicinithart>
  }

  scheduler();        
    80000422:	296010ef          	jal	ra,800016b8 <scheduler>
    consoleinit();
    80000426:	0c0050ef          	jal	ra,800054e6 <consoleinit>
    printfinit();
    8000042a:	482050ef          	jal	ra,800058ac <printfinit>
    printf("\n");
    8000042e:	00007517          	auipc	a0,0x7
    80000432:	c2a50513          	addi	a0,a0,-982 # 80007058 <etext+0x58>
    80000436:	188050ef          	jal	ra,800055be <printf>
    printf("xv6 kernel is booting\n");
    8000043a:	00007517          	auipc	a0,0x7
    8000043e:	bf650513          	addi	a0,a0,-1034 # 80007030 <etext+0x30>
    80000442:	17c050ef          	jal	ra,800055be <printf>
    printf("\n");
    80000446:	00007517          	auipc	a0,0x7
    8000044a:	c1250513          	addi	a0,a0,-1006 # 80007058 <etext+0x58>
    8000044e:	170050ef          	jal	ra,800055be <printf>
    kinit();         // physical page allocator
    80000452:	d63ff0ef          	jal	ra,800001b4 <kinit>
    kvminit();       // create kernel page table
    80000456:	516000ef          	jal	ra,8000096c <kvminit>
    kvminithart();   // turn on paging
    8000045a:	162000ef          	jal	ra,800005bc <kvminithart>
    procinit();      // process table
    8000045e:	4b5000ef          	jal	ra,80001112 <procinit>
    trapinit();      // trap vectors
    80000462:	0ed010ef          	jal	ra,80001d4e <trapinit>
    trapinithart();  // install kernel trap vector
    80000466:	10d010ef          	jal	ra,80001d72 <trapinithart>
    plicinit();      // set up interrupt controller
    8000046a:	6f4040ef          	jal	ra,80004b5e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000046e:	706040ef          	jal	ra,80004b74 <plicinithart>
    binit();         // buffer cache
    80000472:	77f010ef          	jal	ra,800023f0 <binit>
    iinit();         // inode table
    80000476:	55e020ef          	jal	ra,800029d4 <iinit>
    fileinit();      // file table
    8000047a:	2f8030ef          	jal	ra,80003772 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000047e:	7e6040ef          	jal	ra,80004c64 <virtio_disk_init>
    userinit();      // first user process
    80000482:	070010ef          	jal	ra,800014f2 <userinit>
    __sync_synchronize();
    80000486:	0ff0000f          	fence
    started = 1;
    8000048a:	4785                	li	a5,1
    8000048c:	00007717          	auipc	a4,0x7
    80000490:	5af72a23          	sw	a5,1460(a4) # 80007a40 <started>
    80000494:	b779                	j	80000422 <main+0x3e>

0000000080000496 <vmprint_>:
}


static void
vmprint_(pagetable_t pagetable, int level)
{
    80000496:	7159                	addi	sp,sp,-112
    80000498:	f486                	sd	ra,104(sp)
    8000049a:	f0a2                	sd	s0,96(sp)
    8000049c:	eca6                	sd	s1,88(sp)
    8000049e:	e8ca                	sd	s2,80(sp)
    800004a0:	e4ce                	sd	s3,72(sp)
    800004a2:	e0d2                	sd	s4,64(sp)
    800004a4:	fc56                	sd	s5,56(sp)
    800004a6:	f85a                	sd	s6,48(sp)
    800004a8:	f45e                	sd	s7,40(sp)
    800004aa:	f062                	sd	s8,32(sp)
    800004ac:	ec66                	sd	s9,24(sp)
    800004ae:	e86a                	sd	s10,16(sp)
    800004b0:	e46e                	sd	s11,8(sp)
    800004b2:	1880                	addi	s0,sp,112
    800004b4:	8aae                	mv	s5,a1
  for(int i = 0; i < 512; i++){
    800004b6:	8a2a                	mv	s4,a0
    800004b8:	4981                	li	s3,0
      for(int j = 0; j < level; j++) {
        printf("..");
      }
      
      // 打印页表项信息
      printf("%d: pte %p ", i, (void *)pte);
    800004ba:	00007d17          	auipc	s10,0x7
    800004be:	baed0d13          	addi	s10,s10,-1106 # 80007068 <etext+0x68>
      
      // 打印权限标志（带括号）
      printf("(");
    800004c2:	00007c97          	auipc	s9,0x7
    800004c6:	bb6c8c93          	addi	s9,s9,-1098 # 80007078 <etext+0x78>
      if(pte & PTE_R) printf("R");
      if(pte & PTE_W) printf("W");
      if(pte & PTE_X) printf("X");
      if(pte & PTE_U) printf("U");
      printf(") ");
    800004ca:	00007c17          	auipc	s8,0x7
    800004ce:	bcec0c13          	addi	s8,s8,-1074 # 80007098 <etext+0x98>
      
      // 计算物理页帧号
      uint64 pa = PTE2PA(pte);
      printf("pa %d\n",(int)(pa >> 12));  // 右移12位得到页帧号
    800004d2:	5bfd                	li	s7,-1
    800004d4:	00cbdb93          	srli	s7,s7,0xc
      
      // 递归打印下一级页表（如果是非叶子节点）
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
        uint64 child = PTE2PA(pte);
        vmprint_((pagetable_t)child, level + 1);
    800004d8:	00158d9b          	addiw	s11,a1,1
        printf("..");
    800004dc:	00007b17          	auipc	s6,0x7
    800004e0:	b84b0b13          	addi	s6,s6,-1148 # 80007060 <etext+0x60>
    800004e4:	a099                	j	8000052a <vmprint_+0x94>
      if(pte & PTE_R) printf("R");
    800004e6:	00007517          	auipc	a0,0x7
    800004ea:	25250513          	addi	a0,a0,594 # 80007738 <syscalls+0x218>
    800004ee:	0d0050ef          	jal	ra,800055be <printf>
    800004f2:	a0ad                	j	8000055c <vmprint_+0xc6>
      if(pte & PTE_W) printf("W");
    800004f4:	00007517          	auipc	a0,0x7
    800004f8:	b8c50513          	addi	a0,a0,-1140 # 80007080 <etext+0x80>
    800004fc:	0c2050ef          	jal	ra,800055be <printf>
    80000500:	a08d                	j	80000562 <vmprint_+0xcc>
      if(pte & PTE_X) printf("X");
    80000502:	00007517          	auipc	a0,0x7
    80000506:	b8650513          	addi	a0,a0,-1146 # 80007088 <etext+0x88>
    8000050a:	0b4050ef          	jal	ra,800055be <printf>
    8000050e:	a8a9                	j	80000568 <vmprint_+0xd2>
      if(pte & PTE_U) printf("U");
    80000510:	00007517          	auipc	a0,0x7
    80000514:	b8050513          	addi	a0,a0,-1152 # 80007090 <etext+0x90>
    80000518:	0a6050ef          	jal	ra,800055be <printf>
    8000051c:	a889                	j	8000056e <vmprint_+0xd8>
  for(int i = 0; i < 512; i++){
    8000051e:	2985                	addiw	s3,s3,1
    80000520:	0a21                	addi	s4,s4,8
    80000522:	20000793          	li	a5,512
    80000526:	06f98c63          	beq	s3,a5,8000059e <vmprint_+0x108>
    pte_t pte = pagetable[i];
    8000052a:	000a3903          	ld	s2,0(s4) # ffffffffffe00000 <end+0xffffffff7fddf250>
    if(pte & PTE_V) {  // 检查页表项是否有效
    8000052e:	00197793          	andi	a5,s2,1
    80000532:	d7f5                	beqz	a5,8000051e <vmprint_+0x88>
      for(int j = 0; j < level; j++) {
    80000534:	01505963          	blez	s5,80000546 <vmprint_+0xb0>
    80000538:	4481                	li	s1,0
        printf("..");
    8000053a:	855a                	mv	a0,s6
    8000053c:	082050ef          	jal	ra,800055be <printf>
      for(int j = 0; j < level; j++) {
    80000540:	2485                	addiw	s1,s1,1
    80000542:	fe9a9ce3          	bne	s5,s1,8000053a <vmprint_+0xa4>
      printf("%d: pte %p ", i, (void *)pte);
    80000546:	864a                	mv	a2,s2
    80000548:	85ce                	mv	a1,s3
    8000054a:	856a                	mv	a0,s10
    8000054c:	072050ef          	jal	ra,800055be <printf>
      printf("(");
    80000550:	8566                	mv	a0,s9
    80000552:	06c050ef          	jal	ra,800055be <printf>
      if(pte & PTE_R) printf("R");
    80000556:	00297793          	andi	a5,s2,2
    8000055a:	f7d1                	bnez	a5,800004e6 <vmprint_+0x50>
      if(pte & PTE_W) printf("W");
    8000055c:	00497793          	andi	a5,s2,4
    80000560:	fbd1                	bnez	a5,800004f4 <vmprint_+0x5e>
      if(pte & PTE_X) printf("X");
    80000562:	00897793          	andi	a5,s2,8
    80000566:	ffd1                	bnez	a5,80000502 <vmprint_+0x6c>
      if(pte & PTE_U) printf("U");
    80000568:	01097793          	andi	a5,s2,16
    8000056c:	f3d5                	bnez	a5,80000510 <vmprint_+0x7a>
      printf(") ");
    8000056e:	8562                	mv	a0,s8
    80000570:	04e050ef          	jal	ra,800055be <printf>
      uint64 pa = PTE2PA(pte);
    80000574:	00a95493          	srli	s1,s2,0xa
      printf("pa %d\n",(int)(pa >> 12));  // 右移12位得到页帧号
    80000578:	0174f5b3          	and	a1,s1,s7
    8000057c:	2581                	sext.w	a1,a1
    8000057e:	00007517          	auipc	a0,0x7
    80000582:	b2250513          	addi	a0,a0,-1246 # 800070a0 <etext+0xa0>
    80000586:	038050ef          	jal	ra,800055be <printf>
      if((pte & (PTE_R|PTE_W|PTE_X)) == 0) {
    8000058a:	00e97913          	andi	s2,s2,14
    8000058e:	f80918e3          	bnez	s2,8000051e <vmprint_+0x88>
        vmprint_((pagetable_t)child, level + 1);
    80000592:	85ee                	mv	a1,s11
    80000594:	00c49513          	slli	a0,s1,0xc
    80000598:	effff0ef          	jal	ra,80000496 <vmprint_>
    8000059c:	b749                	j	8000051e <vmprint_+0x88>
      }
    }
  }
}
    8000059e:	70a6                	ld	ra,104(sp)
    800005a0:	7406                	ld	s0,96(sp)
    800005a2:	64e6                	ld	s1,88(sp)
    800005a4:	6946                	ld	s2,80(sp)
    800005a6:	69a6                	ld	s3,72(sp)
    800005a8:	6a06                	ld	s4,64(sp)
    800005aa:	7ae2                	ld	s5,56(sp)
    800005ac:	7b42                	ld	s6,48(sp)
    800005ae:	7ba2                	ld	s7,40(sp)
    800005b0:	7c02                	ld	s8,32(sp)
    800005b2:	6ce2                	ld	s9,24(sp)
    800005b4:	6d42                	ld	s10,16(sp)
    800005b6:	6da2                	ld	s11,8(sp)
    800005b8:	6165                	addi	sp,sp,112
    800005ba:	8082                	ret

00000000800005bc <kvminithart>:
{
    800005bc:	1141                	addi	sp,sp,-16
    800005be:	e422                	sd	s0,8(sp)
    800005c0:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800005c2:	12000073          	sfence.vma
  w_satp(MAKE_SATP(kernel_pagetable));
    800005c6:	00007797          	auipc	a5,0x7
    800005ca:	4827b783          	ld	a5,1154(a5) # 80007a48 <kernel_pagetable>
    800005ce:	83b1                	srli	a5,a5,0xc
    800005d0:	577d                	li	a4,-1
    800005d2:	177e                	slli	a4,a4,0x3f
    800005d4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800005d6:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800005da:	12000073          	sfence.vma
}
    800005de:	6422                	ld	s0,8(sp)
    800005e0:	0141                	addi	sp,sp,16
    800005e2:	8082                	ret

00000000800005e4 <walk>:
{
    800005e4:	7139                	addi	sp,sp,-64
    800005e6:	fc06                	sd	ra,56(sp)
    800005e8:	f822                	sd	s0,48(sp)
    800005ea:	f426                	sd	s1,40(sp)
    800005ec:	f04a                	sd	s2,32(sp)
    800005ee:	ec4e                	sd	s3,24(sp)
    800005f0:	e852                	sd	s4,16(sp)
    800005f2:	e456                	sd	s5,8(sp)
    800005f4:	e05a                	sd	s6,0(sp)
    800005f6:	0080                	addi	s0,sp,64
    800005f8:	892a                	mv	s2,a0
    800005fa:	89ae                	mv	s3,a1
    800005fc:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800005fe:	57fd                	li	a5,-1
    80000600:	83e9                	srli	a5,a5,0x1a
    80000602:	4a79                	li	s4,30
  for(int level = 2; level > 0; level--) {
    80000604:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000606:	02b7fb63          	bgeu	a5,a1,8000063c <walk+0x58>
    panic("walk");
    8000060a:	00007517          	auipc	a0,0x7
    8000060e:	a9e50513          	addi	a0,a0,-1378 # 800070a8 <etext+0xa8>
    80000612:	260050ef          	jal	ra,80005872 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000616:	060a8463          	beqz	s5,8000067e <walk+0x9a>
    8000061a:	a69ff0ef          	jal	ra,80000082 <kalloc>
    8000061e:	892a                	mv	s2,a0
    80000620:	c12d                	beqz	a0,80000682 <walk+0x9e>
      memset(pagetable, 0, PGSIZE);
    80000622:	6605                	lui	a2,0x1
    80000624:	4581                	li	a1,0
    80000626:	c15ff0ef          	jal	ra,8000023a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000062a:	00c95793          	srli	a5,s2,0xc
    8000062e:	07aa                	slli	a5,a5,0xa
    80000630:	0017e793          	ori	a5,a5,1
    80000634:	e09c                	sd	a5,0(s1)
  for(int level = 2; level > 0; level--) {
    80000636:	3a5d                	addiw	s4,s4,-9
    80000638:	036a0263          	beq	s4,s6,8000065c <walk+0x78>
    pte_t *pte = &pagetable[PX(level, va)];
    8000063c:	0149d4b3          	srl	s1,s3,s4
    80000640:	1ff4f493          	andi	s1,s1,511
    80000644:	048e                	slli	s1,s1,0x3
    80000646:	94ca                	add	s1,s1,s2
    if(*pte & PTE_V) {
    80000648:	609c                	ld	a5,0(s1)
    8000064a:	0017f713          	andi	a4,a5,1
    8000064e:	d761                	beqz	a4,80000616 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000650:	00a7d913          	srli	s2,a5,0xa
    80000654:	0932                	slli	s2,s2,0xc
      if(PTE_LEAF(*pte)) {
    80000656:	8bb9                	andi	a5,a5,14
    80000658:	dff9                	beqz	a5,80000636 <walk+0x52>
    8000065a:	a039                	j	80000668 <walk+0x84>
  return &pagetable[PX(0, va)];
    8000065c:	00c9d493          	srli	s1,s3,0xc
    80000660:	1ff4f493          	andi	s1,s1,511
    80000664:	048e                	slli	s1,s1,0x3
    80000666:	94ca                	add	s1,s1,s2
}
    80000668:	8526                	mv	a0,s1
    8000066a:	70e2                	ld	ra,56(sp)
    8000066c:	7442                	ld	s0,48(sp)
    8000066e:	74a2                	ld	s1,40(sp)
    80000670:	7902                	ld	s2,32(sp)
    80000672:	69e2                	ld	s3,24(sp)
    80000674:	6a42                	ld	s4,16(sp)
    80000676:	6aa2                	ld	s5,8(sp)
    80000678:	6b02                	ld	s6,0(sp)
    8000067a:	6121                	addi	sp,sp,64
    8000067c:	8082                	ret
        return 0;
    8000067e:	4481                	li	s1,0
    80000680:	b7e5                	j	80000668 <walk+0x84>
    80000682:	84aa                	mv	s1,a0
    80000684:	b7d5                	j	80000668 <walk+0x84>

0000000080000686 <superwalk>:
{
    80000686:	715d                	addi	sp,sp,-80
    80000688:	e486                	sd	ra,72(sp)
    8000068a:	e0a2                	sd	s0,64(sp)
    8000068c:	fc26                	sd	s1,56(sp)
    8000068e:	f84a                	sd	s2,48(sp)
    80000690:	f44e                	sd	s3,40(sp)
    80000692:	f052                	sd	s4,32(sp)
    80000694:	ec56                	sd	s5,24(sp)
    80000696:	e85a                	sd	s6,16(sp)
    80000698:	e45e                	sd	s7,8(sp)
    8000069a:	0880                	addi	s0,sp,80
  if(va >= MAXVA)
    8000069c:	57fd                	li	a5,-1
    8000069e:	83e9                	srli	a5,a5,0x1a
    800006a0:	04b7e263          	bltu	a5,a1,800006e4 <superwalk+0x5e>
    800006a4:	892a                	mv	s2,a0
    800006a6:	8aae                	mv	s5,a1
    800006a8:	8bb2                	mv	s7,a2
    800006aa:	8b36                	mv	s6,a3
  while (current_level > *level_ptr) {
    800006ac:	429c                	lw	a5,0(a3)
    800006ae:	4705                	li	a4,1
    800006b0:	49f9                	li	s3,30
  int current_level = 2;
    800006b2:	4a09                	li	s4,2
  while (current_level > *level_ptr) {
    800006b4:	06f75463          	bge	a4,a5,8000071c <superwalk+0x96>
  return &pagetable[PX(*level_ptr, va)];
    800006b8:	0037949b          	slliw	s1,a5,0x3
    800006bc:	9cbd                	addw	s1,s1,a5
    800006be:	24b1                	addiw	s1,s1,12
    800006c0:	009ad4b3          	srl	s1,s5,s1
    800006c4:	1ff4f493          	andi	s1,s1,511
    800006c8:	048e                	slli	s1,s1,0x3
    800006ca:	94ca                	add	s1,s1,s2
}
    800006cc:	8526                	mv	a0,s1
    800006ce:	60a6                	ld	ra,72(sp)
    800006d0:	6406                	ld	s0,64(sp)
    800006d2:	74e2                	ld	s1,56(sp)
    800006d4:	7942                	ld	s2,48(sp)
    800006d6:	79a2                	ld	s3,40(sp)
    800006d8:	7a02                	ld	s4,32(sp)
    800006da:	6ae2                	ld	s5,24(sp)
    800006dc:	6b42                	ld	s6,16(sp)
    800006de:	6ba2                	ld	s7,8(sp)
    800006e0:	6161                	addi	sp,sp,80
    800006e2:	8082                	ret
    panic("superwalk: va too high");
    800006e4:	00007517          	auipc	a0,0x7
    800006e8:	9cc50513          	addi	a0,a0,-1588 # 800070b0 <etext+0xb0>
    800006ec:	186050ef          	jal	ra,80005872 <panic>
      if(!alloc) return 0;
    800006f0:	040b8863          	beqz	s7,80000740 <superwalk+0xba>
      pagetable_t new_table = (pde_t*)kalloc();
    800006f4:	98fff0ef          	jal	ra,80000082 <kalloc>
    800006f8:	892a                	mv	s2,a0
      if(!new_table) return 0;
    800006fa:	c529                	beqz	a0,80000744 <superwalk+0xbe>
      memset(new_table, 0, PGSIZE);
    800006fc:	6605                	lui	a2,0x1
    800006fe:	4581                	li	a1,0
    80000700:	b3bff0ef          	jal	ra,8000023a <memset>
      *entry = PA2PTE(new_table) | PTE_V;
    80000704:	00c95793          	srli	a5,s2,0xc
    80000708:	07aa                	slli	a5,a5,0xa
    8000070a:	0017e793          	ori	a5,a5,1
    8000070e:	e09c                	sd	a5,0(s1)
    current_level--;
    80000710:	3a7d                	addiw	s4,s4,-1
  while (current_level > *level_ptr) {
    80000712:	000b2783          	lw	a5,0(s6)
    80000716:	39dd                	addiw	s3,s3,-9
    80000718:	fb47d0e3          	bge	a5,s4,800006b8 <superwalk+0x32>
    pte_t *entry = &pagetable[PX(current_level, va)];
    8000071c:	013ad4b3          	srl	s1,s5,s3
    80000720:	1ff4f493          	andi	s1,s1,511
    80000724:	048e                	slli	s1,s1,0x3
    80000726:	94ca                	add	s1,s1,s2
    if(*entry & PTE_V) {
    80000728:	609c                	ld	a5,0(s1)
    8000072a:	0017f713          	andi	a4,a5,1
    8000072e:	d369                	beqz	a4,800006f0 <superwalk+0x6a>
      pagetable = (pagetable_t)PTE2PA(*entry);
    80000730:	00a7d913          	srli	s2,a5,0xa
    80000734:	0932                	slli	s2,s2,0xc
      if(PTE_LEAF(*entry)) {
    80000736:	8bb9                	andi	a5,a5,14
    80000738:	dfe1                	beqz	a5,80000710 <superwalk+0x8a>
        *level_ptr = current_level;
    8000073a:	014b2023          	sw	s4,0(s6)
        return entry;
    8000073e:	b779                	j	800006cc <superwalk+0x46>
      if(!alloc) return 0;
    80000740:	4481                	li	s1,0
    80000742:	b769                	j	800006cc <superwalk+0x46>
      if(!new_table) return 0;
    80000744:	84aa                	mv	s1,a0
    80000746:	b759                	j	800006cc <superwalk+0x46>

0000000080000748 <walkaddr>:
  if(va >= MAXVA)
    80000748:	57fd                	li	a5,-1
    8000074a:	83e9                	srli	a5,a5,0x1a
    8000074c:	00b7f463          	bgeu	a5,a1,80000754 <walkaddr+0xc>
    return 0;
    80000750:	4501                	li	a0,0
}
    80000752:	8082                	ret
{
    80000754:	1141                	addi	sp,sp,-16
    80000756:	e406                	sd	ra,8(sp)
    80000758:	e022                	sd	s0,0(sp)
    8000075a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000075c:	4601                	li	a2,0
    8000075e:	e87ff0ef          	jal	ra,800005e4 <walk>
  if(pte == 0)
    80000762:	c105                	beqz	a0,80000782 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000764:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000766:	0117f693          	andi	a3,a5,17
    8000076a:	4745                	li	a4,17
    return 0;
    8000076c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000076e:	00e68663          	beq	a3,a4,8000077a <walkaddr+0x32>
}
    80000772:	60a2                	ld	ra,8(sp)
    80000774:	6402                	ld	s0,0(sp)
    80000776:	0141                	addi	sp,sp,16
    80000778:	8082                	ret
  pa = PTE2PA(*pte);
    8000077a:	00a7d513          	srli	a0,a5,0xa
    8000077e:	0532                	slli	a0,a0,0xc
  return pa;
    80000780:	bfcd                	j	80000772 <walkaddr+0x2a>
    return 0;
    80000782:	4501                	li	a0,0
    80000784:	b7fd                	j	80000772 <walkaddr+0x2a>

0000000080000786 <mappages>:
{
    80000786:	7119                	addi	sp,sp,-128
    80000788:	fc86                	sd	ra,120(sp)
    8000078a:	f8a2                	sd	s0,112(sp)
    8000078c:	f4a6                	sd	s1,104(sp)
    8000078e:	f0ca                	sd	s2,96(sp)
    80000790:	ecce                	sd	s3,88(sp)
    80000792:	e8d2                	sd	s4,80(sp)
    80000794:	e4d6                	sd	s5,72(sp)
    80000796:	e0da                	sd	s6,64(sp)
    80000798:	fc5e                	sd	s7,56(sp)
    8000079a:	f862                	sd	s8,48(sp)
    8000079c:	f466                	sd	s9,40(sp)
    8000079e:	f06a                	sd	s10,32(sp)
    800007a0:	ec6e                	sd	s11,24(sp)
    800007a2:	0100                	addi	s0,sp,128
  if((va % PGSIZE) != 0)
    800007a4:	03459793          	slli	a5,a1,0x34
    800007a8:	e795                	bnez	a5,800007d4 <mappages+0x4e>
    800007aa:	8c2a                	mv	s8,a0
    800007ac:	84ae                	mv	s1,a1
    800007ae:	8936                	mv	s2,a3
    800007b0:	8b3a                	mv	s6,a4
  if((size % PGSIZE) != 0)
    800007b2:	03461793          	slli	a5,a2,0x34
    800007b6:	e78d                	bnez	a5,800007e0 <mappages+0x5a>
  last = va + size - PGSIZE;
    800007b8:	00c58ab3          	add	s5,a1,a2
  if(size == 0)
    800007bc:	ca05                	beqz	a2,800007ec <mappages+0x66>
    if((perm & PTE_U) && 
    800007be:	01077b93          	andi	s7,a4,16
    800007c2:	2b81                	sext.w	s7,s7
    int sz = PGSIZE;
    800007c4:	6985                	lui	s3,0x1
    int use_super = 0;
    800007c6:	4c81                	li	s9,0
       (a % SUPERPGSIZE == 0) && 
    800007c8:	00200a37          	lui	s4,0x200
    800007cc:	fffa0d13          	addi	s10,s4,-1 # 1fffff <_entry-0x7fe00001>
      int level = 1;
    800007d0:	4d85                	li	s11,1
    800007d2:	a8b9                	j	80000830 <mappages+0xaa>
    panic("mappages: va not aligned");
    800007d4:	00007517          	auipc	a0,0x7
    800007d8:	8f450513          	addi	a0,a0,-1804 # 800070c8 <etext+0xc8>
    800007dc:	096050ef          	jal	ra,80005872 <panic>
    panic("mappages: size not aligned");
    800007e0:	00007517          	auipc	a0,0x7
    800007e4:	90850513          	addi	a0,a0,-1784 # 800070e8 <etext+0xe8>
    800007e8:	08a050ef          	jal	ra,80005872 <panic>
    panic("mappages: size");
    800007ec:	00007517          	auipc	a0,0x7
    800007f0:	91c50513          	addi	a0,a0,-1764 # 80007108 <etext+0x108>
    800007f4:	07e050ef          	jal	ra,80005872 <panic>
        return -1;
    800007f8:	557d                	li	a0,-1
    800007fa:	a8ad                	j	80000874 <mappages+0xee>
      if((pte = walk(pagetable, a, 1)) == 0)
    800007fc:	4605                	li	a2,1
    800007fe:	85a6                	mv	a1,s1
    80000800:	8562                	mv	a0,s8
    80000802:	de3ff0ef          	jal	ra,800005e4 <walk>
    80000806:	c525                	beqz	a0,8000086e <mappages+0xe8>
    int sz = PGSIZE;
    80000808:	874e                	mv	a4,s3
    int use_super = 0;
    8000080a:	86e6                	mv	a3,s9
    if(*pte & PTE_V)
    8000080c:	611c                	ld	a5,0(a0)
    8000080e:	8b85                	andi	a5,a5,1
    80000810:	e7b1                	bnez	a5,8000085c <mappages+0xd6>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000812:	00c95793          	srli	a5,s2,0xc
    80000816:	07aa                	slli	a5,a5,0xa
    80000818:	0167e7b3          	or	a5,a5,s6
    8000081c:	0017e793          	ori	a5,a5,1
    80000820:	e11c                	sd	a5,0(a0)
    if(a + sz == last + PGSIZE)
    80000822:	009707b3          	add	a5,a4,s1
    80000826:	04fa8663          	beq	s5,a5,80000872 <mappages+0xec>
    if(use_super) {
    8000082a:	ce9d                	beqz	a3,80000868 <mappages+0xe2>
      a += SUPERPGSIZE;
    8000082c:	94d2                	add	s1,s1,s4
      pa += SUPERPGSIZE;
    8000082e:	9952                	add	s2,s2,s4
    if((perm & PTE_U) && 
    80000830:	fc0b86e3          	beqz	s7,800007fc <mappages+0x76>
       (a % SUPERPGSIZE == 0) && 
    80000834:	01a4f7b3          	and	a5,s1,s10
    if((perm & PTE_U) && 
    80000838:	f3f1                	bnez	a5,800007fc <mappages+0x76>
       ((last - a + PGSIZE) >= SUPERPGSIZE)) {
    8000083a:	409a87b3          	sub	a5,s5,s1
       (a % SUPERPGSIZE == 0) && 
    8000083e:	fb47efe3          	bltu	a5,s4,800007fc <mappages+0x76>
      int level = 1;
    80000842:	f9b42623          	sw	s11,-116(s0)
      if((pte = superwalk(pagetable, a, 1, &level)) == 0)
    80000846:	f8c40693          	addi	a3,s0,-116
    8000084a:	4605                	li	a2,1
    8000084c:	85a6                	mv	a1,s1
    8000084e:	8562                	mv	a0,s8
    80000850:	e37ff0ef          	jal	ra,80000686 <superwalk>
    80000854:	d155                	beqz	a0,800007f8 <mappages+0x72>
      sz = SUPERPGSIZE;
    80000856:	8752                	mv	a4,s4
      use_super = 1;
    80000858:	4685                	li	a3,1
       ((last - a + PGSIZE) >= SUPERPGSIZE)) {
    8000085a:	bf4d                	j	8000080c <mappages+0x86>
      panic("mappages: remap");
    8000085c:	00007517          	auipc	a0,0x7
    80000860:	8bc50513          	addi	a0,a0,-1860 # 80007118 <etext+0x118>
    80000864:	00e050ef          	jal	ra,80005872 <panic>
      a += PGSIZE;
    80000868:	94ce                	add	s1,s1,s3
      pa += PGSIZE;
    8000086a:	994e                	add	s2,s2,s3
    8000086c:	b7d1                	j	80000830 <mappages+0xaa>
        return -1;
    8000086e:	557d                	li	a0,-1
    80000870:	a011                	j	80000874 <mappages+0xee>
  return 0;
    80000872:	4501                	li	a0,0
}
    80000874:	70e6                	ld	ra,120(sp)
    80000876:	7446                	ld	s0,112(sp)
    80000878:	74a6                	ld	s1,104(sp)
    8000087a:	7906                	ld	s2,96(sp)
    8000087c:	69e6                	ld	s3,88(sp)
    8000087e:	6a46                	ld	s4,80(sp)
    80000880:	6aa6                	ld	s5,72(sp)
    80000882:	6b06                	ld	s6,64(sp)
    80000884:	7be2                	ld	s7,56(sp)
    80000886:	7c42                	ld	s8,48(sp)
    80000888:	7ca2                	ld	s9,40(sp)
    8000088a:	7d02                	ld	s10,32(sp)
    8000088c:	6de2                	ld	s11,24(sp)
    8000088e:	6109                	addi	sp,sp,128
    80000890:	8082                	ret

0000000080000892 <kvmmap>:
{
    80000892:	1141                	addi	sp,sp,-16
    80000894:	e406                	sd	ra,8(sp)
    80000896:	e022                	sd	s0,0(sp)
    80000898:	0800                	addi	s0,sp,16
    8000089a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000089c:	86b2                	mv	a3,a2
    8000089e:	863e                	mv	a2,a5
    800008a0:	ee7ff0ef          	jal	ra,80000786 <mappages>
    800008a4:	e509                	bnez	a0,800008ae <kvmmap+0x1c>
}
    800008a6:	60a2                	ld	ra,8(sp)
    800008a8:	6402                	ld	s0,0(sp)
    800008aa:	0141                	addi	sp,sp,16
    800008ac:	8082                	ret
    panic("kvmmap");
    800008ae:	00007517          	auipc	a0,0x7
    800008b2:	87a50513          	addi	a0,a0,-1926 # 80007128 <etext+0x128>
    800008b6:	7bd040ef          	jal	ra,80005872 <panic>

00000000800008ba <kvmmake>:
{
    800008ba:	1101                	addi	sp,sp,-32
    800008bc:	ec06                	sd	ra,24(sp)
    800008be:	e822                	sd	s0,16(sp)
    800008c0:	e426                	sd	s1,8(sp)
    800008c2:	e04a                	sd	s2,0(sp)
    800008c4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800008c6:	fbcff0ef          	jal	ra,80000082 <kalloc>
    800008ca:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800008cc:	6605                	lui	a2,0x1
    800008ce:	4581                	li	a1,0
    800008d0:	96bff0ef          	jal	ra,8000023a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800008d4:	4719                	li	a4,6
    800008d6:	6685                	lui	a3,0x1
    800008d8:	10000637          	lui	a2,0x10000
    800008dc:	100005b7          	lui	a1,0x10000
    800008e0:	8526                	mv	a0,s1
    800008e2:	fb1ff0ef          	jal	ra,80000892 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800008e6:	4719                	li	a4,6
    800008e8:	6685                	lui	a3,0x1
    800008ea:	10001637          	lui	a2,0x10001
    800008ee:	100015b7          	lui	a1,0x10001
    800008f2:	8526                	mv	a0,s1
    800008f4:	f9fff0ef          	jal	ra,80000892 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800008f8:	4719                	li	a4,6
    800008fa:	040006b7          	lui	a3,0x4000
    800008fe:	0c000637          	lui	a2,0xc000
    80000902:	0c0005b7          	lui	a1,0xc000
    80000906:	8526                	mv	a0,s1
    80000908:	f8bff0ef          	jal	ra,80000892 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000090c:	00006917          	auipc	s2,0x6
    80000910:	6f490913          	addi	s2,s2,1780 # 80007000 <etext>
    80000914:	4729                	li	a4,10
    80000916:	80006697          	auipc	a3,0x80006
    8000091a:	6ea68693          	addi	a3,a3,1770 # 7000 <_entry-0x7fff9000>
    8000091e:	4605                	li	a2,1
    80000920:	067e                	slli	a2,a2,0x1f
    80000922:	85b2                	mv	a1,a2
    80000924:	8526                	mv	a0,s1
    80000926:	f6dff0ef          	jal	ra,80000892 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000092a:	4719                	li	a4,6
    8000092c:	46c5                	li	a3,17
    8000092e:	06ee                	slli	a3,a3,0x1b
    80000930:	412686b3          	sub	a3,a3,s2
    80000934:	864a                	mv	a2,s2
    80000936:	85ca                	mv	a1,s2
    80000938:	8526                	mv	a0,s1
    8000093a:	f59ff0ef          	jal	ra,80000892 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000093e:	4729                	li	a4,10
    80000940:	6685                	lui	a3,0x1
    80000942:	00005617          	auipc	a2,0x5
    80000946:	6be60613          	addi	a2,a2,1726 # 80006000 <_trampoline>
    8000094a:	040005b7          	lui	a1,0x4000
    8000094e:	15fd                	addi	a1,a1,-1
    80000950:	05b2                	slli	a1,a1,0xc
    80000952:	8526                	mv	a0,s1
    80000954:	f3fff0ef          	jal	ra,80000892 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000958:	8526                	mv	a0,s1
    8000095a:	730000ef          	jal	ra,8000108a <proc_mapstacks>
}
    8000095e:	8526                	mv	a0,s1
    80000960:	60e2                	ld	ra,24(sp)
    80000962:	6442                	ld	s0,16(sp)
    80000964:	64a2                	ld	s1,8(sp)
    80000966:	6902                	ld	s2,0(sp)
    80000968:	6105                	addi	sp,sp,32
    8000096a:	8082                	ret

000000008000096c <kvminit>:
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e406                	sd	ra,8(sp)
    80000970:	e022                	sd	s0,0(sp)
    80000972:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000974:	f47ff0ef          	jal	ra,800008ba <kvmmake>
    80000978:	00007797          	auipc	a5,0x7
    8000097c:	0ca7b823          	sd	a0,208(a5) # 80007a48 <kernel_pagetable>
}
    80000980:	60a2                	ld	ra,8(sp)
    80000982:	6402                	ld	s0,0(sp)
    80000984:	0141                	addi	sp,sp,16
    80000986:	8082                	ret

0000000080000988 <uvmunmap>:
{
    80000988:	7175                	addi	sp,sp,-144
    8000098a:	e506                	sd	ra,136(sp)
    8000098c:	e122                	sd	s0,128(sp)
    8000098e:	fca6                	sd	s1,120(sp)
    80000990:	f8ca                	sd	s2,112(sp)
    80000992:	f4ce                	sd	s3,104(sp)
    80000994:	f0d2                	sd	s4,96(sp)
    80000996:	ecd6                	sd	s5,88(sp)
    80000998:	e8da                	sd	s6,80(sp)
    8000099a:	e4de                	sd	s7,72(sp)
    8000099c:	e0e2                	sd	s8,64(sp)
    8000099e:	fc66                	sd	s9,56(sp)
    800009a0:	f86a                	sd	s10,48(sp)
    800009a2:	f46e                	sd	s11,40(sp)
    800009a4:	0900                	addi	s0,sp,144
  if((va % PGSIZE) != 0)
    800009a6:	03459793          	slli	a5,a1,0x34
    800009aa:	e395                	bnez	a5,800009ce <uvmunmap+0x46>
    800009ac:	8b2a                	mv	s6,a0
    800009ae:	84ae                	mv	s1,a1
    800009b0:	8bb6                	mv	s7,a3
  const uint64 limit = va + npages * PGSIZE;
    800009b2:	0632                	slli	a2,a2,0xc
    800009b4:	00b609b3          	add	s3,a2,a1
  while(current < limit) {
    800009b8:	1335f463          	bgeu	a1,s3,80000ae0 <uvmunmap+0x158>
    if(PTE_FLAGS(*pte) == PTE_V)
    800009bc:	4905                	li	s2,1
    int size = PGSIZE;
    800009be:	6a05                	lui	s4,0x1
        if(current % SUPERPGSIZE != 0) {
    800009c0:	002007b7          	lui	a5,0x200
    800009c4:	fff78d93          	addi	s11,a5,-1 # 1fffff <_entry-0x7fe00001>
          uint64 process_end = (limit < end) ? limit : end;
    800009c8:	f7343823          	sd	s3,-144(s0)
    800009cc:	a0e9                	j	80000a96 <uvmunmap+0x10e>
    panic("uvmunmap: address not page-aligned");
    800009ce:	00006517          	auipc	a0,0x6
    800009d2:	76250513          	addi	a0,a0,1890 # 80007130 <etext+0x130>
    800009d6:	69d040ef          	jal	ra,80005872 <panic>
      panic("uvmunmap: page table entry missing");
    800009da:	00006517          	auipc	a0,0x6
    800009de:	77e50513          	addi	a0,a0,1918 # 80007158 <etext+0x158>
    800009e2:	691040ef          	jal	ra,80005872 <panic>
      printf("Address: 0x%lx, PTE: 0x%lx\n", current, *pte);
    800009e6:	85a6                	mv	a1,s1
    800009e8:	00006517          	auipc	a0,0x6
    800009ec:	79850513          	addi	a0,a0,1944 # 80007180 <etext+0x180>
    800009f0:	3cf040ef          	jal	ra,800055be <printf>
      panic("uvmunmap: page not present");
    800009f4:	00006517          	auipc	a0,0x6
    800009f8:	7ac50513          	addi	a0,a0,1964 # 800071a0 <etext+0x1a0>
    800009fc:	677040ef          	jal	ra,80005872 <panic>
      panic("uvmunmap: invalid leaf entry");
    80000a00:	00006517          	auipc	a0,0x6
    80000a04:	7c050513          	addi	a0,a0,1984 # 800071c0 <etext+0x1c0>
    80000a08:	66b040ef          	jal	ra,80005872 <panic>
          uint64 base = SUPERPGROUNDDOWN(current);
    80000a0c:	ffe007b7          	lui	a5,0xffe00
    80000a10:	8fe5                	and	a5,a5,s1
          uint64 end = base + SUPERPGSIZE;
    80000a12:	00200737          	lui	a4,0x200
    80000a16:	00e78d33          	add	s10,a5,a4
          uint64 process_end = (limit < end) ? limit : end;
    80000a1a:	f7043c83          	ld	s9,-144(s0)
    80000a1e:	013d7363          	bgeu	s10,s3,80000a24 <uvmunmap+0x9c>
    80000a22:	8cea                	mv	s9,s10
          for(uint64 i = base; i < process_end; i += PGSIZE) {
    80000a24:	0597ff63          	bgeu	a5,s9,80000a82 <uvmunmap+0xfa>
    80000a28:	8abe                	mv	s5,a5
            memmove(new_page, (char*)pa + offset, PGSIZE);
    80000a2a:	40f507b3          	sub	a5,a0,a5
    80000a2e:	f6f43c23          	sd	a5,-136(s0)
    80000a32:	a811                	j	80000a46 <uvmunmap+0xbe>
            if(!new_page) panic("uvmunmap: page allocation error");
    80000a34:	00006517          	auipc	a0,0x6
    80000a38:	7ac50513          	addi	a0,a0,1964 # 800071e0 <etext+0x1e0>
    80000a3c:	637040ef          	jal	ra,80005872 <panic>
          for(uint64 i = base; i < process_end; i += PGSIZE) {
    80000a40:	9ad2                	add	s5,s5,s4
    80000a42:	059af063          	bgeu	s5,s9,80000a82 <uvmunmap+0xfa>
            if(i < current) continue;
    80000a46:	fe9aede3          	bltu	s5,s1,80000a40 <uvmunmap+0xb8>
            char *new_page = kalloc();
    80000a4a:	e38ff0ef          	jal	ra,80000082 <kalloc>
    80000a4e:	8c2a                	mv	s8,a0
            if(!new_page) panic("uvmunmap: page allocation error");
    80000a50:	d175                	beqz	a0,80000a34 <uvmunmap+0xac>
            memmove(new_page, (char*)pa + offset, PGSIZE);
    80000a52:	8652                	mv	a2,s4
    80000a54:	f7843783          	ld	a5,-136(s0)
    80000a58:	015785b3          	add	a1,a5,s5
    80000a5c:	83fff0ef          	jal	ra,8000029a <memmove>
            if(mappages(pagetable, i, PGSIZE, (uint64)new_page, perm_flags) != 0) {
    80000a60:	4701                	li	a4,0
    80000a62:	86e2                	mv	a3,s8
    80000a64:	8652                	mv	a2,s4
    80000a66:	85d6                	mv	a1,s5
    80000a68:	855a                	mv	a0,s6
    80000a6a:	d1dff0ef          	jal	ra,80000786 <mappages>
    80000a6e:	d969                	beqz	a0,80000a40 <uvmunmap+0xb8>
              kfree(new_page);
    80000a70:	8562                	mv	a0,s8
    80000a72:	daaff0ef          	jal	ra,8000001c <kfree>
              panic("uvmunmap: remapping failed");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	78a50513          	addi	a0,a0,1930 # 80007200 <etext+0x200>
    80000a7e:	5f5040ef          	jal	ra,80005872 <panic>
          current = end;
    80000a82:	84ea                	mv	s1,s10
    80000a84:	a039                	j	80000a92 <uvmunmap+0x10a>
        kfree((void*)pa);
    80000a86:	d96ff0ef          	jal	ra,8000001c <kfree>
    int size = PGSIZE;
    80000a8a:	87d2                	mv	a5,s4
    80000a8c:	a011                	j	80000a90 <uvmunmap+0x108>
    80000a8e:	87d2                	mv	a5,s4
    current += size;
    80000a90:	94be                	add	s1,s1,a5
  while(current < limit) {
    80000a92:	0534f763          	bgeu	s1,s3,80000ae0 <uvmunmap+0x158>
    int level = 0;
    80000a96:	f8042623          	sw	zero,-116(s0)
    pte = superwalk(pagetable, current, 0, &level);
    80000a9a:	f8c40693          	addi	a3,s0,-116
    80000a9e:	4601                	li	a2,0
    80000aa0:	85a6                	mv	a1,s1
    80000aa2:	855a                	mv	a0,s6
    80000aa4:	be3ff0ef          	jal	ra,80000686 <superwalk>
    if(!pte) 
    80000aa8:	d90d                	beqz	a0,800009da <uvmunmap+0x52>
    if(!(*pte & PTE_V)) {
    80000aaa:	6110                	ld	a2,0(a0)
    80000aac:	00167793          	andi	a5,a2,1
    80000ab0:	db9d                	beqz	a5,800009e6 <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000ab2:	3ff67793          	andi	a5,a2,1023
    80000ab6:	f52785e3          	beq	a5,s2,80000a00 <uvmunmap+0x78>
    *pte = 0;  // 清除页表项
    80000aba:	00053023          	sd	zero,0(a0)
    if(do_free) {
    80000abe:	fc0b88e3          	beqz	s7,80000a8e <uvmunmap+0x106>
    uint64 pa = PTE2PA(*pte);
    80000ac2:	8229                	srli	a2,a2,0xa
    80000ac4:	00c61513          	slli	a0,a2,0xc
      if(level == 1) {
    80000ac8:	f8c42783          	lw	a5,-116(s0)
    80000acc:	fb279de3          	bne	a5,s2,80000a86 <uvmunmap+0xfe>
        if(current % SUPERPGSIZE != 0) {
    80000ad0:	01b4f7b3          	and	a5,s1,s11
    80000ad4:	ff85                	bnez	a5,80000a0c <uvmunmap+0x84>
        superfree((void*)pa);
    80000ad6:	dfcff0ef          	jal	ra,800000d2 <superfree>
        size = SUPERPGSIZE;
    80000ada:	002007b7          	lui	a5,0x200
    80000ade:	bf4d                	j	80000a90 <uvmunmap+0x108>
}
    80000ae0:	60aa                	ld	ra,136(sp)
    80000ae2:	640a                	ld	s0,128(sp)
    80000ae4:	74e6                	ld	s1,120(sp)
    80000ae6:	7946                	ld	s2,112(sp)
    80000ae8:	79a6                	ld	s3,104(sp)
    80000aea:	7a06                	ld	s4,96(sp)
    80000aec:	6ae6                	ld	s5,88(sp)
    80000aee:	6b46                	ld	s6,80(sp)
    80000af0:	6ba6                	ld	s7,72(sp)
    80000af2:	6c06                	ld	s8,64(sp)
    80000af4:	7ce2                	ld	s9,56(sp)
    80000af6:	7d42                	ld	s10,48(sp)
    80000af8:	7da2                	ld	s11,40(sp)
    80000afa:	6149                	addi	sp,sp,144
    80000afc:	8082                	ret

0000000080000afe <uvmcreate>:
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    80000b08:	d7aff0ef          	jal	ra,80000082 <kalloc>
    80000b0c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000b0e:	c509                	beqz	a0,80000b18 <uvmcreate+0x1a>
  memset(pagetable, 0, PGSIZE);
    80000b10:	6605                	lui	a2,0x1
    80000b12:	4581                	li	a1,0
    80000b14:	f26ff0ef          	jal	ra,8000023a <memset>
}
    80000b18:	8526                	mv	a0,s1
    80000b1a:	60e2                	ld	ra,24(sp)
    80000b1c:	6442                	ld	s0,16(sp)
    80000b1e:	64a2                	ld	s1,8(sp)
    80000b20:	6105                	addi	sp,sp,32
    80000b22:	8082                	ret

0000000080000b24 <uvmfirst>:
{
    80000b24:	7179                	addi	sp,sp,-48
    80000b26:	f406                	sd	ra,40(sp)
    80000b28:	f022                	sd	s0,32(sp)
    80000b2a:	ec26                	sd	s1,24(sp)
    80000b2c:	e84a                	sd	s2,16(sp)
    80000b2e:	e44e                	sd	s3,8(sp)
    80000b30:	e052                	sd	s4,0(sp)
    80000b32:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80000b34:	6785                	lui	a5,0x1
    80000b36:	04f67063          	bgeu	a2,a5,80000b76 <uvmfirst+0x52>
    80000b3a:	8a2a                	mv	s4,a0
    80000b3c:	89ae                	mv	s3,a1
    80000b3e:	84b2                	mv	s1,a2
  mem = kalloc();
    80000b40:	d42ff0ef          	jal	ra,80000082 <kalloc>
    80000b44:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000b46:	6605                	lui	a2,0x1
    80000b48:	4581                	li	a1,0
    80000b4a:	ef0ff0ef          	jal	ra,8000023a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000b4e:	4779                	li	a4,30
    80000b50:	86ca                	mv	a3,s2
    80000b52:	6605                	lui	a2,0x1
    80000b54:	4581                	li	a1,0
    80000b56:	8552                	mv	a0,s4
    80000b58:	c2fff0ef          	jal	ra,80000786 <mappages>
  memmove(mem, src, sz);
    80000b5c:	8626                	mv	a2,s1
    80000b5e:	85ce                	mv	a1,s3
    80000b60:	854a                	mv	a0,s2
    80000b62:	f38ff0ef          	jal	ra,8000029a <memmove>
}
    80000b66:	70a2                	ld	ra,40(sp)
    80000b68:	7402                	ld	s0,32(sp)
    80000b6a:	64e2                	ld	s1,24(sp)
    80000b6c:	6942                	ld	s2,16(sp)
    80000b6e:	69a2                	ld	s3,8(sp)
    80000b70:	6a02                	ld	s4,0(sp)
    80000b72:	6145                	addi	sp,sp,48
    80000b74:	8082                	ret
    panic("uvmfirst: more than a page");
    80000b76:	00006517          	auipc	a0,0x6
    80000b7a:	6aa50513          	addi	a0,a0,1706 # 80007220 <etext+0x220>
    80000b7e:	4f5040ef          	jal	ra,80005872 <panic>

0000000080000b82 <uvmdealloc>:
{
    80000b82:	1101                	addi	sp,sp,-32
    80000b84:	ec06                	sd	ra,24(sp)
    80000b86:	e822                	sd	s0,16(sp)
    80000b88:	e426                	sd	s1,8(sp)
    80000b8a:	1000                	addi	s0,sp,32
    return oldsz;
    80000b8c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80000b8e:	00b67d63          	bgeu	a2,a1,80000ba8 <uvmdealloc+0x26>
    80000b92:	84b2                	mv	s1,a2
  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000b94:	6785                	lui	a5,0x1
    80000b96:	17fd                	addi	a5,a5,-1
    80000b98:	00f60733          	add	a4,a2,a5
    80000b9c:	767d                	lui	a2,0xfffff
    80000b9e:	8f71                	and	a4,a4,a2
    80000ba0:	97ae                	add	a5,a5,a1
    80000ba2:	8ff1                	and	a5,a5,a2
    80000ba4:	00f76863          	bltu	a4,a5,80000bb4 <uvmdealloc+0x32>
}
    80000ba8:	8526                	mv	a0,s1
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000bb4:	8f99                	sub	a5,a5,a4
    80000bb6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000bb8:	4685                	li	a3,1
    80000bba:	0007861b          	sext.w	a2,a5
    80000bbe:	85ba                	mv	a1,a4
    80000bc0:	dc9ff0ef          	jal	ra,80000988 <uvmunmap>
    80000bc4:	b7d5                	j	80000ba8 <uvmdealloc+0x26>

0000000080000bc6 <uvmalloc>:
  if(new_size < old_size) return old_size;
    80000bc6:	0cb66c63          	bltu	a2,a1,80000c9e <uvmalloc+0xd8>
{
    80000bca:	711d                	addi	sp,sp,-96
    80000bcc:	ec86                	sd	ra,88(sp)
    80000bce:	e8a2                	sd	s0,80(sp)
    80000bd0:	e4a6                	sd	s1,72(sp)
    80000bd2:	e0ca                	sd	s2,64(sp)
    80000bd4:	fc4e                	sd	s3,56(sp)
    80000bd6:	f852                	sd	s4,48(sp)
    80000bd8:	f456                	sd	s5,40(sp)
    80000bda:	f05a                	sd	s6,32(sp)
    80000bdc:	ec5e                	sd	s7,24(sp)
    80000bde:	e862                	sd	s8,16(sp)
    80000be0:	e466                	sd	s9,8(sp)
    80000be2:	e06a                	sd	s10,0(sp)
    80000be4:	1080                	addi	s0,sp,96
    80000be6:	8b2a                	mv	s6,a0
    80000be8:	89b2                	mv	s3,a2
  old_size = PGROUNDUP(old_size);
    80000bea:	6a05                	lui	s4,0x1
    80000bec:	1a7d                	addi	s4,s4,-1
    80000bee:	95d2                	add	a1,a1,s4
    80000bf0:	7a7d                	lui	s4,0xfffff
    80000bf2:	0145fa33          	and	s4,a1,s4
  while(current_va < new_size) {
    80000bf6:	0aca7663          	bgeu	s4,a2,80000ca2 <uvmalloc+0xdc>
  uint64 current_va = old_size;
    80000bfa:	8952                	mv	s2,s4
    if(remaining >= SUPERPGSIZE && (current_va % SUPERPGSIZE == 0)) {
    80000bfc:	00200bb7          	lui	s7,0x200
    uint64 alloc_size = PGSIZE;
    80000c00:	6c05                	lui	s8,0x1
    if(remaining >= SUPERPGSIZE && (current_va % SUPERPGSIZE == 0)) {
    80000c02:	fffb8c93          	addi	s9,s7,-1 # 1fffff <_entry-0x7fe00001>
    int map_result = mappages(pagetable, current_va, alloc_size, 
    80000c06:	0126ea93          	ori	s5,a3,18
    80000c0a:	a035                	j	80000c36 <uvmalloc+0x70>
      new_mem = kalloc();
    80000c0c:	c76ff0ef          	jal	ra,80000082 <kalloc>
    80000c10:	84aa                	mv	s1,a0
    uint64 alloc_size = PGSIZE;
    80000c12:	8d62                	mv	s10,s8
    if(!new_mem) {
    80000c14:	cc8d                	beqz	s1,80000c4e <uvmalloc+0x88>
    memset(new_mem, 0, alloc_size);
    80000c16:	866a                	mv	a2,s10
    80000c18:	4581                	li	a1,0
    80000c1a:	8526                	mv	a0,s1
    80000c1c:	e1eff0ef          	jal	ra,8000023a <memset>
    int map_result = mappages(pagetable, current_va, alloc_size, 
    80000c20:	8756                	mv	a4,s5
    80000c22:	86a6                	mv	a3,s1
    80000c24:	866a                	mv	a2,s10
    80000c26:	85ca                	mv	a1,s2
    80000c28:	855a                	mv	a0,s6
    80000c2a:	b5dff0ef          	jal	ra,80000786 <mappages>
    if(map_result != 0) {
    80000c2e:	e521                	bnez	a0,80000c76 <uvmalloc+0xb0>
    current_va += alloc_size;
    80000c30:	996a                	add	s2,s2,s10
  while(current_va < new_size) {
    80000c32:	07397463          	bgeu	s2,s3,80000c9a <uvmalloc+0xd4>
    uint64 remaining = new_size - current_va;
    80000c36:	412987b3          	sub	a5,s3,s2
    if(remaining >= SUPERPGSIZE && (current_va % SUPERPGSIZE == 0)) {
    80000c3a:	fd77e9e3          	bltu	a5,s7,80000c0c <uvmalloc+0x46>
    80000c3e:	019977b3          	and	a5,s2,s9
    80000c42:	f7e9                	bnez	a5,80000c0c <uvmalloc+0x46>
      new_mem = superalloc();
    80000c44:	da4ff0ef          	jal	ra,800001e8 <superalloc>
    80000c48:	84aa                	mv	s1,a0
      alloc_size = SUPERPGSIZE;
    80000c4a:	8d5e                	mv	s10,s7
      new_mem = superalloc();
    80000c4c:	b7e1                	j	80000c14 <uvmalloc+0x4e>
      uvmdealloc(pagetable, current_va, old_size);
    80000c4e:	8652                	mv	a2,s4
    80000c50:	85ca                	mv	a1,s2
    80000c52:	855a                	mv	a0,s6
    80000c54:	f2fff0ef          	jal	ra,80000b82 <uvmdealloc>
      return 0;
    80000c58:	4501                	li	a0,0
}
    80000c5a:	60e6                	ld	ra,88(sp)
    80000c5c:	6446                	ld	s0,80(sp)
    80000c5e:	64a6                	ld	s1,72(sp)
    80000c60:	6906                	ld	s2,64(sp)
    80000c62:	79e2                	ld	s3,56(sp)
    80000c64:	7a42                	ld	s4,48(sp)
    80000c66:	7aa2                	ld	s5,40(sp)
    80000c68:	7b02                	ld	s6,32(sp)
    80000c6a:	6be2                	ld	s7,24(sp)
    80000c6c:	6c42                	ld	s8,16(sp)
    80000c6e:	6ca2                	ld	s9,8(sp)
    80000c70:	6d02                	ld	s10,0(sp)
    80000c72:	6125                	addi	sp,sp,96
    80000c74:	8082                	ret
      if(alloc_size == SUPERPGSIZE) 
    80000c76:	002007b7          	lui	a5,0x200
    80000c7a:	00fd0c63          	beq	s10,a5,80000c92 <uvmalloc+0xcc>
        kfree(new_mem);
    80000c7e:	8526                	mv	a0,s1
    80000c80:	b9cff0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, current_va, old_size);
    80000c84:	8652                	mv	a2,s4
    80000c86:	85ca                	mv	a1,s2
    80000c88:	855a                	mv	a0,s6
    80000c8a:	ef9ff0ef          	jal	ra,80000b82 <uvmdealloc>
      return 0;
    80000c8e:	4501                	li	a0,0
    80000c90:	b7e9                	j	80000c5a <uvmalloc+0x94>
        superfree(new_mem);
    80000c92:	8526                	mv	a0,s1
    80000c94:	c3eff0ef          	jal	ra,800000d2 <superfree>
    80000c98:	b7f5                	j	80000c84 <uvmalloc+0xbe>
  return new_size;
    80000c9a:	854e                	mv	a0,s3
    80000c9c:	bf7d                	j	80000c5a <uvmalloc+0x94>
  if(new_size < old_size) return old_size;
    80000c9e:	852e                	mv	a0,a1
}
    80000ca0:	8082                	ret
  return new_size;
    80000ca2:	8532                	mv	a0,a2
    80000ca4:	bf5d                	j	80000c5a <uvmalloc+0x94>

0000000080000ca6 <freewalk>:
{
    80000ca6:	7179                	addi	sp,sp,-48
    80000ca8:	f406                	sd	ra,40(sp)
    80000caa:	f022                	sd	s0,32(sp)
    80000cac:	ec26                	sd	s1,24(sp)
    80000cae:	e84a                	sd	s2,16(sp)
    80000cb0:	e44e                	sd	s3,8(sp)
    80000cb2:	e052                	sd	s4,0(sp)
    80000cb4:	1800                	addi	s0,sp,48
    80000cb6:	8a2a                	mv	s4,a0
  for(int i = 0; i < 512; i++){
    80000cb8:	84aa                	mv	s1,a0
    80000cba:	6905                	lui	s2,0x1
    80000cbc:	992a                	add	s2,s2,a0
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000cbe:	4985                	li	s3,1
    80000cc0:	a811                	j	80000cd4 <freewalk+0x2e>
      uint64 child = PTE2PA(pte);
    80000cc2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000cc4:	0532                	slli	a0,a0,0xc
    80000cc6:	fe1ff0ef          	jal	ra,80000ca6 <freewalk>
      pagetable[i] = 0;
    80000cca:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000cce:	04a1                	addi	s1,s1,8
    80000cd0:	01248f63          	beq	s1,s2,80000cee <freewalk+0x48>
    pte_t pte = pagetable[i];
    80000cd4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000cd6:	00f57793          	andi	a5,a0,15
    80000cda:	ff3784e3          	beq	a5,s3,80000cc2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000cde:	8905                	andi	a0,a0,1
    80000ce0:	d57d                	beqz	a0,80000cce <freewalk+0x28>
      panic("freewalk: leaf");
    80000ce2:	00006517          	auipc	a0,0x6
    80000ce6:	55e50513          	addi	a0,a0,1374 # 80007240 <etext+0x240>
    80000cea:	389040ef          	jal	ra,80005872 <panic>
  kfree((void*)pagetable);
    80000cee:	8552                	mv	a0,s4
    80000cf0:	b2cff0ef          	jal	ra,8000001c <kfree>
}
    80000cf4:	70a2                	ld	ra,40(sp)
    80000cf6:	7402                	ld	s0,32(sp)
    80000cf8:	64e2                	ld	s1,24(sp)
    80000cfa:	6942                	ld	s2,16(sp)
    80000cfc:	69a2                	ld	s3,8(sp)
    80000cfe:	6a02                	ld	s4,0(sp)
    80000d00:	6145                	addi	sp,sp,48
    80000d02:	8082                	ret

0000000080000d04 <uvmfree>:
{
    80000d04:	1101                	addi	sp,sp,-32
    80000d06:	ec06                	sd	ra,24(sp)
    80000d08:	e822                	sd	s0,16(sp)
    80000d0a:	e426                	sd	s1,8(sp)
    80000d0c:	1000                	addi	s0,sp,32
    80000d0e:	84aa                	mv	s1,a0
  if(sz > 0)
    80000d10:	e989                	bnez	a1,80000d22 <uvmfree+0x1e>
  freewalk(pagetable);
    80000d12:	8526                	mv	a0,s1
    80000d14:	f93ff0ef          	jal	ra,80000ca6 <freewalk>
}
    80000d18:	60e2                	ld	ra,24(sp)
    80000d1a:	6442                	ld	s0,16(sp)
    80000d1c:	64a2                	ld	s1,8(sp)
    80000d1e:	6105                	addi	sp,sp,32
    80000d20:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000d22:	6605                	lui	a2,0x1
    80000d24:	167d                	addi	a2,a2,-1
    80000d26:	962e                	add	a2,a2,a1
    80000d28:	4685                	li	a3,1
    80000d2a:	8231                	srli	a2,a2,0xc
    80000d2c:	4581                	li	a1,0
    80000d2e:	c5bff0ef          	jal	ra,80000988 <uvmunmap>
    80000d32:	b7c5                	j	80000d12 <uvmfree+0xe>

0000000080000d34 <uvmcopy>:
  while(current_va < size) {
    80000d34:	0e060d63          	beqz	a2,80000e2e <uvmcopy+0xfa>
{
    80000d38:	711d                	addi	sp,sp,-96
    80000d3a:	ec86                	sd	ra,88(sp)
    80000d3c:	e8a2                	sd	s0,80(sp)
    80000d3e:	e4a6                	sd	s1,72(sp)
    80000d40:	e0ca                	sd	s2,64(sp)
    80000d42:	fc4e                	sd	s3,56(sp)
    80000d44:	f852                	sd	s4,48(sp)
    80000d46:	f456                	sd	s5,40(sp)
    80000d48:	f05a                	sd	s6,32(sp)
    80000d4a:	ec5e                	sd	s7,24(sp)
    80000d4c:	e862                	sd	s8,16(sp)
    80000d4e:	1080                	addi	s0,sp,96
    80000d50:	8baa                	mv	s7,a0
    80000d52:	8b2e                	mv	s6,a1
    80000d54:	8ab2                	mv	s5,a2
  uint64 current_va = 0;
    80000d56:	4901                	li	s2,0
    if(page_level == 1) {
    80000d58:	4c05                	li	s8,1
    80000d5a:	a0a1                	j	80000da2 <uvmcopy+0x6e>
    if(!src_pte) panic("uvmcopy: pte missing");
    80000d5c:	00006517          	auipc	a0,0x6
    80000d60:	4f450513          	addi	a0,a0,1268 # 80007250 <etext+0x250>
    80000d64:	30f040ef          	jal	ra,80005872 <panic>
    if(!(*src_pte & PTE_V)) panic("uvmcopy: page absent");
    80000d68:	00006517          	auipc	a0,0x6
    80000d6c:	50050513          	addi	a0,a0,1280 # 80007268 <etext+0x268>
    80000d70:	303040ef          	jal	ra,80005872 <panic>
      new_mem = superalloc();
    80000d74:	c74ff0ef          	jal	ra,800001e8 <superalloc>
    80000d78:	8a2a                	mv	s4,a0
      if(!new_mem) goto error;
    80000d7a:	c541                	beqz	a0,80000e02 <uvmcopy+0xce>
      memmove(new_mem, (char*)phys_src, copy_size);
    80000d7c:	00200637          	lui	a2,0x200
    80000d80:	85ce                	mv	a1,s3
    80000d82:	d18ff0ef          	jal	ra,8000029a <memmove>
      if(mappages(dst_pg, current_va, copy_size, (uint64)new_mem, flags)) {
    80000d86:	8726                	mv	a4,s1
    80000d88:	86d2                	mv	a3,s4
    80000d8a:	00200637          	lui	a2,0x200
    80000d8e:	85ca                	mv	a1,s2
    80000d90:	855a                	mv	a0,s6
    80000d92:	9f5ff0ef          	jal	ra,80000786 <mappages>
    80000d96:	ed39                	bnez	a0,80000df4 <uvmcopy+0xc0>
      copy_size = SUPERPGSIZE;
    80000d98:	002007b7          	lui	a5,0x200
    current_va += copy_size;
    80000d9c:	993e                	add	s2,s2,a5
  while(current_va < size) {
    80000d9e:	09597663          	bgeu	s2,s5,80000e2a <uvmcopy+0xf6>
    int page_level = 0;
    80000da2:	fa042623          	sw	zero,-84(s0)
    src_pte = superwalk(src_pg, current_va, 0, &page_level);
    80000da6:	fac40693          	addi	a3,s0,-84
    80000daa:	4601                	li	a2,0
    80000dac:	85ca                	mv	a1,s2
    80000dae:	855e                	mv	a0,s7
    80000db0:	8d7ff0ef          	jal	ra,80000686 <superwalk>
    if(!src_pte) panic("uvmcopy: pte missing");
    80000db4:	d545                	beqz	a0,80000d5c <uvmcopy+0x28>
    if(!(*src_pte & PTE_V)) panic("uvmcopy: page absent");
    80000db6:	6118                	ld	a4,0(a0)
    80000db8:	00177793          	andi	a5,a4,1
    80000dbc:	d7d5                	beqz	a5,80000d68 <uvmcopy+0x34>
    uint64 phys_src = PTE2PA(*src_pte);
    80000dbe:	00a75993          	srli	s3,a4,0xa
    80000dc2:	09b2                	slli	s3,s3,0xc
    uint flags = PTE_FLAGS(*src_pte);
    80000dc4:	3ff77493          	andi	s1,a4,1023
    if(page_level == 1) {
    80000dc8:	fac42783          	lw	a5,-84(s0)
    80000dcc:	fb8784e3          	beq	a5,s8,80000d74 <uvmcopy+0x40>
      new_mem = kalloc();
    80000dd0:	ab2ff0ef          	jal	ra,80000082 <kalloc>
    80000dd4:	8a2a                	mv	s4,a0
      if(!new_mem) goto error;
    80000dd6:	c515                	beqz	a0,80000e02 <uvmcopy+0xce>
      memmove(new_mem, (char*)phys_src, PGSIZE);
    80000dd8:	6605                	lui	a2,0x1
    80000dda:	85ce                	mv	a1,s3
    80000ddc:	cbeff0ef          	jal	ra,8000029a <memmove>
      if(mappages(dst_pg, current_va, PGSIZE, (uint64)new_mem, flags)) {
    80000de0:	8726                	mv	a4,s1
    80000de2:	86d2                	mv	a3,s4
    80000de4:	6605                	lui	a2,0x1
    80000de6:	85ca                	mv	a1,s2
    80000de8:	855a                	mv	a0,s6
    80000dea:	99dff0ef          	jal	ra,80000786 <mappages>
    80000dee:	e519                	bnez	a0,80000dfc <uvmcopy+0xc8>
    uint64 copy_size = PGSIZE;
    80000df0:	6785                	lui	a5,0x1
    80000df2:	b76d                	j	80000d9c <uvmcopy+0x68>
        superfree(new_mem);
    80000df4:	8552                	mv	a0,s4
    80000df6:	adcff0ef          	jal	ra,800000d2 <superfree>
        goto error;
    80000dfa:	a021                	j	80000e02 <uvmcopy+0xce>
        kfree(new_mem);
    80000dfc:	8552                	mv	a0,s4
    80000dfe:	a1eff0ef          	jal	ra,8000001c <kfree>
  uvmunmap(dst_pg, 0, current_va / PGSIZE, 1);
    80000e02:	4685                	li	a3,1
    80000e04:	00c95613          	srli	a2,s2,0xc
    80000e08:	4581                	li	a1,0
    80000e0a:	855a                	mv	a0,s6
    80000e0c:	b7dff0ef          	jal	ra,80000988 <uvmunmap>
  return -1;
    80000e10:	557d                	li	a0,-1
}
    80000e12:	60e6                	ld	ra,88(sp)
    80000e14:	6446                	ld	s0,80(sp)
    80000e16:	64a6                	ld	s1,72(sp)
    80000e18:	6906                	ld	s2,64(sp)
    80000e1a:	79e2                	ld	s3,56(sp)
    80000e1c:	7a42                	ld	s4,48(sp)
    80000e1e:	7aa2                	ld	s5,40(sp)
    80000e20:	7b02                	ld	s6,32(sp)
    80000e22:	6be2                	ld	s7,24(sp)
    80000e24:	6c42                	ld	s8,16(sp)
    80000e26:	6125                	addi	sp,sp,96
    80000e28:	8082                	ret
  return 0;
    80000e2a:	4501                	li	a0,0
    80000e2c:	b7dd                	j	80000e12 <uvmcopy+0xde>
    80000e2e:	4501                	li	a0,0
}
    80000e30:	8082                	ret

0000000080000e32 <uvmclear>:
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e406                	sd	ra,8(sp)
    80000e36:	e022                	sd	s0,0(sp)
    80000e38:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000e3a:	4601                	li	a2,0
    80000e3c:	fa8ff0ef          	jal	ra,800005e4 <walk>
  if(pte == 0)
    80000e40:	c901                	beqz	a0,80000e50 <uvmclear+0x1e>
  *pte &= ~PTE_U;
    80000e42:	611c                	ld	a5,0(a0)
    80000e44:	9bbd                	andi	a5,a5,-17
    80000e46:	e11c                	sd	a5,0(a0)
}
    80000e48:	60a2                	ld	ra,8(sp)
    80000e4a:	6402                	ld	s0,0(sp)
    80000e4c:	0141                	addi	sp,sp,16
    80000e4e:	8082                	ret
    panic("uvmclear");
    80000e50:	00006517          	auipc	a0,0x6
    80000e54:	43050513          	addi	a0,a0,1072 # 80007280 <etext+0x280>
    80000e58:	21b040ef          	jal	ra,80005872 <panic>

0000000080000e5c <copyout>:
  while(len > 0){
    80000e5c:	c6c1                	beqz	a3,80000ee4 <copyout+0x88>
{
    80000e5e:	711d                	addi	sp,sp,-96
    80000e60:	ec86                	sd	ra,88(sp)
    80000e62:	e8a2                	sd	s0,80(sp)
    80000e64:	e4a6                	sd	s1,72(sp)
    80000e66:	e0ca                	sd	s2,64(sp)
    80000e68:	fc4e                	sd	s3,56(sp)
    80000e6a:	f852                	sd	s4,48(sp)
    80000e6c:	f456                	sd	s5,40(sp)
    80000e6e:	f05a                	sd	s6,32(sp)
    80000e70:	ec5e                	sd	s7,24(sp)
    80000e72:	e862                	sd	s8,16(sp)
    80000e74:	e466                	sd	s9,8(sp)
    80000e76:	1080                	addi	s0,sp,96
    80000e78:	8b2a                	mv	s6,a0
    80000e7a:	8a2e                	mv	s4,a1
    80000e7c:	8ab2                	mv	s5,a2
    80000e7e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000e80:	74fd                	lui	s1,0xfffff
    80000e82:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000e84:	57fd                	li	a5,-1
    80000e86:	83e9                	srli	a5,a5,0x1a
    80000e88:	0697e063          	bltu	a5,s1,80000ee8 <copyout+0x8c>
    80000e8c:	6c05                	lui	s8,0x1
    80000e8e:	8bbe                	mv	s7,a5
    80000e90:	a015                	j	80000eb4 <copyout+0x58>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000e92:	409a04b3          	sub	s1,s4,s1
    80000e96:	0009061b          	sext.w	a2,s2
    80000e9a:	85d6                	mv	a1,s5
    80000e9c:	9526                	add	a0,a0,s1
    80000e9e:	bfcff0ef          	jal	ra,8000029a <memmove>
    len -= n;
    80000ea2:	412989b3          	sub	s3,s3,s2
    src += n;
    80000ea6:	9aca                	add	s5,s5,s2
  while(len > 0){
    80000ea8:	02098c63          	beqz	s3,80000ee0 <copyout+0x84>
    if (va0 >= MAXVA)
    80000eac:	059be063          	bltu	s7,s9,80000eec <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80000eb0:	84e6                	mv	s1,s9
    dstva = va0 + PGSIZE;
    80000eb2:	8a66                	mv	s4,s9
    if((pte = walk(pagetable, va0, 0)) == 0) {
    80000eb4:	4601                	li	a2,0
    80000eb6:	85a6                	mv	a1,s1
    80000eb8:	855a                	mv	a0,s6
    80000eba:	f2aff0ef          	jal	ra,800005e4 <walk>
    80000ebe:	c90d                	beqz	a0,80000ef0 <copyout+0x94>
    if((*pte & PTE_W) == 0)
    80000ec0:	611c                	ld	a5,0(a0)
    80000ec2:	8b91                	andi	a5,a5,4
    80000ec4:	c7a1                	beqz	a5,80000f0c <copyout+0xb0>
    pa0 = walkaddr(pagetable, va0);
    80000ec6:	85a6                	mv	a1,s1
    80000ec8:	855a                	mv	a0,s6
    80000eca:	87fff0ef          	jal	ra,80000748 <walkaddr>
    if(pa0 == 0)
    80000ece:	c129                	beqz	a0,80000f10 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000ed0:	01848cb3          	add	s9,s1,s8
    80000ed4:	414c8933          	sub	s2,s9,s4
    if(n > len)
    80000ed8:	fb29fde3          	bgeu	s3,s2,80000e92 <copyout+0x36>
    80000edc:	894e                	mv	s2,s3
    80000ede:	bf55                	j	80000e92 <copyout+0x36>
  return 0;
    80000ee0:	4501                	li	a0,0
    80000ee2:	a801                	j	80000ef2 <copyout+0x96>
    80000ee4:	4501                	li	a0,0
}
    80000ee6:	8082                	ret
      return -1;
    80000ee8:	557d                	li	a0,-1
    80000eea:	a021                	j	80000ef2 <copyout+0x96>
    80000eec:	557d                	li	a0,-1
    80000eee:	a011                	j	80000ef2 <copyout+0x96>
      return -1;
    80000ef0:	557d                	li	a0,-1
}
    80000ef2:	60e6                	ld	ra,88(sp)
    80000ef4:	6446                	ld	s0,80(sp)
    80000ef6:	64a6                	ld	s1,72(sp)
    80000ef8:	6906                	ld	s2,64(sp)
    80000efa:	79e2                	ld	s3,56(sp)
    80000efc:	7a42                	ld	s4,48(sp)
    80000efe:	7aa2                	ld	s5,40(sp)
    80000f00:	7b02                	ld	s6,32(sp)
    80000f02:	6be2                	ld	s7,24(sp)
    80000f04:	6c42                	ld	s8,16(sp)
    80000f06:	6ca2                	ld	s9,8(sp)
    80000f08:	6125                	addi	sp,sp,96
    80000f0a:	8082                	ret
      return -1;
    80000f0c:	557d                	li	a0,-1
    80000f0e:	b7d5                	j	80000ef2 <copyout+0x96>
      return -1;
    80000f10:	557d                	li	a0,-1
    80000f12:	b7c5                	j	80000ef2 <copyout+0x96>

0000000080000f14 <copyin>:
  while(len > 0){
    80000f14:	c2bd                	beqz	a3,80000f7a <copyin+0x66>
{
    80000f16:	715d                	addi	sp,sp,-80
    80000f18:	e486                	sd	ra,72(sp)
    80000f1a:	e0a2                	sd	s0,64(sp)
    80000f1c:	fc26                	sd	s1,56(sp)
    80000f1e:	f84a                	sd	s2,48(sp)
    80000f20:	f44e                	sd	s3,40(sp)
    80000f22:	f052                	sd	s4,32(sp)
    80000f24:	ec56                	sd	s5,24(sp)
    80000f26:	e85a                	sd	s6,16(sp)
    80000f28:	e45e                	sd	s7,8(sp)
    80000f2a:	e062                	sd	s8,0(sp)
    80000f2c:	0880                	addi	s0,sp,80
    80000f2e:	8b2a                	mv	s6,a0
    80000f30:	8a2e                	mv	s4,a1
    80000f32:	8c32                	mv	s8,a2
    80000f34:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000f36:	7bfd                	lui	s7,0xfffff
    n = PGSIZE - (srcva - va0);
    80000f38:	6a85                	lui	s5,0x1
    80000f3a:	a005                	j	80000f5a <copyin+0x46>
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000f3c:	9562                	add	a0,a0,s8
    80000f3e:	0004861b          	sext.w	a2,s1
    80000f42:	412505b3          	sub	a1,a0,s2
    80000f46:	8552                	mv	a0,s4
    80000f48:	b52ff0ef          	jal	ra,8000029a <memmove>
    len -= n;
    80000f4c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000f50:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000f52:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000f56:	02098063          	beqz	s3,80000f76 <copyin+0x62>
    va0 = PGROUNDDOWN(srcva);
    80000f5a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000f5e:	85ca                	mv	a1,s2
    80000f60:	855a                	mv	a0,s6
    80000f62:	fe6ff0ef          	jal	ra,80000748 <walkaddr>
    if(pa0 == 0)
    80000f66:	cd01                	beqz	a0,80000f7e <copyin+0x6a>
    n = PGSIZE - (srcva - va0);
    80000f68:	418904b3          	sub	s1,s2,s8
    80000f6c:	94d6                	add	s1,s1,s5
    if(n > len)
    80000f6e:	fc99f7e3          	bgeu	s3,s1,80000f3c <copyin+0x28>
    80000f72:	84ce                	mv	s1,s3
    80000f74:	b7e1                	j	80000f3c <copyin+0x28>
  return 0;
    80000f76:	4501                	li	a0,0
    80000f78:	a021                	j	80000f80 <copyin+0x6c>
    80000f7a:	4501                	li	a0,0
}
    80000f7c:	8082                	ret
      return -1;
    80000f7e:	557d                	li	a0,-1
}
    80000f80:	60a6                	ld	ra,72(sp)
    80000f82:	6406                	ld	s0,64(sp)
    80000f84:	74e2                	ld	s1,56(sp)
    80000f86:	7942                	ld	s2,48(sp)
    80000f88:	79a2                	ld	s3,40(sp)
    80000f8a:	7a02                	ld	s4,32(sp)
    80000f8c:	6ae2                	ld	s5,24(sp)
    80000f8e:	6b42                	ld	s6,16(sp)
    80000f90:	6ba2                	ld	s7,8(sp)
    80000f92:	6c02                	ld	s8,0(sp)
    80000f94:	6161                	addi	sp,sp,80
    80000f96:	8082                	ret

0000000080000f98 <copyinstr>:
  while(got_null == 0 && max > 0){
    80000f98:	c2d5                	beqz	a3,8000103c <copyinstr+0xa4>
{
    80000f9a:	715d                	addi	sp,sp,-80
    80000f9c:	e486                	sd	ra,72(sp)
    80000f9e:	e0a2                	sd	s0,64(sp)
    80000fa0:	fc26                	sd	s1,56(sp)
    80000fa2:	f84a                	sd	s2,48(sp)
    80000fa4:	f44e                	sd	s3,40(sp)
    80000fa6:	f052                	sd	s4,32(sp)
    80000fa8:	ec56                	sd	s5,24(sp)
    80000faa:	e85a                	sd	s6,16(sp)
    80000fac:	e45e                	sd	s7,8(sp)
    80000fae:	0880                	addi	s0,sp,80
    80000fb0:	8a2a                	mv	s4,a0
    80000fb2:	8b2e                	mv	s6,a1
    80000fb4:	8bb2                	mv	s7,a2
    80000fb6:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000fb8:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80000fba:	6985                	lui	s3,0x1
    80000fbc:	a035                	j	80000fe8 <copyinstr+0x50>
        *dst = '\0';
    80000fbe:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000fc2:	4785                	li	a5,1
  if(got_null){
    80000fc4:	0017b793          	seqz	a5,a5
    80000fc8:	40f00533          	neg	a0,a5
}
    80000fcc:	60a6                	ld	ra,72(sp)
    80000fce:	6406                	ld	s0,64(sp)
    80000fd0:	74e2                	ld	s1,56(sp)
    80000fd2:	7942                	ld	s2,48(sp)
    80000fd4:	79a2                	ld	s3,40(sp)
    80000fd6:	7a02                	ld	s4,32(sp)
    80000fd8:	6ae2                	ld	s5,24(sp)
    80000fda:	6b42                	ld	s6,16(sp)
    80000fdc:	6ba2                	ld	s7,8(sp)
    80000fde:	6161                	addi	sp,sp,80
    80000fe0:	8082                	ret
    srcva = va0 + PGSIZE;
    80000fe2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000fe6:	c4b9                	beqz	s1,80001034 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80000fe8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000fec:	85ca                	mv	a1,s2
    80000fee:	8552                	mv	a0,s4
    80000ff0:	f58ff0ef          	jal	ra,80000748 <walkaddr>
    if(pa0 == 0)
    80000ff4:	c131                	beqz	a0,80001038 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80000ff6:	41790833          	sub	a6,s2,s7
    80000ffa:	984e                	add	a6,a6,s3
    if(n > max)
    80000ffc:	0104f363          	bgeu	s1,a6,80001002 <copyinstr+0x6a>
    80001000:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001002:	955e                	add	a0,a0,s7
    80001004:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001008:	fc080de3          	beqz	a6,80000fe2 <copyinstr+0x4a>
    8000100c:	985a                	add	a6,a6,s6
    8000100e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001010:	41650633          	sub	a2,a0,s6
    80001014:	14fd                	addi	s1,s1,-1
    80001016:	9b26                	add	s6,s6,s1
    80001018:	00f60733          	add	a4,a2,a5
    8000101c:	00074703          	lbu	a4,0(a4) # 200000 <_entry-0x7fe00000>
    80001020:	df59                	beqz	a4,80000fbe <copyinstr+0x26>
        *dst = *p;
    80001022:	00e78023          	sb	a4,0(a5)
      --max;
    80001026:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000102a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000102c:	ff0796e3          	bne	a5,a6,80001018 <copyinstr+0x80>
      dst++;
    80001030:	8b42                	mv	s6,a6
    80001032:	bf45                	j	80000fe2 <copyinstr+0x4a>
    80001034:	4781                	li	a5,0
    80001036:	b779                	j	80000fc4 <copyinstr+0x2c>
      return -1;
    80001038:	557d                	li	a0,-1
    8000103a:	bf49                	j	80000fcc <copyinstr+0x34>
  int got_null = 0;
    8000103c:	4781                	li	a5,0
  if(got_null){
    8000103e:	0017b793          	seqz	a5,a5
    80001042:	40f00533          	neg	a0,a5
}
    80001046:	8082                	ret

0000000080001048 <vmprint>:



#ifdef LAB_PGTBL
void
vmprint(pagetable_t pagetable) {
    80001048:	1101                	addi	sp,sp,-32
    8000104a:	ec06                	sd	ra,24(sp)
    8000104c:	e822                	sd	s0,16(sp)
    8000104e:	e426                	sd	s1,8(sp)
    80001050:	1000                	addi	s0,sp,32
    80001052:	84aa                	mv	s1,a0
  // your code here
  printf("page table %p\n", pagetable);
    80001054:	85aa                	mv	a1,a0
    80001056:	00006517          	auipc	a0,0x6
    8000105a:	23a50513          	addi	a0,a0,570 # 80007290 <etext+0x290>
    8000105e:	560040ef          	jal	ra,800055be <printf>
  vmprint_(pagetable, 0);
    80001062:	4581                	li	a1,0
    80001064:	8526                	mv	a0,s1
    80001066:	c30ff0ef          	jal	ra,80000496 <vmprint_>
}
    8000106a:	60e2                	ld	ra,24(sp)
    8000106c:	6442                	ld	s0,16(sp)
    8000106e:	64a2                	ld	s1,8(sp)
    80001070:	6105                	addi	sp,sp,32
    80001072:	8082                	ret

0000000080001074 <pgpte>:



#ifdef LAB_PGTBL
pte_t*
pgpte(pagetable_t pagetable, uint64 va) {
    80001074:	1141                	addi	sp,sp,-16
    80001076:	e406                	sd	ra,8(sp)
    80001078:	e022                	sd	s0,0(sp)
    8000107a:	0800                	addi	s0,sp,16
  return walk(pagetable, va, 0);
    8000107c:	4601                	li	a2,0
    8000107e:	d66ff0ef          	jal	ra,800005e4 <walk>
}
    80001082:	60a2                	ld	ra,8(sp)
    80001084:	6402                	ld	s0,0(sp)
    80001086:	0141                	addi	sp,sp,16
    80001088:	8082                	ret

000000008000108a <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000108a:	7139                	addi	sp,sp,-64
    8000108c:	fc06                	sd	ra,56(sp)
    8000108e:	f822                	sd	s0,48(sp)
    80001090:	f426                	sd	s1,40(sp)
    80001092:	f04a                	sd	s2,32(sp)
    80001094:	ec4e                	sd	s3,24(sp)
    80001096:	e852                	sd	s4,16(sp)
    80001098:	e456                	sd	s5,8(sp)
    8000109a:	e05a                	sd	s6,0(sp)
    8000109c:	0080                	addi	s0,sp,64
    8000109e:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800010a0:	00007497          	auipc	s1,0x7
    800010a4:	e2848493          	addi	s1,s1,-472 # 80007ec8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800010a8:	8b26                	mv	s6,s1
    800010aa:	00006a97          	auipc	s5,0x6
    800010ae:	f56a8a93          	addi	s5,s5,-170 # 80007000 <etext>
    800010b2:	01000937          	lui	s2,0x1000
    800010b6:	197d                	addi	s2,s2,-1
    800010b8:	093a                	slli	s2,s2,0xe
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ba:	0000da17          	auipc	s4,0xd
    800010be:	80ea0a13          	addi	s4,s4,-2034 # 8000d8c8 <tickslock>
    char *pa = kalloc();
    800010c2:	fc1fe0ef          	jal	ra,80000082 <kalloc>
    800010c6:	862a                	mv	a2,a0
    if(pa == 0)
    800010c8:	cd1d                	beqz	a0,80001106 <proc_mapstacks+0x7c>
    uint64 va = KSTACK((int) (p - proc));
    800010ca:	416485b3          	sub	a1,s1,s6
    800010ce:	858d                	srai	a1,a1,0x3
    800010d0:	000ab783          	ld	a5,0(s5)
    800010d4:	02f585b3          	mul	a1,a1,a5
    800010d8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800010dc:	4719                	li	a4,6
    800010de:	6685                	lui	a3,0x1
    800010e0:	40b905b3          	sub	a1,s2,a1
    800010e4:	854e                	mv	a0,s3
    800010e6:	facff0ef          	jal	ra,80000892 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010ea:	16848493          	addi	s1,s1,360
    800010ee:	fd449ae3          	bne	s1,s4,800010c2 <proc_mapstacks+0x38>
  }
}
    800010f2:	70e2                	ld	ra,56(sp)
    800010f4:	7442                	ld	s0,48(sp)
    800010f6:	74a2                	ld	s1,40(sp)
    800010f8:	7902                	ld	s2,32(sp)
    800010fa:	69e2                	ld	s3,24(sp)
    800010fc:	6a42                	ld	s4,16(sp)
    800010fe:	6aa2                	ld	s5,8(sp)
    80001100:	6b02                	ld	s6,0(sp)
    80001102:	6121                	addi	sp,sp,64
    80001104:	8082                	ret
      panic("kalloc");
    80001106:	00006517          	auipc	a0,0x6
    8000110a:	19a50513          	addi	a0,a0,410 # 800072a0 <etext+0x2a0>
    8000110e:	764040ef          	jal	ra,80005872 <panic>

0000000080001112 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001112:	7139                	addi	sp,sp,-64
    80001114:	fc06                	sd	ra,56(sp)
    80001116:	f822                	sd	s0,48(sp)
    80001118:	f426                	sd	s1,40(sp)
    8000111a:	f04a                	sd	s2,32(sp)
    8000111c:	ec4e                	sd	s3,24(sp)
    8000111e:	e852                	sd	s4,16(sp)
    80001120:	e456                	sd	s5,8(sp)
    80001122:	e05a                	sd	s6,0(sp)
    80001124:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001126:	00006597          	auipc	a1,0x6
    8000112a:	18258593          	addi	a1,a1,386 # 800072a8 <etext+0x2a8>
    8000112e:	00007517          	auipc	a0,0x7
    80001132:	96a50513          	addi	a0,a0,-1686 # 80007a98 <pid_lock>
    80001136:	1d9040ef          	jal	ra,80005b0e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000113a:	00006597          	auipc	a1,0x6
    8000113e:	17658593          	addi	a1,a1,374 # 800072b0 <etext+0x2b0>
    80001142:	00007517          	auipc	a0,0x7
    80001146:	96e50513          	addi	a0,a0,-1682 # 80007ab0 <wait_lock>
    8000114a:	1c5040ef          	jal	ra,80005b0e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000114e:	00007497          	auipc	s1,0x7
    80001152:	d7a48493          	addi	s1,s1,-646 # 80007ec8 <proc>
      initlock(&p->lock, "proc");
    80001156:	00006b17          	auipc	s6,0x6
    8000115a:	16ab0b13          	addi	s6,s6,362 # 800072c0 <etext+0x2c0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000115e:	8aa6                	mv	s5,s1
    80001160:	00006a17          	auipc	s4,0x6
    80001164:	ea0a0a13          	addi	s4,s4,-352 # 80007000 <etext>
    80001168:	01000937          	lui	s2,0x1000
    8000116c:	197d                	addi	s2,s2,-1
    8000116e:	093a                	slli	s2,s2,0xe
  for(p = proc; p < &proc[NPROC]; p++) {
    80001170:	0000c997          	auipc	s3,0xc
    80001174:	75898993          	addi	s3,s3,1880 # 8000d8c8 <tickslock>
      initlock(&p->lock, "proc");
    80001178:	85da                	mv	a1,s6
    8000117a:	8526                	mv	a0,s1
    8000117c:	193040ef          	jal	ra,80005b0e <initlock>
      p->state = UNUSED;
    80001180:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001184:	415487b3          	sub	a5,s1,s5
    80001188:	878d                	srai	a5,a5,0x3
    8000118a:	000a3703          	ld	a4,0(s4)
    8000118e:	02e787b3          	mul	a5,a5,a4
    80001192:	00d7979b          	slliw	a5,a5,0xd
    80001196:	40f907b3          	sub	a5,s2,a5
    8000119a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000119c:	16848493          	addi	s1,s1,360
    800011a0:	fd349ce3          	bne	s1,s3,80001178 <procinit+0x66>
  }
}
    800011a4:	70e2                	ld	ra,56(sp)
    800011a6:	7442                	ld	s0,48(sp)
    800011a8:	74a2                	ld	s1,40(sp)
    800011aa:	7902                	ld	s2,32(sp)
    800011ac:	69e2                	ld	s3,24(sp)
    800011ae:	6a42                	ld	s4,16(sp)
    800011b0:	6aa2                	ld	s5,8(sp)
    800011b2:	6b02                	ld	s6,0(sp)
    800011b4:	6121                	addi	sp,sp,64
    800011b6:	8082                	ret

00000000800011b8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800011b8:	1141                	addi	sp,sp,-16
    800011ba:	e422                	sd	s0,8(sp)
    800011bc:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    800011be:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800011c0:	2501                	sext.w	a0,a0
    800011c2:	6422                	ld	s0,8(sp)
    800011c4:	0141                	addi	sp,sp,16
    800011c6:	8082                	ret

00000000800011c8 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e422                	sd	s0,8(sp)
    800011cc:	0800                	addi	s0,sp,16
    800011ce:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800011d0:	2781                	sext.w	a5,a5
    800011d2:	079e                	slli	a5,a5,0x7
  return c;
}
    800011d4:	00007517          	auipc	a0,0x7
    800011d8:	8f450513          	addi	a0,a0,-1804 # 80007ac8 <cpus>
    800011dc:	953e                	add	a0,a0,a5
    800011de:	6422                	ld	s0,8(sp)
    800011e0:	0141                	addi	sp,sp,16
    800011e2:	8082                	ret

00000000800011e4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800011e4:	1101                	addi	sp,sp,-32
    800011e6:	ec06                	sd	ra,24(sp)
    800011e8:	e822                	sd	s0,16(sp)
    800011ea:	e426                	sd	s1,8(sp)
    800011ec:	1000                	addi	s0,sp,32
  push_off();
    800011ee:	161040ef          	jal	ra,80005b4e <push_off>
    800011f2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800011f4:	2781                	sext.w	a5,a5
    800011f6:	079e                	slli	a5,a5,0x7
    800011f8:	00007717          	auipc	a4,0x7
    800011fc:	8a070713          	addi	a4,a4,-1888 # 80007a98 <pid_lock>
    80001200:	97ba                	add	a5,a5,a4
    80001202:	7b84                	ld	s1,48(a5)
  pop_off();
    80001204:	1cf040ef          	jal	ra,80005bd2 <pop_off>
  return p;
}
    80001208:	8526                	mv	a0,s1
    8000120a:	60e2                	ld	ra,24(sp)
    8000120c:	6442                	ld	s0,16(sp)
    8000120e:	64a2                	ld	s1,8(sp)
    80001210:	6105                	addi	sp,sp,32
    80001212:	8082                	ret

0000000080001214 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001214:	1141                	addi	sp,sp,-16
    80001216:	e406                	sd	ra,8(sp)
    80001218:	e022                	sd	s0,0(sp)
    8000121a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000121c:	fc9ff0ef          	jal	ra,800011e4 <myproc>
    80001220:	207040ef          	jal	ra,80005c26 <release>

  if (first) {
    80001224:	00006797          	auipc	a5,0x6
    80001228:	7cc7a783          	lw	a5,1996(a5) # 800079f0 <first.2219>
    8000122c:	e799                	bnez	a5,8000123a <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000122e:	35d000ef          	jal	ra,80001d8a <usertrapret>
}
    80001232:	60a2                	ld	ra,8(sp)
    80001234:	6402                	ld	s0,0(sp)
    80001236:	0141                	addi	sp,sp,16
    80001238:	8082                	ret
    fsinit(ROOTDEV);
    8000123a:	4505                	li	a0,1
    8000123c:	72c010ef          	jal	ra,80002968 <fsinit>
    first = 0;
    80001240:	00006797          	auipc	a5,0x6
    80001244:	7a07a823          	sw	zero,1968(a5) # 800079f0 <first.2219>
    __sync_synchronize();
    80001248:	0ff0000f          	fence
    8000124c:	b7cd                	j	8000122e <forkret+0x1a>

000000008000124e <allocpid>:
{
    8000124e:	1101                	addi	sp,sp,-32
    80001250:	ec06                	sd	ra,24(sp)
    80001252:	e822                	sd	s0,16(sp)
    80001254:	e426                	sd	s1,8(sp)
    80001256:	e04a                	sd	s2,0(sp)
    80001258:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000125a:	00007917          	auipc	s2,0x7
    8000125e:	83e90913          	addi	s2,s2,-1986 # 80007a98 <pid_lock>
    80001262:	854a                	mv	a0,s2
    80001264:	12b040ef          	jal	ra,80005b8e <acquire>
  pid = nextpid;
    80001268:	00006797          	auipc	a5,0x6
    8000126c:	78c78793          	addi	a5,a5,1932 # 800079f4 <nextpid>
    80001270:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001272:	0014871b          	addiw	a4,s1,1
    80001276:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001278:	854a                	mv	a0,s2
    8000127a:	1ad040ef          	jal	ra,80005c26 <release>
}
    8000127e:	8526                	mv	a0,s1
    80001280:	60e2                	ld	ra,24(sp)
    80001282:	6442                	ld	s0,16(sp)
    80001284:	64a2                	ld	s1,8(sp)
    80001286:	6902                	ld	s2,0(sp)
    80001288:	6105                	addi	sp,sp,32
    8000128a:	8082                	ret

000000008000128c <proc_pagetable>:
{
    8000128c:	7179                	addi	sp,sp,-48
    8000128e:	f406                	sd	ra,40(sp)
    80001290:	f022                	sd	s0,32(sp)
    80001292:	ec26                	sd	s1,24(sp)
    80001294:	e84a                	sd	s2,16(sp)
    80001296:	e44e                	sd	s3,8(sp)
    80001298:	1800                	addi	s0,sp,48
    8000129a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000129c:	863ff0ef          	jal	ra,80000afe <uvmcreate>
    800012a0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012a2:	cd39                	beqz	a0,80001300 <proc_pagetable+0x74>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800012a4:	4729                	li	a4,10
    800012a6:	00005697          	auipc	a3,0x5
    800012aa:	d5a68693          	addi	a3,a3,-678 # 80006000 <_trampoline>
    800012ae:	6605                	lui	a2,0x1
    800012b0:	040005b7          	lui	a1,0x4000
    800012b4:	15fd                	addi	a1,a1,-1
    800012b6:	05b2                	slli	a1,a1,0xc
    800012b8:	cceff0ef          	jal	ra,80000786 <mappages>
    800012bc:	04054a63          	bltz	a0,80001310 <proc_pagetable+0x84>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800012c0:	4719                	li	a4,6
    800012c2:	05893683          	ld	a3,88(s2)
    800012c6:	6605                	lui	a2,0x1
    800012c8:	020005b7          	lui	a1,0x2000
    800012cc:	15fd                	addi	a1,a1,-1
    800012ce:	05b6                	slli	a1,a1,0xd
    800012d0:	8526                	mv	a0,s1
    800012d2:	cb4ff0ef          	jal	ra,80000786 <mappages>
    800012d6:	04054363          	bltz	a0,8000131c <proc_pagetable+0x90>
  struct usyscall *usyscallpage = (struct usyscall *)kalloc();
    800012da:	da9fe0ef          	jal	ra,80000082 <kalloc>
    800012de:	89aa                	mv	s3,a0
  if(usyscallpage == 0) {
    800012e0:	cd29                	beqz	a0,8000133a <proc_pagetable+0xae>
  usyscallpage->pid = p->pid;
    800012e2:	03092783          	lw	a5,48(s2)
    800012e6:	c11c                	sw	a5,0(a0)
  if(mappages(pagetable, USYSCALL, PGSIZE, (uint64)usyscallpage, PTE_R | PTE_U) < 0){
    800012e8:	4749                	li	a4,18
    800012ea:	86aa                	mv	a3,a0
    800012ec:	6605                	lui	a2,0x1
    800012ee:	040005b7          	lui	a1,0x4000
    800012f2:	15f5                	addi	a1,a1,-3
    800012f4:	05b2                	slli	a1,a1,0xc
    800012f6:	8526                	mv	a0,s1
    800012f8:	c8eff0ef          	jal	ra,80000786 <mappages>
    800012fc:	06054763          	bltz	a0,8000136a <proc_pagetable+0xde>
}
    80001300:	8526                	mv	a0,s1
    80001302:	70a2                	ld	ra,40(sp)
    80001304:	7402                	ld	s0,32(sp)
    80001306:	64e2                	ld	s1,24(sp)
    80001308:	6942                	ld	s2,16(sp)
    8000130a:	69a2                	ld	s3,8(sp)
    8000130c:	6145                	addi	sp,sp,48
    8000130e:	8082                	ret
    uvmfree(pagetable, 0);
    80001310:	4581                	li	a1,0
    80001312:	8526                	mv	a0,s1
    80001314:	9f1ff0ef          	jal	ra,80000d04 <uvmfree>
    return 0;
    80001318:	4481                	li	s1,0
    8000131a:	b7dd                	j	80001300 <proc_pagetable+0x74>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000131c:	4681                	li	a3,0
    8000131e:	4605                	li	a2,1
    80001320:	040005b7          	lui	a1,0x4000
    80001324:	15fd                	addi	a1,a1,-1
    80001326:	05b2                	slli	a1,a1,0xc
    80001328:	8526                	mv	a0,s1
    8000132a:	e5eff0ef          	jal	ra,80000988 <uvmunmap>
    uvmfree(pagetable, 0);
    8000132e:	4581                	li	a1,0
    80001330:	8526                	mv	a0,s1
    80001332:	9d3ff0ef          	jal	ra,80000d04 <uvmfree>
    return 0;
    80001336:	4481                	li	s1,0
    80001338:	b7e1                	j	80001300 <proc_pagetable+0x74>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000133a:	4681                	li	a3,0
    8000133c:	4605                	li	a2,1
    8000133e:	040005b7          	lui	a1,0x4000
    80001342:	15fd                	addi	a1,a1,-1
    80001344:	05b2                	slli	a1,a1,0xc
    80001346:	8526                	mv	a0,s1
    80001348:	e40ff0ef          	jal	ra,80000988 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000134c:	4681                	li	a3,0
    8000134e:	4605                	li	a2,1
    80001350:	020005b7          	lui	a1,0x2000
    80001354:	15fd                	addi	a1,a1,-1
    80001356:	05b6                	slli	a1,a1,0xd
    80001358:	8526                	mv	a0,s1
    8000135a:	e2eff0ef          	jal	ra,80000988 <uvmunmap>
    uvmfree(pagetable, 0);
    8000135e:	4581                	li	a1,0
    80001360:	8526                	mv	a0,s1
    80001362:	9a3ff0ef          	jal	ra,80000d04 <uvmfree>
    return 0;
    80001366:	84ce                	mv	s1,s3
    80001368:	bf61                	j	80001300 <proc_pagetable+0x74>
    kfree((void*)usyscallpage);
    8000136a:	854e                	mv	a0,s3
    8000136c:	cb1fe0ef          	jal	ra,8000001c <kfree>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001370:	4681                	li	a3,0
    80001372:	4605                	li	a2,1
    80001374:	040005b7          	lui	a1,0x4000
    80001378:	15fd                	addi	a1,a1,-1
    8000137a:	05b2                	slli	a1,a1,0xc
    8000137c:	8526                	mv	a0,s1
    8000137e:	e0aff0ef          	jal	ra,80000988 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001382:	4681                	li	a3,0
    80001384:	4605                	li	a2,1
    80001386:	020005b7          	lui	a1,0x2000
    8000138a:	15fd                	addi	a1,a1,-1
    8000138c:	05b6                	slli	a1,a1,0xd
    8000138e:	8526                	mv	a0,s1
    80001390:	df8ff0ef          	jal	ra,80000988 <uvmunmap>
    uvmfree(pagetable, 0);
    80001394:	4581                	li	a1,0
    80001396:	8526                	mv	a0,s1
    80001398:	96dff0ef          	jal	ra,80000d04 <uvmfree>
    return 0;
    8000139c:	4481                	li	s1,0
    8000139e:	b78d                	j	80001300 <proc_pagetable+0x74>

00000000800013a0 <proc_freepagetable>:
{
    800013a0:	7179                	addi	sp,sp,-48
    800013a2:	f406                	sd	ra,40(sp)
    800013a4:	f022                	sd	s0,32(sp)
    800013a6:	ec26                	sd	s1,24(sp)
    800013a8:	e84a                	sd	s2,16(sp)
    800013aa:	e44e                	sd	s3,8(sp)
    800013ac:	1800                	addi	s0,sp,48
    800013ae:	84aa                	mv	s1,a0
    800013b0:	89ae                	mv	s3,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800013b2:	4681                	li	a3,0
    800013b4:	4605                	li	a2,1
    800013b6:	04000937          	lui	s2,0x4000
    800013ba:	fff90593          	addi	a1,s2,-1 # 3ffffff <_entry-0x7c000001>
    800013be:	05b2                	slli	a1,a1,0xc
    800013c0:	dc8ff0ef          	jal	ra,80000988 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    800013c4:	4681                	li	a3,0
    800013c6:	4605                	li	a2,1
    800013c8:	020005b7          	lui	a1,0x2000
    800013cc:	15fd                	addi	a1,a1,-1
    800013ce:	05b6                	slli	a1,a1,0xd
    800013d0:	8526                	mv	a0,s1
    800013d2:	db6ff0ef          	jal	ra,80000988 <uvmunmap>
  uvmunmap(pagetable, USYSCALL, 1, 1);
    800013d6:	4685                	li	a3,1
    800013d8:	4605                	li	a2,1
    800013da:	1975                	addi	s2,s2,-3
    800013dc:	00c91593          	slli	a1,s2,0xc
    800013e0:	8526                	mv	a0,s1
    800013e2:	da6ff0ef          	jal	ra,80000988 <uvmunmap>
  uvmfree(pagetable, sz);
    800013e6:	85ce                	mv	a1,s3
    800013e8:	8526                	mv	a0,s1
    800013ea:	91bff0ef          	jal	ra,80000d04 <uvmfree>
}
    800013ee:	70a2                	ld	ra,40(sp)
    800013f0:	7402                	ld	s0,32(sp)
    800013f2:	64e2                	ld	s1,24(sp)
    800013f4:	6942                	ld	s2,16(sp)
    800013f6:	69a2                	ld	s3,8(sp)
    800013f8:	6145                	addi	sp,sp,48
    800013fa:	8082                	ret

00000000800013fc <freeproc>:
{
    800013fc:	1101                	addi	sp,sp,-32
    800013fe:	ec06                	sd	ra,24(sp)
    80001400:	e822                	sd	s0,16(sp)
    80001402:	e426                	sd	s1,8(sp)
    80001404:	1000                	addi	s0,sp,32
    80001406:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001408:	6d28                	ld	a0,88(a0)
    8000140a:	c119                	beqz	a0,80001410 <freeproc+0x14>
    kfree((void*)p->trapframe);
    8000140c:	c11fe0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    80001410:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001414:	68a8                	ld	a0,80(s1)
    80001416:	c501                	beqz	a0,8000141e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001418:	64ac                	ld	a1,72(s1)
    8000141a:	f87ff0ef          	jal	ra,800013a0 <proc_freepagetable>
  p->pagetable = 0;
    8000141e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001422:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001426:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000142a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    8000142e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001432:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001436:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000143a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    8000143e:	0004ac23          	sw	zero,24(s1)
}
    80001442:	60e2                	ld	ra,24(sp)
    80001444:	6442                	ld	s0,16(sp)
    80001446:	64a2                	ld	s1,8(sp)
    80001448:	6105                	addi	sp,sp,32
    8000144a:	8082                	ret

000000008000144c <allocproc>:
{
    8000144c:	1101                	addi	sp,sp,-32
    8000144e:	ec06                	sd	ra,24(sp)
    80001450:	e822                	sd	s0,16(sp)
    80001452:	e426                	sd	s1,8(sp)
    80001454:	e04a                	sd	s2,0(sp)
    80001456:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001458:	00007497          	auipc	s1,0x7
    8000145c:	a7048493          	addi	s1,s1,-1424 # 80007ec8 <proc>
    80001460:	0000c917          	auipc	s2,0xc
    80001464:	46890913          	addi	s2,s2,1128 # 8000d8c8 <tickslock>
    acquire(&p->lock);
    80001468:	8526                	mv	a0,s1
    8000146a:	724040ef          	jal	ra,80005b8e <acquire>
    if(p->state == UNUSED) {
    8000146e:	4c9c                	lw	a5,24(s1)
    80001470:	cb91                	beqz	a5,80001484 <allocproc+0x38>
      release(&p->lock);
    80001472:	8526                	mv	a0,s1
    80001474:	7b2040ef          	jal	ra,80005c26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001478:	16848493          	addi	s1,s1,360
    8000147c:	ff2496e3          	bne	s1,s2,80001468 <allocproc+0x1c>
  return 0;
    80001480:	4481                	li	s1,0
    80001482:	a089                	j	800014c4 <allocproc+0x78>
  p->pid = allocpid();
    80001484:	dcbff0ef          	jal	ra,8000124e <allocpid>
    80001488:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000148a:	4785                	li	a5,1
    8000148c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000148e:	bf5fe0ef          	jal	ra,80000082 <kalloc>
    80001492:	892a                	mv	s2,a0
    80001494:	eca8                	sd	a0,88(s1)
    80001496:	cd15                	beqz	a0,800014d2 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001498:	8526                	mv	a0,s1
    8000149a:	df3ff0ef          	jal	ra,8000128c <proc_pagetable>
    8000149e:	892a                	mv	s2,a0
    800014a0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800014a2:	c121                	beqz	a0,800014e2 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    800014a4:	07000613          	li	a2,112
    800014a8:	4581                	li	a1,0
    800014aa:	06048513          	addi	a0,s1,96
    800014ae:	d8dfe0ef          	jal	ra,8000023a <memset>
  p->context.ra = (uint64)forkret;
    800014b2:	00000797          	auipc	a5,0x0
    800014b6:	d6278793          	addi	a5,a5,-670 # 80001214 <forkret>
    800014ba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800014bc:	60bc                	ld	a5,64(s1)
    800014be:	6705                	lui	a4,0x1
    800014c0:	97ba                	add	a5,a5,a4
    800014c2:	f4bc                	sd	a5,104(s1)
}
    800014c4:	8526                	mv	a0,s1
    800014c6:	60e2                	ld	ra,24(sp)
    800014c8:	6442                	ld	s0,16(sp)
    800014ca:	64a2                	ld	s1,8(sp)
    800014cc:	6902                	ld	s2,0(sp)
    800014ce:	6105                	addi	sp,sp,32
    800014d0:	8082                	ret
    freeproc(p);
    800014d2:	8526                	mv	a0,s1
    800014d4:	f29ff0ef          	jal	ra,800013fc <freeproc>
    release(&p->lock);
    800014d8:	8526                	mv	a0,s1
    800014da:	74c040ef          	jal	ra,80005c26 <release>
    return 0;
    800014de:	84ca                	mv	s1,s2
    800014e0:	b7d5                	j	800014c4 <allocproc+0x78>
    freeproc(p);
    800014e2:	8526                	mv	a0,s1
    800014e4:	f19ff0ef          	jal	ra,800013fc <freeproc>
    release(&p->lock);
    800014e8:	8526                	mv	a0,s1
    800014ea:	73c040ef          	jal	ra,80005c26 <release>
    return 0;
    800014ee:	84ca                	mv	s1,s2
    800014f0:	bfd1                	j	800014c4 <allocproc+0x78>

00000000800014f2 <userinit>:
{
    800014f2:	1101                	addi	sp,sp,-32
    800014f4:	ec06                	sd	ra,24(sp)
    800014f6:	e822                	sd	s0,16(sp)
    800014f8:	e426                	sd	s1,8(sp)
    800014fa:	1000                	addi	s0,sp,32
  p = allocproc();
    800014fc:	f51ff0ef          	jal	ra,8000144c <allocproc>
    80001500:	84aa                	mv	s1,a0
  initproc = p;
    80001502:	00006797          	auipc	a5,0x6
    80001506:	54a7b723          	sd	a0,1358(a5) # 80007a50 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000150a:	03400613          	li	a2,52
    8000150e:	00006597          	auipc	a1,0x6
    80001512:	4f258593          	addi	a1,a1,1266 # 80007a00 <initcode>
    80001516:	6928                	ld	a0,80(a0)
    80001518:	e0cff0ef          	jal	ra,80000b24 <uvmfirst>
  p->sz = PGSIZE;
    8000151c:	6785                	lui	a5,0x1
    8000151e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001520:	6cb8                	ld	a4,88(s1)
    80001522:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001526:	6cb8                	ld	a4,88(s1)
    80001528:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000152a:	4641                	li	a2,16
    8000152c:	00006597          	auipc	a1,0x6
    80001530:	d9c58593          	addi	a1,a1,-612 # 800072c8 <etext+0x2c8>
    80001534:	15848513          	addi	a0,s1,344
    80001538:	e51fe0ef          	jal	ra,80000388 <safestrcpy>
  p->cwd = namei("/");
    8000153c:	00006517          	auipc	a0,0x6
    80001540:	d9c50513          	addi	a0,a0,-612 # 800072d8 <etext+0x2d8>
    80001544:	503010ef          	jal	ra,80003246 <namei>
    80001548:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000154c:	478d                	li	a5,3
    8000154e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001550:	8526                	mv	a0,s1
    80001552:	6d4040ef          	jal	ra,80005c26 <release>
}
    80001556:	60e2                	ld	ra,24(sp)
    80001558:	6442                	ld	s0,16(sp)
    8000155a:	64a2                	ld	s1,8(sp)
    8000155c:	6105                	addi	sp,sp,32
    8000155e:	8082                	ret

0000000080001560 <growproc>:
{
    80001560:	1101                	addi	sp,sp,-32
    80001562:	ec06                	sd	ra,24(sp)
    80001564:	e822                	sd	s0,16(sp)
    80001566:	e426                	sd	s1,8(sp)
    80001568:	e04a                	sd	s2,0(sp)
    8000156a:	1000                	addi	s0,sp,32
    8000156c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000156e:	c77ff0ef          	jal	ra,800011e4 <myproc>
    80001572:	84aa                	mv	s1,a0
  sz = p->sz;
    80001574:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001576:	01204c63          	bgtz	s2,8000158e <growproc+0x2e>
  } else if(n < 0){
    8000157a:	02094463          	bltz	s2,800015a2 <growproc+0x42>
  p->sz = sz;
    8000157e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001580:	4501                	li	a0,0
}
    80001582:	60e2                	ld	ra,24(sp)
    80001584:	6442                	ld	s0,16(sp)
    80001586:	64a2                	ld	s1,8(sp)
    80001588:	6902                	ld	s2,0(sp)
    8000158a:	6105                	addi	sp,sp,32
    8000158c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000158e:	4691                	li	a3,4
    80001590:	00b90633          	add	a2,s2,a1
    80001594:	6928                	ld	a0,80(a0)
    80001596:	e30ff0ef          	jal	ra,80000bc6 <uvmalloc>
    8000159a:	85aa                	mv	a1,a0
    8000159c:	f16d                	bnez	a0,8000157e <growproc+0x1e>
      return -1;
    8000159e:	557d                	li	a0,-1
    800015a0:	b7cd                	j	80001582 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800015a2:	00b90633          	add	a2,s2,a1
    800015a6:	6928                	ld	a0,80(a0)
    800015a8:	ddaff0ef          	jal	ra,80000b82 <uvmdealloc>
    800015ac:	85aa                	mv	a1,a0
    800015ae:	bfc1                	j	8000157e <growproc+0x1e>

00000000800015b0 <fork>:
{
    800015b0:	7179                	addi	sp,sp,-48
    800015b2:	f406                	sd	ra,40(sp)
    800015b4:	f022                	sd	s0,32(sp)
    800015b6:	ec26                	sd	s1,24(sp)
    800015b8:	e84a                	sd	s2,16(sp)
    800015ba:	e44e                	sd	s3,8(sp)
    800015bc:	e052                	sd	s4,0(sp)
    800015be:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800015c0:	c25ff0ef          	jal	ra,800011e4 <myproc>
    800015c4:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800015c6:	e87ff0ef          	jal	ra,8000144c <allocproc>
    800015ca:	0e050563          	beqz	a0,800016b4 <fork+0x104>
    800015ce:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800015d0:	04893603          	ld	a2,72(s2)
    800015d4:	692c                	ld	a1,80(a0)
    800015d6:	05093503          	ld	a0,80(s2)
    800015da:	f5aff0ef          	jal	ra,80000d34 <uvmcopy>
    800015de:	04054663          	bltz	a0,8000162a <fork+0x7a>
  np->sz = p->sz;
    800015e2:	04893783          	ld	a5,72(s2)
    800015e6:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800015ea:	05893683          	ld	a3,88(s2)
    800015ee:	87b6                	mv	a5,a3
    800015f0:	0589b703          	ld	a4,88(s3)
    800015f4:	12068693          	addi	a3,a3,288
    800015f8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800015fc:	6788                	ld	a0,8(a5)
    800015fe:	6b8c                	ld	a1,16(a5)
    80001600:	6f90                	ld	a2,24(a5)
    80001602:	01073023          	sd	a6,0(a4)
    80001606:	e708                	sd	a0,8(a4)
    80001608:	eb0c                	sd	a1,16(a4)
    8000160a:	ef10                	sd	a2,24(a4)
    8000160c:	02078793          	addi	a5,a5,32
    80001610:	02070713          	addi	a4,a4,32
    80001614:	fed792e3          	bne	a5,a3,800015f8 <fork+0x48>
  np->trapframe->a0 = 0;
    80001618:	0589b783          	ld	a5,88(s3)
    8000161c:	0607b823          	sd	zero,112(a5)
    80001620:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001624:	15000a13          	li	s4,336
    80001628:	a00d                	j	8000164a <fork+0x9a>
    freeproc(np);
    8000162a:	854e                	mv	a0,s3
    8000162c:	dd1ff0ef          	jal	ra,800013fc <freeproc>
    release(&np->lock);
    80001630:	854e                	mv	a0,s3
    80001632:	5f4040ef          	jal	ra,80005c26 <release>
    return -1;
    80001636:	5a7d                	li	s4,-1
    80001638:	a0ad                	j	800016a2 <fork+0xf2>
      np->ofile[i] = filedup(p->ofile[i]);
    8000163a:	1ba020ef          	jal	ra,800037f4 <filedup>
    8000163e:	009987b3          	add	a5,s3,s1
    80001642:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001644:	04a1                	addi	s1,s1,8
    80001646:	01448763          	beq	s1,s4,80001654 <fork+0xa4>
    if(p->ofile[i])
    8000164a:	009907b3          	add	a5,s2,s1
    8000164e:	6388                	ld	a0,0(a5)
    80001650:	f56d                	bnez	a0,8000163a <fork+0x8a>
    80001652:	bfcd                	j	80001644 <fork+0x94>
  np->cwd = idup(p->cwd);
    80001654:	15093503          	ld	a0,336(s2)
    80001658:	506010ef          	jal	ra,80002b5e <idup>
    8000165c:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001660:	4641                	li	a2,16
    80001662:	15890593          	addi	a1,s2,344
    80001666:	15898513          	addi	a0,s3,344
    8000166a:	d1ffe0ef          	jal	ra,80000388 <safestrcpy>
  pid = np->pid;
    8000166e:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001672:	854e                	mv	a0,s3
    80001674:	5b2040ef          	jal	ra,80005c26 <release>
  acquire(&wait_lock);
    80001678:	00006497          	auipc	s1,0x6
    8000167c:	43848493          	addi	s1,s1,1080 # 80007ab0 <wait_lock>
    80001680:	8526                	mv	a0,s1
    80001682:	50c040ef          	jal	ra,80005b8e <acquire>
  np->parent = p;
    80001686:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    8000168a:	8526                	mv	a0,s1
    8000168c:	59a040ef          	jal	ra,80005c26 <release>
  acquire(&np->lock);
    80001690:	854e                	mv	a0,s3
    80001692:	4fc040ef          	jal	ra,80005b8e <acquire>
  np->state = RUNNABLE;
    80001696:	478d                	li	a5,3
    80001698:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000169c:	854e                	mv	a0,s3
    8000169e:	588040ef          	jal	ra,80005c26 <release>
}
    800016a2:	8552                	mv	a0,s4
    800016a4:	70a2                	ld	ra,40(sp)
    800016a6:	7402                	ld	s0,32(sp)
    800016a8:	64e2                	ld	s1,24(sp)
    800016aa:	6942                	ld	s2,16(sp)
    800016ac:	69a2                	ld	s3,8(sp)
    800016ae:	6a02                	ld	s4,0(sp)
    800016b0:	6145                	addi	sp,sp,48
    800016b2:	8082                	ret
    return -1;
    800016b4:	5a7d                	li	s4,-1
    800016b6:	b7f5                	j	800016a2 <fork+0xf2>

00000000800016b8 <scheduler>:
{
    800016b8:	715d                	addi	sp,sp,-80
    800016ba:	e486                	sd	ra,72(sp)
    800016bc:	e0a2                	sd	s0,64(sp)
    800016be:	fc26                	sd	s1,56(sp)
    800016c0:	f84a                	sd	s2,48(sp)
    800016c2:	f44e                	sd	s3,40(sp)
    800016c4:	f052                	sd	s4,32(sp)
    800016c6:	ec56                	sd	s5,24(sp)
    800016c8:	e85a                	sd	s6,16(sp)
    800016ca:	e45e                	sd	s7,8(sp)
    800016cc:	e062                	sd	s8,0(sp)
    800016ce:	0880                	addi	s0,sp,80
    800016d0:	8792                	mv	a5,tp
  int id = r_tp();
    800016d2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800016d4:	00779b13          	slli	s6,a5,0x7
    800016d8:	00006717          	auipc	a4,0x6
    800016dc:	3c070713          	addi	a4,a4,960 # 80007a98 <pid_lock>
    800016e0:	975a                	add	a4,a4,s6
    800016e2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800016e6:	00006717          	auipc	a4,0x6
    800016ea:	3ea70713          	addi	a4,a4,1002 # 80007ad0 <cpus+0x8>
    800016ee:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800016f0:	4c11                	li	s8,4
        c->proc = p;
    800016f2:	079e                	slli	a5,a5,0x7
    800016f4:	00006a17          	auipc	s4,0x6
    800016f8:	3a4a0a13          	addi	s4,s4,932 # 80007a98 <pid_lock>
    800016fc:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800016fe:	0000c997          	auipc	s3,0xc
    80001702:	1ca98993          	addi	s3,s3,458 # 8000d8c8 <tickslock>
        found = 1;
    80001706:	4b85                	li	s7,1
    80001708:	a0a9                	j	80001752 <scheduler+0x9a>
        p->state = RUNNING;
    8000170a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    8000170e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001712:	06048593          	addi	a1,s1,96
    80001716:	855a                	mv	a0,s6
    80001718:	5cc000ef          	jal	ra,80001ce4 <swtch>
        c->proc = 0;
    8000171c:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001720:	8ade                	mv	s5,s7
      release(&p->lock);
    80001722:	8526                	mv	a0,s1
    80001724:	502040ef          	jal	ra,80005c26 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001728:	16848493          	addi	s1,s1,360
    8000172c:	01348963          	beq	s1,s3,8000173e <scheduler+0x86>
      acquire(&p->lock);
    80001730:	8526                	mv	a0,s1
    80001732:	45c040ef          	jal	ra,80005b8e <acquire>
      if(p->state == RUNNABLE) {
    80001736:	4c9c                	lw	a5,24(s1)
    80001738:	ff2795e3          	bne	a5,s2,80001722 <scheduler+0x6a>
    8000173c:	b7f9                	j	8000170a <scheduler+0x52>
    if(found == 0) {
    8000173e:	000a9a63          	bnez	s5,80001752 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001742:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001746:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000174a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000174e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001752:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001756:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000175a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000175e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001760:	00006497          	auipc	s1,0x6
    80001764:	76848493          	addi	s1,s1,1896 # 80007ec8 <proc>
      if(p->state == RUNNABLE) {
    80001768:	490d                	li	s2,3
    8000176a:	b7d9                	j	80001730 <scheduler+0x78>

000000008000176c <sched>:
{
    8000176c:	7179                	addi	sp,sp,-48
    8000176e:	f406                	sd	ra,40(sp)
    80001770:	f022                	sd	s0,32(sp)
    80001772:	ec26                	sd	s1,24(sp)
    80001774:	e84a                	sd	s2,16(sp)
    80001776:	e44e                	sd	s3,8(sp)
    80001778:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000177a:	a6bff0ef          	jal	ra,800011e4 <myproc>
    8000177e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001780:	3a4040ef          	jal	ra,80005b24 <holding>
    80001784:	c92d                	beqz	a0,800017f6 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001786:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001788:	2781                	sext.w	a5,a5
    8000178a:	079e                	slli	a5,a5,0x7
    8000178c:	00006717          	auipc	a4,0x6
    80001790:	30c70713          	addi	a4,a4,780 # 80007a98 <pid_lock>
    80001794:	97ba                	add	a5,a5,a4
    80001796:	0a87a703          	lw	a4,168(a5)
    8000179a:	4785                	li	a5,1
    8000179c:	06f71363          	bne	a4,a5,80001802 <sched+0x96>
  if(p->state == RUNNING)
    800017a0:	4c98                	lw	a4,24(s1)
    800017a2:	4791                	li	a5,4
    800017a4:	06f70563          	beq	a4,a5,8000180e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800017a8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800017ac:	8b89                	andi	a5,a5,2
  if(intr_get())
    800017ae:	e7b5                	bnez	a5,8000181a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800017b0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800017b2:	00006917          	auipc	s2,0x6
    800017b6:	2e690913          	addi	s2,s2,742 # 80007a98 <pid_lock>
    800017ba:	2781                	sext.w	a5,a5
    800017bc:	079e                	slli	a5,a5,0x7
    800017be:	97ca                	add	a5,a5,s2
    800017c0:	0ac7a983          	lw	s3,172(a5)
    800017c4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800017c6:	2781                	sext.w	a5,a5
    800017c8:	079e                	slli	a5,a5,0x7
    800017ca:	00006597          	auipc	a1,0x6
    800017ce:	30658593          	addi	a1,a1,774 # 80007ad0 <cpus+0x8>
    800017d2:	95be                	add	a1,a1,a5
    800017d4:	06048513          	addi	a0,s1,96
    800017d8:	50c000ef          	jal	ra,80001ce4 <swtch>
    800017dc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800017de:	2781                	sext.w	a5,a5
    800017e0:	079e                	slli	a5,a5,0x7
    800017e2:	97ca                	add	a5,a5,s2
    800017e4:	0b37a623          	sw	s3,172(a5)
}
    800017e8:	70a2                	ld	ra,40(sp)
    800017ea:	7402                	ld	s0,32(sp)
    800017ec:	64e2                	ld	s1,24(sp)
    800017ee:	6942                	ld	s2,16(sp)
    800017f0:	69a2                	ld	s3,8(sp)
    800017f2:	6145                	addi	sp,sp,48
    800017f4:	8082                	ret
    panic("sched p->lock");
    800017f6:	00006517          	auipc	a0,0x6
    800017fa:	aea50513          	addi	a0,a0,-1302 # 800072e0 <etext+0x2e0>
    800017fe:	074040ef          	jal	ra,80005872 <panic>
    panic("sched locks");
    80001802:	00006517          	auipc	a0,0x6
    80001806:	aee50513          	addi	a0,a0,-1298 # 800072f0 <etext+0x2f0>
    8000180a:	068040ef          	jal	ra,80005872 <panic>
    panic("sched running");
    8000180e:	00006517          	auipc	a0,0x6
    80001812:	af250513          	addi	a0,a0,-1294 # 80007300 <etext+0x300>
    80001816:	05c040ef          	jal	ra,80005872 <panic>
    panic("sched interruptible");
    8000181a:	00006517          	auipc	a0,0x6
    8000181e:	af650513          	addi	a0,a0,-1290 # 80007310 <etext+0x310>
    80001822:	050040ef          	jal	ra,80005872 <panic>

0000000080001826 <yield>:
{
    80001826:	1101                	addi	sp,sp,-32
    80001828:	ec06                	sd	ra,24(sp)
    8000182a:	e822                	sd	s0,16(sp)
    8000182c:	e426                	sd	s1,8(sp)
    8000182e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001830:	9b5ff0ef          	jal	ra,800011e4 <myproc>
    80001834:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001836:	358040ef          	jal	ra,80005b8e <acquire>
  p->state = RUNNABLE;
    8000183a:	478d                	li	a5,3
    8000183c:	cc9c                	sw	a5,24(s1)
  sched();
    8000183e:	f2fff0ef          	jal	ra,8000176c <sched>
  release(&p->lock);
    80001842:	8526                	mv	a0,s1
    80001844:	3e2040ef          	jal	ra,80005c26 <release>
}
    80001848:	60e2                	ld	ra,24(sp)
    8000184a:	6442                	ld	s0,16(sp)
    8000184c:	64a2                	ld	s1,8(sp)
    8000184e:	6105                	addi	sp,sp,32
    80001850:	8082                	ret

0000000080001852 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001852:	7179                	addi	sp,sp,-48
    80001854:	f406                	sd	ra,40(sp)
    80001856:	f022                	sd	s0,32(sp)
    80001858:	ec26                	sd	s1,24(sp)
    8000185a:	e84a                	sd	s2,16(sp)
    8000185c:	e44e                	sd	s3,8(sp)
    8000185e:	1800                	addi	s0,sp,48
    80001860:	89aa                	mv	s3,a0
    80001862:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001864:	981ff0ef          	jal	ra,800011e4 <myproc>
    80001868:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000186a:	324040ef          	jal	ra,80005b8e <acquire>
  release(lk);
    8000186e:	854a                	mv	a0,s2
    80001870:	3b6040ef          	jal	ra,80005c26 <release>

  // Go to sleep.
  p->chan = chan;
    80001874:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001878:	4789                	li	a5,2
    8000187a:	cc9c                	sw	a5,24(s1)

  sched();
    8000187c:	ef1ff0ef          	jal	ra,8000176c <sched>

  // Tidy up.
  p->chan = 0;
    80001880:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001884:	8526                	mv	a0,s1
    80001886:	3a0040ef          	jal	ra,80005c26 <release>
  acquire(lk);
    8000188a:	854a                	mv	a0,s2
    8000188c:	302040ef          	jal	ra,80005b8e <acquire>
}
    80001890:	70a2                	ld	ra,40(sp)
    80001892:	7402                	ld	s0,32(sp)
    80001894:	64e2                	ld	s1,24(sp)
    80001896:	6942                	ld	s2,16(sp)
    80001898:	69a2                	ld	s3,8(sp)
    8000189a:	6145                	addi	sp,sp,48
    8000189c:	8082                	ret

000000008000189e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000189e:	7139                	addi	sp,sp,-64
    800018a0:	fc06                	sd	ra,56(sp)
    800018a2:	f822                	sd	s0,48(sp)
    800018a4:	f426                	sd	s1,40(sp)
    800018a6:	f04a                	sd	s2,32(sp)
    800018a8:	ec4e                	sd	s3,24(sp)
    800018aa:	e852                	sd	s4,16(sp)
    800018ac:	e456                	sd	s5,8(sp)
    800018ae:	0080                	addi	s0,sp,64
    800018b0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800018b2:	00006497          	auipc	s1,0x6
    800018b6:	61648493          	addi	s1,s1,1558 # 80007ec8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800018ba:	4989                	li	s3,2
        p->state = RUNNABLE;
    800018bc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800018be:	0000c917          	auipc	s2,0xc
    800018c2:	00a90913          	addi	s2,s2,10 # 8000d8c8 <tickslock>
    800018c6:	a811                	j	800018da <wakeup+0x3c>
        p->state = RUNNABLE;
    800018c8:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800018cc:	8526                	mv	a0,s1
    800018ce:	358040ef          	jal	ra,80005c26 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d2:	16848493          	addi	s1,s1,360
    800018d6:	03248063          	beq	s1,s2,800018f6 <wakeup+0x58>
    if(p != myproc()){
    800018da:	90bff0ef          	jal	ra,800011e4 <myproc>
    800018de:	fea48ae3          	beq	s1,a0,800018d2 <wakeup+0x34>
      acquire(&p->lock);
    800018e2:	8526                	mv	a0,s1
    800018e4:	2aa040ef          	jal	ra,80005b8e <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800018e8:	4c9c                	lw	a5,24(s1)
    800018ea:	ff3791e3          	bne	a5,s3,800018cc <wakeup+0x2e>
    800018ee:	709c                	ld	a5,32(s1)
    800018f0:	fd479ee3          	bne	a5,s4,800018cc <wakeup+0x2e>
    800018f4:	bfd1                	j	800018c8 <wakeup+0x2a>
    }
  }
}
    800018f6:	70e2                	ld	ra,56(sp)
    800018f8:	7442                	ld	s0,48(sp)
    800018fa:	74a2                	ld	s1,40(sp)
    800018fc:	7902                	ld	s2,32(sp)
    800018fe:	69e2                	ld	s3,24(sp)
    80001900:	6a42                	ld	s4,16(sp)
    80001902:	6aa2                	ld	s5,8(sp)
    80001904:	6121                	addi	sp,sp,64
    80001906:	8082                	ret

0000000080001908 <reparent>:
{
    80001908:	7179                	addi	sp,sp,-48
    8000190a:	f406                	sd	ra,40(sp)
    8000190c:	f022                	sd	s0,32(sp)
    8000190e:	ec26                	sd	s1,24(sp)
    80001910:	e84a                	sd	s2,16(sp)
    80001912:	e44e                	sd	s3,8(sp)
    80001914:	e052                	sd	s4,0(sp)
    80001916:	1800                	addi	s0,sp,48
    80001918:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000191a:	00006497          	auipc	s1,0x6
    8000191e:	5ae48493          	addi	s1,s1,1454 # 80007ec8 <proc>
      pp->parent = initproc;
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	12ea0a13          	addi	s4,s4,302 # 80007a50 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000192a:	0000c997          	auipc	s3,0xc
    8000192e:	f9e98993          	addi	s3,s3,-98 # 8000d8c8 <tickslock>
    80001932:	a029                	j	8000193c <reparent+0x34>
    80001934:	16848493          	addi	s1,s1,360
    80001938:	01348b63          	beq	s1,s3,8000194e <reparent+0x46>
    if(pp->parent == p){
    8000193c:	7c9c                	ld	a5,56(s1)
    8000193e:	ff279be3          	bne	a5,s2,80001934 <reparent+0x2c>
      pp->parent = initproc;
    80001942:	000a3503          	ld	a0,0(s4)
    80001946:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001948:	f57ff0ef          	jal	ra,8000189e <wakeup>
    8000194c:	b7e5                	j	80001934 <reparent+0x2c>
}
    8000194e:	70a2                	ld	ra,40(sp)
    80001950:	7402                	ld	s0,32(sp)
    80001952:	64e2                	ld	s1,24(sp)
    80001954:	6942                	ld	s2,16(sp)
    80001956:	69a2                	ld	s3,8(sp)
    80001958:	6a02                	ld	s4,0(sp)
    8000195a:	6145                	addi	sp,sp,48
    8000195c:	8082                	ret

000000008000195e <exit>:
{
    8000195e:	7179                	addi	sp,sp,-48
    80001960:	f406                	sd	ra,40(sp)
    80001962:	f022                	sd	s0,32(sp)
    80001964:	ec26                	sd	s1,24(sp)
    80001966:	e84a                	sd	s2,16(sp)
    80001968:	e44e                	sd	s3,8(sp)
    8000196a:	e052                	sd	s4,0(sp)
    8000196c:	1800                	addi	s0,sp,48
    8000196e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001970:	875ff0ef          	jal	ra,800011e4 <myproc>
    80001974:	89aa                	mv	s3,a0
  if(p == initproc)
    80001976:	00006797          	auipc	a5,0x6
    8000197a:	0da7b783          	ld	a5,218(a5) # 80007a50 <initproc>
    8000197e:	0d050493          	addi	s1,a0,208
    80001982:	15050913          	addi	s2,a0,336
    80001986:	00a79f63          	bne	a5,a0,800019a4 <exit+0x46>
    panic("init exiting");
    8000198a:	00006517          	auipc	a0,0x6
    8000198e:	99e50513          	addi	a0,a0,-1634 # 80007328 <etext+0x328>
    80001992:	6e1030ef          	jal	ra,80005872 <panic>
      fileclose(f);
    80001996:	6a5010ef          	jal	ra,8000383a <fileclose>
      p->ofile[fd] = 0;
    8000199a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000199e:	04a1                	addi	s1,s1,8
    800019a0:	01248563          	beq	s1,s2,800019aa <exit+0x4c>
    if(p->ofile[fd]){
    800019a4:	6088                	ld	a0,0(s1)
    800019a6:	f965                	bnez	a0,80001996 <exit+0x38>
    800019a8:	bfdd                	j	8000199e <exit+0x40>
  begin_op();
    800019aa:	275010ef          	jal	ra,8000341e <begin_op>
  iput(p->cwd);
    800019ae:	1509b503          	ld	a0,336(s3)
    800019b2:	360010ef          	jal	ra,80002d12 <iput>
  end_op();
    800019b6:	2d9010ef          	jal	ra,8000348e <end_op>
  p->cwd = 0;
    800019ba:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800019be:	00006497          	auipc	s1,0x6
    800019c2:	0f248493          	addi	s1,s1,242 # 80007ab0 <wait_lock>
    800019c6:	8526                	mv	a0,s1
    800019c8:	1c6040ef          	jal	ra,80005b8e <acquire>
  reparent(p);
    800019cc:	854e                	mv	a0,s3
    800019ce:	f3bff0ef          	jal	ra,80001908 <reparent>
  wakeup(p->parent);
    800019d2:	0389b503          	ld	a0,56(s3)
    800019d6:	ec9ff0ef          	jal	ra,8000189e <wakeup>
  acquire(&p->lock);
    800019da:	854e                	mv	a0,s3
    800019dc:	1b2040ef          	jal	ra,80005b8e <acquire>
  p->xstate = status;
    800019e0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800019e4:	4795                	li	a5,5
    800019e6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800019ea:	8526                	mv	a0,s1
    800019ec:	23a040ef          	jal	ra,80005c26 <release>
  sched();
    800019f0:	d7dff0ef          	jal	ra,8000176c <sched>
  panic("zombie exit");
    800019f4:	00006517          	auipc	a0,0x6
    800019f8:	94450513          	addi	a0,a0,-1724 # 80007338 <etext+0x338>
    800019fc:	677030ef          	jal	ra,80005872 <panic>

0000000080001a00 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001a00:	7179                	addi	sp,sp,-48
    80001a02:	f406                	sd	ra,40(sp)
    80001a04:	f022                	sd	s0,32(sp)
    80001a06:	ec26                	sd	s1,24(sp)
    80001a08:	e84a                	sd	s2,16(sp)
    80001a0a:	e44e                	sd	s3,8(sp)
    80001a0c:	1800                	addi	s0,sp,48
    80001a0e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001a10:	00006497          	auipc	s1,0x6
    80001a14:	4b848493          	addi	s1,s1,1208 # 80007ec8 <proc>
    80001a18:	0000c997          	auipc	s3,0xc
    80001a1c:	eb098993          	addi	s3,s3,-336 # 8000d8c8 <tickslock>
    acquire(&p->lock);
    80001a20:	8526                	mv	a0,s1
    80001a22:	16c040ef          	jal	ra,80005b8e <acquire>
    if(p->pid == pid){
    80001a26:	589c                	lw	a5,48(s1)
    80001a28:	01278b63          	beq	a5,s2,80001a3e <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	1f8040ef          	jal	ra,80005c26 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a32:	16848493          	addi	s1,s1,360
    80001a36:	ff3495e3          	bne	s1,s3,80001a20 <kill+0x20>
  }
  return -1;
    80001a3a:	557d                	li	a0,-1
    80001a3c:	a819                	j	80001a52 <kill+0x52>
      p->killed = 1;
    80001a3e:	4785                	li	a5,1
    80001a40:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001a42:	4c98                	lw	a4,24(s1)
    80001a44:	4789                	li	a5,2
    80001a46:	00f70d63          	beq	a4,a5,80001a60 <kill+0x60>
      release(&p->lock);
    80001a4a:	8526                	mv	a0,s1
    80001a4c:	1da040ef          	jal	ra,80005c26 <release>
      return 0;
    80001a50:	4501                	li	a0,0
}
    80001a52:	70a2                	ld	ra,40(sp)
    80001a54:	7402                	ld	s0,32(sp)
    80001a56:	64e2                	ld	s1,24(sp)
    80001a58:	6942                	ld	s2,16(sp)
    80001a5a:	69a2                	ld	s3,8(sp)
    80001a5c:	6145                	addi	sp,sp,48
    80001a5e:	8082                	ret
        p->state = RUNNABLE;
    80001a60:	478d                	li	a5,3
    80001a62:	cc9c                	sw	a5,24(s1)
    80001a64:	b7dd                	j	80001a4a <kill+0x4a>

0000000080001a66 <setkilled>:

void
setkilled(struct proc *p)
{
    80001a66:	1101                	addi	sp,sp,-32
    80001a68:	ec06                	sd	ra,24(sp)
    80001a6a:	e822                	sd	s0,16(sp)
    80001a6c:	e426                	sd	s1,8(sp)
    80001a6e:	1000                	addi	s0,sp,32
    80001a70:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a72:	11c040ef          	jal	ra,80005b8e <acquire>
  p->killed = 1;
    80001a76:	4785                	li	a5,1
    80001a78:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	1aa040ef          	jal	ra,80005c26 <release>
}
    80001a80:	60e2                	ld	ra,24(sp)
    80001a82:	6442                	ld	s0,16(sp)
    80001a84:	64a2                	ld	s1,8(sp)
    80001a86:	6105                	addi	sp,sp,32
    80001a88:	8082                	ret

0000000080001a8a <killed>:

int
killed(struct proc *p)
{
    80001a8a:	1101                	addi	sp,sp,-32
    80001a8c:	ec06                	sd	ra,24(sp)
    80001a8e:	e822                	sd	s0,16(sp)
    80001a90:	e426                	sd	s1,8(sp)
    80001a92:	e04a                	sd	s2,0(sp)
    80001a94:	1000                	addi	s0,sp,32
    80001a96:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001a98:	0f6040ef          	jal	ra,80005b8e <acquire>
  k = p->killed;
    80001a9c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001aa0:	8526                	mv	a0,s1
    80001aa2:	184040ef          	jal	ra,80005c26 <release>
  return k;
}
    80001aa6:	854a                	mv	a0,s2
    80001aa8:	60e2                	ld	ra,24(sp)
    80001aaa:	6442                	ld	s0,16(sp)
    80001aac:	64a2                	ld	s1,8(sp)
    80001aae:	6902                	ld	s2,0(sp)
    80001ab0:	6105                	addi	sp,sp,32
    80001ab2:	8082                	ret

0000000080001ab4 <wait>:
{
    80001ab4:	715d                	addi	sp,sp,-80
    80001ab6:	e486                	sd	ra,72(sp)
    80001ab8:	e0a2                	sd	s0,64(sp)
    80001aba:	fc26                	sd	s1,56(sp)
    80001abc:	f84a                	sd	s2,48(sp)
    80001abe:	f44e                	sd	s3,40(sp)
    80001ac0:	f052                	sd	s4,32(sp)
    80001ac2:	ec56                	sd	s5,24(sp)
    80001ac4:	e85a                	sd	s6,16(sp)
    80001ac6:	e45e                	sd	s7,8(sp)
    80001ac8:	e062                	sd	s8,0(sp)
    80001aca:	0880                	addi	s0,sp,80
    80001acc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001ace:	f16ff0ef          	jal	ra,800011e4 <myproc>
    80001ad2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001ad4:	00006517          	auipc	a0,0x6
    80001ad8:	fdc50513          	addi	a0,a0,-36 # 80007ab0 <wait_lock>
    80001adc:	0b2040ef          	jal	ra,80005b8e <acquire>
    havekids = 0;
    80001ae0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001ae2:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ae4:	0000c997          	auipc	s3,0xc
    80001ae8:	de498993          	addi	s3,s3,-540 # 8000d8c8 <tickslock>
        havekids = 1;
    80001aec:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001aee:	00006c17          	auipc	s8,0x6
    80001af2:	fc2c0c13          	addi	s8,s8,-62 # 80007ab0 <wait_lock>
    havekids = 0;
    80001af6:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001af8:	00006497          	auipc	s1,0x6
    80001afc:	3d048493          	addi	s1,s1,976 # 80007ec8 <proc>
    80001b00:	a899                	j	80001b56 <wait+0xa2>
          pid = pp->pid;
    80001b02:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001b06:	000b0c63          	beqz	s6,80001b1e <wait+0x6a>
    80001b0a:	4691                	li	a3,4
    80001b0c:	02c48613          	addi	a2,s1,44
    80001b10:	85da                	mv	a1,s6
    80001b12:	05093503          	ld	a0,80(s2)
    80001b16:	b46ff0ef          	jal	ra,80000e5c <copyout>
    80001b1a:	00054f63          	bltz	a0,80001b38 <wait+0x84>
          freeproc(pp);
    80001b1e:	8526                	mv	a0,s1
    80001b20:	8ddff0ef          	jal	ra,800013fc <freeproc>
          release(&pp->lock);
    80001b24:	8526                	mv	a0,s1
    80001b26:	100040ef          	jal	ra,80005c26 <release>
          release(&wait_lock);
    80001b2a:	00006517          	auipc	a0,0x6
    80001b2e:	f8650513          	addi	a0,a0,-122 # 80007ab0 <wait_lock>
    80001b32:	0f4040ef          	jal	ra,80005c26 <release>
          return pid;
    80001b36:	a891                	j	80001b8a <wait+0xd6>
            release(&pp->lock);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	0ec040ef          	jal	ra,80005c26 <release>
            release(&wait_lock);
    80001b3e:	00006517          	auipc	a0,0x6
    80001b42:	f7250513          	addi	a0,a0,-142 # 80007ab0 <wait_lock>
    80001b46:	0e0040ef          	jal	ra,80005c26 <release>
            return -1;
    80001b4a:	59fd                	li	s3,-1
    80001b4c:	a83d                	j	80001b8a <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001b4e:	16848493          	addi	s1,s1,360
    80001b52:	03348063          	beq	s1,s3,80001b72 <wait+0xbe>
      if(pp->parent == p){
    80001b56:	7c9c                	ld	a5,56(s1)
    80001b58:	ff279be3          	bne	a5,s2,80001b4e <wait+0x9a>
        acquire(&pp->lock);
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	030040ef          	jal	ra,80005b8e <acquire>
        if(pp->state == ZOMBIE){
    80001b62:	4c9c                	lw	a5,24(s1)
    80001b64:	f9478fe3          	beq	a5,s4,80001b02 <wait+0x4e>
        release(&pp->lock);
    80001b68:	8526                	mv	a0,s1
    80001b6a:	0bc040ef          	jal	ra,80005c26 <release>
        havekids = 1;
    80001b6e:	8756                	mv	a4,s5
    80001b70:	bff9                	j	80001b4e <wait+0x9a>
    if(!havekids || killed(p)){
    80001b72:	c709                	beqz	a4,80001b7c <wait+0xc8>
    80001b74:	854a                	mv	a0,s2
    80001b76:	f15ff0ef          	jal	ra,80001a8a <killed>
    80001b7a:	c50d                	beqz	a0,80001ba4 <wait+0xf0>
      release(&wait_lock);
    80001b7c:	00006517          	auipc	a0,0x6
    80001b80:	f3450513          	addi	a0,a0,-204 # 80007ab0 <wait_lock>
    80001b84:	0a2040ef          	jal	ra,80005c26 <release>
      return -1;
    80001b88:	59fd                	li	s3,-1
}
    80001b8a:	854e                	mv	a0,s3
    80001b8c:	60a6                	ld	ra,72(sp)
    80001b8e:	6406                	ld	s0,64(sp)
    80001b90:	74e2                	ld	s1,56(sp)
    80001b92:	7942                	ld	s2,48(sp)
    80001b94:	79a2                	ld	s3,40(sp)
    80001b96:	7a02                	ld	s4,32(sp)
    80001b98:	6ae2                	ld	s5,24(sp)
    80001b9a:	6b42                	ld	s6,16(sp)
    80001b9c:	6ba2                	ld	s7,8(sp)
    80001b9e:	6c02                	ld	s8,0(sp)
    80001ba0:	6161                	addi	sp,sp,80
    80001ba2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001ba4:	85e2                	mv	a1,s8
    80001ba6:	854a                	mv	a0,s2
    80001ba8:	cabff0ef          	jal	ra,80001852 <sleep>
    havekids = 0;
    80001bac:	b7a9                	j	80001af6 <wait+0x42>

0000000080001bae <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001bae:	7179                	addi	sp,sp,-48
    80001bb0:	f406                	sd	ra,40(sp)
    80001bb2:	f022                	sd	s0,32(sp)
    80001bb4:	ec26                	sd	s1,24(sp)
    80001bb6:	e84a                	sd	s2,16(sp)
    80001bb8:	e44e                	sd	s3,8(sp)
    80001bba:	e052                	sd	s4,0(sp)
    80001bbc:	1800                	addi	s0,sp,48
    80001bbe:	84aa                	mv	s1,a0
    80001bc0:	892e                	mv	s2,a1
    80001bc2:	89b2                	mv	s3,a2
    80001bc4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001bc6:	e1eff0ef          	jal	ra,800011e4 <myproc>
  if(user_dst){
    80001bca:	cc99                	beqz	s1,80001be8 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80001bcc:	86d2                	mv	a3,s4
    80001bce:	864e                	mv	a2,s3
    80001bd0:	85ca                	mv	a1,s2
    80001bd2:	6928                	ld	a0,80(a0)
    80001bd4:	a88ff0ef          	jal	ra,80000e5c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001bd8:	70a2                	ld	ra,40(sp)
    80001bda:	7402                	ld	s0,32(sp)
    80001bdc:	64e2                	ld	s1,24(sp)
    80001bde:	6942                	ld	s2,16(sp)
    80001be0:	69a2                	ld	s3,8(sp)
    80001be2:	6a02                	ld	s4,0(sp)
    80001be4:	6145                	addi	sp,sp,48
    80001be6:	8082                	ret
    memmove((char *)dst, src, len);
    80001be8:	000a061b          	sext.w	a2,s4
    80001bec:	85ce                	mv	a1,s3
    80001bee:	854a                	mv	a0,s2
    80001bf0:	eaafe0ef          	jal	ra,8000029a <memmove>
    return 0;
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	b7cd                	j	80001bd8 <either_copyout+0x2a>

0000000080001bf8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001bf8:	7179                	addi	sp,sp,-48
    80001bfa:	f406                	sd	ra,40(sp)
    80001bfc:	f022                	sd	s0,32(sp)
    80001bfe:	ec26                	sd	s1,24(sp)
    80001c00:	e84a                	sd	s2,16(sp)
    80001c02:	e44e                	sd	s3,8(sp)
    80001c04:	e052                	sd	s4,0(sp)
    80001c06:	1800                	addi	s0,sp,48
    80001c08:	892a                	mv	s2,a0
    80001c0a:	84ae                	mv	s1,a1
    80001c0c:	89b2                	mv	s3,a2
    80001c0e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001c10:	dd4ff0ef          	jal	ra,800011e4 <myproc>
  if(user_src){
    80001c14:	cc99                	beqz	s1,80001c32 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001c16:	86d2                	mv	a3,s4
    80001c18:	864e                	mv	a2,s3
    80001c1a:	85ca                	mv	a1,s2
    80001c1c:	6928                	ld	a0,80(a0)
    80001c1e:	af6ff0ef          	jal	ra,80000f14 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001c22:	70a2                	ld	ra,40(sp)
    80001c24:	7402                	ld	s0,32(sp)
    80001c26:	64e2                	ld	s1,24(sp)
    80001c28:	6942                	ld	s2,16(sp)
    80001c2a:	69a2                	ld	s3,8(sp)
    80001c2c:	6a02                	ld	s4,0(sp)
    80001c2e:	6145                	addi	sp,sp,48
    80001c30:	8082                	ret
    memmove(dst, (char*)src, len);
    80001c32:	000a061b          	sext.w	a2,s4
    80001c36:	85ce                	mv	a1,s3
    80001c38:	854a                	mv	a0,s2
    80001c3a:	e60fe0ef          	jal	ra,8000029a <memmove>
    return 0;
    80001c3e:	8526                	mv	a0,s1
    80001c40:	b7cd                	j	80001c22 <either_copyin+0x2a>

0000000080001c42 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001c42:	715d                	addi	sp,sp,-80
    80001c44:	e486                	sd	ra,72(sp)
    80001c46:	e0a2                	sd	s0,64(sp)
    80001c48:	fc26                	sd	s1,56(sp)
    80001c4a:	f84a                	sd	s2,48(sp)
    80001c4c:	f44e                	sd	s3,40(sp)
    80001c4e:	f052                	sd	s4,32(sp)
    80001c50:	ec56                	sd	s5,24(sp)
    80001c52:	e85a                	sd	s6,16(sp)
    80001c54:	e45e                	sd	s7,8(sp)
    80001c56:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001c58:	00005517          	auipc	a0,0x5
    80001c5c:	40050513          	addi	a0,a0,1024 # 80007058 <etext+0x58>
    80001c60:	15f030ef          	jal	ra,800055be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001c64:	00006497          	auipc	s1,0x6
    80001c68:	3bc48493          	addi	s1,s1,956 # 80008020 <proc+0x158>
    80001c6c:	0000c917          	auipc	s2,0xc
    80001c70:	db490913          	addi	s2,s2,-588 # 8000da20 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c74:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001c76:	00005997          	auipc	s3,0x5
    80001c7a:	6d298993          	addi	s3,s3,1746 # 80007348 <etext+0x348>
    printf("%d %s %s", p->pid, state, p->name);
    80001c7e:	00005a97          	auipc	s5,0x5
    80001c82:	6d2a8a93          	addi	s5,s5,1746 # 80007350 <etext+0x350>
    printf("\n");
    80001c86:	00005a17          	auipc	s4,0x5
    80001c8a:	3d2a0a13          	addi	s4,s4,978 # 80007058 <etext+0x58>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c8e:	00005b97          	auipc	s7,0x5
    80001c92:	702b8b93          	addi	s7,s7,1794 # 80007390 <states.2263>
    80001c96:	a829                	j	80001cb0 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80001c98:	ed86a583          	lw	a1,-296(a3)
    80001c9c:	8556                	mv	a0,s5
    80001c9e:	121030ef          	jal	ra,800055be <printf>
    printf("\n");
    80001ca2:	8552                	mv	a0,s4
    80001ca4:	11b030ef          	jal	ra,800055be <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001ca8:	16848493          	addi	s1,s1,360
    80001cac:	03248163          	beq	s1,s2,80001cce <procdump+0x8c>
    if(p->state == UNUSED)
    80001cb0:	86a6                	mv	a3,s1
    80001cb2:	ec04a783          	lw	a5,-320(s1)
    80001cb6:	dbed                	beqz	a5,80001ca8 <procdump+0x66>
      state = "???";
    80001cb8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001cba:	fcfb6fe3          	bltu	s6,a5,80001c98 <procdump+0x56>
    80001cbe:	1782                	slli	a5,a5,0x20
    80001cc0:	9381                	srli	a5,a5,0x20
    80001cc2:	078e                	slli	a5,a5,0x3
    80001cc4:	97de                	add	a5,a5,s7
    80001cc6:	6390                	ld	a2,0(a5)
    80001cc8:	fa61                	bnez	a2,80001c98 <procdump+0x56>
      state = "???";
    80001cca:	864e                	mv	a2,s3
    80001ccc:	b7f1                	j	80001c98 <procdump+0x56>
  }
}
    80001cce:	60a6                	ld	ra,72(sp)
    80001cd0:	6406                	ld	s0,64(sp)
    80001cd2:	74e2                	ld	s1,56(sp)
    80001cd4:	7942                	ld	s2,48(sp)
    80001cd6:	79a2                	ld	s3,40(sp)
    80001cd8:	7a02                	ld	s4,32(sp)
    80001cda:	6ae2                	ld	s5,24(sp)
    80001cdc:	6b42                	ld	s6,16(sp)
    80001cde:	6ba2                	ld	s7,8(sp)
    80001ce0:	6161                	addi	sp,sp,80
    80001ce2:	8082                	ret

0000000080001ce4 <swtch>:
    80001ce4:	00153023          	sd	ra,0(a0)
    80001ce8:	00253423          	sd	sp,8(a0)
    80001cec:	e900                	sd	s0,16(a0)
    80001cee:	ed04                	sd	s1,24(a0)
    80001cf0:	03253023          	sd	s2,32(a0)
    80001cf4:	03353423          	sd	s3,40(a0)
    80001cf8:	03453823          	sd	s4,48(a0)
    80001cfc:	03553c23          	sd	s5,56(a0)
    80001d00:	05653023          	sd	s6,64(a0)
    80001d04:	05753423          	sd	s7,72(a0)
    80001d08:	05853823          	sd	s8,80(a0)
    80001d0c:	05953c23          	sd	s9,88(a0)
    80001d10:	07a53023          	sd	s10,96(a0)
    80001d14:	07b53423          	sd	s11,104(a0)
    80001d18:	0005b083          	ld	ra,0(a1)
    80001d1c:	0085b103          	ld	sp,8(a1)
    80001d20:	6980                	ld	s0,16(a1)
    80001d22:	6d84                	ld	s1,24(a1)
    80001d24:	0205b903          	ld	s2,32(a1)
    80001d28:	0285b983          	ld	s3,40(a1)
    80001d2c:	0305ba03          	ld	s4,48(a1)
    80001d30:	0385ba83          	ld	s5,56(a1)
    80001d34:	0405bb03          	ld	s6,64(a1)
    80001d38:	0485bb83          	ld	s7,72(a1)
    80001d3c:	0505bc03          	ld	s8,80(a1)
    80001d40:	0585bc83          	ld	s9,88(a1)
    80001d44:	0605bd03          	ld	s10,96(a1)
    80001d48:	0685bd83          	ld	s11,104(a1)
    80001d4c:	8082                	ret

0000000080001d4e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001d4e:	1141                	addi	sp,sp,-16
    80001d50:	e406                	sd	ra,8(sp)
    80001d52:	e022                	sd	s0,0(sp)
    80001d54:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001d56:	00005597          	auipc	a1,0x5
    80001d5a:	66a58593          	addi	a1,a1,1642 # 800073c0 <states.2263+0x30>
    80001d5e:	0000c517          	auipc	a0,0xc
    80001d62:	b6a50513          	addi	a0,a0,-1174 # 8000d8c8 <tickslock>
    80001d66:	5a9030ef          	jal	ra,80005b0e <initlock>
}
    80001d6a:	60a2                	ld	ra,8(sp)
    80001d6c:	6402                	ld	s0,0(sp)
    80001d6e:	0141                	addi	sp,sp,16
    80001d70:	8082                	ret

0000000080001d72 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001d72:	1141                	addi	sp,sp,-16
    80001d74:	e422                	sd	s0,8(sp)
    80001d76:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d78:	00003797          	auipc	a5,0x3
    80001d7c:	d8878793          	addi	a5,a5,-632 # 80004b00 <kernelvec>
    80001d80:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001d84:	6422                	ld	s0,8(sp)
    80001d86:	0141                	addi	sp,sp,16
    80001d88:	8082                	ret

0000000080001d8a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001d8a:	1141                	addi	sp,sp,-16
    80001d8c:	e406                	sd	ra,8(sp)
    80001d8e:	e022                	sd	s0,0(sp)
    80001d90:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001d92:	c52ff0ef          	jal	ra,800011e4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d9c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001da0:	00004617          	auipc	a2,0x4
    80001da4:	26060613          	addi	a2,a2,608 # 80006000 <_trampoline>
    80001da8:	00004697          	auipc	a3,0x4
    80001dac:	25868693          	addi	a3,a3,600 # 80006000 <_trampoline>
    80001db0:	8e91                	sub	a3,a3,a2
    80001db2:	040007b7          	lui	a5,0x4000
    80001db6:	17fd                	addi	a5,a5,-1
    80001db8:	07b2                	slli	a5,a5,0xc
    80001dba:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001dbc:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001dc0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001dc2:	180026f3          	csrr	a3,satp
    80001dc6:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001dc8:	6d38                	ld	a4,88(a0)
    80001dca:	6134                	ld	a3,64(a0)
    80001dcc:	6585                	lui	a1,0x1
    80001dce:	96ae                	add	a3,a3,a1
    80001dd0:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001dd2:	6d38                	ld	a4,88(a0)
    80001dd4:	00000697          	auipc	a3,0x0
    80001dd8:	10c68693          	addi	a3,a3,268 # 80001ee0 <usertrap>
    80001ddc:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001dde:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de0:	8692                	mv	a3,tp
    80001de2:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de4:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001de8:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001dec:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001df0:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001df4:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001df6:	6f18                	ld	a4,24(a4)
    80001df8:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001dfc:	6928                	ld	a0,80(a0)
    80001dfe:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001e00:	00004717          	auipc	a4,0x4
    80001e04:	29c70713          	addi	a4,a4,668 # 8000609c <userret>
    80001e08:	8f11                	sub	a4,a4,a2
    80001e0a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001e0c:	577d                	li	a4,-1
    80001e0e:	177e                	slli	a4,a4,0x3f
    80001e10:	8d59                	or	a0,a0,a4
    80001e12:	9782                	jalr	a5
}
    80001e14:	60a2                	ld	ra,8(sp)
    80001e16:	6402                	ld	s0,0(sp)
    80001e18:	0141                	addi	sp,sp,16
    80001e1a:	8082                	ret

0000000080001e1c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001e1c:	1101                	addi	sp,sp,-32
    80001e1e:	ec06                	sd	ra,24(sp)
    80001e20:	e822                	sd	s0,16(sp)
    80001e22:	e426                	sd	s1,8(sp)
    80001e24:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80001e26:	b92ff0ef          	jal	ra,800011b8 <cpuid>
    80001e2a:	cd19                	beqz	a0,80001e48 <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001e2c:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001e30:	000f4737          	lui	a4,0xf4
    80001e34:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001e38:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001e3a:	14d79073          	csrw	0x14d,a5
}
    80001e3e:	60e2                	ld	ra,24(sp)
    80001e40:	6442                	ld	s0,16(sp)
    80001e42:	64a2                	ld	s1,8(sp)
    80001e44:	6105                	addi	sp,sp,32
    80001e46:	8082                	ret
    acquire(&tickslock);
    80001e48:	0000c497          	auipc	s1,0xc
    80001e4c:	a8048493          	addi	s1,s1,-1408 # 8000d8c8 <tickslock>
    80001e50:	8526                	mv	a0,s1
    80001e52:	53d030ef          	jal	ra,80005b8e <acquire>
    ticks++;
    80001e56:	00006517          	auipc	a0,0x6
    80001e5a:	c0250513          	addi	a0,a0,-1022 # 80007a58 <ticks>
    80001e5e:	411c                	lw	a5,0(a0)
    80001e60:	2785                	addiw	a5,a5,1
    80001e62:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80001e64:	a3bff0ef          	jal	ra,8000189e <wakeup>
    release(&tickslock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	5bd030ef          	jal	ra,80005c26 <release>
    80001e6e:	bf7d                	j	80001e2c <clockintr+0x10>

0000000080001e70 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001e70:	1101                	addi	sp,sp,-32
    80001e72:	ec06                	sd	ra,24(sp)
    80001e74:	e822                	sd	s0,16(sp)
    80001e76:	e426                	sd	s1,8(sp)
    80001e78:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e7a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001e7e:	57fd                	li	a5,-1
    80001e80:	17fe                	slli	a5,a5,0x3f
    80001e82:	07a5                	addi	a5,a5,9
    80001e84:	00f70d63          	beq	a4,a5,80001e9e <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001e88:	57fd                	li	a5,-1
    80001e8a:	17fe                	slli	a5,a5,0x3f
    80001e8c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001e8e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001e90:	04f70463          	beq	a4,a5,80001ed8 <devintr+0x68>
  }
}
    80001e94:	60e2                	ld	ra,24(sp)
    80001e96:	6442                	ld	s0,16(sp)
    80001e98:	64a2                	ld	s1,8(sp)
    80001e9a:	6105                	addi	sp,sp,32
    80001e9c:	8082                	ret
    int irq = plic_claim();
    80001e9e:	50b020ef          	jal	ra,80004ba8 <plic_claim>
    80001ea2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001ea4:	47a9                	li	a5,10
    80001ea6:	02f50363          	beq	a0,a5,80001ecc <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001eaa:	4785                	li	a5,1
    80001eac:	02f50363          	beq	a0,a5,80001ed2 <devintr+0x62>
    return 1;
    80001eb0:	4505                	li	a0,1
    } else if(irq){
    80001eb2:	d0ed                	beqz	s1,80001e94 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001eb4:	85a6                	mv	a1,s1
    80001eb6:	00005517          	auipc	a0,0x5
    80001eba:	51250513          	addi	a0,a0,1298 # 800073c8 <states.2263+0x38>
    80001ebe:	700030ef          	jal	ra,800055be <printf>
      plic_complete(irq);
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	505020ef          	jal	ra,80004bc8 <plic_complete>
    return 1;
    80001ec8:	4505                	li	a0,1
    80001eca:	b7e9                	j	80001e94 <devintr+0x24>
      uartintr();
    80001ecc:	407030ef          	jal	ra,80005ad2 <uartintr>
    80001ed0:	bfcd                	j	80001ec2 <devintr+0x52>
      virtio_disk_intr();
    80001ed2:	1bc030ef          	jal	ra,8000508e <virtio_disk_intr>
    80001ed6:	b7f5                	j	80001ec2 <devintr+0x52>
    clockintr();
    80001ed8:	f45ff0ef          	jal	ra,80001e1c <clockintr>
    return 2;
    80001edc:	4509                	li	a0,2
    80001ede:	bf5d                	j	80001e94 <devintr+0x24>

0000000080001ee0 <usertrap>:
{
    80001ee0:	1101                	addi	sp,sp,-32
    80001ee2:	ec06                	sd	ra,24(sp)
    80001ee4:	e822                	sd	s0,16(sp)
    80001ee6:	e426                	sd	s1,8(sp)
    80001ee8:	e04a                	sd	s2,0(sp)
    80001eea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eec:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001ef0:	1007f793          	andi	a5,a5,256
    80001ef4:	ef85                	bnez	a5,80001f2c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ef6:	00003797          	auipc	a5,0x3
    80001efa:	c0a78793          	addi	a5,a5,-1014 # 80004b00 <kernelvec>
    80001efe:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001f02:	ae2ff0ef          	jal	ra,800011e4 <myproc>
    80001f06:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001f08:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f0a:	14102773          	csrr	a4,sepc
    80001f0e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f10:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001f14:	47a1                	li	a5,8
    80001f16:	02f70163          	beq	a4,a5,80001f38 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001f1a:	f57ff0ef          	jal	ra,80001e70 <devintr>
    80001f1e:	892a                	mv	s2,a0
    80001f20:	c135                	beqz	a0,80001f84 <usertrap+0xa4>
  if(killed(p))
    80001f22:	8526                	mv	a0,s1
    80001f24:	b67ff0ef          	jal	ra,80001a8a <killed>
    80001f28:	cd1d                	beqz	a0,80001f66 <usertrap+0x86>
    80001f2a:	a81d                	j	80001f60 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001f2c:	00005517          	auipc	a0,0x5
    80001f30:	4bc50513          	addi	a0,a0,1212 # 800073e8 <states.2263+0x58>
    80001f34:	13f030ef          	jal	ra,80005872 <panic>
    if(killed(p))
    80001f38:	b53ff0ef          	jal	ra,80001a8a <killed>
    80001f3c:	e121                	bnez	a0,80001f7c <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001f3e:	6cb8                	ld	a4,88(s1)
    80001f40:	6f1c                	ld	a5,24(a4)
    80001f42:	0791                	addi	a5,a5,4
    80001f44:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f4a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f4e:	10079073          	csrw	sstatus,a5
    syscall();
    80001f52:	248000ef          	jal	ra,8000219a <syscall>
  if(killed(p))
    80001f56:	8526                	mv	a0,s1
    80001f58:	b33ff0ef          	jal	ra,80001a8a <killed>
    80001f5c:	c901                	beqz	a0,80001f6c <usertrap+0x8c>
    80001f5e:	4901                	li	s2,0
    exit(-1);
    80001f60:	557d                	li	a0,-1
    80001f62:	9fdff0ef          	jal	ra,8000195e <exit>
  if(which_dev == 2)
    80001f66:	4789                	li	a5,2
    80001f68:	04f90563          	beq	s2,a5,80001fb2 <usertrap+0xd2>
  usertrapret();
    80001f6c:	e1fff0ef          	jal	ra,80001d8a <usertrapret>
}
    80001f70:	60e2                	ld	ra,24(sp)
    80001f72:	6442                	ld	s0,16(sp)
    80001f74:	64a2                	ld	s1,8(sp)
    80001f76:	6902                	ld	s2,0(sp)
    80001f78:	6105                	addi	sp,sp,32
    80001f7a:	8082                	ret
      exit(-1);
    80001f7c:	557d                	li	a0,-1
    80001f7e:	9e1ff0ef          	jal	ra,8000195e <exit>
    80001f82:	bf75                	j	80001f3e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f84:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001f88:	5890                	lw	a2,48(s1)
    80001f8a:	00005517          	auipc	a0,0x5
    80001f8e:	47e50513          	addi	a0,a0,1150 # 80007408 <states.2263+0x78>
    80001f92:	62c030ef          	jal	ra,800055be <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f96:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f9a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001f9e:	00005517          	auipc	a0,0x5
    80001fa2:	49a50513          	addi	a0,a0,1178 # 80007438 <states.2263+0xa8>
    80001fa6:	618030ef          	jal	ra,800055be <printf>
    setkilled(p);
    80001faa:	8526                	mv	a0,s1
    80001fac:	abbff0ef          	jal	ra,80001a66 <setkilled>
    80001fb0:	b75d                	j	80001f56 <usertrap+0x76>
    yield();
    80001fb2:	875ff0ef          	jal	ra,80001826 <yield>
    80001fb6:	bf5d                	j	80001f6c <usertrap+0x8c>

0000000080001fb8 <kerneltrap>:
{
    80001fb8:	7179                	addi	sp,sp,-48
    80001fba:	f406                	sd	ra,40(sp)
    80001fbc:	f022                	sd	s0,32(sp)
    80001fbe:	ec26                	sd	s1,24(sp)
    80001fc0:	e84a                	sd	s2,16(sp)
    80001fc2:	e44e                	sd	s3,8(sp)
    80001fc4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001fc6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fca:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001fce:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001fd2:	1004f793          	andi	a5,s1,256
    80001fd6:	c795                	beqz	a5,80002002 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fd8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fdc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001fde:	eb85                	bnez	a5,8000200e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001fe0:	e91ff0ef          	jal	ra,80001e70 <devintr>
    80001fe4:	c91d                	beqz	a0,8000201a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001fe6:	4789                	li	a5,2
    80001fe8:	04f50a63          	beq	a0,a5,8000203c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001fec:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ff0:	10049073          	csrw	sstatus,s1
}
    80001ff4:	70a2                	ld	ra,40(sp)
    80001ff6:	7402                	ld	s0,32(sp)
    80001ff8:	64e2                	ld	s1,24(sp)
    80001ffa:	6942                	ld	s2,16(sp)
    80001ffc:	69a2                	ld	s3,8(sp)
    80001ffe:	6145                	addi	sp,sp,48
    80002000:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002002:	00005517          	auipc	a0,0x5
    80002006:	45e50513          	addi	a0,a0,1118 # 80007460 <states.2263+0xd0>
    8000200a:	069030ef          	jal	ra,80005872 <panic>
    panic("kerneltrap: interrupts enabled");
    8000200e:	00005517          	auipc	a0,0x5
    80002012:	47a50513          	addi	a0,a0,1146 # 80007488 <states.2263+0xf8>
    80002016:	05d030ef          	jal	ra,80005872 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000201a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000201e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002022:	85ce                	mv	a1,s3
    80002024:	00005517          	auipc	a0,0x5
    80002028:	48450513          	addi	a0,a0,1156 # 800074a8 <states.2263+0x118>
    8000202c:	592030ef          	jal	ra,800055be <printf>
    panic("kerneltrap");
    80002030:	00005517          	auipc	a0,0x5
    80002034:	4a050513          	addi	a0,a0,1184 # 800074d0 <states.2263+0x140>
    80002038:	03b030ef          	jal	ra,80005872 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000203c:	9a8ff0ef          	jal	ra,800011e4 <myproc>
    80002040:	d555                	beqz	a0,80001fec <kerneltrap+0x34>
    yield();
    80002042:	fe4ff0ef          	jal	ra,80001826 <yield>
    80002046:	b75d                	j	80001fec <kerneltrap+0x34>

0000000080002048 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002048:	1101                	addi	sp,sp,-32
    8000204a:	ec06                	sd	ra,24(sp)
    8000204c:	e822                	sd	s0,16(sp)
    8000204e:	e426                	sd	s1,8(sp)
    80002050:	1000                	addi	s0,sp,32
    80002052:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002054:	990ff0ef          	jal	ra,800011e4 <myproc>
  switch (n) {
    80002058:	4795                	li	a5,5
    8000205a:	0497e163          	bltu	a5,s1,8000209c <argraw+0x54>
    8000205e:	048a                	slli	s1,s1,0x2
    80002060:	00005717          	auipc	a4,0x5
    80002064:	4a870713          	addi	a4,a4,1192 # 80007508 <states.2263+0x178>
    80002068:	94ba                	add	s1,s1,a4
    8000206a:	409c                	lw	a5,0(s1)
    8000206c:	97ba                	add	a5,a5,a4
    8000206e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002070:	6d3c                	ld	a5,88(a0)
    80002072:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002074:	60e2                	ld	ra,24(sp)
    80002076:	6442                	ld	s0,16(sp)
    80002078:	64a2                	ld	s1,8(sp)
    8000207a:	6105                	addi	sp,sp,32
    8000207c:	8082                	ret
    return p->trapframe->a1;
    8000207e:	6d3c                	ld	a5,88(a0)
    80002080:	7fa8                	ld	a0,120(a5)
    80002082:	bfcd                	j	80002074 <argraw+0x2c>
    return p->trapframe->a2;
    80002084:	6d3c                	ld	a5,88(a0)
    80002086:	63c8                	ld	a0,128(a5)
    80002088:	b7f5                	j	80002074 <argraw+0x2c>
    return p->trapframe->a3;
    8000208a:	6d3c                	ld	a5,88(a0)
    8000208c:	67c8                	ld	a0,136(a5)
    8000208e:	b7dd                	j	80002074 <argraw+0x2c>
    return p->trapframe->a4;
    80002090:	6d3c                	ld	a5,88(a0)
    80002092:	6bc8                	ld	a0,144(a5)
    80002094:	b7c5                	j	80002074 <argraw+0x2c>
    return p->trapframe->a5;
    80002096:	6d3c                	ld	a5,88(a0)
    80002098:	6fc8                	ld	a0,152(a5)
    8000209a:	bfe9                	j	80002074 <argraw+0x2c>
  panic("argraw");
    8000209c:	00005517          	auipc	a0,0x5
    800020a0:	44450513          	addi	a0,a0,1092 # 800074e0 <states.2263+0x150>
    800020a4:	7ce030ef          	jal	ra,80005872 <panic>

00000000800020a8 <fetchaddr>:
{
    800020a8:	1101                	addi	sp,sp,-32
    800020aa:	ec06                	sd	ra,24(sp)
    800020ac:	e822                	sd	s0,16(sp)
    800020ae:	e426                	sd	s1,8(sp)
    800020b0:	e04a                	sd	s2,0(sp)
    800020b2:	1000                	addi	s0,sp,32
    800020b4:	84aa                	mv	s1,a0
    800020b6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020b8:	92cff0ef          	jal	ra,800011e4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800020bc:	653c                	ld	a5,72(a0)
    800020be:	02f4f663          	bgeu	s1,a5,800020ea <fetchaddr+0x42>
    800020c2:	00848713          	addi	a4,s1,8
    800020c6:	02e7e463          	bltu	a5,a4,800020ee <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800020ca:	46a1                	li	a3,8
    800020cc:	8626                	mv	a2,s1
    800020ce:	85ca                	mv	a1,s2
    800020d0:	6928                	ld	a0,80(a0)
    800020d2:	e43fe0ef          	jal	ra,80000f14 <copyin>
    800020d6:	00a03533          	snez	a0,a0
    800020da:	40a00533          	neg	a0,a0
}
    800020de:	60e2                	ld	ra,24(sp)
    800020e0:	6442                	ld	s0,16(sp)
    800020e2:	64a2                	ld	s1,8(sp)
    800020e4:	6902                	ld	s2,0(sp)
    800020e6:	6105                	addi	sp,sp,32
    800020e8:	8082                	ret
    return -1;
    800020ea:	557d                	li	a0,-1
    800020ec:	bfcd                	j	800020de <fetchaddr+0x36>
    800020ee:	557d                	li	a0,-1
    800020f0:	b7fd                	j	800020de <fetchaddr+0x36>

00000000800020f2 <fetchstr>:
{
    800020f2:	7179                	addi	sp,sp,-48
    800020f4:	f406                	sd	ra,40(sp)
    800020f6:	f022                	sd	s0,32(sp)
    800020f8:	ec26                	sd	s1,24(sp)
    800020fa:	e84a                	sd	s2,16(sp)
    800020fc:	e44e                	sd	s3,8(sp)
    800020fe:	1800                	addi	s0,sp,48
    80002100:	892a                	mv	s2,a0
    80002102:	84ae                	mv	s1,a1
    80002104:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002106:	8deff0ef          	jal	ra,800011e4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000210a:	86ce                	mv	a3,s3
    8000210c:	864a                	mv	a2,s2
    8000210e:	85a6                	mv	a1,s1
    80002110:	6928                	ld	a0,80(a0)
    80002112:	e87fe0ef          	jal	ra,80000f98 <copyinstr>
    80002116:	00054c63          	bltz	a0,8000212e <fetchstr+0x3c>
  return strlen(buf);
    8000211a:	8526                	mv	a0,s1
    8000211c:	a9efe0ef          	jal	ra,800003ba <strlen>
}
    80002120:	70a2                	ld	ra,40(sp)
    80002122:	7402                	ld	s0,32(sp)
    80002124:	64e2                	ld	s1,24(sp)
    80002126:	6942                	ld	s2,16(sp)
    80002128:	69a2                	ld	s3,8(sp)
    8000212a:	6145                	addi	sp,sp,48
    8000212c:	8082                	ret
    return -1;
    8000212e:	557d                	li	a0,-1
    80002130:	bfc5                	j	80002120 <fetchstr+0x2e>

0000000080002132 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002132:	1101                	addi	sp,sp,-32
    80002134:	ec06                	sd	ra,24(sp)
    80002136:	e822                	sd	s0,16(sp)
    80002138:	e426                	sd	s1,8(sp)
    8000213a:	1000                	addi	s0,sp,32
    8000213c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000213e:	f0bff0ef          	jal	ra,80002048 <argraw>
    80002142:	c088                	sw	a0,0(s1)
}
    80002144:	60e2                	ld	ra,24(sp)
    80002146:	6442                	ld	s0,16(sp)
    80002148:	64a2                	ld	s1,8(sp)
    8000214a:	6105                	addi	sp,sp,32
    8000214c:	8082                	ret

000000008000214e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000214e:	1101                	addi	sp,sp,-32
    80002150:	ec06                	sd	ra,24(sp)
    80002152:	e822                	sd	s0,16(sp)
    80002154:	e426                	sd	s1,8(sp)
    80002156:	1000                	addi	s0,sp,32
    80002158:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000215a:	eefff0ef          	jal	ra,80002048 <argraw>
    8000215e:	e088                	sd	a0,0(s1)
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6105                	addi	sp,sp,32
    80002168:	8082                	ret

000000008000216a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000216a:	7179                	addi	sp,sp,-48
    8000216c:	f406                	sd	ra,40(sp)
    8000216e:	f022                	sd	s0,32(sp)
    80002170:	ec26                	sd	s1,24(sp)
    80002172:	e84a                	sd	s2,16(sp)
    80002174:	1800                	addi	s0,sp,48
    80002176:	84ae                	mv	s1,a1
    80002178:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000217a:	fd840593          	addi	a1,s0,-40
    8000217e:	fd1ff0ef          	jal	ra,8000214e <argaddr>
  return fetchstr(addr, buf, max);
    80002182:	864a                	mv	a2,s2
    80002184:	85a6                	mv	a1,s1
    80002186:	fd843503          	ld	a0,-40(s0)
    8000218a:	f69ff0ef          	jal	ra,800020f2 <fetchstr>
}
    8000218e:	70a2                	ld	ra,40(sp)
    80002190:	7402                	ld	s0,32(sp)
    80002192:	64e2                	ld	s1,24(sp)
    80002194:	6942                	ld	s2,16(sp)
    80002196:	6145                	addi	sp,sp,48
    80002198:	8082                	ret

000000008000219a <syscall>:



void
syscall(void)
{
    8000219a:	1101                	addi	sp,sp,-32
    8000219c:	ec06                	sd	ra,24(sp)
    8000219e:	e822                	sd	s0,16(sp)
    800021a0:	e426                	sd	s1,8(sp)
    800021a2:	e04a                	sd	s2,0(sp)
    800021a4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800021a6:	83eff0ef          	jal	ra,800011e4 <myproc>
    800021aa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800021ac:	05853903          	ld	s2,88(a0)
    800021b0:	0a893783          	ld	a5,168(s2)
    800021b4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800021b8:	37fd                	addiw	a5,a5,-1
    800021ba:	02100713          	li	a4,33
    800021be:	00f76f63          	bltu	a4,a5,800021dc <syscall+0x42>
    800021c2:	00369713          	slli	a4,a3,0x3
    800021c6:	00005797          	auipc	a5,0x5
    800021ca:	35a78793          	addi	a5,a5,858 # 80007520 <syscalls>
    800021ce:	97ba                	add	a5,a5,a4
    800021d0:	639c                	ld	a5,0(a5)
    800021d2:	c789                	beqz	a5,800021dc <syscall+0x42>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800021d4:	9782                	jalr	a5
    800021d6:	06a93823          	sd	a0,112(s2)
    800021da:	a829                	j	800021f4 <syscall+0x5a>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800021dc:	15848613          	addi	a2,s1,344
    800021e0:	588c                	lw	a1,48(s1)
    800021e2:	00005517          	auipc	a0,0x5
    800021e6:	30650513          	addi	a0,a0,774 # 800074e8 <states.2263+0x158>
    800021ea:	3d4030ef          	jal	ra,800055be <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800021ee:	6cbc                	ld	a5,88(s1)
    800021f0:	577d                	li	a4,-1
    800021f2:	fbb8                	sd	a4,112(a5)
  }
}
    800021f4:	60e2                	ld	ra,24(sp)
    800021f6:	6442                	ld	s0,16(sp)
    800021f8:	64a2                	ld	s1,8(sp)
    800021fa:	6902                	ld	s2,0(sp)
    800021fc:	6105                	addi	sp,sp,32
    800021fe:	8082                	ret

0000000080002200 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002200:	1101                	addi	sp,sp,-32
    80002202:	ec06                	sd	ra,24(sp)
    80002204:	e822                	sd	s0,16(sp)
    80002206:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002208:	fec40593          	addi	a1,s0,-20
    8000220c:	4501                	li	a0,0
    8000220e:	f25ff0ef          	jal	ra,80002132 <argint>
  exit(n);
    80002212:	fec42503          	lw	a0,-20(s0)
    80002216:	f48ff0ef          	jal	ra,8000195e <exit>
  return 0;  // not reached
}
    8000221a:	4501                	li	a0,0
    8000221c:	60e2                	ld	ra,24(sp)
    8000221e:	6442                	ld	s0,16(sp)
    80002220:	6105                	addi	sp,sp,32
    80002222:	8082                	ret

0000000080002224 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002224:	1141                	addi	sp,sp,-16
    80002226:	e406                	sd	ra,8(sp)
    80002228:	e022                	sd	s0,0(sp)
    8000222a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000222c:	fb9fe0ef          	jal	ra,800011e4 <myproc>
}
    80002230:	5908                	lw	a0,48(a0)
    80002232:	60a2                	ld	ra,8(sp)
    80002234:	6402                	ld	s0,0(sp)
    80002236:	0141                	addi	sp,sp,16
    80002238:	8082                	ret

000000008000223a <sys_fork>:

uint64
sys_fork(void)
{
    8000223a:	1141                	addi	sp,sp,-16
    8000223c:	e406                	sd	ra,8(sp)
    8000223e:	e022                	sd	s0,0(sp)
    80002240:	0800                	addi	s0,sp,16
  return fork();
    80002242:	b6eff0ef          	jal	ra,800015b0 <fork>
}
    80002246:	60a2                	ld	ra,8(sp)
    80002248:	6402                	ld	s0,0(sp)
    8000224a:	0141                	addi	sp,sp,16
    8000224c:	8082                	ret

000000008000224e <sys_wait>:

uint64
sys_wait(void)
{
    8000224e:	1101                	addi	sp,sp,-32
    80002250:	ec06                	sd	ra,24(sp)
    80002252:	e822                	sd	s0,16(sp)
    80002254:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002256:	fe840593          	addi	a1,s0,-24
    8000225a:	4501                	li	a0,0
    8000225c:	ef3ff0ef          	jal	ra,8000214e <argaddr>
  return wait(p);
    80002260:	fe843503          	ld	a0,-24(s0)
    80002264:	851ff0ef          	jal	ra,80001ab4 <wait>
}
    80002268:	60e2                	ld	ra,24(sp)
    8000226a:	6442                	ld	s0,16(sp)
    8000226c:	6105                	addi	sp,sp,32
    8000226e:	8082                	ret

0000000080002270 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002270:	7179                	addi	sp,sp,-48
    80002272:	f406                	sd	ra,40(sp)
    80002274:	f022                	sd	s0,32(sp)
    80002276:	ec26                	sd	s1,24(sp)
    80002278:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000227a:	fdc40593          	addi	a1,s0,-36
    8000227e:	4501                	li	a0,0
    80002280:	eb3ff0ef          	jal	ra,80002132 <argint>
  addr = myproc()->sz;
    80002284:	f61fe0ef          	jal	ra,800011e4 <myproc>
    80002288:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000228a:	fdc42503          	lw	a0,-36(s0)
    8000228e:	ad2ff0ef          	jal	ra,80001560 <growproc>
    80002292:	00054863          	bltz	a0,800022a2 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002296:	8526                	mv	a0,s1
    80002298:	70a2                	ld	ra,40(sp)
    8000229a:	7402                	ld	s0,32(sp)
    8000229c:	64e2                	ld	s1,24(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
    return -1;
    800022a2:	54fd                	li	s1,-1
    800022a4:	bfcd                	j	80002296 <sys_sbrk+0x26>

00000000800022a6 <sys_sleep>:

uint64
sys_sleep(void)
{
    800022a6:	7139                	addi	sp,sp,-64
    800022a8:	fc06                	sd	ra,56(sp)
    800022aa:	f822                	sd	s0,48(sp)
    800022ac:	f426                	sd	s1,40(sp)
    800022ae:	f04a                	sd	s2,32(sp)
    800022b0:	ec4e                	sd	s3,24(sp)
    800022b2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;


  argint(0, &n);
    800022b4:	fcc40593          	addi	a1,s0,-52
    800022b8:	4501                	li	a0,0
    800022ba:	e79ff0ef          	jal	ra,80002132 <argint>
  if(n < 0)
    800022be:	fcc42783          	lw	a5,-52(s0)
    800022c2:	0607c563          	bltz	a5,8000232c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800022c6:	0000b517          	auipc	a0,0xb
    800022ca:	60250513          	addi	a0,a0,1538 # 8000d8c8 <tickslock>
    800022ce:	0c1030ef          	jal	ra,80005b8e <acquire>
  ticks0 = ticks;
    800022d2:	00005917          	auipc	s2,0x5
    800022d6:	78692903          	lw	s2,1926(s2) # 80007a58 <ticks>
  while(ticks - ticks0 < n){
    800022da:	fcc42783          	lw	a5,-52(s0)
    800022de:	cb8d                	beqz	a5,80002310 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800022e0:	0000b997          	auipc	s3,0xb
    800022e4:	5e898993          	addi	s3,s3,1512 # 8000d8c8 <tickslock>
    800022e8:	00005497          	auipc	s1,0x5
    800022ec:	77048493          	addi	s1,s1,1904 # 80007a58 <ticks>
    if(killed(myproc())){
    800022f0:	ef5fe0ef          	jal	ra,800011e4 <myproc>
    800022f4:	f96ff0ef          	jal	ra,80001a8a <killed>
    800022f8:	ed0d                	bnez	a0,80002332 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800022fa:	85ce                	mv	a1,s3
    800022fc:	8526                	mv	a0,s1
    800022fe:	d54ff0ef          	jal	ra,80001852 <sleep>
  while(ticks - ticks0 < n){
    80002302:	409c                	lw	a5,0(s1)
    80002304:	412787bb          	subw	a5,a5,s2
    80002308:	fcc42703          	lw	a4,-52(s0)
    8000230c:	fee7e2e3          	bltu	a5,a4,800022f0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002310:	0000b517          	auipc	a0,0xb
    80002314:	5b850513          	addi	a0,a0,1464 # 8000d8c8 <tickslock>
    80002318:	10f030ef          	jal	ra,80005c26 <release>
  return 0;
    8000231c:	4501                	li	a0,0
}
    8000231e:	70e2                	ld	ra,56(sp)
    80002320:	7442                	ld	s0,48(sp)
    80002322:	74a2                	ld	s1,40(sp)
    80002324:	7902                	ld	s2,32(sp)
    80002326:	69e2                	ld	s3,24(sp)
    80002328:	6121                	addi	sp,sp,64
    8000232a:	8082                	ret
    n = 0;
    8000232c:	fc042623          	sw	zero,-52(s0)
    80002330:	bf59                	j	800022c6 <sys_sleep+0x20>
      release(&tickslock);
    80002332:	0000b517          	auipc	a0,0xb
    80002336:	59650513          	addi	a0,a0,1430 # 8000d8c8 <tickslock>
    8000233a:	0ed030ef          	jal	ra,80005c26 <release>
      return -1;
    8000233e:	557d                	li	a0,-1
    80002340:	bff9                	j	8000231e <sys_sleep+0x78>

0000000080002342 <sys_pgpte>:


#ifdef LAB_PGTBL
int
sys_pgpte(void)
{
    80002342:	7179                	addi	sp,sp,-48
    80002344:	f406                	sd	ra,40(sp)
    80002346:	f022                	sd	s0,32(sp)
    80002348:	ec26                	sd	s1,24(sp)
    8000234a:	1800                	addi	s0,sp,48
  uint64 va;
  struct proc *p;  

  p = myproc();
    8000234c:	e99fe0ef          	jal	ra,800011e4 <myproc>
    80002350:	84aa                	mv	s1,a0
  argaddr(0, &va);
    80002352:	fd840593          	addi	a1,s0,-40
    80002356:	4501                	li	a0,0
    80002358:	df7ff0ef          	jal	ra,8000214e <argaddr>
  pte_t *pte = pgpte(p->pagetable, va);
    8000235c:	fd843583          	ld	a1,-40(s0)
    80002360:	68a8                	ld	a0,80(s1)
    80002362:	d13fe0ef          	jal	ra,80001074 <pgpte>
    80002366:	87aa                	mv	a5,a0
  if(pte != 0) {
      return (uint64) *pte;
  }
  return 0;
    80002368:	4501                	li	a0,0
  if(pte != 0) {
    8000236a:	c391                	beqz	a5,8000236e <sys_pgpte+0x2c>
      return (uint64) *pte;
    8000236c:	4388                	lw	a0,0(a5)
}
    8000236e:	70a2                	ld	ra,40(sp)
    80002370:	7402                	ld	s0,32(sp)
    80002372:	64e2                	ld	s1,24(sp)
    80002374:	6145                	addi	sp,sp,48
    80002376:	8082                	ret

0000000080002378 <sys_kpgtbl>:
#endif

#ifdef LAB_PGTBL
int
sys_kpgtbl(void)
{
    80002378:	1141                	addi	sp,sp,-16
    8000237a:	e406                	sd	ra,8(sp)
    8000237c:	e022                	sd	s0,0(sp)
    8000237e:	0800                	addi	s0,sp,16
  struct proc *p;  

  p = myproc();
    80002380:	e65fe0ef          	jal	ra,800011e4 <myproc>
  vmprint(p->pagetable);
    80002384:	6928                	ld	a0,80(a0)
    80002386:	cc3fe0ef          	jal	ra,80001048 <vmprint>
  return 0;
}
    8000238a:	4501                	li	a0,0
    8000238c:	60a2                	ld	ra,8(sp)
    8000238e:	6402                	ld	s0,0(sp)
    80002390:	0141                	addi	sp,sp,16
    80002392:	8082                	ret

0000000080002394 <sys_kill>:
#endif


uint64
sys_kill(void)
{
    80002394:	1101                	addi	sp,sp,-32
    80002396:	ec06                	sd	ra,24(sp)
    80002398:	e822                	sd	s0,16(sp)
    8000239a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000239c:	fec40593          	addi	a1,s0,-20
    800023a0:	4501                	li	a0,0
    800023a2:	d91ff0ef          	jal	ra,80002132 <argint>
  return kill(pid);
    800023a6:	fec42503          	lw	a0,-20(s0)
    800023aa:	e56ff0ef          	jal	ra,80001a00 <kill>
}
    800023ae:	60e2                	ld	ra,24(sp)
    800023b0:	6442                	ld	s0,16(sp)
    800023b2:	6105                	addi	sp,sp,32
    800023b4:	8082                	ret

00000000800023b6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800023b6:	1101                	addi	sp,sp,-32
    800023b8:	ec06                	sd	ra,24(sp)
    800023ba:	e822                	sd	s0,16(sp)
    800023bc:	e426                	sd	s1,8(sp)
    800023be:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800023c0:	0000b517          	auipc	a0,0xb
    800023c4:	50850513          	addi	a0,a0,1288 # 8000d8c8 <tickslock>
    800023c8:	7c6030ef          	jal	ra,80005b8e <acquire>
  xticks = ticks;
    800023cc:	00005497          	auipc	s1,0x5
    800023d0:	68c4a483          	lw	s1,1676(s1) # 80007a58 <ticks>
  release(&tickslock);
    800023d4:	0000b517          	auipc	a0,0xb
    800023d8:	4f450513          	addi	a0,a0,1268 # 8000d8c8 <tickslock>
    800023dc:	04b030ef          	jal	ra,80005c26 <release>
  return xticks;
}
    800023e0:	02049513          	slli	a0,s1,0x20
    800023e4:	9101                	srli	a0,a0,0x20
    800023e6:	60e2                	ld	ra,24(sp)
    800023e8:	6442                	ld	s0,16(sp)
    800023ea:	64a2                	ld	s1,8(sp)
    800023ec:	6105                	addi	sp,sp,32
    800023ee:	8082                	ret

00000000800023f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800023f0:	7179                	addi	sp,sp,-48
    800023f2:	f406                	sd	ra,40(sp)
    800023f4:	f022                	sd	s0,32(sp)
    800023f6:	ec26                	sd	s1,24(sp)
    800023f8:	e84a                	sd	s2,16(sp)
    800023fa:	e44e                	sd	s3,8(sp)
    800023fc:	e052                	sd	s4,0(sp)
    800023fe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002400:	00005597          	auipc	a1,0x5
    80002404:	23858593          	addi	a1,a1,568 # 80007638 <syscalls+0x118>
    80002408:	0000b517          	auipc	a0,0xb
    8000240c:	4d850513          	addi	a0,a0,1240 # 8000d8e0 <bcache>
    80002410:	6fe030ef          	jal	ra,80005b0e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002414:	00013797          	auipc	a5,0x13
    80002418:	4cc78793          	addi	a5,a5,1228 # 800158e0 <bcache+0x8000>
    8000241c:	00013717          	auipc	a4,0x13
    80002420:	72c70713          	addi	a4,a4,1836 # 80015b48 <bcache+0x8268>
    80002424:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002428:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000242c:	0000b497          	auipc	s1,0xb
    80002430:	4cc48493          	addi	s1,s1,1228 # 8000d8f8 <bcache+0x18>
    b->next = bcache.head.next;
    80002434:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002436:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002438:	00005a17          	auipc	s4,0x5
    8000243c:	208a0a13          	addi	s4,s4,520 # 80007640 <syscalls+0x120>
    b->next = bcache.head.next;
    80002440:	2b893783          	ld	a5,696(s2)
    80002444:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002446:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000244a:	85d2                	mv	a1,s4
    8000244c:	01048513          	addi	a0,s1,16
    80002450:	224010ef          	jal	ra,80003674 <initsleeplock>
    bcache.head.next->prev = b;
    80002454:	2b893783          	ld	a5,696(s2)
    80002458:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000245a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000245e:	45848493          	addi	s1,s1,1112
    80002462:	fd349fe3          	bne	s1,s3,80002440 <binit+0x50>
  }
}
    80002466:	70a2                	ld	ra,40(sp)
    80002468:	7402                	ld	s0,32(sp)
    8000246a:	64e2                	ld	s1,24(sp)
    8000246c:	6942                	ld	s2,16(sp)
    8000246e:	69a2                	ld	s3,8(sp)
    80002470:	6a02                	ld	s4,0(sp)
    80002472:	6145                	addi	sp,sp,48
    80002474:	8082                	ret

0000000080002476 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	1800                	addi	s0,sp,48
    80002484:	89aa                	mv	s3,a0
    80002486:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002488:	0000b517          	auipc	a0,0xb
    8000248c:	45850513          	addi	a0,a0,1112 # 8000d8e0 <bcache>
    80002490:	6fe030ef          	jal	ra,80005b8e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002494:	00013497          	auipc	s1,0x13
    80002498:	7044b483          	ld	s1,1796(s1) # 80015b98 <bcache+0x82b8>
    8000249c:	00013797          	auipc	a5,0x13
    800024a0:	6ac78793          	addi	a5,a5,1708 # 80015b48 <bcache+0x8268>
    800024a4:	02f48b63          	beq	s1,a5,800024da <bread+0x64>
    800024a8:	873e                	mv	a4,a5
    800024aa:	a021                	j	800024b2 <bread+0x3c>
    800024ac:	68a4                	ld	s1,80(s1)
    800024ae:	02e48663          	beq	s1,a4,800024da <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800024b2:	449c                	lw	a5,8(s1)
    800024b4:	ff379ce3          	bne	a5,s3,800024ac <bread+0x36>
    800024b8:	44dc                	lw	a5,12(s1)
    800024ba:	ff2799e3          	bne	a5,s2,800024ac <bread+0x36>
      b->refcnt++;
    800024be:	40bc                	lw	a5,64(s1)
    800024c0:	2785                	addiw	a5,a5,1
    800024c2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800024c4:	0000b517          	auipc	a0,0xb
    800024c8:	41c50513          	addi	a0,a0,1052 # 8000d8e0 <bcache>
    800024cc:	75a030ef          	jal	ra,80005c26 <release>
      acquiresleep(&b->lock);
    800024d0:	01048513          	addi	a0,s1,16
    800024d4:	1d6010ef          	jal	ra,800036aa <acquiresleep>
      return b;
    800024d8:	a889                	j	8000252a <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800024da:	00013497          	auipc	s1,0x13
    800024de:	6b64b483          	ld	s1,1718(s1) # 80015b90 <bcache+0x82b0>
    800024e2:	00013797          	auipc	a5,0x13
    800024e6:	66678793          	addi	a5,a5,1638 # 80015b48 <bcache+0x8268>
    800024ea:	00f48863          	beq	s1,a5,800024fa <bread+0x84>
    800024ee:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800024f0:	40bc                	lw	a5,64(s1)
    800024f2:	cb91                	beqz	a5,80002506 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800024f4:	64a4                	ld	s1,72(s1)
    800024f6:	fee49de3          	bne	s1,a4,800024f0 <bread+0x7a>
  panic("bget: no buffers");
    800024fa:	00005517          	auipc	a0,0x5
    800024fe:	14e50513          	addi	a0,a0,334 # 80007648 <syscalls+0x128>
    80002502:	370030ef          	jal	ra,80005872 <panic>
      b->dev = dev;
    80002506:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000250a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000250e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002512:	4785                	li	a5,1
    80002514:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002516:	0000b517          	auipc	a0,0xb
    8000251a:	3ca50513          	addi	a0,a0,970 # 8000d8e0 <bcache>
    8000251e:	708030ef          	jal	ra,80005c26 <release>
      acquiresleep(&b->lock);
    80002522:	01048513          	addi	a0,s1,16
    80002526:	184010ef          	jal	ra,800036aa <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000252a:	409c                	lw	a5,0(s1)
    8000252c:	cb89                	beqz	a5,8000253e <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000252e:	8526                	mv	a0,s1
    80002530:	70a2                	ld	ra,40(sp)
    80002532:	7402                	ld	s0,32(sp)
    80002534:	64e2                	ld	s1,24(sp)
    80002536:	6942                	ld	s2,16(sp)
    80002538:	69a2                	ld	s3,8(sp)
    8000253a:	6145                	addi	sp,sp,48
    8000253c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000253e:	4581                	li	a1,0
    80002540:	8526                	mv	a0,s1
    80002542:	0df020ef          	jal	ra,80004e20 <virtio_disk_rw>
    b->valid = 1;
    80002546:	4785                	li	a5,1
    80002548:	c09c                	sw	a5,0(s1)
  return b;
    8000254a:	b7d5                	j	8000252e <bread+0xb8>

000000008000254c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000254c:	1101                	addi	sp,sp,-32
    8000254e:	ec06                	sd	ra,24(sp)
    80002550:	e822                	sd	s0,16(sp)
    80002552:	e426                	sd	s1,8(sp)
    80002554:	1000                	addi	s0,sp,32
    80002556:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002558:	0541                	addi	a0,a0,16
    8000255a:	1ce010ef          	jal	ra,80003728 <holdingsleep>
    8000255e:	c911                	beqz	a0,80002572 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002560:	4585                	li	a1,1
    80002562:	8526                	mv	a0,s1
    80002564:	0bd020ef          	jal	ra,80004e20 <virtio_disk_rw>
}
    80002568:	60e2                	ld	ra,24(sp)
    8000256a:	6442                	ld	s0,16(sp)
    8000256c:	64a2                	ld	s1,8(sp)
    8000256e:	6105                	addi	sp,sp,32
    80002570:	8082                	ret
    panic("bwrite");
    80002572:	00005517          	auipc	a0,0x5
    80002576:	0ee50513          	addi	a0,a0,238 # 80007660 <syscalls+0x140>
    8000257a:	2f8030ef          	jal	ra,80005872 <panic>

000000008000257e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000257e:	1101                	addi	sp,sp,-32
    80002580:	ec06                	sd	ra,24(sp)
    80002582:	e822                	sd	s0,16(sp)
    80002584:	e426                	sd	s1,8(sp)
    80002586:	e04a                	sd	s2,0(sp)
    80002588:	1000                	addi	s0,sp,32
    8000258a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000258c:	01050913          	addi	s2,a0,16
    80002590:	854a                	mv	a0,s2
    80002592:	196010ef          	jal	ra,80003728 <holdingsleep>
    80002596:	c13d                	beqz	a0,800025fc <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002598:	854a                	mv	a0,s2
    8000259a:	156010ef          	jal	ra,800036f0 <releasesleep>

  acquire(&bcache.lock);
    8000259e:	0000b517          	auipc	a0,0xb
    800025a2:	34250513          	addi	a0,a0,834 # 8000d8e0 <bcache>
    800025a6:	5e8030ef          	jal	ra,80005b8e <acquire>
  b->refcnt--;
    800025aa:	40bc                	lw	a5,64(s1)
    800025ac:	37fd                	addiw	a5,a5,-1
    800025ae:	0007871b          	sext.w	a4,a5
    800025b2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800025b4:	eb05                	bnez	a4,800025e4 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800025b6:	68bc                	ld	a5,80(s1)
    800025b8:	64b8                	ld	a4,72(s1)
    800025ba:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800025bc:	64bc                	ld	a5,72(s1)
    800025be:	68b8                	ld	a4,80(s1)
    800025c0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800025c2:	00013797          	auipc	a5,0x13
    800025c6:	31e78793          	addi	a5,a5,798 # 800158e0 <bcache+0x8000>
    800025ca:	2b87b703          	ld	a4,696(a5)
    800025ce:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800025d0:	00013717          	auipc	a4,0x13
    800025d4:	57870713          	addi	a4,a4,1400 # 80015b48 <bcache+0x8268>
    800025d8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800025da:	2b87b703          	ld	a4,696(a5)
    800025de:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800025e0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800025e4:	0000b517          	auipc	a0,0xb
    800025e8:	2fc50513          	addi	a0,a0,764 # 8000d8e0 <bcache>
    800025ec:	63a030ef          	jal	ra,80005c26 <release>
}
    800025f0:	60e2                	ld	ra,24(sp)
    800025f2:	6442                	ld	s0,16(sp)
    800025f4:	64a2                	ld	s1,8(sp)
    800025f6:	6902                	ld	s2,0(sp)
    800025f8:	6105                	addi	sp,sp,32
    800025fa:	8082                	ret
    panic("brelse");
    800025fc:	00005517          	auipc	a0,0x5
    80002600:	06c50513          	addi	a0,a0,108 # 80007668 <syscalls+0x148>
    80002604:	26e030ef          	jal	ra,80005872 <panic>

0000000080002608 <bpin>:

void
bpin(struct buf *b) {
    80002608:	1101                	addi	sp,sp,-32
    8000260a:	ec06                	sd	ra,24(sp)
    8000260c:	e822                	sd	s0,16(sp)
    8000260e:	e426                	sd	s1,8(sp)
    80002610:	1000                	addi	s0,sp,32
    80002612:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002614:	0000b517          	auipc	a0,0xb
    80002618:	2cc50513          	addi	a0,a0,716 # 8000d8e0 <bcache>
    8000261c:	572030ef          	jal	ra,80005b8e <acquire>
  b->refcnt++;
    80002620:	40bc                	lw	a5,64(s1)
    80002622:	2785                	addiw	a5,a5,1
    80002624:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002626:	0000b517          	auipc	a0,0xb
    8000262a:	2ba50513          	addi	a0,a0,698 # 8000d8e0 <bcache>
    8000262e:	5f8030ef          	jal	ra,80005c26 <release>
}
    80002632:	60e2                	ld	ra,24(sp)
    80002634:	6442                	ld	s0,16(sp)
    80002636:	64a2                	ld	s1,8(sp)
    80002638:	6105                	addi	sp,sp,32
    8000263a:	8082                	ret

000000008000263c <bunpin>:

void
bunpin(struct buf *b) {
    8000263c:	1101                	addi	sp,sp,-32
    8000263e:	ec06                	sd	ra,24(sp)
    80002640:	e822                	sd	s0,16(sp)
    80002642:	e426                	sd	s1,8(sp)
    80002644:	1000                	addi	s0,sp,32
    80002646:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002648:	0000b517          	auipc	a0,0xb
    8000264c:	29850513          	addi	a0,a0,664 # 8000d8e0 <bcache>
    80002650:	53e030ef          	jal	ra,80005b8e <acquire>
  b->refcnt--;
    80002654:	40bc                	lw	a5,64(s1)
    80002656:	37fd                	addiw	a5,a5,-1
    80002658:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000265a:	0000b517          	auipc	a0,0xb
    8000265e:	28650513          	addi	a0,a0,646 # 8000d8e0 <bcache>
    80002662:	5c4030ef          	jal	ra,80005c26 <release>
}
    80002666:	60e2                	ld	ra,24(sp)
    80002668:	6442                	ld	s0,16(sp)
    8000266a:	64a2                	ld	s1,8(sp)
    8000266c:	6105                	addi	sp,sp,32
    8000266e:	8082                	ret

0000000080002670 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002670:	1101                	addi	sp,sp,-32
    80002672:	ec06                	sd	ra,24(sp)
    80002674:	e822                	sd	s0,16(sp)
    80002676:	e426                	sd	s1,8(sp)
    80002678:	e04a                	sd	s2,0(sp)
    8000267a:	1000                	addi	s0,sp,32
    8000267c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000267e:	00d5d59b          	srliw	a1,a1,0xd
    80002682:	00014797          	auipc	a5,0x14
    80002686:	93a7a783          	lw	a5,-1734(a5) # 80015fbc <sb+0x1c>
    8000268a:	9dbd                	addw	a1,a1,a5
    8000268c:	debff0ef          	jal	ra,80002476 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002690:	0074f713          	andi	a4,s1,7
    80002694:	4785                	li	a5,1
    80002696:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000269a:	14ce                	slli	s1,s1,0x33
    8000269c:	90d9                	srli	s1,s1,0x36
    8000269e:	00950733          	add	a4,a0,s1
    800026a2:	05874703          	lbu	a4,88(a4)
    800026a6:	00e7f6b3          	and	a3,a5,a4
    800026aa:	c29d                	beqz	a3,800026d0 <bfree+0x60>
    800026ac:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800026ae:	94aa                	add	s1,s1,a0
    800026b0:	fff7c793          	not	a5,a5
    800026b4:	8ff9                	and	a5,a5,a4
    800026b6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800026ba:	6e9000ef          	jal	ra,800035a2 <log_write>
  brelse(bp);
    800026be:	854a                	mv	a0,s2
    800026c0:	ebfff0ef          	jal	ra,8000257e <brelse>
}
    800026c4:	60e2                	ld	ra,24(sp)
    800026c6:	6442                	ld	s0,16(sp)
    800026c8:	64a2                	ld	s1,8(sp)
    800026ca:	6902                	ld	s2,0(sp)
    800026cc:	6105                	addi	sp,sp,32
    800026ce:	8082                	ret
    panic("freeing free block");
    800026d0:	00005517          	auipc	a0,0x5
    800026d4:	fa050513          	addi	a0,a0,-96 # 80007670 <syscalls+0x150>
    800026d8:	19a030ef          	jal	ra,80005872 <panic>

00000000800026dc <balloc>:
{
    800026dc:	711d                	addi	sp,sp,-96
    800026de:	ec86                	sd	ra,88(sp)
    800026e0:	e8a2                	sd	s0,80(sp)
    800026e2:	e4a6                	sd	s1,72(sp)
    800026e4:	e0ca                	sd	s2,64(sp)
    800026e6:	fc4e                	sd	s3,56(sp)
    800026e8:	f852                	sd	s4,48(sp)
    800026ea:	f456                	sd	s5,40(sp)
    800026ec:	f05a                	sd	s6,32(sp)
    800026ee:	ec5e                	sd	s7,24(sp)
    800026f0:	e862                	sd	s8,16(sp)
    800026f2:	e466                	sd	s9,8(sp)
    800026f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800026f6:	00014797          	auipc	a5,0x14
    800026fa:	8ae7a783          	lw	a5,-1874(a5) # 80015fa4 <sb+0x4>
    800026fe:	0e078163          	beqz	a5,800027e0 <balloc+0x104>
    80002702:	8baa                	mv	s7,a0
    80002704:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002706:	00014b17          	auipc	s6,0x14
    8000270a:	89ab0b13          	addi	s6,s6,-1894 # 80015fa0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000270e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002710:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002712:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002714:	6c89                	lui	s9,0x2
    80002716:	a0b5                	j	80002782 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002718:	974a                	add	a4,a4,s2
    8000271a:	8fd5                	or	a5,a5,a3
    8000271c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002720:	854a                	mv	a0,s2
    80002722:	681000ef          	jal	ra,800035a2 <log_write>
        brelse(bp);
    80002726:	854a                	mv	a0,s2
    80002728:	e57ff0ef          	jal	ra,8000257e <brelse>
  bp = bread(dev, bno);
    8000272c:	85a6                	mv	a1,s1
    8000272e:	855e                	mv	a0,s7
    80002730:	d47ff0ef          	jal	ra,80002476 <bread>
    80002734:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002736:	40000613          	li	a2,1024
    8000273a:	4581                	li	a1,0
    8000273c:	05850513          	addi	a0,a0,88
    80002740:	afbfd0ef          	jal	ra,8000023a <memset>
  log_write(bp);
    80002744:	854a                	mv	a0,s2
    80002746:	65d000ef          	jal	ra,800035a2 <log_write>
  brelse(bp);
    8000274a:	854a                	mv	a0,s2
    8000274c:	e33ff0ef          	jal	ra,8000257e <brelse>
}
    80002750:	8526                	mv	a0,s1
    80002752:	60e6                	ld	ra,88(sp)
    80002754:	6446                	ld	s0,80(sp)
    80002756:	64a6                	ld	s1,72(sp)
    80002758:	6906                	ld	s2,64(sp)
    8000275a:	79e2                	ld	s3,56(sp)
    8000275c:	7a42                	ld	s4,48(sp)
    8000275e:	7aa2                	ld	s5,40(sp)
    80002760:	7b02                	ld	s6,32(sp)
    80002762:	6be2                	ld	s7,24(sp)
    80002764:	6c42                	ld	s8,16(sp)
    80002766:	6ca2                	ld	s9,8(sp)
    80002768:	6125                	addi	sp,sp,96
    8000276a:	8082                	ret
    brelse(bp);
    8000276c:	854a                	mv	a0,s2
    8000276e:	e11ff0ef          	jal	ra,8000257e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002772:	015c87bb          	addw	a5,s9,s5
    80002776:	00078a9b          	sext.w	s5,a5
    8000277a:	004b2703          	lw	a4,4(s6)
    8000277e:	06eaf163          	bgeu	s5,a4,800027e0 <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002782:	41fad79b          	sraiw	a5,s5,0x1f
    80002786:	0137d79b          	srliw	a5,a5,0x13
    8000278a:	015787bb          	addw	a5,a5,s5
    8000278e:	40d7d79b          	sraiw	a5,a5,0xd
    80002792:	01cb2583          	lw	a1,28(s6)
    80002796:	9dbd                	addw	a1,a1,a5
    80002798:	855e                	mv	a0,s7
    8000279a:	cddff0ef          	jal	ra,80002476 <bread>
    8000279e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027a0:	004b2503          	lw	a0,4(s6)
    800027a4:	000a849b          	sext.w	s1,s5
    800027a8:	8662                	mv	a2,s8
    800027aa:	fca4f1e3          	bgeu	s1,a0,8000276c <balloc+0x90>
      m = 1 << (bi % 8);
    800027ae:	41f6579b          	sraiw	a5,a2,0x1f
    800027b2:	01d7d69b          	srliw	a3,a5,0x1d
    800027b6:	00c6873b          	addw	a4,a3,a2
    800027ba:	00777793          	andi	a5,a4,7
    800027be:	9f95                	subw	a5,a5,a3
    800027c0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800027c4:	4037571b          	sraiw	a4,a4,0x3
    800027c8:	00e906b3          	add	a3,s2,a4
    800027cc:	0586c683          	lbu	a3,88(a3)
    800027d0:	00d7f5b3          	and	a1,a5,a3
    800027d4:	d1b1                	beqz	a1,80002718 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027d6:	2605                	addiw	a2,a2,1
    800027d8:	2485                	addiw	s1,s1,1
    800027da:	fd4618e3          	bne	a2,s4,800027aa <balloc+0xce>
    800027de:	b779                	j	8000276c <balloc+0x90>
  printf("balloc: out of blocks\n");
    800027e0:	00005517          	auipc	a0,0x5
    800027e4:	ea850513          	addi	a0,a0,-344 # 80007688 <syscalls+0x168>
    800027e8:	5d7020ef          	jal	ra,800055be <printf>
  return 0;
    800027ec:	4481                	li	s1,0
    800027ee:	b78d                	j	80002750 <balloc+0x74>

00000000800027f0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800027f0:	7179                	addi	sp,sp,-48
    800027f2:	f406                	sd	ra,40(sp)
    800027f4:	f022                	sd	s0,32(sp)
    800027f6:	ec26                	sd	s1,24(sp)
    800027f8:	e84a                	sd	s2,16(sp)
    800027fa:	e44e                	sd	s3,8(sp)
    800027fc:	e052                	sd	s4,0(sp)
    800027fe:	1800                	addi	s0,sp,48
    80002800:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002802:	47ad                	li	a5,11
    80002804:	02b7e563          	bltu	a5,a1,8000282e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002808:	02059493          	slli	s1,a1,0x20
    8000280c:	9081                	srli	s1,s1,0x20
    8000280e:	048a                	slli	s1,s1,0x2
    80002810:	94aa                	add	s1,s1,a0
    80002812:	0504a903          	lw	s2,80(s1)
    80002816:	06091663          	bnez	s2,80002882 <bmap+0x92>
      addr = balloc(ip->dev);
    8000281a:	4108                	lw	a0,0(a0)
    8000281c:	ec1ff0ef          	jal	ra,800026dc <balloc>
    80002820:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002824:	04090f63          	beqz	s2,80002882 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002828:	0524a823          	sw	s2,80(s1)
    8000282c:	a899                	j	80002882 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000282e:	ff45849b          	addiw	s1,a1,-12
    80002832:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002836:	0ff00793          	li	a5,255
    8000283a:	06e7eb63          	bltu	a5,a4,800028b0 <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000283e:	08052903          	lw	s2,128(a0)
    80002842:	00091b63          	bnez	s2,80002858 <bmap+0x68>
      addr = balloc(ip->dev);
    80002846:	4108                	lw	a0,0(a0)
    80002848:	e95ff0ef          	jal	ra,800026dc <balloc>
    8000284c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002850:	02090963          	beqz	s2,80002882 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002854:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002858:	85ca                	mv	a1,s2
    8000285a:	0009a503          	lw	a0,0(s3)
    8000285e:	c19ff0ef          	jal	ra,80002476 <bread>
    80002862:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002864:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002868:	02049593          	slli	a1,s1,0x20
    8000286c:	9181                	srli	a1,a1,0x20
    8000286e:	058a                	slli	a1,a1,0x2
    80002870:	00b784b3          	add	s1,a5,a1
    80002874:	0004a903          	lw	s2,0(s1)
    80002878:	00090e63          	beqz	s2,80002894 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000287c:	8552                	mv	a0,s4
    8000287e:	d01ff0ef          	jal	ra,8000257e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002882:	854a                	mv	a0,s2
    80002884:	70a2                	ld	ra,40(sp)
    80002886:	7402                	ld	s0,32(sp)
    80002888:	64e2                	ld	s1,24(sp)
    8000288a:	6942                	ld	s2,16(sp)
    8000288c:	69a2                	ld	s3,8(sp)
    8000288e:	6a02                	ld	s4,0(sp)
    80002890:	6145                	addi	sp,sp,48
    80002892:	8082                	ret
      addr = balloc(ip->dev);
    80002894:	0009a503          	lw	a0,0(s3)
    80002898:	e45ff0ef          	jal	ra,800026dc <balloc>
    8000289c:	0005091b          	sext.w	s2,a0
      if(addr){
    800028a0:	fc090ee3          	beqz	s2,8000287c <bmap+0x8c>
        a[bn] = addr;
    800028a4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800028a8:	8552                	mv	a0,s4
    800028aa:	4f9000ef          	jal	ra,800035a2 <log_write>
    800028ae:	b7f9                	j	8000287c <bmap+0x8c>
  panic("bmap: out of range");
    800028b0:	00005517          	auipc	a0,0x5
    800028b4:	df050513          	addi	a0,a0,-528 # 800076a0 <syscalls+0x180>
    800028b8:	7bb020ef          	jal	ra,80005872 <panic>

00000000800028bc <iget>:
{
    800028bc:	7179                	addi	sp,sp,-48
    800028be:	f406                	sd	ra,40(sp)
    800028c0:	f022                	sd	s0,32(sp)
    800028c2:	ec26                	sd	s1,24(sp)
    800028c4:	e84a                	sd	s2,16(sp)
    800028c6:	e44e                	sd	s3,8(sp)
    800028c8:	e052                	sd	s4,0(sp)
    800028ca:	1800                	addi	s0,sp,48
    800028cc:	89aa                	mv	s3,a0
    800028ce:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800028d0:	00013517          	auipc	a0,0x13
    800028d4:	6f050513          	addi	a0,a0,1776 # 80015fc0 <itable>
    800028d8:	2b6030ef          	jal	ra,80005b8e <acquire>
  empty = 0;
    800028dc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028de:	00013497          	auipc	s1,0x13
    800028e2:	6fa48493          	addi	s1,s1,1786 # 80015fd8 <itable+0x18>
    800028e6:	00015697          	auipc	a3,0x15
    800028ea:	18268693          	addi	a3,a3,386 # 80017a68 <log>
    800028ee:	a039                	j	800028fc <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028f0:	02090963          	beqz	s2,80002922 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800028f4:	08848493          	addi	s1,s1,136
    800028f8:	02d48863          	beq	s1,a3,80002928 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800028fc:	449c                	lw	a5,8(s1)
    800028fe:	fef059e3          	blez	a5,800028f0 <iget+0x34>
    80002902:	4098                	lw	a4,0(s1)
    80002904:	ff3716e3          	bne	a4,s3,800028f0 <iget+0x34>
    80002908:	40d8                	lw	a4,4(s1)
    8000290a:	ff4713e3          	bne	a4,s4,800028f0 <iget+0x34>
      ip->ref++;
    8000290e:	2785                	addiw	a5,a5,1
    80002910:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002912:	00013517          	auipc	a0,0x13
    80002916:	6ae50513          	addi	a0,a0,1710 # 80015fc0 <itable>
    8000291a:	30c030ef          	jal	ra,80005c26 <release>
      return ip;
    8000291e:	8926                	mv	s2,s1
    80002920:	a02d                	j	8000294a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002922:	fbe9                	bnez	a5,800028f4 <iget+0x38>
    80002924:	8926                	mv	s2,s1
    80002926:	b7f9                	j	800028f4 <iget+0x38>
  if(empty == 0)
    80002928:	02090a63          	beqz	s2,8000295c <iget+0xa0>
  ip->dev = dev;
    8000292c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002930:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002934:	4785                	li	a5,1
    80002936:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000293a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000293e:	00013517          	auipc	a0,0x13
    80002942:	68250513          	addi	a0,a0,1666 # 80015fc0 <itable>
    80002946:	2e0030ef          	jal	ra,80005c26 <release>
}
    8000294a:	854a                	mv	a0,s2
    8000294c:	70a2                	ld	ra,40(sp)
    8000294e:	7402                	ld	s0,32(sp)
    80002950:	64e2                	ld	s1,24(sp)
    80002952:	6942                	ld	s2,16(sp)
    80002954:	69a2                	ld	s3,8(sp)
    80002956:	6a02                	ld	s4,0(sp)
    80002958:	6145                	addi	sp,sp,48
    8000295a:	8082                	ret
    panic("iget: no inodes");
    8000295c:	00005517          	auipc	a0,0x5
    80002960:	d5c50513          	addi	a0,a0,-676 # 800076b8 <syscalls+0x198>
    80002964:	70f020ef          	jal	ra,80005872 <panic>

0000000080002968 <fsinit>:
fsinit(int dev) {
    80002968:	7179                	addi	sp,sp,-48
    8000296a:	f406                	sd	ra,40(sp)
    8000296c:	f022                	sd	s0,32(sp)
    8000296e:	ec26                	sd	s1,24(sp)
    80002970:	e84a                	sd	s2,16(sp)
    80002972:	e44e                	sd	s3,8(sp)
    80002974:	1800                	addi	s0,sp,48
    80002976:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002978:	4585                	li	a1,1
    8000297a:	afdff0ef          	jal	ra,80002476 <bread>
    8000297e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002980:	00013997          	auipc	s3,0x13
    80002984:	62098993          	addi	s3,s3,1568 # 80015fa0 <sb>
    80002988:	02000613          	li	a2,32
    8000298c:	05850593          	addi	a1,a0,88
    80002990:	854e                	mv	a0,s3
    80002992:	909fd0ef          	jal	ra,8000029a <memmove>
  brelse(bp);
    80002996:	8526                	mv	a0,s1
    80002998:	be7ff0ef          	jal	ra,8000257e <brelse>
  if(sb.magic != FSMAGIC)
    8000299c:	0009a703          	lw	a4,0(s3)
    800029a0:	102037b7          	lui	a5,0x10203
    800029a4:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800029a8:	02f71063          	bne	a4,a5,800029c8 <fsinit+0x60>
  initlog(dev, &sb);
    800029ac:	00013597          	auipc	a1,0x13
    800029b0:	5f458593          	addi	a1,a1,1524 # 80015fa0 <sb>
    800029b4:	854a                	mv	a0,s2
    800029b6:	1d9000ef          	jal	ra,8000338e <initlog>
}
    800029ba:	70a2                	ld	ra,40(sp)
    800029bc:	7402                	ld	s0,32(sp)
    800029be:	64e2                	ld	s1,24(sp)
    800029c0:	6942                	ld	s2,16(sp)
    800029c2:	69a2                	ld	s3,8(sp)
    800029c4:	6145                	addi	sp,sp,48
    800029c6:	8082                	ret
    panic("invalid file system");
    800029c8:	00005517          	auipc	a0,0x5
    800029cc:	d0050513          	addi	a0,a0,-768 # 800076c8 <syscalls+0x1a8>
    800029d0:	6a3020ef          	jal	ra,80005872 <panic>

00000000800029d4 <iinit>:
{
    800029d4:	7179                	addi	sp,sp,-48
    800029d6:	f406                	sd	ra,40(sp)
    800029d8:	f022                	sd	s0,32(sp)
    800029da:	ec26                	sd	s1,24(sp)
    800029dc:	e84a                	sd	s2,16(sp)
    800029de:	e44e                	sd	s3,8(sp)
    800029e0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800029e2:	00005597          	auipc	a1,0x5
    800029e6:	cfe58593          	addi	a1,a1,-770 # 800076e0 <syscalls+0x1c0>
    800029ea:	00013517          	auipc	a0,0x13
    800029ee:	5d650513          	addi	a0,a0,1494 # 80015fc0 <itable>
    800029f2:	11c030ef          	jal	ra,80005b0e <initlock>
  for(i = 0; i < NINODE; i++) {
    800029f6:	00013497          	auipc	s1,0x13
    800029fa:	5f248493          	addi	s1,s1,1522 # 80015fe8 <itable+0x28>
    800029fe:	00015997          	auipc	s3,0x15
    80002a02:	07a98993          	addi	s3,s3,122 # 80017a78 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002a06:	00005917          	auipc	s2,0x5
    80002a0a:	ce290913          	addi	s2,s2,-798 # 800076e8 <syscalls+0x1c8>
    80002a0e:	85ca                	mv	a1,s2
    80002a10:	8526                	mv	a0,s1
    80002a12:	463000ef          	jal	ra,80003674 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a16:	08848493          	addi	s1,s1,136
    80002a1a:	ff349ae3          	bne	s1,s3,80002a0e <iinit+0x3a>
}
    80002a1e:	70a2                	ld	ra,40(sp)
    80002a20:	7402                	ld	s0,32(sp)
    80002a22:	64e2                	ld	s1,24(sp)
    80002a24:	6942                	ld	s2,16(sp)
    80002a26:	69a2                	ld	s3,8(sp)
    80002a28:	6145                	addi	sp,sp,48
    80002a2a:	8082                	ret

0000000080002a2c <ialloc>:
{
    80002a2c:	715d                	addi	sp,sp,-80
    80002a2e:	e486                	sd	ra,72(sp)
    80002a30:	e0a2                	sd	s0,64(sp)
    80002a32:	fc26                	sd	s1,56(sp)
    80002a34:	f84a                	sd	s2,48(sp)
    80002a36:	f44e                	sd	s3,40(sp)
    80002a38:	f052                	sd	s4,32(sp)
    80002a3a:	ec56                	sd	s5,24(sp)
    80002a3c:	e85a                	sd	s6,16(sp)
    80002a3e:	e45e                	sd	s7,8(sp)
    80002a40:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a42:	00013717          	auipc	a4,0x13
    80002a46:	56a72703          	lw	a4,1386(a4) # 80015fac <sb+0xc>
    80002a4a:	4785                	li	a5,1
    80002a4c:	04e7f663          	bgeu	a5,a4,80002a98 <ialloc+0x6c>
    80002a50:	8aaa                	mv	s5,a0
    80002a52:	8bae                	mv	s7,a1
    80002a54:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002a56:	00013a17          	auipc	s4,0x13
    80002a5a:	54aa0a13          	addi	s4,s4,1354 # 80015fa0 <sb>
    80002a5e:	00048b1b          	sext.w	s6,s1
    80002a62:	0044d593          	srli	a1,s1,0x4
    80002a66:	018a2783          	lw	a5,24(s4)
    80002a6a:	9dbd                	addw	a1,a1,a5
    80002a6c:	8556                	mv	a0,s5
    80002a6e:	a09ff0ef          	jal	ra,80002476 <bread>
    80002a72:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002a74:	05850993          	addi	s3,a0,88
    80002a78:	00f4f793          	andi	a5,s1,15
    80002a7c:	079a                	slli	a5,a5,0x6
    80002a7e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002a80:	00099783          	lh	a5,0(s3)
    80002a84:	cf85                	beqz	a5,80002abc <ialloc+0x90>
    brelse(bp);
    80002a86:	af9ff0ef          	jal	ra,8000257e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a8a:	0485                	addi	s1,s1,1
    80002a8c:	00ca2703          	lw	a4,12(s4)
    80002a90:	0004879b          	sext.w	a5,s1
    80002a94:	fce7e5e3          	bltu	a5,a4,80002a5e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002a98:	00005517          	auipc	a0,0x5
    80002a9c:	c5850513          	addi	a0,a0,-936 # 800076f0 <syscalls+0x1d0>
    80002aa0:	31f020ef          	jal	ra,800055be <printf>
  return 0;
    80002aa4:	4501                	li	a0,0
}
    80002aa6:	60a6                	ld	ra,72(sp)
    80002aa8:	6406                	ld	s0,64(sp)
    80002aaa:	74e2                	ld	s1,56(sp)
    80002aac:	7942                	ld	s2,48(sp)
    80002aae:	79a2                	ld	s3,40(sp)
    80002ab0:	7a02                	ld	s4,32(sp)
    80002ab2:	6ae2                	ld	s5,24(sp)
    80002ab4:	6b42                	ld	s6,16(sp)
    80002ab6:	6ba2                	ld	s7,8(sp)
    80002ab8:	6161                	addi	sp,sp,80
    80002aba:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002abc:	04000613          	li	a2,64
    80002ac0:	4581                	li	a1,0
    80002ac2:	854e                	mv	a0,s3
    80002ac4:	f76fd0ef          	jal	ra,8000023a <memset>
      dip->type = type;
    80002ac8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002acc:	854a                	mv	a0,s2
    80002ace:	2d5000ef          	jal	ra,800035a2 <log_write>
      brelse(bp);
    80002ad2:	854a                	mv	a0,s2
    80002ad4:	aabff0ef          	jal	ra,8000257e <brelse>
      return iget(dev, inum);
    80002ad8:	85da                	mv	a1,s6
    80002ada:	8556                	mv	a0,s5
    80002adc:	de1ff0ef          	jal	ra,800028bc <iget>
    80002ae0:	b7d9                	j	80002aa6 <ialloc+0x7a>

0000000080002ae2 <iupdate>:
{
    80002ae2:	1101                	addi	sp,sp,-32
    80002ae4:	ec06                	sd	ra,24(sp)
    80002ae6:	e822                	sd	s0,16(sp)
    80002ae8:	e426                	sd	s1,8(sp)
    80002aea:	e04a                	sd	s2,0(sp)
    80002aec:	1000                	addi	s0,sp,32
    80002aee:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002af0:	415c                	lw	a5,4(a0)
    80002af2:	0047d79b          	srliw	a5,a5,0x4
    80002af6:	00013597          	auipc	a1,0x13
    80002afa:	4c25a583          	lw	a1,1218(a1) # 80015fb8 <sb+0x18>
    80002afe:	9dbd                	addw	a1,a1,a5
    80002b00:	4108                	lw	a0,0(a0)
    80002b02:	975ff0ef          	jal	ra,80002476 <bread>
    80002b06:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b08:	05850793          	addi	a5,a0,88
    80002b0c:	40c8                	lw	a0,4(s1)
    80002b0e:	893d                	andi	a0,a0,15
    80002b10:	051a                	slli	a0,a0,0x6
    80002b12:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002b14:	04449703          	lh	a4,68(s1)
    80002b18:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002b1c:	04649703          	lh	a4,70(s1)
    80002b20:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002b24:	04849703          	lh	a4,72(s1)
    80002b28:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002b2c:	04a49703          	lh	a4,74(s1)
    80002b30:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002b34:	44f8                	lw	a4,76(s1)
    80002b36:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002b38:	03400613          	li	a2,52
    80002b3c:	05048593          	addi	a1,s1,80
    80002b40:	0531                	addi	a0,a0,12
    80002b42:	f58fd0ef          	jal	ra,8000029a <memmove>
  log_write(bp);
    80002b46:	854a                	mv	a0,s2
    80002b48:	25b000ef          	jal	ra,800035a2 <log_write>
  brelse(bp);
    80002b4c:	854a                	mv	a0,s2
    80002b4e:	a31ff0ef          	jal	ra,8000257e <brelse>
}
    80002b52:	60e2                	ld	ra,24(sp)
    80002b54:	6442                	ld	s0,16(sp)
    80002b56:	64a2                	ld	s1,8(sp)
    80002b58:	6902                	ld	s2,0(sp)
    80002b5a:	6105                	addi	sp,sp,32
    80002b5c:	8082                	ret

0000000080002b5e <idup>:
{
    80002b5e:	1101                	addi	sp,sp,-32
    80002b60:	ec06                	sd	ra,24(sp)
    80002b62:	e822                	sd	s0,16(sp)
    80002b64:	e426                	sd	s1,8(sp)
    80002b66:	1000                	addi	s0,sp,32
    80002b68:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b6a:	00013517          	auipc	a0,0x13
    80002b6e:	45650513          	addi	a0,a0,1110 # 80015fc0 <itable>
    80002b72:	01c030ef          	jal	ra,80005b8e <acquire>
  ip->ref++;
    80002b76:	449c                	lw	a5,8(s1)
    80002b78:	2785                	addiw	a5,a5,1
    80002b7a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b7c:	00013517          	auipc	a0,0x13
    80002b80:	44450513          	addi	a0,a0,1092 # 80015fc0 <itable>
    80002b84:	0a2030ef          	jal	ra,80005c26 <release>
}
    80002b88:	8526                	mv	a0,s1
    80002b8a:	60e2                	ld	ra,24(sp)
    80002b8c:	6442                	ld	s0,16(sp)
    80002b8e:	64a2                	ld	s1,8(sp)
    80002b90:	6105                	addi	sp,sp,32
    80002b92:	8082                	ret

0000000080002b94 <ilock>:
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	e426                	sd	s1,8(sp)
    80002b9c:	e04a                	sd	s2,0(sp)
    80002b9e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002ba0:	c105                	beqz	a0,80002bc0 <ilock+0x2c>
    80002ba2:	84aa                	mv	s1,a0
    80002ba4:	451c                	lw	a5,8(a0)
    80002ba6:	00f05d63          	blez	a5,80002bc0 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80002baa:	0541                	addi	a0,a0,16
    80002bac:	2ff000ef          	jal	ra,800036aa <acquiresleep>
  if(ip->valid == 0){
    80002bb0:	40bc                	lw	a5,64(s1)
    80002bb2:	cf89                	beqz	a5,80002bcc <ilock+0x38>
}
    80002bb4:	60e2                	ld	ra,24(sp)
    80002bb6:	6442                	ld	s0,16(sp)
    80002bb8:	64a2                	ld	s1,8(sp)
    80002bba:	6902                	ld	s2,0(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret
    panic("ilock");
    80002bc0:	00005517          	auipc	a0,0x5
    80002bc4:	b4850513          	addi	a0,a0,-1208 # 80007708 <syscalls+0x1e8>
    80002bc8:	4ab020ef          	jal	ra,80005872 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002bcc:	40dc                	lw	a5,4(s1)
    80002bce:	0047d79b          	srliw	a5,a5,0x4
    80002bd2:	00013597          	auipc	a1,0x13
    80002bd6:	3e65a583          	lw	a1,998(a1) # 80015fb8 <sb+0x18>
    80002bda:	9dbd                	addw	a1,a1,a5
    80002bdc:	4088                	lw	a0,0(s1)
    80002bde:	899ff0ef          	jal	ra,80002476 <bread>
    80002be2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002be4:	05850593          	addi	a1,a0,88
    80002be8:	40dc                	lw	a5,4(s1)
    80002bea:	8bbd                	andi	a5,a5,15
    80002bec:	079a                	slli	a5,a5,0x6
    80002bee:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002bf0:	00059783          	lh	a5,0(a1)
    80002bf4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002bf8:	00259783          	lh	a5,2(a1)
    80002bfc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c00:	00459783          	lh	a5,4(a1)
    80002c04:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002c08:	00659783          	lh	a5,6(a1)
    80002c0c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002c10:	459c                	lw	a5,8(a1)
    80002c12:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002c14:	03400613          	li	a2,52
    80002c18:	05b1                	addi	a1,a1,12
    80002c1a:	05048513          	addi	a0,s1,80
    80002c1e:	e7cfd0ef          	jal	ra,8000029a <memmove>
    brelse(bp);
    80002c22:	854a                	mv	a0,s2
    80002c24:	95bff0ef          	jal	ra,8000257e <brelse>
    ip->valid = 1;
    80002c28:	4785                	li	a5,1
    80002c2a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002c2c:	04449783          	lh	a5,68(s1)
    80002c30:	f3d1                	bnez	a5,80002bb4 <ilock+0x20>
      panic("ilock: no type");
    80002c32:	00005517          	auipc	a0,0x5
    80002c36:	ade50513          	addi	a0,a0,-1314 # 80007710 <syscalls+0x1f0>
    80002c3a:	439020ef          	jal	ra,80005872 <panic>

0000000080002c3e <iunlock>:
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	e426                	sd	s1,8(sp)
    80002c46:	e04a                	sd	s2,0(sp)
    80002c48:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002c4a:	c505                	beqz	a0,80002c72 <iunlock+0x34>
    80002c4c:	84aa                	mv	s1,a0
    80002c4e:	01050913          	addi	s2,a0,16
    80002c52:	854a                	mv	a0,s2
    80002c54:	2d5000ef          	jal	ra,80003728 <holdingsleep>
    80002c58:	cd09                	beqz	a0,80002c72 <iunlock+0x34>
    80002c5a:	449c                	lw	a5,8(s1)
    80002c5c:	00f05b63          	blez	a5,80002c72 <iunlock+0x34>
  releasesleep(&ip->lock);
    80002c60:	854a                	mv	a0,s2
    80002c62:	28f000ef          	jal	ra,800036f0 <releasesleep>
}
    80002c66:	60e2                	ld	ra,24(sp)
    80002c68:	6442                	ld	s0,16(sp)
    80002c6a:	64a2                	ld	s1,8(sp)
    80002c6c:	6902                	ld	s2,0(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret
    panic("iunlock");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	aae50513          	addi	a0,a0,-1362 # 80007720 <syscalls+0x200>
    80002c7a:	3f9020ef          	jal	ra,80005872 <panic>

0000000080002c7e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002c7e:	7179                	addi	sp,sp,-48
    80002c80:	f406                	sd	ra,40(sp)
    80002c82:	f022                	sd	s0,32(sp)
    80002c84:	ec26                	sd	s1,24(sp)
    80002c86:	e84a                	sd	s2,16(sp)
    80002c88:	e44e                	sd	s3,8(sp)
    80002c8a:	e052                	sd	s4,0(sp)
    80002c8c:	1800                	addi	s0,sp,48
    80002c8e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002c90:	05050493          	addi	s1,a0,80
    80002c94:	08050913          	addi	s2,a0,128
    80002c98:	a021                	j	80002ca0 <itrunc+0x22>
    80002c9a:	0491                	addi	s1,s1,4
    80002c9c:	01248b63          	beq	s1,s2,80002cb2 <itrunc+0x34>
    if(ip->addrs[i]){
    80002ca0:	408c                	lw	a1,0(s1)
    80002ca2:	dde5                	beqz	a1,80002c9a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002ca4:	0009a503          	lw	a0,0(s3)
    80002ca8:	9c9ff0ef          	jal	ra,80002670 <bfree>
      ip->addrs[i] = 0;
    80002cac:	0004a023          	sw	zero,0(s1)
    80002cb0:	b7ed                	j	80002c9a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002cb2:	0809a583          	lw	a1,128(s3)
    80002cb6:	ed91                	bnez	a1,80002cd2 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002cb8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002cbc:	854e                	mv	a0,s3
    80002cbe:	e25ff0ef          	jal	ra,80002ae2 <iupdate>
}
    80002cc2:	70a2                	ld	ra,40(sp)
    80002cc4:	7402                	ld	s0,32(sp)
    80002cc6:	64e2                	ld	s1,24(sp)
    80002cc8:	6942                	ld	s2,16(sp)
    80002cca:	69a2                	ld	s3,8(sp)
    80002ccc:	6a02                	ld	s4,0(sp)
    80002cce:	6145                	addi	sp,sp,48
    80002cd0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002cd2:	0009a503          	lw	a0,0(s3)
    80002cd6:	fa0ff0ef          	jal	ra,80002476 <bread>
    80002cda:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002cdc:	05850493          	addi	s1,a0,88
    80002ce0:	45850913          	addi	s2,a0,1112
    80002ce4:	a801                	j	80002cf4 <itrunc+0x76>
        bfree(ip->dev, a[j]);
    80002ce6:	0009a503          	lw	a0,0(s3)
    80002cea:	987ff0ef          	jal	ra,80002670 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002cee:	0491                	addi	s1,s1,4
    80002cf0:	01248563          	beq	s1,s2,80002cfa <itrunc+0x7c>
      if(a[j])
    80002cf4:	408c                	lw	a1,0(s1)
    80002cf6:	dde5                	beqz	a1,80002cee <itrunc+0x70>
    80002cf8:	b7fd                	j	80002ce6 <itrunc+0x68>
    brelse(bp);
    80002cfa:	8552                	mv	a0,s4
    80002cfc:	883ff0ef          	jal	ra,8000257e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002d00:	0809a583          	lw	a1,128(s3)
    80002d04:	0009a503          	lw	a0,0(s3)
    80002d08:	969ff0ef          	jal	ra,80002670 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002d0c:	0809a023          	sw	zero,128(s3)
    80002d10:	b765                	j	80002cb8 <itrunc+0x3a>

0000000080002d12 <iput>:
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	e426                	sd	s1,8(sp)
    80002d1a:	e04a                	sd	s2,0(sp)
    80002d1c:	1000                	addi	s0,sp,32
    80002d1e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d20:	00013517          	auipc	a0,0x13
    80002d24:	2a050513          	addi	a0,a0,672 # 80015fc0 <itable>
    80002d28:	667020ef          	jal	ra,80005b8e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d2c:	4498                	lw	a4,8(s1)
    80002d2e:	4785                	li	a5,1
    80002d30:	02f70163          	beq	a4,a5,80002d52 <iput+0x40>
  ip->ref--;
    80002d34:	449c                	lw	a5,8(s1)
    80002d36:	37fd                	addiw	a5,a5,-1
    80002d38:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002d3a:	00013517          	auipc	a0,0x13
    80002d3e:	28650513          	addi	a0,a0,646 # 80015fc0 <itable>
    80002d42:	6e5020ef          	jal	ra,80005c26 <release>
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6902                	ld	s2,0(sp)
    80002d4e:	6105                	addi	sp,sp,32
    80002d50:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d52:	40bc                	lw	a5,64(s1)
    80002d54:	d3e5                	beqz	a5,80002d34 <iput+0x22>
    80002d56:	04a49783          	lh	a5,74(s1)
    80002d5a:	ffe9                	bnez	a5,80002d34 <iput+0x22>
    acquiresleep(&ip->lock);
    80002d5c:	01048913          	addi	s2,s1,16
    80002d60:	854a                	mv	a0,s2
    80002d62:	149000ef          	jal	ra,800036aa <acquiresleep>
    release(&itable.lock);
    80002d66:	00013517          	auipc	a0,0x13
    80002d6a:	25a50513          	addi	a0,a0,602 # 80015fc0 <itable>
    80002d6e:	6b9020ef          	jal	ra,80005c26 <release>
    itrunc(ip);
    80002d72:	8526                	mv	a0,s1
    80002d74:	f0bff0ef          	jal	ra,80002c7e <itrunc>
    ip->type = 0;
    80002d78:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002d7c:	8526                	mv	a0,s1
    80002d7e:	d65ff0ef          	jal	ra,80002ae2 <iupdate>
    ip->valid = 0;
    80002d82:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002d86:	854a                	mv	a0,s2
    80002d88:	169000ef          	jal	ra,800036f0 <releasesleep>
    acquire(&itable.lock);
    80002d8c:	00013517          	auipc	a0,0x13
    80002d90:	23450513          	addi	a0,a0,564 # 80015fc0 <itable>
    80002d94:	5fb020ef          	jal	ra,80005b8e <acquire>
    80002d98:	bf71                	j	80002d34 <iput+0x22>

0000000080002d9a <iunlockput>:
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	84aa                	mv	s1,a0
  iunlock(ip);
    80002da6:	e99ff0ef          	jal	ra,80002c3e <iunlock>
  iput(ip);
    80002daa:	8526                	mv	a0,s1
    80002dac:	f67ff0ef          	jal	ra,80002d12 <iput>
}
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	64a2                	ld	s1,8(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret

0000000080002dba <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002dba:	1141                	addi	sp,sp,-16
    80002dbc:	e422                	sd	s0,8(sp)
    80002dbe:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002dc0:	411c                	lw	a5,0(a0)
    80002dc2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002dc4:	415c                	lw	a5,4(a0)
    80002dc6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002dc8:	04451783          	lh	a5,68(a0)
    80002dcc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002dd0:	04a51783          	lh	a5,74(a0)
    80002dd4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002dd8:	04c56783          	lwu	a5,76(a0)
    80002ddc:	e99c                	sd	a5,16(a1)
}
    80002dde:	6422                	ld	s0,8(sp)
    80002de0:	0141                	addi	sp,sp,16
    80002de2:	8082                	ret

0000000080002de4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002de4:	457c                	lw	a5,76(a0)
    80002de6:	0cd7ef63          	bltu	a5,a3,80002ec4 <readi+0xe0>
{
    80002dea:	7159                	addi	sp,sp,-112
    80002dec:	f486                	sd	ra,104(sp)
    80002dee:	f0a2                	sd	s0,96(sp)
    80002df0:	eca6                	sd	s1,88(sp)
    80002df2:	e8ca                	sd	s2,80(sp)
    80002df4:	e4ce                	sd	s3,72(sp)
    80002df6:	e0d2                	sd	s4,64(sp)
    80002df8:	fc56                	sd	s5,56(sp)
    80002dfa:	f85a                	sd	s6,48(sp)
    80002dfc:	f45e                	sd	s7,40(sp)
    80002dfe:	f062                	sd	s8,32(sp)
    80002e00:	ec66                	sd	s9,24(sp)
    80002e02:	e86a                	sd	s10,16(sp)
    80002e04:	e46e                	sd	s11,8(sp)
    80002e06:	1880                	addi	s0,sp,112
    80002e08:	8b2a                	mv	s6,a0
    80002e0a:	8bae                	mv	s7,a1
    80002e0c:	8a32                	mv	s4,a2
    80002e0e:	84b6                	mv	s1,a3
    80002e10:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002e12:	9f35                	addw	a4,a4,a3
    return 0;
    80002e14:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002e16:	08d76663          	bltu	a4,a3,80002ea2 <readi+0xbe>
  if(off + n > ip->size)
    80002e1a:	00e7f463          	bgeu	a5,a4,80002e22 <readi+0x3e>
    n = ip->size - off;
    80002e1e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e22:	080a8f63          	beqz	s5,80002ec0 <readi+0xdc>
    80002e26:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e28:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002e2c:	5c7d                	li	s8,-1
    80002e2e:	a80d                	j	80002e60 <readi+0x7c>
    80002e30:	020d1d93          	slli	s11,s10,0x20
    80002e34:	020ddd93          	srli	s11,s11,0x20
    80002e38:	05890613          	addi	a2,s2,88
    80002e3c:	86ee                	mv	a3,s11
    80002e3e:	963a                	add	a2,a2,a4
    80002e40:	85d2                	mv	a1,s4
    80002e42:	855e                	mv	a0,s7
    80002e44:	d6bfe0ef          	jal	ra,80001bae <either_copyout>
    80002e48:	05850763          	beq	a0,s8,80002e96 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002e4c:	854a                	mv	a0,s2
    80002e4e:	f30ff0ef          	jal	ra,8000257e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e52:	013d09bb          	addw	s3,s10,s3
    80002e56:	009d04bb          	addw	s1,s10,s1
    80002e5a:	9a6e                	add	s4,s4,s11
    80002e5c:	0559f163          	bgeu	s3,s5,80002e9e <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80002e60:	00a4d59b          	srliw	a1,s1,0xa
    80002e64:	855a                	mv	a0,s6
    80002e66:	98bff0ef          	jal	ra,800027f0 <bmap>
    80002e6a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002e6e:	c985                	beqz	a1,80002e9e <readi+0xba>
    bp = bread(ip->dev, addr);
    80002e70:	000b2503          	lw	a0,0(s6)
    80002e74:	e02ff0ef          	jal	ra,80002476 <bread>
    80002e78:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e7a:	3ff4f713          	andi	a4,s1,1023
    80002e7e:	40ec87bb          	subw	a5,s9,a4
    80002e82:	413a86bb          	subw	a3,s5,s3
    80002e86:	8d3e                	mv	s10,a5
    80002e88:	2781                	sext.w	a5,a5
    80002e8a:	0006861b          	sext.w	a2,a3
    80002e8e:	faf671e3          	bgeu	a2,a5,80002e30 <readi+0x4c>
    80002e92:	8d36                	mv	s10,a3
    80002e94:	bf71                	j	80002e30 <readi+0x4c>
      brelse(bp);
    80002e96:	854a                	mv	a0,s2
    80002e98:	ee6ff0ef          	jal	ra,8000257e <brelse>
      tot = -1;
    80002e9c:	59fd                	li	s3,-1
  }
  return tot;
    80002e9e:	0009851b          	sext.w	a0,s3
}
    80002ea2:	70a6                	ld	ra,104(sp)
    80002ea4:	7406                	ld	s0,96(sp)
    80002ea6:	64e6                	ld	s1,88(sp)
    80002ea8:	6946                	ld	s2,80(sp)
    80002eaa:	69a6                	ld	s3,72(sp)
    80002eac:	6a06                	ld	s4,64(sp)
    80002eae:	7ae2                	ld	s5,56(sp)
    80002eb0:	7b42                	ld	s6,48(sp)
    80002eb2:	7ba2                	ld	s7,40(sp)
    80002eb4:	7c02                	ld	s8,32(sp)
    80002eb6:	6ce2                	ld	s9,24(sp)
    80002eb8:	6d42                	ld	s10,16(sp)
    80002eba:	6da2                	ld	s11,8(sp)
    80002ebc:	6165                	addi	sp,sp,112
    80002ebe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002ec0:	89d6                	mv	s3,s5
    80002ec2:	bff1                	j	80002e9e <readi+0xba>
    return 0;
    80002ec4:	4501                	li	a0,0
}
    80002ec6:	8082                	ret

0000000080002ec8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002ec8:	457c                	lw	a5,76(a0)
    80002eca:	0ed7ea63          	bltu	a5,a3,80002fbe <writei+0xf6>
{
    80002ece:	7159                	addi	sp,sp,-112
    80002ed0:	f486                	sd	ra,104(sp)
    80002ed2:	f0a2                	sd	s0,96(sp)
    80002ed4:	eca6                	sd	s1,88(sp)
    80002ed6:	e8ca                	sd	s2,80(sp)
    80002ed8:	e4ce                	sd	s3,72(sp)
    80002eda:	e0d2                	sd	s4,64(sp)
    80002edc:	fc56                	sd	s5,56(sp)
    80002ede:	f85a                	sd	s6,48(sp)
    80002ee0:	f45e                	sd	s7,40(sp)
    80002ee2:	f062                	sd	s8,32(sp)
    80002ee4:	ec66                	sd	s9,24(sp)
    80002ee6:	e86a                	sd	s10,16(sp)
    80002ee8:	e46e                	sd	s11,8(sp)
    80002eea:	1880                	addi	s0,sp,112
    80002eec:	8aaa                	mv	s5,a0
    80002eee:	8bae                	mv	s7,a1
    80002ef0:	8a32                	mv	s4,a2
    80002ef2:	8936                	mv	s2,a3
    80002ef4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002ef6:	00e687bb          	addw	a5,a3,a4
    80002efa:	0cd7e463          	bltu	a5,a3,80002fc2 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002efe:	00043737          	lui	a4,0x43
    80002f02:	0cf76263          	bltu	a4,a5,80002fc6 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f06:	0a0b0a63          	beqz	s6,80002fba <writei+0xf2>
    80002f0a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f0c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002f10:	5c7d                	li	s8,-1
    80002f12:	a825                	j	80002f4a <writei+0x82>
    80002f14:	020d1d93          	slli	s11,s10,0x20
    80002f18:	020ddd93          	srli	s11,s11,0x20
    80002f1c:	05848513          	addi	a0,s1,88
    80002f20:	86ee                	mv	a3,s11
    80002f22:	8652                	mv	a2,s4
    80002f24:	85de                	mv	a1,s7
    80002f26:	953a                	add	a0,a0,a4
    80002f28:	cd1fe0ef          	jal	ra,80001bf8 <either_copyin>
    80002f2c:	05850a63          	beq	a0,s8,80002f80 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002f30:	8526                	mv	a0,s1
    80002f32:	670000ef          	jal	ra,800035a2 <log_write>
    brelse(bp);
    80002f36:	8526                	mv	a0,s1
    80002f38:	e46ff0ef          	jal	ra,8000257e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f3c:	013d09bb          	addw	s3,s10,s3
    80002f40:	012d093b          	addw	s2,s10,s2
    80002f44:	9a6e                	add	s4,s4,s11
    80002f46:	0569f063          	bgeu	s3,s6,80002f86 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002f4a:	00a9559b          	srliw	a1,s2,0xa
    80002f4e:	8556                	mv	a0,s5
    80002f50:	8a1ff0ef          	jal	ra,800027f0 <bmap>
    80002f54:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002f58:	c59d                	beqz	a1,80002f86 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002f5a:	000aa503          	lw	a0,0(s5)
    80002f5e:	d18ff0ef          	jal	ra,80002476 <bread>
    80002f62:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f64:	3ff97713          	andi	a4,s2,1023
    80002f68:	40ec87bb          	subw	a5,s9,a4
    80002f6c:	413b06bb          	subw	a3,s6,s3
    80002f70:	8d3e                	mv	s10,a5
    80002f72:	2781                	sext.w	a5,a5
    80002f74:	0006861b          	sext.w	a2,a3
    80002f78:	f8f67ee3          	bgeu	a2,a5,80002f14 <writei+0x4c>
    80002f7c:	8d36                	mv	s10,a3
    80002f7e:	bf59                	j	80002f14 <writei+0x4c>
      brelse(bp);
    80002f80:	8526                	mv	a0,s1
    80002f82:	dfcff0ef          	jal	ra,8000257e <brelse>
  }

  if(off > ip->size)
    80002f86:	04caa783          	lw	a5,76(s5)
    80002f8a:	0127f463          	bgeu	a5,s2,80002f92 <writei+0xca>
    ip->size = off;
    80002f8e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002f92:	8556                	mv	a0,s5
    80002f94:	b4fff0ef          	jal	ra,80002ae2 <iupdate>

  return tot;
    80002f98:	0009851b          	sext.w	a0,s3
}
    80002f9c:	70a6                	ld	ra,104(sp)
    80002f9e:	7406                	ld	s0,96(sp)
    80002fa0:	64e6                	ld	s1,88(sp)
    80002fa2:	6946                	ld	s2,80(sp)
    80002fa4:	69a6                	ld	s3,72(sp)
    80002fa6:	6a06                	ld	s4,64(sp)
    80002fa8:	7ae2                	ld	s5,56(sp)
    80002faa:	7b42                	ld	s6,48(sp)
    80002fac:	7ba2                	ld	s7,40(sp)
    80002fae:	7c02                	ld	s8,32(sp)
    80002fb0:	6ce2                	ld	s9,24(sp)
    80002fb2:	6d42                	ld	s10,16(sp)
    80002fb4:	6da2                	ld	s11,8(sp)
    80002fb6:	6165                	addi	sp,sp,112
    80002fb8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fba:	89da                	mv	s3,s6
    80002fbc:	bfd9                	j	80002f92 <writei+0xca>
    return -1;
    80002fbe:	557d                	li	a0,-1
}
    80002fc0:	8082                	ret
    return -1;
    80002fc2:	557d                	li	a0,-1
    80002fc4:	bfe1                	j	80002f9c <writei+0xd4>
    return -1;
    80002fc6:	557d                	li	a0,-1
    80002fc8:	bfd1                	j	80002f9c <writei+0xd4>

0000000080002fca <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002fca:	1141                	addi	sp,sp,-16
    80002fcc:	e406                	sd	ra,8(sp)
    80002fce:	e022                	sd	s0,0(sp)
    80002fd0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002fd2:	4639                	li	a2,14
    80002fd4:	b3afd0ef          	jal	ra,8000030e <strncmp>
}
    80002fd8:	60a2                	ld	ra,8(sp)
    80002fda:	6402                	ld	s0,0(sp)
    80002fdc:	0141                	addi	sp,sp,16
    80002fde:	8082                	ret

0000000080002fe0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002fe0:	7139                	addi	sp,sp,-64
    80002fe2:	fc06                	sd	ra,56(sp)
    80002fe4:	f822                	sd	s0,48(sp)
    80002fe6:	f426                	sd	s1,40(sp)
    80002fe8:	f04a                	sd	s2,32(sp)
    80002fea:	ec4e                	sd	s3,24(sp)
    80002fec:	e852                	sd	s4,16(sp)
    80002fee:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002ff0:	04451703          	lh	a4,68(a0)
    80002ff4:	4785                	li	a5,1
    80002ff6:	00f71a63          	bne	a4,a5,8000300a <dirlookup+0x2a>
    80002ffa:	892a                	mv	s2,a0
    80002ffc:	89ae                	mv	s3,a1
    80002ffe:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003000:	457c                	lw	a5,76(a0)
    80003002:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003004:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003006:	e39d                	bnez	a5,8000302c <dirlookup+0x4c>
    80003008:	a095                	j	8000306c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000300a:	00004517          	auipc	a0,0x4
    8000300e:	71e50513          	addi	a0,a0,1822 # 80007728 <syscalls+0x208>
    80003012:	061020ef          	jal	ra,80005872 <panic>
      panic("dirlookup read");
    80003016:	00004517          	auipc	a0,0x4
    8000301a:	72a50513          	addi	a0,a0,1834 # 80007740 <syscalls+0x220>
    8000301e:	055020ef          	jal	ra,80005872 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003022:	24c1                	addiw	s1,s1,16
    80003024:	04c92783          	lw	a5,76(s2)
    80003028:	04f4f163          	bgeu	s1,a5,8000306a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000302c:	4741                	li	a4,16
    8000302e:	86a6                	mv	a3,s1
    80003030:	fc040613          	addi	a2,s0,-64
    80003034:	4581                	li	a1,0
    80003036:	854a                	mv	a0,s2
    80003038:	dadff0ef          	jal	ra,80002de4 <readi>
    8000303c:	47c1                	li	a5,16
    8000303e:	fcf51ce3          	bne	a0,a5,80003016 <dirlookup+0x36>
    if(de.inum == 0)
    80003042:	fc045783          	lhu	a5,-64(s0)
    80003046:	dff1                	beqz	a5,80003022 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003048:	fc240593          	addi	a1,s0,-62
    8000304c:	854e                	mv	a0,s3
    8000304e:	f7dff0ef          	jal	ra,80002fca <namecmp>
    80003052:	f961                	bnez	a0,80003022 <dirlookup+0x42>
      if(poff)
    80003054:	000a0463          	beqz	s4,8000305c <dirlookup+0x7c>
        *poff = off;
    80003058:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000305c:	fc045583          	lhu	a1,-64(s0)
    80003060:	00092503          	lw	a0,0(s2)
    80003064:	859ff0ef          	jal	ra,800028bc <iget>
    80003068:	a011                	j	8000306c <dirlookup+0x8c>
  return 0;
    8000306a:	4501                	li	a0,0
}
    8000306c:	70e2                	ld	ra,56(sp)
    8000306e:	7442                	ld	s0,48(sp)
    80003070:	74a2                	ld	s1,40(sp)
    80003072:	7902                	ld	s2,32(sp)
    80003074:	69e2                	ld	s3,24(sp)
    80003076:	6a42                	ld	s4,16(sp)
    80003078:	6121                	addi	sp,sp,64
    8000307a:	8082                	ret

000000008000307c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000307c:	711d                	addi	sp,sp,-96
    8000307e:	ec86                	sd	ra,88(sp)
    80003080:	e8a2                	sd	s0,80(sp)
    80003082:	e4a6                	sd	s1,72(sp)
    80003084:	e0ca                	sd	s2,64(sp)
    80003086:	fc4e                	sd	s3,56(sp)
    80003088:	f852                	sd	s4,48(sp)
    8000308a:	f456                	sd	s5,40(sp)
    8000308c:	f05a                	sd	s6,32(sp)
    8000308e:	ec5e                	sd	s7,24(sp)
    80003090:	e862                	sd	s8,16(sp)
    80003092:	e466                	sd	s9,8(sp)
    80003094:	1080                	addi	s0,sp,96
    80003096:	84aa                	mv	s1,a0
    80003098:	8b2e                	mv	s6,a1
    8000309a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000309c:	00054703          	lbu	a4,0(a0)
    800030a0:	02f00793          	li	a5,47
    800030a4:	00f70f63          	beq	a4,a5,800030c2 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800030a8:	93cfe0ef          	jal	ra,800011e4 <myproc>
    800030ac:	15053503          	ld	a0,336(a0)
    800030b0:	aafff0ef          	jal	ra,80002b5e <idup>
    800030b4:	89aa                	mv	s3,a0
  while(*path == '/')
    800030b6:	02f00913          	li	s2,47
  len = path - s;
    800030ba:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800030bc:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800030be:	4c05                	li	s8,1
    800030c0:	a861                	j	80003158 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    800030c2:	4585                	li	a1,1
    800030c4:	4505                	li	a0,1
    800030c6:	ff6ff0ef          	jal	ra,800028bc <iget>
    800030ca:	89aa                	mv	s3,a0
    800030cc:	b7ed                	j	800030b6 <namex+0x3a>
      iunlockput(ip);
    800030ce:	854e                	mv	a0,s3
    800030d0:	ccbff0ef          	jal	ra,80002d9a <iunlockput>
      return 0;
    800030d4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800030d6:	854e                	mv	a0,s3
    800030d8:	60e6                	ld	ra,88(sp)
    800030da:	6446                	ld	s0,80(sp)
    800030dc:	64a6                	ld	s1,72(sp)
    800030de:	6906                	ld	s2,64(sp)
    800030e0:	79e2                	ld	s3,56(sp)
    800030e2:	7a42                	ld	s4,48(sp)
    800030e4:	7aa2                	ld	s5,40(sp)
    800030e6:	7b02                	ld	s6,32(sp)
    800030e8:	6be2                	ld	s7,24(sp)
    800030ea:	6c42                	ld	s8,16(sp)
    800030ec:	6ca2                	ld	s9,8(sp)
    800030ee:	6125                	addi	sp,sp,96
    800030f0:	8082                	ret
      iunlock(ip);
    800030f2:	854e                	mv	a0,s3
    800030f4:	b4bff0ef          	jal	ra,80002c3e <iunlock>
      return ip;
    800030f8:	bff9                	j	800030d6 <namex+0x5a>
      iunlockput(ip);
    800030fa:	854e                	mv	a0,s3
    800030fc:	c9fff0ef          	jal	ra,80002d9a <iunlockput>
      return 0;
    80003100:	89d2                	mv	s3,s4
    80003102:	bfd1                	j	800030d6 <namex+0x5a>
  len = path - s;
    80003104:	40b48633          	sub	a2,s1,a1
    80003108:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000310c:	074cdc63          	bge	s9,s4,80003184 <namex+0x108>
    memmove(name, s, DIRSIZ);
    80003110:	4639                	li	a2,14
    80003112:	8556                	mv	a0,s5
    80003114:	986fd0ef          	jal	ra,8000029a <memmove>
  while(*path == '/')
    80003118:	0004c783          	lbu	a5,0(s1)
    8000311c:	01279763          	bne	a5,s2,8000312a <namex+0xae>
    path++;
    80003120:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003122:	0004c783          	lbu	a5,0(s1)
    80003126:	ff278de3          	beq	a5,s2,80003120 <namex+0xa4>
    ilock(ip);
    8000312a:	854e                	mv	a0,s3
    8000312c:	a69ff0ef          	jal	ra,80002b94 <ilock>
    if(ip->type != T_DIR){
    80003130:	04499783          	lh	a5,68(s3)
    80003134:	f9879de3          	bne	a5,s8,800030ce <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003138:	000b0563          	beqz	s6,80003142 <namex+0xc6>
    8000313c:	0004c783          	lbu	a5,0(s1)
    80003140:	dbcd                	beqz	a5,800030f2 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003142:	865e                	mv	a2,s7
    80003144:	85d6                	mv	a1,s5
    80003146:	854e                	mv	a0,s3
    80003148:	e99ff0ef          	jal	ra,80002fe0 <dirlookup>
    8000314c:	8a2a                	mv	s4,a0
    8000314e:	d555                	beqz	a0,800030fa <namex+0x7e>
    iunlockput(ip);
    80003150:	854e                	mv	a0,s3
    80003152:	c49ff0ef          	jal	ra,80002d9a <iunlockput>
    ip = next;
    80003156:	89d2                	mv	s3,s4
  while(*path == '/')
    80003158:	0004c783          	lbu	a5,0(s1)
    8000315c:	05279363          	bne	a5,s2,800031a2 <namex+0x126>
    path++;
    80003160:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003162:	0004c783          	lbu	a5,0(s1)
    80003166:	ff278de3          	beq	a5,s2,80003160 <namex+0xe4>
  if(*path == 0)
    8000316a:	c78d                	beqz	a5,80003194 <namex+0x118>
    path++;
    8000316c:	85a6                	mv	a1,s1
  len = path - s;
    8000316e:	8a5e                	mv	s4,s7
    80003170:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003172:	01278963          	beq	a5,s2,80003184 <namex+0x108>
    80003176:	d7d9                	beqz	a5,80003104 <namex+0x88>
    path++;
    80003178:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000317a:	0004c783          	lbu	a5,0(s1)
    8000317e:	ff279ce3          	bne	a5,s2,80003176 <namex+0xfa>
    80003182:	b749                	j	80003104 <namex+0x88>
    memmove(name, s, len);
    80003184:	2601                	sext.w	a2,a2
    80003186:	8556                	mv	a0,s5
    80003188:	912fd0ef          	jal	ra,8000029a <memmove>
    name[len] = 0;
    8000318c:	9a56                	add	s4,s4,s5
    8000318e:	000a0023          	sb	zero,0(s4)
    80003192:	b759                	j	80003118 <namex+0x9c>
  if(nameiparent){
    80003194:	f40b01e3          	beqz	s6,800030d6 <namex+0x5a>
    iput(ip);
    80003198:	854e                	mv	a0,s3
    8000319a:	b79ff0ef          	jal	ra,80002d12 <iput>
    return 0;
    8000319e:	4981                	li	s3,0
    800031a0:	bf1d                	j	800030d6 <namex+0x5a>
  if(*path == 0)
    800031a2:	dbed                	beqz	a5,80003194 <namex+0x118>
  while(*path != '/' && *path != 0)
    800031a4:	0004c783          	lbu	a5,0(s1)
    800031a8:	85a6                	mv	a1,s1
    800031aa:	b7f1                	j	80003176 <namex+0xfa>

00000000800031ac <dirlink>:
{
    800031ac:	7139                	addi	sp,sp,-64
    800031ae:	fc06                	sd	ra,56(sp)
    800031b0:	f822                	sd	s0,48(sp)
    800031b2:	f426                	sd	s1,40(sp)
    800031b4:	f04a                	sd	s2,32(sp)
    800031b6:	ec4e                	sd	s3,24(sp)
    800031b8:	e852                	sd	s4,16(sp)
    800031ba:	0080                	addi	s0,sp,64
    800031bc:	892a                	mv	s2,a0
    800031be:	8a2e                	mv	s4,a1
    800031c0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800031c2:	4601                	li	a2,0
    800031c4:	e1dff0ef          	jal	ra,80002fe0 <dirlookup>
    800031c8:	e52d                	bnez	a0,80003232 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031ca:	04c92483          	lw	s1,76(s2)
    800031ce:	c48d                	beqz	s1,800031f8 <dirlink+0x4c>
    800031d0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800031d2:	4741                	li	a4,16
    800031d4:	86a6                	mv	a3,s1
    800031d6:	fc040613          	addi	a2,s0,-64
    800031da:	4581                	li	a1,0
    800031dc:	854a                	mv	a0,s2
    800031de:	c07ff0ef          	jal	ra,80002de4 <readi>
    800031e2:	47c1                	li	a5,16
    800031e4:	04f51b63          	bne	a0,a5,8000323a <dirlink+0x8e>
    if(de.inum == 0)
    800031e8:	fc045783          	lhu	a5,-64(s0)
    800031ec:	c791                	beqz	a5,800031f8 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031ee:	24c1                	addiw	s1,s1,16
    800031f0:	04c92783          	lw	a5,76(s2)
    800031f4:	fcf4efe3          	bltu	s1,a5,800031d2 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800031f8:	4639                	li	a2,14
    800031fa:	85d2                	mv	a1,s4
    800031fc:	fc240513          	addi	a0,s0,-62
    80003200:	94afd0ef          	jal	ra,8000034a <strncpy>
  de.inum = inum;
    80003204:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003208:	4741                	li	a4,16
    8000320a:	86a6                	mv	a3,s1
    8000320c:	fc040613          	addi	a2,s0,-64
    80003210:	4581                	li	a1,0
    80003212:	854a                	mv	a0,s2
    80003214:	cb5ff0ef          	jal	ra,80002ec8 <writei>
    80003218:	1541                	addi	a0,a0,-16
    8000321a:	00a03533          	snez	a0,a0
    8000321e:	40a00533          	neg	a0,a0
}
    80003222:	70e2                	ld	ra,56(sp)
    80003224:	7442                	ld	s0,48(sp)
    80003226:	74a2                	ld	s1,40(sp)
    80003228:	7902                	ld	s2,32(sp)
    8000322a:	69e2                	ld	s3,24(sp)
    8000322c:	6a42                	ld	s4,16(sp)
    8000322e:	6121                	addi	sp,sp,64
    80003230:	8082                	ret
    iput(ip);
    80003232:	ae1ff0ef          	jal	ra,80002d12 <iput>
    return -1;
    80003236:	557d                	li	a0,-1
    80003238:	b7ed                	j	80003222 <dirlink+0x76>
      panic("dirlink read");
    8000323a:	00004517          	auipc	a0,0x4
    8000323e:	51650513          	addi	a0,a0,1302 # 80007750 <syscalls+0x230>
    80003242:	630020ef          	jal	ra,80005872 <panic>

0000000080003246 <namei>:

struct inode*
namei(char *path)
{
    80003246:	1101                	addi	sp,sp,-32
    80003248:	ec06                	sd	ra,24(sp)
    8000324a:	e822                	sd	s0,16(sp)
    8000324c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000324e:	fe040613          	addi	a2,s0,-32
    80003252:	4581                	li	a1,0
    80003254:	e29ff0ef          	jal	ra,8000307c <namex>
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret

0000000080003260 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003260:	1141                	addi	sp,sp,-16
    80003262:	e406                	sd	ra,8(sp)
    80003264:	e022                	sd	s0,0(sp)
    80003266:	0800                	addi	s0,sp,16
    80003268:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000326a:	4585                	li	a1,1
    8000326c:	e11ff0ef          	jal	ra,8000307c <namex>
}
    80003270:	60a2                	ld	ra,8(sp)
    80003272:	6402                	ld	s0,0(sp)
    80003274:	0141                	addi	sp,sp,16
    80003276:	8082                	ret

0000000080003278 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	e426                	sd	s1,8(sp)
    80003280:	e04a                	sd	s2,0(sp)
    80003282:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003284:	00014917          	auipc	s2,0x14
    80003288:	7e490913          	addi	s2,s2,2020 # 80017a68 <log>
    8000328c:	01892583          	lw	a1,24(s2)
    80003290:	02892503          	lw	a0,40(s2)
    80003294:	9e2ff0ef          	jal	ra,80002476 <bread>
    80003298:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000329a:	02c92683          	lw	a3,44(s2)
    8000329e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800032a0:	02d05763          	blez	a3,800032ce <write_head+0x56>
    800032a4:	00014797          	auipc	a5,0x14
    800032a8:	7f478793          	addi	a5,a5,2036 # 80017a98 <log+0x30>
    800032ac:	05c50713          	addi	a4,a0,92
    800032b0:	36fd                	addiw	a3,a3,-1
    800032b2:	1682                	slli	a3,a3,0x20
    800032b4:	9281                	srli	a3,a3,0x20
    800032b6:	068a                	slli	a3,a3,0x2
    800032b8:	00014617          	auipc	a2,0x14
    800032bc:	7e460613          	addi	a2,a2,2020 # 80017a9c <log+0x34>
    800032c0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800032c2:	4390                	lw	a2,0(a5)
    800032c4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800032c6:	0791                	addi	a5,a5,4
    800032c8:	0711                	addi	a4,a4,4
    800032ca:	fed79ce3          	bne	a5,a3,800032c2 <write_head+0x4a>
  }
  bwrite(buf);
    800032ce:	8526                	mv	a0,s1
    800032d0:	a7cff0ef          	jal	ra,8000254c <bwrite>
  brelse(buf);
    800032d4:	8526                	mv	a0,s1
    800032d6:	aa8ff0ef          	jal	ra,8000257e <brelse>
}
    800032da:	60e2                	ld	ra,24(sp)
    800032dc:	6442                	ld	s0,16(sp)
    800032de:	64a2                	ld	s1,8(sp)
    800032e0:	6902                	ld	s2,0(sp)
    800032e2:	6105                	addi	sp,sp,32
    800032e4:	8082                	ret

00000000800032e6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800032e6:	00014797          	auipc	a5,0x14
    800032ea:	7ae7a783          	lw	a5,1966(a5) # 80017a94 <log+0x2c>
    800032ee:	08f05f63          	blez	a5,8000338c <install_trans+0xa6>
{
    800032f2:	7139                	addi	sp,sp,-64
    800032f4:	fc06                	sd	ra,56(sp)
    800032f6:	f822                	sd	s0,48(sp)
    800032f8:	f426                	sd	s1,40(sp)
    800032fa:	f04a                	sd	s2,32(sp)
    800032fc:	ec4e                	sd	s3,24(sp)
    800032fe:	e852                	sd	s4,16(sp)
    80003300:	e456                	sd	s5,8(sp)
    80003302:	e05a                	sd	s6,0(sp)
    80003304:	0080                	addi	s0,sp,64
    80003306:	8b2a                	mv	s6,a0
    80003308:	00014a97          	auipc	s5,0x14
    8000330c:	790a8a93          	addi	s5,s5,1936 # 80017a98 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003310:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003312:	00014997          	auipc	s3,0x14
    80003316:	75698993          	addi	s3,s3,1878 # 80017a68 <log>
    8000331a:	a005                	j	8000333a <install_trans+0x54>
      bunpin(dbuf);
    8000331c:	8526                	mv	a0,s1
    8000331e:	b1eff0ef          	jal	ra,8000263c <bunpin>
    brelse(lbuf);
    80003322:	854a                	mv	a0,s2
    80003324:	a5aff0ef          	jal	ra,8000257e <brelse>
    brelse(dbuf);
    80003328:	8526                	mv	a0,s1
    8000332a:	a54ff0ef          	jal	ra,8000257e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000332e:	2a05                	addiw	s4,s4,1
    80003330:	0a91                	addi	s5,s5,4
    80003332:	02c9a783          	lw	a5,44(s3)
    80003336:	04fa5163          	bge	s4,a5,80003378 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000333a:	0189a583          	lw	a1,24(s3)
    8000333e:	014585bb          	addw	a1,a1,s4
    80003342:	2585                	addiw	a1,a1,1
    80003344:	0289a503          	lw	a0,40(s3)
    80003348:	92eff0ef          	jal	ra,80002476 <bread>
    8000334c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000334e:	000aa583          	lw	a1,0(s5)
    80003352:	0289a503          	lw	a0,40(s3)
    80003356:	920ff0ef          	jal	ra,80002476 <bread>
    8000335a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000335c:	40000613          	li	a2,1024
    80003360:	05890593          	addi	a1,s2,88
    80003364:	05850513          	addi	a0,a0,88
    80003368:	f33fc0ef          	jal	ra,8000029a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000336c:	8526                	mv	a0,s1
    8000336e:	9deff0ef          	jal	ra,8000254c <bwrite>
    if(recovering == 0)
    80003372:	fa0b18e3          	bnez	s6,80003322 <install_trans+0x3c>
    80003376:	b75d                	j	8000331c <install_trans+0x36>
}
    80003378:	70e2                	ld	ra,56(sp)
    8000337a:	7442                	ld	s0,48(sp)
    8000337c:	74a2                	ld	s1,40(sp)
    8000337e:	7902                	ld	s2,32(sp)
    80003380:	69e2                	ld	s3,24(sp)
    80003382:	6a42                	ld	s4,16(sp)
    80003384:	6aa2                	ld	s5,8(sp)
    80003386:	6b02                	ld	s6,0(sp)
    80003388:	6121                	addi	sp,sp,64
    8000338a:	8082                	ret
    8000338c:	8082                	ret

000000008000338e <initlog>:
{
    8000338e:	7179                	addi	sp,sp,-48
    80003390:	f406                	sd	ra,40(sp)
    80003392:	f022                	sd	s0,32(sp)
    80003394:	ec26                	sd	s1,24(sp)
    80003396:	e84a                	sd	s2,16(sp)
    80003398:	e44e                	sd	s3,8(sp)
    8000339a:	1800                	addi	s0,sp,48
    8000339c:	892a                	mv	s2,a0
    8000339e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800033a0:	00014497          	auipc	s1,0x14
    800033a4:	6c848493          	addi	s1,s1,1736 # 80017a68 <log>
    800033a8:	00004597          	auipc	a1,0x4
    800033ac:	3b858593          	addi	a1,a1,952 # 80007760 <syscalls+0x240>
    800033b0:	8526                	mv	a0,s1
    800033b2:	75c020ef          	jal	ra,80005b0e <initlock>
  log.start = sb->logstart;
    800033b6:	0149a583          	lw	a1,20(s3)
    800033ba:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800033bc:	0109a783          	lw	a5,16(s3)
    800033c0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800033c2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800033c6:	854a                	mv	a0,s2
    800033c8:	8aeff0ef          	jal	ra,80002476 <bread>
  log.lh.n = lh->n;
    800033cc:	4d3c                	lw	a5,88(a0)
    800033ce:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800033d0:	02f05563          	blez	a5,800033fa <initlog+0x6c>
    800033d4:	05c50713          	addi	a4,a0,92
    800033d8:	00014697          	auipc	a3,0x14
    800033dc:	6c068693          	addi	a3,a3,1728 # 80017a98 <log+0x30>
    800033e0:	37fd                	addiw	a5,a5,-1
    800033e2:	1782                	slli	a5,a5,0x20
    800033e4:	9381                	srli	a5,a5,0x20
    800033e6:	078a                	slli	a5,a5,0x2
    800033e8:	06050613          	addi	a2,a0,96
    800033ec:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800033ee:	4310                	lw	a2,0(a4)
    800033f0:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800033f2:	0711                	addi	a4,a4,4
    800033f4:	0691                	addi	a3,a3,4
    800033f6:	fef71ce3          	bne	a4,a5,800033ee <initlog+0x60>
  brelse(buf);
    800033fa:	984ff0ef          	jal	ra,8000257e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800033fe:	4505                	li	a0,1
    80003400:	ee7ff0ef          	jal	ra,800032e6 <install_trans>
  log.lh.n = 0;
    80003404:	00014797          	auipc	a5,0x14
    80003408:	6807a823          	sw	zero,1680(a5) # 80017a94 <log+0x2c>
  write_head(); // clear the log
    8000340c:	e6dff0ef          	jal	ra,80003278 <write_head>
}
    80003410:	70a2                	ld	ra,40(sp)
    80003412:	7402                	ld	s0,32(sp)
    80003414:	64e2                	ld	s1,24(sp)
    80003416:	6942                	ld	s2,16(sp)
    80003418:	69a2                	ld	s3,8(sp)
    8000341a:	6145                	addi	sp,sp,48
    8000341c:	8082                	ret

000000008000341e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000341e:	1101                	addi	sp,sp,-32
    80003420:	ec06                	sd	ra,24(sp)
    80003422:	e822                	sd	s0,16(sp)
    80003424:	e426                	sd	s1,8(sp)
    80003426:	e04a                	sd	s2,0(sp)
    80003428:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000342a:	00014517          	auipc	a0,0x14
    8000342e:	63e50513          	addi	a0,a0,1598 # 80017a68 <log>
    80003432:	75c020ef          	jal	ra,80005b8e <acquire>
  while(1){
    if(log.committing){
    80003436:	00014497          	auipc	s1,0x14
    8000343a:	63248493          	addi	s1,s1,1586 # 80017a68 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000343e:	4979                	li	s2,30
    80003440:	a029                	j	8000344a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003442:	85a6                	mv	a1,s1
    80003444:	8526                	mv	a0,s1
    80003446:	c0cfe0ef          	jal	ra,80001852 <sleep>
    if(log.committing){
    8000344a:	50dc                	lw	a5,36(s1)
    8000344c:	fbfd                	bnez	a5,80003442 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000344e:	509c                	lw	a5,32(s1)
    80003450:	0017871b          	addiw	a4,a5,1
    80003454:	0007069b          	sext.w	a3,a4
    80003458:	0027179b          	slliw	a5,a4,0x2
    8000345c:	9fb9                	addw	a5,a5,a4
    8000345e:	0017979b          	slliw	a5,a5,0x1
    80003462:	54d8                	lw	a4,44(s1)
    80003464:	9fb9                	addw	a5,a5,a4
    80003466:	00f95763          	bge	s2,a5,80003474 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000346a:	85a6                	mv	a1,s1
    8000346c:	8526                	mv	a0,s1
    8000346e:	be4fe0ef          	jal	ra,80001852 <sleep>
    80003472:	bfe1                	j	8000344a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003474:	00014517          	auipc	a0,0x14
    80003478:	5f450513          	addi	a0,a0,1524 # 80017a68 <log>
    8000347c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000347e:	7a8020ef          	jal	ra,80005c26 <release>
      break;
    }
  }
}
    80003482:	60e2                	ld	ra,24(sp)
    80003484:	6442                	ld	s0,16(sp)
    80003486:	64a2                	ld	s1,8(sp)
    80003488:	6902                	ld	s2,0(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret

000000008000348e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000348e:	7139                	addi	sp,sp,-64
    80003490:	fc06                	sd	ra,56(sp)
    80003492:	f822                	sd	s0,48(sp)
    80003494:	f426                	sd	s1,40(sp)
    80003496:	f04a                	sd	s2,32(sp)
    80003498:	ec4e                	sd	s3,24(sp)
    8000349a:	e852                	sd	s4,16(sp)
    8000349c:	e456                	sd	s5,8(sp)
    8000349e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800034a0:	00014497          	auipc	s1,0x14
    800034a4:	5c848493          	addi	s1,s1,1480 # 80017a68 <log>
    800034a8:	8526                	mv	a0,s1
    800034aa:	6e4020ef          	jal	ra,80005b8e <acquire>
  log.outstanding -= 1;
    800034ae:	509c                	lw	a5,32(s1)
    800034b0:	37fd                	addiw	a5,a5,-1
    800034b2:	0007891b          	sext.w	s2,a5
    800034b6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800034b8:	50dc                	lw	a5,36(s1)
    800034ba:	e7b9                	bnez	a5,80003508 <end_op+0x7a>
    panic("log.committing");
  if(log.outstanding == 0){
    800034bc:	04091c63          	bnez	s2,80003514 <end_op+0x86>
    do_commit = 1;
    log.committing = 1;
    800034c0:	00014497          	auipc	s1,0x14
    800034c4:	5a848493          	addi	s1,s1,1448 # 80017a68 <log>
    800034c8:	4785                	li	a5,1
    800034ca:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800034cc:	8526                	mv	a0,s1
    800034ce:	758020ef          	jal	ra,80005c26 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800034d2:	54dc                	lw	a5,44(s1)
    800034d4:	04f04b63          	bgtz	a5,8000352a <end_op+0x9c>
    acquire(&log.lock);
    800034d8:	00014497          	auipc	s1,0x14
    800034dc:	59048493          	addi	s1,s1,1424 # 80017a68 <log>
    800034e0:	8526                	mv	a0,s1
    800034e2:	6ac020ef          	jal	ra,80005b8e <acquire>
    log.committing = 0;
    800034e6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800034ea:	8526                	mv	a0,s1
    800034ec:	bb2fe0ef          	jal	ra,8000189e <wakeup>
    release(&log.lock);
    800034f0:	8526                	mv	a0,s1
    800034f2:	734020ef          	jal	ra,80005c26 <release>
}
    800034f6:	70e2                	ld	ra,56(sp)
    800034f8:	7442                	ld	s0,48(sp)
    800034fa:	74a2                	ld	s1,40(sp)
    800034fc:	7902                	ld	s2,32(sp)
    800034fe:	69e2                	ld	s3,24(sp)
    80003500:	6a42                	ld	s4,16(sp)
    80003502:	6aa2                	ld	s5,8(sp)
    80003504:	6121                	addi	sp,sp,64
    80003506:	8082                	ret
    panic("log.committing");
    80003508:	00004517          	auipc	a0,0x4
    8000350c:	26050513          	addi	a0,a0,608 # 80007768 <syscalls+0x248>
    80003510:	362020ef          	jal	ra,80005872 <panic>
    wakeup(&log);
    80003514:	00014497          	auipc	s1,0x14
    80003518:	55448493          	addi	s1,s1,1364 # 80017a68 <log>
    8000351c:	8526                	mv	a0,s1
    8000351e:	b80fe0ef          	jal	ra,8000189e <wakeup>
  release(&log.lock);
    80003522:	8526                	mv	a0,s1
    80003524:	702020ef          	jal	ra,80005c26 <release>
  if(do_commit){
    80003528:	b7f9                	j	800034f6 <end_op+0x68>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000352a:	00014a97          	auipc	s5,0x14
    8000352e:	56ea8a93          	addi	s5,s5,1390 # 80017a98 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003532:	00014a17          	auipc	s4,0x14
    80003536:	536a0a13          	addi	s4,s4,1334 # 80017a68 <log>
    8000353a:	018a2583          	lw	a1,24(s4)
    8000353e:	012585bb          	addw	a1,a1,s2
    80003542:	2585                	addiw	a1,a1,1
    80003544:	028a2503          	lw	a0,40(s4)
    80003548:	f2ffe0ef          	jal	ra,80002476 <bread>
    8000354c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000354e:	000aa583          	lw	a1,0(s5)
    80003552:	028a2503          	lw	a0,40(s4)
    80003556:	f21fe0ef          	jal	ra,80002476 <bread>
    8000355a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000355c:	40000613          	li	a2,1024
    80003560:	05850593          	addi	a1,a0,88
    80003564:	05848513          	addi	a0,s1,88
    80003568:	d33fc0ef          	jal	ra,8000029a <memmove>
    bwrite(to);  // write the log
    8000356c:	8526                	mv	a0,s1
    8000356e:	fdffe0ef          	jal	ra,8000254c <bwrite>
    brelse(from);
    80003572:	854e                	mv	a0,s3
    80003574:	80aff0ef          	jal	ra,8000257e <brelse>
    brelse(to);
    80003578:	8526                	mv	a0,s1
    8000357a:	804ff0ef          	jal	ra,8000257e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000357e:	2905                	addiw	s2,s2,1
    80003580:	0a91                	addi	s5,s5,4
    80003582:	02ca2783          	lw	a5,44(s4)
    80003586:	faf94ae3          	blt	s2,a5,8000353a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000358a:	cefff0ef          	jal	ra,80003278 <write_head>
    install_trans(0); // Now install writes to home locations
    8000358e:	4501                	li	a0,0
    80003590:	d57ff0ef          	jal	ra,800032e6 <install_trans>
    log.lh.n = 0;
    80003594:	00014797          	auipc	a5,0x14
    80003598:	5007a023          	sw	zero,1280(a5) # 80017a94 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000359c:	cddff0ef          	jal	ra,80003278 <write_head>
    800035a0:	bf25                	j	800034d8 <end_op+0x4a>

00000000800035a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800035a2:	1101                	addi	sp,sp,-32
    800035a4:	ec06                	sd	ra,24(sp)
    800035a6:	e822                	sd	s0,16(sp)
    800035a8:	e426                	sd	s1,8(sp)
    800035aa:	e04a                	sd	s2,0(sp)
    800035ac:	1000                	addi	s0,sp,32
    800035ae:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800035b0:	00014917          	auipc	s2,0x14
    800035b4:	4b890913          	addi	s2,s2,1208 # 80017a68 <log>
    800035b8:	854a                	mv	a0,s2
    800035ba:	5d4020ef          	jal	ra,80005b8e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800035be:	02c92603          	lw	a2,44(s2)
    800035c2:	47f5                	li	a5,29
    800035c4:	06c7c363          	blt	a5,a2,8000362a <log_write+0x88>
    800035c8:	00014797          	auipc	a5,0x14
    800035cc:	4bc7a783          	lw	a5,1212(a5) # 80017a84 <log+0x1c>
    800035d0:	37fd                	addiw	a5,a5,-1
    800035d2:	04f65c63          	bge	a2,a5,8000362a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800035d6:	00014797          	auipc	a5,0x14
    800035da:	4b27a783          	lw	a5,1202(a5) # 80017a88 <log+0x20>
    800035de:	04f05c63          	blez	a5,80003636 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800035e2:	4781                	li	a5,0
    800035e4:	04c05f63          	blez	a2,80003642 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800035e8:	44cc                	lw	a1,12(s1)
    800035ea:	00014717          	auipc	a4,0x14
    800035ee:	4ae70713          	addi	a4,a4,1198 # 80017a98 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800035f2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800035f4:	4314                	lw	a3,0(a4)
    800035f6:	04b68663          	beq	a3,a1,80003642 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800035fa:	2785                	addiw	a5,a5,1
    800035fc:	0711                	addi	a4,a4,4
    800035fe:	fef61be3          	bne	a2,a5,800035f4 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003602:	0621                	addi	a2,a2,8
    80003604:	060a                	slli	a2,a2,0x2
    80003606:	00014797          	auipc	a5,0x14
    8000360a:	46278793          	addi	a5,a5,1122 # 80017a68 <log>
    8000360e:	963e                	add	a2,a2,a5
    80003610:	44dc                	lw	a5,12(s1)
    80003612:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003614:	8526                	mv	a0,s1
    80003616:	ff3fe0ef          	jal	ra,80002608 <bpin>
    log.lh.n++;
    8000361a:	00014717          	auipc	a4,0x14
    8000361e:	44e70713          	addi	a4,a4,1102 # 80017a68 <log>
    80003622:	575c                	lw	a5,44(a4)
    80003624:	2785                	addiw	a5,a5,1
    80003626:	d75c                	sw	a5,44(a4)
    80003628:	a815                	j	8000365c <log_write+0xba>
    panic("too big a transaction");
    8000362a:	00004517          	auipc	a0,0x4
    8000362e:	14e50513          	addi	a0,a0,334 # 80007778 <syscalls+0x258>
    80003632:	240020ef          	jal	ra,80005872 <panic>
    panic("log_write outside of trans");
    80003636:	00004517          	auipc	a0,0x4
    8000363a:	15a50513          	addi	a0,a0,346 # 80007790 <syscalls+0x270>
    8000363e:	234020ef          	jal	ra,80005872 <panic>
  log.lh.block[i] = b->blockno;
    80003642:	00878713          	addi	a4,a5,8
    80003646:	00271693          	slli	a3,a4,0x2
    8000364a:	00014717          	auipc	a4,0x14
    8000364e:	41e70713          	addi	a4,a4,1054 # 80017a68 <log>
    80003652:	9736                	add	a4,a4,a3
    80003654:	44d4                	lw	a3,12(s1)
    80003656:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003658:	faf60ee3          	beq	a2,a5,80003614 <log_write+0x72>
  }
  release(&log.lock);
    8000365c:	00014517          	auipc	a0,0x14
    80003660:	40c50513          	addi	a0,a0,1036 # 80017a68 <log>
    80003664:	5c2020ef          	jal	ra,80005c26 <release>
}
    80003668:	60e2                	ld	ra,24(sp)
    8000366a:	6442                	ld	s0,16(sp)
    8000366c:	64a2                	ld	s1,8(sp)
    8000366e:	6902                	ld	s2,0(sp)
    80003670:	6105                	addi	sp,sp,32
    80003672:	8082                	ret

0000000080003674 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003674:	1101                	addi	sp,sp,-32
    80003676:	ec06                	sd	ra,24(sp)
    80003678:	e822                	sd	s0,16(sp)
    8000367a:	e426                	sd	s1,8(sp)
    8000367c:	e04a                	sd	s2,0(sp)
    8000367e:	1000                	addi	s0,sp,32
    80003680:	84aa                	mv	s1,a0
    80003682:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003684:	00004597          	auipc	a1,0x4
    80003688:	12c58593          	addi	a1,a1,300 # 800077b0 <syscalls+0x290>
    8000368c:	0521                	addi	a0,a0,8
    8000368e:	480020ef          	jal	ra,80005b0e <initlock>
  lk->name = name;
    80003692:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003696:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000369a:	0204a423          	sw	zero,40(s1)
}
    8000369e:	60e2                	ld	ra,24(sp)
    800036a0:	6442                	ld	s0,16(sp)
    800036a2:	64a2                	ld	s1,8(sp)
    800036a4:	6902                	ld	s2,0(sp)
    800036a6:	6105                	addi	sp,sp,32
    800036a8:	8082                	ret

00000000800036aa <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800036aa:	1101                	addi	sp,sp,-32
    800036ac:	ec06                	sd	ra,24(sp)
    800036ae:	e822                	sd	s0,16(sp)
    800036b0:	e426                	sd	s1,8(sp)
    800036b2:	e04a                	sd	s2,0(sp)
    800036b4:	1000                	addi	s0,sp,32
    800036b6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800036b8:	00850913          	addi	s2,a0,8
    800036bc:	854a                	mv	a0,s2
    800036be:	4d0020ef          	jal	ra,80005b8e <acquire>
  while (lk->locked) {
    800036c2:	409c                	lw	a5,0(s1)
    800036c4:	c799                	beqz	a5,800036d2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800036c6:	85ca                	mv	a1,s2
    800036c8:	8526                	mv	a0,s1
    800036ca:	988fe0ef          	jal	ra,80001852 <sleep>
  while (lk->locked) {
    800036ce:	409c                	lw	a5,0(s1)
    800036d0:	fbfd                	bnez	a5,800036c6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800036d2:	4785                	li	a5,1
    800036d4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800036d6:	b0ffd0ef          	jal	ra,800011e4 <myproc>
    800036da:	591c                	lw	a5,48(a0)
    800036dc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800036de:	854a                	mv	a0,s2
    800036e0:	546020ef          	jal	ra,80005c26 <release>
}
    800036e4:	60e2                	ld	ra,24(sp)
    800036e6:	6442                	ld	s0,16(sp)
    800036e8:	64a2                	ld	s1,8(sp)
    800036ea:	6902                	ld	s2,0(sp)
    800036ec:	6105                	addi	sp,sp,32
    800036ee:	8082                	ret

00000000800036f0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800036f0:	1101                	addi	sp,sp,-32
    800036f2:	ec06                	sd	ra,24(sp)
    800036f4:	e822                	sd	s0,16(sp)
    800036f6:	e426                	sd	s1,8(sp)
    800036f8:	e04a                	sd	s2,0(sp)
    800036fa:	1000                	addi	s0,sp,32
    800036fc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800036fe:	00850913          	addi	s2,a0,8
    80003702:	854a                	mv	a0,s2
    80003704:	48a020ef          	jal	ra,80005b8e <acquire>
  lk->locked = 0;
    80003708:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000370c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003710:	8526                	mv	a0,s1
    80003712:	98cfe0ef          	jal	ra,8000189e <wakeup>
  release(&lk->lk);
    80003716:	854a                	mv	a0,s2
    80003718:	50e020ef          	jal	ra,80005c26 <release>
}
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	64a2                	ld	s1,8(sp)
    80003722:	6902                	ld	s2,0(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret

0000000080003728 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003728:	7179                	addi	sp,sp,-48
    8000372a:	f406                	sd	ra,40(sp)
    8000372c:	f022                	sd	s0,32(sp)
    8000372e:	ec26                	sd	s1,24(sp)
    80003730:	e84a                	sd	s2,16(sp)
    80003732:	e44e                	sd	s3,8(sp)
    80003734:	1800                	addi	s0,sp,48
    80003736:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003738:	00850913          	addi	s2,a0,8
    8000373c:	854a                	mv	a0,s2
    8000373e:	450020ef          	jal	ra,80005b8e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003742:	409c                	lw	a5,0(s1)
    80003744:	ef89                	bnez	a5,8000375e <holdingsleep+0x36>
    80003746:	4481                	li	s1,0
  release(&lk->lk);
    80003748:	854a                	mv	a0,s2
    8000374a:	4dc020ef          	jal	ra,80005c26 <release>
  return r;
}
    8000374e:	8526                	mv	a0,s1
    80003750:	70a2                	ld	ra,40(sp)
    80003752:	7402                	ld	s0,32(sp)
    80003754:	64e2                	ld	s1,24(sp)
    80003756:	6942                	ld	s2,16(sp)
    80003758:	69a2                	ld	s3,8(sp)
    8000375a:	6145                	addi	sp,sp,48
    8000375c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000375e:	0284a983          	lw	s3,40(s1)
    80003762:	a83fd0ef          	jal	ra,800011e4 <myproc>
    80003766:	5904                	lw	s1,48(a0)
    80003768:	413484b3          	sub	s1,s1,s3
    8000376c:	0014b493          	seqz	s1,s1
    80003770:	bfe1                	j	80003748 <holdingsleep+0x20>

0000000080003772 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003772:	1141                	addi	sp,sp,-16
    80003774:	e406                	sd	ra,8(sp)
    80003776:	e022                	sd	s0,0(sp)
    80003778:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000377a:	00004597          	auipc	a1,0x4
    8000377e:	04658593          	addi	a1,a1,70 # 800077c0 <syscalls+0x2a0>
    80003782:	00014517          	auipc	a0,0x14
    80003786:	42e50513          	addi	a0,a0,1070 # 80017bb0 <ftable>
    8000378a:	384020ef          	jal	ra,80005b0e <initlock>
}
    8000378e:	60a2                	ld	ra,8(sp)
    80003790:	6402                	ld	s0,0(sp)
    80003792:	0141                	addi	sp,sp,16
    80003794:	8082                	ret

0000000080003796 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003796:	1101                	addi	sp,sp,-32
    80003798:	ec06                	sd	ra,24(sp)
    8000379a:	e822                	sd	s0,16(sp)
    8000379c:	e426                	sd	s1,8(sp)
    8000379e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800037a0:	00014517          	auipc	a0,0x14
    800037a4:	41050513          	addi	a0,a0,1040 # 80017bb0 <ftable>
    800037a8:	3e6020ef          	jal	ra,80005b8e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800037ac:	00014497          	auipc	s1,0x14
    800037b0:	41c48493          	addi	s1,s1,1052 # 80017bc8 <ftable+0x18>
    800037b4:	00015717          	auipc	a4,0x15
    800037b8:	3b470713          	addi	a4,a4,948 # 80018b68 <disk>
    if(f->ref == 0){
    800037bc:	40dc                	lw	a5,4(s1)
    800037be:	cf89                	beqz	a5,800037d8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800037c0:	02848493          	addi	s1,s1,40
    800037c4:	fee49ce3          	bne	s1,a4,800037bc <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800037c8:	00014517          	auipc	a0,0x14
    800037cc:	3e850513          	addi	a0,a0,1000 # 80017bb0 <ftable>
    800037d0:	456020ef          	jal	ra,80005c26 <release>
  return 0;
    800037d4:	4481                	li	s1,0
    800037d6:	a809                	j	800037e8 <filealloc+0x52>
      f->ref = 1;
    800037d8:	4785                	li	a5,1
    800037da:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800037dc:	00014517          	auipc	a0,0x14
    800037e0:	3d450513          	addi	a0,a0,980 # 80017bb0 <ftable>
    800037e4:	442020ef          	jal	ra,80005c26 <release>
}
    800037e8:	8526                	mv	a0,s1
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6105                	addi	sp,sp,32
    800037f2:	8082                	ret

00000000800037f4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800037f4:	1101                	addi	sp,sp,-32
    800037f6:	ec06                	sd	ra,24(sp)
    800037f8:	e822                	sd	s0,16(sp)
    800037fa:	e426                	sd	s1,8(sp)
    800037fc:	1000                	addi	s0,sp,32
    800037fe:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003800:	00014517          	auipc	a0,0x14
    80003804:	3b050513          	addi	a0,a0,944 # 80017bb0 <ftable>
    80003808:	386020ef          	jal	ra,80005b8e <acquire>
  if(f->ref < 1)
    8000380c:	40dc                	lw	a5,4(s1)
    8000380e:	02f05063          	blez	a5,8000382e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003812:	2785                	addiw	a5,a5,1
    80003814:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003816:	00014517          	auipc	a0,0x14
    8000381a:	39a50513          	addi	a0,a0,922 # 80017bb0 <ftable>
    8000381e:	408020ef          	jal	ra,80005c26 <release>
  return f;
}
    80003822:	8526                	mv	a0,s1
    80003824:	60e2                	ld	ra,24(sp)
    80003826:	6442                	ld	s0,16(sp)
    80003828:	64a2                	ld	s1,8(sp)
    8000382a:	6105                	addi	sp,sp,32
    8000382c:	8082                	ret
    panic("filedup");
    8000382e:	00004517          	auipc	a0,0x4
    80003832:	f9a50513          	addi	a0,a0,-102 # 800077c8 <syscalls+0x2a8>
    80003836:	03c020ef          	jal	ra,80005872 <panic>

000000008000383a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000383a:	7139                	addi	sp,sp,-64
    8000383c:	fc06                	sd	ra,56(sp)
    8000383e:	f822                	sd	s0,48(sp)
    80003840:	f426                	sd	s1,40(sp)
    80003842:	f04a                	sd	s2,32(sp)
    80003844:	ec4e                	sd	s3,24(sp)
    80003846:	e852                	sd	s4,16(sp)
    80003848:	e456                	sd	s5,8(sp)
    8000384a:	0080                	addi	s0,sp,64
    8000384c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000384e:	00014517          	auipc	a0,0x14
    80003852:	36250513          	addi	a0,a0,866 # 80017bb0 <ftable>
    80003856:	338020ef          	jal	ra,80005b8e <acquire>
  if(f->ref < 1)
    8000385a:	40dc                	lw	a5,4(s1)
    8000385c:	04f05963          	blez	a5,800038ae <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003860:	37fd                	addiw	a5,a5,-1
    80003862:	0007871b          	sext.w	a4,a5
    80003866:	c0dc                	sw	a5,4(s1)
    80003868:	04e04963          	bgtz	a4,800038ba <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000386c:	0004a903          	lw	s2,0(s1)
    80003870:	0094ca83          	lbu	s5,9(s1)
    80003874:	0104ba03          	ld	s4,16(s1)
    80003878:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000387c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003880:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003884:	00014517          	auipc	a0,0x14
    80003888:	32c50513          	addi	a0,a0,812 # 80017bb0 <ftable>
    8000388c:	39a020ef          	jal	ra,80005c26 <release>

  if(ff.type == FD_PIPE){
    80003890:	4785                	li	a5,1
    80003892:	04f90363          	beq	s2,a5,800038d8 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003896:	3979                	addiw	s2,s2,-2
    80003898:	4785                	li	a5,1
    8000389a:	0327e663          	bltu	a5,s2,800038c6 <fileclose+0x8c>
    begin_op();
    8000389e:	b81ff0ef          	jal	ra,8000341e <begin_op>
    iput(ff.ip);
    800038a2:	854e                	mv	a0,s3
    800038a4:	c6eff0ef          	jal	ra,80002d12 <iput>
    end_op();
    800038a8:	be7ff0ef          	jal	ra,8000348e <end_op>
    800038ac:	a829                	j	800038c6 <fileclose+0x8c>
    panic("fileclose");
    800038ae:	00004517          	auipc	a0,0x4
    800038b2:	f2250513          	addi	a0,a0,-222 # 800077d0 <syscalls+0x2b0>
    800038b6:	7bd010ef          	jal	ra,80005872 <panic>
    release(&ftable.lock);
    800038ba:	00014517          	auipc	a0,0x14
    800038be:	2f650513          	addi	a0,a0,758 # 80017bb0 <ftable>
    800038c2:	364020ef          	jal	ra,80005c26 <release>
  }
}
    800038c6:	70e2                	ld	ra,56(sp)
    800038c8:	7442                	ld	s0,48(sp)
    800038ca:	74a2                	ld	s1,40(sp)
    800038cc:	7902                	ld	s2,32(sp)
    800038ce:	69e2                	ld	s3,24(sp)
    800038d0:	6a42                	ld	s4,16(sp)
    800038d2:	6aa2                	ld	s5,8(sp)
    800038d4:	6121                	addi	sp,sp,64
    800038d6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800038d8:	85d6                	mv	a1,s5
    800038da:	8552                	mv	a0,s4
    800038dc:	2ec000ef          	jal	ra,80003bc8 <pipeclose>
    800038e0:	b7dd                	j	800038c6 <fileclose+0x8c>

00000000800038e2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800038e2:	715d                	addi	sp,sp,-80
    800038e4:	e486                	sd	ra,72(sp)
    800038e6:	e0a2                	sd	s0,64(sp)
    800038e8:	fc26                	sd	s1,56(sp)
    800038ea:	f84a                	sd	s2,48(sp)
    800038ec:	f44e                	sd	s3,40(sp)
    800038ee:	0880                	addi	s0,sp,80
    800038f0:	84aa                	mv	s1,a0
    800038f2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800038f4:	8f1fd0ef          	jal	ra,800011e4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800038f8:	409c                	lw	a5,0(s1)
    800038fa:	37f9                	addiw	a5,a5,-2
    800038fc:	4705                	li	a4,1
    800038fe:	02f76f63          	bltu	a4,a5,8000393c <filestat+0x5a>
    80003902:	892a                	mv	s2,a0
    ilock(f->ip);
    80003904:	6c88                	ld	a0,24(s1)
    80003906:	a8eff0ef          	jal	ra,80002b94 <ilock>
    stati(f->ip, &st);
    8000390a:	fb840593          	addi	a1,s0,-72
    8000390e:	6c88                	ld	a0,24(s1)
    80003910:	caaff0ef          	jal	ra,80002dba <stati>
    iunlock(f->ip);
    80003914:	6c88                	ld	a0,24(s1)
    80003916:	b28ff0ef          	jal	ra,80002c3e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000391a:	46e1                	li	a3,24
    8000391c:	fb840613          	addi	a2,s0,-72
    80003920:	85ce                	mv	a1,s3
    80003922:	05093503          	ld	a0,80(s2)
    80003926:	d36fd0ef          	jal	ra,80000e5c <copyout>
    8000392a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000392e:	60a6                	ld	ra,72(sp)
    80003930:	6406                	ld	s0,64(sp)
    80003932:	74e2                	ld	s1,56(sp)
    80003934:	7942                	ld	s2,48(sp)
    80003936:	79a2                	ld	s3,40(sp)
    80003938:	6161                	addi	sp,sp,80
    8000393a:	8082                	ret
  return -1;
    8000393c:	557d                	li	a0,-1
    8000393e:	bfc5                	j	8000392e <filestat+0x4c>

0000000080003940 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003940:	7179                	addi	sp,sp,-48
    80003942:	f406                	sd	ra,40(sp)
    80003944:	f022                	sd	s0,32(sp)
    80003946:	ec26                	sd	s1,24(sp)
    80003948:	e84a                	sd	s2,16(sp)
    8000394a:	e44e                	sd	s3,8(sp)
    8000394c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000394e:	00854783          	lbu	a5,8(a0)
    80003952:	cbc1                	beqz	a5,800039e2 <fileread+0xa2>
    80003954:	84aa                	mv	s1,a0
    80003956:	89ae                	mv	s3,a1
    80003958:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000395a:	411c                	lw	a5,0(a0)
    8000395c:	4705                	li	a4,1
    8000395e:	04e78363          	beq	a5,a4,800039a4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003962:	470d                	li	a4,3
    80003964:	04e78563          	beq	a5,a4,800039ae <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003968:	4709                	li	a4,2
    8000396a:	06e79663          	bne	a5,a4,800039d6 <fileread+0x96>
    ilock(f->ip);
    8000396e:	6d08                	ld	a0,24(a0)
    80003970:	a24ff0ef          	jal	ra,80002b94 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003974:	874a                	mv	a4,s2
    80003976:	5094                	lw	a3,32(s1)
    80003978:	864e                	mv	a2,s3
    8000397a:	4585                	li	a1,1
    8000397c:	6c88                	ld	a0,24(s1)
    8000397e:	c66ff0ef          	jal	ra,80002de4 <readi>
    80003982:	892a                	mv	s2,a0
    80003984:	00a05563          	blez	a0,8000398e <fileread+0x4e>
      f->off += r;
    80003988:	509c                	lw	a5,32(s1)
    8000398a:	9fa9                	addw	a5,a5,a0
    8000398c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000398e:	6c88                	ld	a0,24(s1)
    80003990:	aaeff0ef          	jal	ra,80002c3e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003994:	854a                	mv	a0,s2
    80003996:	70a2                	ld	ra,40(sp)
    80003998:	7402                	ld	s0,32(sp)
    8000399a:	64e2                	ld	s1,24(sp)
    8000399c:	6942                	ld	s2,16(sp)
    8000399e:	69a2                	ld	s3,8(sp)
    800039a0:	6145                	addi	sp,sp,48
    800039a2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800039a4:	6908                	ld	a0,16(a0)
    800039a6:	356000ef          	jal	ra,80003cfc <piperead>
    800039aa:	892a                	mv	s2,a0
    800039ac:	b7e5                	j	80003994 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800039ae:	02451783          	lh	a5,36(a0)
    800039b2:	03079693          	slli	a3,a5,0x30
    800039b6:	92c1                	srli	a3,a3,0x30
    800039b8:	4725                	li	a4,9
    800039ba:	02d76663          	bltu	a4,a3,800039e6 <fileread+0xa6>
    800039be:	0792                	slli	a5,a5,0x4
    800039c0:	00014717          	auipc	a4,0x14
    800039c4:	15070713          	addi	a4,a4,336 # 80017b10 <devsw>
    800039c8:	97ba                	add	a5,a5,a4
    800039ca:	639c                	ld	a5,0(a5)
    800039cc:	cf99                	beqz	a5,800039ea <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800039ce:	4505                	li	a0,1
    800039d0:	9782                	jalr	a5
    800039d2:	892a                	mv	s2,a0
    800039d4:	b7c1                	j	80003994 <fileread+0x54>
    panic("fileread");
    800039d6:	00004517          	auipc	a0,0x4
    800039da:	e0a50513          	addi	a0,a0,-502 # 800077e0 <syscalls+0x2c0>
    800039de:	695010ef          	jal	ra,80005872 <panic>
    return -1;
    800039e2:	597d                	li	s2,-1
    800039e4:	bf45                	j	80003994 <fileread+0x54>
      return -1;
    800039e6:	597d                	li	s2,-1
    800039e8:	b775                	j	80003994 <fileread+0x54>
    800039ea:	597d                	li	s2,-1
    800039ec:	b765                	j	80003994 <fileread+0x54>

00000000800039ee <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800039ee:	715d                	addi	sp,sp,-80
    800039f0:	e486                	sd	ra,72(sp)
    800039f2:	e0a2                	sd	s0,64(sp)
    800039f4:	fc26                	sd	s1,56(sp)
    800039f6:	f84a                	sd	s2,48(sp)
    800039f8:	f44e                	sd	s3,40(sp)
    800039fa:	f052                	sd	s4,32(sp)
    800039fc:	ec56                	sd	s5,24(sp)
    800039fe:	e85a                	sd	s6,16(sp)
    80003a00:	e45e                	sd	s7,8(sp)
    80003a02:	e062                	sd	s8,0(sp)
    80003a04:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003a06:	00954783          	lbu	a5,9(a0)
    80003a0a:	0e078863          	beqz	a5,80003afa <filewrite+0x10c>
    80003a0e:	892a                	mv	s2,a0
    80003a10:	8aae                	mv	s5,a1
    80003a12:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003a14:	411c                	lw	a5,0(a0)
    80003a16:	4705                	li	a4,1
    80003a18:	02e78263          	beq	a5,a4,80003a3c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003a1c:	470d                	li	a4,3
    80003a1e:	02e78463          	beq	a5,a4,80003a46 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003a22:	4709                	li	a4,2
    80003a24:	0ce79563          	bne	a5,a4,80003aee <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003a28:	0ac05163          	blez	a2,80003aca <filewrite+0xdc>
    int i = 0;
    80003a2c:	4981                	li	s3,0
    80003a2e:	6b05                	lui	s6,0x1
    80003a30:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003a34:	6b85                	lui	s7,0x1
    80003a36:	c00b8b9b          	addiw	s7,s7,-1024
    80003a3a:	a041                	j	80003aba <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003a3c:	6908                	ld	a0,16(a0)
    80003a3e:	1e2000ef          	jal	ra,80003c20 <pipewrite>
    80003a42:	8a2a                	mv	s4,a0
    80003a44:	a071                	j	80003ad0 <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003a46:	02451783          	lh	a5,36(a0)
    80003a4a:	03079693          	slli	a3,a5,0x30
    80003a4e:	92c1                	srli	a3,a3,0x30
    80003a50:	4725                	li	a4,9
    80003a52:	0ad76663          	bltu	a4,a3,80003afe <filewrite+0x110>
    80003a56:	0792                	slli	a5,a5,0x4
    80003a58:	00014717          	auipc	a4,0x14
    80003a5c:	0b870713          	addi	a4,a4,184 # 80017b10 <devsw>
    80003a60:	97ba                	add	a5,a5,a4
    80003a62:	679c                	ld	a5,8(a5)
    80003a64:	cfd9                	beqz	a5,80003b02 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003a66:	4505                	li	a0,1
    80003a68:	9782                	jalr	a5
    80003a6a:	8a2a                	mv	s4,a0
    80003a6c:	a095                	j	80003ad0 <filewrite+0xe2>
    80003a6e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003a72:	9adff0ef          	jal	ra,8000341e <begin_op>
      ilock(f->ip);
    80003a76:	01893503          	ld	a0,24(s2)
    80003a7a:	91aff0ef          	jal	ra,80002b94 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003a7e:	8762                	mv	a4,s8
    80003a80:	02092683          	lw	a3,32(s2)
    80003a84:	01598633          	add	a2,s3,s5
    80003a88:	4585                	li	a1,1
    80003a8a:	01893503          	ld	a0,24(s2)
    80003a8e:	c3aff0ef          	jal	ra,80002ec8 <writei>
    80003a92:	84aa                	mv	s1,a0
    80003a94:	00a05763          	blez	a0,80003aa2 <filewrite+0xb4>
        f->off += r;
    80003a98:	02092783          	lw	a5,32(s2)
    80003a9c:	9fa9                	addw	a5,a5,a0
    80003a9e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003aa2:	01893503          	ld	a0,24(s2)
    80003aa6:	998ff0ef          	jal	ra,80002c3e <iunlock>
      end_op();
    80003aaa:	9e5ff0ef          	jal	ra,8000348e <end_op>

      if(r != n1){
    80003aae:	009c1f63          	bne	s8,s1,80003acc <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    80003ab2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003ab6:	0149db63          	bge	s3,s4,80003acc <filewrite+0xde>
      int n1 = n - i;
    80003aba:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003abe:	84be                	mv	s1,a5
    80003ac0:	2781                	sext.w	a5,a5
    80003ac2:	fafb56e3          	bge	s6,a5,80003a6e <filewrite+0x80>
    80003ac6:	84de                	mv	s1,s7
    80003ac8:	b75d                	j	80003a6e <filewrite+0x80>
    int i = 0;
    80003aca:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003acc:	013a1f63          	bne	s4,s3,80003aea <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003ad0:	8552                	mv	a0,s4
    80003ad2:	60a6                	ld	ra,72(sp)
    80003ad4:	6406                	ld	s0,64(sp)
    80003ad6:	74e2                	ld	s1,56(sp)
    80003ad8:	7942                	ld	s2,48(sp)
    80003ada:	79a2                	ld	s3,40(sp)
    80003adc:	7a02                	ld	s4,32(sp)
    80003ade:	6ae2                	ld	s5,24(sp)
    80003ae0:	6b42                	ld	s6,16(sp)
    80003ae2:	6ba2                	ld	s7,8(sp)
    80003ae4:	6c02                	ld	s8,0(sp)
    80003ae6:	6161                	addi	sp,sp,80
    80003ae8:	8082                	ret
    ret = (i == n ? n : -1);
    80003aea:	5a7d                	li	s4,-1
    80003aec:	b7d5                	j	80003ad0 <filewrite+0xe2>
    panic("filewrite");
    80003aee:	00004517          	auipc	a0,0x4
    80003af2:	d0250513          	addi	a0,a0,-766 # 800077f0 <syscalls+0x2d0>
    80003af6:	57d010ef          	jal	ra,80005872 <panic>
    return -1;
    80003afa:	5a7d                	li	s4,-1
    80003afc:	bfd1                	j	80003ad0 <filewrite+0xe2>
      return -1;
    80003afe:	5a7d                	li	s4,-1
    80003b00:	bfc1                	j	80003ad0 <filewrite+0xe2>
    80003b02:	5a7d                	li	s4,-1
    80003b04:	b7f1                	j	80003ad0 <filewrite+0xe2>

0000000080003b06 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003b06:	7179                	addi	sp,sp,-48
    80003b08:	f406                	sd	ra,40(sp)
    80003b0a:	f022                	sd	s0,32(sp)
    80003b0c:	ec26                	sd	s1,24(sp)
    80003b0e:	e84a                	sd	s2,16(sp)
    80003b10:	e44e                	sd	s3,8(sp)
    80003b12:	e052                	sd	s4,0(sp)
    80003b14:	1800                	addi	s0,sp,48
    80003b16:	84aa                	mv	s1,a0
    80003b18:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003b1a:	0005b023          	sd	zero,0(a1)
    80003b1e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003b22:	c75ff0ef          	jal	ra,80003796 <filealloc>
    80003b26:	e088                	sd	a0,0(s1)
    80003b28:	cd35                	beqz	a0,80003ba4 <pipealloc+0x9e>
    80003b2a:	c6dff0ef          	jal	ra,80003796 <filealloc>
    80003b2e:	00aa3023          	sd	a0,0(s4)
    80003b32:	c52d                	beqz	a0,80003b9c <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003b34:	d4efc0ef          	jal	ra,80000082 <kalloc>
    80003b38:	892a                	mv	s2,a0
    80003b3a:	cd31                	beqz	a0,80003b96 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80003b3c:	4985                	li	s3,1
    80003b3e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003b42:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003b46:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003b4a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003b4e:	00004597          	auipc	a1,0x4
    80003b52:	cb258593          	addi	a1,a1,-846 # 80007800 <syscalls+0x2e0>
    80003b56:	7b9010ef          	jal	ra,80005b0e <initlock>
  (*f0)->type = FD_PIPE;
    80003b5a:	609c                	ld	a5,0(s1)
    80003b5c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003b60:	609c                	ld	a5,0(s1)
    80003b62:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003b66:	609c                	ld	a5,0(s1)
    80003b68:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003b6c:	609c                	ld	a5,0(s1)
    80003b6e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003b72:	000a3783          	ld	a5,0(s4)
    80003b76:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003b7a:	000a3783          	ld	a5,0(s4)
    80003b7e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003b82:	000a3783          	ld	a5,0(s4)
    80003b86:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003b8a:	000a3783          	ld	a5,0(s4)
    80003b8e:	0127b823          	sd	s2,16(a5)
  return 0;
    80003b92:	4501                	li	a0,0
    80003b94:	a005                	j	80003bb4 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003b96:	6088                	ld	a0,0(s1)
    80003b98:	e501                	bnez	a0,80003ba0 <pipealloc+0x9a>
    80003b9a:	a029                	j	80003ba4 <pipealloc+0x9e>
    80003b9c:	6088                	ld	a0,0(s1)
    80003b9e:	c11d                	beqz	a0,80003bc4 <pipealloc+0xbe>
    fileclose(*f0);
    80003ba0:	c9bff0ef          	jal	ra,8000383a <fileclose>
  if(*f1)
    80003ba4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003ba8:	557d                	li	a0,-1
  if(*f1)
    80003baa:	c789                	beqz	a5,80003bb4 <pipealloc+0xae>
    fileclose(*f1);
    80003bac:	853e                	mv	a0,a5
    80003bae:	c8dff0ef          	jal	ra,8000383a <fileclose>
  return -1;
    80003bb2:	557d                	li	a0,-1
}
    80003bb4:	70a2                	ld	ra,40(sp)
    80003bb6:	7402                	ld	s0,32(sp)
    80003bb8:	64e2                	ld	s1,24(sp)
    80003bba:	6942                	ld	s2,16(sp)
    80003bbc:	69a2                	ld	s3,8(sp)
    80003bbe:	6a02                	ld	s4,0(sp)
    80003bc0:	6145                	addi	sp,sp,48
    80003bc2:	8082                	ret
  return -1;
    80003bc4:	557d                	li	a0,-1
    80003bc6:	b7fd                	j	80003bb4 <pipealloc+0xae>

0000000080003bc8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003bc8:	1101                	addi	sp,sp,-32
    80003bca:	ec06                	sd	ra,24(sp)
    80003bcc:	e822                	sd	s0,16(sp)
    80003bce:	e426                	sd	s1,8(sp)
    80003bd0:	e04a                	sd	s2,0(sp)
    80003bd2:	1000                	addi	s0,sp,32
    80003bd4:	84aa                	mv	s1,a0
    80003bd6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003bd8:	7b7010ef          	jal	ra,80005b8e <acquire>
  if(writable){
    80003bdc:	02090763          	beqz	s2,80003c0a <pipeclose+0x42>
    pi->writeopen = 0;
    80003be0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003be4:	21848513          	addi	a0,s1,536
    80003be8:	cb7fd0ef          	jal	ra,8000189e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003bec:	2204b783          	ld	a5,544(s1)
    80003bf0:	e785                	bnez	a5,80003c18 <pipeclose+0x50>
    release(&pi->lock);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	032020ef          	jal	ra,80005c26 <release>
    kfree((char*)pi);
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	c22fc0ef          	jal	ra,8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003bfe:	60e2                	ld	ra,24(sp)
    80003c00:	6442                	ld	s0,16(sp)
    80003c02:	64a2                	ld	s1,8(sp)
    80003c04:	6902                	ld	s2,0(sp)
    80003c06:	6105                	addi	sp,sp,32
    80003c08:	8082                	ret
    pi->readopen = 0;
    80003c0a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003c0e:	21c48513          	addi	a0,s1,540
    80003c12:	c8dfd0ef          	jal	ra,8000189e <wakeup>
    80003c16:	bfd9                	j	80003bec <pipeclose+0x24>
    release(&pi->lock);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	00c020ef          	jal	ra,80005c26 <release>
}
    80003c1e:	b7c5                	j	80003bfe <pipeclose+0x36>

0000000080003c20 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003c20:	7159                	addi	sp,sp,-112
    80003c22:	f486                	sd	ra,104(sp)
    80003c24:	f0a2                	sd	s0,96(sp)
    80003c26:	eca6                	sd	s1,88(sp)
    80003c28:	e8ca                	sd	s2,80(sp)
    80003c2a:	e4ce                	sd	s3,72(sp)
    80003c2c:	e0d2                	sd	s4,64(sp)
    80003c2e:	fc56                	sd	s5,56(sp)
    80003c30:	f85a                	sd	s6,48(sp)
    80003c32:	f45e                	sd	s7,40(sp)
    80003c34:	f062                	sd	s8,32(sp)
    80003c36:	ec66                	sd	s9,24(sp)
    80003c38:	1880                	addi	s0,sp,112
    80003c3a:	84aa                	mv	s1,a0
    80003c3c:	8aae                	mv	s5,a1
    80003c3e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003c40:	da4fd0ef          	jal	ra,800011e4 <myproc>
    80003c44:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003c46:	8526                	mv	a0,s1
    80003c48:	747010ef          	jal	ra,80005b8e <acquire>
  while(i < n){
    80003c4c:	0b405663          	blez	s4,80003cf8 <pipewrite+0xd8>
    80003c50:	8ba6                	mv	s7,s1
  int i = 0;
    80003c52:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003c54:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003c56:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003c5a:	21c48c13          	addi	s8,s1,540
    80003c5e:	a899                	j	80003cb4 <pipewrite+0x94>
      release(&pi->lock);
    80003c60:	8526                	mv	a0,s1
    80003c62:	7c5010ef          	jal	ra,80005c26 <release>
      return -1;
    80003c66:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003c68:	854a                	mv	a0,s2
    80003c6a:	70a6                	ld	ra,104(sp)
    80003c6c:	7406                	ld	s0,96(sp)
    80003c6e:	64e6                	ld	s1,88(sp)
    80003c70:	6946                	ld	s2,80(sp)
    80003c72:	69a6                	ld	s3,72(sp)
    80003c74:	6a06                	ld	s4,64(sp)
    80003c76:	7ae2                	ld	s5,56(sp)
    80003c78:	7b42                	ld	s6,48(sp)
    80003c7a:	7ba2                	ld	s7,40(sp)
    80003c7c:	7c02                	ld	s8,32(sp)
    80003c7e:	6ce2                	ld	s9,24(sp)
    80003c80:	6165                	addi	sp,sp,112
    80003c82:	8082                	ret
      wakeup(&pi->nread);
    80003c84:	8566                	mv	a0,s9
    80003c86:	c19fd0ef          	jal	ra,8000189e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003c8a:	85de                	mv	a1,s7
    80003c8c:	8562                	mv	a0,s8
    80003c8e:	bc5fd0ef          	jal	ra,80001852 <sleep>
    80003c92:	a839                	j	80003cb0 <pipewrite+0x90>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003c94:	21c4a783          	lw	a5,540(s1)
    80003c98:	0017871b          	addiw	a4,a5,1
    80003c9c:	20e4ae23          	sw	a4,540(s1)
    80003ca0:	1ff7f793          	andi	a5,a5,511
    80003ca4:	97a6                	add	a5,a5,s1
    80003ca6:	f9f44703          	lbu	a4,-97(s0)
    80003caa:	00e78c23          	sb	a4,24(a5)
      i++;
    80003cae:	2905                	addiw	s2,s2,1
  while(i < n){
    80003cb0:	03495c63          	bge	s2,s4,80003ce8 <pipewrite+0xc8>
    if(pi->readopen == 0 || killed(pr)){
    80003cb4:	2204a783          	lw	a5,544(s1)
    80003cb8:	d7c5                	beqz	a5,80003c60 <pipewrite+0x40>
    80003cba:	854e                	mv	a0,s3
    80003cbc:	dcffd0ef          	jal	ra,80001a8a <killed>
    80003cc0:	f145                	bnez	a0,80003c60 <pipewrite+0x40>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003cc2:	2184a783          	lw	a5,536(s1)
    80003cc6:	21c4a703          	lw	a4,540(s1)
    80003cca:	2007879b          	addiw	a5,a5,512
    80003cce:	faf70be3          	beq	a4,a5,80003c84 <pipewrite+0x64>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003cd2:	4685                	li	a3,1
    80003cd4:	01590633          	add	a2,s2,s5
    80003cd8:	f9f40593          	addi	a1,s0,-97
    80003cdc:	0509b503          	ld	a0,80(s3)
    80003ce0:	a34fd0ef          	jal	ra,80000f14 <copyin>
    80003ce4:	fb6518e3          	bne	a0,s6,80003c94 <pipewrite+0x74>
  wakeup(&pi->nread);
    80003ce8:	21848513          	addi	a0,s1,536
    80003cec:	bb3fd0ef          	jal	ra,8000189e <wakeup>
  release(&pi->lock);
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	735010ef          	jal	ra,80005c26 <release>
  return i;
    80003cf6:	bf8d                	j	80003c68 <pipewrite+0x48>
  int i = 0;
    80003cf8:	4901                	li	s2,0
    80003cfa:	b7fd                	j	80003ce8 <pipewrite+0xc8>

0000000080003cfc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003cfc:	715d                	addi	sp,sp,-80
    80003cfe:	e486                	sd	ra,72(sp)
    80003d00:	e0a2                	sd	s0,64(sp)
    80003d02:	fc26                	sd	s1,56(sp)
    80003d04:	f84a                	sd	s2,48(sp)
    80003d06:	f44e                	sd	s3,40(sp)
    80003d08:	f052                	sd	s4,32(sp)
    80003d0a:	ec56                	sd	s5,24(sp)
    80003d0c:	e85a                	sd	s6,16(sp)
    80003d0e:	0880                	addi	s0,sp,80
    80003d10:	84aa                	mv	s1,a0
    80003d12:	892e                	mv	s2,a1
    80003d14:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003d16:	ccefd0ef          	jal	ra,800011e4 <myproc>
    80003d1a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003d1c:	8b26                	mv	s6,s1
    80003d1e:	8526                	mv	a0,s1
    80003d20:	66f010ef          	jal	ra,80005b8e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003d24:	2184a703          	lw	a4,536(s1)
    80003d28:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003d2c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003d30:	02f71363          	bne	a4,a5,80003d56 <piperead+0x5a>
    80003d34:	2244a783          	lw	a5,548(s1)
    80003d38:	cf99                	beqz	a5,80003d56 <piperead+0x5a>
    if(killed(pr)){
    80003d3a:	8552                	mv	a0,s4
    80003d3c:	d4ffd0ef          	jal	ra,80001a8a <killed>
    80003d40:	e141                	bnez	a0,80003dc0 <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003d42:	85da                	mv	a1,s6
    80003d44:	854e                	mv	a0,s3
    80003d46:	b0dfd0ef          	jal	ra,80001852 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003d4a:	2184a703          	lw	a4,536(s1)
    80003d4e:	21c4a783          	lw	a5,540(s1)
    80003d52:	fef701e3          	beq	a4,a5,80003d34 <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003d56:	07505a63          	blez	s5,80003dca <piperead+0xce>
    80003d5a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003d5c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80003d5e:	2184a783          	lw	a5,536(s1)
    80003d62:	21c4a703          	lw	a4,540(s1)
    80003d66:	02f70b63          	beq	a4,a5,80003d9c <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003d6a:	0017871b          	addiw	a4,a5,1
    80003d6e:	20e4ac23          	sw	a4,536(s1)
    80003d72:	1ff7f793          	andi	a5,a5,511
    80003d76:	97a6                	add	a5,a5,s1
    80003d78:	0187c783          	lbu	a5,24(a5)
    80003d7c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003d80:	4685                	li	a3,1
    80003d82:	fbf40613          	addi	a2,s0,-65
    80003d86:	85ca                	mv	a1,s2
    80003d88:	050a3503          	ld	a0,80(s4)
    80003d8c:	8d0fd0ef          	jal	ra,80000e5c <copyout>
    80003d90:	01650663          	beq	a0,s6,80003d9c <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003d94:	2985                	addiw	s3,s3,1
    80003d96:	0905                	addi	s2,s2,1
    80003d98:	fd3a93e3          	bne	s5,s3,80003d5e <piperead+0x62>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003d9c:	21c48513          	addi	a0,s1,540
    80003da0:	afffd0ef          	jal	ra,8000189e <wakeup>
  release(&pi->lock);
    80003da4:	8526                	mv	a0,s1
    80003da6:	681010ef          	jal	ra,80005c26 <release>
  return i;
}
    80003daa:	854e                	mv	a0,s3
    80003dac:	60a6                	ld	ra,72(sp)
    80003dae:	6406                	ld	s0,64(sp)
    80003db0:	74e2                	ld	s1,56(sp)
    80003db2:	7942                	ld	s2,48(sp)
    80003db4:	79a2                	ld	s3,40(sp)
    80003db6:	7a02                	ld	s4,32(sp)
    80003db8:	6ae2                	ld	s5,24(sp)
    80003dba:	6b42                	ld	s6,16(sp)
    80003dbc:	6161                	addi	sp,sp,80
    80003dbe:	8082                	ret
      release(&pi->lock);
    80003dc0:	8526                	mv	a0,s1
    80003dc2:	665010ef          	jal	ra,80005c26 <release>
      return -1;
    80003dc6:	59fd                	li	s3,-1
    80003dc8:	b7cd                	j	80003daa <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003dca:	4981                	li	s3,0
    80003dcc:	bfc1                	j	80003d9c <piperead+0xa0>

0000000080003dce <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003dce:	1141                	addi	sp,sp,-16
    80003dd0:	e422                	sd	s0,8(sp)
    80003dd2:	0800                	addi	s0,sp,16
    80003dd4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003dd6:	8905                	andi	a0,a0,1
    80003dd8:	c111                	beqz	a0,80003ddc <flags2perm+0xe>
      perm = PTE_X;
    80003dda:	4521                	li	a0,8
    if(flags & 0x2)
    80003ddc:	8b89                	andi	a5,a5,2
    80003dde:	c399                	beqz	a5,80003de4 <flags2perm+0x16>
      perm |= PTE_W;
    80003de0:	00456513          	ori	a0,a0,4
    return perm;
}
    80003de4:	6422                	ld	s0,8(sp)
    80003de6:	0141                	addi	sp,sp,16
    80003de8:	8082                	ret

0000000080003dea <exec>:

int
exec(char *path, char **argv)
{
    80003dea:	df010113          	addi	sp,sp,-528
    80003dee:	20113423          	sd	ra,520(sp)
    80003df2:	20813023          	sd	s0,512(sp)
    80003df6:	ffa6                	sd	s1,504(sp)
    80003df8:	fbca                	sd	s2,496(sp)
    80003dfa:	f7ce                	sd	s3,488(sp)
    80003dfc:	f3d2                	sd	s4,480(sp)
    80003dfe:	efd6                	sd	s5,472(sp)
    80003e00:	ebda                	sd	s6,464(sp)
    80003e02:	e7de                	sd	s7,456(sp)
    80003e04:	e3e2                	sd	s8,448(sp)
    80003e06:	ff66                	sd	s9,440(sp)
    80003e08:	fb6a                	sd	s10,432(sp)
    80003e0a:	f76e                	sd	s11,424(sp)
    80003e0c:	0c00                	addi	s0,sp,528
    80003e0e:	84aa                	mv	s1,a0
    80003e10:	dea43c23          	sd	a0,-520(s0)
    80003e14:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003e18:	bccfd0ef          	jal	ra,800011e4 <myproc>
    80003e1c:	892a                	mv	s2,a0

  begin_op();
    80003e1e:	e00ff0ef          	jal	ra,8000341e <begin_op>

  if((ip = namei(path)) == 0){
    80003e22:	8526                	mv	a0,s1
    80003e24:	c22ff0ef          	jal	ra,80003246 <namei>
    80003e28:	c12d                	beqz	a0,80003e8a <exec+0xa0>
    80003e2a:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003e2c:	d69fe0ef          	jal	ra,80002b94 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003e30:	04000713          	li	a4,64
    80003e34:	4681                	li	a3,0
    80003e36:	e5040613          	addi	a2,s0,-432
    80003e3a:	4581                	li	a1,0
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	fa7fe0ef          	jal	ra,80002de4 <readi>
    80003e42:	04000793          	li	a5,64
    80003e46:	00f51a63          	bne	a0,a5,80003e5a <exec+0x70>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003e4a:	e5042703          	lw	a4,-432(s0)
    80003e4e:	464c47b7          	lui	a5,0x464c4
    80003e52:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003e56:	02f70e63          	beq	a4,a5,80003e92 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003e5a:	8526                	mv	a0,s1
    80003e5c:	f3ffe0ef          	jal	ra,80002d9a <iunlockput>
    end_op();
    80003e60:	e2eff0ef          	jal	ra,8000348e <end_op>
  }
  return -1;
    80003e64:	557d                	li	a0,-1
}
    80003e66:	20813083          	ld	ra,520(sp)
    80003e6a:	20013403          	ld	s0,512(sp)
    80003e6e:	74fe                	ld	s1,504(sp)
    80003e70:	795e                	ld	s2,496(sp)
    80003e72:	79be                	ld	s3,488(sp)
    80003e74:	7a1e                	ld	s4,480(sp)
    80003e76:	6afe                	ld	s5,472(sp)
    80003e78:	6b5e                	ld	s6,464(sp)
    80003e7a:	6bbe                	ld	s7,456(sp)
    80003e7c:	6c1e                	ld	s8,448(sp)
    80003e7e:	7cfa                	ld	s9,440(sp)
    80003e80:	7d5a                	ld	s10,432(sp)
    80003e82:	7dba                	ld	s11,424(sp)
    80003e84:	21010113          	addi	sp,sp,528
    80003e88:	8082                	ret
    end_op();
    80003e8a:	e04ff0ef          	jal	ra,8000348e <end_op>
    return -1;
    80003e8e:	557d                	li	a0,-1
    80003e90:	bfd9                	j	80003e66 <exec+0x7c>
  if((pagetable = proc_pagetable(p)) == 0)
    80003e92:	854a                	mv	a0,s2
    80003e94:	bf8fd0ef          	jal	ra,8000128c <proc_pagetable>
    80003e98:	8baa                	mv	s7,a0
    80003e9a:	d161                	beqz	a0,80003e5a <exec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003e9c:	e7042983          	lw	s3,-400(s0)
    80003ea0:	e8845783          	lhu	a5,-376(s0)
    80003ea4:	cfb9                	beqz	a5,80003f02 <exec+0x118>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ea6:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003ea8:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80003eaa:	6c85                	lui	s9,0x1
    80003eac:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003eb0:	def43823          	sd	a5,-528(s0)
    80003eb4:	a429                	j	800040be <exec+0x2d4>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003eb6:	00004517          	auipc	a0,0x4
    80003eba:	95250513          	addi	a0,a0,-1710 # 80007808 <syscalls+0x2e8>
    80003ebe:	1b5010ef          	jal	ra,80005872 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003ec2:	8756                	mv	a4,s5
    80003ec4:	012d86bb          	addw	a3,s11,s2
    80003ec8:	4581                	li	a1,0
    80003eca:	8526                	mv	a0,s1
    80003ecc:	f19fe0ef          	jal	ra,80002de4 <readi>
    80003ed0:	2501                	sext.w	a0,a0
    80003ed2:	18aa9c63          	bne	s5,a0,8000406a <exec+0x280>
  for(i = 0; i < sz; i += PGSIZE){
    80003ed6:	6785                	lui	a5,0x1
    80003ed8:	0127893b          	addw	s2,a5,s2
    80003edc:	77fd                	lui	a5,0xfffff
    80003ede:	01478a3b          	addw	s4,a5,s4
    80003ee2:	1d897563          	bgeu	s2,s8,800040ac <exec+0x2c2>
    pa = walkaddr(pagetable, va + i);
    80003ee6:	02091593          	slli	a1,s2,0x20
    80003eea:	9181                	srli	a1,a1,0x20
    80003eec:	95ea                	add	a1,a1,s10
    80003eee:	855e                	mv	a0,s7
    80003ef0:	859fc0ef          	jal	ra,80000748 <walkaddr>
    80003ef4:	862a                	mv	a2,a0
    if(pa == 0)
    80003ef6:	d161                	beqz	a0,80003eb6 <exec+0xcc>
      n = PGSIZE;
    80003ef8:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80003efa:	fd9a74e3          	bgeu	s4,s9,80003ec2 <exec+0xd8>
      n = sz - i;
    80003efe:	8ad2                	mv	s5,s4
    80003f00:	b7c9                	j	80003ec2 <exec+0xd8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003f02:	4a01                	li	s4,0
  iunlockput(ip);
    80003f04:	8526                	mv	a0,s1
    80003f06:	e95fe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    80003f0a:	d84ff0ef          	jal	ra,8000348e <end_op>
  p = myproc();
    80003f0e:	ad6fd0ef          	jal	ra,800011e4 <myproc>
    80003f12:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003f14:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003f18:	6785                	lui	a5,0x1
    80003f1a:	17fd                	addi	a5,a5,-1
    80003f1c:	9a3e                	add	s4,s4,a5
    80003f1e:	757d                	lui	a0,0xfffff
    80003f20:	00aa77b3          	and	a5,s4,a0
    80003f24:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003f28:	4691                	li	a3,4
    80003f2a:	6609                	lui	a2,0x2
    80003f2c:	963e                	add	a2,a2,a5
    80003f2e:	85be                	mv	a1,a5
    80003f30:	855e                	mv	a0,s7
    80003f32:	c95fc0ef          	jal	ra,80000bc6 <uvmalloc>
    80003f36:	8b2a                	mv	s6,a0
  ip = 0;
    80003f38:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003f3a:	12050863          	beqz	a0,8000406a <exec+0x280>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003f3e:	75f9                	lui	a1,0xffffe
    80003f40:	95aa                	add	a1,a1,a0
    80003f42:	855e                	mv	a0,s7
    80003f44:	eeffc0ef          	jal	ra,80000e32 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003f48:	7c7d                	lui	s8,0xfffff
    80003f4a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80003f4c:	e0043783          	ld	a5,-512(s0)
    80003f50:	6388                	ld	a0,0(a5)
    80003f52:	c125                	beqz	a0,80003fb2 <exec+0x1c8>
    80003f54:	e9040993          	addi	s3,s0,-368
    80003f58:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003f5c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80003f5e:	c5cfc0ef          	jal	ra,800003ba <strlen>
    80003f62:	2505                	addiw	a0,a0,1
    80003f64:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003f68:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80003f6c:	13896463          	bltu	s2,s8,80004094 <exec+0x2aa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003f70:	e0043d83          	ld	s11,-512(s0)
    80003f74:	000dba03          	ld	s4,0(s11)
    80003f78:	8552                	mv	a0,s4
    80003f7a:	c40fc0ef          	jal	ra,800003ba <strlen>
    80003f7e:	0015069b          	addiw	a3,a0,1
    80003f82:	8652                	mv	a2,s4
    80003f84:	85ca                	mv	a1,s2
    80003f86:	855e                	mv	a0,s7
    80003f88:	ed5fc0ef          	jal	ra,80000e5c <copyout>
    80003f8c:	10054863          	bltz	a0,8000409c <exec+0x2b2>
    ustack[argc] = sp;
    80003f90:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003f94:	0485                	addi	s1,s1,1
    80003f96:	008d8793          	addi	a5,s11,8
    80003f9a:	e0f43023          	sd	a5,-512(s0)
    80003f9e:	008db503          	ld	a0,8(s11)
    80003fa2:	c911                	beqz	a0,80003fb6 <exec+0x1cc>
    if(argc >= MAXARG)
    80003fa4:	09a1                	addi	s3,s3,8
    80003fa6:	fb3c9ce3          	bne	s9,s3,80003f5e <exec+0x174>
  sz = sz1;
    80003faa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003fae:	4481                	li	s1,0
    80003fb0:	a86d                	j	8000406a <exec+0x280>
  sp = sz;
    80003fb2:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80003fb4:	4481                	li	s1,0
  ustack[argc] = 0;
    80003fb6:	00349793          	slli	a5,s1,0x3
    80003fba:	f9040713          	addi	a4,s0,-112
    80003fbe:	97ba                	add	a5,a5,a4
    80003fc0:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80003fc4:	00148693          	addi	a3,s1,1
    80003fc8:	068e                	slli	a3,a3,0x3
    80003fca:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003fce:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003fd2:	01897663          	bgeu	s2,s8,80003fde <exec+0x1f4>
  sz = sz1;
    80003fd6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003fda:	4481                	li	s1,0
    80003fdc:	a079                	j	8000406a <exec+0x280>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003fde:	e9040613          	addi	a2,s0,-368
    80003fe2:	85ca                	mv	a1,s2
    80003fe4:	855e                	mv	a0,s7
    80003fe6:	e77fc0ef          	jal	ra,80000e5c <copyout>
    80003fea:	0a054d63          	bltz	a0,800040a4 <exec+0x2ba>
  p->trapframe->a1 = sp;
    80003fee:	058ab783          	ld	a5,88(s5)
    80003ff2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003ff6:	df843783          	ld	a5,-520(s0)
    80003ffa:	0007c703          	lbu	a4,0(a5)
    80003ffe:	cf11                	beqz	a4,8000401a <exec+0x230>
    80004000:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004002:	02f00693          	li	a3,47
    80004006:	a039                	j	80004014 <exec+0x22a>
      last = s+1;
    80004008:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000400c:	0785                	addi	a5,a5,1
    8000400e:	fff7c703          	lbu	a4,-1(a5)
    80004012:	c701                	beqz	a4,8000401a <exec+0x230>
    if(*s == '/')
    80004014:	fed71ce3          	bne	a4,a3,8000400c <exec+0x222>
    80004018:	bfc5                	j	80004008 <exec+0x21e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000401a:	4641                	li	a2,16
    8000401c:	df843583          	ld	a1,-520(s0)
    80004020:	158a8513          	addi	a0,s5,344
    80004024:	b64fc0ef          	jal	ra,80000388 <safestrcpy>
  oldpagetable = p->pagetable;
    80004028:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000402c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004030:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004034:	058ab783          	ld	a5,88(s5)
    80004038:	e6843703          	ld	a4,-408(s0)
    8000403c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000403e:	058ab783          	ld	a5,88(s5)
    80004042:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004046:	85ea                	mv	a1,s10
    80004048:	b58fd0ef          	jal	ra,800013a0 <proc_freepagetable>
  if (p->pid==1) vmprint(p->pagetable);
    8000404c:	030aa703          	lw	a4,48(s5)
    80004050:	4785                	li	a5,1
    80004052:	00f70563          	beq	a4,a5,8000405c <exec+0x272>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004056:	0004851b          	sext.w	a0,s1
    8000405a:	b531                	j	80003e66 <exec+0x7c>
  if (p->pid==1) vmprint(p->pagetable);
    8000405c:	050ab503          	ld	a0,80(s5)
    80004060:	fe9fc0ef          	jal	ra,80001048 <vmprint>
    80004064:	bfcd                	j	80004056 <exec+0x26c>
    80004066:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000406a:	e0843583          	ld	a1,-504(s0)
    8000406e:	855e                	mv	a0,s7
    80004070:	b30fd0ef          	jal	ra,800013a0 <proc_freepagetable>
  if(ip){
    80004074:	de0493e3          	bnez	s1,80003e5a <exec+0x70>
  return -1;
    80004078:	557d                	li	a0,-1
    8000407a:	b3f5                	j	80003e66 <exec+0x7c>
    8000407c:	e1443423          	sd	s4,-504(s0)
    80004080:	b7ed                	j	8000406a <exec+0x280>
    80004082:	e1443423          	sd	s4,-504(s0)
    80004086:	b7d5                	j	8000406a <exec+0x280>
    80004088:	e1443423          	sd	s4,-504(s0)
    8000408c:	bff9                	j	8000406a <exec+0x280>
    8000408e:	e1443423          	sd	s4,-504(s0)
    80004092:	bfe1                	j	8000406a <exec+0x280>
  sz = sz1;
    80004094:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004098:	4481                	li	s1,0
    8000409a:	bfc1                	j	8000406a <exec+0x280>
  sz = sz1;
    8000409c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800040a0:	4481                	li	s1,0
    800040a2:	b7e1                	j	8000406a <exec+0x280>
  sz = sz1;
    800040a4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800040a8:	4481                	li	s1,0
    800040aa:	b7c1                	j	8000406a <exec+0x280>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800040ac:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800040b0:	2b05                	addiw	s6,s6,1
    800040b2:	0389899b          	addiw	s3,s3,56
    800040b6:	e8845783          	lhu	a5,-376(s0)
    800040ba:	e4fb55e3          	bge	s6,a5,80003f04 <exec+0x11a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800040be:	2981                	sext.w	s3,s3
    800040c0:	03800713          	li	a4,56
    800040c4:	86ce                	mv	a3,s3
    800040c6:	e1840613          	addi	a2,s0,-488
    800040ca:	4581                	li	a1,0
    800040cc:	8526                	mv	a0,s1
    800040ce:	d17fe0ef          	jal	ra,80002de4 <readi>
    800040d2:	03800793          	li	a5,56
    800040d6:	f8f518e3          	bne	a0,a5,80004066 <exec+0x27c>
    if(ph.type != ELF_PROG_LOAD)
    800040da:	e1842783          	lw	a5,-488(s0)
    800040de:	4705                	li	a4,1
    800040e0:	fce798e3          	bne	a5,a4,800040b0 <exec+0x2c6>
    if(ph.memsz < ph.filesz)
    800040e4:	e4043903          	ld	s2,-448(s0)
    800040e8:	e3843783          	ld	a5,-456(s0)
    800040ec:	f8f968e3          	bltu	s2,a5,8000407c <exec+0x292>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800040f0:	e2843783          	ld	a5,-472(s0)
    800040f4:	993e                	add	s2,s2,a5
    800040f6:	f8f966e3          	bltu	s2,a5,80004082 <exec+0x298>
    if(ph.vaddr % PGSIZE != 0)
    800040fa:	df043703          	ld	a4,-528(s0)
    800040fe:	8ff9                	and	a5,a5,a4
    80004100:	f7c1                	bnez	a5,80004088 <exec+0x29e>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004102:	e1c42503          	lw	a0,-484(s0)
    80004106:	cc9ff0ef          	jal	ra,80003dce <flags2perm>
    8000410a:	86aa                	mv	a3,a0
    8000410c:	864a                	mv	a2,s2
    8000410e:	85d2                	mv	a1,s4
    80004110:	855e                	mv	a0,s7
    80004112:	ab5fc0ef          	jal	ra,80000bc6 <uvmalloc>
    80004116:	e0a43423          	sd	a0,-504(s0)
    8000411a:	d935                	beqz	a0,8000408e <exec+0x2a4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000411c:	e2843d03          	ld	s10,-472(s0)
    80004120:	e2042d83          	lw	s11,-480(s0)
    80004124:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004128:	f80c02e3          	beqz	s8,800040ac <exec+0x2c2>
    8000412c:	8a62                	mv	s4,s8
    8000412e:	4901                	li	s2,0
    80004130:	bb5d                	j	80003ee6 <exec+0xfc>

0000000080004132 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004132:	7179                	addi	sp,sp,-48
    80004134:	f406                	sd	ra,40(sp)
    80004136:	f022                	sd	s0,32(sp)
    80004138:	ec26                	sd	s1,24(sp)
    8000413a:	e84a                	sd	s2,16(sp)
    8000413c:	1800                	addi	s0,sp,48
    8000413e:	892e                	mv	s2,a1
    80004140:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004142:	fdc40593          	addi	a1,s0,-36
    80004146:	fedfd0ef          	jal	ra,80002132 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000414a:	fdc42703          	lw	a4,-36(s0)
    8000414e:	47bd                	li	a5,15
    80004150:	02e7e963          	bltu	a5,a4,80004182 <argfd+0x50>
    80004154:	890fd0ef          	jal	ra,800011e4 <myproc>
    80004158:	fdc42703          	lw	a4,-36(s0)
    8000415c:	01a70793          	addi	a5,a4,26
    80004160:	078e                	slli	a5,a5,0x3
    80004162:	953e                	add	a0,a0,a5
    80004164:	611c                	ld	a5,0(a0)
    80004166:	c385                	beqz	a5,80004186 <argfd+0x54>
    return -1;
  if(pfd)
    80004168:	00090463          	beqz	s2,80004170 <argfd+0x3e>
    *pfd = fd;
    8000416c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004170:	4501                	li	a0,0
  if(pf)
    80004172:	c091                	beqz	s1,80004176 <argfd+0x44>
    *pf = f;
    80004174:	e09c                	sd	a5,0(s1)
}
    80004176:	70a2                	ld	ra,40(sp)
    80004178:	7402                	ld	s0,32(sp)
    8000417a:	64e2                	ld	s1,24(sp)
    8000417c:	6942                	ld	s2,16(sp)
    8000417e:	6145                	addi	sp,sp,48
    80004180:	8082                	ret
    return -1;
    80004182:	557d                	li	a0,-1
    80004184:	bfcd                	j	80004176 <argfd+0x44>
    80004186:	557d                	li	a0,-1
    80004188:	b7fd                	j	80004176 <argfd+0x44>

000000008000418a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000418a:	1101                	addi	sp,sp,-32
    8000418c:	ec06                	sd	ra,24(sp)
    8000418e:	e822                	sd	s0,16(sp)
    80004190:	e426                	sd	s1,8(sp)
    80004192:	1000                	addi	s0,sp,32
    80004194:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004196:	84efd0ef          	jal	ra,800011e4 <myproc>
    8000419a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000419c:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffde320>
    800041a0:	4501                	li	a0,0
    800041a2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800041a4:	6398                	ld	a4,0(a5)
    800041a6:	cb19                	beqz	a4,800041bc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800041a8:	2505                	addiw	a0,a0,1
    800041aa:	07a1                	addi	a5,a5,8
    800041ac:	fed51ce3          	bne	a0,a3,800041a4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800041b0:	557d                	li	a0,-1
}
    800041b2:	60e2                	ld	ra,24(sp)
    800041b4:	6442                	ld	s0,16(sp)
    800041b6:	64a2                	ld	s1,8(sp)
    800041b8:	6105                	addi	sp,sp,32
    800041ba:	8082                	ret
      p->ofile[fd] = f;
    800041bc:	01a50793          	addi	a5,a0,26
    800041c0:	078e                	slli	a5,a5,0x3
    800041c2:	963e                	add	a2,a2,a5
    800041c4:	e204                	sd	s1,0(a2)
      return fd;
    800041c6:	b7f5                	j	800041b2 <fdalloc+0x28>

00000000800041c8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800041c8:	715d                	addi	sp,sp,-80
    800041ca:	e486                	sd	ra,72(sp)
    800041cc:	e0a2                	sd	s0,64(sp)
    800041ce:	fc26                	sd	s1,56(sp)
    800041d0:	f84a                	sd	s2,48(sp)
    800041d2:	f44e                	sd	s3,40(sp)
    800041d4:	f052                	sd	s4,32(sp)
    800041d6:	ec56                	sd	s5,24(sp)
    800041d8:	e85a                	sd	s6,16(sp)
    800041da:	0880                	addi	s0,sp,80
    800041dc:	8b2e                	mv	s6,a1
    800041de:	89b2                	mv	s3,a2
    800041e0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800041e2:	fb040593          	addi	a1,s0,-80
    800041e6:	87aff0ef          	jal	ra,80003260 <nameiparent>
    800041ea:	84aa                	mv	s1,a0
    800041ec:	10050c63          	beqz	a0,80004304 <create+0x13c>
    return 0;

  ilock(dp);
    800041f0:	9a5fe0ef          	jal	ra,80002b94 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800041f4:	4601                	li	a2,0
    800041f6:	fb040593          	addi	a1,s0,-80
    800041fa:	8526                	mv	a0,s1
    800041fc:	de5fe0ef          	jal	ra,80002fe0 <dirlookup>
    80004200:	8aaa                	mv	s5,a0
    80004202:	c521                	beqz	a0,8000424a <create+0x82>
    iunlockput(dp);
    80004204:	8526                	mv	a0,s1
    80004206:	b95fe0ef          	jal	ra,80002d9a <iunlockput>
    ilock(ip);
    8000420a:	8556                	mv	a0,s5
    8000420c:	989fe0ef          	jal	ra,80002b94 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004210:	000b059b          	sext.w	a1,s6
    80004214:	4789                	li	a5,2
    80004216:	02f59563          	bne	a1,a5,80004240 <create+0x78>
    8000421a:	044ad783          	lhu	a5,68(s5)
    8000421e:	37f9                	addiw	a5,a5,-2
    80004220:	17c2                	slli	a5,a5,0x30
    80004222:	93c1                	srli	a5,a5,0x30
    80004224:	4705                	li	a4,1
    80004226:	00f76d63          	bltu	a4,a5,80004240 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000422a:	8556                	mv	a0,s5
    8000422c:	60a6                	ld	ra,72(sp)
    8000422e:	6406                	ld	s0,64(sp)
    80004230:	74e2                	ld	s1,56(sp)
    80004232:	7942                	ld	s2,48(sp)
    80004234:	79a2                	ld	s3,40(sp)
    80004236:	7a02                	ld	s4,32(sp)
    80004238:	6ae2                	ld	s5,24(sp)
    8000423a:	6b42                	ld	s6,16(sp)
    8000423c:	6161                	addi	sp,sp,80
    8000423e:	8082                	ret
    iunlockput(ip);
    80004240:	8556                	mv	a0,s5
    80004242:	b59fe0ef          	jal	ra,80002d9a <iunlockput>
    return 0;
    80004246:	4a81                	li	s5,0
    80004248:	b7cd                	j	8000422a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000424a:	85da                	mv	a1,s6
    8000424c:	4088                	lw	a0,0(s1)
    8000424e:	fdefe0ef          	jal	ra,80002a2c <ialloc>
    80004252:	8a2a                	mv	s4,a0
    80004254:	c121                	beqz	a0,80004294 <create+0xcc>
  ilock(ip);
    80004256:	93ffe0ef          	jal	ra,80002b94 <ilock>
  ip->major = major;
    8000425a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000425e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004262:	4785                	li	a5,1
    80004264:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80004268:	8552                	mv	a0,s4
    8000426a:	879fe0ef          	jal	ra,80002ae2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000426e:	000b059b          	sext.w	a1,s6
    80004272:	4785                	li	a5,1
    80004274:	02f58563          	beq	a1,a5,8000429e <create+0xd6>
  if(dirlink(dp, name, ip->inum) < 0)
    80004278:	004a2603          	lw	a2,4(s4)
    8000427c:	fb040593          	addi	a1,s0,-80
    80004280:	8526                	mv	a0,s1
    80004282:	f2bfe0ef          	jal	ra,800031ac <dirlink>
    80004286:	06054363          	bltz	a0,800042ec <create+0x124>
  iunlockput(dp);
    8000428a:	8526                	mv	a0,s1
    8000428c:	b0ffe0ef          	jal	ra,80002d9a <iunlockput>
  return ip;
    80004290:	8ad2                	mv	s5,s4
    80004292:	bf61                	j	8000422a <create+0x62>
    iunlockput(dp);
    80004294:	8526                	mv	a0,s1
    80004296:	b05fe0ef          	jal	ra,80002d9a <iunlockput>
    return 0;
    8000429a:	8ad2                	mv	s5,s4
    8000429c:	b779                	j	8000422a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000429e:	004a2603          	lw	a2,4(s4)
    800042a2:	00003597          	auipc	a1,0x3
    800042a6:	58658593          	addi	a1,a1,1414 # 80007828 <syscalls+0x308>
    800042aa:	8552                	mv	a0,s4
    800042ac:	f01fe0ef          	jal	ra,800031ac <dirlink>
    800042b0:	02054e63          	bltz	a0,800042ec <create+0x124>
    800042b4:	40d0                	lw	a2,4(s1)
    800042b6:	00003597          	auipc	a1,0x3
    800042ba:	daa58593          	addi	a1,a1,-598 # 80007060 <etext+0x60>
    800042be:	8552                	mv	a0,s4
    800042c0:	eedfe0ef          	jal	ra,800031ac <dirlink>
    800042c4:	02054463          	bltz	a0,800042ec <create+0x124>
  if(dirlink(dp, name, ip->inum) < 0)
    800042c8:	004a2603          	lw	a2,4(s4)
    800042cc:	fb040593          	addi	a1,s0,-80
    800042d0:	8526                	mv	a0,s1
    800042d2:	edbfe0ef          	jal	ra,800031ac <dirlink>
    800042d6:	00054b63          	bltz	a0,800042ec <create+0x124>
    dp->nlink++;  // for ".."
    800042da:	04a4d783          	lhu	a5,74(s1)
    800042de:	2785                	addiw	a5,a5,1
    800042e0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800042e4:	8526                	mv	a0,s1
    800042e6:	ffcfe0ef          	jal	ra,80002ae2 <iupdate>
    800042ea:	b745                	j	8000428a <create+0xc2>
  ip->nlink = 0;
    800042ec:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800042f0:	8552                	mv	a0,s4
    800042f2:	ff0fe0ef          	jal	ra,80002ae2 <iupdate>
  iunlockput(ip);
    800042f6:	8552                	mv	a0,s4
    800042f8:	aa3fe0ef          	jal	ra,80002d9a <iunlockput>
  iunlockput(dp);
    800042fc:	8526                	mv	a0,s1
    800042fe:	a9dfe0ef          	jal	ra,80002d9a <iunlockput>
  return 0;
    80004302:	b725                	j	8000422a <create+0x62>
    return 0;
    80004304:	8aaa                	mv	s5,a0
    80004306:	b715                	j	8000422a <create+0x62>

0000000080004308 <sys_dup>:
{
    80004308:	7179                	addi	sp,sp,-48
    8000430a:	f406                	sd	ra,40(sp)
    8000430c:	f022                	sd	s0,32(sp)
    8000430e:	ec26                	sd	s1,24(sp)
    80004310:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004312:	fd840613          	addi	a2,s0,-40
    80004316:	4581                	li	a1,0
    80004318:	4501                	li	a0,0
    8000431a:	e19ff0ef          	jal	ra,80004132 <argfd>
    return -1;
    8000431e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004320:	00054f63          	bltz	a0,8000433e <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004324:	fd843503          	ld	a0,-40(s0)
    80004328:	e63ff0ef          	jal	ra,8000418a <fdalloc>
    8000432c:	84aa                	mv	s1,a0
    return -1;
    8000432e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004330:	00054763          	bltz	a0,8000433e <sys_dup+0x36>
  filedup(f);
    80004334:	fd843503          	ld	a0,-40(s0)
    80004338:	cbcff0ef          	jal	ra,800037f4 <filedup>
  return fd;
    8000433c:	87a6                	mv	a5,s1
}
    8000433e:	853e                	mv	a0,a5
    80004340:	70a2                	ld	ra,40(sp)
    80004342:	7402                	ld	s0,32(sp)
    80004344:	64e2                	ld	s1,24(sp)
    80004346:	6145                	addi	sp,sp,48
    80004348:	8082                	ret

000000008000434a <sys_read>:
{
    8000434a:	7179                	addi	sp,sp,-48
    8000434c:	f406                	sd	ra,40(sp)
    8000434e:	f022                	sd	s0,32(sp)
    80004350:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004352:	fd840593          	addi	a1,s0,-40
    80004356:	4505                	li	a0,1
    80004358:	df7fd0ef          	jal	ra,8000214e <argaddr>
  argint(2, &n);
    8000435c:	fe440593          	addi	a1,s0,-28
    80004360:	4509                	li	a0,2
    80004362:	dd1fd0ef          	jal	ra,80002132 <argint>
  if(argfd(0, 0, &f) < 0)
    80004366:	fe840613          	addi	a2,s0,-24
    8000436a:	4581                	li	a1,0
    8000436c:	4501                	li	a0,0
    8000436e:	dc5ff0ef          	jal	ra,80004132 <argfd>
    80004372:	87aa                	mv	a5,a0
    return -1;
    80004374:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004376:	0007ca63          	bltz	a5,8000438a <sys_read+0x40>
  return fileread(f, p, n);
    8000437a:	fe442603          	lw	a2,-28(s0)
    8000437e:	fd843583          	ld	a1,-40(s0)
    80004382:	fe843503          	ld	a0,-24(s0)
    80004386:	dbaff0ef          	jal	ra,80003940 <fileread>
}
    8000438a:	70a2                	ld	ra,40(sp)
    8000438c:	7402                	ld	s0,32(sp)
    8000438e:	6145                	addi	sp,sp,48
    80004390:	8082                	ret

0000000080004392 <sys_write>:
{
    80004392:	7179                	addi	sp,sp,-48
    80004394:	f406                	sd	ra,40(sp)
    80004396:	f022                	sd	s0,32(sp)
    80004398:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000439a:	fd840593          	addi	a1,s0,-40
    8000439e:	4505                	li	a0,1
    800043a0:	daffd0ef          	jal	ra,8000214e <argaddr>
  argint(2, &n);
    800043a4:	fe440593          	addi	a1,s0,-28
    800043a8:	4509                	li	a0,2
    800043aa:	d89fd0ef          	jal	ra,80002132 <argint>
  if(argfd(0, 0, &f) < 0)
    800043ae:	fe840613          	addi	a2,s0,-24
    800043b2:	4581                	li	a1,0
    800043b4:	4501                	li	a0,0
    800043b6:	d7dff0ef          	jal	ra,80004132 <argfd>
    800043ba:	87aa                	mv	a5,a0
    return -1;
    800043bc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800043be:	0007ca63          	bltz	a5,800043d2 <sys_write+0x40>
  return filewrite(f, p, n);
    800043c2:	fe442603          	lw	a2,-28(s0)
    800043c6:	fd843583          	ld	a1,-40(s0)
    800043ca:	fe843503          	ld	a0,-24(s0)
    800043ce:	e20ff0ef          	jal	ra,800039ee <filewrite>
}
    800043d2:	70a2                	ld	ra,40(sp)
    800043d4:	7402                	ld	s0,32(sp)
    800043d6:	6145                	addi	sp,sp,48
    800043d8:	8082                	ret

00000000800043da <sys_close>:
{
    800043da:	1101                	addi	sp,sp,-32
    800043dc:	ec06                	sd	ra,24(sp)
    800043de:	e822                	sd	s0,16(sp)
    800043e0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800043e2:	fe040613          	addi	a2,s0,-32
    800043e6:	fec40593          	addi	a1,s0,-20
    800043ea:	4501                	li	a0,0
    800043ec:	d47ff0ef          	jal	ra,80004132 <argfd>
    return -1;
    800043f0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800043f2:	02054063          	bltz	a0,80004412 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    800043f6:	deffc0ef          	jal	ra,800011e4 <myproc>
    800043fa:	fec42783          	lw	a5,-20(s0)
    800043fe:	07e9                	addi	a5,a5,26
    80004400:	078e                	slli	a5,a5,0x3
    80004402:	97aa                	add	a5,a5,a0
    80004404:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004408:	fe043503          	ld	a0,-32(s0)
    8000440c:	c2eff0ef          	jal	ra,8000383a <fileclose>
  return 0;
    80004410:	4781                	li	a5,0
}
    80004412:	853e                	mv	a0,a5
    80004414:	60e2                	ld	ra,24(sp)
    80004416:	6442                	ld	s0,16(sp)
    80004418:	6105                	addi	sp,sp,32
    8000441a:	8082                	ret

000000008000441c <sys_fstat>:
{
    8000441c:	1101                	addi	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004424:	fe040593          	addi	a1,s0,-32
    80004428:	4505                	li	a0,1
    8000442a:	d25fd0ef          	jal	ra,8000214e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000442e:	fe840613          	addi	a2,s0,-24
    80004432:	4581                	li	a1,0
    80004434:	4501                	li	a0,0
    80004436:	cfdff0ef          	jal	ra,80004132 <argfd>
    8000443a:	87aa                	mv	a5,a0
    return -1;
    8000443c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000443e:	0007c863          	bltz	a5,8000444e <sys_fstat+0x32>
  return filestat(f, st);
    80004442:	fe043583          	ld	a1,-32(s0)
    80004446:	fe843503          	ld	a0,-24(s0)
    8000444a:	c98ff0ef          	jal	ra,800038e2 <filestat>
}
    8000444e:	60e2                	ld	ra,24(sp)
    80004450:	6442                	ld	s0,16(sp)
    80004452:	6105                	addi	sp,sp,32
    80004454:	8082                	ret

0000000080004456 <sys_link>:
{
    80004456:	7169                	addi	sp,sp,-304
    80004458:	f606                	sd	ra,296(sp)
    8000445a:	f222                	sd	s0,288(sp)
    8000445c:	ee26                	sd	s1,280(sp)
    8000445e:	ea4a                	sd	s2,272(sp)
    80004460:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004462:	08000613          	li	a2,128
    80004466:	ed040593          	addi	a1,s0,-304
    8000446a:	4501                	li	a0,0
    8000446c:	cfffd0ef          	jal	ra,8000216a <argstr>
    return -1;
    80004470:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004472:	0c054663          	bltz	a0,8000453e <sys_link+0xe8>
    80004476:	08000613          	li	a2,128
    8000447a:	f5040593          	addi	a1,s0,-176
    8000447e:	4505                	li	a0,1
    80004480:	cebfd0ef          	jal	ra,8000216a <argstr>
    return -1;
    80004484:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004486:	0a054c63          	bltz	a0,8000453e <sys_link+0xe8>
  begin_op();
    8000448a:	f95fe0ef          	jal	ra,8000341e <begin_op>
  if((ip = namei(old)) == 0){
    8000448e:	ed040513          	addi	a0,s0,-304
    80004492:	db5fe0ef          	jal	ra,80003246 <namei>
    80004496:	84aa                	mv	s1,a0
    80004498:	c525                	beqz	a0,80004500 <sys_link+0xaa>
  ilock(ip);
    8000449a:	efafe0ef          	jal	ra,80002b94 <ilock>
  if(ip->type == T_DIR){
    8000449e:	04449703          	lh	a4,68(s1)
    800044a2:	4785                	li	a5,1
    800044a4:	06f70263          	beq	a4,a5,80004508 <sys_link+0xb2>
  ip->nlink++;
    800044a8:	04a4d783          	lhu	a5,74(s1)
    800044ac:	2785                	addiw	a5,a5,1
    800044ae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800044b2:	8526                	mv	a0,s1
    800044b4:	e2efe0ef          	jal	ra,80002ae2 <iupdate>
  iunlock(ip);
    800044b8:	8526                	mv	a0,s1
    800044ba:	f84fe0ef          	jal	ra,80002c3e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800044be:	fd040593          	addi	a1,s0,-48
    800044c2:	f5040513          	addi	a0,s0,-176
    800044c6:	d9bfe0ef          	jal	ra,80003260 <nameiparent>
    800044ca:	892a                	mv	s2,a0
    800044cc:	c921                	beqz	a0,8000451c <sys_link+0xc6>
  ilock(dp);
    800044ce:	ec6fe0ef          	jal	ra,80002b94 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800044d2:	00092703          	lw	a4,0(s2)
    800044d6:	409c                	lw	a5,0(s1)
    800044d8:	02f71f63          	bne	a4,a5,80004516 <sys_link+0xc0>
    800044dc:	40d0                	lw	a2,4(s1)
    800044de:	fd040593          	addi	a1,s0,-48
    800044e2:	854a                	mv	a0,s2
    800044e4:	cc9fe0ef          	jal	ra,800031ac <dirlink>
    800044e8:	02054763          	bltz	a0,80004516 <sys_link+0xc0>
  iunlockput(dp);
    800044ec:	854a                	mv	a0,s2
    800044ee:	8adfe0ef          	jal	ra,80002d9a <iunlockput>
  iput(ip);
    800044f2:	8526                	mv	a0,s1
    800044f4:	81ffe0ef          	jal	ra,80002d12 <iput>
  end_op();
    800044f8:	f97fe0ef          	jal	ra,8000348e <end_op>
  return 0;
    800044fc:	4781                	li	a5,0
    800044fe:	a081                	j	8000453e <sys_link+0xe8>
    end_op();
    80004500:	f8ffe0ef          	jal	ra,8000348e <end_op>
    return -1;
    80004504:	57fd                	li	a5,-1
    80004506:	a825                	j	8000453e <sys_link+0xe8>
    iunlockput(ip);
    80004508:	8526                	mv	a0,s1
    8000450a:	891fe0ef          	jal	ra,80002d9a <iunlockput>
    end_op();
    8000450e:	f81fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    80004512:	57fd                	li	a5,-1
    80004514:	a02d                	j	8000453e <sys_link+0xe8>
    iunlockput(dp);
    80004516:	854a                	mv	a0,s2
    80004518:	883fe0ef          	jal	ra,80002d9a <iunlockput>
  ilock(ip);
    8000451c:	8526                	mv	a0,s1
    8000451e:	e76fe0ef          	jal	ra,80002b94 <ilock>
  ip->nlink--;
    80004522:	04a4d783          	lhu	a5,74(s1)
    80004526:	37fd                	addiw	a5,a5,-1
    80004528:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000452c:	8526                	mv	a0,s1
    8000452e:	db4fe0ef          	jal	ra,80002ae2 <iupdate>
  iunlockput(ip);
    80004532:	8526                	mv	a0,s1
    80004534:	867fe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    80004538:	f57fe0ef          	jal	ra,8000348e <end_op>
  return -1;
    8000453c:	57fd                	li	a5,-1
}
    8000453e:	853e                	mv	a0,a5
    80004540:	70b2                	ld	ra,296(sp)
    80004542:	7412                	ld	s0,288(sp)
    80004544:	64f2                	ld	s1,280(sp)
    80004546:	6952                	ld	s2,272(sp)
    80004548:	6155                	addi	sp,sp,304
    8000454a:	8082                	ret

000000008000454c <sys_unlink>:
{
    8000454c:	7151                	addi	sp,sp,-240
    8000454e:	f586                	sd	ra,232(sp)
    80004550:	f1a2                	sd	s0,224(sp)
    80004552:	eda6                	sd	s1,216(sp)
    80004554:	e9ca                	sd	s2,208(sp)
    80004556:	e5ce                	sd	s3,200(sp)
    80004558:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000455a:	08000613          	li	a2,128
    8000455e:	f3040593          	addi	a1,s0,-208
    80004562:	4501                	li	a0,0
    80004564:	c07fd0ef          	jal	ra,8000216a <argstr>
    80004568:	12054b63          	bltz	a0,8000469e <sys_unlink+0x152>
  begin_op();
    8000456c:	eb3fe0ef          	jal	ra,8000341e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004570:	fb040593          	addi	a1,s0,-80
    80004574:	f3040513          	addi	a0,s0,-208
    80004578:	ce9fe0ef          	jal	ra,80003260 <nameiparent>
    8000457c:	84aa                	mv	s1,a0
    8000457e:	c54d                	beqz	a0,80004628 <sys_unlink+0xdc>
  ilock(dp);
    80004580:	e14fe0ef          	jal	ra,80002b94 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004584:	00003597          	auipc	a1,0x3
    80004588:	2a458593          	addi	a1,a1,676 # 80007828 <syscalls+0x308>
    8000458c:	fb040513          	addi	a0,s0,-80
    80004590:	a3bfe0ef          	jal	ra,80002fca <namecmp>
    80004594:	10050a63          	beqz	a0,800046a8 <sys_unlink+0x15c>
    80004598:	00003597          	auipc	a1,0x3
    8000459c:	ac858593          	addi	a1,a1,-1336 # 80007060 <etext+0x60>
    800045a0:	fb040513          	addi	a0,s0,-80
    800045a4:	a27fe0ef          	jal	ra,80002fca <namecmp>
    800045a8:	10050063          	beqz	a0,800046a8 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800045ac:	f2c40613          	addi	a2,s0,-212
    800045b0:	fb040593          	addi	a1,s0,-80
    800045b4:	8526                	mv	a0,s1
    800045b6:	a2bfe0ef          	jal	ra,80002fe0 <dirlookup>
    800045ba:	892a                	mv	s2,a0
    800045bc:	0e050663          	beqz	a0,800046a8 <sys_unlink+0x15c>
  ilock(ip);
    800045c0:	dd4fe0ef          	jal	ra,80002b94 <ilock>
  if(ip->nlink < 1)
    800045c4:	04a91783          	lh	a5,74(s2)
    800045c8:	06f05463          	blez	a5,80004630 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800045cc:	04491703          	lh	a4,68(s2)
    800045d0:	4785                	li	a5,1
    800045d2:	06f70563          	beq	a4,a5,8000463c <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800045d6:	4641                	li	a2,16
    800045d8:	4581                	li	a1,0
    800045da:	fc040513          	addi	a0,s0,-64
    800045de:	c5dfb0ef          	jal	ra,8000023a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045e2:	4741                	li	a4,16
    800045e4:	f2c42683          	lw	a3,-212(s0)
    800045e8:	fc040613          	addi	a2,s0,-64
    800045ec:	4581                	li	a1,0
    800045ee:	8526                	mv	a0,s1
    800045f0:	8d9fe0ef          	jal	ra,80002ec8 <writei>
    800045f4:	47c1                	li	a5,16
    800045f6:	08f51563          	bne	a0,a5,80004680 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800045fa:	04491703          	lh	a4,68(s2)
    800045fe:	4785                	li	a5,1
    80004600:	08f70663          	beq	a4,a5,8000468c <sys_unlink+0x140>
  iunlockput(dp);
    80004604:	8526                	mv	a0,s1
    80004606:	f94fe0ef          	jal	ra,80002d9a <iunlockput>
  ip->nlink--;
    8000460a:	04a95783          	lhu	a5,74(s2)
    8000460e:	37fd                	addiw	a5,a5,-1
    80004610:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004614:	854a                	mv	a0,s2
    80004616:	cccfe0ef          	jal	ra,80002ae2 <iupdate>
  iunlockput(ip);
    8000461a:	854a                	mv	a0,s2
    8000461c:	f7efe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    80004620:	e6ffe0ef          	jal	ra,8000348e <end_op>
  return 0;
    80004624:	4501                	li	a0,0
    80004626:	a079                	j	800046b4 <sys_unlink+0x168>
    end_op();
    80004628:	e67fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    8000462c:	557d                	li	a0,-1
    8000462e:	a059                	j	800046b4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004630:	00003517          	auipc	a0,0x3
    80004634:	20050513          	addi	a0,a0,512 # 80007830 <syscalls+0x310>
    80004638:	23a010ef          	jal	ra,80005872 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000463c:	04c92703          	lw	a4,76(s2)
    80004640:	02000793          	li	a5,32
    80004644:	f8e7f9e3          	bgeu	a5,a4,800045d6 <sys_unlink+0x8a>
    80004648:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000464c:	4741                	li	a4,16
    8000464e:	86ce                	mv	a3,s3
    80004650:	f1840613          	addi	a2,s0,-232
    80004654:	4581                	li	a1,0
    80004656:	854a                	mv	a0,s2
    80004658:	f8cfe0ef          	jal	ra,80002de4 <readi>
    8000465c:	47c1                	li	a5,16
    8000465e:	00f51b63          	bne	a0,a5,80004674 <sys_unlink+0x128>
    if(de.inum != 0)
    80004662:	f1845783          	lhu	a5,-232(s0)
    80004666:	ef95                	bnez	a5,800046a2 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004668:	29c1                	addiw	s3,s3,16
    8000466a:	04c92783          	lw	a5,76(s2)
    8000466e:	fcf9efe3          	bltu	s3,a5,8000464c <sys_unlink+0x100>
    80004672:	b795                	j	800045d6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004674:	00003517          	auipc	a0,0x3
    80004678:	1d450513          	addi	a0,a0,468 # 80007848 <syscalls+0x328>
    8000467c:	1f6010ef          	jal	ra,80005872 <panic>
    panic("unlink: writei");
    80004680:	00003517          	auipc	a0,0x3
    80004684:	1e050513          	addi	a0,a0,480 # 80007860 <syscalls+0x340>
    80004688:	1ea010ef          	jal	ra,80005872 <panic>
    dp->nlink--;
    8000468c:	04a4d783          	lhu	a5,74(s1)
    80004690:	37fd                	addiw	a5,a5,-1
    80004692:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004696:	8526                	mv	a0,s1
    80004698:	c4afe0ef          	jal	ra,80002ae2 <iupdate>
    8000469c:	b7a5                	j	80004604 <sys_unlink+0xb8>
    return -1;
    8000469e:	557d                	li	a0,-1
    800046a0:	a811                	j	800046b4 <sys_unlink+0x168>
    iunlockput(ip);
    800046a2:	854a                	mv	a0,s2
    800046a4:	ef6fe0ef          	jal	ra,80002d9a <iunlockput>
  iunlockput(dp);
    800046a8:	8526                	mv	a0,s1
    800046aa:	ef0fe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    800046ae:	de1fe0ef          	jal	ra,8000348e <end_op>
  return -1;
    800046b2:	557d                	li	a0,-1
}
    800046b4:	70ae                	ld	ra,232(sp)
    800046b6:	740e                	ld	s0,224(sp)
    800046b8:	64ee                	ld	s1,216(sp)
    800046ba:	694e                	ld	s2,208(sp)
    800046bc:	69ae                	ld	s3,200(sp)
    800046be:	616d                	addi	sp,sp,240
    800046c0:	8082                	ret

00000000800046c2 <sys_open>:

uint64
sys_open(void)
{
    800046c2:	7131                	addi	sp,sp,-192
    800046c4:	fd06                	sd	ra,184(sp)
    800046c6:	f922                	sd	s0,176(sp)
    800046c8:	f526                	sd	s1,168(sp)
    800046ca:	f14a                	sd	s2,160(sp)
    800046cc:	ed4e                	sd	s3,152(sp)
    800046ce:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800046d0:	f4c40593          	addi	a1,s0,-180
    800046d4:	4505                	li	a0,1
    800046d6:	a5dfd0ef          	jal	ra,80002132 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800046da:	08000613          	li	a2,128
    800046de:	f5040593          	addi	a1,s0,-176
    800046e2:	4501                	li	a0,0
    800046e4:	a87fd0ef          	jal	ra,8000216a <argstr>
    800046e8:	87aa                	mv	a5,a0
    return -1;
    800046ea:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800046ec:	0807cd63          	bltz	a5,80004786 <sys_open+0xc4>

  begin_op();
    800046f0:	d2ffe0ef          	jal	ra,8000341e <begin_op>

  if(omode & O_CREATE){
    800046f4:	f4c42783          	lw	a5,-180(s0)
    800046f8:	2007f793          	andi	a5,a5,512
    800046fc:	c3c5                	beqz	a5,8000479c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800046fe:	4681                	li	a3,0
    80004700:	4601                	li	a2,0
    80004702:	4589                	li	a1,2
    80004704:	f5040513          	addi	a0,s0,-176
    80004708:	ac1ff0ef          	jal	ra,800041c8 <create>
    8000470c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000470e:	c159                	beqz	a0,80004794 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004710:	04449703          	lh	a4,68(s1)
    80004714:	478d                	li	a5,3
    80004716:	00f71763          	bne	a4,a5,80004724 <sys_open+0x62>
    8000471a:	0464d703          	lhu	a4,70(s1)
    8000471e:	47a5                	li	a5,9
    80004720:	0ae7e963          	bltu	a5,a4,800047d2 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004724:	872ff0ef          	jal	ra,80003796 <filealloc>
    80004728:	89aa                	mv	s3,a0
    8000472a:	0c050963          	beqz	a0,800047fc <sys_open+0x13a>
    8000472e:	a5dff0ef          	jal	ra,8000418a <fdalloc>
    80004732:	892a                	mv	s2,a0
    80004734:	0c054163          	bltz	a0,800047f6 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004738:	04449703          	lh	a4,68(s1)
    8000473c:	478d                	li	a5,3
    8000473e:	0af70163          	beq	a4,a5,800047e0 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004742:	4789                	li	a5,2
    80004744:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004748:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000474c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004750:	f4c42783          	lw	a5,-180(s0)
    80004754:	0017c713          	xori	a4,a5,1
    80004758:	8b05                	andi	a4,a4,1
    8000475a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000475e:	0037f713          	andi	a4,a5,3
    80004762:	00e03733          	snez	a4,a4
    80004766:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000476a:	4007f793          	andi	a5,a5,1024
    8000476e:	c791                	beqz	a5,8000477a <sys_open+0xb8>
    80004770:	04449703          	lh	a4,68(s1)
    80004774:	4789                	li	a5,2
    80004776:	06f70c63          	beq	a4,a5,800047ee <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    8000477a:	8526                	mv	a0,s1
    8000477c:	cc2fe0ef          	jal	ra,80002c3e <iunlock>
  end_op();
    80004780:	d0ffe0ef          	jal	ra,8000348e <end_op>

  return fd;
    80004784:	854a                	mv	a0,s2
}
    80004786:	70ea                	ld	ra,184(sp)
    80004788:	744a                	ld	s0,176(sp)
    8000478a:	74aa                	ld	s1,168(sp)
    8000478c:	790a                	ld	s2,160(sp)
    8000478e:	69ea                	ld	s3,152(sp)
    80004790:	6129                	addi	sp,sp,192
    80004792:	8082                	ret
      end_op();
    80004794:	cfbfe0ef          	jal	ra,8000348e <end_op>
      return -1;
    80004798:	557d                	li	a0,-1
    8000479a:	b7f5                	j	80004786 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    8000479c:	f5040513          	addi	a0,s0,-176
    800047a0:	aa7fe0ef          	jal	ra,80003246 <namei>
    800047a4:	84aa                	mv	s1,a0
    800047a6:	c115                	beqz	a0,800047ca <sys_open+0x108>
    ilock(ip);
    800047a8:	becfe0ef          	jal	ra,80002b94 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800047ac:	04449703          	lh	a4,68(s1)
    800047b0:	4785                	li	a5,1
    800047b2:	f4f71fe3          	bne	a4,a5,80004710 <sys_open+0x4e>
    800047b6:	f4c42783          	lw	a5,-180(s0)
    800047ba:	d7ad                	beqz	a5,80004724 <sys_open+0x62>
      iunlockput(ip);
    800047bc:	8526                	mv	a0,s1
    800047be:	ddcfe0ef          	jal	ra,80002d9a <iunlockput>
      end_op();
    800047c2:	ccdfe0ef          	jal	ra,8000348e <end_op>
      return -1;
    800047c6:	557d                	li	a0,-1
    800047c8:	bf7d                	j	80004786 <sys_open+0xc4>
      end_op();
    800047ca:	cc5fe0ef          	jal	ra,8000348e <end_op>
      return -1;
    800047ce:	557d                	li	a0,-1
    800047d0:	bf5d                	j	80004786 <sys_open+0xc4>
    iunlockput(ip);
    800047d2:	8526                	mv	a0,s1
    800047d4:	dc6fe0ef          	jal	ra,80002d9a <iunlockput>
    end_op();
    800047d8:	cb7fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    800047dc:	557d                	li	a0,-1
    800047de:	b765                	j	80004786 <sys_open+0xc4>
    f->type = FD_DEVICE;
    800047e0:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800047e4:	04649783          	lh	a5,70(s1)
    800047e8:	02f99223          	sh	a5,36(s3)
    800047ec:	b785                	j	8000474c <sys_open+0x8a>
    itrunc(ip);
    800047ee:	8526                	mv	a0,s1
    800047f0:	c8efe0ef          	jal	ra,80002c7e <itrunc>
    800047f4:	b759                	j	8000477a <sys_open+0xb8>
      fileclose(f);
    800047f6:	854e                	mv	a0,s3
    800047f8:	842ff0ef          	jal	ra,8000383a <fileclose>
    iunlockput(ip);
    800047fc:	8526                	mv	a0,s1
    800047fe:	d9cfe0ef          	jal	ra,80002d9a <iunlockput>
    end_op();
    80004802:	c8dfe0ef          	jal	ra,8000348e <end_op>
    return -1;
    80004806:	557d                	li	a0,-1
    80004808:	bfbd                	j	80004786 <sys_open+0xc4>

000000008000480a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000480a:	7175                	addi	sp,sp,-144
    8000480c:	e506                	sd	ra,136(sp)
    8000480e:	e122                	sd	s0,128(sp)
    80004810:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004812:	c0dfe0ef          	jal	ra,8000341e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004816:	08000613          	li	a2,128
    8000481a:	f7040593          	addi	a1,s0,-144
    8000481e:	4501                	li	a0,0
    80004820:	94bfd0ef          	jal	ra,8000216a <argstr>
    80004824:	02054363          	bltz	a0,8000484a <sys_mkdir+0x40>
    80004828:	4681                	li	a3,0
    8000482a:	4601                	li	a2,0
    8000482c:	4585                	li	a1,1
    8000482e:	f7040513          	addi	a0,s0,-144
    80004832:	997ff0ef          	jal	ra,800041c8 <create>
    80004836:	c911                	beqz	a0,8000484a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004838:	d62fe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    8000483c:	c53fe0ef          	jal	ra,8000348e <end_op>
  return 0;
    80004840:	4501                	li	a0,0
}
    80004842:	60aa                	ld	ra,136(sp)
    80004844:	640a                	ld	s0,128(sp)
    80004846:	6149                	addi	sp,sp,144
    80004848:	8082                	ret
    end_op();
    8000484a:	c45fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    8000484e:	557d                	li	a0,-1
    80004850:	bfcd                	j	80004842 <sys_mkdir+0x38>

0000000080004852 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004852:	7135                	addi	sp,sp,-160
    80004854:	ed06                	sd	ra,152(sp)
    80004856:	e922                	sd	s0,144(sp)
    80004858:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000485a:	bc5fe0ef          	jal	ra,8000341e <begin_op>
  argint(1, &major);
    8000485e:	f6c40593          	addi	a1,s0,-148
    80004862:	4505                	li	a0,1
    80004864:	8cffd0ef          	jal	ra,80002132 <argint>
  argint(2, &minor);
    80004868:	f6840593          	addi	a1,s0,-152
    8000486c:	4509                	li	a0,2
    8000486e:	8c5fd0ef          	jal	ra,80002132 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004872:	08000613          	li	a2,128
    80004876:	f7040593          	addi	a1,s0,-144
    8000487a:	4501                	li	a0,0
    8000487c:	8effd0ef          	jal	ra,8000216a <argstr>
    80004880:	02054563          	bltz	a0,800048aa <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004884:	f6841683          	lh	a3,-152(s0)
    80004888:	f6c41603          	lh	a2,-148(s0)
    8000488c:	458d                	li	a1,3
    8000488e:	f7040513          	addi	a0,s0,-144
    80004892:	937ff0ef          	jal	ra,800041c8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004896:	c911                	beqz	a0,800048aa <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004898:	d02fe0ef          	jal	ra,80002d9a <iunlockput>
  end_op();
    8000489c:	bf3fe0ef          	jal	ra,8000348e <end_op>
  return 0;
    800048a0:	4501                	li	a0,0
}
    800048a2:	60ea                	ld	ra,152(sp)
    800048a4:	644a                	ld	s0,144(sp)
    800048a6:	610d                	addi	sp,sp,160
    800048a8:	8082                	ret
    end_op();
    800048aa:	be5fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    800048ae:	557d                	li	a0,-1
    800048b0:	bfcd                	j	800048a2 <sys_mknod+0x50>

00000000800048b2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800048b2:	7135                	addi	sp,sp,-160
    800048b4:	ed06                	sd	ra,152(sp)
    800048b6:	e922                	sd	s0,144(sp)
    800048b8:	e526                	sd	s1,136(sp)
    800048ba:	e14a                	sd	s2,128(sp)
    800048bc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800048be:	927fc0ef          	jal	ra,800011e4 <myproc>
    800048c2:	892a                	mv	s2,a0
  
  begin_op();
    800048c4:	b5bfe0ef          	jal	ra,8000341e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800048c8:	08000613          	li	a2,128
    800048cc:	f6040593          	addi	a1,s0,-160
    800048d0:	4501                	li	a0,0
    800048d2:	899fd0ef          	jal	ra,8000216a <argstr>
    800048d6:	04054163          	bltz	a0,80004918 <sys_chdir+0x66>
    800048da:	f6040513          	addi	a0,s0,-160
    800048de:	969fe0ef          	jal	ra,80003246 <namei>
    800048e2:	84aa                	mv	s1,a0
    800048e4:	c915                	beqz	a0,80004918 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800048e6:	aaefe0ef          	jal	ra,80002b94 <ilock>
  if(ip->type != T_DIR){
    800048ea:	04449703          	lh	a4,68(s1)
    800048ee:	4785                	li	a5,1
    800048f0:	02f71863          	bne	a4,a5,80004920 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800048f4:	8526                	mv	a0,s1
    800048f6:	b48fe0ef          	jal	ra,80002c3e <iunlock>
  iput(p->cwd);
    800048fa:	15093503          	ld	a0,336(s2)
    800048fe:	c14fe0ef          	jal	ra,80002d12 <iput>
  end_op();
    80004902:	b8dfe0ef          	jal	ra,8000348e <end_op>
  p->cwd = ip;
    80004906:	14993823          	sd	s1,336(s2)
  return 0;
    8000490a:	4501                	li	a0,0
}
    8000490c:	60ea                	ld	ra,152(sp)
    8000490e:	644a                	ld	s0,144(sp)
    80004910:	64aa                	ld	s1,136(sp)
    80004912:	690a                	ld	s2,128(sp)
    80004914:	610d                	addi	sp,sp,160
    80004916:	8082                	ret
    end_op();
    80004918:	b77fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    8000491c:	557d                	li	a0,-1
    8000491e:	b7fd                	j	8000490c <sys_chdir+0x5a>
    iunlockput(ip);
    80004920:	8526                	mv	a0,s1
    80004922:	c78fe0ef          	jal	ra,80002d9a <iunlockput>
    end_op();
    80004926:	b69fe0ef          	jal	ra,8000348e <end_op>
    return -1;
    8000492a:	557d                	li	a0,-1
    8000492c:	b7c5                	j	8000490c <sys_chdir+0x5a>

000000008000492e <sys_exec>:

uint64
sys_exec(void)
{
    8000492e:	7145                	addi	sp,sp,-464
    80004930:	e786                	sd	ra,456(sp)
    80004932:	e3a2                	sd	s0,448(sp)
    80004934:	ff26                	sd	s1,440(sp)
    80004936:	fb4a                	sd	s2,432(sp)
    80004938:	f74e                	sd	s3,424(sp)
    8000493a:	f352                	sd	s4,416(sp)
    8000493c:	ef56                	sd	s5,408(sp)
    8000493e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004940:	e3840593          	addi	a1,s0,-456
    80004944:	4505                	li	a0,1
    80004946:	809fd0ef          	jal	ra,8000214e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000494a:	08000613          	li	a2,128
    8000494e:	f4040593          	addi	a1,s0,-192
    80004952:	4501                	li	a0,0
    80004954:	817fd0ef          	jal	ra,8000216a <argstr>
    80004958:	87aa                	mv	a5,a0
    return -1;
    8000495a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000495c:	0a07c463          	bltz	a5,80004a04 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80004960:	10000613          	li	a2,256
    80004964:	4581                	li	a1,0
    80004966:	e4040513          	addi	a0,s0,-448
    8000496a:	8d1fb0ef          	jal	ra,8000023a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000496e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004972:	89a6                	mv	s3,s1
    80004974:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004976:	02000a13          	li	s4,32
    8000497a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000497e:	00391513          	slli	a0,s2,0x3
    80004982:	e3040593          	addi	a1,s0,-464
    80004986:	e3843783          	ld	a5,-456(s0)
    8000498a:	953e                	add	a0,a0,a5
    8000498c:	f1cfd0ef          	jal	ra,800020a8 <fetchaddr>
    80004990:	02054663          	bltz	a0,800049bc <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80004994:	e3043783          	ld	a5,-464(s0)
    80004998:	cf8d                	beqz	a5,800049d2 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000499a:	ee8fb0ef          	jal	ra,80000082 <kalloc>
    8000499e:	85aa                	mv	a1,a0
    800049a0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800049a4:	cd01                	beqz	a0,800049bc <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800049a6:	6605                	lui	a2,0x1
    800049a8:	e3043503          	ld	a0,-464(s0)
    800049ac:	f46fd0ef          	jal	ra,800020f2 <fetchstr>
    800049b0:	00054663          	bltz	a0,800049bc <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800049b4:	0905                	addi	s2,s2,1
    800049b6:	09a1                	addi	s3,s3,8
    800049b8:	fd4911e3          	bne	s2,s4,8000497a <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800049bc:	10048913          	addi	s2,s1,256
    800049c0:	6088                	ld	a0,0(s1)
    800049c2:	c121                	beqz	a0,80004a02 <sys_exec+0xd4>
    kfree(argv[i]);
    800049c4:	e58fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800049c8:	04a1                	addi	s1,s1,8
    800049ca:	ff249be3          	bne	s1,s2,800049c0 <sys_exec+0x92>
  return -1;
    800049ce:	557d                	li	a0,-1
    800049d0:	a815                	j	80004a04 <sys_exec+0xd6>
      argv[i] = 0;
    800049d2:	0a8e                	slli	s5,s5,0x3
    800049d4:	fc040793          	addi	a5,s0,-64
    800049d8:	9abe                	add	s5,s5,a5
    800049da:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800049de:	e4040593          	addi	a1,s0,-448
    800049e2:	f4040513          	addi	a0,s0,-192
    800049e6:	c04ff0ef          	jal	ra,80003dea <exec>
    800049ea:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800049ec:	10048993          	addi	s3,s1,256
    800049f0:	6088                	ld	a0,0(s1)
    800049f2:	c511                	beqz	a0,800049fe <sys_exec+0xd0>
    kfree(argv[i]);
    800049f4:	e28fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800049f8:	04a1                	addi	s1,s1,8
    800049fa:	ff349be3          	bne	s1,s3,800049f0 <sys_exec+0xc2>
  return ret;
    800049fe:	854a                	mv	a0,s2
    80004a00:	a011                	j	80004a04 <sys_exec+0xd6>
  return -1;
    80004a02:	557d                	li	a0,-1
}
    80004a04:	60be                	ld	ra,456(sp)
    80004a06:	641e                	ld	s0,448(sp)
    80004a08:	74fa                	ld	s1,440(sp)
    80004a0a:	795a                	ld	s2,432(sp)
    80004a0c:	79ba                	ld	s3,424(sp)
    80004a0e:	7a1a                	ld	s4,416(sp)
    80004a10:	6afa                	ld	s5,408(sp)
    80004a12:	6179                	addi	sp,sp,464
    80004a14:	8082                	ret

0000000080004a16 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004a16:	7139                	addi	sp,sp,-64
    80004a18:	fc06                	sd	ra,56(sp)
    80004a1a:	f822                	sd	s0,48(sp)
    80004a1c:	f426                	sd	s1,40(sp)
    80004a1e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004a20:	fc4fc0ef          	jal	ra,800011e4 <myproc>
    80004a24:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004a26:	fd840593          	addi	a1,s0,-40
    80004a2a:	4501                	li	a0,0
    80004a2c:	f22fd0ef          	jal	ra,8000214e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004a30:	fc840593          	addi	a1,s0,-56
    80004a34:	fd040513          	addi	a0,s0,-48
    80004a38:	8ceff0ef          	jal	ra,80003b06 <pipealloc>
    return -1;
    80004a3c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004a3e:	0a054463          	bltz	a0,80004ae6 <sys_pipe+0xd0>
  fd0 = -1;
    80004a42:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004a46:	fd043503          	ld	a0,-48(s0)
    80004a4a:	f40ff0ef          	jal	ra,8000418a <fdalloc>
    80004a4e:	fca42223          	sw	a0,-60(s0)
    80004a52:	08054163          	bltz	a0,80004ad4 <sys_pipe+0xbe>
    80004a56:	fc843503          	ld	a0,-56(s0)
    80004a5a:	f30ff0ef          	jal	ra,8000418a <fdalloc>
    80004a5e:	fca42023          	sw	a0,-64(s0)
    80004a62:	06054063          	bltz	a0,80004ac2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004a66:	4691                	li	a3,4
    80004a68:	fc440613          	addi	a2,s0,-60
    80004a6c:	fd843583          	ld	a1,-40(s0)
    80004a70:	68a8                	ld	a0,80(s1)
    80004a72:	beafc0ef          	jal	ra,80000e5c <copyout>
    80004a76:	00054e63          	bltz	a0,80004a92 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004a7a:	4691                	li	a3,4
    80004a7c:	fc040613          	addi	a2,s0,-64
    80004a80:	fd843583          	ld	a1,-40(s0)
    80004a84:	0591                	addi	a1,a1,4
    80004a86:	68a8                	ld	a0,80(s1)
    80004a88:	bd4fc0ef          	jal	ra,80000e5c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004a8c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004a8e:	04055c63          	bgez	a0,80004ae6 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004a92:	fc442783          	lw	a5,-60(s0)
    80004a96:	07e9                	addi	a5,a5,26
    80004a98:	078e                	slli	a5,a5,0x3
    80004a9a:	97a6                	add	a5,a5,s1
    80004a9c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004aa0:	fc042503          	lw	a0,-64(s0)
    80004aa4:	0569                	addi	a0,a0,26
    80004aa6:	050e                	slli	a0,a0,0x3
    80004aa8:	94aa                	add	s1,s1,a0
    80004aaa:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004aae:	fd043503          	ld	a0,-48(s0)
    80004ab2:	d89fe0ef          	jal	ra,8000383a <fileclose>
    fileclose(wf);
    80004ab6:	fc843503          	ld	a0,-56(s0)
    80004aba:	d81fe0ef          	jal	ra,8000383a <fileclose>
    return -1;
    80004abe:	57fd                	li	a5,-1
    80004ac0:	a01d                	j	80004ae6 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004ac2:	fc442783          	lw	a5,-60(s0)
    80004ac6:	0007c763          	bltz	a5,80004ad4 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80004aca:	07e9                	addi	a5,a5,26
    80004acc:	078e                	slli	a5,a5,0x3
    80004ace:	94be                	add	s1,s1,a5
    80004ad0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004ad4:	fd043503          	ld	a0,-48(s0)
    80004ad8:	d63fe0ef          	jal	ra,8000383a <fileclose>
    fileclose(wf);
    80004adc:	fc843503          	ld	a0,-56(s0)
    80004ae0:	d5bfe0ef          	jal	ra,8000383a <fileclose>
    return -1;
    80004ae4:	57fd                	li	a5,-1
}
    80004ae6:	853e                	mv	a0,a5
    80004ae8:	70e2                	ld	ra,56(sp)
    80004aea:	7442                	ld	s0,48(sp)
    80004aec:	74a2                	ld	s1,40(sp)
    80004aee:	6121                	addi	sp,sp,64
    80004af0:	8082                	ret
	...

0000000080004b00 <kernelvec>:
    80004b00:	7111                	addi	sp,sp,-256
    80004b02:	e006                	sd	ra,0(sp)
    80004b04:	e40a                	sd	sp,8(sp)
    80004b06:	e80e                	sd	gp,16(sp)
    80004b08:	ec12                	sd	tp,24(sp)
    80004b0a:	f016                	sd	t0,32(sp)
    80004b0c:	f41a                	sd	t1,40(sp)
    80004b0e:	f81e                	sd	t2,48(sp)
    80004b10:	e4aa                	sd	a0,72(sp)
    80004b12:	e8ae                	sd	a1,80(sp)
    80004b14:	ecb2                	sd	a2,88(sp)
    80004b16:	f0b6                	sd	a3,96(sp)
    80004b18:	f4ba                	sd	a4,104(sp)
    80004b1a:	f8be                	sd	a5,112(sp)
    80004b1c:	fcc2                	sd	a6,120(sp)
    80004b1e:	e146                	sd	a7,128(sp)
    80004b20:	edf2                	sd	t3,216(sp)
    80004b22:	f1f6                	sd	t4,224(sp)
    80004b24:	f5fa                	sd	t5,232(sp)
    80004b26:	f9fe                	sd	t6,240(sp)
    80004b28:	c90fd0ef          	jal	ra,80001fb8 <kerneltrap>
    80004b2c:	6082                	ld	ra,0(sp)
    80004b2e:	6122                	ld	sp,8(sp)
    80004b30:	61c2                	ld	gp,16(sp)
    80004b32:	7282                	ld	t0,32(sp)
    80004b34:	7322                	ld	t1,40(sp)
    80004b36:	73c2                	ld	t2,48(sp)
    80004b38:	6526                	ld	a0,72(sp)
    80004b3a:	65c6                	ld	a1,80(sp)
    80004b3c:	6666                	ld	a2,88(sp)
    80004b3e:	7686                	ld	a3,96(sp)
    80004b40:	7726                	ld	a4,104(sp)
    80004b42:	77c6                	ld	a5,112(sp)
    80004b44:	7866                	ld	a6,120(sp)
    80004b46:	688a                	ld	a7,128(sp)
    80004b48:	6e6e                	ld	t3,216(sp)
    80004b4a:	7e8e                	ld	t4,224(sp)
    80004b4c:	7f2e                	ld	t5,232(sp)
    80004b4e:	7fce                	ld	t6,240(sp)
    80004b50:	6111                	addi	sp,sp,256
    80004b52:	10200073          	sret
	...

0000000080004b5e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80004b5e:	1141                	addi	sp,sp,-16
    80004b60:	e422                	sd	s0,8(sp)
    80004b62:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004b64:	0c0007b7          	lui	a5,0xc000
    80004b68:	4705                	li	a4,1
    80004b6a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80004b6c:	c3d8                	sw	a4,4(a5)
}
    80004b6e:	6422                	ld	s0,8(sp)
    80004b70:	0141                	addi	sp,sp,16
    80004b72:	8082                	ret

0000000080004b74 <plicinithart>:

void
plicinithart(void)
{
    80004b74:	1141                	addi	sp,sp,-16
    80004b76:	e406                	sd	ra,8(sp)
    80004b78:	e022                	sd	s0,0(sp)
    80004b7a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004b7c:	e3cfc0ef          	jal	ra,800011b8 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004b80:	0085171b          	slliw	a4,a0,0x8
    80004b84:	0c0027b7          	lui	a5,0xc002
    80004b88:	97ba                	add	a5,a5,a4
    80004b8a:	40200713          	li	a4,1026
    80004b8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004b92:	00d5151b          	slliw	a0,a0,0xd
    80004b96:	0c2017b7          	lui	a5,0xc201
    80004b9a:	953e                	add	a0,a0,a5
    80004b9c:	00052023          	sw	zero,0(a0)
}
    80004ba0:	60a2                	ld	ra,8(sp)
    80004ba2:	6402                	ld	s0,0(sp)
    80004ba4:	0141                	addi	sp,sp,16
    80004ba6:	8082                	ret

0000000080004ba8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004ba8:	1141                	addi	sp,sp,-16
    80004baa:	e406                	sd	ra,8(sp)
    80004bac:	e022                	sd	s0,0(sp)
    80004bae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004bb0:	e08fc0ef          	jal	ra,800011b8 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004bb4:	00d5179b          	slliw	a5,a0,0xd
    80004bb8:	0c201537          	lui	a0,0xc201
    80004bbc:	953e                	add	a0,a0,a5
  return irq;
}
    80004bbe:	4148                	lw	a0,4(a0)
    80004bc0:	60a2                	ld	ra,8(sp)
    80004bc2:	6402                	ld	s0,0(sp)
    80004bc4:	0141                	addi	sp,sp,16
    80004bc6:	8082                	ret

0000000080004bc8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004bc8:	1101                	addi	sp,sp,-32
    80004bca:	ec06                	sd	ra,24(sp)
    80004bcc:	e822                	sd	s0,16(sp)
    80004bce:	e426                	sd	s1,8(sp)
    80004bd0:	1000                	addi	s0,sp,32
    80004bd2:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004bd4:	de4fc0ef          	jal	ra,800011b8 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80004bd8:	00d5151b          	slliw	a0,a0,0xd
    80004bdc:	0c2017b7          	lui	a5,0xc201
    80004be0:	97aa                	add	a5,a5,a0
    80004be2:	c3c4                	sw	s1,4(a5)
}
    80004be4:	60e2                	ld	ra,24(sp)
    80004be6:	6442                	ld	s0,16(sp)
    80004be8:	64a2                	ld	s1,8(sp)
    80004bea:	6105                	addi	sp,sp,32
    80004bec:	8082                	ret

0000000080004bee <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004bee:	1141                	addi	sp,sp,-16
    80004bf0:	e406                	sd	ra,8(sp)
    80004bf2:	e022                	sd	s0,0(sp)
    80004bf4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80004bf6:	479d                	li	a5,7
    80004bf8:	04a7ca63          	blt	a5,a0,80004c4c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004bfc:	00014797          	auipc	a5,0x14
    80004c00:	f6c78793          	addi	a5,a5,-148 # 80018b68 <disk>
    80004c04:	97aa                	add	a5,a5,a0
    80004c06:	0187c783          	lbu	a5,24(a5)
    80004c0a:	e7b9                	bnez	a5,80004c58 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004c0c:	00451613          	slli	a2,a0,0x4
    80004c10:	00014797          	auipc	a5,0x14
    80004c14:	f5878793          	addi	a5,a5,-168 # 80018b68 <disk>
    80004c18:	6394                	ld	a3,0(a5)
    80004c1a:	96b2                	add	a3,a3,a2
    80004c1c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80004c20:	6398                	ld	a4,0(a5)
    80004c22:	9732                	add	a4,a4,a2
    80004c24:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80004c28:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004c2c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004c30:	953e                	add	a0,a0,a5
    80004c32:	4785                	li	a5,1
    80004c34:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80004c38:	00014517          	auipc	a0,0x14
    80004c3c:	f4850513          	addi	a0,a0,-184 # 80018b80 <disk+0x18>
    80004c40:	c5ffc0ef          	jal	ra,8000189e <wakeup>
}
    80004c44:	60a2                	ld	ra,8(sp)
    80004c46:	6402                	ld	s0,0(sp)
    80004c48:	0141                	addi	sp,sp,16
    80004c4a:	8082                	ret
    panic("free_desc 1");
    80004c4c:	00003517          	auipc	a0,0x3
    80004c50:	c2450513          	addi	a0,a0,-988 # 80007870 <syscalls+0x350>
    80004c54:	41f000ef          	jal	ra,80005872 <panic>
    panic("free_desc 2");
    80004c58:	00003517          	auipc	a0,0x3
    80004c5c:	c2850513          	addi	a0,a0,-984 # 80007880 <syscalls+0x360>
    80004c60:	413000ef          	jal	ra,80005872 <panic>

0000000080004c64 <virtio_disk_init>:
{
    80004c64:	1101                	addi	sp,sp,-32
    80004c66:	ec06                	sd	ra,24(sp)
    80004c68:	e822                	sd	s0,16(sp)
    80004c6a:	e426                	sd	s1,8(sp)
    80004c6c:	e04a                	sd	s2,0(sp)
    80004c6e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004c70:	00003597          	auipc	a1,0x3
    80004c74:	c2058593          	addi	a1,a1,-992 # 80007890 <syscalls+0x370>
    80004c78:	00014517          	auipc	a0,0x14
    80004c7c:	01850513          	addi	a0,a0,24 # 80018c90 <disk+0x128>
    80004c80:	68f000ef          	jal	ra,80005b0e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004c84:	100017b7          	lui	a5,0x10001
    80004c88:	4398                	lw	a4,0(a5)
    80004c8a:	2701                	sext.w	a4,a4
    80004c8c:	747277b7          	lui	a5,0x74727
    80004c90:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004c94:	14f71263          	bne	a4,a5,80004dd8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004c98:	100017b7          	lui	a5,0x10001
    80004c9c:	43dc                	lw	a5,4(a5)
    80004c9e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004ca0:	4709                	li	a4,2
    80004ca2:	12e79b63          	bne	a5,a4,80004dd8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004ca6:	100017b7          	lui	a5,0x10001
    80004caa:	479c                	lw	a5,8(a5)
    80004cac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004cae:	12e79563          	bne	a5,a4,80004dd8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004cb2:	100017b7          	lui	a5,0x10001
    80004cb6:	47d8                	lw	a4,12(a5)
    80004cb8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004cba:	554d47b7          	lui	a5,0x554d4
    80004cbe:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004cc2:	10f71b63          	bne	a4,a5,80004dd8 <virtio_disk_init+0x174>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004cc6:	100017b7          	lui	a5,0x10001
    80004cca:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004cce:	4705                	li	a4,1
    80004cd0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004cd2:	470d                	li	a4,3
    80004cd4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004cd6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004cd8:	c7ffe737          	lui	a4,0xc7ffe
    80004cdc:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd9af>
    80004ce0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004ce2:	2701                	sext.w	a4,a4
    80004ce4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004ce6:	472d                	li	a4,11
    80004ce8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80004cea:	0707a903          	lw	s2,112(a5)
    80004cee:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004cf0:	00897793          	andi	a5,s2,8
    80004cf4:	0e078863          	beqz	a5,80004de4 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004cf8:	100017b7          	lui	a5,0x10001
    80004cfc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004d00:	43fc                	lw	a5,68(a5)
    80004d02:	2781                	sext.w	a5,a5
    80004d04:	0e079663          	bnez	a5,80004df0 <virtio_disk_init+0x18c>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004d08:	100017b7          	lui	a5,0x10001
    80004d0c:	5bdc                	lw	a5,52(a5)
    80004d0e:	2781                	sext.w	a5,a5
  if(max == 0)
    80004d10:	0e078663          	beqz	a5,80004dfc <virtio_disk_init+0x198>
  if(max < NUM)
    80004d14:	471d                	li	a4,7
    80004d16:	0ef77963          	bgeu	a4,a5,80004e08 <virtio_disk_init+0x1a4>
  disk.desc = kalloc();
    80004d1a:	b68fb0ef          	jal	ra,80000082 <kalloc>
    80004d1e:	00014497          	auipc	s1,0x14
    80004d22:	e4a48493          	addi	s1,s1,-438 # 80018b68 <disk>
    80004d26:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004d28:	b5afb0ef          	jal	ra,80000082 <kalloc>
    80004d2c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004d2e:	b54fb0ef          	jal	ra,80000082 <kalloc>
    80004d32:	87aa                	mv	a5,a0
    80004d34:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004d36:	6088                	ld	a0,0(s1)
    80004d38:	cd71                	beqz	a0,80004e14 <virtio_disk_init+0x1b0>
    80004d3a:	00014717          	auipc	a4,0x14
    80004d3e:	e3673703          	ld	a4,-458(a4) # 80018b70 <disk+0x8>
    80004d42:	cb69                	beqz	a4,80004e14 <virtio_disk_init+0x1b0>
    80004d44:	cbe1                	beqz	a5,80004e14 <virtio_disk_init+0x1b0>
  memset(disk.desc, 0, PGSIZE);
    80004d46:	6605                	lui	a2,0x1
    80004d48:	4581                	li	a1,0
    80004d4a:	cf0fb0ef          	jal	ra,8000023a <memset>
  memset(disk.avail, 0, PGSIZE);
    80004d4e:	00014497          	auipc	s1,0x14
    80004d52:	e1a48493          	addi	s1,s1,-486 # 80018b68 <disk>
    80004d56:	6605                	lui	a2,0x1
    80004d58:	4581                	li	a1,0
    80004d5a:	6488                	ld	a0,8(s1)
    80004d5c:	cdefb0ef          	jal	ra,8000023a <memset>
  memset(disk.used, 0, PGSIZE);
    80004d60:	6605                	lui	a2,0x1
    80004d62:	4581                	li	a1,0
    80004d64:	6888                	ld	a0,16(s1)
    80004d66:	cd4fb0ef          	jal	ra,8000023a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004d6a:	100017b7          	lui	a5,0x10001
    80004d6e:	4721                	li	a4,8
    80004d70:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004d72:	4098                	lw	a4,0(s1)
    80004d74:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004d78:	40d8                	lw	a4,4(s1)
    80004d7a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004d7e:	6498                	ld	a4,8(s1)
    80004d80:	0007069b          	sext.w	a3,a4
    80004d84:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004d88:	9701                	srai	a4,a4,0x20
    80004d8a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004d8e:	6898                	ld	a4,16(s1)
    80004d90:	0007069b          	sext.w	a3,a4
    80004d94:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004d98:	9701                	srai	a4,a4,0x20
    80004d9a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004d9e:	4685                	li	a3,1
    80004da0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80004da2:	4705                	li	a4,1
    80004da4:	00d48c23          	sb	a3,24(s1)
    80004da8:	00e48ca3          	sb	a4,25(s1)
    80004dac:	00e48d23          	sb	a4,26(s1)
    80004db0:	00e48da3          	sb	a4,27(s1)
    80004db4:	00e48e23          	sb	a4,28(s1)
    80004db8:	00e48ea3          	sb	a4,29(s1)
    80004dbc:	00e48f23          	sb	a4,30(s1)
    80004dc0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004dc4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004dc8:	0727a823          	sw	s2,112(a5)
}
    80004dcc:	60e2                	ld	ra,24(sp)
    80004dce:	6442                	ld	s0,16(sp)
    80004dd0:	64a2                	ld	s1,8(sp)
    80004dd2:	6902                	ld	s2,0(sp)
    80004dd4:	6105                	addi	sp,sp,32
    80004dd6:	8082                	ret
    panic("could not find virtio disk");
    80004dd8:	00003517          	auipc	a0,0x3
    80004ddc:	ac850513          	addi	a0,a0,-1336 # 800078a0 <syscalls+0x380>
    80004de0:	293000ef          	jal	ra,80005872 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004de4:	00003517          	auipc	a0,0x3
    80004de8:	adc50513          	addi	a0,a0,-1316 # 800078c0 <syscalls+0x3a0>
    80004dec:	287000ef          	jal	ra,80005872 <panic>
    panic("virtio disk should not be ready");
    80004df0:	00003517          	auipc	a0,0x3
    80004df4:	af050513          	addi	a0,a0,-1296 # 800078e0 <syscalls+0x3c0>
    80004df8:	27b000ef          	jal	ra,80005872 <panic>
    panic("virtio disk has no queue 0");
    80004dfc:	00003517          	auipc	a0,0x3
    80004e00:	b0450513          	addi	a0,a0,-1276 # 80007900 <syscalls+0x3e0>
    80004e04:	26f000ef          	jal	ra,80005872 <panic>
    panic("virtio disk max queue too short");
    80004e08:	00003517          	auipc	a0,0x3
    80004e0c:	b1850513          	addi	a0,a0,-1256 # 80007920 <syscalls+0x400>
    80004e10:	263000ef          	jal	ra,80005872 <panic>
    panic("virtio disk kalloc");
    80004e14:	00003517          	auipc	a0,0x3
    80004e18:	b2c50513          	addi	a0,a0,-1236 # 80007940 <syscalls+0x420>
    80004e1c:	257000ef          	jal	ra,80005872 <panic>

0000000080004e20 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004e20:	7159                	addi	sp,sp,-112
    80004e22:	f486                	sd	ra,104(sp)
    80004e24:	f0a2                	sd	s0,96(sp)
    80004e26:	eca6                	sd	s1,88(sp)
    80004e28:	e8ca                	sd	s2,80(sp)
    80004e2a:	e4ce                	sd	s3,72(sp)
    80004e2c:	e0d2                	sd	s4,64(sp)
    80004e2e:	fc56                	sd	s5,56(sp)
    80004e30:	f85a                	sd	s6,48(sp)
    80004e32:	f45e                	sd	s7,40(sp)
    80004e34:	f062                	sd	s8,32(sp)
    80004e36:	ec66                	sd	s9,24(sp)
    80004e38:	e86a                	sd	s10,16(sp)
    80004e3a:	1880                	addi	s0,sp,112
    80004e3c:	892a                	mv	s2,a0
    80004e3e:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004e40:	00c52c83          	lw	s9,12(a0)
    80004e44:	001c9c9b          	slliw	s9,s9,0x1
    80004e48:	1c82                	slli	s9,s9,0x20
    80004e4a:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004e4e:	00014517          	auipc	a0,0x14
    80004e52:	e4250513          	addi	a0,a0,-446 # 80018c90 <disk+0x128>
    80004e56:	539000ef          	jal	ra,80005b8e <acquire>
  for(int i = 0; i < 3; i++){
    80004e5a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004e5c:	4ba1                	li	s7,8
      disk.free[i] = 0;
    80004e5e:	00014b17          	auipc	s6,0x14
    80004e62:	d0ab0b13          	addi	s6,s6,-758 # 80018b68 <disk>
  for(int i = 0; i < 3; i++){
    80004e66:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80004e68:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004e6a:	00014c17          	auipc	s8,0x14
    80004e6e:	e26c0c13          	addi	s8,s8,-474 # 80018c90 <disk+0x128>
    80004e72:	a0b5                	j	80004ede <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    80004e74:	00fb06b3          	add	a3,s6,a5
    80004e78:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80004e7c:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80004e7e:	0207c563          	bltz	a5,80004ea8 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004e82:	2485                	addiw	s1,s1,1
    80004e84:	0711                	addi	a4,a4,4
    80004e86:	1d548c63          	beq	s1,s5,8000505e <virtio_disk_rw+0x23e>
    idx[i] = alloc_desc();
    80004e8a:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80004e8c:	00014697          	auipc	a3,0x14
    80004e90:	cdc68693          	addi	a3,a3,-804 # 80018b68 <disk>
    80004e94:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80004e96:	0186c583          	lbu	a1,24(a3)
    80004e9a:	fde9                	bnez	a1,80004e74 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80004e9c:	2785                	addiw	a5,a5,1
    80004e9e:	0685                	addi	a3,a3,1
    80004ea0:	ff779be3          	bne	a5,s7,80004e96 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004ea4:	57fd                	li	a5,-1
    80004ea6:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80004ea8:	02905463          	blez	s1,80004ed0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    80004eac:	f9042503          	lw	a0,-112(s0)
    80004eb0:	d3fff0ef          	jal	ra,80004bee <free_desc>
      for(int j = 0; j < i; j++)
    80004eb4:	4785                	li	a5,1
    80004eb6:	0097dd63          	bge	a5,s1,80004ed0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    80004eba:	f9442503          	lw	a0,-108(s0)
    80004ebe:	d31ff0ef          	jal	ra,80004bee <free_desc>
      for(int j = 0; j < i; j++)
    80004ec2:	4789                	li	a5,2
    80004ec4:	0097d663          	bge	a5,s1,80004ed0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    80004ec8:	f9842503          	lw	a0,-104(s0)
    80004ecc:	d23ff0ef          	jal	ra,80004bee <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004ed0:	85e2                	mv	a1,s8
    80004ed2:	00014517          	auipc	a0,0x14
    80004ed6:	cae50513          	addi	a0,a0,-850 # 80018b80 <disk+0x18>
    80004eda:	979fc0ef          	jal	ra,80001852 <sleep>
  for(int i = 0; i < 3; i++){
    80004ede:	f9040713          	addi	a4,s0,-112
    80004ee2:	84ce                	mv	s1,s3
    80004ee4:	b75d                	j	80004e8a <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80004ee6:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80004eea:	00479693          	slli	a3,a5,0x4
    80004eee:	00014797          	auipc	a5,0x14
    80004ef2:	c7a78793          	addi	a5,a5,-902 # 80018b68 <disk>
    80004ef6:	97b6                	add	a5,a5,a3
    80004ef8:	4685                	li	a3,1
    80004efa:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004efc:	00014597          	auipc	a1,0x14
    80004f00:	c6c58593          	addi	a1,a1,-916 # 80018b68 <disk>
    80004f04:	00a60793          	addi	a5,a2,10
    80004f08:	0792                	slli	a5,a5,0x4
    80004f0a:	97ae                	add	a5,a5,a1
    80004f0c:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    80004f10:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004f14:	f6070693          	addi	a3,a4,-160
    80004f18:	619c                	ld	a5,0(a1)
    80004f1a:	97b6                	add	a5,a5,a3
    80004f1c:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004f1e:	6188                	ld	a0,0(a1)
    80004f20:	96aa                	add	a3,a3,a0
    80004f22:	47c1                	li	a5,16
    80004f24:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004f26:	4785                	li	a5,1
    80004f28:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80004f2c:	f9442783          	lw	a5,-108(s0)
    80004f30:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004f34:	0792                	slli	a5,a5,0x4
    80004f36:	953e                	add	a0,a0,a5
    80004f38:	05890693          	addi	a3,s2,88
    80004f3c:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80004f3e:	6188                	ld	a0,0(a1)
    80004f40:	97aa                	add	a5,a5,a0
    80004f42:	40000693          	li	a3,1024
    80004f46:	c794                	sw	a3,8(a5)
  if(write)
    80004f48:	100d0763          	beqz	s10,80005056 <virtio_disk_rw+0x236>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80004f4c:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004f50:	00c7d683          	lhu	a3,12(a5)
    80004f54:	0016e693          	ori	a3,a3,1
    80004f58:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80004f5c:	f9842583          	lw	a1,-104(s0)
    80004f60:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004f64:	00014697          	auipc	a3,0x14
    80004f68:	c0468693          	addi	a3,a3,-1020 # 80018b68 <disk>
    80004f6c:	00260793          	addi	a5,a2,2
    80004f70:	0792                	slli	a5,a5,0x4
    80004f72:	97b6                	add	a5,a5,a3
    80004f74:	587d                	li	a6,-1
    80004f76:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004f7a:	0592                	slli	a1,a1,0x4
    80004f7c:	952e                	add	a0,a0,a1
    80004f7e:	f9070713          	addi	a4,a4,-112
    80004f82:	9736                	add	a4,a4,a3
    80004f84:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80004f86:	6298                	ld	a4,0(a3)
    80004f88:	972e                	add	a4,a4,a1
    80004f8a:	4585                	li	a1,1
    80004f8c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004f8e:	4509                	li	a0,2
    80004f90:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80004f94:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004f98:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80004f9c:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004fa0:	6698                	ld	a4,8(a3)
    80004fa2:	00275783          	lhu	a5,2(a4)
    80004fa6:	8b9d                	andi	a5,a5,7
    80004fa8:	0786                	slli	a5,a5,0x1
    80004faa:	97ba                	add	a5,a5,a4
    80004fac:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    80004fb0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004fb4:	6698                	ld	a4,8(a3)
    80004fb6:	00275783          	lhu	a5,2(a4)
    80004fba:	2785                	addiw	a5,a5,1
    80004fbc:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004fc0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004fc4:	100017b7          	lui	a5,0x10001
    80004fc8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004fcc:	00492703          	lw	a4,4(s2)
    80004fd0:	4785                	li	a5,1
    80004fd2:	00f71f63          	bne	a4,a5,80004ff0 <virtio_disk_rw+0x1d0>
    sleep(b, &disk.vdisk_lock);
    80004fd6:	00014997          	auipc	s3,0x14
    80004fda:	cba98993          	addi	s3,s3,-838 # 80018c90 <disk+0x128>
  while(b->disk == 1) {
    80004fde:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80004fe0:	85ce                	mv	a1,s3
    80004fe2:	854a                	mv	a0,s2
    80004fe4:	86ffc0ef          	jal	ra,80001852 <sleep>
  while(b->disk == 1) {
    80004fe8:	00492783          	lw	a5,4(s2)
    80004fec:	fe978ae3          	beq	a5,s1,80004fe0 <virtio_disk_rw+0x1c0>
  }

  disk.info[idx[0]].b = 0;
    80004ff0:	f9042903          	lw	s2,-112(s0)
    80004ff4:	00290793          	addi	a5,s2,2
    80004ff8:	00479713          	slli	a4,a5,0x4
    80004ffc:	00014797          	auipc	a5,0x14
    80005000:	b6c78793          	addi	a5,a5,-1172 # 80018b68 <disk>
    80005004:	97ba                	add	a5,a5,a4
    80005006:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000500a:	00014997          	auipc	s3,0x14
    8000500e:	b5e98993          	addi	s3,s3,-1186 # 80018b68 <disk>
    80005012:	00491713          	slli	a4,s2,0x4
    80005016:	0009b783          	ld	a5,0(s3)
    8000501a:	97ba                	add	a5,a5,a4
    8000501c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005020:	854a                	mv	a0,s2
    80005022:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005026:	bc9ff0ef          	jal	ra,80004bee <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000502a:	8885                	andi	s1,s1,1
    8000502c:	f0fd                	bnez	s1,80005012 <virtio_disk_rw+0x1f2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000502e:	00014517          	auipc	a0,0x14
    80005032:	c6250513          	addi	a0,a0,-926 # 80018c90 <disk+0x128>
    80005036:	3f1000ef          	jal	ra,80005c26 <release>
}
    8000503a:	70a6                	ld	ra,104(sp)
    8000503c:	7406                	ld	s0,96(sp)
    8000503e:	64e6                	ld	s1,88(sp)
    80005040:	6946                	ld	s2,80(sp)
    80005042:	69a6                	ld	s3,72(sp)
    80005044:	6a06                	ld	s4,64(sp)
    80005046:	7ae2                	ld	s5,56(sp)
    80005048:	7b42                	ld	s6,48(sp)
    8000504a:	7ba2                	ld	s7,40(sp)
    8000504c:	7c02                	ld	s8,32(sp)
    8000504e:	6ce2                	ld	s9,24(sp)
    80005050:	6d42                	ld	s10,16(sp)
    80005052:	6165                	addi	sp,sp,112
    80005054:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005056:	4689                	li	a3,2
    80005058:	00d79623          	sh	a3,12(a5)
    8000505c:	bdd5                	j	80004f50 <virtio_disk_rw+0x130>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000505e:	f9042603          	lw	a2,-112(s0)
    80005062:	00a60713          	addi	a4,a2,10
    80005066:	0712                	slli	a4,a4,0x4
    80005068:	00014517          	auipc	a0,0x14
    8000506c:	b0850513          	addi	a0,a0,-1272 # 80018b70 <disk+0x8>
    80005070:	953a                	add	a0,a0,a4
  if(write)
    80005072:	e60d1ae3          	bnez	s10,80004ee6 <virtio_disk_rw+0xc6>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005076:	00a60793          	addi	a5,a2,10
    8000507a:	00479693          	slli	a3,a5,0x4
    8000507e:	00014797          	auipc	a5,0x14
    80005082:	aea78793          	addi	a5,a5,-1302 # 80018b68 <disk>
    80005086:	97b6                	add	a5,a5,a3
    80005088:	0007a423          	sw	zero,8(a5)
    8000508c:	bd85                	j	80004efc <virtio_disk_rw+0xdc>

000000008000508e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000508e:	1101                	addi	sp,sp,-32
    80005090:	ec06                	sd	ra,24(sp)
    80005092:	e822                	sd	s0,16(sp)
    80005094:	e426                	sd	s1,8(sp)
    80005096:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005098:	00014497          	auipc	s1,0x14
    8000509c:	ad048493          	addi	s1,s1,-1328 # 80018b68 <disk>
    800050a0:	00014517          	auipc	a0,0x14
    800050a4:	bf050513          	addi	a0,a0,-1040 # 80018c90 <disk+0x128>
    800050a8:	2e7000ef          	jal	ra,80005b8e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800050ac:	10001737          	lui	a4,0x10001
    800050b0:	533c                	lw	a5,96(a4)
    800050b2:	8b8d                	andi	a5,a5,3
    800050b4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800050b6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800050ba:	689c                	ld	a5,16(s1)
    800050bc:	0204d703          	lhu	a4,32(s1)
    800050c0:	0027d783          	lhu	a5,2(a5)
    800050c4:	04f70663          	beq	a4,a5,80005110 <virtio_disk_intr+0x82>
    __sync_synchronize();
    800050c8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800050cc:	6898                	ld	a4,16(s1)
    800050ce:	0204d783          	lhu	a5,32(s1)
    800050d2:	8b9d                	andi	a5,a5,7
    800050d4:	078e                	slli	a5,a5,0x3
    800050d6:	97ba                	add	a5,a5,a4
    800050d8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800050da:	00278713          	addi	a4,a5,2
    800050de:	0712                	slli	a4,a4,0x4
    800050e0:	9726                	add	a4,a4,s1
    800050e2:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800050e6:	e321                	bnez	a4,80005126 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800050e8:	0789                	addi	a5,a5,2
    800050ea:	0792                	slli	a5,a5,0x4
    800050ec:	97a6                	add	a5,a5,s1
    800050ee:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800050f0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800050f4:	faafc0ef          	jal	ra,8000189e <wakeup>

    disk.used_idx += 1;
    800050f8:	0204d783          	lhu	a5,32(s1)
    800050fc:	2785                	addiw	a5,a5,1
    800050fe:	17c2                	slli	a5,a5,0x30
    80005100:	93c1                	srli	a5,a5,0x30
    80005102:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005106:	6898                	ld	a4,16(s1)
    80005108:	00275703          	lhu	a4,2(a4)
    8000510c:	faf71ee3          	bne	a4,a5,800050c8 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005110:	00014517          	auipc	a0,0x14
    80005114:	b8050513          	addi	a0,a0,-1152 # 80018c90 <disk+0x128>
    80005118:	30f000ef          	jal	ra,80005c26 <release>
}
    8000511c:	60e2                	ld	ra,24(sp)
    8000511e:	6442                	ld	s0,16(sp)
    80005120:	64a2                	ld	s1,8(sp)
    80005122:	6105                	addi	sp,sp,32
    80005124:	8082                	ret
      panic("virtio_disk_intr status");
    80005126:	00003517          	auipc	a0,0x3
    8000512a:	83250513          	addi	a0,a0,-1998 # 80007958 <syscalls+0x438>
    8000512e:	744000ef          	jal	ra,80005872 <panic>

0000000080005132 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80005132:	1141                	addi	sp,sp,-16
    80005134:	e422                	sd	s0,8(sp)
    80005136:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005138:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    8000513c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80005140:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80005144:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80005148:	577d                	li	a4,-1
    8000514a:	177e                	slli	a4,a4,0x3f
    8000514c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000514e:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80005152:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80005156:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    8000515a:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    8000515e:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80005162:	000f4737          	lui	a4,0xf4
    80005166:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000516a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000516c:	14d79073          	csrw	0x14d,a5
}
    80005170:	6422                	ld	s0,8(sp)
    80005172:	0141                	addi	sp,sp,16
    80005174:	8082                	ret

0000000080005176 <start>:
{
    80005176:	1141                	addi	sp,sp,-16
    80005178:	e406                	sd	ra,8(sp)
    8000517a:	e022                	sd	s0,0(sp)
    8000517c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000517e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005182:	7779                	lui	a4,0xffffe
    80005184:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda4f>
    80005188:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000518a:	6705                	lui	a4,0x1
    8000518c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005190:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005192:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005196:	ffffb797          	auipc	a5,0xffffb
    8000519a:	24e78793          	addi	a5,a5,590 # 800003e4 <main>
    8000519e:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800051a2:	4781                	li	a5,0
    800051a4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800051a8:	67c1                	lui	a5,0x10
    800051aa:	17fd                	addi	a5,a5,-1
    800051ac:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800051b0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800051b4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800051b8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800051bc:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800051c0:	57fd                	li	a5,-1
    800051c2:	83a9                	srli	a5,a5,0xa
    800051c4:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800051c8:	47bd                	li	a5,15
    800051ca:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800051ce:	f65ff0ef          	jal	ra,80005132 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800051d2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800051d6:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800051d8:	823e                	mv	tp,a5
  asm volatile("mret");
    800051da:	30200073          	mret
}
    800051de:	60a2                	ld	ra,8(sp)
    800051e0:	6402                	ld	s0,0(sp)
    800051e2:	0141                	addi	sp,sp,16
    800051e4:	8082                	ret

00000000800051e6 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800051e6:	715d                	addi	sp,sp,-80
    800051e8:	e486                	sd	ra,72(sp)
    800051ea:	e0a2                	sd	s0,64(sp)
    800051ec:	fc26                	sd	s1,56(sp)
    800051ee:	f84a                	sd	s2,48(sp)
    800051f0:	f44e                	sd	s3,40(sp)
    800051f2:	f052                	sd	s4,32(sp)
    800051f4:	ec56                	sd	s5,24(sp)
    800051f6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800051f8:	04c05263          	blez	a2,8000523c <consolewrite+0x56>
    800051fc:	8a2a                	mv	s4,a0
    800051fe:	84ae                	mv	s1,a1
    80005200:	89b2                	mv	s3,a2
    80005202:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005204:	5afd                	li	s5,-1
    80005206:	4685                	li	a3,1
    80005208:	8626                	mv	a2,s1
    8000520a:	85d2                	mv	a1,s4
    8000520c:	fbf40513          	addi	a0,s0,-65
    80005210:	9e9fc0ef          	jal	ra,80001bf8 <either_copyin>
    80005214:	01550a63          	beq	a0,s5,80005228 <consolewrite+0x42>
      break;
    uartputc(c);
    80005218:	fbf44503          	lbu	a0,-65(s0)
    8000521c:	7e8000ef          	jal	ra,80005a04 <uartputc>
  for(i = 0; i < n; i++){
    80005220:	2905                	addiw	s2,s2,1
    80005222:	0485                	addi	s1,s1,1
    80005224:	ff2991e3          	bne	s3,s2,80005206 <consolewrite+0x20>
  }

  return i;
}
    80005228:	854a                	mv	a0,s2
    8000522a:	60a6                	ld	ra,72(sp)
    8000522c:	6406                	ld	s0,64(sp)
    8000522e:	74e2                	ld	s1,56(sp)
    80005230:	7942                	ld	s2,48(sp)
    80005232:	79a2                	ld	s3,40(sp)
    80005234:	7a02                	ld	s4,32(sp)
    80005236:	6ae2                	ld	s5,24(sp)
    80005238:	6161                	addi	sp,sp,80
    8000523a:	8082                	ret
  for(i = 0; i < n; i++){
    8000523c:	4901                	li	s2,0
    8000523e:	b7ed                	j	80005228 <consolewrite+0x42>

0000000080005240 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005240:	7119                	addi	sp,sp,-128
    80005242:	fc86                	sd	ra,120(sp)
    80005244:	f8a2                	sd	s0,112(sp)
    80005246:	f4a6                	sd	s1,104(sp)
    80005248:	f0ca                	sd	s2,96(sp)
    8000524a:	ecce                	sd	s3,88(sp)
    8000524c:	e8d2                	sd	s4,80(sp)
    8000524e:	e4d6                	sd	s5,72(sp)
    80005250:	e0da                	sd	s6,64(sp)
    80005252:	fc5e                	sd	s7,56(sp)
    80005254:	f862                	sd	s8,48(sp)
    80005256:	f466                	sd	s9,40(sp)
    80005258:	f06a                	sd	s10,32(sp)
    8000525a:	ec6e                	sd	s11,24(sp)
    8000525c:	0100                	addi	s0,sp,128
    8000525e:	8b2a                	mv	s6,a0
    80005260:	8aae                	mv	s5,a1
    80005262:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005264:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80005268:	0001c517          	auipc	a0,0x1c
    8000526c:	a4850513          	addi	a0,a0,-1464 # 80020cb0 <cons>
    80005270:	11f000ef          	jal	ra,80005b8e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005274:	0001c497          	auipc	s1,0x1c
    80005278:	a3c48493          	addi	s1,s1,-1476 # 80020cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000527c:	89a6                	mv	s3,s1
    8000527e:	0001c917          	auipc	s2,0x1c
    80005282:	aca90913          	addi	s2,s2,-1334 # 80020d48 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005286:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005288:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000528a:	4da9                	li	s11,10
  while(n > 0){
    8000528c:	07405363          	blez	s4,800052f2 <consoleread+0xb2>
    while(cons.r == cons.w){
    80005290:	0984a783          	lw	a5,152(s1)
    80005294:	09c4a703          	lw	a4,156(s1)
    80005298:	02f71163          	bne	a4,a5,800052ba <consoleread+0x7a>
      if(killed(myproc())){
    8000529c:	f49fb0ef          	jal	ra,800011e4 <myproc>
    800052a0:	feafc0ef          	jal	ra,80001a8a <killed>
    800052a4:	e125                	bnez	a0,80005304 <consoleread+0xc4>
      sleep(&cons.r, &cons.lock);
    800052a6:	85ce                	mv	a1,s3
    800052a8:	854a                	mv	a0,s2
    800052aa:	da8fc0ef          	jal	ra,80001852 <sleep>
    while(cons.r == cons.w){
    800052ae:	0984a783          	lw	a5,152(s1)
    800052b2:	09c4a703          	lw	a4,156(s1)
    800052b6:	fef703e3          	beq	a4,a5,8000529c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800052ba:	0017871b          	addiw	a4,a5,1
    800052be:	08e4ac23          	sw	a4,152(s1)
    800052c2:	07f7f713          	andi	a4,a5,127
    800052c6:	9726                	add	a4,a4,s1
    800052c8:	01874703          	lbu	a4,24(a4)
    800052cc:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800052d0:	079c0063          	beq	s8,s9,80005330 <consoleread+0xf0>
    cbuf = c;
    800052d4:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800052d8:	4685                	li	a3,1
    800052da:	f8f40613          	addi	a2,s0,-113
    800052de:	85d6                	mv	a1,s5
    800052e0:	855a                	mv	a0,s6
    800052e2:	8cdfc0ef          	jal	ra,80001bae <either_copyout>
    800052e6:	01a50663          	beq	a0,s10,800052f2 <consoleread+0xb2>
    dst++;
    800052ea:	0a85                	addi	s5,s5,1
    --n;
    800052ec:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800052ee:	f9bc1fe3          	bne	s8,s11,8000528c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800052f2:	0001c517          	auipc	a0,0x1c
    800052f6:	9be50513          	addi	a0,a0,-1602 # 80020cb0 <cons>
    800052fa:	12d000ef          	jal	ra,80005c26 <release>

  return target - n;
    800052fe:	414b853b          	subw	a0,s7,s4
    80005302:	a801                	j	80005312 <consoleread+0xd2>
        release(&cons.lock);
    80005304:	0001c517          	auipc	a0,0x1c
    80005308:	9ac50513          	addi	a0,a0,-1620 # 80020cb0 <cons>
    8000530c:	11b000ef          	jal	ra,80005c26 <release>
        return -1;
    80005310:	557d                	li	a0,-1
}
    80005312:	70e6                	ld	ra,120(sp)
    80005314:	7446                	ld	s0,112(sp)
    80005316:	74a6                	ld	s1,104(sp)
    80005318:	7906                	ld	s2,96(sp)
    8000531a:	69e6                	ld	s3,88(sp)
    8000531c:	6a46                	ld	s4,80(sp)
    8000531e:	6aa6                	ld	s5,72(sp)
    80005320:	6b06                	ld	s6,64(sp)
    80005322:	7be2                	ld	s7,56(sp)
    80005324:	7c42                	ld	s8,48(sp)
    80005326:	7ca2                	ld	s9,40(sp)
    80005328:	7d02                	ld	s10,32(sp)
    8000532a:	6de2                	ld	s11,24(sp)
    8000532c:	6109                	addi	sp,sp,128
    8000532e:	8082                	ret
      if(n < target){
    80005330:	000a071b          	sext.w	a4,s4
    80005334:	fb777fe3          	bgeu	a4,s7,800052f2 <consoleread+0xb2>
        cons.r--;
    80005338:	0001c717          	auipc	a4,0x1c
    8000533c:	a0f72823          	sw	a5,-1520(a4) # 80020d48 <cons+0x98>
    80005340:	bf4d                	j	800052f2 <consoleread+0xb2>

0000000080005342 <consputc>:
{
    80005342:	1141                	addi	sp,sp,-16
    80005344:	e406                	sd	ra,8(sp)
    80005346:	e022                	sd	s0,0(sp)
    80005348:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000534a:	10000793          	li	a5,256
    8000534e:	00f50863          	beq	a0,a5,8000535e <consputc+0x1c>
    uartputc_sync(c);
    80005352:	5d4000ef          	jal	ra,80005926 <uartputc_sync>
}
    80005356:	60a2                	ld	ra,8(sp)
    80005358:	6402                	ld	s0,0(sp)
    8000535a:	0141                	addi	sp,sp,16
    8000535c:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000535e:	4521                	li	a0,8
    80005360:	5c6000ef          	jal	ra,80005926 <uartputc_sync>
    80005364:	02000513          	li	a0,32
    80005368:	5be000ef          	jal	ra,80005926 <uartputc_sync>
    8000536c:	4521                	li	a0,8
    8000536e:	5b8000ef          	jal	ra,80005926 <uartputc_sync>
    80005372:	b7d5                	j	80005356 <consputc+0x14>

0000000080005374 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005374:	1101                	addi	sp,sp,-32
    80005376:	ec06                	sd	ra,24(sp)
    80005378:	e822                	sd	s0,16(sp)
    8000537a:	e426                	sd	s1,8(sp)
    8000537c:	e04a                	sd	s2,0(sp)
    8000537e:	1000                	addi	s0,sp,32
    80005380:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005382:	0001c517          	auipc	a0,0x1c
    80005386:	92e50513          	addi	a0,a0,-1746 # 80020cb0 <cons>
    8000538a:	005000ef          	jal	ra,80005b8e <acquire>

  switch(c){
    8000538e:	47d5                	li	a5,21
    80005390:	0af48063          	beq	s1,a5,80005430 <consoleintr+0xbc>
    80005394:	0297c663          	blt	a5,s1,800053c0 <consoleintr+0x4c>
    80005398:	47a1                	li	a5,8
    8000539a:	0cf48f63          	beq	s1,a5,80005478 <consoleintr+0x104>
    8000539e:	47c1                	li	a5,16
    800053a0:	10f49063          	bne	s1,a5,800054a0 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    800053a4:	89ffc0ef          	jal	ra,80001c42 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800053a8:	0001c517          	auipc	a0,0x1c
    800053ac:	90850513          	addi	a0,a0,-1784 # 80020cb0 <cons>
    800053b0:	077000ef          	jal	ra,80005c26 <release>
}
    800053b4:	60e2                	ld	ra,24(sp)
    800053b6:	6442                	ld	s0,16(sp)
    800053b8:	64a2                	ld	s1,8(sp)
    800053ba:	6902                	ld	s2,0(sp)
    800053bc:	6105                	addi	sp,sp,32
    800053be:	8082                	ret
  switch(c){
    800053c0:	07f00793          	li	a5,127
    800053c4:	0af48a63          	beq	s1,a5,80005478 <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800053c8:	0001c717          	auipc	a4,0x1c
    800053cc:	8e870713          	addi	a4,a4,-1816 # 80020cb0 <cons>
    800053d0:	0a072783          	lw	a5,160(a4)
    800053d4:	09872703          	lw	a4,152(a4)
    800053d8:	9f99                	subw	a5,a5,a4
    800053da:	07f00713          	li	a4,127
    800053de:	fcf765e3          	bltu	a4,a5,800053a8 <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800053e2:	47b5                	li	a5,13
    800053e4:	0cf48163          	beq	s1,a5,800054a6 <consoleintr+0x132>
      consputc(c);
    800053e8:	8526                	mv	a0,s1
    800053ea:	f59ff0ef          	jal	ra,80005342 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800053ee:	0001c797          	auipc	a5,0x1c
    800053f2:	8c278793          	addi	a5,a5,-1854 # 80020cb0 <cons>
    800053f6:	0a07a683          	lw	a3,160(a5)
    800053fa:	0016871b          	addiw	a4,a3,1
    800053fe:	0007061b          	sext.w	a2,a4
    80005402:	0ae7a023          	sw	a4,160(a5)
    80005406:	07f6f693          	andi	a3,a3,127
    8000540a:	97b6                	add	a5,a5,a3
    8000540c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005410:	47a9                	li	a5,10
    80005412:	0af48f63          	beq	s1,a5,800054d0 <consoleintr+0x15c>
    80005416:	4791                	li	a5,4
    80005418:	0af48c63          	beq	s1,a5,800054d0 <consoleintr+0x15c>
    8000541c:	0001c797          	auipc	a5,0x1c
    80005420:	92c7a783          	lw	a5,-1748(a5) # 80020d48 <cons+0x98>
    80005424:	9f1d                	subw	a4,a4,a5
    80005426:	08000793          	li	a5,128
    8000542a:	f6f71fe3          	bne	a4,a5,800053a8 <consoleintr+0x34>
    8000542e:	a04d                	j	800054d0 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80005430:	0001c717          	auipc	a4,0x1c
    80005434:	88070713          	addi	a4,a4,-1920 # 80020cb0 <cons>
    80005438:	0a072783          	lw	a5,160(a4)
    8000543c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005440:	0001c497          	auipc	s1,0x1c
    80005444:	87048493          	addi	s1,s1,-1936 # 80020cb0 <cons>
    while(cons.e != cons.w &&
    80005448:	4929                	li	s2,10
    8000544a:	f4f70fe3          	beq	a4,a5,800053a8 <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000544e:	37fd                	addiw	a5,a5,-1
    80005450:	07f7f713          	andi	a4,a5,127
    80005454:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005456:	01874703          	lbu	a4,24(a4)
    8000545a:	f52707e3          	beq	a4,s2,800053a8 <consoleintr+0x34>
      cons.e--;
    8000545e:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005462:	10000513          	li	a0,256
    80005466:	eddff0ef          	jal	ra,80005342 <consputc>
    while(cons.e != cons.w &&
    8000546a:	0a04a783          	lw	a5,160(s1)
    8000546e:	09c4a703          	lw	a4,156(s1)
    80005472:	fcf71ee3          	bne	a4,a5,8000544e <consoleintr+0xda>
    80005476:	bf0d                	j	800053a8 <consoleintr+0x34>
    if(cons.e != cons.w){
    80005478:	0001c717          	auipc	a4,0x1c
    8000547c:	83870713          	addi	a4,a4,-1992 # 80020cb0 <cons>
    80005480:	0a072783          	lw	a5,160(a4)
    80005484:	09c72703          	lw	a4,156(a4)
    80005488:	f2f700e3          	beq	a4,a5,800053a8 <consoleintr+0x34>
      cons.e--;
    8000548c:	37fd                	addiw	a5,a5,-1
    8000548e:	0001c717          	auipc	a4,0x1c
    80005492:	8cf72123          	sw	a5,-1854(a4) # 80020d50 <cons+0xa0>
      consputc(BACKSPACE);
    80005496:	10000513          	li	a0,256
    8000549a:	ea9ff0ef          	jal	ra,80005342 <consputc>
    8000549e:	b729                	j	800053a8 <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800054a0:	f00484e3          	beqz	s1,800053a8 <consoleintr+0x34>
    800054a4:	b715                	j	800053c8 <consoleintr+0x54>
      consputc(c);
    800054a6:	4529                	li	a0,10
    800054a8:	e9bff0ef          	jal	ra,80005342 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800054ac:	0001c797          	auipc	a5,0x1c
    800054b0:	80478793          	addi	a5,a5,-2044 # 80020cb0 <cons>
    800054b4:	0a07a703          	lw	a4,160(a5)
    800054b8:	0017069b          	addiw	a3,a4,1
    800054bc:	0006861b          	sext.w	a2,a3
    800054c0:	0ad7a023          	sw	a3,160(a5)
    800054c4:	07f77713          	andi	a4,a4,127
    800054c8:	97ba                	add	a5,a5,a4
    800054ca:	4729                	li	a4,10
    800054cc:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800054d0:	0001c797          	auipc	a5,0x1c
    800054d4:	86c7ae23          	sw	a2,-1924(a5) # 80020d4c <cons+0x9c>
        wakeup(&cons.r);
    800054d8:	0001c517          	auipc	a0,0x1c
    800054dc:	87050513          	addi	a0,a0,-1936 # 80020d48 <cons+0x98>
    800054e0:	bbefc0ef          	jal	ra,8000189e <wakeup>
    800054e4:	b5d1                	j	800053a8 <consoleintr+0x34>

00000000800054e6 <consoleinit>:

void
consoleinit(void)
{
    800054e6:	1141                	addi	sp,sp,-16
    800054e8:	e406                	sd	ra,8(sp)
    800054ea:	e022                	sd	s0,0(sp)
    800054ec:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800054ee:	00002597          	auipc	a1,0x2
    800054f2:	48258593          	addi	a1,a1,1154 # 80007970 <syscalls+0x450>
    800054f6:	0001b517          	auipc	a0,0x1b
    800054fa:	7ba50513          	addi	a0,a0,1978 # 80020cb0 <cons>
    800054fe:	610000ef          	jal	ra,80005b0e <initlock>

  uartinit();
    80005502:	3d8000ef          	jal	ra,800058da <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005506:	00012797          	auipc	a5,0x12
    8000550a:	60a78793          	addi	a5,a5,1546 # 80017b10 <devsw>
    8000550e:	00000717          	auipc	a4,0x0
    80005512:	d3270713          	addi	a4,a4,-718 # 80005240 <consoleread>
    80005516:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005518:	00000717          	auipc	a4,0x0
    8000551c:	cce70713          	addi	a4,a4,-818 # 800051e6 <consolewrite>
    80005520:	ef98                	sd	a4,24(a5)
}
    80005522:	60a2                	ld	ra,8(sp)
    80005524:	6402                	ld	s0,0(sp)
    80005526:	0141                	addi	sp,sp,16
    80005528:	8082                	ret

000000008000552a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000552a:	7179                	addi	sp,sp,-48
    8000552c:	f406                	sd	ra,40(sp)
    8000552e:	f022                	sd	s0,32(sp)
    80005530:	ec26                	sd	s1,24(sp)
    80005532:	e84a                	sd	s2,16(sp)
    80005534:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005536:	c219                	beqz	a2,8000553c <printint+0x12>
    80005538:	06054f63          	bltz	a0,800055b6 <printint+0x8c>
    x = -xx;
  else
    x = xx;
    8000553c:	4881                	li	a7,0
    8000553e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005542:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005544:	00002617          	auipc	a2,0x2
    80005548:	45460613          	addi	a2,a2,1108 # 80007998 <digits>
    8000554c:	883e                	mv	a6,a5
    8000554e:	2785                	addiw	a5,a5,1
    80005550:	02b57733          	remu	a4,a0,a1
    80005554:	9732                	add	a4,a4,a2
    80005556:	00074703          	lbu	a4,0(a4)
    8000555a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000555e:	872a                	mv	a4,a0
    80005560:	02b55533          	divu	a0,a0,a1
    80005564:	0685                	addi	a3,a3,1
    80005566:	feb773e3          	bgeu	a4,a1,8000554c <printint+0x22>

  if(sign)
    8000556a:	00088b63          	beqz	a7,80005580 <printint+0x56>
    buf[i++] = '-';
    8000556e:	fe040713          	addi	a4,s0,-32
    80005572:	97ba                	add	a5,a5,a4
    80005574:	02d00713          	li	a4,45
    80005578:	fee78823          	sb	a4,-16(a5)
    8000557c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005580:	02f05563          	blez	a5,800055aa <printint+0x80>
    80005584:	fd040713          	addi	a4,s0,-48
    80005588:	00f704b3          	add	s1,a4,a5
    8000558c:	fff70913          	addi	s2,a4,-1
    80005590:	993e                	add	s2,s2,a5
    80005592:	37fd                	addiw	a5,a5,-1
    80005594:	1782                	slli	a5,a5,0x20
    80005596:	9381                	srli	a5,a5,0x20
    80005598:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000559c:	fff4c503          	lbu	a0,-1(s1)
    800055a0:	da3ff0ef          	jal	ra,80005342 <consputc>
  while(--i >= 0)
    800055a4:	14fd                	addi	s1,s1,-1
    800055a6:	ff249be3          	bne	s1,s2,8000559c <printint+0x72>
}
    800055aa:	70a2                	ld	ra,40(sp)
    800055ac:	7402                	ld	s0,32(sp)
    800055ae:	64e2                	ld	s1,24(sp)
    800055b0:	6942                	ld	s2,16(sp)
    800055b2:	6145                	addi	sp,sp,48
    800055b4:	8082                	ret
    x = -xx;
    800055b6:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800055ba:	4885                	li	a7,1
    x = -xx;
    800055bc:	b749                	j	8000553e <printint+0x14>

00000000800055be <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800055be:	7155                	addi	sp,sp,-208
    800055c0:	e506                	sd	ra,136(sp)
    800055c2:	e122                	sd	s0,128(sp)
    800055c4:	fca6                	sd	s1,120(sp)
    800055c6:	f8ca                	sd	s2,112(sp)
    800055c8:	f4ce                	sd	s3,104(sp)
    800055ca:	f0d2                	sd	s4,96(sp)
    800055cc:	ecd6                	sd	s5,88(sp)
    800055ce:	e8da                	sd	s6,80(sp)
    800055d0:	e4de                	sd	s7,72(sp)
    800055d2:	e0e2                	sd	s8,64(sp)
    800055d4:	fc66                	sd	s9,56(sp)
    800055d6:	f86a                	sd	s10,48(sp)
    800055d8:	f46e                	sd	s11,40(sp)
    800055da:	0900                	addi	s0,sp,144
    800055dc:	8a2a                	mv	s4,a0
    800055de:	e40c                	sd	a1,8(s0)
    800055e0:	e810                	sd	a2,16(s0)
    800055e2:	ec14                	sd	a3,24(s0)
    800055e4:	f018                	sd	a4,32(s0)
    800055e6:	f41c                	sd	a5,40(s0)
    800055e8:	03043823          	sd	a6,48(s0)
    800055ec:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800055f0:	0001b797          	auipc	a5,0x1b
    800055f4:	7807a783          	lw	a5,1920(a5) # 80020d70 <pr+0x18>
    800055f8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800055fc:	eb9d                	bnez	a5,80005632 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800055fe:	00840793          	addi	a5,s0,8
    80005602:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005606:	00054503          	lbu	a0,0(a0)
    8000560a:	24050463          	beqz	a0,80005852 <printf+0x294>
    8000560e:	4981                	li	s3,0
    if(cx != '%'){
    80005610:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005614:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005618:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000561c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005620:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005624:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005628:	00002b97          	auipc	s7,0x2
    8000562c:	370b8b93          	addi	s7,s7,880 # 80007998 <digits>
    80005630:	a081                	j	80005670 <printf+0xb2>
    acquire(&pr.lock);
    80005632:	0001b517          	auipc	a0,0x1b
    80005636:	72650513          	addi	a0,a0,1830 # 80020d58 <pr>
    8000563a:	554000ef          	jal	ra,80005b8e <acquire>
  va_start(ap, fmt);
    8000563e:	00840793          	addi	a5,s0,8
    80005642:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005646:	000a4503          	lbu	a0,0(s4)
    8000564a:	f171                	bnez	a0,8000560e <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000564c:	0001b517          	auipc	a0,0x1b
    80005650:	70c50513          	addi	a0,a0,1804 # 80020d58 <pr>
    80005654:	5d2000ef          	jal	ra,80005c26 <release>
    80005658:	aaed                	j	80005852 <printf+0x294>
      consputc(cx);
    8000565a:	ce9ff0ef          	jal	ra,80005342 <consputc>
      continue;
    8000565e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005660:	0014899b          	addiw	s3,s1,1
    80005664:	013a07b3          	add	a5,s4,s3
    80005668:	0007c503          	lbu	a0,0(a5)
    8000566c:	1c050f63          	beqz	a0,8000584a <printf+0x28c>
    if(cx != '%'){
    80005670:	ff5515e3          	bne	a0,s5,8000565a <printf+0x9c>
    i++;
    80005674:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005678:	009a07b3          	add	a5,s4,s1
    8000567c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005680:	1c090563          	beqz	s2,8000584a <printf+0x28c>
    80005684:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005688:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000568a:	c789                	beqz	a5,80005694 <printf+0xd6>
    8000568c:	009a0733          	add	a4,s4,s1
    80005690:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005694:	03690463          	beq	s2,s6,800056bc <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005698:	03890e63          	beq	s2,s8,800056d4 <printf+0x116>
    } else if(c0 == 'u'){
    8000569c:	0b990d63          	beq	s2,s9,80005756 <printf+0x198>
    } else if(c0 == 'x'){
    800056a0:	11a90363          	beq	s2,s10,800057a6 <printf+0x1e8>
    } else if(c0 == 'p'){
    800056a4:	13b90b63          	beq	s2,s11,800057da <printf+0x21c>
    } else if(c0 == 's'){
    800056a8:	07300793          	li	a5,115
    800056ac:	16f90363          	beq	s2,a5,80005812 <printf+0x254>
    } else if(c0 == '%'){
    800056b0:	03591c63          	bne	s2,s5,800056e8 <printf+0x12a>
      consputc('%');
    800056b4:	8556                	mv	a0,s5
    800056b6:	c8dff0ef          	jal	ra,80005342 <consputc>
    800056ba:	b75d                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800056bc:	f8843783          	ld	a5,-120(s0)
    800056c0:	00878713          	addi	a4,a5,8
    800056c4:	f8e43423          	sd	a4,-120(s0)
    800056c8:	4605                	li	a2,1
    800056ca:	45a9                	li	a1,10
    800056cc:	4388                	lw	a0,0(a5)
    800056ce:	e5dff0ef          	jal	ra,8000552a <printint>
    800056d2:	b779                	j	80005660 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800056d4:	03678163          	beq	a5,s6,800056f6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800056d8:	03878d63          	beq	a5,s8,80005712 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800056dc:	09978963          	beq	a5,s9,8000576e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800056e0:	03878b63          	beq	a5,s8,80005716 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800056e4:	0da78d63          	beq	a5,s10,800057be <printf+0x200>
      consputc('%');
    800056e8:	8556                	mv	a0,s5
    800056ea:	c59ff0ef          	jal	ra,80005342 <consputc>
      consputc(c0);
    800056ee:	854a                	mv	a0,s2
    800056f0:	c53ff0ef          	jal	ra,80005342 <consputc>
    800056f4:	b7b5                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800056f6:	f8843783          	ld	a5,-120(s0)
    800056fa:	00878713          	addi	a4,a5,8
    800056fe:	f8e43423          	sd	a4,-120(s0)
    80005702:	4605                	li	a2,1
    80005704:	45a9                	li	a1,10
    80005706:	6388                	ld	a0,0(a5)
    80005708:	e23ff0ef          	jal	ra,8000552a <printint>
      i += 1;
    8000570c:	0029849b          	addiw	s1,s3,2
    80005710:	bf81                	j	80005660 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80005712:	03668463          	beq	a3,s6,8000573a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005716:	07968a63          	beq	a3,s9,8000578a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000571a:	fda697e3          	bne	a3,s10,800056e8 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000571e:	f8843783          	ld	a5,-120(s0)
    80005722:	00878713          	addi	a4,a5,8
    80005726:	f8e43423          	sd	a4,-120(s0)
    8000572a:	4601                	li	a2,0
    8000572c:	45c1                	li	a1,16
    8000572e:	6388                	ld	a0,0(a5)
    80005730:	dfbff0ef          	jal	ra,8000552a <printint>
      i += 2;
    80005734:	0039849b          	addiw	s1,s3,3
    80005738:	b725                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000573a:	f8843783          	ld	a5,-120(s0)
    8000573e:	00878713          	addi	a4,a5,8
    80005742:	f8e43423          	sd	a4,-120(s0)
    80005746:	4605                	li	a2,1
    80005748:	45a9                	li	a1,10
    8000574a:	6388                	ld	a0,0(a5)
    8000574c:	ddfff0ef          	jal	ra,8000552a <printint>
      i += 2;
    80005750:	0039849b          	addiw	s1,s3,3
    80005754:	b731                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005756:	f8843783          	ld	a5,-120(s0)
    8000575a:	00878713          	addi	a4,a5,8
    8000575e:	f8e43423          	sd	a4,-120(s0)
    80005762:	4601                	li	a2,0
    80005764:	45a9                	li	a1,10
    80005766:	4388                	lw	a0,0(a5)
    80005768:	dc3ff0ef          	jal	ra,8000552a <printint>
    8000576c:	bdd5                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000576e:	f8843783          	ld	a5,-120(s0)
    80005772:	00878713          	addi	a4,a5,8
    80005776:	f8e43423          	sd	a4,-120(s0)
    8000577a:	4601                	li	a2,0
    8000577c:	45a9                	li	a1,10
    8000577e:	6388                	ld	a0,0(a5)
    80005780:	dabff0ef          	jal	ra,8000552a <printint>
      i += 1;
    80005784:	0029849b          	addiw	s1,s3,2
    80005788:	bde1                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000578a:	f8843783          	ld	a5,-120(s0)
    8000578e:	00878713          	addi	a4,a5,8
    80005792:	f8e43423          	sd	a4,-120(s0)
    80005796:	4601                	li	a2,0
    80005798:	45a9                	li	a1,10
    8000579a:	6388                	ld	a0,0(a5)
    8000579c:	d8fff0ef          	jal	ra,8000552a <printint>
      i += 2;
    800057a0:	0039849b          	addiw	s1,s3,3
    800057a4:	bd75                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800057a6:	f8843783          	ld	a5,-120(s0)
    800057aa:	00878713          	addi	a4,a5,8
    800057ae:	f8e43423          	sd	a4,-120(s0)
    800057b2:	4601                	li	a2,0
    800057b4:	45c1                	li	a1,16
    800057b6:	4388                	lw	a0,0(a5)
    800057b8:	d73ff0ef          	jal	ra,8000552a <printint>
    800057bc:	b555                	j	80005660 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800057be:	f8843783          	ld	a5,-120(s0)
    800057c2:	00878713          	addi	a4,a5,8
    800057c6:	f8e43423          	sd	a4,-120(s0)
    800057ca:	4601                	li	a2,0
    800057cc:	45c1                	li	a1,16
    800057ce:	6388                	ld	a0,0(a5)
    800057d0:	d5bff0ef          	jal	ra,8000552a <printint>
      i += 1;
    800057d4:	0029849b          	addiw	s1,s3,2
    800057d8:	b561                	j	80005660 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800057da:	f8843783          	ld	a5,-120(s0)
    800057de:	00878713          	addi	a4,a5,8
    800057e2:	f8e43423          	sd	a4,-120(s0)
    800057e6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800057ea:	03000513          	li	a0,48
    800057ee:	b55ff0ef          	jal	ra,80005342 <consputc>
  consputc('x');
    800057f2:	856a                	mv	a0,s10
    800057f4:	b4fff0ef          	jal	ra,80005342 <consputc>
    800057f8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800057fa:	03c9d793          	srli	a5,s3,0x3c
    800057fe:	97de                	add	a5,a5,s7
    80005800:	0007c503          	lbu	a0,0(a5)
    80005804:	b3fff0ef          	jal	ra,80005342 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005808:	0992                	slli	s3,s3,0x4
    8000580a:	397d                	addiw	s2,s2,-1
    8000580c:	fe0917e3          	bnez	s2,800057fa <printf+0x23c>
    80005810:	bd81                	j	80005660 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    80005812:	f8843783          	ld	a5,-120(s0)
    80005816:	00878713          	addi	a4,a5,8
    8000581a:	f8e43423          	sd	a4,-120(s0)
    8000581e:	0007b903          	ld	s2,0(a5)
    80005822:	00090d63          	beqz	s2,8000583c <printf+0x27e>
      for(; *s; s++)
    80005826:	00094503          	lbu	a0,0(s2)
    8000582a:	e2050be3          	beqz	a0,80005660 <printf+0xa2>
        consputc(*s);
    8000582e:	b15ff0ef          	jal	ra,80005342 <consputc>
      for(; *s; s++)
    80005832:	0905                	addi	s2,s2,1
    80005834:	00094503          	lbu	a0,0(s2)
    80005838:	f97d                	bnez	a0,8000582e <printf+0x270>
    8000583a:	b51d                	j	80005660 <printf+0xa2>
        s = "(null)";
    8000583c:	00002917          	auipc	s2,0x2
    80005840:	13c90913          	addi	s2,s2,316 # 80007978 <syscalls+0x458>
      for(; *s; s++)
    80005844:	02800513          	li	a0,40
    80005848:	b7dd                	j	8000582e <printf+0x270>
  if(locking)
    8000584a:	f7843783          	ld	a5,-136(s0)
    8000584e:	de079fe3          	bnez	a5,8000564c <printf+0x8e>

  return 0;
}
    80005852:	4501                	li	a0,0
    80005854:	60aa                	ld	ra,136(sp)
    80005856:	640a                	ld	s0,128(sp)
    80005858:	74e6                	ld	s1,120(sp)
    8000585a:	7946                	ld	s2,112(sp)
    8000585c:	79a6                	ld	s3,104(sp)
    8000585e:	7a06                	ld	s4,96(sp)
    80005860:	6ae6                	ld	s5,88(sp)
    80005862:	6b46                	ld	s6,80(sp)
    80005864:	6ba6                	ld	s7,72(sp)
    80005866:	6c06                	ld	s8,64(sp)
    80005868:	7ce2                	ld	s9,56(sp)
    8000586a:	7d42                	ld	s10,48(sp)
    8000586c:	7da2                	ld	s11,40(sp)
    8000586e:	6169                	addi	sp,sp,208
    80005870:	8082                	ret

0000000080005872 <panic>:

void
panic(char *s)
{
    80005872:	1101                	addi	sp,sp,-32
    80005874:	ec06                	sd	ra,24(sp)
    80005876:	e822                	sd	s0,16(sp)
    80005878:	e426                	sd	s1,8(sp)
    8000587a:	1000                	addi	s0,sp,32
    8000587c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000587e:	0001b797          	auipc	a5,0x1b
    80005882:	4e07a923          	sw	zero,1266(a5) # 80020d70 <pr+0x18>
  printf("panic: ");
    80005886:	00002517          	auipc	a0,0x2
    8000588a:	0fa50513          	addi	a0,a0,250 # 80007980 <syscalls+0x460>
    8000588e:	d31ff0ef          	jal	ra,800055be <printf>
  printf("%s\n", s);
    80005892:	85a6                	mv	a1,s1
    80005894:	00002517          	auipc	a0,0x2
    80005898:	0f450513          	addi	a0,a0,244 # 80007988 <syscalls+0x468>
    8000589c:	d23ff0ef          	jal	ra,800055be <printf>
  panicked = 1; // freeze uart output from other CPUs
    800058a0:	4785                	li	a5,1
    800058a2:	00002717          	auipc	a4,0x2
    800058a6:	1af72d23          	sw	a5,442(a4) # 80007a5c <panicked>
  for(;;)
    800058aa:	a001                	j	800058aa <panic+0x38>

00000000800058ac <printfinit>:
    ;
}

void
printfinit(void)
{
    800058ac:	1101                	addi	sp,sp,-32
    800058ae:	ec06                	sd	ra,24(sp)
    800058b0:	e822                	sd	s0,16(sp)
    800058b2:	e426                	sd	s1,8(sp)
    800058b4:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800058b6:	0001b497          	auipc	s1,0x1b
    800058ba:	4a248493          	addi	s1,s1,1186 # 80020d58 <pr>
    800058be:	00002597          	auipc	a1,0x2
    800058c2:	0d258593          	addi	a1,a1,210 # 80007990 <syscalls+0x470>
    800058c6:	8526                	mv	a0,s1
    800058c8:	246000ef          	jal	ra,80005b0e <initlock>
  pr.locking = 1;
    800058cc:	4785                	li	a5,1
    800058ce:	cc9c                	sw	a5,24(s1)
}
    800058d0:	60e2                	ld	ra,24(sp)
    800058d2:	6442                	ld	s0,16(sp)
    800058d4:	64a2                	ld	s1,8(sp)
    800058d6:	6105                	addi	sp,sp,32
    800058d8:	8082                	ret

00000000800058da <uartinit>:

void uartstart();

void
uartinit(void)
{
    800058da:	1141                	addi	sp,sp,-16
    800058dc:	e406                	sd	ra,8(sp)
    800058de:	e022                	sd	s0,0(sp)
    800058e0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800058e2:	100007b7          	lui	a5,0x10000
    800058e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800058ea:	f8000713          	li	a4,-128
    800058ee:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800058f2:	470d                	li	a4,3
    800058f4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800058f8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800058fc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005900:	469d                	li	a3,7
    80005902:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005906:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000590a:	00002597          	auipc	a1,0x2
    8000590e:	0a658593          	addi	a1,a1,166 # 800079b0 <digits+0x18>
    80005912:	0001b517          	auipc	a0,0x1b
    80005916:	46650513          	addi	a0,a0,1126 # 80020d78 <uart_tx_lock>
    8000591a:	1f4000ef          	jal	ra,80005b0e <initlock>
}
    8000591e:	60a2                	ld	ra,8(sp)
    80005920:	6402                	ld	s0,0(sp)
    80005922:	0141                	addi	sp,sp,16
    80005924:	8082                	ret

0000000080005926 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005926:	1101                	addi	sp,sp,-32
    80005928:	ec06                	sd	ra,24(sp)
    8000592a:	e822                	sd	s0,16(sp)
    8000592c:	e426                	sd	s1,8(sp)
    8000592e:	1000                	addi	s0,sp,32
    80005930:	84aa                	mv	s1,a0
  push_off();
    80005932:	21c000ef          	jal	ra,80005b4e <push_off>

  if(panicked){
    80005936:	00002797          	auipc	a5,0x2
    8000593a:	1267a783          	lw	a5,294(a5) # 80007a5c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000593e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005942:	c391                	beqz	a5,80005946 <uartputc_sync+0x20>
    for(;;)
    80005944:	a001                	j	80005944 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005946:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000594a:	0ff7f793          	andi	a5,a5,255
    8000594e:	0207f793          	andi	a5,a5,32
    80005952:	dbf5                	beqz	a5,80005946 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005954:	0ff4f793          	andi	a5,s1,255
    80005958:	10000737          	lui	a4,0x10000
    8000595c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80005960:	272000ef          	jal	ra,80005bd2 <pop_off>
}
    80005964:	60e2                	ld	ra,24(sp)
    80005966:	6442                	ld	s0,16(sp)
    80005968:	64a2                	ld	s1,8(sp)
    8000596a:	6105                	addi	sp,sp,32
    8000596c:	8082                	ret

000000008000596e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000596e:	00002717          	auipc	a4,0x2
    80005972:	0f273703          	ld	a4,242(a4) # 80007a60 <uart_tx_r>
    80005976:	00002797          	auipc	a5,0x2
    8000597a:	0f27b783          	ld	a5,242(a5) # 80007a68 <uart_tx_w>
    8000597e:	06e78e63          	beq	a5,a4,800059fa <uartstart+0x8c>
{
    80005982:	7139                	addi	sp,sp,-64
    80005984:	fc06                	sd	ra,56(sp)
    80005986:	f822                	sd	s0,48(sp)
    80005988:	f426                	sd	s1,40(sp)
    8000598a:	f04a                	sd	s2,32(sp)
    8000598c:	ec4e                	sd	s3,24(sp)
    8000598e:	e852                	sd	s4,16(sp)
    80005990:	e456                	sd	s5,8(sp)
    80005992:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005994:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005998:	0001ba17          	auipc	s4,0x1b
    8000599c:	3e0a0a13          	addi	s4,s4,992 # 80020d78 <uart_tx_lock>
    uart_tx_r += 1;
    800059a0:	00002497          	auipc	s1,0x2
    800059a4:	0c048493          	addi	s1,s1,192 # 80007a60 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800059a8:	00002997          	auipc	s3,0x2
    800059ac:	0c098993          	addi	s3,s3,192 # 80007a68 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800059b0:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800059b4:	0ff7f793          	andi	a5,a5,255
    800059b8:	0207f793          	andi	a5,a5,32
    800059bc:	c795                	beqz	a5,800059e8 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800059be:	01f77793          	andi	a5,a4,31
    800059c2:	97d2                	add	a5,a5,s4
    800059c4:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800059c8:	0705                	addi	a4,a4,1
    800059ca:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800059cc:	8526                	mv	a0,s1
    800059ce:	ed1fb0ef          	jal	ra,8000189e <wakeup>
    
    WriteReg(THR, c);
    800059d2:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800059d6:	6098                	ld	a4,0(s1)
    800059d8:	0009b783          	ld	a5,0(s3)
    800059dc:	fce79ae3          	bne	a5,a4,800059b0 <uartstart+0x42>
      ReadReg(ISR);
    800059e0:	100007b7          	lui	a5,0x10000
    800059e4:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800059e8:	70e2                	ld	ra,56(sp)
    800059ea:	7442                	ld	s0,48(sp)
    800059ec:	74a2                	ld	s1,40(sp)
    800059ee:	7902                	ld	s2,32(sp)
    800059f0:	69e2                	ld	s3,24(sp)
    800059f2:	6a42                	ld	s4,16(sp)
    800059f4:	6aa2                	ld	s5,8(sp)
    800059f6:	6121                	addi	sp,sp,64
    800059f8:	8082                	ret
      ReadReg(ISR);
    800059fa:	100007b7          	lui	a5,0x10000
    800059fe:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    80005a02:	8082                	ret

0000000080005a04 <uartputc>:
{
    80005a04:	7179                	addi	sp,sp,-48
    80005a06:	f406                	sd	ra,40(sp)
    80005a08:	f022                	sd	s0,32(sp)
    80005a0a:	ec26                	sd	s1,24(sp)
    80005a0c:	e84a                	sd	s2,16(sp)
    80005a0e:	e44e                	sd	s3,8(sp)
    80005a10:	e052                	sd	s4,0(sp)
    80005a12:	1800                	addi	s0,sp,48
    80005a14:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80005a16:	0001b517          	auipc	a0,0x1b
    80005a1a:	36250513          	addi	a0,a0,866 # 80020d78 <uart_tx_lock>
    80005a1e:	170000ef          	jal	ra,80005b8e <acquire>
  if(panicked){
    80005a22:	00002797          	auipc	a5,0x2
    80005a26:	03a7a783          	lw	a5,58(a5) # 80007a5c <panicked>
    80005a2a:	efbd                	bnez	a5,80005aa8 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005a2c:	00002797          	auipc	a5,0x2
    80005a30:	03c7b783          	ld	a5,60(a5) # 80007a68 <uart_tx_w>
    80005a34:	00002717          	auipc	a4,0x2
    80005a38:	02c73703          	ld	a4,44(a4) # 80007a60 <uart_tx_r>
    80005a3c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005a40:	0001ba17          	auipc	s4,0x1b
    80005a44:	338a0a13          	addi	s4,s4,824 # 80020d78 <uart_tx_lock>
    80005a48:	00002497          	auipc	s1,0x2
    80005a4c:	01848493          	addi	s1,s1,24 # 80007a60 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005a50:	00002917          	auipc	s2,0x2
    80005a54:	01890913          	addi	s2,s2,24 # 80007a68 <uart_tx_w>
    80005a58:	00f71d63          	bne	a4,a5,80005a72 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005a5c:	85d2                	mv	a1,s4
    80005a5e:	8526                	mv	a0,s1
    80005a60:	df3fb0ef          	jal	ra,80001852 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005a64:	00093783          	ld	a5,0(s2)
    80005a68:	6098                	ld	a4,0(s1)
    80005a6a:	02070713          	addi	a4,a4,32
    80005a6e:	fef707e3          	beq	a4,a5,80005a5c <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80005a72:	0001b497          	auipc	s1,0x1b
    80005a76:	30648493          	addi	s1,s1,774 # 80020d78 <uart_tx_lock>
    80005a7a:	01f7f713          	andi	a4,a5,31
    80005a7e:	9726                	add	a4,a4,s1
    80005a80:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80005a84:	0785                	addi	a5,a5,1
    80005a86:	00002717          	auipc	a4,0x2
    80005a8a:	fef73123          	sd	a5,-30(a4) # 80007a68 <uart_tx_w>
  uartstart();
    80005a8e:	ee1ff0ef          	jal	ra,8000596e <uartstart>
  release(&uart_tx_lock);
    80005a92:	8526                	mv	a0,s1
    80005a94:	192000ef          	jal	ra,80005c26 <release>
}
    80005a98:	70a2                	ld	ra,40(sp)
    80005a9a:	7402                	ld	s0,32(sp)
    80005a9c:	64e2                	ld	s1,24(sp)
    80005a9e:	6942                	ld	s2,16(sp)
    80005aa0:	69a2                	ld	s3,8(sp)
    80005aa2:	6a02                	ld	s4,0(sp)
    80005aa4:	6145                	addi	sp,sp,48
    80005aa6:	8082                	ret
    for(;;)
    80005aa8:	a001                	j	80005aa8 <uartputc+0xa4>

0000000080005aaa <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80005aaa:	1141                	addi	sp,sp,-16
    80005aac:	e422                	sd	s0,8(sp)
    80005aae:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005ab0:	100007b7          	lui	a5,0x10000
    80005ab4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005ab8:	8b85                	andi	a5,a5,1
    80005aba:	cb91                	beqz	a5,80005ace <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80005abc:	100007b7          	lui	a5,0x10000
    80005ac0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80005ac4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80005ac8:	6422                	ld	s0,8(sp)
    80005aca:	0141                	addi	sp,sp,16
    80005acc:	8082                	ret
    return -1;
    80005ace:	557d                	li	a0,-1
    80005ad0:	bfe5                	j	80005ac8 <uartgetc+0x1e>

0000000080005ad2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005ad2:	1101                	addi	sp,sp,-32
    80005ad4:	ec06                	sd	ra,24(sp)
    80005ad6:	e822                	sd	s0,16(sp)
    80005ad8:	e426                	sd	s1,8(sp)
    80005ada:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80005adc:	54fd                	li	s1,-1
    int c = uartgetc();
    80005ade:	fcdff0ef          	jal	ra,80005aaa <uartgetc>
    if(c == -1)
    80005ae2:	00950563          	beq	a0,s1,80005aec <uartintr+0x1a>
      break;
    consoleintr(c);
    80005ae6:	88fff0ef          	jal	ra,80005374 <consoleintr>
  while(1){
    80005aea:	bfd5                	j	80005ade <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80005aec:	0001b497          	auipc	s1,0x1b
    80005af0:	28c48493          	addi	s1,s1,652 # 80020d78 <uart_tx_lock>
    80005af4:	8526                	mv	a0,s1
    80005af6:	098000ef          	jal	ra,80005b8e <acquire>
  uartstart();
    80005afa:	e75ff0ef          	jal	ra,8000596e <uartstart>
  release(&uart_tx_lock);
    80005afe:	8526                	mv	a0,s1
    80005b00:	126000ef          	jal	ra,80005c26 <release>
}
    80005b04:	60e2                	ld	ra,24(sp)
    80005b06:	6442                	ld	s0,16(sp)
    80005b08:	64a2                	ld	s1,8(sp)
    80005b0a:	6105                	addi	sp,sp,32
    80005b0c:	8082                	ret

0000000080005b0e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005b0e:	1141                	addi	sp,sp,-16
    80005b10:	e422                	sd	s0,8(sp)
    80005b12:	0800                	addi	s0,sp,16
  lk->name = name;
    80005b14:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005b16:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80005b1a:	00053823          	sd	zero,16(a0)
}
    80005b1e:	6422                	ld	s0,8(sp)
    80005b20:	0141                	addi	sp,sp,16
    80005b22:	8082                	ret

0000000080005b24 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005b24:	411c                	lw	a5,0(a0)
    80005b26:	e399                	bnez	a5,80005b2c <holding+0x8>
    80005b28:	4501                	li	a0,0
  return r;
}
    80005b2a:	8082                	ret
{
    80005b2c:	1101                	addi	sp,sp,-32
    80005b2e:	ec06                	sd	ra,24(sp)
    80005b30:	e822                	sd	s0,16(sp)
    80005b32:	e426                	sd	s1,8(sp)
    80005b34:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005b36:	6904                	ld	s1,16(a0)
    80005b38:	e90fb0ef          	jal	ra,800011c8 <mycpu>
    80005b3c:	40a48533          	sub	a0,s1,a0
    80005b40:	00153513          	seqz	a0,a0
}
    80005b44:	60e2                	ld	ra,24(sp)
    80005b46:	6442                	ld	s0,16(sp)
    80005b48:	64a2                	ld	s1,8(sp)
    80005b4a:	6105                	addi	sp,sp,32
    80005b4c:	8082                	ret

0000000080005b4e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80005b4e:	1101                	addi	sp,sp,-32
    80005b50:	ec06                	sd	ra,24(sp)
    80005b52:	e822                	sd	s0,16(sp)
    80005b54:	e426                	sd	s1,8(sp)
    80005b56:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005b58:	100024f3          	csrr	s1,sstatus
    80005b5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005b60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005b62:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005b66:	e62fb0ef          	jal	ra,800011c8 <mycpu>
    80005b6a:	5d3c                	lw	a5,120(a0)
    80005b6c:	cb99                	beqz	a5,80005b82 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80005b6e:	e5afb0ef          	jal	ra,800011c8 <mycpu>
    80005b72:	5d3c                	lw	a5,120(a0)
    80005b74:	2785                	addiw	a5,a5,1
    80005b76:	dd3c                	sw	a5,120(a0)
}
    80005b78:	60e2                	ld	ra,24(sp)
    80005b7a:	6442                	ld	s0,16(sp)
    80005b7c:	64a2                	ld	s1,8(sp)
    80005b7e:	6105                	addi	sp,sp,32
    80005b80:	8082                	ret
    mycpu()->intena = old;
    80005b82:	e46fb0ef          	jal	ra,800011c8 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005b86:	8085                	srli	s1,s1,0x1
    80005b88:	8885                	andi	s1,s1,1
    80005b8a:	dd64                	sw	s1,124(a0)
    80005b8c:	b7cd                	j	80005b6e <push_off+0x20>

0000000080005b8e <acquire>:
{
    80005b8e:	1101                	addi	sp,sp,-32
    80005b90:	ec06                	sd	ra,24(sp)
    80005b92:	e822                	sd	s0,16(sp)
    80005b94:	e426                	sd	s1,8(sp)
    80005b96:	1000                	addi	s0,sp,32
    80005b98:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80005b9a:	fb5ff0ef          	jal	ra,80005b4e <push_off>
  if(holding(lk))
    80005b9e:	8526                	mv	a0,s1
    80005ba0:	f85ff0ef          	jal	ra,80005b24 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005ba4:	4705                	li	a4,1
  if(holding(lk))
    80005ba6:	e105                	bnez	a0,80005bc6 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005ba8:	87ba                	mv	a5,a4
    80005baa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005bae:	2781                	sext.w	a5,a5
    80005bb0:	ffe5                	bnez	a5,80005ba8 <acquire+0x1a>
  __sync_synchronize();
    80005bb2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80005bb6:	e12fb0ef          	jal	ra,800011c8 <mycpu>
    80005bba:	e888                	sd	a0,16(s1)
}
    80005bbc:	60e2                	ld	ra,24(sp)
    80005bbe:	6442                	ld	s0,16(sp)
    80005bc0:	64a2                	ld	s1,8(sp)
    80005bc2:	6105                	addi	sp,sp,32
    80005bc4:	8082                	ret
    panic("acquire");
    80005bc6:	00002517          	auipc	a0,0x2
    80005bca:	df250513          	addi	a0,a0,-526 # 800079b8 <digits+0x20>
    80005bce:	ca5ff0ef          	jal	ra,80005872 <panic>

0000000080005bd2 <pop_off>:

void
pop_off(void)
{
    80005bd2:	1141                	addi	sp,sp,-16
    80005bd4:	e406                	sd	ra,8(sp)
    80005bd6:	e022                	sd	s0,0(sp)
    80005bd8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80005bda:	deefb0ef          	jal	ra,800011c8 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005bde:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005be2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005be4:	e78d                	bnez	a5,80005c0e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005be6:	5d3c                	lw	a5,120(a0)
    80005be8:	02f05963          	blez	a5,80005c1a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80005bec:	37fd                	addiw	a5,a5,-1
    80005bee:	0007871b          	sext.w	a4,a5
    80005bf2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005bf4:	eb09                	bnez	a4,80005c06 <pop_off+0x34>
    80005bf6:	5d7c                	lw	a5,124(a0)
    80005bf8:	c799                	beqz	a5,80005c06 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005bfe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005c02:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005c06:	60a2                	ld	ra,8(sp)
    80005c08:	6402                	ld	s0,0(sp)
    80005c0a:	0141                	addi	sp,sp,16
    80005c0c:	8082                	ret
    panic("pop_off - interruptible");
    80005c0e:	00002517          	auipc	a0,0x2
    80005c12:	db250513          	addi	a0,a0,-590 # 800079c0 <digits+0x28>
    80005c16:	c5dff0ef          	jal	ra,80005872 <panic>
    panic("pop_off");
    80005c1a:	00002517          	auipc	a0,0x2
    80005c1e:	dbe50513          	addi	a0,a0,-578 # 800079d8 <digits+0x40>
    80005c22:	c51ff0ef          	jal	ra,80005872 <panic>

0000000080005c26 <release>:
{
    80005c26:	1101                	addi	sp,sp,-32
    80005c28:	ec06                	sd	ra,24(sp)
    80005c2a:	e822                	sd	s0,16(sp)
    80005c2c:	e426                	sd	s1,8(sp)
    80005c2e:	1000                	addi	s0,sp,32
    80005c30:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005c32:	ef3ff0ef          	jal	ra,80005b24 <holding>
    80005c36:	c105                	beqz	a0,80005c56 <release+0x30>
  lk->cpu = 0;
    80005c38:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80005c3c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005c40:	0f50000f          	fence	iorw,ow
    80005c44:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80005c48:	f8bff0ef          	jal	ra,80005bd2 <pop_off>
}
    80005c4c:	60e2                	ld	ra,24(sp)
    80005c4e:	6442                	ld	s0,16(sp)
    80005c50:	64a2                	ld	s1,8(sp)
    80005c52:	6105                	addi	sp,sp,32
    80005c54:	8082                	ret
    panic("release");
    80005c56:	00002517          	auipc	a0,0x2
    80005c5a:	d8a50513          	addi	a0,a0,-630 # 800079e0 <digits+0x48>
    80005c5e:	c15ff0ef          	jal	ra,80005872 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
