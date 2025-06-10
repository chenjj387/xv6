
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0001e117          	auipc	sp,0x1e
    80000004:	94010113          	addi	sp,sp,-1728 # 8001d940 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	431040ef          	jal	ra,80004c46 <start>

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
    80000030:	00026797          	auipc	a5,0x26
    80000034:	a1078793          	addi	a5,a5,-1520 # 80025a40 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	104000ef          	jal	ra,8000014c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00008917          	auipc	s2,0x8
    80000050:	8c490913          	addi	s2,s2,-1852 # 80007910 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	608050ef          	jal	ra,8000565e <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	690050ef          	jal	ra,800056f6 <release>
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
    8000007e:	2c4050ef          	jal	ra,80005342 <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	e84a                	sd	s2,16(sp)
    8000008c:	e44e                	sd	s3,8(sp)
    8000008e:	e052                	sd	s4,0(sp)
    80000090:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000092:	6785                	lui	a5,0x1
    80000094:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000098:	94aa                	add	s1,s1,a0
    8000009a:	757d                	lui	a0,0xfffff
    8000009c:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000009e:	94be                	add	s1,s1,a5
    800000a0:	0095ec63          	bltu	a1,s1,800000b8 <freerange+0x36>
    800000a4:	892e                	mv	s2,a1
    kfree(p);
    800000a6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000a8:	6985                	lui	s3,0x1
    kfree(p);
    800000aa:	01448533          	add	a0,s1,s4
    800000ae:	f6fff0ef          	jal	ra,8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b2:	94ce                	add	s1,s1,s3
    800000b4:	fe997be3          	bgeu	s2,s1,800000aa <freerange+0x28>
}
    800000b8:	70a2                	ld	ra,40(sp)
    800000ba:	7402                	ld	s0,32(sp)
    800000bc:	64e2                	ld	s1,24(sp)
    800000be:	6942                	ld	s2,16(sp)
    800000c0:	69a2                	ld	s3,8(sp)
    800000c2:	6a02                	ld	s4,0(sp)
    800000c4:	6145                	addi	sp,sp,48
    800000c6:	8082                	ret

00000000800000c8 <kinit>:
{
    800000c8:	1141                	addi	sp,sp,-16
    800000ca:	e406                	sd	ra,8(sp)
    800000cc:	e022                	sd	s0,0(sp)
    800000ce:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000d0:	00007597          	auipc	a1,0x7
    800000d4:	f4858593          	addi	a1,a1,-184 # 80007018 <etext+0x18>
    800000d8:	00008517          	auipc	a0,0x8
    800000dc:	83850513          	addi	a0,a0,-1992 # 80007910 <kmem>
    800000e0:	4fe050ef          	jal	ra,800055de <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e4:	45c5                	li	a1,17
    800000e6:	05ee                	slli	a1,a1,0x1b
    800000e8:	00026517          	auipc	a0,0x26
    800000ec:	95850513          	addi	a0,a0,-1704 # 80025a40 <end>
    800000f0:	f93ff0ef          	jal	ra,80000082 <freerange>
}
    800000f4:	60a2                	ld	ra,8(sp)
    800000f6:	6402                	ld	s0,0(sp)
    800000f8:	0141                	addi	sp,sp,16
    800000fa:	8082                	ret

00000000800000fc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000fc:	1101                	addi	sp,sp,-32
    800000fe:	ec06                	sd	ra,24(sp)
    80000100:	e822                	sd	s0,16(sp)
    80000102:	e426                	sd	s1,8(sp)
    80000104:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000106:	00008497          	auipc	s1,0x8
    8000010a:	80a48493          	addi	s1,s1,-2038 # 80007910 <kmem>
    8000010e:	8526                	mv	a0,s1
    80000110:	54e050ef          	jal	ra,8000565e <acquire>
  r = kmem.freelist;
    80000114:	6c84                	ld	s1,24(s1)
  if(r)
    80000116:	c485                	beqz	s1,8000013e <kalloc+0x42>
    kmem.freelist = r->next;
    80000118:	609c                	ld	a5,0(s1)
    8000011a:	00007517          	auipc	a0,0x7
    8000011e:	7f650513          	addi	a0,a0,2038 # 80007910 <kmem>
    80000122:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000124:	5d2050ef          	jal	ra,800056f6 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000128:	6605                	lui	a2,0x1
    8000012a:	4595                	li	a1,5
    8000012c:	8526                	mv	a0,s1
    8000012e:	01e000ef          	jal	ra,8000014c <memset>
  return (void*)r;
}
    80000132:	8526                	mv	a0,s1
    80000134:	60e2                	ld	ra,24(sp)
    80000136:	6442                	ld	s0,16(sp)
    80000138:	64a2                	ld	s1,8(sp)
    8000013a:	6105                	addi	sp,sp,32
    8000013c:	8082                	ret
  release(&kmem.lock);
    8000013e:	00007517          	auipc	a0,0x7
    80000142:	7d250513          	addi	a0,a0,2002 # 80007910 <kmem>
    80000146:	5b0050ef          	jal	ra,800056f6 <release>
  if(r)
    8000014a:	b7e5                	j	80000132 <kalloc+0x36>

000000008000014c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000014c:	1141                	addi	sp,sp,-16
    8000014e:	e422                	sd	s0,8(sp)
    80000150:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000152:	ce09                	beqz	a2,8000016c <memset+0x20>
    80000154:	87aa                	mv	a5,a0
    80000156:	fff6071b          	addiw	a4,a2,-1
    8000015a:	1702                	slli	a4,a4,0x20
    8000015c:	9301                	srli	a4,a4,0x20
    8000015e:	0705                	addi	a4,a4,1
    80000160:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000162:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000166:	0785                	addi	a5,a5,1
    80000168:	fee79de3          	bne	a5,a4,80000162 <memset+0x16>
  }
  return dst;
}
    8000016c:	6422                	ld	s0,8(sp)
    8000016e:	0141                	addi	sp,sp,16
    80000170:	8082                	ret

0000000080000172 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000172:	1141                	addi	sp,sp,-16
    80000174:	e422                	sd	s0,8(sp)
    80000176:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000178:	ca05                	beqz	a2,800001a8 <memcmp+0x36>
    8000017a:	fff6069b          	addiw	a3,a2,-1
    8000017e:	1682                	slli	a3,a3,0x20
    80000180:	9281                	srli	a3,a3,0x20
    80000182:	0685                	addi	a3,a3,1
    80000184:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000186:	00054783          	lbu	a5,0(a0)
    8000018a:	0005c703          	lbu	a4,0(a1)
    8000018e:	00e79863          	bne	a5,a4,8000019e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000192:	0505                	addi	a0,a0,1
    80000194:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000196:	fed518e3          	bne	a0,a3,80000186 <memcmp+0x14>
  }

  return 0;
    8000019a:	4501                	li	a0,0
    8000019c:	a019                	j	800001a2 <memcmp+0x30>
      return *s1 - *s2;
    8000019e:	40e7853b          	subw	a0,a5,a4
}
    800001a2:	6422                	ld	s0,8(sp)
    800001a4:	0141                	addi	sp,sp,16
    800001a6:	8082                	ret
  return 0;
    800001a8:	4501                	li	a0,0
    800001aa:	bfe5                	j	800001a2 <memcmp+0x30>

00000000800001ac <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001ac:	1141                	addi	sp,sp,-16
    800001ae:	e422                	sd	s0,8(sp)
    800001b0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001b2:	ca0d                	beqz	a2,800001e4 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001b4:	00a5f963          	bgeu	a1,a0,800001c6 <memmove+0x1a>
    800001b8:	02061693          	slli	a3,a2,0x20
    800001bc:	9281                	srli	a3,a3,0x20
    800001be:	00d58733          	add	a4,a1,a3
    800001c2:	02e56463          	bltu	a0,a4,800001ea <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001c6:	fff6079b          	addiw	a5,a2,-1
    800001ca:	1782                	slli	a5,a5,0x20
    800001cc:	9381                	srli	a5,a5,0x20
    800001ce:	0785                	addi	a5,a5,1
    800001d0:	97ae                	add	a5,a5,a1
    800001d2:	872a                	mv	a4,a0
      *d++ = *s++;
    800001d4:	0585                	addi	a1,a1,1
    800001d6:	0705                	addi	a4,a4,1
    800001d8:	fff5c683          	lbu	a3,-1(a1)
    800001dc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001e0:	fef59ae3          	bne	a1,a5,800001d4 <memmove+0x28>

  return dst;
}
    800001e4:	6422                	ld	s0,8(sp)
    800001e6:	0141                	addi	sp,sp,16
    800001e8:	8082                	ret
    d += n;
    800001ea:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800001ec:	fff6079b          	addiw	a5,a2,-1
    800001f0:	1782                	slli	a5,a5,0x20
    800001f2:	9381                	srli	a5,a5,0x20
    800001f4:	fff7c793          	not	a5,a5
    800001f8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800001fa:	177d                	addi	a4,a4,-1
    800001fc:	16fd                	addi	a3,a3,-1
    800001fe:	00074603          	lbu	a2,0(a4)
    80000202:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000206:	fef71ae3          	bne	a4,a5,800001fa <memmove+0x4e>
    8000020a:	bfe9                	j	800001e4 <memmove+0x38>

000000008000020c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000020c:	1141                	addi	sp,sp,-16
    8000020e:	e406                	sd	ra,8(sp)
    80000210:	e022                	sd	s0,0(sp)
    80000212:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000214:	f99ff0ef          	jal	ra,800001ac <memmove>
}
    80000218:	60a2                	ld	ra,8(sp)
    8000021a:	6402                	ld	s0,0(sp)
    8000021c:	0141                	addi	sp,sp,16
    8000021e:	8082                	ret

0000000080000220 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000220:	1141                	addi	sp,sp,-16
    80000222:	e422                	sd	s0,8(sp)
    80000224:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000226:	ce11                	beqz	a2,80000242 <strncmp+0x22>
    80000228:	00054783          	lbu	a5,0(a0)
    8000022c:	cf89                	beqz	a5,80000246 <strncmp+0x26>
    8000022e:	0005c703          	lbu	a4,0(a1)
    80000232:	00f71a63          	bne	a4,a5,80000246 <strncmp+0x26>
    n--, p++, q++;
    80000236:	367d                	addiw	a2,a2,-1
    80000238:	0505                	addi	a0,a0,1
    8000023a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000023c:	f675                	bnez	a2,80000228 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000023e:	4501                	li	a0,0
    80000240:	a809                	j	80000252 <strncmp+0x32>
    80000242:	4501                	li	a0,0
    80000244:	a039                	j	80000252 <strncmp+0x32>
  if(n == 0)
    80000246:	ca09                	beqz	a2,80000258 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000248:	00054503          	lbu	a0,0(a0)
    8000024c:	0005c783          	lbu	a5,0(a1)
    80000250:	9d1d                	subw	a0,a0,a5
}
    80000252:	6422                	ld	s0,8(sp)
    80000254:	0141                	addi	sp,sp,16
    80000256:	8082                	ret
    return 0;
    80000258:	4501                	li	a0,0
    8000025a:	bfe5                	j	80000252 <strncmp+0x32>

000000008000025c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000025c:	1141                	addi	sp,sp,-16
    8000025e:	e422                	sd	s0,8(sp)
    80000260:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000262:	872a                	mv	a4,a0
    80000264:	8832                	mv	a6,a2
    80000266:	367d                	addiw	a2,a2,-1
    80000268:	01005963          	blez	a6,8000027a <strncpy+0x1e>
    8000026c:	0705                	addi	a4,a4,1
    8000026e:	0005c783          	lbu	a5,0(a1)
    80000272:	fef70fa3          	sb	a5,-1(a4)
    80000276:	0585                	addi	a1,a1,1
    80000278:	f7f5                	bnez	a5,80000264 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000027a:	00c05d63          	blez	a2,80000294 <strncpy+0x38>
    8000027e:	86ba                	mv	a3,a4
    *s++ = 0;
    80000280:	0685                	addi	a3,a3,1
    80000282:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000286:	fff6c793          	not	a5,a3
    8000028a:	9fb9                	addw	a5,a5,a4
    8000028c:	010787bb          	addw	a5,a5,a6
    80000290:	fef048e3          	bgtz	a5,80000280 <strncpy+0x24>
  return os;
}
    80000294:	6422                	ld	s0,8(sp)
    80000296:	0141                	addi	sp,sp,16
    80000298:	8082                	ret

000000008000029a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000029a:	1141                	addi	sp,sp,-16
    8000029c:	e422                	sd	s0,8(sp)
    8000029e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002a0:	02c05363          	blez	a2,800002c6 <safestrcpy+0x2c>
    800002a4:	fff6069b          	addiw	a3,a2,-1
    800002a8:	1682                	slli	a3,a3,0x20
    800002aa:	9281                	srli	a3,a3,0x20
    800002ac:	96ae                	add	a3,a3,a1
    800002ae:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002b0:	00d58963          	beq	a1,a3,800002c2 <safestrcpy+0x28>
    800002b4:	0585                	addi	a1,a1,1
    800002b6:	0785                	addi	a5,a5,1
    800002b8:	fff5c703          	lbu	a4,-1(a1)
    800002bc:	fee78fa3          	sb	a4,-1(a5)
    800002c0:	fb65                	bnez	a4,800002b0 <safestrcpy+0x16>
    ;
  *s = 0;
    800002c2:	00078023          	sb	zero,0(a5)
  return os;
}
    800002c6:	6422                	ld	s0,8(sp)
    800002c8:	0141                	addi	sp,sp,16
    800002ca:	8082                	ret

00000000800002cc <strlen>:

int
strlen(const char *s)
{
    800002cc:	1141                	addi	sp,sp,-16
    800002ce:	e422                	sd	s0,8(sp)
    800002d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002d2:	00054783          	lbu	a5,0(a0)
    800002d6:	cf91                	beqz	a5,800002f2 <strlen+0x26>
    800002d8:	0505                	addi	a0,a0,1
    800002da:	87aa                	mv	a5,a0
    800002dc:	4685                	li	a3,1
    800002de:	9e89                	subw	a3,a3,a0
    800002e0:	00f6853b          	addw	a0,a3,a5
    800002e4:	0785                	addi	a5,a5,1
    800002e6:	fff7c703          	lbu	a4,-1(a5)
    800002ea:	fb7d                	bnez	a4,800002e0 <strlen+0x14>
    ;
  return n;
}
    800002ec:	6422                	ld	s0,8(sp)
    800002ee:	0141                	addi	sp,sp,16
    800002f0:	8082                	ret
  for(n = 0; s[n]; n++)
    800002f2:	4501                	li	a0,0
    800002f4:	bfe5                	j	800002ec <strlen+0x20>

00000000800002f6 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800002f6:	1141                	addi	sp,sp,-16
    800002f8:	e406                	sd	ra,8(sp)
    800002fa:	e022                	sd	s0,0(sp)
    800002fc:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800002fe:	1e7000ef          	jal	ra,80000ce4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000302:	00007717          	auipc	a4,0x7
    80000306:	5de70713          	addi	a4,a4,1502 # 800078e0 <started>
  if(cpuid() == 0){
    8000030a:	c51d                	beqz	a0,80000338 <main+0x42>
    while(started == 0)
    8000030c:	431c                	lw	a5,0(a4)
    8000030e:	2781                	sext.w	a5,a5
    80000310:	dff5                	beqz	a5,8000030c <main+0x16>
      ;
    __sync_synchronize();
    80000312:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000316:	1cf000ef          	jal	ra,80000ce4 <cpuid>
    8000031a:	85aa                	mv	a1,a0
    8000031c:	00007517          	auipc	a0,0x7
    80000320:	d1c50513          	addi	a0,a0,-740 # 80007038 <etext+0x38>
    80000324:	56b040ef          	jal	ra,8000508e <printf>
    kvminithart();    // turn on paging
    80000328:	080000ef          	jal	ra,800003a8 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000032c:	4d8010ef          	jal	ra,80001804 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000330:	314040ef          	jal	ra,80004644 <plicinithart>
  }

  scheduler();        
    80000334:	617000ef          	jal	ra,8000114a <scheduler>
    consoleinit();
    80000338:	47f040ef          	jal	ra,80004fb6 <consoleinit>
    printfinit();
    8000033c:	040050ef          	jal	ra,8000537c <printfinit>
    printf("\n");
    80000340:	00007517          	auipc	a0,0x7
    80000344:	d0850513          	addi	a0,a0,-760 # 80007048 <etext+0x48>
    80000348:	547040ef          	jal	ra,8000508e <printf>
    printf("xv6 kernel is booting\n");
    8000034c:	00007517          	auipc	a0,0x7
    80000350:	cd450513          	addi	a0,a0,-812 # 80007020 <etext+0x20>
    80000354:	53b040ef          	jal	ra,8000508e <printf>
    printf("\n");
    80000358:	00007517          	auipc	a0,0x7
    8000035c:	cf050513          	addi	a0,a0,-784 # 80007048 <etext+0x48>
    80000360:	52f040ef          	jal	ra,8000508e <printf>
    kinit();         // physical page allocator
    80000364:	d65ff0ef          	jal	ra,800000c8 <kinit>
    kvminit();       // create kernel page table
    80000368:	2ca000ef          	jal	ra,80000632 <kvminit>
    kvminithart();   // turn on paging
    8000036c:	03c000ef          	jal	ra,800003a8 <kvminithart>
    procinit();      // process table
    80000370:	0cd000ef          	jal	ra,80000c3c <procinit>
    trapinit();      // trap vectors
    80000374:	46c010ef          	jal	ra,800017e0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000378:	48c010ef          	jal	ra,80001804 <trapinithart>
    plicinit();      // set up interrupt controller
    8000037c:	2b2040ef          	jal	ra,8000462e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000380:	2c4040ef          	jal	ra,80004644 <plicinithart>
    binit();         // buffer cache
    80000384:	357010ef          	jal	ra,80001eda <binit>
    iinit();         // inode table
    80000388:	136020ef          	jal	ra,800024be <iinit>
    fileinit();      // file table
    8000038c:	6d1020ef          	jal	ra,8000325c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000390:	3a4040ef          	jal	ra,80004734 <virtio_disk_init>
    userinit();      // first user process
    80000394:	3f1000ef          	jal	ra,80000f84 <userinit>
    __sync_synchronize();
    80000398:	0ff0000f          	fence
    started = 1;
    8000039c:	4785                	li	a5,1
    8000039e:	00007717          	auipc	a4,0x7
    800003a2:	54f72123          	sw	a5,1346(a4) # 800078e0 <started>
    800003a6:	b779                	j	80000334 <main+0x3e>

00000000800003a8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800003a8:	1141                	addi	sp,sp,-16
    800003aa:	e422                	sd	s0,8(sp)
    800003ac:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003ae:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003b2:	00007797          	auipc	a5,0x7
    800003b6:	5367b783          	ld	a5,1334(a5) # 800078e8 <kernel_pagetable>
    800003ba:	83b1                	srli	a5,a5,0xc
    800003bc:	577d                	li	a4,-1
    800003be:	177e                	slli	a4,a4,0x3f
    800003c0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003c2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003c6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003ca:	6422                	ld	s0,8(sp)
    800003cc:	0141                	addi	sp,sp,16
    800003ce:	8082                	ret

00000000800003d0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003d0:	7139                	addi	sp,sp,-64
    800003d2:	fc06                	sd	ra,56(sp)
    800003d4:	f822                	sd	s0,48(sp)
    800003d6:	f426                	sd	s1,40(sp)
    800003d8:	f04a                	sd	s2,32(sp)
    800003da:	ec4e                	sd	s3,24(sp)
    800003dc:	e852                	sd	s4,16(sp)
    800003de:	e456                	sd	s5,8(sp)
    800003e0:	e05a                	sd	s6,0(sp)
    800003e2:	0080                	addi	s0,sp,64
    800003e4:	84aa                	mv	s1,a0
    800003e6:	89ae                	mv	s3,a1
    800003e8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800003ea:	57fd                	li	a5,-1
    800003ec:	83e9                	srli	a5,a5,0x1a
    800003ee:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800003f0:	4b31                	li	s6,12
  if(va >= MAXVA)
    800003f2:	02b7fc63          	bgeu	a5,a1,8000042a <walk+0x5a>
    panic("walk");
    800003f6:	00007517          	auipc	a0,0x7
    800003fa:	c5a50513          	addi	a0,a0,-934 # 80007050 <etext+0x50>
    800003fe:	745040ef          	jal	ra,80005342 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000402:	060a8263          	beqz	s5,80000466 <walk+0x96>
    80000406:	cf7ff0ef          	jal	ra,800000fc <kalloc>
    8000040a:	84aa                	mv	s1,a0
    8000040c:	c139                	beqz	a0,80000452 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000040e:	6605                	lui	a2,0x1
    80000410:	4581                	li	a1,0
    80000412:	d3bff0ef          	jal	ra,8000014c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000416:	00c4d793          	srli	a5,s1,0xc
    8000041a:	07aa                	slli	a5,a5,0xa
    8000041c:	0017e793          	ori	a5,a5,1
    80000420:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000424:	3a5d                	addiw	s4,s4,-9
    80000426:	036a0063          	beq	s4,s6,80000446 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000042a:	0149d933          	srl	s2,s3,s4
    8000042e:	1ff97913          	andi	s2,s2,511
    80000432:	090e                	slli	s2,s2,0x3
    80000434:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000436:	00093483          	ld	s1,0(s2)
    8000043a:	0014f793          	andi	a5,s1,1
    8000043e:	d3f1                	beqz	a5,80000402 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000440:	80a9                	srli	s1,s1,0xa
    80000442:	04b2                	slli	s1,s1,0xc
    80000444:	b7c5                	j	80000424 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000446:	00c9d513          	srli	a0,s3,0xc
    8000044a:	1ff57513          	andi	a0,a0,511
    8000044e:	050e                	slli	a0,a0,0x3
    80000450:	9526                	add	a0,a0,s1
}
    80000452:	70e2                	ld	ra,56(sp)
    80000454:	7442                	ld	s0,48(sp)
    80000456:	74a2                	ld	s1,40(sp)
    80000458:	7902                	ld	s2,32(sp)
    8000045a:	69e2                	ld	s3,24(sp)
    8000045c:	6a42                	ld	s4,16(sp)
    8000045e:	6aa2                	ld	s5,8(sp)
    80000460:	6b02                	ld	s6,0(sp)
    80000462:	6121                	addi	sp,sp,64
    80000464:	8082                	ret
        return 0;
    80000466:	4501                	li	a0,0
    80000468:	b7ed                	j	80000452 <walk+0x82>

000000008000046a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000046a:	57fd                	li	a5,-1
    8000046c:	83e9                	srli	a5,a5,0x1a
    8000046e:	00b7f463          	bgeu	a5,a1,80000476 <walkaddr+0xc>
    return 0;
    80000472:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000474:	8082                	ret
{
    80000476:	1141                	addi	sp,sp,-16
    80000478:	e406                	sd	ra,8(sp)
    8000047a:	e022                	sd	s0,0(sp)
    8000047c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000047e:	4601                	li	a2,0
    80000480:	f51ff0ef          	jal	ra,800003d0 <walk>
  if(pte == 0)
    80000484:	c105                	beqz	a0,800004a4 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000486:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000488:	0117f693          	andi	a3,a5,17
    8000048c:	4745                	li	a4,17
    return 0;
    8000048e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000490:	00e68663          	beq	a3,a4,8000049c <walkaddr+0x32>
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret
  pa = PTE2PA(*pte);
    8000049c:	00a7d513          	srli	a0,a5,0xa
    800004a0:	0532                	slli	a0,a0,0xc
  return pa;
    800004a2:	bfcd                	j	80000494 <walkaddr+0x2a>
    return 0;
    800004a4:	4501                	li	a0,0
    800004a6:	b7fd                	j	80000494 <walkaddr+0x2a>

00000000800004a8 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800004a8:	715d                	addi	sp,sp,-80
    800004aa:	e486                	sd	ra,72(sp)
    800004ac:	e0a2                	sd	s0,64(sp)
    800004ae:	fc26                	sd	s1,56(sp)
    800004b0:	f84a                	sd	s2,48(sp)
    800004b2:	f44e                	sd	s3,40(sp)
    800004b4:	f052                	sd	s4,32(sp)
    800004b6:	ec56                	sd	s5,24(sp)
    800004b8:	e85a                	sd	s6,16(sp)
    800004ba:	e45e                	sd	s7,8(sp)
    800004bc:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004be:	03459793          	slli	a5,a1,0x34
    800004c2:	e385                	bnez	a5,800004e2 <mappages+0x3a>
    800004c4:	8aaa                	mv	s5,a0
    800004c6:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004c8:	03461793          	slli	a5,a2,0x34
    800004cc:	e38d                	bnez	a5,800004ee <mappages+0x46>
    panic("mappages: size not aligned");

  if(size == 0)
    800004ce:	c615                	beqz	a2,800004fa <mappages+0x52>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800004d0:	79fd                	lui	s3,0xfffff
    800004d2:	964e                	add	a2,a2,s3
    800004d4:	00b609b3          	add	s3,a2,a1
  a = va;
    800004d8:	892e                	mv	s2,a1
    800004da:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004de:	6b85                	lui	s7,0x1
    800004e0:	a815                	j	80000514 <mappages+0x6c>
    panic("mappages: va not aligned");
    800004e2:	00007517          	auipc	a0,0x7
    800004e6:	b7650513          	addi	a0,a0,-1162 # 80007058 <etext+0x58>
    800004ea:	659040ef          	jal	ra,80005342 <panic>
    panic("mappages: size not aligned");
    800004ee:	00007517          	auipc	a0,0x7
    800004f2:	b8a50513          	addi	a0,a0,-1142 # 80007078 <etext+0x78>
    800004f6:	64d040ef          	jal	ra,80005342 <panic>
    panic("mappages: size");
    800004fa:	00007517          	auipc	a0,0x7
    800004fe:	b9e50513          	addi	a0,a0,-1122 # 80007098 <etext+0x98>
    80000502:	641040ef          	jal	ra,80005342 <panic>
      panic("mappages: remap");
    80000506:	00007517          	auipc	a0,0x7
    8000050a:	ba250513          	addi	a0,a0,-1118 # 800070a8 <etext+0xa8>
    8000050e:	635040ef          	jal	ra,80005342 <panic>
    a += PGSIZE;
    80000512:	995e                	add	s2,s2,s7
  for(;;){
    80000514:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000518:	4605                	li	a2,1
    8000051a:	85ca                	mv	a1,s2
    8000051c:	8556                	mv	a0,s5
    8000051e:	eb3ff0ef          	jal	ra,800003d0 <walk>
    80000522:	cd19                	beqz	a0,80000540 <mappages+0x98>
    if(*pte & PTE_V)
    80000524:	611c                	ld	a5,0(a0)
    80000526:	8b85                	andi	a5,a5,1
    80000528:	fff9                	bnez	a5,80000506 <mappages+0x5e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000052a:	80b1                	srli	s1,s1,0xc
    8000052c:	04aa                	slli	s1,s1,0xa
    8000052e:	0164e4b3          	or	s1,s1,s6
    80000532:	0014e493          	ori	s1,s1,1
    80000536:	e104                	sd	s1,0(a0)
    if(a == last)
    80000538:	fd391de3          	bne	s2,s3,80000512 <mappages+0x6a>
    pa += PGSIZE;
  }
  return 0;
    8000053c:	4501                	li	a0,0
    8000053e:	a011                	j	80000542 <mappages+0x9a>
      return -1;
    80000540:	557d                	li	a0,-1
}
    80000542:	60a6                	ld	ra,72(sp)
    80000544:	6406                	ld	s0,64(sp)
    80000546:	74e2                	ld	s1,56(sp)
    80000548:	7942                	ld	s2,48(sp)
    8000054a:	79a2                	ld	s3,40(sp)
    8000054c:	7a02                	ld	s4,32(sp)
    8000054e:	6ae2                	ld	s5,24(sp)
    80000550:	6b42                	ld	s6,16(sp)
    80000552:	6ba2                	ld	s7,8(sp)
    80000554:	6161                	addi	sp,sp,80
    80000556:	8082                	ret

0000000080000558 <kvmmap>:
{
    80000558:	1141                	addi	sp,sp,-16
    8000055a:	e406                	sd	ra,8(sp)
    8000055c:	e022                	sd	s0,0(sp)
    8000055e:	0800                	addi	s0,sp,16
    80000560:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000562:	86b2                	mv	a3,a2
    80000564:	863e                	mv	a2,a5
    80000566:	f43ff0ef          	jal	ra,800004a8 <mappages>
    8000056a:	e509                	bnez	a0,80000574 <kvmmap+0x1c>
}
    8000056c:	60a2                	ld	ra,8(sp)
    8000056e:	6402                	ld	s0,0(sp)
    80000570:	0141                	addi	sp,sp,16
    80000572:	8082                	ret
    panic("kvmmap");
    80000574:	00007517          	auipc	a0,0x7
    80000578:	b4450513          	addi	a0,a0,-1212 # 800070b8 <etext+0xb8>
    8000057c:	5c7040ef          	jal	ra,80005342 <panic>

0000000080000580 <kvmmake>:
{
    80000580:	1101                	addi	sp,sp,-32
    80000582:	ec06                	sd	ra,24(sp)
    80000584:	e822                	sd	s0,16(sp)
    80000586:	e426                	sd	s1,8(sp)
    80000588:	e04a                	sd	s2,0(sp)
    8000058a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000058c:	b71ff0ef          	jal	ra,800000fc <kalloc>
    80000590:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000592:	6605                	lui	a2,0x1
    80000594:	4581                	li	a1,0
    80000596:	bb7ff0ef          	jal	ra,8000014c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000059a:	4719                	li	a4,6
    8000059c:	6685                	lui	a3,0x1
    8000059e:	10000637          	lui	a2,0x10000
    800005a2:	100005b7          	lui	a1,0x10000
    800005a6:	8526                	mv	a0,s1
    800005a8:	fb1ff0ef          	jal	ra,80000558 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800005ac:	4719                	li	a4,6
    800005ae:	6685                	lui	a3,0x1
    800005b0:	10001637          	lui	a2,0x10001
    800005b4:	100015b7          	lui	a1,0x10001
    800005b8:	8526                	mv	a0,s1
    800005ba:	f9fff0ef          	jal	ra,80000558 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005be:	4719                	li	a4,6
    800005c0:	040006b7          	lui	a3,0x4000
    800005c4:	0c000637          	lui	a2,0xc000
    800005c8:	0c0005b7          	lui	a1,0xc000
    800005cc:	8526                	mv	a0,s1
    800005ce:	f8bff0ef          	jal	ra,80000558 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005d2:	00007917          	auipc	s2,0x7
    800005d6:	a2e90913          	addi	s2,s2,-1490 # 80007000 <etext>
    800005da:	4729                	li	a4,10
    800005dc:	80007697          	auipc	a3,0x80007
    800005e0:	a2468693          	addi	a3,a3,-1500 # 7000 <_entry-0x7fff9000>
    800005e4:	4605                	li	a2,1
    800005e6:	067e                	slli	a2,a2,0x1f
    800005e8:	85b2                	mv	a1,a2
    800005ea:	8526                	mv	a0,s1
    800005ec:	f6dff0ef          	jal	ra,80000558 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800005f0:	4719                	li	a4,6
    800005f2:	46c5                	li	a3,17
    800005f4:	06ee                	slli	a3,a3,0x1b
    800005f6:	412686b3          	sub	a3,a3,s2
    800005fa:	864a                	mv	a2,s2
    800005fc:	85ca                	mv	a1,s2
    800005fe:	8526                	mv	a0,s1
    80000600:	f59ff0ef          	jal	ra,80000558 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000604:	4729                	li	a4,10
    80000606:	6685                	lui	a3,0x1
    80000608:	00006617          	auipc	a2,0x6
    8000060c:	9f860613          	addi	a2,a2,-1544 # 80006000 <_trampoline>
    80000610:	040005b7          	lui	a1,0x4000
    80000614:	15fd                	addi	a1,a1,-1
    80000616:	05b2                	slli	a1,a1,0xc
    80000618:	8526                	mv	a0,s1
    8000061a:	f3fff0ef          	jal	ra,80000558 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000061e:	8526                	mv	a0,s1
    80000620:	592000ef          	jal	ra,80000bb2 <proc_mapstacks>
}
    80000624:	8526                	mv	a0,s1
    80000626:	60e2                	ld	ra,24(sp)
    80000628:	6442                	ld	s0,16(sp)
    8000062a:	64a2                	ld	s1,8(sp)
    8000062c:	6902                	ld	s2,0(sp)
    8000062e:	6105                	addi	sp,sp,32
    80000630:	8082                	ret

0000000080000632 <kvminit>:
{
    80000632:	1141                	addi	sp,sp,-16
    80000634:	e406                	sd	ra,8(sp)
    80000636:	e022                	sd	s0,0(sp)
    80000638:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000063a:	f47ff0ef          	jal	ra,80000580 <kvmmake>
    8000063e:	00007797          	auipc	a5,0x7
    80000642:	2aa7b523          	sd	a0,682(a5) # 800078e8 <kernel_pagetable>
}
    80000646:	60a2                	ld	ra,8(sp)
    80000648:	6402                	ld	s0,0(sp)
    8000064a:	0141                	addi	sp,sp,16
    8000064c:	8082                	ret

000000008000064e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000064e:	715d                	addi	sp,sp,-80
    80000650:	e486                	sd	ra,72(sp)
    80000652:	e0a2                	sd	s0,64(sp)
    80000654:	fc26                	sd	s1,56(sp)
    80000656:	f84a                	sd	s2,48(sp)
    80000658:	f44e                	sd	s3,40(sp)
    8000065a:	f052                	sd	s4,32(sp)
    8000065c:	ec56                	sd	s5,24(sp)
    8000065e:	e85a                	sd	s6,16(sp)
    80000660:	e45e                	sd	s7,8(sp)
    80000662:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000664:	03459793          	slli	a5,a1,0x34
    80000668:	e795                	bnez	a5,80000694 <uvmunmap+0x46>
    8000066a:	8a2a                	mv	s4,a0
    8000066c:	892e                	mv	s2,a1
    8000066e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000670:	0632                	slli	a2,a2,0xc
    80000672:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000676:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000678:	6b05                	lui	s6,0x1
    8000067a:	0535ee63          	bltu	a1,s3,800006d6 <uvmunmap+0x88>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000067e:	60a6                	ld	ra,72(sp)
    80000680:	6406                	ld	s0,64(sp)
    80000682:	74e2                	ld	s1,56(sp)
    80000684:	7942                	ld	s2,48(sp)
    80000686:	79a2                	ld	s3,40(sp)
    80000688:	7a02                	ld	s4,32(sp)
    8000068a:	6ae2                	ld	s5,24(sp)
    8000068c:	6b42                	ld	s6,16(sp)
    8000068e:	6ba2                	ld	s7,8(sp)
    80000690:	6161                	addi	sp,sp,80
    80000692:	8082                	ret
    panic("uvmunmap: not aligned");
    80000694:	00007517          	auipc	a0,0x7
    80000698:	a2c50513          	addi	a0,a0,-1492 # 800070c0 <etext+0xc0>
    8000069c:	4a7040ef          	jal	ra,80005342 <panic>
      panic("uvmunmap: walk");
    800006a0:	00007517          	auipc	a0,0x7
    800006a4:	a3850513          	addi	a0,a0,-1480 # 800070d8 <etext+0xd8>
    800006a8:	49b040ef          	jal	ra,80005342 <panic>
      panic("uvmunmap: not mapped");
    800006ac:	00007517          	auipc	a0,0x7
    800006b0:	a3c50513          	addi	a0,a0,-1476 # 800070e8 <etext+0xe8>
    800006b4:	48f040ef          	jal	ra,80005342 <panic>
      panic("uvmunmap: not a leaf");
    800006b8:	00007517          	auipc	a0,0x7
    800006bc:	a4850513          	addi	a0,a0,-1464 # 80007100 <etext+0x100>
    800006c0:	483040ef          	jal	ra,80005342 <panic>
      uint64 pa = PTE2PA(*pte);
    800006c4:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800006c6:	0532                	slli	a0,a0,0xc
    800006c8:	955ff0ef          	jal	ra,8000001c <kfree>
    *pte = 0;
    800006cc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800006d0:	995a                	add	s2,s2,s6
    800006d2:	fb3976e3          	bgeu	s2,s3,8000067e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800006d6:	4601                	li	a2,0
    800006d8:	85ca                	mv	a1,s2
    800006da:	8552                	mv	a0,s4
    800006dc:	cf5ff0ef          	jal	ra,800003d0 <walk>
    800006e0:	84aa                	mv	s1,a0
    800006e2:	dd5d                	beqz	a0,800006a0 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    800006e4:	6108                	ld	a0,0(a0)
    800006e6:	00157793          	andi	a5,a0,1
    800006ea:	d3e9                	beqz	a5,800006ac <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    800006ec:	3ff57793          	andi	a5,a0,1023
    800006f0:	fd7784e3          	beq	a5,s7,800006b8 <uvmunmap+0x6a>
    if(do_free){
    800006f4:	fc0a8ce3          	beqz	s5,800006cc <uvmunmap+0x7e>
    800006f8:	b7f1                	j	800006c4 <uvmunmap+0x76>

00000000800006fa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800006fa:	1101                	addi	sp,sp,-32
    800006fc:	ec06                	sd	ra,24(sp)
    800006fe:	e822                	sd	s0,16(sp)
    80000700:	e426                	sd	s1,8(sp)
    80000702:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000704:	9f9ff0ef          	jal	ra,800000fc <kalloc>
    80000708:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000070a:	c509                	beqz	a0,80000714 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000070c:	6605                	lui	a2,0x1
    8000070e:	4581                	li	a1,0
    80000710:	a3dff0ef          	jal	ra,8000014c <memset>
  return pagetable;
}
    80000714:	8526                	mv	a0,s1
    80000716:	60e2                	ld	ra,24(sp)
    80000718:	6442                	ld	s0,16(sp)
    8000071a:	64a2                	ld	s1,8(sp)
    8000071c:	6105                	addi	sp,sp,32
    8000071e:	8082                	ret

0000000080000720 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000720:	7179                	addi	sp,sp,-48
    80000722:	f406                	sd	ra,40(sp)
    80000724:	f022                	sd	s0,32(sp)
    80000726:	ec26                	sd	s1,24(sp)
    80000728:	e84a                	sd	s2,16(sp)
    8000072a:	e44e                	sd	s3,8(sp)
    8000072c:	e052                	sd	s4,0(sp)
    8000072e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000730:	6785                	lui	a5,0x1
    80000732:	04f67063          	bgeu	a2,a5,80000772 <uvmfirst+0x52>
    80000736:	8a2a                	mv	s4,a0
    80000738:	89ae                	mv	s3,a1
    8000073a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000073c:	9c1ff0ef          	jal	ra,800000fc <kalloc>
    80000740:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000742:	6605                	lui	a2,0x1
    80000744:	4581                	li	a1,0
    80000746:	a07ff0ef          	jal	ra,8000014c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000074a:	4779                	li	a4,30
    8000074c:	86ca                	mv	a3,s2
    8000074e:	6605                	lui	a2,0x1
    80000750:	4581                	li	a1,0
    80000752:	8552                	mv	a0,s4
    80000754:	d55ff0ef          	jal	ra,800004a8 <mappages>
  memmove(mem, src, sz);
    80000758:	8626                	mv	a2,s1
    8000075a:	85ce                	mv	a1,s3
    8000075c:	854a                	mv	a0,s2
    8000075e:	a4fff0ef          	jal	ra,800001ac <memmove>
}
    80000762:	70a2                	ld	ra,40(sp)
    80000764:	7402                	ld	s0,32(sp)
    80000766:	64e2                	ld	s1,24(sp)
    80000768:	6942                	ld	s2,16(sp)
    8000076a:	69a2                	ld	s3,8(sp)
    8000076c:	6a02                	ld	s4,0(sp)
    8000076e:	6145                	addi	sp,sp,48
    80000770:	8082                	ret
    panic("uvmfirst: more than a page");
    80000772:	00007517          	auipc	a0,0x7
    80000776:	9a650513          	addi	a0,a0,-1626 # 80007118 <etext+0x118>
    8000077a:	3c9040ef          	jal	ra,80005342 <panic>

000000008000077e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000077e:	1101                	addi	sp,sp,-32
    80000780:	ec06                	sd	ra,24(sp)
    80000782:	e822                	sd	s0,16(sp)
    80000784:	e426                	sd	s1,8(sp)
    80000786:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80000788:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000078a:	00b67d63          	bgeu	a2,a1,800007a4 <uvmdealloc+0x26>
    8000078e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000790:	6785                	lui	a5,0x1
    80000792:	17fd                	addi	a5,a5,-1
    80000794:	00f60733          	add	a4,a2,a5
    80000798:	767d                	lui	a2,0xfffff
    8000079a:	8f71                	and	a4,a4,a2
    8000079c:	97ae                	add	a5,a5,a1
    8000079e:	8ff1                	and	a5,a5,a2
    800007a0:	00f76863          	bltu	a4,a5,800007b0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007a4:	8526                	mv	a0,s1
    800007a6:	60e2                	ld	ra,24(sp)
    800007a8:	6442                	ld	s0,16(sp)
    800007aa:	64a2                	ld	s1,8(sp)
    800007ac:	6105                	addi	sp,sp,32
    800007ae:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007b0:	8f99                	sub	a5,a5,a4
    800007b2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007b4:	4685                	li	a3,1
    800007b6:	0007861b          	sext.w	a2,a5
    800007ba:	85ba                	mv	a1,a4
    800007bc:	e93ff0ef          	jal	ra,8000064e <uvmunmap>
    800007c0:	b7d5                	j	800007a4 <uvmdealloc+0x26>

00000000800007c2 <uvmalloc>:
  if(newsz < oldsz)
    800007c2:	08b66963          	bltu	a2,a1,80000854 <uvmalloc+0x92>
{
    800007c6:	7139                	addi	sp,sp,-64
    800007c8:	fc06                	sd	ra,56(sp)
    800007ca:	f822                	sd	s0,48(sp)
    800007cc:	f426                	sd	s1,40(sp)
    800007ce:	f04a                	sd	s2,32(sp)
    800007d0:	ec4e                	sd	s3,24(sp)
    800007d2:	e852                	sd	s4,16(sp)
    800007d4:	e456                	sd	s5,8(sp)
    800007d6:	e05a                	sd	s6,0(sp)
    800007d8:	0080                	addi	s0,sp,64
    800007da:	8aaa                	mv	s5,a0
    800007dc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800007de:	6985                	lui	s3,0x1
    800007e0:	19fd                	addi	s3,s3,-1
    800007e2:	95ce                	add	a1,a1,s3
    800007e4:	79fd                	lui	s3,0xfffff
    800007e6:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800007ea:	06c9f763          	bgeu	s3,a2,80000858 <uvmalloc+0x96>
    800007ee:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800007f0:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800007f4:	909ff0ef          	jal	ra,800000fc <kalloc>
    800007f8:	84aa                	mv	s1,a0
    if(mem == 0){
    800007fa:	c11d                	beqz	a0,80000820 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    800007fc:	6605                	lui	a2,0x1
    800007fe:	4581                	li	a1,0
    80000800:	94dff0ef          	jal	ra,8000014c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000804:	875a                	mv	a4,s6
    80000806:	86a6                	mv	a3,s1
    80000808:	6605                	lui	a2,0x1
    8000080a:	85ca                	mv	a1,s2
    8000080c:	8556                	mv	a0,s5
    8000080e:	c9bff0ef          	jal	ra,800004a8 <mappages>
    80000812:	e51d                	bnez	a0,80000840 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000814:	6785                	lui	a5,0x1
    80000816:	993e                	add	s2,s2,a5
    80000818:	fd496ee3          	bltu	s2,s4,800007f4 <uvmalloc+0x32>
  return newsz;
    8000081c:	8552                	mv	a0,s4
    8000081e:	a039                	j	8000082c <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80000820:	864e                	mv	a2,s3
    80000822:	85ca                	mv	a1,s2
    80000824:	8556                	mv	a0,s5
    80000826:	f59ff0ef          	jal	ra,8000077e <uvmdealloc>
      return 0;
    8000082a:	4501                	li	a0,0
}
    8000082c:	70e2                	ld	ra,56(sp)
    8000082e:	7442                	ld	s0,48(sp)
    80000830:	74a2                	ld	s1,40(sp)
    80000832:	7902                	ld	s2,32(sp)
    80000834:	69e2                	ld	s3,24(sp)
    80000836:	6a42                	ld	s4,16(sp)
    80000838:	6aa2                	ld	s5,8(sp)
    8000083a:	6b02                	ld	s6,0(sp)
    8000083c:	6121                	addi	sp,sp,64
    8000083e:	8082                	ret
      kfree(mem);
    80000840:	8526                	mv	a0,s1
    80000842:	fdaff0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000846:	864e                	mv	a2,s3
    80000848:	85ca                	mv	a1,s2
    8000084a:	8556                	mv	a0,s5
    8000084c:	f33ff0ef          	jal	ra,8000077e <uvmdealloc>
      return 0;
    80000850:	4501                	li	a0,0
    80000852:	bfe9                	j	8000082c <uvmalloc+0x6a>
    return oldsz;
    80000854:	852e                	mv	a0,a1
}
    80000856:	8082                	ret
  return newsz;
    80000858:	8532                	mv	a0,a2
    8000085a:	bfc9                	j	8000082c <uvmalloc+0x6a>

000000008000085c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000085c:	7179                	addi	sp,sp,-48
    8000085e:	f406                	sd	ra,40(sp)
    80000860:	f022                	sd	s0,32(sp)
    80000862:	ec26                	sd	s1,24(sp)
    80000864:	e84a                	sd	s2,16(sp)
    80000866:	e44e                	sd	s3,8(sp)
    80000868:	e052                	sd	s4,0(sp)
    8000086a:	1800                	addi	s0,sp,48
    8000086c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000086e:	84aa                	mv	s1,a0
    80000870:	6905                	lui	s2,0x1
    80000872:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000874:	4985                	li	s3,1
    80000876:	a811                	j	8000088a <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000878:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000087a:	0532                	slli	a0,a0,0xc
    8000087c:	fe1ff0ef          	jal	ra,8000085c <freewalk>
      pagetable[i] = 0;
    80000880:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000884:	04a1                	addi	s1,s1,8
    80000886:	01248f63          	beq	s1,s2,800008a4 <freewalk+0x48>
    pte_t pte = pagetable[i];
    8000088a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000088c:	00f57793          	andi	a5,a0,15
    80000890:	ff3784e3          	beq	a5,s3,80000878 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000894:	8905                	andi	a0,a0,1
    80000896:	d57d                	beqz	a0,80000884 <freewalk+0x28>
      panic("freewalk: leaf");
    80000898:	00007517          	auipc	a0,0x7
    8000089c:	8a050513          	addi	a0,a0,-1888 # 80007138 <etext+0x138>
    800008a0:	2a3040ef          	jal	ra,80005342 <panic>
    }
  }
  kfree((void*)pagetable);
    800008a4:	8552                	mv	a0,s4
    800008a6:	f76ff0ef          	jal	ra,8000001c <kfree>
}
    800008aa:	70a2                	ld	ra,40(sp)
    800008ac:	7402                	ld	s0,32(sp)
    800008ae:	64e2                	ld	s1,24(sp)
    800008b0:	6942                	ld	s2,16(sp)
    800008b2:	69a2                	ld	s3,8(sp)
    800008b4:	6a02                	ld	s4,0(sp)
    800008b6:	6145                	addi	sp,sp,48
    800008b8:	8082                	ret

00000000800008ba <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800008ba:	1101                	addi	sp,sp,-32
    800008bc:	ec06                	sd	ra,24(sp)
    800008be:	e822                	sd	s0,16(sp)
    800008c0:	e426                	sd	s1,8(sp)
    800008c2:	1000                	addi	s0,sp,32
    800008c4:	84aa                	mv	s1,a0
  if(sz > 0)
    800008c6:	e989                	bnez	a1,800008d8 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800008c8:	8526                	mv	a0,s1
    800008ca:	f93ff0ef          	jal	ra,8000085c <freewalk>
}
    800008ce:	60e2                	ld	ra,24(sp)
    800008d0:	6442                	ld	s0,16(sp)
    800008d2:	64a2                	ld	s1,8(sp)
    800008d4:	6105                	addi	sp,sp,32
    800008d6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800008d8:	6605                	lui	a2,0x1
    800008da:	167d                	addi	a2,a2,-1
    800008dc:	962e                	add	a2,a2,a1
    800008de:	4685                	li	a3,1
    800008e0:	8231                	srli	a2,a2,0xc
    800008e2:	4581                	li	a1,0
    800008e4:	d6bff0ef          	jal	ra,8000064e <uvmunmap>
    800008e8:	b7c5                	j	800008c8 <uvmfree+0xe>

00000000800008ea <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800008ea:	c65d                	beqz	a2,80000998 <uvmcopy+0xae>
{
    800008ec:	715d                	addi	sp,sp,-80
    800008ee:	e486                	sd	ra,72(sp)
    800008f0:	e0a2                	sd	s0,64(sp)
    800008f2:	fc26                	sd	s1,56(sp)
    800008f4:	f84a                	sd	s2,48(sp)
    800008f6:	f44e                	sd	s3,40(sp)
    800008f8:	f052                	sd	s4,32(sp)
    800008fa:	ec56                	sd	s5,24(sp)
    800008fc:	e85a                	sd	s6,16(sp)
    800008fe:	e45e                	sd	s7,8(sp)
    80000900:	0880                	addi	s0,sp,80
    80000902:	8b2a                	mv	s6,a0
    80000904:	8aae                	mv	s5,a1
    80000906:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000908:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000090a:	4601                	li	a2,0
    8000090c:	85ce                	mv	a1,s3
    8000090e:	855a                	mv	a0,s6
    80000910:	ac1ff0ef          	jal	ra,800003d0 <walk>
    80000914:	c121                	beqz	a0,80000954 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000916:	6118                	ld	a4,0(a0)
    80000918:	00177793          	andi	a5,a4,1
    8000091c:	c3b1                	beqz	a5,80000960 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000091e:	00a75593          	srli	a1,a4,0xa
    80000922:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000926:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000092a:	fd2ff0ef          	jal	ra,800000fc <kalloc>
    8000092e:	892a                	mv	s2,a0
    80000930:	c129                	beqz	a0,80000972 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000932:	6605                	lui	a2,0x1
    80000934:	85de                	mv	a1,s7
    80000936:	877ff0ef          	jal	ra,800001ac <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000093a:	8726                	mv	a4,s1
    8000093c:	86ca                	mv	a3,s2
    8000093e:	6605                	lui	a2,0x1
    80000940:	85ce                	mv	a1,s3
    80000942:	8556                	mv	a0,s5
    80000944:	b65ff0ef          	jal	ra,800004a8 <mappages>
    80000948:	e115                	bnez	a0,8000096c <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000094a:	6785                	lui	a5,0x1
    8000094c:	99be                	add	s3,s3,a5
    8000094e:	fb49eee3          	bltu	s3,s4,8000090a <uvmcopy+0x20>
    80000952:	a805                	j	80000982 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000954:	00006517          	auipc	a0,0x6
    80000958:	7f450513          	addi	a0,a0,2036 # 80007148 <etext+0x148>
    8000095c:	1e7040ef          	jal	ra,80005342 <panic>
      panic("uvmcopy: page not present");
    80000960:	00007517          	auipc	a0,0x7
    80000964:	80850513          	addi	a0,a0,-2040 # 80007168 <etext+0x168>
    80000968:	1db040ef          	jal	ra,80005342 <panic>
      kfree(mem);
    8000096c:	854a                	mv	a0,s2
    8000096e:	eaeff0ef          	jal	ra,8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000972:	4685                	li	a3,1
    80000974:	00c9d613          	srli	a2,s3,0xc
    80000978:	4581                	li	a1,0
    8000097a:	8556                	mv	a0,s5
    8000097c:	cd3ff0ef          	jal	ra,8000064e <uvmunmap>
  return -1;
    80000980:	557d                	li	a0,-1
}
    80000982:	60a6                	ld	ra,72(sp)
    80000984:	6406                	ld	s0,64(sp)
    80000986:	74e2                	ld	s1,56(sp)
    80000988:	7942                	ld	s2,48(sp)
    8000098a:	79a2                	ld	s3,40(sp)
    8000098c:	7a02                	ld	s4,32(sp)
    8000098e:	6ae2                	ld	s5,24(sp)
    80000990:	6b42                	ld	s6,16(sp)
    80000992:	6ba2                	ld	s7,8(sp)
    80000994:	6161                	addi	sp,sp,80
    80000996:	8082                	ret
  return 0;
    80000998:	4501                	li	a0,0
}
    8000099a:	8082                	ret

000000008000099c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000099c:	1141                	addi	sp,sp,-16
    8000099e:	e406                	sd	ra,8(sp)
    800009a0:	e022                	sd	s0,0(sp)
    800009a2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800009a4:	4601                	li	a2,0
    800009a6:	a2bff0ef          	jal	ra,800003d0 <walk>
  if(pte == 0)
    800009aa:	c901                	beqz	a0,800009ba <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800009ac:	611c                	ld	a5,0(a0)
    800009ae:	9bbd                	andi	a5,a5,-17
    800009b0:	e11c                	sd	a5,0(a0)
}
    800009b2:	60a2                	ld	ra,8(sp)
    800009b4:	6402                	ld	s0,0(sp)
    800009b6:	0141                	addi	sp,sp,16
    800009b8:	8082                	ret
    panic("uvmclear");
    800009ba:	00006517          	auipc	a0,0x6
    800009be:	7ce50513          	addi	a0,a0,1998 # 80007188 <etext+0x188>
    800009c2:	181040ef          	jal	ra,80005342 <panic>

00000000800009c6 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800009c6:	c6c9                	beqz	a3,80000a50 <copyout+0x8a>
{
    800009c8:	711d                	addi	sp,sp,-96
    800009ca:	ec86                	sd	ra,88(sp)
    800009cc:	e8a2                	sd	s0,80(sp)
    800009ce:	e4a6                	sd	s1,72(sp)
    800009d0:	e0ca                	sd	s2,64(sp)
    800009d2:	fc4e                	sd	s3,56(sp)
    800009d4:	f852                	sd	s4,48(sp)
    800009d6:	f456                	sd	s5,40(sp)
    800009d8:	f05a                	sd	s6,32(sp)
    800009da:	ec5e                	sd	s7,24(sp)
    800009dc:	e862                	sd	s8,16(sp)
    800009de:	e466                	sd	s9,8(sp)
    800009e0:	e06a                	sd	s10,0(sp)
    800009e2:	1080                	addi	s0,sp,96
    800009e4:	8baa                	mv	s7,a0
    800009e6:	8aae                	mv	s5,a1
    800009e8:	8b32                	mv	s6,a2
    800009ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800009ec:	74fd                	lui	s1,0xfffff
    800009ee:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800009f0:	57fd                	li	a5,-1
    800009f2:	83e9                	srli	a5,a5,0x1a
    800009f4:	0697e063          	bltu	a5,s1,80000a54 <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800009f8:	4cd5                	li	s9,21
    800009fa:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800009fc:	8c3e                	mv	s8,a5
    800009fe:	a025                	j	80000a26 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    80000a00:	83a9                	srli	a5,a5,0xa
    80000a02:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a04:	409a8533          	sub	a0,s5,s1
    80000a08:	0009061b          	sext.w	a2,s2
    80000a0c:	85da                	mv	a1,s6
    80000a0e:	953e                	add	a0,a0,a5
    80000a10:	f9cff0ef          	jal	ra,800001ac <memmove>

    len -= n;
    80000a14:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a18:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80000a1a:	02098963          	beqz	s3,80000a4c <copyout+0x86>
    if(va0 >= MAXVA)
    80000a1e:	034c6d63          	bltu	s8,s4,80000a58 <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    80000a22:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    80000a24:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80000a26:	4601                	li	a2,0
    80000a28:	85a6                	mv	a1,s1
    80000a2a:	855e                	mv	a0,s7
    80000a2c:	9a5ff0ef          	jal	ra,800003d0 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80000a30:	c515                	beqz	a0,80000a5c <copyout+0x96>
    80000a32:	611c                	ld	a5,0(a0)
    80000a34:	0157f713          	andi	a4,a5,21
    80000a38:	05971163          	bne	a4,s9,80000a7a <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80000a3c:	01a48a33          	add	s4,s1,s10
    80000a40:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80000a44:	fb29fee3          	bgeu	s3,s2,80000a00 <copyout+0x3a>
    80000a48:	894e                	mv	s2,s3
    80000a4a:	bf5d                	j	80000a00 <copyout+0x3a>
  }
  return 0;
    80000a4c:	4501                	li	a0,0
    80000a4e:	a801                	j	80000a5e <copyout+0x98>
    80000a50:	4501                	li	a0,0
}
    80000a52:	8082                	ret
      return -1;
    80000a54:	557d                	li	a0,-1
    80000a56:	a021                	j	80000a5e <copyout+0x98>
    80000a58:	557d                	li	a0,-1
    80000a5a:	a011                	j	80000a5e <copyout+0x98>
      return -1;
    80000a5c:	557d                	li	a0,-1
}
    80000a5e:	60e6                	ld	ra,88(sp)
    80000a60:	6446                	ld	s0,80(sp)
    80000a62:	64a6                	ld	s1,72(sp)
    80000a64:	6906                	ld	s2,64(sp)
    80000a66:	79e2                	ld	s3,56(sp)
    80000a68:	7a42                	ld	s4,48(sp)
    80000a6a:	7aa2                	ld	s5,40(sp)
    80000a6c:	7b02                	ld	s6,32(sp)
    80000a6e:	6be2                	ld	s7,24(sp)
    80000a70:	6c42                	ld	s8,16(sp)
    80000a72:	6ca2                	ld	s9,8(sp)
    80000a74:	6d02                	ld	s10,0(sp)
    80000a76:	6125                	addi	sp,sp,96
    80000a78:	8082                	ret
      return -1;
    80000a7a:	557d                	li	a0,-1
    80000a7c:	b7cd                	j	80000a5e <copyout+0x98>

0000000080000a7e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000a7e:	c2bd                	beqz	a3,80000ae4 <copyin+0x66>
{
    80000a80:	715d                	addi	sp,sp,-80
    80000a82:	e486                	sd	ra,72(sp)
    80000a84:	e0a2                	sd	s0,64(sp)
    80000a86:	fc26                	sd	s1,56(sp)
    80000a88:	f84a                	sd	s2,48(sp)
    80000a8a:	f44e                	sd	s3,40(sp)
    80000a8c:	f052                	sd	s4,32(sp)
    80000a8e:	ec56                	sd	s5,24(sp)
    80000a90:	e85a                	sd	s6,16(sp)
    80000a92:	e45e                	sd	s7,8(sp)
    80000a94:	e062                	sd	s8,0(sp)
    80000a96:	0880                	addi	s0,sp,80
    80000a98:	8b2a                	mv	s6,a0
    80000a9a:	8a2e                	mv	s4,a1
    80000a9c:	8c32                	mv	s8,a2
    80000a9e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000aa0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000aa2:	6a85                	lui	s5,0x1
    80000aa4:	a005                	j	80000ac4 <copyin+0x46>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000aa6:	9562                	add	a0,a0,s8
    80000aa8:	0004861b          	sext.w	a2,s1
    80000aac:	412505b3          	sub	a1,a0,s2
    80000ab0:	8552                	mv	a0,s4
    80000ab2:	efaff0ef          	jal	ra,800001ac <memmove>

    len -= n;
    80000ab6:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000aba:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000abc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000ac0:	02098063          	beqz	s3,80000ae0 <copyin+0x62>
    va0 = PGROUNDDOWN(srcva);
    80000ac4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000ac8:	85ca                	mv	a1,s2
    80000aca:	855a                	mv	a0,s6
    80000acc:	99fff0ef          	jal	ra,8000046a <walkaddr>
    if(pa0 == 0)
    80000ad0:	cd01                	beqz	a0,80000ae8 <copyin+0x6a>
    n = PGSIZE - (srcva - va0);
    80000ad2:	418904b3          	sub	s1,s2,s8
    80000ad6:	94d6                	add	s1,s1,s5
    if(n > len)
    80000ad8:	fc99f7e3          	bgeu	s3,s1,80000aa6 <copyin+0x28>
    80000adc:	84ce                	mv	s1,s3
    80000ade:	b7e1                	j	80000aa6 <copyin+0x28>
  }
  return 0;
    80000ae0:	4501                	li	a0,0
    80000ae2:	a021                	j	80000aea <copyin+0x6c>
    80000ae4:	4501                	li	a0,0
}
    80000ae6:	8082                	ret
      return -1;
    80000ae8:	557d                	li	a0,-1
}
    80000aea:	60a6                	ld	ra,72(sp)
    80000aec:	6406                	ld	s0,64(sp)
    80000aee:	74e2                	ld	s1,56(sp)
    80000af0:	7942                	ld	s2,48(sp)
    80000af2:	79a2                	ld	s3,40(sp)
    80000af4:	7a02                	ld	s4,32(sp)
    80000af6:	6ae2                	ld	s5,24(sp)
    80000af8:	6b42                	ld	s6,16(sp)
    80000afa:	6ba2                	ld	s7,8(sp)
    80000afc:	6c02                	ld	s8,0(sp)
    80000afe:	6161                	addi	sp,sp,80
    80000b00:	8082                	ret

0000000080000b02 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000b02:	c2d5                	beqz	a3,80000ba6 <copyinstr+0xa4>
{
    80000b04:	715d                	addi	sp,sp,-80
    80000b06:	e486                	sd	ra,72(sp)
    80000b08:	e0a2                	sd	s0,64(sp)
    80000b0a:	fc26                	sd	s1,56(sp)
    80000b0c:	f84a                	sd	s2,48(sp)
    80000b0e:	f44e                	sd	s3,40(sp)
    80000b10:	f052                	sd	s4,32(sp)
    80000b12:	ec56                	sd	s5,24(sp)
    80000b14:	e85a                	sd	s6,16(sp)
    80000b16:	e45e                	sd	s7,8(sp)
    80000b18:	0880                	addi	s0,sp,80
    80000b1a:	8a2a                	mv	s4,a0
    80000b1c:	8b2e                	mv	s6,a1
    80000b1e:	8bb2                	mv	s7,a2
    80000b20:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000b22:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b24:	6985                	lui	s3,0x1
    80000b26:	a035                	j	80000b52 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000b28:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000b2c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000b2e:	0017b793          	seqz	a5,a5
    80000b32:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000b36:	60a6                	ld	ra,72(sp)
    80000b38:	6406                	ld	s0,64(sp)
    80000b3a:	74e2                	ld	s1,56(sp)
    80000b3c:	7942                	ld	s2,48(sp)
    80000b3e:	79a2                	ld	s3,40(sp)
    80000b40:	7a02                	ld	s4,32(sp)
    80000b42:	6ae2                	ld	s5,24(sp)
    80000b44:	6b42                	ld	s6,16(sp)
    80000b46:	6ba2                	ld	s7,8(sp)
    80000b48:	6161                	addi	sp,sp,80
    80000b4a:	8082                	ret
    srcva = va0 + PGSIZE;
    80000b4c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000b50:	c4b9                	beqz	s1,80000b9e <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80000b52:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000b56:	85ca                	mv	a1,s2
    80000b58:	8552                	mv	a0,s4
    80000b5a:	911ff0ef          	jal	ra,8000046a <walkaddr>
    if(pa0 == 0)
    80000b5e:	c131                	beqz	a0,80000ba2 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80000b60:	41790833          	sub	a6,s2,s7
    80000b64:	984e                	add	a6,a6,s3
    if(n > max)
    80000b66:	0104f363          	bgeu	s1,a6,80000b6c <copyinstr+0x6a>
    80000b6a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000b6c:	955e                	add	a0,a0,s7
    80000b6e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000b72:	fc080de3          	beqz	a6,80000b4c <copyinstr+0x4a>
    80000b76:	985a                	add	a6,a6,s6
    80000b78:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000b7a:	41650633          	sub	a2,a0,s6
    80000b7e:	14fd                	addi	s1,s1,-1
    80000b80:	9b26                	add	s6,s6,s1
    80000b82:	00f60733          	add	a4,a2,a5
    80000b86:	00074703          	lbu	a4,0(a4)
    80000b8a:	df59                	beqz	a4,80000b28 <copyinstr+0x26>
        *dst = *p;
    80000b8c:	00e78023          	sb	a4,0(a5)
      --max;
    80000b90:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000b94:	0785                	addi	a5,a5,1
    while(n > 0){
    80000b96:	ff0796e3          	bne	a5,a6,80000b82 <copyinstr+0x80>
      dst++;
    80000b9a:	8b42                	mv	s6,a6
    80000b9c:	bf45                	j	80000b4c <copyinstr+0x4a>
    80000b9e:	4781                	li	a5,0
    80000ba0:	b779                	j	80000b2e <copyinstr+0x2c>
      return -1;
    80000ba2:	557d                	li	a0,-1
    80000ba4:	bf49                	j	80000b36 <copyinstr+0x34>
  int got_null = 0;
    80000ba6:	4781                	li	a5,0
  if(got_null){
    80000ba8:	0017b793          	seqz	a5,a5
    80000bac:	40f00533          	neg	a0,a5
}
    80000bb0:	8082                	ret

0000000080000bb2 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000bb2:	7139                	addi	sp,sp,-64
    80000bb4:	fc06                	sd	ra,56(sp)
    80000bb6:	f822                	sd	s0,48(sp)
    80000bb8:	f426                	sd	s1,40(sp)
    80000bba:	f04a                	sd	s2,32(sp)
    80000bbc:	ec4e                	sd	s3,24(sp)
    80000bbe:	e852                	sd	s4,16(sp)
    80000bc0:	e456                	sd	s5,8(sp)
    80000bc2:	e05a                	sd	s6,0(sp)
    80000bc4:	0080                	addi	s0,sp,64
    80000bc6:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000bc8:	00007497          	auipc	s1,0x7
    80000bcc:	19848493          	addi	s1,s1,408 # 80007d60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000bd0:	8b26                	mv	s6,s1
    80000bd2:	00006a97          	auipc	s5,0x6
    80000bd6:	42ea8a93          	addi	s5,s5,1070 # 80007000 <etext>
    80000bda:	04000937          	lui	s2,0x4000
    80000bde:	197d                	addi	s2,s2,-1
    80000be0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000be2:	00012a17          	auipc	s4,0x12
    80000be6:	97ea0a13          	addi	s4,s4,-1666 # 80012560 <tickslock>
    char *pa = kalloc();
    80000bea:	d12ff0ef          	jal	ra,800000fc <kalloc>
    80000bee:	862a                	mv	a2,a0
    if(pa == 0)
    80000bf0:	c121                	beqz	a0,80000c30 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000bf2:	416485b3          	sub	a1,s1,s6
    80000bf6:	8595                	srai	a1,a1,0x5
    80000bf8:	000ab783          	ld	a5,0(s5)
    80000bfc:	02f585b3          	mul	a1,a1,a5
    80000c00:	2585                	addiw	a1,a1,1
    80000c02:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c06:	4719                	li	a4,6
    80000c08:	6685                	lui	a3,0x1
    80000c0a:	40b905b3          	sub	a1,s2,a1
    80000c0e:	854e                	mv	a0,s3
    80000c10:	949ff0ef          	jal	ra,80000558 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c14:	2a048493          	addi	s1,s1,672
    80000c18:	fd4499e3          	bne	s1,s4,80000bea <proc_mapstacks+0x38>
  }
}
    80000c1c:	70e2                	ld	ra,56(sp)
    80000c1e:	7442                	ld	s0,48(sp)
    80000c20:	74a2                	ld	s1,40(sp)
    80000c22:	7902                	ld	s2,32(sp)
    80000c24:	69e2                	ld	s3,24(sp)
    80000c26:	6a42                	ld	s4,16(sp)
    80000c28:	6aa2                	ld	s5,8(sp)
    80000c2a:	6b02                	ld	s6,0(sp)
    80000c2c:	6121                	addi	sp,sp,64
    80000c2e:	8082                	ret
      panic("kalloc");
    80000c30:	00006517          	auipc	a0,0x6
    80000c34:	56850513          	addi	a0,a0,1384 # 80007198 <etext+0x198>
    80000c38:	70a040ef          	jal	ra,80005342 <panic>

0000000080000c3c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000c3c:	7139                	addi	sp,sp,-64
    80000c3e:	fc06                	sd	ra,56(sp)
    80000c40:	f822                	sd	s0,48(sp)
    80000c42:	f426                	sd	s1,40(sp)
    80000c44:	f04a                	sd	s2,32(sp)
    80000c46:	ec4e                	sd	s3,24(sp)
    80000c48:	e852                	sd	s4,16(sp)
    80000c4a:	e456                	sd	s5,8(sp)
    80000c4c:	e05a                	sd	s6,0(sp)
    80000c4e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000c50:	00006597          	auipc	a1,0x6
    80000c54:	55058593          	addi	a1,a1,1360 # 800071a0 <etext+0x1a0>
    80000c58:	00007517          	auipc	a0,0x7
    80000c5c:	cd850513          	addi	a0,a0,-808 # 80007930 <pid_lock>
    80000c60:	17f040ef          	jal	ra,800055de <initlock>
  initlock(&wait_lock, "wait_lock");
    80000c64:	00006597          	auipc	a1,0x6
    80000c68:	54458593          	addi	a1,a1,1348 # 800071a8 <etext+0x1a8>
    80000c6c:	00007517          	auipc	a0,0x7
    80000c70:	cdc50513          	addi	a0,a0,-804 # 80007948 <wait_lock>
    80000c74:	16b040ef          	jal	ra,800055de <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c78:	00007497          	auipc	s1,0x7
    80000c7c:	0e848493          	addi	s1,s1,232 # 80007d60 <proc>
      initlock(&p->lock, "proc");
    80000c80:	00006b17          	auipc	s6,0x6
    80000c84:	538b0b13          	addi	s6,s6,1336 # 800071b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000c88:	8aa6                	mv	s5,s1
    80000c8a:	00006a17          	auipc	s4,0x6
    80000c8e:	376a0a13          	addi	s4,s4,886 # 80007000 <etext>
    80000c92:	04000937          	lui	s2,0x4000
    80000c96:	197d                	addi	s2,s2,-1
    80000c98:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c9a:	00012997          	auipc	s3,0x12
    80000c9e:	8c698993          	addi	s3,s3,-1850 # 80012560 <tickslock>
      initlock(&p->lock, "proc");
    80000ca2:	85da                	mv	a1,s6
    80000ca4:	8526                	mv	a0,s1
    80000ca6:	139040ef          	jal	ra,800055de <initlock>
      p->state = UNUSED;
    80000caa:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000cae:	415487b3          	sub	a5,s1,s5
    80000cb2:	8795                	srai	a5,a5,0x5
    80000cb4:	000a3703          	ld	a4,0(s4)
    80000cb8:	02e787b3          	mul	a5,a5,a4
    80000cbc:	2785                	addiw	a5,a5,1
    80000cbe:	00d7979b          	slliw	a5,a5,0xd
    80000cc2:	40f907b3          	sub	a5,s2,a5
    80000cc6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cc8:	2a048493          	addi	s1,s1,672
    80000ccc:	fd349be3          	bne	s1,s3,80000ca2 <procinit+0x66>
  }
}
    80000cd0:	70e2                	ld	ra,56(sp)
    80000cd2:	7442                	ld	s0,48(sp)
    80000cd4:	74a2                	ld	s1,40(sp)
    80000cd6:	7902                	ld	s2,32(sp)
    80000cd8:	69e2                	ld	s3,24(sp)
    80000cda:	6a42                	ld	s4,16(sp)
    80000cdc:	6aa2                	ld	s5,8(sp)
    80000cde:	6b02                	ld	s6,0(sp)
    80000ce0:	6121                	addi	sp,sp,64
    80000ce2:	8082                	ret

0000000080000ce4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e422                	sd	s0,8(sp)
    80000ce8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000cea:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000cec:	2501                	sext.w	a0,a0
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
    80000cfa:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000cfc:	2781                	sext.w	a5,a5
    80000cfe:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d00:	00007517          	auipc	a0,0x7
    80000d04:	c6050513          	addi	a0,a0,-928 # 80007960 <cpus>
    80000d08:	953e                	add	a0,a0,a5
    80000d0a:	6422                	ld	s0,8(sp)
    80000d0c:	0141                	addi	sp,sp,16
    80000d0e:	8082                	ret

0000000080000d10 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d10:	1101                	addi	sp,sp,-32
    80000d12:	ec06                	sd	ra,24(sp)
    80000d14:	e822                	sd	s0,16(sp)
    80000d16:	e426                	sd	s1,8(sp)
    80000d18:	1000                	addi	s0,sp,32
  push_off();
    80000d1a:	105040ef          	jal	ra,8000561e <push_off>
    80000d1e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000d20:	2781                	sext.w	a5,a5
    80000d22:	079e                	slli	a5,a5,0x7
    80000d24:	00007717          	auipc	a4,0x7
    80000d28:	c0c70713          	addi	a4,a4,-1012 # 80007930 <pid_lock>
    80000d2c:	97ba                	add	a5,a5,a4
    80000d2e:	7b84                	ld	s1,48(a5)
  pop_off();
    80000d30:	173040ef          	jal	ra,800056a2 <pop_off>
  return p;
}
    80000d34:	8526                	mv	a0,s1
    80000d36:	60e2                	ld	ra,24(sp)
    80000d38:	6442                	ld	s0,16(sp)
    80000d3a:	64a2                	ld	s1,8(sp)
    80000d3c:	6105                	addi	sp,sp,32
    80000d3e:	8082                	ret

0000000080000d40 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e406                	sd	ra,8(sp)
    80000d44:	e022                	sd	s0,0(sp)
    80000d46:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000d48:	fc9ff0ef          	jal	ra,80000d10 <myproc>
    80000d4c:	1ab040ef          	jal	ra,800056f6 <release>

  if (first) {
    80000d50:	00007797          	auipc	a5,0x7
    80000d54:	b407a783          	lw	a5,-1216(a5) # 80007890 <first.2196>
    80000d58:	e799                	bnez	a5,80000d66 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000d5a:	2c3000ef          	jal	ra,8000181c <usertrapret>
}
    80000d5e:	60a2                	ld	ra,8(sp)
    80000d60:	6402                	ld	s0,0(sp)
    80000d62:	0141                	addi	sp,sp,16
    80000d64:	8082                	ret
    fsinit(ROOTDEV);
    80000d66:	4505                	li	a0,1
    80000d68:	6ea010ef          	jal	ra,80002452 <fsinit>
    first = 0;
    80000d6c:	00007797          	auipc	a5,0x7
    80000d70:	b207a223          	sw	zero,-1244(a5) # 80007890 <first.2196>
    __sync_synchronize();
    80000d74:	0ff0000f          	fence
    80000d78:	b7cd                	j	80000d5a <forkret+0x1a>

0000000080000d7a <allocpid>:
{
    80000d7a:	1101                	addi	sp,sp,-32
    80000d7c:	ec06                	sd	ra,24(sp)
    80000d7e:	e822                	sd	s0,16(sp)
    80000d80:	e426                	sd	s1,8(sp)
    80000d82:	e04a                	sd	s2,0(sp)
    80000d84:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000d86:	00007917          	auipc	s2,0x7
    80000d8a:	baa90913          	addi	s2,s2,-1110 # 80007930 <pid_lock>
    80000d8e:	854a                	mv	a0,s2
    80000d90:	0cf040ef          	jal	ra,8000565e <acquire>
  pid = nextpid;
    80000d94:	00007797          	auipc	a5,0x7
    80000d98:	b0078793          	addi	a5,a5,-1280 # 80007894 <nextpid>
    80000d9c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000d9e:	0014871b          	addiw	a4,s1,1
    80000da2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000da4:	854a                	mv	a0,s2
    80000da6:	151040ef          	jal	ra,800056f6 <release>
}
    80000daa:	8526                	mv	a0,s1
    80000dac:	60e2                	ld	ra,24(sp)
    80000dae:	6442                	ld	s0,16(sp)
    80000db0:	64a2                	ld	s1,8(sp)
    80000db2:	6902                	ld	s2,0(sp)
    80000db4:	6105                	addi	sp,sp,32
    80000db6:	8082                	ret

0000000080000db8 <proc_pagetable>:
{
    80000db8:	1101                	addi	sp,sp,-32
    80000dba:	ec06                	sd	ra,24(sp)
    80000dbc:	e822                	sd	s0,16(sp)
    80000dbe:	e426                	sd	s1,8(sp)
    80000dc0:	e04a                	sd	s2,0(sp)
    80000dc2:	1000                	addi	s0,sp,32
    80000dc4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000dc6:	935ff0ef          	jal	ra,800006fa <uvmcreate>
    80000dca:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000dcc:	cd05                	beqz	a0,80000e04 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000dce:	4729                	li	a4,10
    80000dd0:	00005697          	auipc	a3,0x5
    80000dd4:	23068693          	addi	a3,a3,560 # 80006000 <_trampoline>
    80000dd8:	6605                	lui	a2,0x1
    80000dda:	040005b7          	lui	a1,0x4000
    80000dde:	15fd                	addi	a1,a1,-1
    80000de0:	05b2                	slli	a1,a1,0xc
    80000de2:	ec6ff0ef          	jal	ra,800004a8 <mappages>
    80000de6:	02054663          	bltz	a0,80000e12 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000dea:	4719                	li	a4,6
    80000dec:	05893683          	ld	a3,88(s2)
    80000df0:	6605                	lui	a2,0x1
    80000df2:	020005b7          	lui	a1,0x2000
    80000df6:	15fd                	addi	a1,a1,-1
    80000df8:	05b6                	slli	a1,a1,0xd
    80000dfa:	8526                	mv	a0,s1
    80000dfc:	eacff0ef          	jal	ra,800004a8 <mappages>
    80000e00:	00054f63          	bltz	a0,80000e1e <proc_pagetable+0x66>
}
    80000e04:	8526                	mv	a0,s1
    80000e06:	60e2                	ld	ra,24(sp)
    80000e08:	6442                	ld	s0,16(sp)
    80000e0a:	64a2                	ld	s1,8(sp)
    80000e0c:	6902                	ld	s2,0(sp)
    80000e0e:	6105                	addi	sp,sp,32
    80000e10:	8082                	ret
    uvmfree(pagetable, 0);
    80000e12:	4581                	li	a1,0
    80000e14:	8526                	mv	a0,s1
    80000e16:	aa5ff0ef          	jal	ra,800008ba <uvmfree>
    return 0;
    80000e1a:	4481                	li	s1,0
    80000e1c:	b7e5                	j	80000e04 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000e1e:	4681                	li	a3,0
    80000e20:	4605                	li	a2,1
    80000e22:	040005b7          	lui	a1,0x4000
    80000e26:	15fd                	addi	a1,a1,-1
    80000e28:	05b2                	slli	a1,a1,0xc
    80000e2a:	8526                	mv	a0,s1
    80000e2c:	823ff0ef          	jal	ra,8000064e <uvmunmap>
    uvmfree(pagetable, 0);
    80000e30:	4581                	li	a1,0
    80000e32:	8526                	mv	a0,s1
    80000e34:	a87ff0ef          	jal	ra,800008ba <uvmfree>
    return 0;
    80000e38:	4481                	li	s1,0
    80000e3a:	b7e9                	j	80000e04 <proc_pagetable+0x4c>

0000000080000e3c <proc_freepagetable>:
{
    80000e3c:	1101                	addi	sp,sp,-32
    80000e3e:	ec06                	sd	ra,24(sp)
    80000e40:	e822                	sd	s0,16(sp)
    80000e42:	e426                	sd	s1,8(sp)
    80000e44:	e04a                	sd	s2,0(sp)
    80000e46:	1000                	addi	s0,sp,32
    80000e48:	84aa                	mv	s1,a0
    80000e4a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000e4c:	4681                	li	a3,0
    80000e4e:	4605                	li	a2,1
    80000e50:	040005b7          	lui	a1,0x4000
    80000e54:	15fd                	addi	a1,a1,-1
    80000e56:	05b2                	slli	a1,a1,0xc
    80000e58:	ff6ff0ef          	jal	ra,8000064e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000e5c:	4681                	li	a3,0
    80000e5e:	4605                	li	a2,1
    80000e60:	020005b7          	lui	a1,0x2000
    80000e64:	15fd                	addi	a1,a1,-1
    80000e66:	05b6                	slli	a1,a1,0xd
    80000e68:	8526                	mv	a0,s1
    80000e6a:	fe4ff0ef          	jal	ra,8000064e <uvmunmap>
  uvmfree(pagetable, sz);
    80000e6e:	85ca                	mv	a1,s2
    80000e70:	8526                	mv	a0,s1
    80000e72:	a49ff0ef          	jal	ra,800008ba <uvmfree>
}
    80000e76:	60e2                	ld	ra,24(sp)
    80000e78:	6442                	ld	s0,16(sp)
    80000e7a:	64a2                	ld	s1,8(sp)
    80000e7c:	6902                	ld	s2,0(sp)
    80000e7e:	6105                	addi	sp,sp,32
    80000e80:	8082                	ret

0000000080000e82 <freeproc>:
{
    80000e82:	1101                	addi	sp,sp,-32
    80000e84:	ec06                	sd	ra,24(sp)
    80000e86:	e822                	sd	s0,16(sp)
    80000e88:	e426                	sd	s1,8(sp)
    80000e8a:	1000                	addi	s0,sp,32
    80000e8c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000e8e:	6d28                	ld	a0,88(a0)
    80000e90:	c119                	beqz	a0,80000e96 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000e92:	98aff0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    80000e96:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000e9a:	68a8                	ld	a0,80(s1)
    80000e9c:	c501                	beqz	a0,80000ea4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000e9e:	64ac                	ld	a1,72(s1)
    80000ea0:	f9dff0ef          	jal	ra,80000e3c <proc_freepagetable>
  p->pagetable = 0;
    80000ea4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000ea8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000eac:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000eb0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000eb4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000eb8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000ebc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000ec0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000ec4:	0004ac23          	sw	zero,24(s1)
}
    80000ec8:	60e2                	ld	ra,24(sp)
    80000eca:	6442                	ld	s0,16(sp)
    80000ecc:	64a2                	ld	s1,8(sp)
    80000ece:	6105                	addi	sp,sp,32
    80000ed0:	8082                	ret

0000000080000ed2 <allocproc>:
{
    80000ed2:	1101                	addi	sp,sp,-32
    80000ed4:	ec06                	sd	ra,24(sp)
    80000ed6:	e822                	sd	s0,16(sp)
    80000ed8:	e426                	sd	s1,8(sp)
    80000eda:	e04a                	sd	s2,0(sp)
    80000edc:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ede:	00007497          	auipc	s1,0x7
    80000ee2:	e8248493          	addi	s1,s1,-382 # 80007d60 <proc>
    80000ee6:	00011917          	auipc	s2,0x11
    80000eea:	67a90913          	addi	s2,s2,1658 # 80012560 <tickslock>
    acquire(&p->lock);
    80000eee:	8526                	mv	a0,s1
    80000ef0:	76e040ef          	jal	ra,8000565e <acquire>
    if(p->state == UNUSED) {
    80000ef4:	4c9c                	lw	a5,24(s1)
    80000ef6:	cb91                	beqz	a5,80000f0a <allocproc+0x38>
      release(&p->lock);
    80000ef8:	8526                	mv	a0,s1
    80000efa:	7fc040ef          	jal	ra,800056f6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000efe:	2a048493          	addi	s1,s1,672
    80000f02:	ff2496e3          	bne	s1,s2,80000eee <allocproc+0x1c>
  return 0;
    80000f06:	4481                	li	s1,0
    80000f08:	a0b9                	j	80000f56 <allocproc+0x84>
  p->pid = allocpid();
    80000f0a:	e71ff0ef          	jal	ra,80000d7a <allocpid>
    80000f0e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000f10:	4785                	li	a5,1
    80000f12:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000f14:	9e8ff0ef          	jal	ra,800000fc <kalloc>
    80000f18:	892a                	mv	s2,a0
    80000f1a:	eca8                	sd	a0,88(s1)
    80000f1c:	c521                	beqz	a0,80000f64 <allocproc+0x92>
  p->pagetable = proc_pagetable(p);
    80000f1e:	8526                	mv	a0,s1
    80000f20:	e99ff0ef          	jal	ra,80000db8 <proc_pagetable>
    80000f24:	892a                	mv	s2,a0
    80000f26:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000f28:	c531                	beqz	a0,80000f74 <allocproc+0xa2>
  memset(&p->context, 0, sizeof(p->context));
    80000f2a:	07000613          	li	a2,112
    80000f2e:	4581                	li	a1,0
    80000f30:	06048513          	addi	a0,s1,96
    80000f34:	a18ff0ef          	jal	ra,8000014c <memset>
  p->context.ra = (uint64)forkret;
    80000f38:	00000797          	auipc	a5,0x0
    80000f3c:	e0878793          	addi	a5,a5,-504 # 80000d40 <forkret>
    80000f40:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000f42:	60bc                	ld	a5,64(s1)
    80000f44:	6705                	lui	a4,0x1
    80000f46:	97ba                	add	a5,a5,a4
    80000f48:	f4bc                	sd	a5,104(s1)
  p->interval=0;
    80000f4a:	1604a423          	sw	zero,360(s1)
  p->handler=0;
    80000f4e:	1604b823          	sd	zero,368(s1)
  p->passedticks=0;
    80000f52:	1604ac23          	sw	zero,376(s1)
}
    80000f56:	8526                	mv	a0,s1
    80000f58:	60e2                	ld	ra,24(sp)
    80000f5a:	6442                	ld	s0,16(sp)
    80000f5c:	64a2                	ld	s1,8(sp)
    80000f5e:	6902                	ld	s2,0(sp)
    80000f60:	6105                	addi	sp,sp,32
    80000f62:	8082                	ret
    freeproc(p);
    80000f64:	8526                	mv	a0,s1
    80000f66:	f1dff0ef          	jal	ra,80000e82 <freeproc>
    release(&p->lock);
    80000f6a:	8526                	mv	a0,s1
    80000f6c:	78a040ef          	jal	ra,800056f6 <release>
    return 0;
    80000f70:	84ca                	mv	s1,s2
    80000f72:	b7d5                	j	80000f56 <allocproc+0x84>
    freeproc(p);
    80000f74:	8526                	mv	a0,s1
    80000f76:	f0dff0ef          	jal	ra,80000e82 <freeproc>
    release(&p->lock);
    80000f7a:	8526                	mv	a0,s1
    80000f7c:	77a040ef          	jal	ra,800056f6 <release>
    return 0;
    80000f80:	84ca                	mv	s1,s2
    80000f82:	bfd1                	j	80000f56 <allocproc+0x84>

0000000080000f84 <userinit>:
{
    80000f84:	1101                	addi	sp,sp,-32
    80000f86:	ec06                	sd	ra,24(sp)
    80000f88:	e822                	sd	s0,16(sp)
    80000f8a:	e426                	sd	s1,8(sp)
    80000f8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80000f8e:	f45ff0ef          	jal	ra,80000ed2 <allocproc>
    80000f92:	84aa                	mv	s1,a0
  initproc = p;
    80000f94:	00007797          	auipc	a5,0x7
    80000f98:	94a7be23          	sd	a0,-1700(a5) # 800078f0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80000f9c:	03400613          	li	a2,52
    80000fa0:	00007597          	auipc	a1,0x7
    80000fa4:	90058593          	addi	a1,a1,-1792 # 800078a0 <initcode>
    80000fa8:	6928                	ld	a0,80(a0)
    80000faa:	f76ff0ef          	jal	ra,80000720 <uvmfirst>
  p->sz = PGSIZE;
    80000fae:	6785                	lui	a5,0x1
    80000fb0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80000fb2:	6cb8                	ld	a4,88(s1)
    80000fb4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80000fb8:	6cb8                	ld	a4,88(s1)
    80000fba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80000fbc:	4641                	li	a2,16
    80000fbe:	00006597          	auipc	a1,0x6
    80000fc2:	20258593          	addi	a1,a1,514 # 800071c0 <etext+0x1c0>
    80000fc6:	15848513          	addi	a0,s1,344
    80000fca:	ad0ff0ef          	jal	ra,8000029a <safestrcpy>
  p->cwd = namei("/");
    80000fce:	00006517          	auipc	a0,0x6
    80000fd2:	20250513          	addi	a0,a0,514 # 800071d0 <etext+0x1d0>
    80000fd6:	55b010ef          	jal	ra,80002d30 <namei>
    80000fda:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80000fde:	478d                	li	a5,3
    80000fe0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80000fe2:	8526                	mv	a0,s1
    80000fe4:	712040ef          	jal	ra,800056f6 <release>
}
    80000fe8:	60e2                	ld	ra,24(sp)
    80000fea:	6442                	ld	s0,16(sp)
    80000fec:	64a2                	ld	s1,8(sp)
    80000fee:	6105                	addi	sp,sp,32
    80000ff0:	8082                	ret

0000000080000ff2 <growproc>:
{
    80000ff2:	1101                	addi	sp,sp,-32
    80000ff4:	ec06                	sd	ra,24(sp)
    80000ff6:	e822                	sd	s0,16(sp)
    80000ff8:	e426                	sd	s1,8(sp)
    80000ffa:	e04a                	sd	s2,0(sp)
    80000ffc:	1000                	addi	s0,sp,32
    80000ffe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001000:	d11ff0ef          	jal	ra,80000d10 <myproc>
    80001004:	84aa                	mv	s1,a0
  sz = p->sz;
    80001006:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001008:	01204c63          	bgtz	s2,80001020 <growproc+0x2e>
  } else if(n < 0){
    8000100c:	02094463          	bltz	s2,80001034 <growproc+0x42>
  p->sz = sz;
    80001010:	e4ac                	sd	a1,72(s1)
  return 0;
    80001012:	4501                	li	a0,0
}
    80001014:	60e2                	ld	ra,24(sp)
    80001016:	6442                	ld	s0,16(sp)
    80001018:	64a2                	ld	s1,8(sp)
    8000101a:	6902                	ld	s2,0(sp)
    8000101c:	6105                	addi	sp,sp,32
    8000101e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001020:	4691                	li	a3,4
    80001022:	00b90633          	add	a2,s2,a1
    80001026:	6928                	ld	a0,80(a0)
    80001028:	f9aff0ef          	jal	ra,800007c2 <uvmalloc>
    8000102c:	85aa                	mv	a1,a0
    8000102e:	f16d                	bnez	a0,80001010 <growproc+0x1e>
      return -1;
    80001030:	557d                	li	a0,-1
    80001032:	b7cd                	j	80001014 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001034:	00b90633          	add	a2,s2,a1
    80001038:	6928                	ld	a0,80(a0)
    8000103a:	f44ff0ef          	jal	ra,8000077e <uvmdealloc>
    8000103e:	85aa                	mv	a1,a0
    80001040:	bfc1                	j	80001010 <growproc+0x1e>

0000000080001042 <fork>:
{
    80001042:	7179                	addi	sp,sp,-48
    80001044:	f406                	sd	ra,40(sp)
    80001046:	f022                	sd	s0,32(sp)
    80001048:	ec26                	sd	s1,24(sp)
    8000104a:	e84a                	sd	s2,16(sp)
    8000104c:	e44e                	sd	s3,8(sp)
    8000104e:	e052                	sd	s4,0(sp)
    80001050:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001052:	cbfff0ef          	jal	ra,80000d10 <myproc>
    80001056:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001058:	e7bff0ef          	jal	ra,80000ed2 <allocproc>
    8000105c:	0e050563          	beqz	a0,80001146 <fork+0x104>
    80001060:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001062:	04893603          	ld	a2,72(s2)
    80001066:	692c                	ld	a1,80(a0)
    80001068:	05093503          	ld	a0,80(s2)
    8000106c:	87fff0ef          	jal	ra,800008ea <uvmcopy>
    80001070:	04054663          	bltz	a0,800010bc <fork+0x7a>
  np->sz = p->sz;
    80001074:	04893783          	ld	a5,72(s2)
    80001078:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    8000107c:	05893683          	ld	a3,88(s2)
    80001080:	87b6                	mv	a5,a3
    80001082:	0589b703          	ld	a4,88(s3)
    80001086:	12068693          	addi	a3,a3,288
    8000108a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000108e:	6788                	ld	a0,8(a5)
    80001090:	6b8c                	ld	a1,16(a5)
    80001092:	6f90                	ld	a2,24(a5)
    80001094:	01073023          	sd	a6,0(a4)
    80001098:	e708                	sd	a0,8(a4)
    8000109a:	eb0c                	sd	a1,16(a4)
    8000109c:	ef10                	sd	a2,24(a4)
    8000109e:	02078793          	addi	a5,a5,32
    800010a2:	02070713          	addi	a4,a4,32
    800010a6:	fed792e3          	bne	a5,a3,8000108a <fork+0x48>
  np->trapframe->a0 = 0;
    800010aa:	0589b783          	ld	a5,88(s3)
    800010ae:	0607b823          	sd	zero,112(a5)
    800010b2:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    800010b6:	15000a13          	li	s4,336
    800010ba:	a00d                	j	800010dc <fork+0x9a>
    freeproc(np);
    800010bc:	854e                	mv	a0,s3
    800010be:	dc5ff0ef          	jal	ra,80000e82 <freeproc>
    release(&np->lock);
    800010c2:	854e                	mv	a0,s3
    800010c4:	632040ef          	jal	ra,800056f6 <release>
    return -1;
    800010c8:	5a7d                	li	s4,-1
    800010ca:	a0ad                	j	80001134 <fork+0xf2>
      np->ofile[i] = filedup(p->ofile[i]);
    800010cc:	212020ef          	jal	ra,800032de <filedup>
    800010d0:	009987b3          	add	a5,s3,s1
    800010d4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800010d6:	04a1                	addi	s1,s1,8
    800010d8:	01448763          	beq	s1,s4,800010e6 <fork+0xa4>
    if(p->ofile[i])
    800010dc:	009907b3          	add	a5,s2,s1
    800010e0:	6388                	ld	a0,0(a5)
    800010e2:	f56d                	bnez	a0,800010cc <fork+0x8a>
    800010e4:	bfcd                	j	800010d6 <fork+0x94>
  np->cwd = idup(p->cwd);
    800010e6:	15093503          	ld	a0,336(s2)
    800010ea:	55e010ef          	jal	ra,80002648 <idup>
    800010ee:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800010f2:	4641                	li	a2,16
    800010f4:	15890593          	addi	a1,s2,344
    800010f8:	15898513          	addi	a0,s3,344
    800010fc:	99eff0ef          	jal	ra,8000029a <safestrcpy>
  pid = np->pid;
    80001100:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001104:	854e                	mv	a0,s3
    80001106:	5f0040ef          	jal	ra,800056f6 <release>
  acquire(&wait_lock);
    8000110a:	00007497          	auipc	s1,0x7
    8000110e:	83e48493          	addi	s1,s1,-1986 # 80007948 <wait_lock>
    80001112:	8526                	mv	a0,s1
    80001114:	54a040ef          	jal	ra,8000565e <acquire>
  np->parent = p;
    80001118:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    8000111c:	8526                	mv	a0,s1
    8000111e:	5d8040ef          	jal	ra,800056f6 <release>
  acquire(&np->lock);
    80001122:	854e                	mv	a0,s3
    80001124:	53a040ef          	jal	ra,8000565e <acquire>
  np->state = RUNNABLE;
    80001128:	478d                	li	a5,3
    8000112a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    8000112e:	854e                	mv	a0,s3
    80001130:	5c6040ef          	jal	ra,800056f6 <release>
}
    80001134:	8552                	mv	a0,s4
    80001136:	70a2                	ld	ra,40(sp)
    80001138:	7402                	ld	s0,32(sp)
    8000113a:	64e2                	ld	s1,24(sp)
    8000113c:	6942                	ld	s2,16(sp)
    8000113e:	69a2                	ld	s3,8(sp)
    80001140:	6a02                	ld	s4,0(sp)
    80001142:	6145                	addi	sp,sp,48
    80001144:	8082                	ret
    return -1;
    80001146:	5a7d                	li	s4,-1
    80001148:	b7f5                	j	80001134 <fork+0xf2>

000000008000114a <scheduler>:
{
    8000114a:	715d                	addi	sp,sp,-80
    8000114c:	e486                	sd	ra,72(sp)
    8000114e:	e0a2                	sd	s0,64(sp)
    80001150:	fc26                	sd	s1,56(sp)
    80001152:	f84a                	sd	s2,48(sp)
    80001154:	f44e                	sd	s3,40(sp)
    80001156:	f052                	sd	s4,32(sp)
    80001158:	ec56                	sd	s5,24(sp)
    8000115a:	e85a                	sd	s6,16(sp)
    8000115c:	e45e                	sd	s7,8(sp)
    8000115e:	e062                	sd	s8,0(sp)
    80001160:	0880                	addi	s0,sp,80
    80001162:	8792                	mv	a5,tp
  int id = r_tp();
    80001164:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001166:	00779b13          	slli	s6,a5,0x7
    8000116a:	00006717          	auipc	a4,0x6
    8000116e:	7c670713          	addi	a4,a4,1990 # 80007930 <pid_lock>
    80001172:	975a                	add	a4,a4,s6
    80001174:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001178:	00006717          	auipc	a4,0x6
    8000117c:	7f070713          	addi	a4,a4,2032 # 80007968 <cpus+0x8>
    80001180:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001182:	4c11                	li	s8,4
        c->proc = p;
    80001184:	079e                	slli	a5,a5,0x7
    80001186:	00006a17          	auipc	s4,0x6
    8000118a:	7aaa0a13          	addi	s4,s4,1962 # 80007930 <pid_lock>
    8000118e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001190:	00011997          	auipc	s3,0x11
    80001194:	3d098993          	addi	s3,s3,976 # 80012560 <tickslock>
        found = 1;
    80001198:	4b85                	li	s7,1
    8000119a:	a0a9                	j	800011e4 <scheduler+0x9a>
        p->state = RUNNING;
    8000119c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    800011a0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800011a4:	06048593          	addi	a1,s1,96
    800011a8:	855a                	mv	a0,s6
    800011aa:	5cc000ef          	jal	ra,80001776 <swtch>
        c->proc = 0;
    800011ae:	020a3823          	sd	zero,48(s4)
        found = 1;
    800011b2:	8ade                	mv	s5,s7
      release(&p->lock);
    800011b4:	8526                	mv	a0,s1
    800011b6:	540040ef          	jal	ra,800056f6 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800011ba:	2a048493          	addi	s1,s1,672
    800011be:	01348963          	beq	s1,s3,800011d0 <scheduler+0x86>
      acquire(&p->lock);
    800011c2:	8526                	mv	a0,s1
    800011c4:	49a040ef          	jal	ra,8000565e <acquire>
      if(p->state == RUNNABLE) {
    800011c8:	4c9c                	lw	a5,24(s1)
    800011ca:	ff2795e3          	bne	a5,s2,800011b4 <scheduler+0x6a>
    800011ce:	b7f9                	j	8000119c <scheduler+0x52>
    if(found == 0) {
    800011d0:	000a9a63          	bnez	s5,800011e4 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800011d4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800011d8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800011dc:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800011e0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800011e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800011e8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800011ec:	10079073          	csrw	sstatus,a5
    int found = 0;
    800011f0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800011f2:	00007497          	auipc	s1,0x7
    800011f6:	b6e48493          	addi	s1,s1,-1170 # 80007d60 <proc>
      if(p->state == RUNNABLE) {
    800011fa:	490d                	li	s2,3
    800011fc:	b7d9                	j	800011c2 <scheduler+0x78>

00000000800011fe <sched>:
{
    800011fe:	7179                	addi	sp,sp,-48
    80001200:	f406                	sd	ra,40(sp)
    80001202:	f022                	sd	s0,32(sp)
    80001204:	ec26                	sd	s1,24(sp)
    80001206:	e84a                	sd	s2,16(sp)
    80001208:	e44e                	sd	s3,8(sp)
    8000120a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000120c:	b05ff0ef          	jal	ra,80000d10 <myproc>
    80001210:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001212:	3e2040ef          	jal	ra,800055f4 <holding>
    80001216:	c92d                	beqz	a0,80001288 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001218:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000121a:	2781                	sext.w	a5,a5
    8000121c:	079e                	slli	a5,a5,0x7
    8000121e:	00006717          	auipc	a4,0x6
    80001222:	71270713          	addi	a4,a4,1810 # 80007930 <pid_lock>
    80001226:	97ba                	add	a5,a5,a4
    80001228:	0a87a703          	lw	a4,168(a5)
    8000122c:	4785                	li	a5,1
    8000122e:	06f71363          	bne	a4,a5,80001294 <sched+0x96>
  if(p->state == RUNNING)
    80001232:	4c98                	lw	a4,24(s1)
    80001234:	4791                	li	a5,4
    80001236:	06f70563          	beq	a4,a5,800012a0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000123a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000123e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001240:	e7b5                	bnez	a5,800012ac <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001242:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001244:	00006917          	auipc	s2,0x6
    80001248:	6ec90913          	addi	s2,s2,1772 # 80007930 <pid_lock>
    8000124c:	2781                	sext.w	a5,a5
    8000124e:	079e                	slli	a5,a5,0x7
    80001250:	97ca                	add	a5,a5,s2
    80001252:	0ac7a983          	lw	s3,172(a5)
    80001256:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001258:	2781                	sext.w	a5,a5
    8000125a:	079e                	slli	a5,a5,0x7
    8000125c:	00006597          	auipc	a1,0x6
    80001260:	70c58593          	addi	a1,a1,1804 # 80007968 <cpus+0x8>
    80001264:	95be                	add	a1,a1,a5
    80001266:	06048513          	addi	a0,s1,96
    8000126a:	50c000ef          	jal	ra,80001776 <swtch>
    8000126e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001270:	2781                	sext.w	a5,a5
    80001272:	079e                	slli	a5,a5,0x7
    80001274:	97ca                	add	a5,a5,s2
    80001276:	0b37a623          	sw	s3,172(a5)
}
    8000127a:	70a2                	ld	ra,40(sp)
    8000127c:	7402                	ld	s0,32(sp)
    8000127e:	64e2                	ld	s1,24(sp)
    80001280:	6942                	ld	s2,16(sp)
    80001282:	69a2                	ld	s3,8(sp)
    80001284:	6145                	addi	sp,sp,48
    80001286:	8082                	ret
    panic("sched p->lock");
    80001288:	00006517          	auipc	a0,0x6
    8000128c:	f5050513          	addi	a0,a0,-176 # 800071d8 <etext+0x1d8>
    80001290:	0b2040ef          	jal	ra,80005342 <panic>
    panic("sched locks");
    80001294:	00006517          	auipc	a0,0x6
    80001298:	f5450513          	addi	a0,a0,-172 # 800071e8 <etext+0x1e8>
    8000129c:	0a6040ef          	jal	ra,80005342 <panic>
    panic("sched running");
    800012a0:	00006517          	auipc	a0,0x6
    800012a4:	f5850513          	addi	a0,a0,-168 # 800071f8 <etext+0x1f8>
    800012a8:	09a040ef          	jal	ra,80005342 <panic>
    panic("sched interruptible");
    800012ac:	00006517          	auipc	a0,0x6
    800012b0:	f5c50513          	addi	a0,a0,-164 # 80007208 <etext+0x208>
    800012b4:	08e040ef          	jal	ra,80005342 <panic>

00000000800012b8 <yield>:
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800012c2:	a4fff0ef          	jal	ra,80000d10 <myproc>
    800012c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800012c8:	396040ef          	jal	ra,8000565e <acquire>
  p->state = RUNNABLE;
    800012cc:	478d                	li	a5,3
    800012ce:	cc9c                	sw	a5,24(s1)
  sched();
    800012d0:	f2fff0ef          	jal	ra,800011fe <sched>
  release(&p->lock);
    800012d4:	8526                	mv	a0,s1
    800012d6:	420040ef          	jal	ra,800056f6 <release>
}
    800012da:	60e2                	ld	ra,24(sp)
    800012dc:	6442                	ld	s0,16(sp)
    800012de:	64a2                	ld	s1,8(sp)
    800012e0:	6105                	addi	sp,sp,32
    800012e2:	8082                	ret

00000000800012e4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800012e4:	7179                	addi	sp,sp,-48
    800012e6:	f406                	sd	ra,40(sp)
    800012e8:	f022                	sd	s0,32(sp)
    800012ea:	ec26                	sd	s1,24(sp)
    800012ec:	e84a                	sd	s2,16(sp)
    800012ee:	e44e                	sd	s3,8(sp)
    800012f0:	1800                	addi	s0,sp,48
    800012f2:	89aa                	mv	s3,a0
    800012f4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800012f6:	a1bff0ef          	jal	ra,80000d10 <myproc>
    800012fa:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800012fc:	362040ef          	jal	ra,8000565e <acquire>
  release(lk);
    80001300:	854a                	mv	a0,s2
    80001302:	3f4040ef          	jal	ra,800056f6 <release>

  // Go to sleep.
  p->chan = chan;
    80001306:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000130a:	4789                	li	a5,2
    8000130c:	cc9c                	sw	a5,24(s1)

  sched();
    8000130e:	ef1ff0ef          	jal	ra,800011fe <sched>

  // Tidy up.
  p->chan = 0;
    80001312:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001316:	8526                	mv	a0,s1
    80001318:	3de040ef          	jal	ra,800056f6 <release>
  acquire(lk);
    8000131c:	854a                	mv	a0,s2
    8000131e:	340040ef          	jal	ra,8000565e <acquire>
}
    80001322:	70a2                	ld	ra,40(sp)
    80001324:	7402                	ld	s0,32(sp)
    80001326:	64e2                	ld	s1,24(sp)
    80001328:	6942                	ld	s2,16(sp)
    8000132a:	69a2                	ld	s3,8(sp)
    8000132c:	6145                	addi	sp,sp,48
    8000132e:	8082                	ret

0000000080001330 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001330:	7139                	addi	sp,sp,-64
    80001332:	fc06                	sd	ra,56(sp)
    80001334:	f822                	sd	s0,48(sp)
    80001336:	f426                	sd	s1,40(sp)
    80001338:	f04a                	sd	s2,32(sp)
    8000133a:	ec4e                	sd	s3,24(sp)
    8000133c:	e852                	sd	s4,16(sp)
    8000133e:	e456                	sd	s5,8(sp)
    80001340:	0080                	addi	s0,sp,64
    80001342:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001344:	00007497          	auipc	s1,0x7
    80001348:	a1c48493          	addi	s1,s1,-1508 # 80007d60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000134c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000134e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001350:	00011917          	auipc	s2,0x11
    80001354:	21090913          	addi	s2,s2,528 # 80012560 <tickslock>
    80001358:	a811                	j	8000136c <wakeup+0x3c>
        p->state = RUNNABLE;
    8000135a:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    8000135e:	8526                	mv	a0,s1
    80001360:	396040ef          	jal	ra,800056f6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001364:	2a048493          	addi	s1,s1,672
    80001368:	03248063          	beq	s1,s2,80001388 <wakeup+0x58>
    if(p != myproc()){
    8000136c:	9a5ff0ef          	jal	ra,80000d10 <myproc>
    80001370:	fea48ae3          	beq	s1,a0,80001364 <wakeup+0x34>
      acquire(&p->lock);
    80001374:	8526                	mv	a0,s1
    80001376:	2e8040ef          	jal	ra,8000565e <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000137a:	4c9c                	lw	a5,24(s1)
    8000137c:	ff3791e3          	bne	a5,s3,8000135e <wakeup+0x2e>
    80001380:	709c                	ld	a5,32(s1)
    80001382:	fd479ee3          	bne	a5,s4,8000135e <wakeup+0x2e>
    80001386:	bfd1                	j	8000135a <wakeup+0x2a>
    }
  }
}
    80001388:	70e2                	ld	ra,56(sp)
    8000138a:	7442                	ld	s0,48(sp)
    8000138c:	74a2                	ld	s1,40(sp)
    8000138e:	7902                	ld	s2,32(sp)
    80001390:	69e2                	ld	s3,24(sp)
    80001392:	6a42                	ld	s4,16(sp)
    80001394:	6aa2                	ld	s5,8(sp)
    80001396:	6121                	addi	sp,sp,64
    80001398:	8082                	ret

000000008000139a <reparent>:
{
    8000139a:	7179                	addi	sp,sp,-48
    8000139c:	f406                	sd	ra,40(sp)
    8000139e:	f022                	sd	s0,32(sp)
    800013a0:	ec26                	sd	s1,24(sp)
    800013a2:	e84a                	sd	s2,16(sp)
    800013a4:	e44e                	sd	s3,8(sp)
    800013a6:	e052                	sd	s4,0(sp)
    800013a8:	1800                	addi	s0,sp,48
    800013aa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013ac:	00007497          	auipc	s1,0x7
    800013b0:	9b448493          	addi	s1,s1,-1612 # 80007d60 <proc>
      pp->parent = initproc;
    800013b4:	00006a17          	auipc	s4,0x6
    800013b8:	53ca0a13          	addi	s4,s4,1340 # 800078f0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013bc:	00011997          	auipc	s3,0x11
    800013c0:	1a498993          	addi	s3,s3,420 # 80012560 <tickslock>
    800013c4:	a029                	j	800013ce <reparent+0x34>
    800013c6:	2a048493          	addi	s1,s1,672
    800013ca:	01348b63          	beq	s1,s3,800013e0 <reparent+0x46>
    if(pp->parent == p){
    800013ce:	7c9c                	ld	a5,56(s1)
    800013d0:	ff279be3          	bne	a5,s2,800013c6 <reparent+0x2c>
      pp->parent = initproc;
    800013d4:	000a3503          	ld	a0,0(s4)
    800013d8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800013da:	f57ff0ef          	jal	ra,80001330 <wakeup>
    800013de:	b7e5                	j	800013c6 <reparent+0x2c>
}
    800013e0:	70a2                	ld	ra,40(sp)
    800013e2:	7402                	ld	s0,32(sp)
    800013e4:	64e2                	ld	s1,24(sp)
    800013e6:	6942                	ld	s2,16(sp)
    800013e8:	69a2                	ld	s3,8(sp)
    800013ea:	6a02                	ld	s4,0(sp)
    800013ec:	6145                	addi	sp,sp,48
    800013ee:	8082                	ret

00000000800013f0 <exit>:
{
    800013f0:	7179                	addi	sp,sp,-48
    800013f2:	f406                	sd	ra,40(sp)
    800013f4:	f022                	sd	s0,32(sp)
    800013f6:	ec26                	sd	s1,24(sp)
    800013f8:	e84a                	sd	s2,16(sp)
    800013fa:	e44e                	sd	s3,8(sp)
    800013fc:	e052                	sd	s4,0(sp)
    800013fe:	1800                	addi	s0,sp,48
    80001400:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001402:	90fff0ef          	jal	ra,80000d10 <myproc>
    80001406:	89aa                	mv	s3,a0
  if(p == initproc)
    80001408:	00006797          	auipc	a5,0x6
    8000140c:	4e87b783          	ld	a5,1256(a5) # 800078f0 <initproc>
    80001410:	0d050493          	addi	s1,a0,208
    80001414:	15050913          	addi	s2,a0,336
    80001418:	00a79f63          	bne	a5,a0,80001436 <exit+0x46>
    panic("init exiting");
    8000141c:	00006517          	auipc	a0,0x6
    80001420:	e0450513          	addi	a0,a0,-508 # 80007220 <etext+0x220>
    80001424:	71f030ef          	jal	ra,80005342 <panic>
      fileclose(f);
    80001428:	6fd010ef          	jal	ra,80003324 <fileclose>
      p->ofile[fd] = 0;
    8000142c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001430:	04a1                	addi	s1,s1,8
    80001432:	01248563          	beq	s1,s2,8000143c <exit+0x4c>
    if(p->ofile[fd]){
    80001436:	6088                	ld	a0,0(s1)
    80001438:	f965                	bnez	a0,80001428 <exit+0x38>
    8000143a:	bfdd                	j	80001430 <exit+0x40>
  begin_op();
    8000143c:	2cd010ef          	jal	ra,80002f08 <begin_op>
  iput(p->cwd);
    80001440:	1509b503          	ld	a0,336(s3)
    80001444:	3b8010ef          	jal	ra,800027fc <iput>
  end_op();
    80001448:	331010ef          	jal	ra,80002f78 <end_op>
  p->cwd = 0;
    8000144c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80001450:	00006497          	auipc	s1,0x6
    80001454:	4f848493          	addi	s1,s1,1272 # 80007948 <wait_lock>
    80001458:	8526                	mv	a0,s1
    8000145a:	204040ef          	jal	ra,8000565e <acquire>
  reparent(p);
    8000145e:	854e                	mv	a0,s3
    80001460:	f3bff0ef          	jal	ra,8000139a <reparent>
  wakeup(p->parent);
    80001464:	0389b503          	ld	a0,56(s3)
    80001468:	ec9ff0ef          	jal	ra,80001330 <wakeup>
  acquire(&p->lock);
    8000146c:	854e                	mv	a0,s3
    8000146e:	1f0040ef          	jal	ra,8000565e <acquire>
  p->xstate = status;
    80001472:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001476:	4795                	li	a5,5
    80001478:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000147c:	8526                	mv	a0,s1
    8000147e:	278040ef          	jal	ra,800056f6 <release>
  sched();
    80001482:	d7dff0ef          	jal	ra,800011fe <sched>
  panic("zombie exit");
    80001486:	00006517          	auipc	a0,0x6
    8000148a:	daa50513          	addi	a0,a0,-598 # 80007230 <etext+0x230>
    8000148e:	6b5030ef          	jal	ra,80005342 <panic>

0000000080001492 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001492:	7179                	addi	sp,sp,-48
    80001494:	f406                	sd	ra,40(sp)
    80001496:	f022                	sd	s0,32(sp)
    80001498:	ec26                	sd	s1,24(sp)
    8000149a:	e84a                	sd	s2,16(sp)
    8000149c:	e44e                	sd	s3,8(sp)
    8000149e:	1800                	addi	s0,sp,48
    800014a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800014a2:	00007497          	auipc	s1,0x7
    800014a6:	8be48493          	addi	s1,s1,-1858 # 80007d60 <proc>
    800014aa:	00011997          	auipc	s3,0x11
    800014ae:	0b698993          	addi	s3,s3,182 # 80012560 <tickslock>
    acquire(&p->lock);
    800014b2:	8526                	mv	a0,s1
    800014b4:	1aa040ef          	jal	ra,8000565e <acquire>
    if(p->pid == pid){
    800014b8:	589c                	lw	a5,48(s1)
    800014ba:	01278b63          	beq	a5,s2,800014d0 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800014be:	8526                	mv	a0,s1
    800014c0:	236040ef          	jal	ra,800056f6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800014c4:	2a048493          	addi	s1,s1,672
    800014c8:	ff3495e3          	bne	s1,s3,800014b2 <kill+0x20>
  }
  return -1;
    800014cc:	557d                	li	a0,-1
    800014ce:	a819                	j	800014e4 <kill+0x52>
      p->killed = 1;
    800014d0:	4785                	li	a5,1
    800014d2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800014d4:	4c98                	lw	a4,24(s1)
    800014d6:	4789                	li	a5,2
    800014d8:	00f70d63          	beq	a4,a5,800014f2 <kill+0x60>
      release(&p->lock);
    800014dc:	8526                	mv	a0,s1
    800014de:	218040ef          	jal	ra,800056f6 <release>
      return 0;
    800014e2:	4501                	li	a0,0
}
    800014e4:	70a2                	ld	ra,40(sp)
    800014e6:	7402                	ld	s0,32(sp)
    800014e8:	64e2                	ld	s1,24(sp)
    800014ea:	6942                	ld	s2,16(sp)
    800014ec:	69a2                	ld	s3,8(sp)
    800014ee:	6145                	addi	sp,sp,48
    800014f0:	8082                	ret
        p->state = RUNNABLE;
    800014f2:	478d                	li	a5,3
    800014f4:	cc9c                	sw	a5,24(s1)
    800014f6:	b7dd                	j	800014dc <kill+0x4a>

00000000800014f8 <setkilled>:

void
setkilled(struct proc *p)
{
    800014f8:	1101                	addi	sp,sp,-32
    800014fa:	ec06                	sd	ra,24(sp)
    800014fc:	e822                	sd	s0,16(sp)
    800014fe:	e426                	sd	s1,8(sp)
    80001500:	1000                	addi	s0,sp,32
    80001502:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001504:	15a040ef          	jal	ra,8000565e <acquire>
  p->killed = 1;
    80001508:	4785                	li	a5,1
    8000150a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000150c:	8526                	mv	a0,s1
    8000150e:	1e8040ef          	jal	ra,800056f6 <release>
}
    80001512:	60e2                	ld	ra,24(sp)
    80001514:	6442                	ld	s0,16(sp)
    80001516:	64a2                	ld	s1,8(sp)
    80001518:	6105                	addi	sp,sp,32
    8000151a:	8082                	ret

000000008000151c <killed>:

int
killed(struct proc *p)
{
    8000151c:	1101                	addi	sp,sp,-32
    8000151e:	ec06                	sd	ra,24(sp)
    80001520:	e822                	sd	s0,16(sp)
    80001522:	e426                	sd	s1,8(sp)
    80001524:	e04a                	sd	s2,0(sp)
    80001526:	1000                	addi	s0,sp,32
    80001528:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000152a:	134040ef          	jal	ra,8000565e <acquire>
  k = p->killed;
    8000152e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001532:	8526                	mv	a0,s1
    80001534:	1c2040ef          	jal	ra,800056f6 <release>
  return k;
}
    80001538:	854a                	mv	a0,s2
    8000153a:	60e2                	ld	ra,24(sp)
    8000153c:	6442                	ld	s0,16(sp)
    8000153e:	64a2                	ld	s1,8(sp)
    80001540:	6902                	ld	s2,0(sp)
    80001542:	6105                	addi	sp,sp,32
    80001544:	8082                	ret

0000000080001546 <wait>:
{
    80001546:	715d                	addi	sp,sp,-80
    80001548:	e486                	sd	ra,72(sp)
    8000154a:	e0a2                	sd	s0,64(sp)
    8000154c:	fc26                	sd	s1,56(sp)
    8000154e:	f84a                	sd	s2,48(sp)
    80001550:	f44e                	sd	s3,40(sp)
    80001552:	f052                	sd	s4,32(sp)
    80001554:	ec56                	sd	s5,24(sp)
    80001556:	e85a                	sd	s6,16(sp)
    80001558:	e45e                	sd	s7,8(sp)
    8000155a:	e062                	sd	s8,0(sp)
    8000155c:	0880                	addi	s0,sp,80
    8000155e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001560:	fb0ff0ef          	jal	ra,80000d10 <myproc>
    80001564:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001566:	00006517          	auipc	a0,0x6
    8000156a:	3e250513          	addi	a0,a0,994 # 80007948 <wait_lock>
    8000156e:	0f0040ef          	jal	ra,8000565e <acquire>
    havekids = 0;
    80001572:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001574:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001576:	00011997          	auipc	s3,0x11
    8000157a:	fea98993          	addi	s3,s3,-22 # 80012560 <tickslock>
        havekids = 1;
    8000157e:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001580:	00006c17          	auipc	s8,0x6
    80001584:	3c8c0c13          	addi	s8,s8,968 # 80007948 <wait_lock>
    havekids = 0;
    80001588:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000158a:	00006497          	auipc	s1,0x6
    8000158e:	7d648493          	addi	s1,s1,2006 # 80007d60 <proc>
    80001592:	a899                	j	800015e8 <wait+0xa2>
          pid = pp->pid;
    80001594:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001598:	000b0c63          	beqz	s6,800015b0 <wait+0x6a>
    8000159c:	4691                	li	a3,4
    8000159e:	02c48613          	addi	a2,s1,44
    800015a2:	85da                	mv	a1,s6
    800015a4:	05093503          	ld	a0,80(s2)
    800015a8:	c1eff0ef          	jal	ra,800009c6 <copyout>
    800015ac:	00054f63          	bltz	a0,800015ca <wait+0x84>
          freeproc(pp);
    800015b0:	8526                	mv	a0,s1
    800015b2:	8d1ff0ef          	jal	ra,80000e82 <freeproc>
          release(&pp->lock);
    800015b6:	8526                	mv	a0,s1
    800015b8:	13e040ef          	jal	ra,800056f6 <release>
          release(&wait_lock);
    800015bc:	00006517          	auipc	a0,0x6
    800015c0:	38c50513          	addi	a0,a0,908 # 80007948 <wait_lock>
    800015c4:	132040ef          	jal	ra,800056f6 <release>
          return pid;
    800015c8:	a891                	j	8000161c <wait+0xd6>
            release(&pp->lock);
    800015ca:	8526                	mv	a0,s1
    800015cc:	12a040ef          	jal	ra,800056f6 <release>
            release(&wait_lock);
    800015d0:	00006517          	auipc	a0,0x6
    800015d4:	37850513          	addi	a0,a0,888 # 80007948 <wait_lock>
    800015d8:	11e040ef          	jal	ra,800056f6 <release>
            return -1;
    800015dc:	59fd                	li	s3,-1
    800015de:	a83d                	j	8000161c <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800015e0:	2a048493          	addi	s1,s1,672
    800015e4:	03348063          	beq	s1,s3,80001604 <wait+0xbe>
      if(pp->parent == p){
    800015e8:	7c9c                	ld	a5,56(s1)
    800015ea:	ff279be3          	bne	a5,s2,800015e0 <wait+0x9a>
        acquire(&pp->lock);
    800015ee:	8526                	mv	a0,s1
    800015f0:	06e040ef          	jal	ra,8000565e <acquire>
        if(pp->state == ZOMBIE){
    800015f4:	4c9c                	lw	a5,24(s1)
    800015f6:	f9478fe3          	beq	a5,s4,80001594 <wait+0x4e>
        release(&pp->lock);
    800015fa:	8526                	mv	a0,s1
    800015fc:	0fa040ef          	jal	ra,800056f6 <release>
        havekids = 1;
    80001600:	8756                	mv	a4,s5
    80001602:	bff9                	j	800015e0 <wait+0x9a>
    if(!havekids || killed(p)){
    80001604:	c709                	beqz	a4,8000160e <wait+0xc8>
    80001606:	854a                	mv	a0,s2
    80001608:	f15ff0ef          	jal	ra,8000151c <killed>
    8000160c:	c50d                	beqz	a0,80001636 <wait+0xf0>
      release(&wait_lock);
    8000160e:	00006517          	auipc	a0,0x6
    80001612:	33a50513          	addi	a0,a0,826 # 80007948 <wait_lock>
    80001616:	0e0040ef          	jal	ra,800056f6 <release>
      return -1;
    8000161a:	59fd                	li	s3,-1
}
    8000161c:	854e                	mv	a0,s3
    8000161e:	60a6                	ld	ra,72(sp)
    80001620:	6406                	ld	s0,64(sp)
    80001622:	74e2                	ld	s1,56(sp)
    80001624:	7942                	ld	s2,48(sp)
    80001626:	79a2                	ld	s3,40(sp)
    80001628:	7a02                	ld	s4,32(sp)
    8000162a:	6ae2                	ld	s5,24(sp)
    8000162c:	6b42                	ld	s6,16(sp)
    8000162e:	6ba2                	ld	s7,8(sp)
    80001630:	6c02                	ld	s8,0(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001636:	85e2                	mv	a1,s8
    80001638:	854a                	mv	a0,s2
    8000163a:	cabff0ef          	jal	ra,800012e4 <sleep>
    havekids = 0;
    8000163e:	b7a9                	j	80001588 <wait+0x42>

0000000080001640 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001640:	7179                	addi	sp,sp,-48
    80001642:	f406                	sd	ra,40(sp)
    80001644:	f022                	sd	s0,32(sp)
    80001646:	ec26                	sd	s1,24(sp)
    80001648:	e84a                	sd	s2,16(sp)
    8000164a:	e44e                	sd	s3,8(sp)
    8000164c:	e052                	sd	s4,0(sp)
    8000164e:	1800                	addi	s0,sp,48
    80001650:	84aa                	mv	s1,a0
    80001652:	892e                	mv	s2,a1
    80001654:	89b2                	mv	s3,a2
    80001656:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001658:	eb8ff0ef          	jal	ra,80000d10 <myproc>
  if(user_dst){
    8000165c:	cc99                	beqz	s1,8000167a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000165e:	86d2                	mv	a3,s4
    80001660:	864e                	mv	a2,s3
    80001662:	85ca                	mv	a1,s2
    80001664:	6928                	ld	a0,80(a0)
    80001666:	b60ff0ef          	jal	ra,800009c6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000166a:	70a2                	ld	ra,40(sp)
    8000166c:	7402                	ld	s0,32(sp)
    8000166e:	64e2                	ld	s1,24(sp)
    80001670:	6942                	ld	s2,16(sp)
    80001672:	69a2                	ld	s3,8(sp)
    80001674:	6a02                	ld	s4,0(sp)
    80001676:	6145                	addi	sp,sp,48
    80001678:	8082                	ret
    memmove((char *)dst, src, len);
    8000167a:	000a061b          	sext.w	a2,s4
    8000167e:	85ce                	mv	a1,s3
    80001680:	854a                	mv	a0,s2
    80001682:	b2bfe0ef          	jal	ra,800001ac <memmove>
    return 0;
    80001686:	8526                	mv	a0,s1
    80001688:	b7cd                	j	8000166a <either_copyout+0x2a>

000000008000168a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000168a:	7179                	addi	sp,sp,-48
    8000168c:	f406                	sd	ra,40(sp)
    8000168e:	f022                	sd	s0,32(sp)
    80001690:	ec26                	sd	s1,24(sp)
    80001692:	e84a                	sd	s2,16(sp)
    80001694:	e44e                	sd	s3,8(sp)
    80001696:	e052                	sd	s4,0(sp)
    80001698:	1800                	addi	s0,sp,48
    8000169a:	892a                	mv	s2,a0
    8000169c:	84ae                	mv	s1,a1
    8000169e:	89b2                	mv	s3,a2
    800016a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016a2:	e6eff0ef          	jal	ra,80000d10 <myproc>
  if(user_src){
    800016a6:	cc99                	beqz	s1,800016c4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800016a8:	86d2                	mv	a3,s4
    800016aa:	864e                	mv	a2,s3
    800016ac:	85ca                	mv	a1,s2
    800016ae:	6928                	ld	a0,80(a0)
    800016b0:	bceff0ef          	jal	ra,80000a7e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800016b4:	70a2                	ld	ra,40(sp)
    800016b6:	7402                	ld	s0,32(sp)
    800016b8:	64e2                	ld	s1,24(sp)
    800016ba:	6942                	ld	s2,16(sp)
    800016bc:	69a2                	ld	s3,8(sp)
    800016be:	6a02                	ld	s4,0(sp)
    800016c0:	6145                	addi	sp,sp,48
    800016c2:	8082                	ret
    memmove(dst, (char*)src, len);
    800016c4:	000a061b          	sext.w	a2,s4
    800016c8:	85ce                	mv	a1,s3
    800016ca:	854a                	mv	a0,s2
    800016cc:	ae1fe0ef          	jal	ra,800001ac <memmove>
    return 0;
    800016d0:	8526                	mv	a0,s1
    800016d2:	b7cd                	j	800016b4 <either_copyin+0x2a>

00000000800016d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800016d4:	715d                	addi	sp,sp,-80
    800016d6:	e486                	sd	ra,72(sp)
    800016d8:	e0a2                	sd	s0,64(sp)
    800016da:	fc26                	sd	s1,56(sp)
    800016dc:	f84a                	sd	s2,48(sp)
    800016de:	f44e                	sd	s3,40(sp)
    800016e0:	f052                	sd	s4,32(sp)
    800016e2:	ec56                	sd	s5,24(sp)
    800016e4:	e85a                	sd	s6,16(sp)
    800016e6:	e45e                	sd	s7,8(sp)
    800016e8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800016ea:	00006517          	auipc	a0,0x6
    800016ee:	95e50513          	addi	a0,a0,-1698 # 80007048 <etext+0x48>
    800016f2:	19d030ef          	jal	ra,8000508e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800016f6:	00006497          	auipc	s1,0x6
    800016fa:	7c248493          	addi	s1,s1,1986 # 80007eb8 <proc+0x158>
    800016fe:	00011917          	auipc	s2,0x11
    80001702:	fba90913          	addi	s2,s2,-70 # 800126b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001706:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001708:	00006997          	auipc	s3,0x6
    8000170c:	b3898993          	addi	s3,s3,-1224 # 80007240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80001710:	00006a97          	auipc	s5,0x6
    80001714:	b38a8a93          	addi	s5,s5,-1224 # 80007248 <etext+0x248>
    printf("\n");
    80001718:	00006a17          	auipc	s4,0x6
    8000171c:	930a0a13          	addi	s4,s4,-1744 # 80007048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001720:	00006b97          	auipc	s7,0x6
    80001724:	b68b8b93          	addi	s7,s7,-1176 # 80007288 <states.2240>
    80001728:	a829                	j	80001742 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000172a:	ed86a583          	lw	a1,-296(a3)
    8000172e:	8556                	mv	a0,s5
    80001730:	15f030ef          	jal	ra,8000508e <printf>
    printf("\n");
    80001734:	8552                	mv	a0,s4
    80001736:	159030ef          	jal	ra,8000508e <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000173a:	2a048493          	addi	s1,s1,672
    8000173e:	03248163          	beq	s1,s2,80001760 <procdump+0x8c>
    if(p->state == UNUSED)
    80001742:	86a6                	mv	a3,s1
    80001744:	ec04a783          	lw	a5,-320(s1)
    80001748:	dbed                	beqz	a5,8000173a <procdump+0x66>
      state = "???";
    8000174a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000174c:	fcfb6fe3          	bltu	s6,a5,8000172a <procdump+0x56>
    80001750:	1782                	slli	a5,a5,0x20
    80001752:	9381                	srli	a5,a5,0x20
    80001754:	078e                	slli	a5,a5,0x3
    80001756:	97de                	add	a5,a5,s7
    80001758:	6390                	ld	a2,0(a5)
    8000175a:	fa61                	bnez	a2,8000172a <procdump+0x56>
      state = "???";
    8000175c:	864e                	mv	a2,s3
    8000175e:	b7f1                	j	8000172a <procdump+0x56>
  }
}
    80001760:	60a6                	ld	ra,72(sp)
    80001762:	6406                	ld	s0,64(sp)
    80001764:	74e2                	ld	s1,56(sp)
    80001766:	7942                	ld	s2,48(sp)
    80001768:	79a2                	ld	s3,40(sp)
    8000176a:	7a02                	ld	s4,32(sp)
    8000176c:	6ae2                	ld	s5,24(sp)
    8000176e:	6b42                	ld	s6,16(sp)
    80001770:	6ba2                	ld	s7,8(sp)
    80001772:	6161                	addi	sp,sp,80
    80001774:	8082                	ret

0000000080001776 <swtch>:
    80001776:	00153023          	sd	ra,0(a0)
    8000177a:	00253423          	sd	sp,8(a0)
    8000177e:	e900                	sd	s0,16(a0)
    80001780:	ed04                	sd	s1,24(a0)
    80001782:	03253023          	sd	s2,32(a0)
    80001786:	03353423          	sd	s3,40(a0)
    8000178a:	03453823          	sd	s4,48(a0)
    8000178e:	03553c23          	sd	s5,56(a0)
    80001792:	05653023          	sd	s6,64(a0)
    80001796:	05753423          	sd	s7,72(a0)
    8000179a:	05853823          	sd	s8,80(a0)
    8000179e:	05953c23          	sd	s9,88(a0)
    800017a2:	07a53023          	sd	s10,96(a0)
    800017a6:	07b53423          	sd	s11,104(a0)
    800017aa:	0005b083          	ld	ra,0(a1)
    800017ae:	0085b103          	ld	sp,8(a1)
    800017b2:	6980                	ld	s0,16(a1)
    800017b4:	6d84                	ld	s1,24(a1)
    800017b6:	0205b903          	ld	s2,32(a1)
    800017ba:	0285b983          	ld	s3,40(a1)
    800017be:	0305ba03          	ld	s4,48(a1)
    800017c2:	0385ba83          	ld	s5,56(a1)
    800017c6:	0405bb03          	ld	s6,64(a1)
    800017ca:	0485bb83          	ld	s7,72(a1)
    800017ce:	0505bc03          	ld	s8,80(a1)
    800017d2:	0585bc83          	ld	s9,88(a1)
    800017d6:	0605bd03          	ld	s10,96(a1)
    800017da:	0685bd83          	ld	s11,104(a1)
    800017de:	8082                	ret

00000000800017e0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800017e0:	1141                	addi	sp,sp,-16
    800017e2:	e406                	sd	ra,8(sp)
    800017e4:	e022                	sd	s0,0(sp)
    800017e6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800017e8:	00006597          	auipc	a1,0x6
    800017ec:	ad058593          	addi	a1,a1,-1328 # 800072b8 <states.2240+0x30>
    800017f0:	00011517          	auipc	a0,0x11
    800017f4:	d7050513          	addi	a0,a0,-656 # 80012560 <tickslock>
    800017f8:	5e7030ef          	jal	ra,800055de <initlock>
}
    800017fc:	60a2                	ld	ra,8(sp)
    800017fe:	6402                	ld	s0,0(sp)
    80001800:	0141                	addi	sp,sp,16
    80001802:	8082                	ret

0000000080001804 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001804:	1141                	addi	sp,sp,-16
    80001806:	e422                	sd	s0,8(sp)
    80001808:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000180a:	00003797          	auipc	a5,0x3
    8000180e:	dc678793          	addi	a5,a5,-570 # 800045d0 <kernelvec>
    80001812:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001816:	6422                	ld	s0,8(sp)
    80001818:	0141                	addi	sp,sp,16
    8000181a:	8082                	ret

000000008000181c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000181c:	1141                	addi	sp,sp,-16
    8000181e:	e406                	sd	ra,8(sp)
    80001820:	e022                	sd	s0,0(sp)
    80001822:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001824:	cecff0ef          	jal	ra,80000d10 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001828:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000182c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000182e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001832:	00004617          	auipc	a2,0x4
    80001836:	7ce60613          	addi	a2,a2,1998 # 80006000 <_trampoline>
    8000183a:	00004697          	auipc	a3,0x4
    8000183e:	7c668693          	addi	a3,a3,1990 # 80006000 <_trampoline>
    80001842:	8e91                	sub	a3,a3,a2
    80001844:	040007b7          	lui	a5,0x4000
    80001848:	17fd                	addi	a5,a5,-1
    8000184a:	07b2                	slli	a5,a5,0xc
    8000184c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000184e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001852:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001854:	180026f3          	csrr	a3,satp
    80001858:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000185a:	6d38                	ld	a4,88(a0)
    8000185c:	6134                	ld	a3,64(a0)
    8000185e:	6585                	lui	a1,0x1
    80001860:	96ae                	add	a3,a3,a1
    80001862:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001864:	6d38                	ld	a4,88(a0)
    80001866:	00000697          	auipc	a3,0x0
    8000186a:	10c68693          	addi	a3,a3,268 # 80001972 <usertrap>
    8000186e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001870:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001872:	8692                	mv	a3,tp
    80001874:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001876:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000187a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000187e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001882:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001886:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001888:	6f18                	ld	a4,24(a4)
    8000188a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000188e:	6928                	ld	a0,80(a0)
    80001890:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001892:	00005717          	auipc	a4,0x5
    80001896:	80a70713          	addi	a4,a4,-2038 # 8000609c <userret>
    8000189a:	8f11                	sub	a4,a4,a2
    8000189c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000189e:	577d                	li	a4,-1
    800018a0:	177e                	slli	a4,a4,0x3f
    800018a2:	8d59                	or	a0,a0,a4
    800018a4:	9782                	jalr	a5
}
    800018a6:	60a2                	ld	ra,8(sp)
    800018a8:	6402                	ld	s0,0(sp)
    800018aa:	0141                	addi	sp,sp,16
    800018ac:	8082                	ret

00000000800018ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800018ae:	1101                	addi	sp,sp,-32
    800018b0:	ec06                	sd	ra,24(sp)
    800018b2:	e822                	sd	s0,16(sp)
    800018b4:	e426                	sd	s1,8(sp)
    800018b6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800018b8:	c2cff0ef          	jal	ra,80000ce4 <cpuid>
    800018bc:	cd19                	beqz	a0,800018da <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800018be:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800018c2:	000f4737          	lui	a4,0xf4
    800018c6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800018ca:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800018cc:	14d79073          	csrw	0x14d,a5
}
    800018d0:	60e2                	ld	ra,24(sp)
    800018d2:	6442                	ld	s0,16(sp)
    800018d4:	64a2                	ld	s1,8(sp)
    800018d6:	6105                	addi	sp,sp,32
    800018d8:	8082                	ret
    acquire(&tickslock);
    800018da:	00011497          	auipc	s1,0x11
    800018de:	c8648493          	addi	s1,s1,-890 # 80012560 <tickslock>
    800018e2:	8526                	mv	a0,s1
    800018e4:	57b030ef          	jal	ra,8000565e <acquire>
    ticks++;
    800018e8:	00006517          	auipc	a0,0x6
    800018ec:	01050513          	addi	a0,a0,16 # 800078f8 <ticks>
    800018f0:	411c                	lw	a5,0(a0)
    800018f2:	2785                	addiw	a5,a5,1
    800018f4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800018f6:	a3bff0ef          	jal	ra,80001330 <wakeup>
    release(&tickslock);
    800018fa:	8526                	mv	a0,s1
    800018fc:	5fb030ef          	jal	ra,800056f6 <release>
    80001900:	bf7d                	j	800018be <clockintr+0x10>

0000000080001902 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000190c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001910:	57fd                	li	a5,-1
    80001912:	17fe                	slli	a5,a5,0x3f
    80001914:	07a5                	addi	a5,a5,9
    80001916:	00f70d63          	beq	a4,a5,80001930 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000191a:	57fd                	li	a5,-1
    8000191c:	17fe                	slli	a5,a5,0x3f
    8000191e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001920:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001922:	04f70463          	beq	a4,a5,8000196a <devintr+0x68>
  }
}
    80001926:	60e2                	ld	ra,24(sp)
    80001928:	6442                	ld	s0,16(sp)
    8000192a:	64a2                	ld	s1,8(sp)
    8000192c:	6105                	addi	sp,sp,32
    8000192e:	8082                	ret
    int irq = plic_claim();
    80001930:	549020ef          	jal	ra,80004678 <plic_claim>
    80001934:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001936:	47a9                	li	a5,10
    80001938:	02f50363          	beq	a0,a5,8000195e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000193c:	4785                	li	a5,1
    8000193e:	02f50363          	beq	a0,a5,80001964 <devintr+0x62>
    return 1;
    80001942:	4505                	li	a0,1
    } else if(irq){
    80001944:	d0ed                	beqz	s1,80001926 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001946:	85a6                	mv	a1,s1
    80001948:	00006517          	auipc	a0,0x6
    8000194c:	97850513          	addi	a0,a0,-1672 # 800072c0 <states.2240+0x38>
    80001950:	73e030ef          	jal	ra,8000508e <printf>
      plic_complete(irq);
    80001954:	8526                	mv	a0,s1
    80001956:	543020ef          	jal	ra,80004698 <plic_complete>
    return 1;
    8000195a:	4505                	li	a0,1
    8000195c:	b7e9                	j	80001926 <devintr+0x24>
      uartintr();
    8000195e:	445030ef          	jal	ra,800055a2 <uartintr>
    80001962:	bfcd                	j	80001954 <devintr+0x52>
      virtio_disk_intr();
    80001964:	1fa030ef          	jal	ra,80004b5e <virtio_disk_intr>
    80001968:	b7f5                	j	80001954 <devintr+0x52>
    clockintr();
    8000196a:	f45ff0ef          	jal	ra,800018ae <clockintr>
    return 2;
    8000196e:	4509                	li	a0,2
    80001970:	bf5d                	j	80001926 <devintr+0x24>

0000000080001972 <usertrap>:
{
    80001972:	1101                	addi	sp,sp,-32
    80001974:	ec06                	sd	ra,24(sp)
    80001976:	e822                	sd	s0,16(sp)
    80001978:	e426                	sd	s1,8(sp)
    8000197a:	e04a                	sd	s2,0(sp)
    8000197c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000197e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001982:	1007f793          	andi	a5,a5,256
    80001986:	ef85                	bnez	a5,800019be <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001988:	00003797          	auipc	a5,0x3
    8000198c:	c4878793          	addi	a5,a5,-952 # 800045d0 <kernelvec>
    80001990:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001994:	b7cff0ef          	jal	ra,80000d10 <myproc>
    80001998:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000199a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000199c:	14102773          	csrr	a4,sepc
    800019a0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019a2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800019a6:	47a1                	li	a5,8
    800019a8:	02f70163          	beq	a4,a5,800019ca <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800019ac:	f57ff0ef          	jal	ra,80001902 <devintr>
    800019b0:	892a                	mv	s2,a0
    800019b2:	c939                	beqz	a0,80001a08 <usertrap+0x96>
  if(killed(p))
    800019b4:	8526                	mv	a0,s1
    800019b6:	b67ff0ef          	jal	ra,8000151c <killed>
    800019ba:	c151                	beqz	a0,80001a3e <usertrap+0xcc>
    800019bc:	a8b5                	j	80001a38 <usertrap+0xc6>
    panic("usertrap: not from user mode");
    800019be:	00006517          	auipc	a0,0x6
    800019c2:	92250513          	addi	a0,a0,-1758 # 800072e0 <states.2240+0x58>
    800019c6:	17d030ef          	jal	ra,80005342 <panic>
    if(killed(p))
    800019ca:	b53ff0ef          	jal	ra,8000151c <killed>
    800019ce:	e90d                	bnez	a0,80001a00 <usertrap+0x8e>
    p->trapframe->epc += 4;
    800019d0:	6cb8                	ld	a4,88(s1)
    800019d2:	6f1c                	ld	a5,24(a4)
    800019d4:	0791                	addi	a5,a5,4
    800019d6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800019d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800019dc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800019e0:	10079073          	csrw	sstatus,a5
    syscall();
    800019e4:	278000ef          	jal	ra,80001c5c <syscall>
  if(killed(p))
    800019e8:	8526                	mv	a0,s1
    800019ea:	b33ff0ef          	jal	ra,8000151c <killed>
    800019ee:	e521                	bnez	a0,80001a36 <usertrap+0xc4>
  usertrapret();
    800019f0:	e2dff0ef          	jal	ra,8000181c <usertrapret>
}
    800019f4:	60e2                	ld	ra,24(sp)
    800019f6:	6442                	ld	s0,16(sp)
    800019f8:	64a2                	ld	s1,8(sp)
    800019fa:	6902                	ld	s2,0(sp)
    800019fc:	6105                	addi	sp,sp,32
    800019fe:	8082                	ret
      exit(-1);
    80001a00:	557d                	li	a0,-1
    80001a02:	9efff0ef          	jal	ra,800013f0 <exit>
    80001a06:	b7e9                	j	800019d0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a08:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001a0c:	5890                	lw	a2,48(s1)
    80001a0e:	00006517          	auipc	a0,0x6
    80001a12:	8f250513          	addi	a0,a0,-1806 # 80007300 <states.2240+0x78>
    80001a16:	678030ef          	jal	ra,8000508e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a1a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001a1e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001a22:	00006517          	auipc	a0,0x6
    80001a26:	90e50513          	addi	a0,a0,-1778 # 80007330 <states.2240+0xa8>
    80001a2a:	664030ef          	jal	ra,8000508e <printf>
    setkilled(p);
    80001a2e:	8526                	mv	a0,s1
    80001a30:	ac9ff0ef          	jal	ra,800014f8 <setkilled>
    80001a34:	bf55                	j	800019e8 <usertrap+0x76>
  if(killed(p))
    80001a36:	4901                	li	s2,0
    exit(-1);
    80001a38:	557d                	li	a0,-1
    80001a3a:	9b7ff0ef          	jal	ra,800013f0 <exit>
  if (which_dev == 2) {
    80001a3e:	4789                	li	a5,2
    80001a40:	faf918e3          	bne	s2,a5,800019f0 <usertrap+0x7e>
    if (p->interval != 0) {
    80001a44:	1684a783          	lw	a5,360(s1)
    80001a48:	cb91                	beqz	a5,80001a5c <usertrap+0xea>
        p->passedticks++;
    80001a4a:	1784a703          	lw	a4,376(s1)
    80001a4e:	2705                	addiw	a4,a4,1
    80001a50:	0007069b          	sext.w	a3,a4
    80001a54:	16e4ac23          	sw	a4,376(s1)
        if (p->passedticks == p->interval) {
    80001a58:	00d78563          	beq	a5,a3,80001a62 <usertrap+0xf0>
    yield();
    80001a5c:	85dff0ef          	jal	ra,800012b8 <yield>
    80001a60:	bf41                	j	800019f0 <usertrap+0x7e>
            memmove(&p->saved_trapframe, p->trapframe, sizeof(struct trapframe));
    80001a62:	12000613          	li	a2,288
    80001a66:	6cac                	ld	a1,88(s1)
    80001a68:	18048513          	addi	a0,s1,384
    80001a6c:	f40fe0ef          	jal	ra,800001ac <memmove>
            p->trapframe->epc = p->handler;
    80001a70:	6cbc                	ld	a5,88(s1)
    80001a72:	1704b703          	ld	a4,368(s1)
    80001a76:	ef98                	sd	a4,24(a5)
    80001a78:	b7d5                	j	80001a5c <usertrap+0xea>

0000000080001a7a <kerneltrap>:
{
    80001a7a:	7179                	addi	sp,sp,-48
    80001a7c:	f406                	sd	ra,40(sp)
    80001a7e:	f022                	sd	s0,32(sp)
    80001a80:	ec26                	sd	s1,24(sp)
    80001a82:	e84a                	sd	s2,16(sp)
    80001a84:	e44e                	sd	s3,8(sp)
    80001a86:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a88:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a8c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a90:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001a94:	1004f793          	andi	a5,s1,256
    80001a98:	c795                	beqz	a5,80001ac4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a9a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001a9e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001aa0:	eb85                	bnez	a5,80001ad0 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001aa2:	e61ff0ef          	jal	ra,80001902 <devintr>
    80001aa6:	c91d                	beqz	a0,80001adc <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001aa8:	4789                	li	a5,2
    80001aaa:	04f50a63          	beq	a0,a5,80001afe <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001aae:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ab2:	10049073          	csrw	sstatus,s1
}
    80001ab6:	70a2                	ld	ra,40(sp)
    80001ab8:	7402                	ld	s0,32(sp)
    80001aba:	64e2                	ld	s1,24(sp)
    80001abc:	6942                	ld	s2,16(sp)
    80001abe:	69a2                	ld	s3,8(sp)
    80001ac0:	6145                	addi	sp,sp,48
    80001ac2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001ac4:	00006517          	auipc	a0,0x6
    80001ac8:	89450513          	addi	a0,a0,-1900 # 80007358 <states.2240+0xd0>
    80001acc:	077030ef          	jal	ra,80005342 <panic>
    panic("kerneltrap: interrupts enabled");
    80001ad0:	00006517          	auipc	a0,0x6
    80001ad4:	8b050513          	addi	a0,a0,-1872 # 80007380 <states.2240+0xf8>
    80001ad8:	06b030ef          	jal	ra,80005342 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001adc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001ae0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001ae4:	85ce                	mv	a1,s3
    80001ae6:	00006517          	auipc	a0,0x6
    80001aea:	8ba50513          	addi	a0,a0,-1862 # 800073a0 <states.2240+0x118>
    80001aee:	5a0030ef          	jal	ra,8000508e <printf>
    panic("kerneltrap");
    80001af2:	00006517          	auipc	a0,0x6
    80001af6:	8d650513          	addi	a0,a0,-1834 # 800073c8 <states.2240+0x140>
    80001afa:	049030ef          	jal	ra,80005342 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001afe:	a12ff0ef          	jal	ra,80000d10 <myproc>
    80001b02:	d555                	beqz	a0,80001aae <kerneltrap+0x34>
    yield();
    80001b04:	fb4ff0ef          	jal	ra,800012b8 <yield>
    80001b08:	b75d                	j	80001aae <kerneltrap+0x34>

0000000080001b0a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	1000                	addi	s0,sp,32
    80001b14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b16:	9faff0ef          	jal	ra,80000d10 <myproc>
  switch (n) {
    80001b1a:	4795                	li	a5,5
    80001b1c:	0497e163          	bltu	a5,s1,80001b5e <argraw+0x54>
    80001b20:	048a                	slli	s1,s1,0x2
    80001b22:	00006717          	auipc	a4,0x6
    80001b26:	8de70713          	addi	a4,a4,-1826 # 80007400 <states.2240+0x178>
    80001b2a:	94ba                	add	s1,s1,a4
    80001b2c:	409c                	lw	a5,0(s1)
    80001b2e:	97ba                	add	a5,a5,a4
    80001b30:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001b32:	6d3c                	ld	a5,88(a0)
    80001b34:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001b36:	60e2                	ld	ra,24(sp)
    80001b38:	6442                	ld	s0,16(sp)
    80001b3a:	64a2                	ld	s1,8(sp)
    80001b3c:	6105                	addi	sp,sp,32
    80001b3e:	8082                	ret
    return p->trapframe->a1;
    80001b40:	6d3c                	ld	a5,88(a0)
    80001b42:	7fa8                	ld	a0,120(a5)
    80001b44:	bfcd                	j	80001b36 <argraw+0x2c>
    return p->trapframe->a2;
    80001b46:	6d3c                	ld	a5,88(a0)
    80001b48:	63c8                	ld	a0,128(a5)
    80001b4a:	b7f5                	j	80001b36 <argraw+0x2c>
    return p->trapframe->a3;
    80001b4c:	6d3c                	ld	a5,88(a0)
    80001b4e:	67c8                	ld	a0,136(a5)
    80001b50:	b7dd                	j	80001b36 <argraw+0x2c>
    return p->trapframe->a4;
    80001b52:	6d3c                	ld	a5,88(a0)
    80001b54:	6bc8                	ld	a0,144(a5)
    80001b56:	b7c5                	j	80001b36 <argraw+0x2c>
    return p->trapframe->a5;
    80001b58:	6d3c                	ld	a5,88(a0)
    80001b5a:	6fc8                	ld	a0,152(a5)
    80001b5c:	bfe9                	j	80001b36 <argraw+0x2c>
  panic("argraw");
    80001b5e:	00006517          	auipc	a0,0x6
    80001b62:	87a50513          	addi	a0,a0,-1926 # 800073d8 <states.2240+0x150>
    80001b66:	7dc030ef          	jal	ra,80005342 <panic>

0000000080001b6a <fetchaddr>:
{
    80001b6a:	1101                	addi	sp,sp,-32
    80001b6c:	ec06                	sd	ra,24(sp)
    80001b6e:	e822                	sd	s0,16(sp)
    80001b70:	e426                	sd	s1,8(sp)
    80001b72:	e04a                	sd	s2,0(sp)
    80001b74:	1000                	addi	s0,sp,32
    80001b76:	84aa                	mv	s1,a0
    80001b78:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001b7a:	996ff0ef          	jal	ra,80000d10 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001b7e:	653c                	ld	a5,72(a0)
    80001b80:	02f4f663          	bgeu	s1,a5,80001bac <fetchaddr+0x42>
    80001b84:	00848713          	addi	a4,s1,8
    80001b88:	02e7e463          	bltu	a5,a4,80001bb0 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001b8c:	46a1                	li	a3,8
    80001b8e:	8626                	mv	a2,s1
    80001b90:	85ca                	mv	a1,s2
    80001b92:	6928                	ld	a0,80(a0)
    80001b94:	eebfe0ef          	jal	ra,80000a7e <copyin>
    80001b98:	00a03533          	snez	a0,a0
    80001b9c:	40a00533          	neg	a0,a0
}
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6902                	ld	s2,0(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret
    return -1;
    80001bac:	557d                	li	a0,-1
    80001bae:	bfcd                	j	80001ba0 <fetchaddr+0x36>
    80001bb0:	557d                	li	a0,-1
    80001bb2:	b7fd                	j	80001ba0 <fetchaddr+0x36>

0000000080001bb4 <fetchstr>:
{
    80001bb4:	7179                	addi	sp,sp,-48
    80001bb6:	f406                	sd	ra,40(sp)
    80001bb8:	f022                	sd	s0,32(sp)
    80001bba:	ec26                	sd	s1,24(sp)
    80001bbc:	e84a                	sd	s2,16(sp)
    80001bbe:	e44e                	sd	s3,8(sp)
    80001bc0:	1800                	addi	s0,sp,48
    80001bc2:	892a                	mv	s2,a0
    80001bc4:	84ae                	mv	s1,a1
    80001bc6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001bc8:	948ff0ef          	jal	ra,80000d10 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001bcc:	86ce                	mv	a3,s3
    80001bce:	864a                	mv	a2,s2
    80001bd0:	85a6                	mv	a1,s1
    80001bd2:	6928                	ld	a0,80(a0)
    80001bd4:	f2ffe0ef          	jal	ra,80000b02 <copyinstr>
    80001bd8:	00054c63          	bltz	a0,80001bf0 <fetchstr+0x3c>
  return strlen(buf);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	eeefe0ef          	jal	ra,800002cc <strlen>
}
    80001be2:	70a2                	ld	ra,40(sp)
    80001be4:	7402                	ld	s0,32(sp)
    80001be6:	64e2                	ld	s1,24(sp)
    80001be8:	6942                	ld	s2,16(sp)
    80001bea:	69a2                	ld	s3,8(sp)
    80001bec:	6145                	addi	sp,sp,48
    80001bee:	8082                	ret
    return -1;
    80001bf0:	557d                	li	a0,-1
    80001bf2:	bfc5                	j	80001be2 <fetchstr+0x2e>

0000000080001bf4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001bf4:	1101                	addi	sp,sp,-32
    80001bf6:	ec06                	sd	ra,24(sp)
    80001bf8:	e822                	sd	s0,16(sp)
    80001bfa:	e426                	sd	s1,8(sp)
    80001bfc:	1000                	addi	s0,sp,32
    80001bfe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c00:	f0bff0ef          	jal	ra,80001b0a <argraw>
    80001c04:	c088                	sw	a0,0(s1)
}
    80001c06:	60e2                	ld	ra,24(sp)
    80001c08:	6442                	ld	s0,16(sp)
    80001c0a:	64a2                	ld	s1,8(sp)
    80001c0c:	6105                	addi	sp,sp,32
    80001c0e:	8082                	ret

0000000080001c10 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001c10:	1101                	addi	sp,sp,-32
    80001c12:	ec06                	sd	ra,24(sp)
    80001c14:	e822                	sd	s0,16(sp)
    80001c16:	e426                	sd	s1,8(sp)
    80001c18:	1000                	addi	s0,sp,32
    80001c1a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001c1c:	eefff0ef          	jal	ra,80001b0a <argraw>
    80001c20:	e088                	sd	a0,0(s1)
}
    80001c22:	60e2                	ld	ra,24(sp)
    80001c24:	6442                	ld	s0,16(sp)
    80001c26:	64a2                	ld	s1,8(sp)
    80001c28:	6105                	addi	sp,sp,32
    80001c2a:	8082                	ret

0000000080001c2c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001c2c:	7179                	addi	sp,sp,-48
    80001c2e:	f406                	sd	ra,40(sp)
    80001c30:	f022                	sd	s0,32(sp)
    80001c32:	ec26                	sd	s1,24(sp)
    80001c34:	e84a                	sd	s2,16(sp)
    80001c36:	1800                	addi	s0,sp,48
    80001c38:	84ae                	mv	s1,a1
    80001c3a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001c3c:	fd840593          	addi	a1,s0,-40
    80001c40:	fd1ff0ef          	jal	ra,80001c10 <argaddr>
  return fetchstr(addr, buf, max);
    80001c44:	864a                	mv	a2,s2
    80001c46:	85a6                	mv	a1,s1
    80001c48:	fd843503          	ld	a0,-40(s0)
    80001c4c:	f69ff0ef          	jal	ra,80001bb4 <fetchstr>
}
    80001c50:	70a2                	ld	ra,40(sp)
    80001c52:	7402                	ld	s0,32(sp)
    80001c54:	64e2                	ld	s1,24(sp)
    80001c56:	6942                	ld	s2,16(sp)
    80001c58:	6145                	addi	sp,sp,48
    80001c5a:	8082                	ret

0000000080001c5c <syscall>:
[SYS_sigreturn]   sys_sigreturn,
};

void
syscall(void)
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	e04a                	sd	s2,0(sp)
    80001c66:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80001c68:	8a8ff0ef          	jal	ra,80000d10 <myproc>
    80001c6c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001c6e:	05853903          	ld	s2,88(a0)
    80001c72:	0a893783          	ld	a5,168(s2)
    80001c76:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001c7a:	37fd                	addiw	a5,a5,-1
    80001c7c:	4759                	li	a4,22
    80001c7e:	00f76f63          	bltu	a4,a5,80001c9c <syscall+0x40>
    80001c82:	00369713          	slli	a4,a3,0x3
    80001c86:	00005797          	auipc	a5,0x5
    80001c8a:	79278793          	addi	a5,a5,1938 # 80007418 <syscalls>
    80001c8e:	97ba                	add	a5,a5,a4
    80001c90:	639c                	ld	a5,0(a5)
    80001c92:	c789                	beqz	a5,80001c9c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001c94:	9782                	jalr	a5
    80001c96:	06a93823          	sd	a0,112(s2)
    80001c9a:	a829                	j	80001cb4 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001c9c:	15848613          	addi	a2,s1,344
    80001ca0:	588c                	lw	a1,48(s1)
    80001ca2:	00005517          	auipc	a0,0x5
    80001ca6:	73e50513          	addi	a0,a0,1854 # 800073e0 <states.2240+0x158>
    80001caa:	3e4030ef          	jal	ra,8000508e <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001cae:	6cbc                	ld	a5,88(s1)
    80001cb0:	577d                	li	a4,-1
    80001cb2:	fbb8                	sd	a4,112(a5)
  }
}
    80001cb4:	60e2                	ld	ra,24(sp)
    80001cb6:	6442                	ld	s0,16(sp)
    80001cb8:	64a2                	ld	s1,8(sp)
    80001cba:	6902                	ld	s2,0(sp)
    80001cbc:	6105                	addi	sp,sp,32
    80001cbe:	8082                	ret

0000000080001cc0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001cc0:	1101                	addi	sp,sp,-32
    80001cc2:	ec06                	sd	ra,24(sp)
    80001cc4:	e822                	sd	s0,16(sp)
    80001cc6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001cc8:	fec40593          	addi	a1,s0,-20
    80001ccc:	4501                	li	a0,0
    80001cce:	f27ff0ef          	jal	ra,80001bf4 <argint>
  exit(n);
    80001cd2:	fec42503          	lw	a0,-20(s0)
    80001cd6:	f1aff0ef          	jal	ra,800013f0 <exit>
  return 0;  // not reached
}
    80001cda:	4501                	li	a0,0
    80001cdc:	60e2                	ld	ra,24(sp)
    80001cde:	6442                	ld	s0,16(sp)
    80001ce0:	6105                	addi	sp,sp,32
    80001ce2:	8082                	ret

0000000080001ce4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001ce4:	1141                	addi	sp,sp,-16
    80001ce6:	e406                	sd	ra,8(sp)
    80001ce8:	e022                	sd	s0,0(sp)
    80001cea:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001cec:	824ff0ef          	jal	ra,80000d10 <myproc>
}
    80001cf0:	5908                	lw	a0,48(a0)
    80001cf2:	60a2                	ld	ra,8(sp)
    80001cf4:	6402                	ld	s0,0(sp)
    80001cf6:	0141                	addi	sp,sp,16
    80001cf8:	8082                	ret

0000000080001cfa <sys_fork>:

uint64
sys_fork(void)
{
    80001cfa:	1141                	addi	sp,sp,-16
    80001cfc:	e406                	sd	ra,8(sp)
    80001cfe:	e022                	sd	s0,0(sp)
    80001d00:	0800                	addi	s0,sp,16
  return fork();
    80001d02:	b40ff0ef          	jal	ra,80001042 <fork>
}
    80001d06:	60a2                	ld	ra,8(sp)
    80001d08:	6402                	ld	s0,0(sp)
    80001d0a:	0141                	addi	sp,sp,16
    80001d0c:	8082                	ret

0000000080001d0e <sys_wait>:

uint64
sys_wait(void)
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001d16:	fe840593          	addi	a1,s0,-24
    80001d1a:	4501                	li	a0,0
    80001d1c:	ef5ff0ef          	jal	ra,80001c10 <argaddr>
  return wait(p);
    80001d20:	fe843503          	ld	a0,-24(s0)
    80001d24:	823ff0ef          	jal	ra,80001546 <wait>
}
    80001d28:	60e2                	ld	ra,24(sp)
    80001d2a:	6442                	ld	s0,16(sp)
    80001d2c:	6105                	addi	sp,sp,32
    80001d2e:	8082                	ret

0000000080001d30 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001d30:	7179                	addi	sp,sp,-48
    80001d32:	f406                	sd	ra,40(sp)
    80001d34:	f022                	sd	s0,32(sp)
    80001d36:	ec26                	sd	s1,24(sp)
    80001d38:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001d3a:	fdc40593          	addi	a1,s0,-36
    80001d3e:	4501                	li	a0,0
    80001d40:	eb5ff0ef          	jal	ra,80001bf4 <argint>
  addr = myproc()->sz;
    80001d44:	fcdfe0ef          	jal	ra,80000d10 <myproc>
    80001d48:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001d4a:	fdc42503          	lw	a0,-36(s0)
    80001d4e:	aa4ff0ef          	jal	ra,80000ff2 <growproc>
    80001d52:	00054863          	bltz	a0,80001d62 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001d56:	8526                	mv	a0,s1
    80001d58:	70a2                	ld	ra,40(sp)
    80001d5a:	7402                	ld	s0,32(sp)
    80001d5c:	64e2                	ld	s1,24(sp)
    80001d5e:	6145                	addi	sp,sp,48
    80001d60:	8082                	ret
    return -1;
    80001d62:	54fd                	li	s1,-1
    80001d64:	bfcd                	j	80001d56 <sys_sbrk+0x26>

0000000080001d66 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001d66:	7139                	addi	sp,sp,-64
    80001d68:	fc06                	sd	ra,56(sp)
    80001d6a:	f822                	sd	s0,48(sp)
    80001d6c:	f426                	sd	s1,40(sp)
    80001d6e:	f04a                	sd	s2,32(sp)
    80001d70:	ec4e                	sd	s3,24(sp)
    80001d72:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001d74:	fcc40593          	addi	a1,s0,-52
    80001d78:	4501                	li	a0,0
    80001d7a:	e7bff0ef          	jal	ra,80001bf4 <argint>
  if(n < 0)
    80001d7e:	fcc42783          	lw	a5,-52(s0)
    80001d82:	0607c563          	bltz	a5,80001dec <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001d86:	00010517          	auipc	a0,0x10
    80001d8a:	7da50513          	addi	a0,a0,2010 # 80012560 <tickslock>
    80001d8e:	0d1030ef          	jal	ra,8000565e <acquire>
  ticks0 = ticks;
    80001d92:	00006917          	auipc	s2,0x6
    80001d96:	b6692903          	lw	s2,-1178(s2) # 800078f8 <ticks>
  while(ticks - ticks0 < n){
    80001d9a:	fcc42783          	lw	a5,-52(s0)
    80001d9e:	cb8d                	beqz	a5,80001dd0 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001da0:	00010997          	auipc	s3,0x10
    80001da4:	7c098993          	addi	s3,s3,1984 # 80012560 <tickslock>
    80001da8:	00006497          	auipc	s1,0x6
    80001dac:	b5048493          	addi	s1,s1,-1200 # 800078f8 <ticks>
    if(killed(myproc())){
    80001db0:	f61fe0ef          	jal	ra,80000d10 <myproc>
    80001db4:	f68ff0ef          	jal	ra,8000151c <killed>
    80001db8:	ed0d                	bnez	a0,80001df2 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001dba:	85ce                	mv	a1,s3
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	d26ff0ef          	jal	ra,800012e4 <sleep>
  while(ticks - ticks0 < n){
    80001dc2:	409c                	lw	a5,0(s1)
    80001dc4:	412787bb          	subw	a5,a5,s2
    80001dc8:	fcc42703          	lw	a4,-52(s0)
    80001dcc:	fee7e2e3          	bltu	a5,a4,80001db0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001dd0:	00010517          	auipc	a0,0x10
    80001dd4:	79050513          	addi	a0,a0,1936 # 80012560 <tickslock>
    80001dd8:	11f030ef          	jal	ra,800056f6 <release>
  return 0;
    80001ddc:	4501                	li	a0,0
}
    80001dde:	70e2                	ld	ra,56(sp)
    80001de0:	7442                	ld	s0,48(sp)
    80001de2:	74a2                	ld	s1,40(sp)
    80001de4:	7902                	ld	s2,32(sp)
    80001de6:	69e2                	ld	s3,24(sp)
    80001de8:	6121                	addi	sp,sp,64
    80001dea:	8082                	ret
    n = 0;
    80001dec:	fc042623          	sw	zero,-52(s0)
    80001df0:	bf59                	j	80001d86 <sys_sleep+0x20>
      release(&tickslock);
    80001df2:	00010517          	auipc	a0,0x10
    80001df6:	76e50513          	addi	a0,a0,1902 # 80012560 <tickslock>
    80001dfa:	0fd030ef          	jal	ra,800056f6 <release>
      return -1;
    80001dfe:	557d                	li	a0,-1
    80001e00:	bff9                	j	80001dde <sys_sleep+0x78>

0000000080001e02 <sys_kill>:

uint64
sys_kill(void)
{
    80001e02:	1101                	addi	sp,sp,-32
    80001e04:	ec06                	sd	ra,24(sp)
    80001e06:	e822                	sd	s0,16(sp)
    80001e08:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001e0a:	fec40593          	addi	a1,s0,-20
    80001e0e:	4501                	li	a0,0
    80001e10:	de5ff0ef          	jal	ra,80001bf4 <argint>
  return kill(pid);
    80001e14:	fec42503          	lw	a0,-20(s0)
    80001e18:	e7aff0ef          	jal	ra,80001492 <kill>
}
    80001e1c:	60e2                	ld	ra,24(sp)
    80001e1e:	6442                	ld	s0,16(sp)
    80001e20:	6105                	addi	sp,sp,32
    80001e22:	8082                	ret

0000000080001e24 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001e24:	1101                	addi	sp,sp,-32
    80001e26:	ec06                	sd	ra,24(sp)
    80001e28:	e822                	sd	s0,16(sp)
    80001e2a:	e426                	sd	s1,8(sp)
    80001e2c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001e2e:	00010517          	auipc	a0,0x10
    80001e32:	73250513          	addi	a0,a0,1842 # 80012560 <tickslock>
    80001e36:	029030ef          	jal	ra,8000565e <acquire>
  xticks = ticks;
    80001e3a:	00006497          	auipc	s1,0x6
    80001e3e:	abe4a483          	lw	s1,-1346(s1) # 800078f8 <ticks>
  release(&tickslock);
    80001e42:	00010517          	auipc	a0,0x10
    80001e46:	71e50513          	addi	a0,a0,1822 # 80012560 <tickslock>
    80001e4a:	0ad030ef          	jal	ra,800056f6 <release>
  return xticks;
}
    80001e4e:	02049513          	slli	a0,s1,0x20
    80001e52:	9101                	srli	a0,a0,0x20
    80001e54:	60e2                	ld	ra,24(sp)
    80001e56:	6442                	ld	s0,16(sp)
    80001e58:	64a2                	ld	s1,8(sp)
    80001e5a:	6105                	addi	sp,sp,32
    80001e5c:	8082                	ret

0000000080001e5e <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80001e5e:	7179                	addi	sp,sp,-48
    80001e60:	f406                	sd	ra,40(sp)
    80001e62:	f022                	sd	s0,32(sp)
    80001e64:	ec26                	sd	s1,24(sp)
    80001e66:	1800                	addi	s0,sp,48
    int interval;
    uint64 handler;
    struct proc *p = myproc();
    80001e68:	ea9fe0ef          	jal	ra,80000d10 <myproc>
    80001e6c:	84aa                	mv	s1,a0
    
    argint(0, &interval);
    80001e6e:	fdc40593          	addi	a1,s0,-36
    80001e72:	4501                	li	a0,0
    80001e74:	d81ff0ef          	jal	ra,80001bf4 <argint>
    argaddr(1, &handler);
    80001e78:	fd040593          	addi	a1,s0,-48
    80001e7c:	4505                	li	a0,1
    80001e7e:	d93ff0ef          	jal	ra,80001c10 <argaddr>
    
    if (interval < 0) {
    80001e82:	fdc42783          	lw	a5,-36(s0)
    80001e86:	0207c063          	bltz	a5,80001ea6 <sys_sigalarm+0x48>
        return -1; // 无效的时间间隔
    }
    

    p->interval = interval;
    80001e8a:	16f4a423          	sw	a5,360(s1)
    p->handler = handler;
    80001e8e:	fd043783          	ld	a5,-48(s0)
    80001e92:	16f4b823          	sd	a5,368(s1)
    p->passedticks = 0; // 重置计时器
    80001e96:	1604ac23          	sw	zero,376(s1)
    
    return 0;
    80001e9a:	4501                	li	a0,0
}
    80001e9c:	70a2                	ld	ra,40(sp)
    80001e9e:	7402                	ld	s0,32(sp)
    80001ea0:	64e2                	ld	s1,24(sp)
    80001ea2:	6145                	addi	sp,sp,48
    80001ea4:	8082                	ret
        return -1; // 无效的时间间隔
    80001ea6:	557d                	li	a0,-1
    80001ea8:	bfd5                	j	80001e9c <sys_sigalarm+0x3e>

0000000080001eaa <sys_sigreturn>:

// lab4-3
uint64 sys_sigreturn(void) {
    80001eaa:	1101                	addi	sp,sp,-32
    80001eac:	ec06                	sd	ra,24(sp)
    80001eae:	e822                	sd	s0,16(sp)
    80001eb0:	e426                	sd	s1,8(sp)
    80001eb2:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80001eb4:	e5dfe0ef          	jal	ra,80000d10 <myproc>
    80001eb8:	84aa                	mv	s1,a0
    // 恢复陷阱帧
    memmove(p->trapframe, &p->saved_trapframe, sizeof(struct trapframe));
    80001eba:	12000613          	li	a2,288
    80001ebe:	18050593          	addi	a1,a0,384
    80001ec2:	6d28                	ld	a0,88(a0)
    80001ec4:	ae8fe0ef          	jal	ra,800001ac <memmove>
    // 重置passedticks，防止重入
    p->passedticks = 0;
    80001ec8:	1604ac23          	sw	zero,376(s1)
    return p->trapframe->a0;
    80001ecc:	6cbc                	ld	a5,88(s1)
}
    80001ece:	7ba8                	ld	a0,112(a5)
    80001ed0:	60e2                	ld	ra,24(sp)
    80001ed2:	6442                	ld	s0,16(sp)
    80001ed4:	64a2                	ld	s1,8(sp)
    80001ed6:	6105                	addi	sp,sp,32
    80001ed8:	8082                	ret

0000000080001eda <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80001eda:	7179                	addi	sp,sp,-48
    80001edc:	f406                	sd	ra,40(sp)
    80001ede:	f022                	sd	s0,32(sp)
    80001ee0:	ec26                	sd	s1,24(sp)
    80001ee2:	e84a                	sd	s2,16(sp)
    80001ee4:	e44e                	sd	s3,8(sp)
    80001ee6:	e052                	sd	s4,0(sp)
    80001ee8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80001eea:	00005597          	auipc	a1,0x5
    80001eee:	5ee58593          	addi	a1,a1,1518 # 800074d8 <syscalls+0xc0>
    80001ef2:	00010517          	auipc	a0,0x10
    80001ef6:	68650513          	addi	a0,a0,1670 # 80012578 <bcache>
    80001efa:	6e4030ef          	jal	ra,800055de <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80001efe:	00018797          	auipc	a5,0x18
    80001f02:	67a78793          	addi	a5,a5,1658 # 8001a578 <bcache+0x8000>
    80001f06:	00019717          	auipc	a4,0x19
    80001f0a:	8da70713          	addi	a4,a4,-1830 # 8001a7e0 <bcache+0x8268>
    80001f0e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80001f12:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f16:	00010497          	auipc	s1,0x10
    80001f1a:	67a48493          	addi	s1,s1,1658 # 80012590 <bcache+0x18>
    b->next = bcache.head.next;
    80001f1e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80001f20:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80001f22:	00005a17          	auipc	s4,0x5
    80001f26:	5bea0a13          	addi	s4,s4,1470 # 800074e0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80001f2a:	2b893783          	ld	a5,696(s2)
    80001f2e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80001f30:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80001f34:	85d2                	mv	a1,s4
    80001f36:	01048513          	addi	a0,s1,16
    80001f3a:	224010ef          	jal	ra,8000315e <initsleeplock>
    bcache.head.next->prev = b;
    80001f3e:	2b893783          	ld	a5,696(s2)
    80001f42:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80001f44:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80001f48:	45848493          	addi	s1,s1,1112
    80001f4c:	fd349fe3          	bne	s1,s3,80001f2a <binit+0x50>
  }
}
    80001f50:	70a2                	ld	ra,40(sp)
    80001f52:	7402                	ld	s0,32(sp)
    80001f54:	64e2                	ld	s1,24(sp)
    80001f56:	6942                	ld	s2,16(sp)
    80001f58:	69a2                	ld	s3,8(sp)
    80001f5a:	6a02                	ld	s4,0(sp)
    80001f5c:	6145                	addi	sp,sp,48
    80001f5e:	8082                	ret

0000000080001f60 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80001f60:	7179                	addi	sp,sp,-48
    80001f62:	f406                	sd	ra,40(sp)
    80001f64:	f022                	sd	s0,32(sp)
    80001f66:	ec26                	sd	s1,24(sp)
    80001f68:	e84a                	sd	s2,16(sp)
    80001f6a:	e44e                	sd	s3,8(sp)
    80001f6c:	1800                	addi	s0,sp,48
    80001f6e:	89aa                	mv	s3,a0
    80001f70:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80001f72:	00010517          	auipc	a0,0x10
    80001f76:	60650513          	addi	a0,a0,1542 # 80012578 <bcache>
    80001f7a:	6e4030ef          	jal	ra,8000565e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80001f7e:	00019497          	auipc	s1,0x19
    80001f82:	8b24b483          	ld	s1,-1870(s1) # 8001a830 <bcache+0x82b8>
    80001f86:	00019797          	auipc	a5,0x19
    80001f8a:	85a78793          	addi	a5,a5,-1958 # 8001a7e0 <bcache+0x8268>
    80001f8e:	02f48b63          	beq	s1,a5,80001fc4 <bread+0x64>
    80001f92:	873e                	mv	a4,a5
    80001f94:	a021                	j	80001f9c <bread+0x3c>
    80001f96:	68a4                	ld	s1,80(s1)
    80001f98:	02e48663          	beq	s1,a4,80001fc4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80001f9c:	449c                	lw	a5,8(s1)
    80001f9e:	ff379ce3          	bne	a5,s3,80001f96 <bread+0x36>
    80001fa2:	44dc                	lw	a5,12(s1)
    80001fa4:	ff2799e3          	bne	a5,s2,80001f96 <bread+0x36>
      b->refcnt++;
    80001fa8:	40bc                	lw	a5,64(s1)
    80001faa:	2785                	addiw	a5,a5,1
    80001fac:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80001fae:	00010517          	auipc	a0,0x10
    80001fb2:	5ca50513          	addi	a0,a0,1482 # 80012578 <bcache>
    80001fb6:	740030ef          	jal	ra,800056f6 <release>
      acquiresleep(&b->lock);
    80001fba:	01048513          	addi	a0,s1,16
    80001fbe:	1d6010ef          	jal	ra,80003194 <acquiresleep>
      return b;
    80001fc2:	a889                	j	80002014 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80001fc4:	00019497          	auipc	s1,0x19
    80001fc8:	8644b483          	ld	s1,-1948(s1) # 8001a828 <bcache+0x82b0>
    80001fcc:	00019797          	auipc	a5,0x19
    80001fd0:	81478793          	addi	a5,a5,-2028 # 8001a7e0 <bcache+0x8268>
    80001fd4:	00f48863          	beq	s1,a5,80001fe4 <bread+0x84>
    80001fd8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80001fda:	40bc                	lw	a5,64(s1)
    80001fdc:	cb91                	beqz	a5,80001ff0 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80001fde:	64a4                	ld	s1,72(s1)
    80001fe0:	fee49de3          	bne	s1,a4,80001fda <bread+0x7a>
  panic("bget: no buffers");
    80001fe4:	00005517          	auipc	a0,0x5
    80001fe8:	50450513          	addi	a0,a0,1284 # 800074e8 <syscalls+0xd0>
    80001fec:	356030ef          	jal	ra,80005342 <panic>
      b->dev = dev;
    80001ff0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80001ff4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80001ff8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80001ffc:	4785                	li	a5,1
    80001ffe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002000:	00010517          	auipc	a0,0x10
    80002004:	57850513          	addi	a0,a0,1400 # 80012578 <bcache>
    80002008:	6ee030ef          	jal	ra,800056f6 <release>
      acquiresleep(&b->lock);
    8000200c:	01048513          	addi	a0,s1,16
    80002010:	184010ef          	jal	ra,80003194 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002014:	409c                	lw	a5,0(s1)
    80002016:	cb89                	beqz	a5,80002028 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002018:	8526                	mv	a0,s1
    8000201a:	70a2                	ld	ra,40(sp)
    8000201c:	7402                	ld	s0,32(sp)
    8000201e:	64e2                	ld	s1,24(sp)
    80002020:	6942                	ld	s2,16(sp)
    80002022:	69a2                	ld	s3,8(sp)
    80002024:	6145                	addi	sp,sp,48
    80002026:	8082                	ret
    virtio_disk_rw(b, 0);
    80002028:	4581                	li	a1,0
    8000202a:	8526                	mv	a0,s1
    8000202c:	0c5020ef          	jal	ra,800048f0 <virtio_disk_rw>
    b->valid = 1;
    80002030:	4785                	li	a5,1
    80002032:	c09c                	sw	a5,0(s1)
  return b;
    80002034:	b7d5                	j	80002018 <bread+0xb8>

0000000080002036 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002036:	1101                	addi	sp,sp,-32
    80002038:	ec06                	sd	ra,24(sp)
    8000203a:	e822                	sd	s0,16(sp)
    8000203c:	e426                	sd	s1,8(sp)
    8000203e:	1000                	addi	s0,sp,32
    80002040:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002042:	0541                	addi	a0,a0,16
    80002044:	1ce010ef          	jal	ra,80003212 <holdingsleep>
    80002048:	c911                	beqz	a0,8000205c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000204a:	4585                	li	a1,1
    8000204c:	8526                	mv	a0,s1
    8000204e:	0a3020ef          	jal	ra,800048f0 <virtio_disk_rw>
}
    80002052:	60e2                	ld	ra,24(sp)
    80002054:	6442                	ld	s0,16(sp)
    80002056:	64a2                	ld	s1,8(sp)
    80002058:	6105                	addi	sp,sp,32
    8000205a:	8082                	ret
    panic("bwrite");
    8000205c:	00005517          	auipc	a0,0x5
    80002060:	4a450513          	addi	a0,a0,1188 # 80007500 <syscalls+0xe8>
    80002064:	2de030ef          	jal	ra,80005342 <panic>

0000000080002068 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002068:	1101                	addi	sp,sp,-32
    8000206a:	ec06                	sd	ra,24(sp)
    8000206c:	e822                	sd	s0,16(sp)
    8000206e:	e426                	sd	s1,8(sp)
    80002070:	e04a                	sd	s2,0(sp)
    80002072:	1000                	addi	s0,sp,32
    80002074:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002076:	01050913          	addi	s2,a0,16
    8000207a:	854a                	mv	a0,s2
    8000207c:	196010ef          	jal	ra,80003212 <holdingsleep>
    80002080:	c13d                	beqz	a0,800020e6 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002082:	854a                	mv	a0,s2
    80002084:	156010ef          	jal	ra,800031da <releasesleep>

  acquire(&bcache.lock);
    80002088:	00010517          	auipc	a0,0x10
    8000208c:	4f050513          	addi	a0,a0,1264 # 80012578 <bcache>
    80002090:	5ce030ef          	jal	ra,8000565e <acquire>
  b->refcnt--;
    80002094:	40bc                	lw	a5,64(s1)
    80002096:	37fd                	addiw	a5,a5,-1
    80002098:	0007871b          	sext.w	a4,a5
    8000209c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000209e:	eb05                	bnez	a4,800020ce <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800020a0:	68bc                	ld	a5,80(s1)
    800020a2:	64b8                	ld	a4,72(s1)
    800020a4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800020a6:	64bc                	ld	a5,72(s1)
    800020a8:	68b8                	ld	a4,80(s1)
    800020aa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800020ac:	00018797          	auipc	a5,0x18
    800020b0:	4cc78793          	addi	a5,a5,1228 # 8001a578 <bcache+0x8000>
    800020b4:	2b87b703          	ld	a4,696(a5)
    800020b8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800020ba:	00018717          	auipc	a4,0x18
    800020be:	72670713          	addi	a4,a4,1830 # 8001a7e0 <bcache+0x8268>
    800020c2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800020c4:	2b87b703          	ld	a4,696(a5)
    800020c8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800020ca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800020ce:	00010517          	auipc	a0,0x10
    800020d2:	4aa50513          	addi	a0,a0,1194 # 80012578 <bcache>
    800020d6:	620030ef          	jal	ra,800056f6 <release>
}
    800020da:	60e2                	ld	ra,24(sp)
    800020dc:	6442                	ld	s0,16(sp)
    800020de:	64a2                	ld	s1,8(sp)
    800020e0:	6902                	ld	s2,0(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret
    panic("brelse");
    800020e6:	00005517          	auipc	a0,0x5
    800020ea:	42250513          	addi	a0,a0,1058 # 80007508 <syscalls+0xf0>
    800020ee:	254030ef          	jal	ra,80005342 <panic>

00000000800020f2 <bpin>:

void
bpin(struct buf *b) {
    800020f2:	1101                	addi	sp,sp,-32
    800020f4:	ec06                	sd	ra,24(sp)
    800020f6:	e822                	sd	s0,16(sp)
    800020f8:	e426                	sd	s1,8(sp)
    800020fa:	1000                	addi	s0,sp,32
    800020fc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800020fe:	00010517          	auipc	a0,0x10
    80002102:	47a50513          	addi	a0,a0,1146 # 80012578 <bcache>
    80002106:	558030ef          	jal	ra,8000565e <acquire>
  b->refcnt++;
    8000210a:	40bc                	lw	a5,64(s1)
    8000210c:	2785                	addiw	a5,a5,1
    8000210e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002110:	00010517          	auipc	a0,0x10
    80002114:	46850513          	addi	a0,a0,1128 # 80012578 <bcache>
    80002118:	5de030ef          	jal	ra,800056f6 <release>
}
    8000211c:	60e2                	ld	ra,24(sp)
    8000211e:	6442                	ld	s0,16(sp)
    80002120:	64a2                	ld	s1,8(sp)
    80002122:	6105                	addi	sp,sp,32
    80002124:	8082                	ret

0000000080002126 <bunpin>:

void
bunpin(struct buf *b) {
    80002126:	1101                	addi	sp,sp,-32
    80002128:	ec06                	sd	ra,24(sp)
    8000212a:	e822                	sd	s0,16(sp)
    8000212c:	e426                	sd	s1,8(sp)
    8000212e:	1000                	addi	s0,sp,32
    80002130:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002132:	00010517          	auipc	a0,0x10
    80002136:	44650513          	addi	a0,a0,1094 # 80012578 <bcache>
    8000213a:	524030ef          	jal	ra,8000565e <acquire>
  b->refcnt--;
    8000213e:	40bc                	lw	a5,64(s1)
    80002140:	37fd                	addiw	a5,a5,-1
    80002142:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002144:	00010517          	auipc	a0,0x10
    80002148:	43450513          	addi	a0,a0,1076 # 80012578 <bcache>
    8000214c:	5aa030ef          	jal	ra,800056f6 <release>
}
    80002150:	60e2                	ld	ra,24(sp)
    80002152:	6442                	ld	s0,16(sp)
    80002154:	64a2                	ld	s1,8(sp)
    80002156:	6105                	addi	sp,sp,32
    80002158:	8082                	ret

000000008000215a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000215a:	1101                	addi	sp,sp,-32
    8000215c:	ec06                	sd	ra,24(sp)
    8000215e:	e822                	sd	s0,16(sp)
    80002160:	e426                	sd	s1,8(sp)
    80002162:	e04a                	sd	s2,0(sp)
    80002164:	1000                	addi	s0,sp,32
    80002166:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002168:	00d5d59b          	srliw	a1,a1,0xd
    8000216c:	00019797          	auipc	a5,0x19
    80002170:	ae87a783          	lw	a5,-1304(a5) # 8001ac54 <sb+0x1c>
    80002174:	9dbd                	addw	a1,a1,a5
    80002176:	debff0ef          	jal	ra,80001f60 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000217a:	0074f713          	andi	a4,s1,7
    8000217e:	4785                	li	a5,1
    80002180:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002184:	14ce                	slli	s1,s1,0x33
    80002186:	90d9                	srli	s1,s1,0x36
    80002188:	00950733          	add	a4,a0,s1
    8000218c:	05874703          	lbu	a4,88(a4)
    80002190:	00e7f6b3          	and	a3,a5,a4
    80002194:	c29d                	beqz	a3,800021ba <bfree+0x60>
    80002196:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002198:	94aa                	add	s1,s1,a0
    8000219a:	fff7c793          	not	a5,a5
    8000219e:	8ff9                	and	a5,a5,a4
    800021a0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800021a4:	6e9000ef          	jal	ra,8000308c <log_write>
  brelse(bp);
    800021a8:	854a                	mv	a0,s2
    800021aa:	ebfff0ef          	jal	ra,80002068 <brelse>
}
    800021ae:	60e2                	ld	ra,24(sp)
    800021b0:	6442                	ld	s0,16(sp)
    800021b2:	64a2                	ld	s1,8(sp)
    800021b4:	6902                	ld	s2,0(sp)
    800021b6:	6105                	addi	sp,sp,32
    800021b8:	8082                	ret
    panic("freeing free block");
    800021ba:	00005517          	auipc	a0,0x5
    800021be:	35650513          	addi	a0,a0,854 # 80007510 <syscalls+0xf8>
    800021c2:	180030ef          	jal	ra,80005342 <panic>

00000000800021c6 <balloc>:
{
    800021c6:	711d                	addi	sp,sp,-96
    800021c8:	ec86                	sd	ra,88(sp)
    800021ca:	e8a2                	sd	s0,80(sp)
    800021cc:	e4a6                	sd	s1,72(sp)
    800021ce:	e0ca                	sd	s2,64(sp)
    800021d0:	fc4e                	sd	s3,56(sp)
    800021d2:	f852                	sd	s4,48(sp)
    800021d4:	f456                	sd	s5,40(sp)
    800021d6:	f05a                	sd	s6,32(sp)
    800021d8:	ec5e                	sd	s7,24(sp)
    800021da:	e862                	sd	s8,16(sp)
    800021dc:	e466                	sd	s9,8(sp)
    800021de:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800021e0:	00019797          	auipc	a5,0x19
    800021e4:	a5c7a783          	lw	a5,-1444(a5) # 8001ac3c <sb+0x4>
    800021e8:	0e078163          	beqz	a5,800022ca <balloc+0x104>
    800021ec:	8baa                	mv	s7,a0
    800021ee:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800021f0:	00019b17          	auipc	s6,0x19
    800021f4:	a48b0b13          	addi	s6,s6,-1464 # 8001ac38 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800021f8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800021fa:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800021fc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800021fe:	6c89                	lui	s9,0x2
    80002200:	a0b5                	j	8000226c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002202:	974a                	add	a4,a4,s2
    80002204:	8fd5                	or	a5,a5,a3
    80002206:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000220a:	854a                	mv	a0,s2
    8000220c:	681000ef          	jal	ra,8000308c <log_write>
        brelse(bp);
    80002210:	854a                	mv	a0,s2
    80002212:	e57ff0ef          	jal	ra,80002068 <brelse>
  bp = bread(dev, bno);
    80002216:	85a6                	mv	a1,s1
    80002218:	855e                	mv	a0,s7
    8000221a:	d47ff0ef          	jal	ra,80001f60 <bread>
    8000221e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002220:	40000613          	li	a2,1024
    80002224:	4581                	li	a1,0
    80002226:	05850513          	addi	a0,a0,88
    8000222a:	f23fd0ef          	jal	ra,8000014c <memset>
  log_write(bp);
    8000222e:	854a                	mv	a0,s2
    80002230:	65d000ef          	jal	ra,8000308c <log_write>
  brelse(bp);
    80002234:	854a                	mv	a0,s2
    80002236:	e33ff0ef          	jal	ra,80002068 <brelse>
}
    8000223a:	8526                	mv	a0,s1
    8000223c:	60e6                	ld	ra,88(sp)
    8000223e:	6446                	ld	s0,80(sp)
    80002240:	64a6                	ld	s1,72(sp)
    80002242:	6906                	ld	s2,64(sp)
    80002244:	79e2                	ld	s3,56(sp)
    80002246:	7a42                	ld	s4,48(sp)
    80002248:	7aa2                	ld	s5,40(sp)
    8000224a:	7b02                	ld	s6,32(sp)
    8000224c:	6be2                	ld	s7,24(sp)
    8000224e:	6c42                	ld	s8,16(sp)
    80002250:	6ca2                	ld	s9,8(sp)
    80002252:	6125                	addi	sp,sp,96
    80002254:	8082                	ret
    brelse(bp);
    80002256:	854a                	mv	a0,s2
    80002258:	e11ff0ef          	jal	ra,80002068 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000225c:	015c87bb          	addw	a5,s9,s5
    80002260:	00078a9b          	sext.w	s5,a5
    80002264:	004b2703          	lw	a4,4(s6)
    80002268:	06eaf163          	bgeu	s5,a4,800022ca <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    8000226c:	41fad79b          	sraiw	a5,s5,0x1f
    80002270:	0137d79b          	srliw	a5,a5,0x13
    80002274:	015787bb          	addw	a5,a5,s5
    80002278:	40d7d79b          	sraiw	a5,a5,0xd
    8000227c:	01cb2583          	lw	a1,28(s6)
    80002280:	9dbd                	addw	a1,a1,a5
    80002282:	855e                	mv	a0,s7
    80002284:	cddff0ef          	jal	ra,80001f60 <bread>
    80002288:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000228a:	004b2503          	lw	a0,4(s6)
    8000228e:	000a849b          	sext.w	s1,s5
    80002292:	8662                	mv	a2,s8
    80002294:	fca4f1e3          	bgeu	s1,a0,80002256 <balloc+0x90>
      m = 1 << (bi % 8);
    80002298:	41f6579b          	sraiw	a5,a2,0x1f
    8000229c:	01d7d69b          	srliw	a3,a5,0x1d
    800022a0:	00c6873b          	addw	a4,a3,a2
    800022a4:	00777793          	andi	a5,a4,7
    800022a8:	9f95                	subw	a5,a5,a3
    800022aa:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800022ae:	4037571b          	sraiw	a4,a4,0x3
    800022b2:	00e906b3          	add	a3,s2,a4
    800022b6:	0586c683          	lbu	a3,88(a3)
    800022ba:	00d7f5b3          	and	a1,a5,a3
    800022be:	d1b1                	beqz	a1,80002202 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800022c0:	2605                	addiw	a2,a2,1
    800022c2:	2485                	addiw	s1,s1,1
    800022c4:	fd4618e3          	bne	a2,s4,80002294 <balloc+0xce>
    800022c8:	b779                	j	80002256 <balloc+0x90>
  printf("balloc: out of blocks\n");
    800022ca:	00005517          	auipc	a0,0x5
    800022ce:	25e50513          	addi	a0,a0,606 # 80007528 <syscalls+0x110>
    800022d2:	5bd020ef          	jal	ra,8000508e <printf>
  return 0;
    800022d6:	4481                	li	s1,0
    800022d8:	b78d                	j	8000223a <balloc+0x74>

00000000800022da <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800022da:	7179                	addi	sp,sp,-48
    800022dc:	f406                	sd	ra,40(sp)
    800022de:	f022                	sd	s0,32(sp)
    800022e0:	ec26                	sd	s1,24(sp)
    800022e2:	e84a                	sd	s2,16(sp)
    800022e4:	e44e                	sd	s3,8(sp)
    800022e6:	e052                	sd	s4,0(sp)
    800022e8:	1800                	addi	s0,sp,48
    800022ea:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800022ec:	47ad                	li	a5,11
    800022ee:	02b7e563          	bltu	a5,a1,80002318 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800022f2:	02059493          	slli	s1,a1,0x20
    800022f6:	9081                	srli	s1,s1,0x20
    800022f8:	048a                	slli	s1,s1,0x2
    800022fa:	94aa                	add	s1,s1,a0
    800022fc:	0504a903          	lw	s2,80(s1)
    80002300:	06091663          	bnez	s2,8000236c <bmap+0x92>
      addr = balloc(ip->dev);
    80002304:	4108                	lw	a0,0(a0)
    80002306:	ec1ff0ef          	jal	ra,800021c6 <balloc>
    8000230a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000230e:	04090f63          	beqz	s2,8000236c <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002312:	0524a823          	sw	s2,80(s1)
    80002316:	a899                	j	8000236c <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002318:	ff45849b          	addiw	s1,a1,-12
    8000231c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002320:	0ff00793          	li	a5,255
    80002324:	06e7eb63          	bltu	a5,a4,8000239a <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002328:	08052903          	lw	s2,128(a0)
    8000232c:	00091b63          	bnez	s2,80002342 <bmap+0x68>
      addr = balloc(ip->dev);
    80002330:	4108                	lw	a0,0(a0)
    80002332:	e95ff0ef          	jal	ra,800021c6 <balloc>
    80002336:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000233a:	02090963          	beqz	s2,8000236c <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000233e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002342:	85ca                	mv	a1,s2
    80002344:	0009a503          	lw	a0,0(s3)
    80002348:	c19ff0ef          	jal	ra,80001f60 <bread>
    8000234c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000234e:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002352:	02049593          	slli	a1,s1,0x20
    80002356:	9181                	srli	a1,a1,0x20
    80002358:	058a                	slli	a1,a1,0x2
    8000235a:	00b784b3          	add	s1,a5,a1
    8000235e:	0004a903          	lw	s2,0(s1)
    80002362:	00090e63          	beqz	s2,8000237e <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002366:	8552                	mv	a0,s4
    80002368:	d01ff0ef          	jal	ra,80002068 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000236c:	854a                	mv	a0,s2
    8000236e:	70a2                	ld	ra,40(sp)
    80002370:	7402                	ld	s0,32(sp)
    80002372:	64e2                	ld	s1,24(sp)
    80002374:	6942                	ld	s2,16(sp)
    80002376:	69a2                	ld	s3,8(sp)
    80002378:	6a02                	ld	s4,0(sp)
    8000237a:	6145                	addi	sp,sp,48
    8000237c:	8082                	ret
      addr = balloc(ip->dev);
    8000237e:	0009a503          	lw	a0,0(s3)
    80002382:	e45ff0ef          	jal	ra,800021c6 <balloc>
    80002386:	0005091b          	sext.w	s2,a0
      if(addr){
    8000238a:	fc090ee3          	beqz	s2,80002366 <bmap+0x8c>
        a[bn] = addr;
    8000238e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002392:	8552                	mv	a0,s4
    80002394:	4f9000ef          	jal	ra,8000308c <log_write>
    80002398:	b7f9                	j	80002366 <bmap+0x8c>
  panic("bmap: out of range");
    8000239a:	00005517          	auipc	a0,0x5
    8000239e:	1a650513          	addi	a0,a0,422 # 80007540 <syscalls+0x128>
    800023a2:	7a1020ef          	jal	ra,80005342 <panic>

00000000800023a6 <iget>:
{
    800023a6:	7179                	addi	sp,sp,-48
    800023a8:	f406                	sd	ra,40(sp)
    800023aa:	f022                	sd	s0,32(sp)
    800023ac:	ec26                	sd	s1,24(sp)
    800023ae:	e84a                	sd	s2,16(sp)
    800023b0:	e44e                	sd	s3,8(sp)
    800023b2:	e052                	sd	s4,0(sp)
    800023b4:	1800                	addi	s0,sp,48
    800023b6:	89aa                	mv	s3,a0
    800023b8:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800023ba:	00019517          	auipc	a0,0x19
    800023be:	89e50513          	addi	a0,a0,-1890 # 8001ac58 <itable>
    800023c2:	29c030ef          	jal	ra,8000565e <acquire>
  empty = 0;
    800023c6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800023c8:	00019497          	auipc	s1,0x19
    800023cc:	8a848493          	addi	s1,s1,-1880 # 8001ac70 <itable+0x18>
    800023d0:	0001a697          	auipc	a3,0x1a
    800023d4:	33068693          	addi	a3,a3,816 # 8001c700 <log>
    800023d8:	a039                	j	800023e6 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800023da:	02090963          	beqz	s2,8000240c <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800023de:	08848493          	addi	s1,s1,136
    800023e2:	02d48863          	beq	s1,a3,80002412 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800023e6:	449c                	lw	a5,8(s1)
    800023e8:	fef059e3          	blez	a5,800023da <iget+0x34>
    800023ec:	4098                	lw	a4,0(s1)
    800023ee:	ff3716e3          	bne	a4,s3,800023da <iget+0x34>
    800023f2:	40d8                	lw	a4,4(s1)
    800023f4:	ff4713e3          	bne	a4,s4,800023da <iget+0x34>
      ip->ref++;
    800023f8:	2785                	addiw	a5,a5,1
    800023fa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800023fc:	00019517          	auipc	a0,0x19
    80002400:	85c50513          	addi	a0,a0,-1956 # 8001ac58 <itable>
    80002404:	2f2030ef          	jal	ra,800056f6 <release>
      return ip;
    80002408:	8926                	mv	s2,s1
    8000240a:	a02d                	j	80002434 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000240c:	fbe9                	bnez	a5,800023de <iget+0x38>
    8000240e:	8926                	mv	s2,s1
    80002410:	b7f9                	j	800023de <iget+0x38>
  if(empty == 0)
    80002412:	02090a63          	beqz	s2,80002446 <iget+0xa0>
  ip->dev = dev;
    80002416:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000241a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000241e:	4785                	li	a5,1
    80002420:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002424:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002428:	00019517          	auipc	a0,0x19
    8000242c:	83050513          	addi	a0,a0,-2000 # 8001ac58 <itable>
    80002430:	2c6030ef          	jal	ra,800056f6 <release>
}
    80002434:	854a                	mv	a0,s2
    80002436:	70a2                	ld	ra,40(sp)
    80002438:	7402                	ld	s0,32(sp)
    8000243a:	64e2                	ld	s1,24(sp)
    8000243c:	6942                	ld	s2,16(sp)
    8000243e:	69a2                	ld	s3,8(sp)
    80002440:	6a02                	ld	s4,0(sp)
    80002442:	6145                	addi	sp,sp,48
    80002444:	8082                	ret
    panic("iget: no inodes");
    80002446:	00005517          	auipc	a0,0x5
    8000244a:	11250513          	addi	a0,a0,274 # 80007558 <syscalls+0x140>
    8000244e:	6f5020ef          	jal	ra,80005342 <panic>

0000000080002452 <fsinit>:
fsinit(int dev) {
    80002452:	7179                	addi	sp,sp,-48
    80002454:	f406                	sd	ra,40(sp)
    80002456:	f022                	sd	s0,32(sp)
    80002458:	ec26                	sd	s1,24(sp)
    8000245a:	e84a                	sd	s2,16(sp)
    8000245c:	e44e                	sd	s3,8(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002462:	4585                	li	a1,1
    80002464:	afdff0ef          	jal	ra,80001f60 <bread>
    80002468:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000246a:	00018997          	auipc	s3,0x18
    8000246e:	7ce98993          	addi	s3,s3,1998 # 8001ac38 <sb>
    80002472:	02000613          	li	a2,32
    80002476:	05850593          	addi	a1,a0,88
    8000247a:	854e                	mv	a0,s3
    8000247c:	d31fd0ef          	jal	ra,800001ac <memmove>
  brelse(bp);
    80002480:	8526                	mv	a0,s1
    80002482:	be7ff0ef          	jal	ra,80002068 <brelse>
  if(sb.magic != FSMAGIC)
    80002486:	0009a703          	lw	a4,0(s3)
    8000248a:	102037b7          	lui	a5,0x10203
    8000248e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002492:	02f71063          	bne	a4,a5,800024b2 <fsinit+0x60>
  initlog(dev, &sb);
    80002496:	00018597          	auipc	a1,0x18
    8000249a:	7a258593          	addi	a1,a1,1954 # 8001ac38 <sb>
    8000249e:	854a                	mv	a0,s2
    800024a0:	1d9000ef          	jal	ra,80002e78 <initlog>
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6145                	addi	sp,sp,48
    800024b0:	8082                	ret
    panic("invalid file system");
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	0b650513          	addi	a0,a0,182 # 80007568 <syscalls+0x150>
    800024ba:	689020ef          	jal	ra,80005342 <panic>

00000000800024be <iinit>:
{
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800024cc:	00005597          	auipc	a1,0x5
    800024d0:	0b458593          	addi	a1,a1,180 # 80007580 <syscalls+0x168>
    800024d4:	00018517          	auipc	a0,0x18
    800024d8:	78450513          	addi	a0,a0,1924 # 8001ac58 <itable>
    800024dc:	102030ef          	jal	ra,800055de <initlock>
  for(i = 0; i < NINODE; i++) {
    800024e0:	00018497          	auipc	s1,0x18
    800024e4:	7a048493          	addi	s1,s1,1952 # 8001ac80 <itable+0x28>
    800024e8:	0001a997          	auipc	s3,0x1a
    800024ec:	22898993          	addi	s3,s3,552 # 8001c710 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800024f0:	00005917          	auipc	s2,0x5
    800024f4:	09890913          	addi	s2,s2,152 # 80007588 <syscalls+0x170>
    800024f8:	85ca                	mv	a1,s2
    800024fa:	8526                	mv	a0,s1
    800024fc:	463000ef          	jal	ra,8000315e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002500:	08848493          	addi	s1,s1,136
    80002504:	ff349ae3          	bne	s1,s3,800024f8 <iinit+0x3a>
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6145                	addi	sp,sp,48
    80002514:	8082                	ret

0000000080002516 <ialloc>:
{
    80002516:	715d                	addi	sp,sp,-80
    80002518:	e486                	sd	ra,72(sp)
    8000251a:	e0a2                	sd	s0,64(sp)
    8000251c:	fc26                	sd	s1,56(sp)
    8000251e:	f84a                	sd	s2,48(sp)
    80002520:	f44e                	sd	s3,40(sp)
    80002522:	f052                	sd	s4,32(sp)
    80002524:	ec56                	sd	s5,24(sp)
    80002526:	e85a                	sd	s6,16(sp)
    80002528:	e45e                	sd	s7,8(sp)
    8000252a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000252c:	00018717          	auipc	a4,0x18
    80002530:	71872703          	lw	a4,1816(a4) # 8001ac44 <sb+0xc>
    80002534:	4785                	li	a5,1
    80002536:	04e7f663          	bgeu	a5,a4,80002582 <ialloc+0x6c>
    8000253a:	8aaa                	mv	s5,a0
    8000253c:	8bae                	mv	s7,a1
    8000253e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002540:	00018a17          	auipc	s4,0x18
    80002544:	6f8a0a13          	addi	s4,s4,1784 # 8001ac38 <sb>
    80002548:	00048b1b          	sext.w	s6,s1
    8000254c:	0044d593          	srli	a1,s1,0x4
    80002550:	018a2783          	lw	a5,24(s4)
    80002554:	9dbd                	addw	a1,a1,a5
    80002556:	8556                	mv	a0,s5
    80002558:	a09ff0ef          	jal	ra,80001f60 <bread>
    8000255c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000255e:	05850993          	addi	s3,a0,88
    80002562:	00f4f793          	andi	a5,s1,15
    80002566:	079a                	slli	a5,a5,0x6
    80002568:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000256a:	00099783          	lh	a5,0(s3)
    8000256e:	cf85                	beqz	a5,800025a6 <ialloc+0x90>
    brelse(bp);
    80002570:	af9ff0ef          	jal	ra,80002068 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002574:	0485                	addi	s1,s1,1
    80002576:	00ca2703          	lw	a4,12(s4)
    8000257a:	0004879b          	sext.w	a5,s1
    8000257e:	fce7e5e3          	bltu	a5,a4,80002548 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002582:	00005517          	auipc	a0,0x5
    80002586:	00e50513          	addi	a0,a0,14 # 80007590 <syscalls+0x178>
    8000258a:	305020ef          	jal	ra,8000508e <printf>
  return 0;
    8000258e:	4501                	li	a0,0
}
    80002590:	60a6                	ld	ra,72(sp)
    80002592:	6406                	ld	s0,64(sp)
    80002594:	74e2                	ld	s1,56(sp)
    80002596:	7942                	ld	s2,48(sp)
    80002598:	79a2                	ld	s3,40(sp)
    8000259a:	7a02                	ld	s4,32(sp)
    8000259c:	6ae2                	ld	s5,24(sp)
    8000259e:	6b42                	ld	s6,16(sp)
    800025a0:	6ba2                	ld	s7,8(sp)
    800025a2:	6161                	addi	sp,sp,80
    800025a4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800025a6:	04000613          	li	a2,64
    800025aa:	4581                	li	a1,0
    800025ac:	854e                	mv	a0,s3
    800025ae:	b9ffd0ef          	jal	ra,8000014c <memset>
      dip->type = type;
    800025b2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800025b6:	854a                	mv	a0,s2
    800025b8:	2d5000ef          	jal	ra,8000308c <log_write>
      brelse(bp);
    800025bc:	854a                	mv	a0,s2
    800025be:	aabff0ef          	jal	ra,80002068 <brelse>
      return iget(dev, inum);
    800025c2:	85da                	mv	a1,s6
    800025c4:	8556                	mv	a0,s5
    800025c6:	de1ff0ef          	jal	ra,800023a6 <iget>
    800025ca:	b7d9                	j	80002590 <ialloc+0x7a>

00000000800025cc <iupdate>:
{
    800025cc:	1101                	addi	sp,sp,-32
    800025ce:	ec06                	sd	ra,24(sp)
    800025d0:	e822                	sd	s0,16(sp)
    800025d2:	e426                	sd	s1,8(sp)
    800025d4:	e04a                	sd	s2,0(sp)
    800025d6:	1000                	addi	s0,sp,32
    800025d8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800025da:	415c                	lw	a5,4(a0)
    800025dc:	0047d79b          	srliw	a5,a5,0x4
    800025e0:	00018597          	auipc	a1,0x18
    800025e4:	6705a583          	lw	a1,1648(a1) # 8001ac50 <sb+0x18>
    800025e8:	9dbd                	addw	a1,a1,a5
    800025ea:	4108                	lw	a0,0(a0)
    800025ec:	975ff0ef          	jal	ra,80001f60 <bread>
    800025f0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800025f2:	05850793          	addi	a5,a0,88
    800025f6:	40c8                	lw	a0,4(s1)
    800025f8:	893d                	andi	a0,a0,15
    800025fa:	051a                	slli	a0,a0,0x6
    800025fc:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800025fe:	04449703          	lh	a4,68(s1)
    80002602:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002606:	04649703          	lh	a4,70(s1)
    8000260a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000260e:	04849703          	lh	a4,72(s1)
    80002612:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002616:	04a49703          	lh	a4,74(s1)
    8000261a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000261e:	44f8                	lw	a4,76(s1)
    80002620:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002622:	03400613          	li	a2,52
    80002626:	05048593          	addi	a1,s1,80
    8000262a:	0531                	addi	a0,a0,12
    8000262c:	b81fd0ef          	jal	ra,800001ac <memmove>
  log_write(bp);
    80002630:	854a                	mv	a0,s2
    80002632:	25b000ef          	jal	ra,8000308c <log_write>
  brelse(bp);
    80002636:	854a                	mv	a0,s2
    80002638:	a31ff0ef          	jal	ra,80002068 <brelse>
}
    8000263c:	60e2                	ld	ra,24(sp)
    8000263e:	6442                	ld	s0,16(sp)
    80002640:	64a2                	ld	s1,8(sp)
    80002642:	6902                	ld	s2,0(sp)
    80002644:	6105                	addi	sp,sp,32
    80002646:	8082                	ret

0000000080002648 <idup>:
{
    80002648:	1101                	addi	sp,sp,-32
    8000264a:	ec06                	sd	ra,24(sp)
    8000264c:	e822                	sd	s0,16(sp)
    8000264e:	e426                	sd	s1,8(sp)
    80002650:	1000                	addi	s0,sp,32
    80002652:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002654:	00018517          	auipc	a0,0x18
    80002658:	60450513          	addi	a0,a0,1540 # 8001ac58 <itable>
    8000265c:	002030ef          	jal	ra,8000565e <acquire>
  ip->ref++;
    80002660:	449c                	lw	a5,8(s1)
    80002662:	2785                	addiw	a5,a5,1
    80002664:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002666:	00018517          	auipc	a0,0x18
    8000266a:	5f250513          	addi	a0,a0,1522 # 8001ac58 <itable>
    8000266e:	088030ef          	jal	ra,800056f6 <release>
}
    80002672:	8526                	mv	a0,s1
    80002674:	60e2                	ld	ra,24(sp)
    80002676:	6442                	ld	s0,16(sp)
    80002678:	64a2                	ld	s1,8(sp)
    8000267a:	6105                	addi	sp,sp,32
    8000267c:	8082                	ret

000000008000267e <ilock>:
{
    8000267e:	1101                	addi	sp,sp,-32
    80002680:	ec06                	sd	ra,24(sp)
    80002682:	e822                	sd	s0,16(sp)
    80002684:	e426                	sd	s1,8(sp)
    80002686:	e04a                	sd	s2,0(sp)
    80002688:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000268a:	c105                	beqz	a0,800026aa <ilock+0x2c>
    8000268c:	84aa                	mv	s1,a0
    8000268e:	451c                	lw	a5,8(a0)
    80002690:	00f05d63          	blez	a5,800026aa <ilock+0x2c>
  acquiresleep(&ip->lock);
    80002694:	0541                	addi	a0,a0,16
    80002696:	2ff000ef          	jal	ra,80003194 <acquiresleep>
  if(ip->valid == 0){
    8000269a:	40bc                	lw	a5,64(s1)
    8000269c:	cf89                	beqz	a5,800026b6 <ilock+0x38>
}
    8000269e:	60e2                	ld	ra,24(sp)
    800026a0:	6442                	ld	s0,16(sp)
    800026a2:	64a2                	ld	s1,8(sp)
    800026a4:	6902                	ld	s2,0(sp)
    800026a6:	6105                	addi	sp,sp,32
    800026a8:	8082                	ret
    panic("ilock");
    800026aa:	00005517          	auipc	a0,0x5
    800026ae:	efe50513          	addi	a0,a0,-258 # 800075a8 <syscalls+0x190>
    800026b2:	491020ef          	jal	ra,80005342 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800026b6:	40dc                	lw	a5,4(s1)
    800026b8:	0047d79b          	srliw	a5,a5,0x4
    800026bc:	00018597          	auipc	a1,0x18
    800026c0:	5945a583          	lw	a1,1428(a1) # 8001ac50 <sb+0x18>
    800026c4:	9dbd                	addw	a1,a1,a5
    800026c6:	4088                	lw	a0,0(s1)
    800026c8:	899ff0ef          	jal	ra,80001f60 <bread>
    800026cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800026ce:	05850593          	addi	a1,a0,88
    800026d2:	40dc                	lw	a5,4(s1)
    800026d4:	8bbd                	andi	a5,a5,15
    800026d6:	079a                	slli	a5,a5,0x6
    800026d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800026da:	00059783          	lh	a5,0(a1)
    800026de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800026e2:	00259783          	lh	a5,2(a1)
    800026e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800026ea:	00459783          	lh	a5,4(a1)
    800026ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800026f2:	00659783          	lh	a5,6(a1)
    800026f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800026fa:	459c                	lw	a5,8(a1)
    800026fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800026fe:	03400613          	li	a2,52
    80002702:	05b1                	addi	a1,a1,12
    80002704:	05048513          	addi	a0,s1,80
    80002708:	aa5fd0ef          	jal	ra,800001ac <memmove>
    brelse(bp);
    8000270c:	854a                	mv	a0,s2
    8000270e:	95bff0ef          	jal	ra,80002068 <brelse>
    ip->valid = 1;
    80002712:	4785                	li	a5,1
    80002714:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002716:	04449783          	lh	a5,68(s1)
    8000271a:	f3d1                	bnez	a5,8000269e <ilock+0x20>
      panic("ilock: no type");
    8000271c:	00005517          	auipc	a0,0x5
    80002720:	e9450513          	addi	a0,a0,-364 # 800075b0 <syscalls+0x198>
    80002724:	41f020ef          	jal	ra,80005342 <panic>

0000000080002728 <iunlock>:
{
    80002728:	1101                	addi	sp,sp,-32
    8000272a:	ec06                	sd	ra,24(sp)
    8000272c:	e822                	sd	s0,16(sp)
    8000272e:	e426                	sd	s1,8(sp)
    80002730:	e04a                	sd	s2,0(sp)
    80002732:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002734:	c505                	beqz	a0,8000275c <iunlock+0x34>
    80002736:	84aa                	mv	s1,a0
    80002738:	01050913          	addi	s2,a0,16
    8000273c:	854a                	mv	a0,s2
    8000273e:	2d5000ef          	jal	ra,80003212 <holdingsleep>
    80002742:	cd09                	beqz	a0,8000275c <iunlock+0x34>
    80002744:	449c                	lw	a5,8(s1)
    80002746:	00f05b63          	blez	a5,8000275c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000274a:	854a                	mv	a0,s2
    8000274c:	28f000ef          	jal	ra,800031da <releasesleep>
}
    80002750:	60e2                	ld	ra,24(sp)
    80002752:	6442                	ld	s0,16(sp)
    80002754:	64a2                	ld	s1,8(sp)
    80002756:	6902                	ld	s2,0(sp)
    80002758:	6105                	addi	sp,sp,32
    8000275a:	8082                	ret
    panic("iunlock");
    8000275c:	00005517          	auipc	a0,0x5
    80002760:	e6450513          	addi	a0,a0,-412 # 800075c0 <syscalls+0x1a8>
    80002764:	3df020ef          	jal	ra,80005342 <panic>

0000000080002768 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002768:	7179                	addi	sp,sp,-48
    8000276a:	f406                	sd	ra,40(sp)
    8000276c:	f022                	sd	s0,32(sp)
    8000276e:	ec26                	sd	s1,24(sp)
    80002770:	e84a                	sd	s2,16(sp)
    80002772:	e44e                	sd	s3,8(sp)
    80002774:	e052                	sd	s4,0(sp)
    80002776:	1800                	addi	s0,sp,48
    80002778:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000277a:	05050493          	addi	s1,a0,80
    8000277e:	08050913          	addi	s2,a0,128
    80002782:	a021                	j	8000278a <itrunc+0x22>
    80002784:	0491                	addi	s1,s1,4
    80002786:	01248b63          	beq	s1,s2,8000279c <itrunc+0x34>
    if(ip->addrs[i]){
    8000278a:	408c                	lw	a1,0(s1)
    8000278c:	dde5                	beqz	a1,80002784 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000278e:	0009a503          	lw	a0,0(s3)
    80002792:	9c9ff0ef          	jal	ra,8000215a <bfree>
      ip->addrs[i] = 0;
    80002796:	0004a023          	sw	zero,0(s1)
    8000279a:	b7ed                	j	80002784 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000279c:	0809a583          	lw	a1,128(s3)
    800027a0:	ed91                	bnez	a1,800027bc <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800027a2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800027a6:	854e                	mv	a0,s3
    800027a8:	e25ff0ef          	jal	ra,800025cc <iupdate>
}
    800027ac:	70a2                	ld	ra,40(sp)
    800027ae:	7402                	ld	s0,32(sp)
    800027b0:	64e2                	ld	s1,24(sp)
    800027b2:	6942                	ld	s2,16(sp)
    800027b4:	69a2                	ld	s3,8(sp)
    800027b6:	6a02                	ld	s4,0(sp)
    800027b8:	6145                	addi	sp,sp,48
    800027ba:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800027bc:	0009a503          	lw	a0,0(s3)
    800027c0:	fa0ff0ef          	jal	ra,80001f60 <bread>
    800027c4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800027c6:	05850493          	addi	s1,a0,88
    800027ca:	45850913          	addi	s2,a0,1112
    800027ce:	a801                	j	800027de <itrunc+0x76>
        bfree(ip->dev, a[j]);
    800027d0:	0009a503          	lw	a0,0(s3)
    800027d4:	987ff0ef          	jal	ra,8000215a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800027d8:	0491                	addi	s1,s1,4
    800027da:	01248563          	beq	s1,s2,800027e4 <itrunc+0x7c>
      if(a[j])
    800027de:	408c                	lw	a1,0(s1)
    800027e0:	dde5                	beqz	a1,800027d8 <itrunc+0x70>
    800027e2:	b7fd                	j	800027d0 <itrunc+0x68>
    brelse(bp);
    800027e4:	8552                	mv	a0,s4
    800027e6:	883ff0ef          	jal	ra,80002068 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800027ea:	0809a583          	lw	a1,128(s3)
    800027ee:	0009a503          	lw	a0,0(s3)
    800027f2:	969ff0ef          	jal	ra,8000215a <bfree>
    ip->addrs[NDIRECT] = 0;
    800027f6:	0809a023          	sw	zero,128(s3)
    800027fa:	b765                	j	800027a2 <itrunc+0x3a>

00000000800027fc <iput>:
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	e04a                	sd	s2,0(sp)
    80002806:	1000                	addi	s0,sp,32
    80002808:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000280a:	00018517          	auipc	a0,0x18
    8000280e:	44e50513          	addi	a0,a0,1102 # 8001ac58 <itable>
    80002812:	64d020ef          	jal	ra,8000565e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002816:	4498                	lw	a4,8(s1)
    80002818:	4785                	li	a5,1
    8000281a:	02f70163          	beq	a4,a5,8000283c <iput+0x40>
  ip->ref--;
    8000281e:	449c                	lw	a5,8(s1)
    80002820:	37fd                	addiw	a5,a5,-1
    80002822:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002824:	00018517          	auipc	a0,0x18
    80002828:	43450513          	addi	a0,a0,1076 # 8001ac58 <itable>
    8000282c:	6cb020ef          	jal	ra,800056f6 <release>
}
    80002830:	60e2                	ld	ra,24(sp)
    80002832:	6442                	ld	s0,16(sp)
    80002834:	64a2                	ld	s1,8(sp)
    80002836:	6902                	ld	s2,0(sp)
    80002838:	6105                	addi	sp,sp,32
    8000283a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000283c:	40bc                	lw	a5,64(s1)
    8000283e:	d3e5                	beqz	a5,8000281e <iput+0x22>
    80002840:	04a49783          	lh	a5,74(s1)
    80002844:	ffe9                	bnez	a5,8000281e <iput+0x22>
    acquiresleep(&ip->lock);
    80002846:	01048913          	addi	s2,s1,16
    8000284a:	854a                	mv	a0,s2
    8000284c:	149000ef          	jal	ra,80003194 <acquiresleep>
    release(&itable.lock);
    80002850:	00018517          	auipc	a0,0x18
    80002854:	40850513          	addi	a0,a0,1032 # 8001ac58 <itable>
    80002858:	69f020ef          	jal	ra,800056f6 <release>
    itrunc(ip);
    8000285c:	8526                	mv	a0,s1
    8000285e:	f0bff0ef          	jal	ra,80002768 <itrunc>
    ip->type = 0;
    80002862:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002866:	8526                	mv	a0,s1
    80002868:	d65ff0ef          	jal	ra,800025cc <iupdate>
    ip->valid = 0;
    8000286c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002870:	854a                	mv	a0,s2
    80002872:	169000ef          	jal	ra,800031da <releasesleep>
    acquire(&itable.lock);
    80002876:	00018517          	auipc	a0,0x18
    8000287a:	3e250513          	addi	a0,a0,994 # 8001ac58 <itable>
    8000287e:	5e1020ef          	jal	ra,8000565e <acquire>
    80002882:	bf71                	j	8000281e <iput+0x22>

0000000080002884 <iunlockput>:
{
    80002884:	1101                	addi	sp,sp,-32
    80002886:	ec06                	sd	ra,24(sp)
    80002888:	e822                	sd	s0,16(sp)
    8000288a:	e426                	sd	s1,8(sp)
    8000288c:	1000                	addi	s0,sp,32
    8000288e:	84aa                	mv	s1,a0
  iunlock(ip);
    80002890:	e99ff0ef          	jal	ra,80002728 <iunlock>
  iput(ip);
    80002894:	8526                	mv	a0,s1
    80002896:	f67ff0ef          	jal	ra,800027fc <iput>
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6105                	addi	sp,sp,32
    800028a2:	8082                	ret

00000000800028a4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800028a4:	1141                	addi	sp,sp,-16
    800028a6:	e422                	sd	s0,8(sp)
    800028a8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800028aa:	411c                	lw	a5,0(a0)
    800028ac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800028ae:	415c                	lw	a5,4(a0)
    800028b0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800028b2:	04451783          	lh	a5,68(a0)
    800028b6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800028ba:	04a51783          	lh	a5,74(a0)
    800028be:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800028c2:	04c56783          	lwu	a5,76(a0)
    800028c6:	e99c                	sd	a5,16(a1)
}
    800028c8:	6422                	ld	s0,8(sp)
    800028ca:	0141                	addi	sp,sp,16
    800028cc:	8082                	ret

00000000800028ce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800028ce:	457c                	lw	a5,76(a0)
    800028d0:	0cd7ef63          	bltu	a5,a3,800029ae <readi+0xe0>
{
    800028d4:	7159                	addi	sp,sp,-112
    800028d6:	f486                	sd	ra,104(sp)
    800028d8:	f0a2                	sd	s0,96(sp)
    800028da:	eca6                	sd	s1,88(sp)
    800028dc:	e8ca                	sd	s2,80(sp)
    800028de:	e4ce                	sd	s3,72(sp)
    800028e0:	e0d2                	sd	s4,64(sp)
    800028e2:	fc56                	sd	s5,56(sp)
    800028e4:	f85a                	sd	s6,48(sp)
    800028e6:	f45e                	sd	s7,40(sp)
    800028e8:	f062                	sd	s8,32(sp)
    800028ea:	ec66                	sd	s9,24(sp)
    800028ec:	e86a                	sd	s10,16(sp)
    800028ee:	e46e                	sd	s11,8(sp)
    800028f0:	1880                	addi	s0,sp,112
    800028f2:	8b2a                	mv	s6,a0
    800028f4:	8bae                	mv	s7,a1
    800028f6:	8a32                	mv	s4,a2
    800028f8:	84b6                	mv	s1,a3
    800028fa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800028fc:	9f35                	addw	a4,a4,a3
    return 0;
    800028fe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002900:	08d76663          	bltu	a4,a3,8000298c <readi+0xbe>
  if(off + n > ip->size)
    80002904:	00e7f463          	bgeu	a5,a4,8000290c <readi+0x3e>
    n = ip->size - off;
    80002908:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000290c:	080a8f63          	beqz	s5,800029aa <readi+0xdc>
    80002910:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002912:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002916:	5c7d                	li	s8,-1
    80002918:	a80d                	j	8000294a <readi+0x7c>
    8000291a:	020d1d93          	slli	s11,s10,0x20
    8000291e:	020ddd93          	srli	s11,s11,0x20
    80002922:	05890613          	addi	a2,s2,88
    80002926:	86ee                	mv	a3,s11
    80002928:	963a                	add	a2,a2,a4
    8000292a:	85d2                	mv	a1,s4
    8000292c:	855e                	mv	a0,s7
    8000292e:	d13fe0ef          	jal	ra,80001640 <either_copyout>
    80002932:	05850763          	beq	a0,s8,80002980 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002936:	854a                	mv	a0,s2
    80002938:	f30ff0ef          	jal	ra,80002068 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000293c:	013d09bb          	addw	s3,s10,s3
    80002940:	009d04bb          	addw	s1,s10,s1
    80002944:	9a6e                	add	s4,s4,s11
    80002946:	0559f163          	bgeu	s3,s5,80002988 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000294a:	00a4d59b          	srliw	a1,s1,0xa
    8000294e:	855a                	mv	a0,s6
    80002950:	98bff0ef          	jal	ra,800022da <bmap>
    80002954:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002958:	c985                	beqz	a1,80002988 <readi+0xba>
    bp = bread(ip->dev, addr);
    8000295a:	000b2503          	lw	a0,0(s6)
    8000295e:	e02ff0ef          	jal	ra,80001f60 <bread>
    80002962:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002964:	3ff4f713          	andi	a4,s1,1023
    80002968:	40ec87bb          	subw	a5,s9,a4
    8000296c:	413a86bb          	subw	a3,s5,s3
    80002970:	8d3e                	mv	s10,a5
    80002972:	2781                	sext.w	a5,a5
    80002974:	0006861b          	sext.w	a2,a3
    80002978:	faf671e3          	bgeu	a2,a5,8000291a <readi+0x4c>
    8000297c:	8d36                	mv	s10,a3
    8000297e:	bf71                	j	8000291a <readi+0x4c>
      brelse(bp);
    80002980:	854a                	mv	a0,s2
    80002982:	ee6ff0ef          	jal	ra,80002068 <brelse>
      tot = -1;
    80002986:	59fd                	li	s3,-1
  }
  return tot;
    80002988:	0009851b          	sext.w	a0,s3
}
    8000298c:	70a6                	ld	ra,104(sp)
    8000298e:	7406                	ld	s0,96(sp)
    80002990:	64e6                	ld	s1,88(sp)
    80002992:	6946                	ld	s2,80(sp)
    80002994:	69a6                	ld	s3,72(sp)
    80002996:	6a06                	ld	s4,64(sp)
    80002998:	7ae2                	ld	s5,56(sp)
    8000299a:	7b42                	ld	s6,48(sp)
    8000299c:	7ba2                	ld	s7,40(sp)
    8000299e:	7c02                	ld	s8,32(sp)
    800029a0:	6ce2                	ld	s9,24(sp)
    800029a2:	6d42                	ld	s10,16(sp)
    800029a4:	6da2                	ld	s11,8(sp)
    800029a6:	6165                	addi	sp,sp,112
    800029a8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800029aa:	89d6                	mv	s3,s5
    800029ac:	bff1                	j	80002988 <readi+0xba>
    return 0;
    800029ae:	4501                	li	a0,0
}
    800029b0:	8082                	ret

00000000800029b2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800029b2:	457c                	lw	a5,76(a0)
    800029b4:	0ed7ea63          	bltu	a5,a3,80002aa8 <writei+0xf6>
{
    800029b8:	7159                	addi	sp,sp,-112
    800029ba:	f486                	sd	ra,104(sp)
    800029bc:	f0a2                	sd	s0,96(sp)
    800029be:	eca6                	sd	s1,88(sp)
    800029c0:	e8ca                	sd	s2,80(sp)
    800029c2:	e4ce                	sd	s3,72(sp)
    800029c4:	e0d2                	sd	s4,64(sp)
    800029c6:	fc56                	sd	s5,56(sp)
    800029c8:	f85a                	sd	s6,48(sp)
    800029ca:	f45e                	sd	s7,40(sp)
    800029cc:	f062                	sd	s8,32(sp)
    800029ce:	ec66                	sd	s9,24(sp)
    800029d0:	e86a                	sd	s10,16(sp)
    800029d2:	e46e                	sd	s11,8(sp)
    800029d4:	1880                	addi	s0,sp,112
    800029d6:	8aaa                	mv	s5,a0
    800029d8:	8bae                	mv	s7,a1
    800029da:	8a32                	mv	s4,a2
    800029dc:	8936                	mv	s2,a3
    800029de:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800029e0:	00e687bb          	addw	a5,a3,a4
    800029e4:	0cd7e463          	bltu	a5,a3,80002aac <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800029e8:	00043737          	lui	a4,0x43
    800029ec:	0cf76263          	bltu	a4,a5,80002ab0 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800029f0:	0a0b0a63          	beqz	s6,80002aa4 <writei+0xf2>
    800029f4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800029f6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800029fa:	5c7d                	li	s8,-1
    800029fc:	a825                	j	80002a34 <writei+0x82>
    800029fe:	020d1d93          	slli	s11,s10,0x20
    80002a02:	020ddd93          	srli	s11,s11,0x20
    80002a06:	05848513          	addi	a0,s1,88
    80002a0a:	86ee                	mv	a3,s11
    80002a0c:	8652                	mv	a2,s4
    80002a0e:	85de                	mv	a1,s7
    80002a10:	953a                	add	a0,a0,a4
    80002a12:	c79fe0ef          	jal	ra,8000168a <either_copyin>
    80002a16:	05850a63          	beq	a0,s8,80002a6a <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	670000ef          	jal	ra,8000308c <log_write>
    brelse(bp);
    80002a20:	8526                	mv	a0,s1
    80002a22:	e46ff0ef          	jal	ra,80002068 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002a26:	013d09bb          	addw	s3,s10,s3
    80002a2a:	012d093b          	addw	s2,s10,s2
    80002a2e:	9a6e                	add	s4,s4,s11
    80002a30:	0569f063          	bgeu	s3,s6,80002a70 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002a34:	00a9559b          	srliw	a1,s2,0xa
    80002a38:	8556                	mv	a0,s5
    80002a3a:	8a1ff0ef          	jal	ra,800022da <bmap>
    80002a3e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002a42:	c59d                	beqz	a1,80002a70 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002a44:	000aa503          	lw	a0,0(s5)
    80002a48:	d18ff0ef          	jal	ra,80001f60 <bread>
    80002a4c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002a4e:	3ff97713          	andi	a4,s2,1023
    80002a52:	40ec87bb          	subw	a5,s9,a4
    80002a56:	413b06bb          	subw	a3,s6,s3
    80002a5a:	8d3e                	mv	s10,a5
    80002a5c:	2781                	sext.w	a5,a5
    80002a5e:	0006861b          	sext.w	a2,a3
    80002a62:	f8f67ee3          	bgeu	a2,a5,800029fe <writei+0x4c>
    80002a66:	8d36                	mv	s10,a3
    80002a68:	bf59                	j	800029fe <writei+0x4c>
      brelse(bp);
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	dfcff0ef          	jal	ra,80002068 <brelse>
  }

  if(off > ip->size)
    80002a70:	04caa783          	lw	a5,76(s5)
    80002a74:	0127f463          	bgeu	a5,s2,80002a7c <writei+0xca>
    ip->size = off;
    80002a78:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002a7c:	8556                	mv	a0,s5
    80002a7e:	b4fff0ef          	jal	ra,800025cc <iupdate>

  return tot;
    80002a82:	0009851b          	sext.w	a0,s3
}
    80002a86:	70a6                	ld	ra,104(sp)
    80002a88:	7406                	ld	s0,96(sp)
    80002a8a:	64e6                	ld	s1,88(sp)
    80002a8c:	6946                	ld	s2,80(sp)
    80002a8e:	69a6                	ld	s3,72(sp)
    80002a90:	6a06                	ld	s4,64(sp)
    80002a92:	7ae2                	ld	s5,56(sp)
    80002a94:	7b42                	ld	s6,48(sp)
    80002a96:	7ba2                	ld	s7,40(sp)
    80002a98:	7c02                	ld	s8,32(sp)
    80002a9a:	6ce2                	ld	s9,24(sp)
    80002a9c:	6d42                	ld	s10,16(sp)
    80002a9e:	6da2                	ld	s11,8(sp)
    80002aa0:	6165                	addi	sp,sp,112
    80002aa2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002aa4:	89da                	mv	s3,s6
    80002aa6:	bfd9                	j	80002a7c <writei+0xca>
    return -1;
    80002aa8:	557d                	li	a0,-1
}
    80002aaa:	8082                	ret
    return -1;
    80002aac:	557d                	li	a0,-1
    80002aae:	bfe1                	j	80002a86 <writei+0xd4>
    return -1;
    80002ab0:	557d                	li	a0,-1
    80002ab2:	bfd1                	j	80002a86 <writei+0xd4>

0000000080002ab4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002ab4:	1141                	addi	sp,sp,-16
    80002ab6:	e406                	sd	ra,8(sp)
    80002ab8:	e022                	sd	s0,0(sp)
    80002aba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002abc:	4639                	li	a2,14
    80002abe:	f62fd0ef          	jal	ra,80000220 <strncmp>
}
    80002ac2:	60a2                	ld	ra,8(sp)
    80002ac4:	6402                	ld	s0,0(sp)
    80002ac6:	0141                	addi	sp,sp,16
    80002ac8:	8082                	ret

0000000080002aca <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002aca:	7139                	addi	sp,sp,-64
    80002acc:	fc06                	sd	ra,56(sp)
    80002ace:	f822                	sd	s0,48(sp)
    80002ad0:	f426                	sd	s1,40(sp)
    80002ad2:	f04a                	sd	s2,32(sp)
    80002ad4:	ec4e                	sd	s3,24(sp)
    80002ad6:	e852                	sd	s4,16(sp)
    80002ad8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002ada:	04451703          	lh	a4,68(a0)
    80002ade:	4785                	li	a5,1
    80002ae0:	00f71a63          	bne	a4,a5,80002af4 <dirlookup+0x2a>
    80002ae4:	892a                	mv	s2,a0
    80002ae6:	89ae                	mv	s3,a1
    80002ae8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002aea:	457c                	lw	a5,76(a0)
    80002aec:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002aee:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002af0:	e39d                	bnez	a5,80002b16 <dirlookup+0x4c>
    80002af2:	a095                	j	80002b56 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002af4:	00005517          	auipc	a0,0x5
    80002af8:	ad450513          	addi	a0,a0,-1324 # 800075c8 <syscalls+0x1b0>
    80002afc:	047020ef          	jal	ra,80005342 <panic>
      panic("dirlookup read");
    80002b00:	00005517          	auipc	a0,0x5
    80002b04:	ae050513          	addi	a0,a0,-1312 # 800075e0 <syscalls+0x1c8>
    80002b08:	03b020ef          	jal	ra,80005342 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002b0c:	24c1                	addiw	s1,s1,16
    80002b0e:	04c92783          	lw	a5,76(s2)
    80002b12:	04f4f163          	bgeu	s1,a5,80002b54 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002b16:	4741                	li	a4,16
    80002b18:	86a6                	mv	a3,s1
    80002b1a:	fc040613          	addi	a2,s0,-64
    80002b1e:	4581                	li	a1,0
    80002b20:	854a                	mv	a0,s2
    80002b22:	dadff0ef          	jal	ra,800028ce <readi>
    80002b26:	47c1                	li	a5,16
    80002b28:	fcf51ce3          	bne	a0,a5,80002b00 <dirlookup+0x36>
    if(de.inum == 0)
    80002b2c:	fc045783          	lhu	a5,-64(s0)
    80002b30:	dff1                	beqz	a5,80002b0c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002b32:	fc240593          	addi	a1,s0,-62
    80002b36:	854e                	mv	a0,s3
    80002b38:	f7dff0ef          	jal	ra,80002ab4 <namecmp>
    80002b3c:	f961                	bnez	a0,80002b0c <dirlookup+0x42>
      if(poff)
    80002b3e:	000a0463          	beqz	s4,80002b46 <dirlookup+0x7c>
        *poff = off;
    80002b42:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002b46:	fc045583          	lhu	a1,-64(s0)
    80002b4a:	00092503          	lw	a0,0(s2)
    80002b4e:	859ff0ef          	jal	ra,800023a6 <iget>
    80002b52:	a011                	j	80002b56 <dirlookup+0x8c>
  return 0;
    80002b54:	4501                	li	a0,0
}
    80002b56:	70e2                	ld	ra,56(sp)
    80002b58:	7442                	ld	s0,48(sp)
    80002b5a:	74a2                	ld	s1,40(sp)
    80002b5c:	7902                	ld	s2,32(sp)
    80002b5e:	69e2                	ld	s3,24(sp)
    80002b60:	6a42                	ld	s4,16(sp)
    80002b62:	6121                	addi	sp,sp,64
    80002b64:	8082                	ret

0000000080002b66 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002b66:	711d                	addi	sp,sp,-96
    80002b68:	ec86                	sd	ra,88(sp)
    80002b6a:	e8a2                	sd	s0,80(sp)
    80002b6c:	e4a6                	sd	s1,72(sp)
    80002b6e:	e0ca                	sd	s2,64(sp)
    80002b70:	fc4e                	sd	s3,56(sp)
    80002b72:	f852                	sd	s4,48(sp)
    80002b74:	f456                	sd	s5,40(sp)
    80002b76:	f05a                	sd	s6,32(sp)
    80002b78:	ec5e                	sd	s7,24(sp)
    80002b7a:	e862                	sd	s8,16(sp)
    80002b7c:	e466                	sd	s9,8(sp)
    80002b7e:	1080                	addi	s0,sp,96
    80002b80:	84aa                	mv	s1,a0
    80002b82:	8b2e                	mv	s6,a1
    80002b84:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002b86:	00054703          	lbu	a4,0(a0)
    80002b8a:	02f00793          	li	a5,47
    80002b8e:	00f70f63          	beq	a4,a5,80002bac <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002b92:	97efe0ef          	jal	ra,80000d10 <myproc>
    80002b96:	15053503          	ld	a0,336(a0)
    80002b9a:	aafff0ef          	jal	ra,80002648 <idup>
    80002b9e:	89aa                	mv	s3,a0
  while(*path == '/')
    80002ba0:	02f00913          	li	s2,47
  len = path - s;
    80002ba4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80002ba6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002ba8:	4c05                	li	s8,1
    80002baa:	a861                	j	80002c42 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    80002bac:	4585                	li	a1,1
    80002bae:	4505                	li	a0,1
    80002bb0:	ff6ff0ef          	jal	ra,800023a6 <iget>
    80002bb4:	89aa                	mv	s3,a0
    80002bb6:	b7ed                	j	80002ba0 <namex+0x3a>
      iunlockput(ip);
    80002bb8:	854e                	mv	a0,s3
    80002bba:	ccbff0ef          	jal	ra,80002884 <iunlockput>
      return 0;
    80002bbe:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002bc0:	854e                	mv	a0,s3
    80002bc2:	60e6                	ld	ra,88(sp)
    80002bc4:	6446                	ld	s0,80(sp)
    80002bc6:	64a6                	ld	s1,72(sp)
    80002bc8:	6906                	ld	s2,64(sp)
    80002bca:	79e2                	ld	s3,56(sp)
    80002bcc:	7a42                	ld	s4,48(sp)
    80002bce:	7aa2                	ld	s5,40(sp)
    80002bd0:	7b02                	ld	s6,32(sp)
    80002bd2:	6be2                	ld	s7,24(sp)
    80002bd4:	6c42                	ld	s8,16(sp)
    80002bd6:	6ca2                	ld	s9,8(sp)
    80002bd8:	6125                	addi	sp,sp,96
    80002bda:	8082                	ret
      iunlock(ip);
    80002bdc:	854e                	mv	a0,s3
    80002bde:	b4bff0ef          	jal	ra,80002728 <iunlock>
      return ip;
    80002be2:	bff9                	j	80002bc0 <namex+0x5a>
      iunlockput(ip);
    80002be4:	854e                	mv	a0,s3
    80002be6:	c9fff0ef          	jal	ra,80002884 <iunlockput>
      return 0;
    80002bea:	89d2                	mv	s3,s4
    80002bec:	bfd1                	j	80002bc0 <namex+0x5a>
  len = path - s;
    80002bee:	40b48633          	sub	a2,s1,a1
    80002bf2:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80002bf6:	074cdc63          	bge	s9,s4,80002c6e <namex+0x108>
    memmove(name, s, DIRSIZ);
    80002bfa:	4639                	li	a2,14
    80002bfc:	8556                	mv	a0,s5
    80002bfe:	daefd0ef          	jal	ra,800001ac <memmove>
  while(*path == '/')
    80002c02:	0004c783          	lbu	a5,0(s1)
    80002c06:	01279763          	bne	a5,s2,80002c14 <namex+0xae>
    path++;
    80002c0a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002c0c:	0004c783          	lbu	a5,0(s1)
    80002c10:	ff278de3          	beq	a5,s2,80002c0a <namex+0xa4>
    ilock(ip);
    80002c14:	854e                	mv	a0,s3
    80002c16:	a69ff0ef          	jal	ra,8000267e <ilock>
    if(ip->type != T_DIR){
    80002c1a:	04499783          	lh	a5,68(s3)
    80002c1e:	f9879de3          	bne	a5,s8,80002bb8 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80002c22:	000b0563          	beqz	s6,80002c2c <namex+0xc6>
    80002c26:	0004c783          	lbu	a5,0(s1)
    80002c2a:	dbcd                	beqz	a5,80002bdc <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002c2c:	865e                	mv	a2,s7
    80002c2e:	85d6                	mv	a1,s5
    80002c30:	854e                	mv	a0,s3
    80002c32:	e99ff0ef          	jal	ra,80002aca <dirlookup>
    80002c36:	8a2a                	mv	s4,a0
    80002c38:	d555                	beqz	a0,80002be4 <namex+0x7e>
    iunlockput(ip);
    80002c3a:	854e                	mv	a0,s3
    80002c3c:	c49ff0ef          	jal	ra,80002884 <iunlockput>
    ip = next;
    80002c40:	89d2                	mv	s3,s4
  while(*path == '/')
    80002c42:	0004c783          	lbu	a5,0(s1)
    80002c46:	05279363          	bne	a5,s2,80002c8c <namex+0x126>
    path++;
    80002c4a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002c4c:	0004c783          	lbu	a5,0(s1)
    80002c50:	ff278de3          	beq	a5,s2,80002c4a <namex+0xe4>
  if(*path == 0)
    80002c54:	c78d                	beqz	a5,80002c7e <namex+0x118>
    path++;
    80002c56:	85a6                	mv	a1,s1
  len = path - s;
    80002c58:	8a5e                	mv	s4,s7
    80002c5a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80002c5c:	01278963          	beq	a5,s2,80002c6e <namex+0x108>
    80002c60:	d7d9                	beqz	a5,80002bee <namex+0x88>
    path++;
    80002c62:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80002c64:	0004c783          	lbu	a5,0(s1)
    80002c68:	ff279ce3          	bne	a5,s2,80002c60 <namex+0xfa>
    80002c6c:	b749                	j	80002bee <namex+0x88>
    memmove(name, s, len);
    80002c6e:	2601                	sext.w	a2,a2
    80002c70:	8556                	mv	a0,s5
    80002c72:	d3afd0ef          	jal	ra,800001ac <memmove>
    name[len] = 0;
    80002c76:	9a56                	add	s4,s4,s5
    80002c78:	000a0023          	sb	zero,0(s4)
    80002c7c:	b759                	j	80002c02 <namex+0x9c>
  if(nameiparent){
    80002c7e:	f40b01e3          	beqz	s6,80002bc0 <namex+0x5a>
    iput(ip);
    80002c82:	854e                	mv	a0,s3
    80002c84:	b79ff0ef          	jal	ra,800027fc <iput>
    return 0;
    80002c88:	4981                	li	s3,0
    80002c8a:	bf1d                	j	80002bc0 <namex+0x5a>
  if(*path == 0)
    80002c8c:	dbed                	beqz	a5,80002c7e <namex+0x118>
  while(*path != '/' && *path != 0)
    80002c8e:	0004c783          	lbu	a5,0(s1)
    80002c92:	85a6                	mv	a1,s1
    80002c94:	b7f1                	j	80002c60 <namex+0xfa>

0000000080002c96 <dirlink>:
{
    80002c96:	7139                	addi	sp,sp,-64
    80002c98:	fc06                	sd	ra,56(sp)
    80002c9a:	f822                	sd	s0,48(sp)
    80002c9c:	f426                	sd	s1,40(sp)
    80002c9e:	f04a                	sd	s2,32(sp)
    80002ca0:	ec4e                	sd	s3,24(sp)
    80002ca2:	e852                	sd	s4,16(sp)
    80002ca4:	0080                	addi	s0,sp,64
    80002ca6:	892a                	mv	s2,a0
    80002ca8:	8a2e                	mv	s4,a1
    80002caa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002cac:	4601                	li	a2,0
    80002cae:	e1dff0ef          	jal	ra,80002aca <dirlookup>
    80002cb2:	e52d                	bnez	a0,80002d1c <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cb4:	04c92483          	lw	s1,76(s2)
    80002cb8:	c48d                	beqz	s1,80002ce2 <dirlink+0x4c>
    80002cba:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002cbc:	4741                	li	a4,16
    80002cbe:	86a6                	mv	a3,s1
    80002cc0:	fc040613          	addi	a2,s0,-64
    80002cc4:	4581                	li	a1,0
    80002cc6:	854a                	mv	a0,s2
    80002cc8:	c07ff0ef          	jal	ra,800028ce <readi>
    80002ccc:	47c1                	li	a5,16
    80002cce:	04f51b63          	bne	a0,a5,80002d24 <dirlink+0x8e>
    if(de.inum == 0)
    80002cd2:	fc045783          	lhu	a5,-64(s0)
    80002cd6:	c791                	beqz	a5,80002ce2 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cd8:	24c1                	addiw	s1,s1,16
    80002cda:	04c92783          	lw	a5,76(s2)
    80002cde:	fcf4efe3          	bltu	s1,a5,80002cbc <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002ce2:	4639                	li	a2,14
    80002ce4:	85d2                	mv	a1,s4
    80002ce6:	fc240513          	addi	a0,s0,-62
    80002cea:	d72fd0ef          	jal	ra,8000025c <strncpy>
  de.inum = inum;
    80002cee:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002cf2:	4741                	li	a4,16
    80002cf4:	86a6                	mv	a3,s1
    80002cf6:	fc040613          	addi	a2,s0,-64
    80002cfa:	4581                	li	a1,0
    80002cfc:	854a                	mv	a0,s2
    80002cfe:	cb5ff0ef          	jal	ra,800029b2 <writei>
    80002d02:	1541                	addi	a0,a0,-16
    80002d04:	00a03533          	snez	a0,a0
    80002d08:	40a00533          	neg	a0,a0
}
    80002d0c:	70e2                	ld	ra,56(sp)
    80002d0e:	7442                	ld	s0,48(sp)
    80002d10:	74a2                	ld	s1,40(sp)
    80002d12:	7902                	ld	s2,32(sp)
    80002d14:	69e2                	ld	s3,24(sp)
    80002d16:	6a42                	ld	s4,16(sp)
    80002d18:	6121                	addi	sp,sp,64
    80002d1a:	8082                	ret
    iput(ip);
    80002d1c:	ae1ff0ef          	jal	ra,800027fc <iput>
    return -1;
    80002d20:	557d                	li	a0,-1
    80002d22:	b7ed                	j	80002d0c <dirlink+0x76>
      panic("dirlink read");
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	8cc50513          	addi	a0,a0,-1844 # 800075f0 <syscalls+0x1d8>
    80002d2c:	616020ef          	jal	ra,80005342 <panic>

0000000080002d30 <namei>:

struct inode*
namei(char *path)
{
    80002d30:	1101                	addi	sp,sp,-32
    80002d32:	ec06                	sd	ra,24(sp)
    80002d34:	e822                	sd	s0,16(sp)
    80002d36:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002d38:	fe040613          	addi	a2,s0,-32
    80002d3c:	4581                	li	a1,0
    80002d3e:	e29ff0ef          	jal	ra,80002b66 <namex>
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002d4a:	1141                	addi	sp,sp,-16
    80002d4c:	e406                	sd	ra,8(sp)
    80002d4e:	e022                	sd	s0,0(sp)
    80002d50:	0800                	addi	s0,sp,16
    80002d52:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002d54:	4585                	li	a1,1
    80002d56:	e11ff0ef          	jal	ra,80002b66 <namex>
}
    80002d5a:	60a2                	ld	ra,8(sp)
    80002d5c:	6402                	ld	s0,0(sp)
    80002d5e:	0141                	addi	sp,sp,16
    80002d60:	8082                	ret

0000000080002d62 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002d6e:	0001a917          	auipc	s2,0x1a
    80002d72:	99290913          	addi	s2,s2,-1646 # 8001c700 <log>
    80002d76:	01892583          	lw	a1,24(s2)
    80002d7a:	02892503          	lw	a0,40(s2)
    80002d7e:	9e2ff0ef          	jal	ra,80001f60 <bread>
    80002d82:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002d84:	02c92683          	lw	a3,44(s2)
    80002d88:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002d8a:	02d05763          	blez	a3,80002db8 <write_head+0x56>
    80002d8e:	0001a797          	auipc	a5,0x1a
    80002d92:	9a278793          	addi	a5,a5,-1630 # 8001c730 <log+0x30>
    80002d96:	05c50713          	addi	a4,a0,92
    80002d9a:	36fd                	addiw	a3,a3,-1
    80002d9c:	1682                	slli	a3,a3,0x20
    80002d9e:	9281                	srli	a3,a3,0x20
    80002da0:	068a                	slli	a3,a3,0x2
    80002da2:	0001a617          	auipc	a2,0x1a
    80002da6:	99260613          	addi	a2,a2,-1646 # 8001c734 <log+0x34>
    80002daa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80002dac:	4390                	lw	a2,0(a5)
    80002dae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80002db0:	0791                	addi	a5,a5,4
    80002db2:	0711                	addi	a4,a4,4
    80002db4:	fed79ce3          	bne	a5,a3,80002dac <write_head+0x4a>
  }
  bwrite(buf);
    80002db8:	8526                	mv	a0,s1
    80002dba:	a7cff0ef          	jal	ra,80002036 <bwrite>
  brelse(buf);
    80002dbe:	8526                	mv	a0,s1
    80002dc0:	aa8ff0ef          	jal	ra,80002068 <brelse>
}
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	64a2                	ld	s1,8(sp)
    80002dca:	6902                	ld	s2,0(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002dd0:	0001a797          	auipc	a5,0x1a
    80002dd4:	95c7a783          	lw	a5,-1700(a5) # 8001c72c <log+0x2c>
    80002dd8:	08f05f63          	blez	a5,80002e76 <install_trans+0xa6>
{
    80002ddc:	7139                	addi	sp,sp,-64
    80002dde:	fc06                	sd	ra,56(sp)
    80002de0:	f822                	sd	s0,48(sp)
    80002de2:	f426                	sd	s1,40(sp)
    80002de4:	f04a                	sd	s2,32(sp)
    80002de6:	ec4e                	sd	s3,24(sp)
    80002de8:	e852                	sd	s4,16(sp)
    80002dea:	e456                	sd	s5,8(sp)
    80002dec:	e05a                	sd	s6,0(sp)
    80002dee:	0080                	addi	s0,sp,64
    80002df0:	8b2a                	mv	s6,a0
    80002df2:	0001aa97          	auipc	s5,0x1a
    80002df6:	93ea8a93          	addi	s5,s5,-1730 # 8001c730 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002dfa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002dfc:	0001a997          	auipc	s3,0x1a
    80002e00:	90498993          	addi	s3,s3,-1788 # 8001c700 <log>
    80002e04:	a005                	j	80002e24 <install_trans+0x54>
      bunpin(dbuf);
    80002e06:	8526                	mv	a0,s1
    80002e08:	b1eff0ef          	jal	ra,80002126 <bunpin>
    brelse(lbuf);
    80002e0c:	854a                	mv	a0,s2
    80002e0e:	a5aff0ef          	jal	ra,80002068 <brelse>
    brelse(dbuf);
    80002e12:	8526                	mv	a0,s1
    80002e14:	a54ff0ef          	jal	ra,80002068 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002e18:	2a05                	addiw	s4,s4,1
    80002e1a:	0a91                	addi	s5,s5,4
    80002e1c:	02c9a783          	lw	a5,44(s3)
    80002e20:	04fa5163          	bge	s4,a5,80002e62 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002e24:	0189a583          	lw	a1,24(s3)
    80002e28:	014585bb          	addw	a1,a1,s4
    80002e2c:	2585                	addiw	a1,a1,1
    80002e2e:	0289a503          	lw	a0,40(s3)
    80002e32:	92eff0ef          	jal	ra,80001f60 <bread>
    80002e36:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002e38:	000aa583          	lw	a1,0(s5)
    80002e3c:	0289a503          	lw	a0,40(s3)
    80002e40:	920ff0ef          	jal	ra,80001f60 <bread>
    80002e44:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002e46:	40000613          	li	a2,1024
    80002e4a:	05890593          	addi	a1,s2,88
    80002e4e:	05850513          	addi	a0,a0,88
    80002e52:	b5afd0ef          	jal	ra,800001ac <memmove>
    bwrite(dbuf);  // write dst to disk
    80002e56:	8526                	mv	a0,s1
    80002e58:	9deff0ef          	jal	ra,80002036 <bwrite>
    if(recovering == 0)
    80002e5c:	fa0b18e3          	bnez	s6,80002e0c <install_trans+0x3c>
    80002e60:	b75d                	j	80002e06 <install_trans+0x36>
}
    80002e62:	70e2                	ld	ra,56(sp)
    80002e64:	7442                	ld	s0,48(sp)
    80002e66:	74a2                	ld	s1,40(sp)
    80002e68:	7902                	ld	s2,32(sp)
    80002e6a:	69e2                	ld	s3,24(sp)
    80002e6c:	6a42                	ld	s4,16(sp)
    80002e6e:	6aa2                	ld	s5,8(sp)
    80002e70:	6b02                	ld	s6,0(sp)
    80002e72:	6121                	addi	sp,sp,64
    80002e74:	8082                	ret
    80002e76:	8082                	ret

0000000080002e78 <initlog>:
{
    80002e78:	7179                	addi	sp,sp,-48
    80002e7a:	f406                	sd	ra,40(sp)
    80002e7c:	f022                	sd	s0,32(sp)
    80002e7e:	ec26                	sd	s1,24(sp)
    80002e80:	e84a                	sd	s2,16(sp)
    80002e82:	e44e                	sd	s3,8(sp)
    80002e84:	1800                	addi	s0,sp,48
    80002e86:	892a                	mv	s2,a0
    80002e88:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80002e8a:	0001a497          	auipc	s1,0x1a
    80002e8e:	87648493          	addi	s1,s1,-1930 # 8001c700 <log>
    80002e92:	00004597          	auipc	a1,0x4
    80002e96:	76e58593          	addi	a1,a1,1902 # 80007600 <syscalls+0x1e8>
    80002e9a:	8526                	mv	a0,s1
    80002e9c:	742020ef          	jal	ra,800055de <initlock>
  log.start = sb->logstart;
    80002ea0:	0149a583          	lw	a1,20(s3)
    80002ea4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80002ea6:	0109a783          	lw	a5,16(s3)
    80002eaa:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80002eac:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80002eb0:	854a                	mv	a0,s2
    80002eb2:	8aeff0ef          	jal	ra,80001f60 <bread>
  log.lh.n = lh->n;
    80002eb6:	4d3c                	lw	a5,88(a0)
    80002eb8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80002eba:	02f05563          	blez	a5,80002ee4 <initlog+0x6c>
    80002ebe:	05c50713          	addi	a4,a0,92
    80002ec2:	0001a697          	auipc	a3,0x1a
    80002ec6:	86e68693          	addi	a3,a3,-1938 # 8001c730 <log+0x30>
    80002eca:	37fd                	addiw	a5,a5,-1
    80002ecc:	1782                	slli	a5,a5,0x20
    80002ece:	9381                	srli	a5,a5,0x20
    80002ed0:	078a                	slli	a5,a5,0x2
    80002ed2:	06050613          	addi	a2,a0,96
    80002ed6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80002ed8:	4310                	lw	a2,0(a4)
    80002eda:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80002edc:	0711                	addi	a4,a4,4
    80002ede:	0691                	addi	a3,a3,4
    80002ee0:	fef71ce3          	bne	a4,a5,80002ed8 <initlog+0x60>
  brelse(buf);
    80002ee4:	984ff0ef          	jal	ra,80002068 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80002ee8:	4505                	li	a0,1
    80002eea:	ee7ff0ef          	jal	ra,80002dd0 <install_trans>
  log.lh.n = 0;
    80002eee:	0001a797          	auipc	a5,0x1a
    80002ef2:	8207af23          	sw	zero,-1986(a5) # 8001c72c <log+0x2c>
  write_head(); // clear the log
    80002ef6:	e6dff0ef          	jal	ra,80002d62 <write_head>
}
    80002efa:	70a2                	ld	ra,40(sp)
    80002efc:	7402                	ld	s0,32(sp)
    80002efe:	64e2                	ld	s1,24(sp)
    80002f00:	6942                	ld	s2,16(sp)
    80002f02:	69a2                	ld	s3,8(sp)
    80002f04:	6145                	addi	sp,sp,48
    80002f06:	8082                	ret

0000000080002f08 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80002f08:	1101                	addi	sp,sp,-32
    80002f0a:	ec06                	sd	ra,24(sp)
    80002f0c:	e822                	sd	s0,16(sp)
    80002f0e:	e426                	sd	s1,8(sp)
    80002f10:	e04a                	sd	s2,0(sp)
    80002f12:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80002f14:	00019517          	auipc	a0,0x19
    80002f18:	7ec50513          	addi	a0,a0,2028 # 8001c700 <log>
    80002f1c:	742020ef          	jal	ra,8000565e <acquire>
  while(1){
    if(log.committing){
    80002f20:	00019497          	auipc	s1,0x19
    80002f24:	7e048493          	addi	s1,s1,2016 # 8001c700 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002f28:	4979                	li	s2,30
    80002f2a:	a029                	j	80002f34 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80002f2c:	85a6                	mv	a1,s1
    80002f2e:	8526                	mv	a0,s1
    80002f30:	bb4fe0ef          	jal	ra,800012e4 <sleep>
    if(log.committing){
    80002f34:	50dc                	lw	a5,36(s1)
    80002f36:	fbfd                	bnez	a5,80002f2c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80002f38:	509c                	lw	a5,32(s1)
    80002f3a:	0017871b          	addiw	a4,a5,1
    80002f3e:	0007069b          	sext.w	a3,a4
    80002f42:	0027179b          	slliw	a5,a4,0x2
    80002f46:	9fb9                	addw	a5,a5,a4
    80002f48:	0017979b          	slliw	a5,a5,0x1
    80002f4c:	54d8                	lw	a4,44(s1)
    80002f4e:	9fb9                	addw	a5,a5,a4
    80002f50:	00f95763          	bge	s2,a5,80002f5e <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80002f54:	85a6                	mv	a1,s1
    80002f56:	8526                	mv	a0,s1
    80002f58:	b8cfe0ef          	jal	ra,800012e4 <sleep>
    80002f5c:	bfe1                	j	80002f34 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80002f5e:	00019517          	auipc	a0,0x19
    80002f62:	7a250513          	addi	a0,a0,1954 # 8001c700 <log>
    80002f66:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80002f68:	78e020ef          	jal	ra,800056f6 <release>
      break;
    }
  }
}
    80002f6c:	60e2                	ld	ra,24(sp)
    80002f6e:	6442                	ld	s0,16(sp)
    80002f70:	64a2                	ld	s1,8(sp)
    80002f72:	6902                	ld	s2,0(sp)
    80002f74:	6105                	addi	sp,sp,32
    80002f76:	8082                	ret

0000000080002f78 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80002f78:	7139                	addi	sp,sp,-64
    80002f7a:	fc06                	sd	ra,56(sp)
    80002f7c:	f822                	sd	s0,48(sp)
    80002f7e:	f426                	sd	s1,40(sp)
    80002f80:	f04a                	sd	s2,32(sp)
    80002f82:	ec4e                	sd	s3,24(sp)
    80002f84:	e852                	sd	s4,16(sp)
    80002f86:	e456                	sd	s5,8(sp)
    80002f88:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80002f8a:	00019497          	auipc	s1,0x19
    80002f8e:	77648493          	addi	s1,s1,1910 # 8001c700 <log>
    80002f92:	8526                	mv	a0,s1
    80002f94:	6ca020ef          	jal	ra,8000565e <acquire>
  log.outstanding -= 1;
    80002f98:	509c                	lw	a5,32(s1)
    80002f9a:	37fd                	addiw	a5,a5,-1
    80002f9c:	0007891b          	sext.w	s2,a5
    80002fa0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80002fa2:	50dc                	lw	a5,36(s1)
    80002fa4:	e7b9                	bnez	a5,80002ff2 <end_op+0x7a>
    panic("log.committing");
  if(log.outstanding == 0){
    80002fa6:	04091c63          	bnez	s2,80002ffe <end_op+0x86>
    do_commit = 1;
    log.committing = 1;
    80002faa:	00019497          	auipc	s1,0x19
    80002fae:	75648493          	addi	s1,s1,1878 # 8001c700 <log>
    80002fb2:	4785                	li	a5,1
    80002fb4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	73e020ef          	jal	ra,800056f6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80002fbc:	54dc                	lw	a5,44(s1)
    80002fbe:	04f04b63          	bgtz	a5,80003014 <end_op+0x9c>
    acquire(&log.lock);
    80002fc2:	00019497          	auipc	s1,0x19
    80002fc6:	73e48493          	addi	s1,s1,1854 # 8001c700 <log>
    80002fca:	8526                	mv	a0,s1
    80002fcc:	692020ef          	jal	ra,8000565e <acquire>
    log.committing = 0;
    80002fd0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80002fd4:	8526                	mv	a0,s1
    80002fd6:	b5afe0ef          	jal	ra,80001330 <wakeup>
    release(&log.lock);
    80002fda:	8526                	mv	a0,s1
    80002fdc:	71a020ef          	jal	ra,800056f6 <release>
}
    80002fe0:	70e2                	ld	ra,56(sp)
    80002fe2:	7442                	ld	s0,48(sp)
    80002fe4:	74a2                	ld	s1,40(sp)
    80002fe6:	7902                	ld	s2,32(sp)
    80002fe8:	69e2                	ld	s3,24(sp)
    80002fea:	6a42                	ld	s4,16(sp)
    80002fec:	6aa2                	ld	s5,8(sp)
    80002fee:	6121                	addi	sp,sp,64
    80002ff0:	8082                	ret
    panic("log.committing");
    80002ff2:	00004517          	auipc	a0,0x4
    80002ff6:	61650513          	addi	a0,a0,1558 # 80007608 <syscalls+0x1f0>
    80002ffa:	348020ef          	jal	ra,80005342 <panic>
    wakeup(&log);
    80002ffe:	00019497          	auipc	s1,0x19
    80003002:	70248493          	addi	s1,s1,1794 # 8001c700 <log>
    80003006:	8526                	mv	a0,s1
    80003008:	b28fe0ef          	jal	ra,80001330 <wakeup>
  release(&log.lock);
    8000300c:	8526                	mv	a0,s1
    8000300e:	6e8020ef          	jal	ra,800056f6 <release>
  if(do_commit){
    80003012:	b7f9                	j	80002fe0 <end_op+0x68>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003014:	00019a97          	auipc	s5,0x19
    80003018:	71ca8a93          	addi	s5,s5,1820 # 8001c730 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000301c:	00019a17          	auipc	s4,0x19
    80003020:	6e4a0a13          	addi	s4,s4,1764 # 8001c700 <log>
    80003024:	018a2583          	lw	a1,24(s4)
    80003028:	012585bb          	addw	a1,a1,s2
    8000302c:	2585                	addiw	a1,a1,1
    8000302e:	028a2503          	lw	a0,40(s4)
    80003032:	f2ffe0ef          	jal	ra,80001f60 <bread>
    80003036:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003038:	000aa583          	lw	a1,0(s5)
    8000303c:	028a2503          	lw	a0,40(s4)
    80003040:	f21fe0ef          	jal	ra,80001f60 <bread>
    80003044:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003046:	40000613          	li	a2,1024
    8000304a:	05850593          	addi	a1,a0,88
    8000304e:	05848513          	addi	a0,s1,88
    80003052:	95afd0ef          	jal	ra,800001ac <memmove>
    bwrite(to);  // write the log
    80003056:	8526                	mv	a0,s1
    80003058:	fdffe0ef          	jal	ra,80002036 <bwrite>
    brelse(from);
    8000305c:	854e                	mv	a0,s3
    8000305e:	80aff0ef          	jal	ra,80002068 <brelse>
    brelse(to);
    80003062:	8526                	mv	a0,s1
    80003064:	804ff0ef          	jal	ra,80002068 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003068:	2905                	addiw	s2,s2,1
    8000306a:	0a91                	addi	s5,s5,4
    8000306c:	02ca2783          	lw	a5,44(s4)
    80003070:	faf94ae3          	blt	s2,a5,80003024 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003074:	cefff0ef          	jal	ra,80002d62 <write_head>
    install_trans(0); // Now install writes to home locations
    80003078:	4501                	li	a0,0
    8000307a:	d57ff0ef          	jal	ra,80002dd0 <install_trans>
    log.lh.n = 0;
    8000307e:	00019797          	auipc	a5,0x19
    80003082:	6a07a723          	sw	zero,1710(a5) # 8001c72c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003086:	cddff0ef          	jal	ra,80002d62 <write_head>
    8000308a:	bf25                	j	80002fc2 <end_op+0x4a>

000000008000308c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	e04a                	sd	s2,0(sp)
    80003096:	1000                	addi	s0,sp,32
    80003098:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000309a:	00019917          	auipc	s2,0x19
    8000309e:	66690913          	addi	s2,s2,1638 # 8001c700 <log>
    800030a2:	854a                	mv	a0,s2
    800030a4:	5ba020ef          	jal	ra,8000565e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800030a8:	02c92603          	lw	a2,44(s2)
    800030ac:	47f5                	li	a5,29
    800030ae:	06c7c363          	blt	a5,a2,80003114 <log_write+0x88>
    800030b2:	00019797          	auipc	a5,0x19
    800030b6:	66a7a783          	lw	a5,1642(a5) # 8001c71c <log+0x1c>
    800030ba:	37fd                	addiw	a5,a5,-1
    800030bc:	04f65c63          	bge	a2,a5,80003114 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800030c0:	00019797          	auipc	a5,0x19
    800030c4:	6607a783          	lw	a5,1632(a5) # 8001c720 <log+0x20>
    800030c8:	04f05c63          	blez	a5,80003120 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800030cc:	4781                	li	a5,0
    800030ce:	04c05f63          	blez	a2,8000312c <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800030d2:	44cc                	lw	a1,12(s1)
    800030d4:	00019717          	auipc	a4,0x19
    800030d8:	65c70713          	addi	a4,a4,1628 # 8001c730 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800030dc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800030de:	4314                	lw	a3,0(a4)
    800030e0:	04b68663          	beq	a3,a1,8000312c <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    800030e4:	2785                	addiw	a5,a5,1
    800030e6:	0711                	addi	a4,a4,4
    800030e8:	fef61be3          	bne	a2,a5,800030de <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    800030ec:	0621                	addi	a2,a2,8
    800030ee:	060a                	slli	a2,a2,0x2
    800030f0:	00019797          	auipc	a5,0x19
    800030f4:	61078793          	addi	a5,a5,1552 # 8001c700 <log>
    800030f8:	963e                	add	a2,a2,a5
    800030fa:	44dc                	lw	a5,12(s1)
    800030fc:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800030fe:	8526                	mv	a0,s1
    80003100:	ff3fe0ef          	jal	ra,800020f2 <bpin>
    log.lh.n++;
    80003104:	00019717          	auipc	a4,0x19
    80003108:	5fc70713          	addi	a4,a4,1532 # 8001c700 <log>
    8000310c:	575c                	lw	a5,44(a4)
    8000310e:	2785                	addiw	a5,a5,1
    80003110:	d75c                	sw	a5,44(a4)
    80003112:	a815                	j	80003146 <log_write+0xba>
    panic("too big a transaction");
    80003114:	00004517          	auipc	a0,0x4
    80003118:	50450513          	addi	a0,a0,1284 # 80007618 <syscalls+0x200>
    8000311c:	226020ef          	jal	ra,80005342 <panic>
    panic("log_write outside of trans");
    80003120:	00004517          	auipc	a0,0x4
    80003124:	51050513          	addi	a0,a0,1296 # 80007630 <syscalls+0x218>
    80003128:	21a020ef          	jal	ra,80005342 <panic>
  log.lh.block[i] = b->blockno;
    8000312c:	00878713          	addi	a4,a5,8
    80003130:	00271693          	slli	a3,a4,0x2
    80003134:	00019717          	auipc	a4,0x19
    80003138:	5cc70713          	addi	a4,a4,1484 # 8001c700 <log>
    8000313c:	9736                	add	a4,a4,a3
    8000313e:	44d4                	lw	a3,12(s1)
    80003140:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003142:	faf60ee3          	beq	a2,a5,800030fe <log_write+0x72>
  }
  release(&log.lock);
    80003146:	00019517          	auipc	a0,0x19
    8000314a:	5ba50513          	addi	a0,a0,1466 # 8001c700 <log>
    8000314e:	5a8020ef          	jal	ra,800056f6 <release>
}
    80003152:	60e2                	ld	ra,24(sp)
    80003154:	6442                	ld	s0,16(sp)
    80003156:	64a2                	ld	s1,8(sp)
    80003158:	6902                	ld	s2,0(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret

000000008000315e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	e04a                	sd	s2,0(sp)
    80003168:	1000                	addi	s0,sp,32
    8000316a:	84aa                	mv	s1,a0
    8000316c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000316e:	00004597          	auipc	a1,0x4
    80003172:	4e258593          	addi	a1,a1,1250 # 80007650 <syscalls+0x238>
    80003176:	0521                	addi	a0,a0,8
    80003178:	466020ef          	jal	ra,800055de <initlock>
  lk->name = name;
    8000317c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003180:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003184:	0204a423          	sw	zero,40(s1)
}
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	64a2                	ld	s1,8(sp)
    8000318e:	6902                	ld	s2,0(sp)
    80003190:	6105                	addi	sp,sp,32
    80003192:	8082                	ret

0000000080003194 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003194:	1101                	addi	sp,sp,-32
    80003196:	ec06                	sd	ra,24(sp)
    80003198:	e822                	sd	s0,16(sp)
    8000319a:	e426                	sd	s1,8(sp)
    8000319c:	e04a                	sd	s2,0(sp)
    8000319e:	1000                	addi	s0,sp,32
    800031a0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800031a2:	00850913          	addi	s2,a0,8
    800031a6:	854a                	mv	a0,s2
    800031a8:	4b6020ef          	jal	ra,8000565e <acquire>
  while (lk->locked) {
    800031ac:	409c                	lw	a5,0(s1)
    800031ae:	c799                	beqz	a5,800031bc <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800031b0:	85ca                	mv	a1,s2
    800031b2:	8526                	mv	a0,s1
    800031b4:	930fe0ef          	jal	ra,800012e4 <sleep>
  while (lk->locked) {
    800031b8:	409c                	lw	a5,0(s1)
    800031ba:	fbfd                	bnez	a5,800031b0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800031bc:	4785                	li	a5,1
    800031be:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800031c0:	b51fd0ef          	jal	ra,80000d10 <myproc>
    800031c4:	591c                	lw	a5,48(a0)
    800031c6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800031c8:	854a                	mv	a0,s2
    800031ca:	52c020ef          	jal	ra,800056f6 <release>
}
    800031ce:	60e2                	ld	ra,24(sp)
    800031d0:	6442                	ld	s0,16(sp)
    800031d2:	64a2                	ld	s1,8(sp)
    800031d4:	6902                	ld	s2,0(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret

00000000800031da <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	e04a                	sd	s2,0(sp)
    800031e4:	1000                	addi	s0,sp,32
    800031e6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800031e8:	00850913          	addi	s2,a0,8
    800031ec:	854a                	mv	a0,s2
    800031ee:	470020ef          	jal	ra,8000565e <acquire>
  lk->locked = 0;
    800031f2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800031f6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800031fa:	8526                	mv	a0,s1
    800031fc:	934fe0ef          	jal	ra,80001330 <wakeup>
  release(&lk->lk);
    80003200:	854a                	mv	a0,s2
    80003202:	4f4020ef          	jal	ra,800056f6 <release>
}
    80003206:	60e2                	ld	ra,24(sp)
    80003208:	6442                	ld	s0,16(sp)
    8000320a:	64a2                	ld	s1,8(sp)
    8000320c:	6902                	ld	s2,0(sp)
    8000320e:	6105                	addi	sp,sp,32
    80003210:	8082                	ret

0000000080003212 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003212:	7179                	addi	sp,sp,-48
    80003214:	f406                	sd	ra,40(sp)
    80003216:	f022                	sd	s0,32(sp)
    80003218:	ec26                	sd	s1,24(sp)
    8000321a:	e84a                	sd	s2,16(sp)
    8000321c:	e44e                	sd	s3,8(sp)
    8000321e:	1800                	addi	s0,sp,48
    80003220:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003222:	00850913          	addi	s2,a0,8
    80003226:	854a                	mv	a0,s2
    80003228:	436020ef          	jal	ra,8000565e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000322c:	409c                	lw	a5,0(s1)
    8000322e:	ef89                	bnez	a5,80003248 <holdingsleep+0x36>
    80003230:	4481                	li	s1,0
  release(&lk->lk);
    80003232:	854a                	mv	a0,s2
    80003234:	4c2020ef          	jal	ra,800056f6 <release>
  return r;
}
    80003238:	8526                	mv	a0,s1
    8000323a:	70a2                	ld	ra,40(sp)
    8000323c:	7402                	ld	s0,32(sp)
    8000323e:	64e2                	ld	s1,24(sp)
    80003240:	6942                	ld	s2,16(sp)
    80003242:	69a2                	ld	s3,8(sp)
    80003244:	6145                	addi	sp,sp,48
    80003246:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003248:	0284a983          	lw	s3,40(s1)
    8000324c:	ac5fd0ef          	jal	ra,80000d10 <myproc>
    80003250:	5904                	lw	s1,48(a0)
    80003252:	413484b3          	sub	s1,s1,s3
    80003256:	0014b493          	seqz	s1,s1
    8000325a:	bfe1                	j	80003232 <holdingsleep+0x20>

000000008000325c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000325c:	1141                	addi	sp,sp,-16
    8000325e:	e406                	sd	ra,8(sp)
    80003260:	e022                	sd	s0,0(sp)
    80003262:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003264:	00004597          	auipc	a1,0x4
    80003268:	3fc58593          	addi	a1,a1,1020 # 80007660 <syscalls+0x248>
    8000326c:	00019517          	auipc	a0,0x19
    80003270:	5dc50513          	addi	a0,a0,1500 # 8001c848 <ftable>
    80003274:	36a020ef          	jal	ra,800055de <initlock>
}
    80003278:	60a2                	ld	ra,8(sp)
    8000327a:	6402                	ld	s0,0(sp)
    8000327c:	0141                	addi	sp,sp,16
    8000327e:	8082                	ret

0000000080003280 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003280:	1101                	addi	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	e426                	sd	s1,8(sp)
    80003288:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000328a:	00019517          	auipc	a0,0x19
    8000328e:	5be50513          	addi	a0,a0,1470 # 8001c848 <ftable>
    80003292:	3cc020ef          	jal	ra,8000565e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003296:	00019497          	auipc	s1,0x19
    8000329a:	5ca48493          	addi	s1,s1,1482 # 8001c860 <ftable+0x18>
    8000329e:	0001a717          	auipc	a4,0x1a
    800032a2:	56270713          	addi	a4,a4,1378 # 8001d800 <disk>
    if(f->ref == 0){
    800032a6:	40dc                	lw	a5,4(s1)
    800032a8:	cf89                	beqz	a5,800032c2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800032aa:	02848493          	addi	s1,s1,40
    800032ae:	fee49ce3          	bne	s1,a4,800032a6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800032b2:	00019517          	auipc	a0,0x19
    800032b6:	59650513          	addi	a0,a0,1430 # 8001c848 <ftable>
    800032ba:	43c020ef          	jal	ra,800056f6 <release>
  return 0;
    800032be:	4481                	li	s1,0
    800032c0:	a809                	j	800032d2 <filealloc+0x52>
      f->ref = 1;
    800032c2:	4785                	li	a5,1
    800032c4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800032c6:	00019517          	auipc	a0,0x19
    800032ca:	58250513          	addi	a0,a0,1410 # 8001c848 <ftable>
    800032ce:	428020ef          	jal	ra,800056f6 <release>
}
    800032d2:	8526                	mv	a0,s1
    800032d4:	60e2                	ld	ra,24(sp)
    800032d6:	6442                	ld	s0,16(sp)
    800032d8:	64a2                	ld	s1,8(sp)
    800032da:	6105                	addi	sp,sp,32
    800032dc:	8082                	ret

00000000800032de <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800032de:	1101                	addi	sp,sp,-32
    800032e0:	ec06                	sd	ra,24(sp)
    800032e2:	e822                	sd	s0,16(sp)
    800032e4:	e426                	sd	s1,8(sp)
    800032e6:	1000                	addi	s0,sp,32
    800032e8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800032ea:	00019517          	auipc	a0,0x19
    800032ee:	55e50513          	addi	a0,a0,1374 # 8001c848 <ftable>
    800032f2:	36c020ef          	jal	ra,8000565e <acquire>
  if(f->ref < 1)
    800032f6:	40dc                	lw	a5,4(s1)
    800032f8:	02f05063          	blez	a5,80003318 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800032fc:	2785                	addiw	a5,a5,1
    800032fe:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003300:	00019517          	auipc	a0,0x19
    80003304:	54850513          	addi	a0,a0,1352 # 8001c848 <ftable>
    80003308:	3ee020ef          	jal	ra,800056f6 <release>
  return f;
}
    8000330c:	8526                	mv	a0,s1
    8000330e:	60e2                	ld	ra,24(sp)
    80003310:	6442                	ld	s0,16(sp)
    80003312:	64a2                	ld	s1,8(sp)
    80003314:	6105                	addi	sp,sp,32
    80003316:	8082                	ret
    panic("filedup");
    80003318:	00004517          	auipc	a0,0x4
    8000331c:	35050513          	addi	a0,a0,848 # 80007668 <syscalls+0x250>
    80003320:	022020ef          	jal	ra,80005342 <panic>

0000000080003324 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003324:	7139                	addi	sp,sp,-64
    80003326:	fc06                	sd	ra,56(sp)
    80003328:	f822                	sd	s0,48(sp)
    8000332a:	f426                	sd	s1,40(sp)
    8000332c:	f04a                	sd	s2,32(sp)
    8000332e:	ec4e                	sd	s3,24(sp)
    80003330:	e852                	sd	s4,16(sp)
    80003332:	e456                	sd	s5,8(sp)
    80003334:	0080                	addi	s0,sp,64
    80003336:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003338:	00019517          	auipc	a0,0x19
    8000333c:	51050513          	addi	a0,a0,1296 # 8001c848 <ftable>
    80003340:	31e020ef          	jal	ra,8000565e <acquire>
  if(f->ref < 1)
    80003344:	40dc                	lw	a5,4(s1)
    80003346:	04f05963          	blez	a5,80003398 <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    8000334a:	37fd                	addiw	a5,a5,-1
    8000334c:	0007871b          	sext.w	a4,a5
    80003350:	c0dc                	sw	a5,4(s1)
    80003352:	04e04963          	bgtz	a4,800033a4 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003356:	0004a903          	lw	s2,0(s1)
    8000335a:	0094ca83          	lbu	s5,9(s1)
    8000335e:	0104ba03          	ld	s4,16(s1)
    80003362:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003366:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000336a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000336e:	00019517          	auipc	a0,0x19
    80003372:	4da50513          	addi	a0,a0,1242 # 8001c848 <ftable>
    80003376:	380020ef          	jal	ra,800056f6 <release>

  if(ff.type == FD_PIPE){
    8000337a:	4785                	li	a5,1
    8000337c:	04f90363          	beq	s2,a5,800033c2 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003380:	3979                	addiw	s2,s2,-2
    80003382:	4785                	li	a5,1
    80003384:	0327e663          	bltu	a5,s2,800033b0 <fileclose+0x8c>
    begin_op();
    80003388:	b81ff0ef          	jal	ra,80002f08 <begin_op>
    iput(ff.ip);
    8000338c:	854e                	mv	a0,s3
    8000338e:	c6eff0ef          	jal	ra,800027fc <iput>
    end_op();
    80003392:	be7ff0ef          	jal	ra,80002f78 <end_op>
    80003396:	a829                	j	800033b0 <fileclose+0x8c>
    panic("fileclose");
    80003398:	00004517          	auipc	a0,0x4
    8000339c:	2d850513          	addi	a0,a0,728 # 80007670 <syscalls+0x258>
    800033a0:	7a3010ef          	jal	ra,80005342 <panic>
    release(&ftable.lock);
    800033a4:	00019517          	auipc	a0,0x19
    800033a8:	4a450513          	addi	a0,a0,1188 # 8001c848 <ftable>
    800033ac:	34a020ef          	jal	ra,800056f6 <release>
  }
}
    800033b0:	70e2                	ld	ra,56(sp)
    800033b2:	7442                	ld	s0,48(sp)
    800033b4:	74a2                	ld	s1,40(sp)
    800033b6:	7902                	ld	s2,32(sp)
    800033b8:	69e2                	ld	s3,24(sp)
    800033ba:	6a42                	ld	s4,16(sp)
    800033bc:	6aa2                	ld	s5,8(sp)
    800033be:	6121                	addi	sp,sp,64
    800033c0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800033c2:	85d6                	mv	a1,s5
    800033c4:	8552                	mv	a0,s4
    800033c6:	2ec000ef          	jal	ra,800036b2 <pipeclose>
    800033ca:	b7dd                	j	800033b0 <fileclose+0x8c>

00000000800033cc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800033cc:	715d                	addi	sp,sp,-80
    800033ce:	e486                	sd	ra,72(sp)
    800033d0:	e0a2                	sd	s0,64(sp)
    800033d2:	fc26                	sd	s1,56(sp)
    800033d4:	f84a                	sd	s2,48(sp)
    800033d6:	f44e                	sd	s3,40(sp)
    800033d8:	0880                	addi	s0,sp,80
    800033da:	84aa                	mv	s1,a0
    800033dc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800033de:	933fd0ef          	jal	ra,80000d10 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800033e2:	409c                	lw	a5,0(s1)
    800033e4:	37f9                	addiw	a5,a5,-2
    800033e6:	4705                	li	a4,1
    800033e8:	02f76f63          	bltu	a4,a5,80003426 <filestat+0x5a>
    800033ec:	892a                	mv	s2,a0
    ilock(f->ip);
    800033ee:	6c88                	ld	a0,24(s1)
    800033f0:	a8eff0ef          	jal	ra,8000267e <ilock>
    stati(f->ip, &st);
    800033f4:	fb840593          	addi	a1,s0,-72
    800033f8:	6c88                	ld	a0,24(s1)
    800033fa:	caaff0ef          	jal	ra,800028a4 <stati>
    iunlock(f->ip);
    800033fe:	6c88                	ld	a0,24(s1)
    80003400:	b28ff0ef          	jal	ra,80002728 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003404:	46e1                	li	a3,24
    80003406:	fb840613          	addi	a2,s0,-72
    8000340a:	85ce                	mv	a1,s3
    8000340c:	05093503          	ld	a0,80(s2)
    80003410:	db6fd0ef          	jal	ra,800009c6 <copyout>
    80003414:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003418:	60a6                	ld	ra,72(sp)
    8000341a:	6406                	ld	s0,64(sp)
    8000341c:	74e2                	ld	s1,56(sp)
    8000341e:	7942                	ld	s2,48(sp)
    80003420:	79a2                	ld	s3,40(sp)
    80003422:	6161                	addi	sp,sp,80
    80003424:	8082                	ret
  return -1;
    80003426:	557d                	li	a0,-1
    80003428:	bfc5                	j	80003418 <filestat+0x4c>

000000008000342a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000342a:	7179                	addi	sp,sp,-48
    8000342c:	f406                	sd	ra,40(sp)
    8000342e:	f022                	sd	s0,32(sp)
    80003430:	ec26                	sd	s1,24(sp)
    80003432:	e84a                	sd	s2,16(sp)
    80003434:	e44e                	sd	s3,8(sp)
    80003436:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003438:	00854783          	lbu	a5,8(a0)
    8000343c:	cbc1                	beqz	a5,800034cc <fileread+0xa2>
    8000343e:	84aa                	mv	s1,a0
    80003440:	89ae                	mv	s3,a1
    80003442:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003444:	411c                	lw	a5,0(a0)
    80003446:	4705                	li	a4,1
    80003448:	04e78363          	beq	a5,a4,8000348e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000344c:	470d                	li	a4,3
    8000344e:	04e78563          	beq	a5,a4,80003498 <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003452:	4709                	li	a4,2
    80003454:	06e79663          	bne	a5,a4,800034c0 <fileread+0x96>
    ilock(f->ip);
    80003458:	6d08                	ld	a0,24(a0)
    8000345a:	a24ff0ef          	jal	ra,8000267e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000345e:	874a                	mv	a4,s2
    80003460:	5094                	lw	a3,32(s1)
    80003462:	864e                	mv	a2,s3
    80003464:	4585                	li	a1,1
    80003466:	6c88                	ld	a0,24(s1)
    80003468:	c66ff0ef          	jal	ra,800028ce <readi>
    8000346c:	892a                	mv	s2,a0
    8000346e:	00a05563          	blez	a0,80003478 <fileread+0x4e>
      f->off += r;
    80003472:	509c                	lw	a5,32(s1)
    80003474:	9fa9                	addw	a5,a5,a0
    80003476:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003478:	6c88                	ld	a0,24(s1)
    8000347a:	aaeff0ef          	jal	ra,80002728 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000347e:	854a                	mv	a0,s2
    80003480:	70a2                	ld	ra,40(sp)
    80003482:	7402                	ld	s0,32(sp)
    80003484:	64e2                	ld	s1,24(sp)
    80003486:	6942                	ld	s2,16(sp)
    80003488:	69a2                	ld	s3,8(sp)
    8000348a:	6145                	addi	sp,sp,48
    8000348c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000348e:	6908                	ld	a0,16(a0)
    80003490:	356000ef          	jal	ra,800037e6 <piperead>
    80003494:	892a                	mv	s2,a0
    80003496:	b7e5                	j	8000347e <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003498:	02451783          	lh	a5,36(a0)
    8000349c:	03079693          	slli	a3,a5,0x30
    800034a0:	92c1                	srli	a3,a3,0x30
    800034a2:	4725                	li	a4,9
    800034a4:	02d76663          	bltu	a4,a3,800034d0 <fileread+0xa6>
    800034a8:	0792                	slli	a5,a5,0x4
    800034aa:	00019717          	auipc	a4,0x19
    800034ae:	2fe70713          	addi	a4,a4,766 # 8001c7a8 <devsw>
    800034b2:	97ba                	add	a5,a5,a4
    800034b4:	639c                	ld	a5,0(a5)
    800034b6:	cf99                	beqz	a5,800034d4 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800034b8:	4505                	li	a0,1
    800034ba:	9782                	jalr	a5
    800034bc:	892a                	mv	s2,a0
    800034be:	b7c1                	j	8000347e <fileread+0x54>
    panic("fileread");
    800034c0:	00004517          	auipc	a0,0x4
    800034c4:	1c050513          	addi	a0,a0,448 # 80007680 <syscalls+0x268>
    800034c8:	67b010ef          	jal	ra,80005342 <panic>
    return -1;
    800034cc:	597d                	li	s2,-1
    800034ce:	bf45                	j	8000347e <fileread+0x54>
      return -1;
    800034d0:	597d                	li	s2,-1
    800034d2:	b775                	j	8000347e <fileread+0x54>
    800034d4:	597d                	li	s2,-1
    800034d6:	b765                	j	8000347e <fileread+0x54>

00000000800034d8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800034d8:	715d                	addi	sp,sp,-80
    800034da:	e486                	sd	ra,72(sp)
    800034dc:	e0a2                	sd	s0,64(sp)
    800034de:	fc26                	sd	s1,56(sp)
    800034e0:	f84a                	sd	s2,48(sp)
    800034e2:	f44e                	sd	s3,40(sp)
    800034e4:	f052                	sd	s4,32(sp)
    800034e6:	ec56                	sd	s5,24(sp)
    800034e8:	e85a                	sd	s6,16(sp)
    800034ea:	e45e                	sd	s7,8(sp)
    800034ec:	e062                	sd	s8,0(sp)
    800034ee:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800034f0:	00954783          	lbu	a5,9(a0)
    800034f4:	0e078863          	beqz	a5,800035e4 <filewrite+0x10c>
    800034f8:	892a                	mv	s2,a0
    800034fa:	8aae                	mv	s5,a1
    800034fc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800034fe:	411c                	lw	a5,0(a0)
    80003500:	4705                	li	a4,1
    80003502:	02e78263          	beq	a5,a4,80003526 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003506:	470d                	li	a4,3
    80003508:	02e78463          	beq	a5,a4,80003530 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000350c:	4709                	li	a4,2
    8000350e:	0ce79563          	bne	a5,a4,800035d8 <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003512:	0ac05163          	blez	a2,800035b4 <filewrite+0xdc>
    int i = 0;
    80003516:	4981                	li	s3,0
    80003518:	6b05                	lui	s6,0x1
    8000351a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    8000351e:	6b85                	lui	s7,0x1
    80003520:	c00b8b9b          	addiw	s7,s7,-1024
    80003524:	a041                	j	800035a4 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80003526:	6908                	ld	a0,16(a0)
    80003528:	1e2000ef          	jal	ra,8000370a <pipewrite>
    8000352c:	8a2a                	mv	s4,a0
    8000352e:	a071                	j	800035ba <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003530:	02451783          	lh	a5,36(a0)
    80003534:	03079693          	slli	a3,a5,0x30
    80003538:	92c1                	srli	a3,a3,0x30
    8000353a:	4725                	li	a4,9
    8000353c:	0ad76663          	bltu	a4,a3,800035e8 <filewrite+0x110>
    80003540:	0792                	slli	a5,a5,0x4
    80003542:	00019717          	auipc	a4,0x19
    80003546:	26670713          	addi	a4,a4,614 # 8001c7a8 <devsw>
    8000354a:	97ba                	add	a5,a5,a4
    8000354c:	679c                	ld	a5,8(a5)
    8000354e:	cfd9                	beqz	a5,800035ec <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80003550:	4505                	li	a0,1
    80003552:	9782                	jalr	a5
    80003554:	8a2a                	mv	s4,a0
    80003556:	a095                	j	800035ba <filewrite+0xe2>
    80003558:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000355c:	9adff0ef          	jal	ra,80002f08 <begin_op>
      ilock(f->ip);
    80003560:	01893503          	ld	a0,24(s2)
    80003564:	91aff0ef          	jal	ra,8000267e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003568:	8762                	mv	a4,s8
    8000356a:	02092683          	lw	a3,32(s2)
    8000356e:	01598633          	add	a2,s3,s5
    80003572:	4585                	li	a1,1
    80003574:	01893503          	ld	a0,24(s2)
    80003578:	c3aff0ef          	jal	ra,800029b2 <writei>
    8000357c:	84aa                	mv	s1,a0
    8000357e:	00a05763          	blez	a0,8000358c <filewrite+0xb4>
        f->off += r;
    80003582:	02092783          	lw	a5,32(s2)
    80003586:	9fa9                	addw	a5,a5,a0
    80003588:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000358c:	01893503          	ld	a0,24(s2)
    80003590:	998ff0ef          	jal	ra,80002728 <iunlock>
      end_op();
    80003594:	9e5ff0ef          	jal	ra,80002f78 <end_op>

      if(r != n1){
    80003598:	009c1f63          	bne	s8,s1,800035b6 <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    8000359c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800035a0:	0149db63          	bge	s3,s4,800035b6 <filewrite+0xde>
      int n1 = n - i;
    800035a4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800035a8:	84be                	mv	s1,a5
    800035aa:	2781                	sext.w	a5,a5
    800035ac:	fafb56e3          	bge	s6,a5,80003558 <filewrite+0x80>
    800035b0:	84de                	mv	s1,s7
    800035b2:	b75d                	j	80003558 <filewrite+0x80>
    int i = 0;
    800035b4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800035b6:	013a1f63          	bne	s4,s3,800035d4 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800035ba:	8552                	mv	a0,s4
    800035bc:	60a6                	ld	ra,72(sp)
    800035be:	6406                	ld	s0,64(sp)
    800035c0:	74e2                	ld	s1,56(sp)
    800035c2:	7942                	ld	s2,48(sp)
    800035c4:	79a2                	ld	s3,40(sp)
    800035c6:	7a02                	ld	s4,32(sp)
    800035c8:	6ae2                	ld	s5,24(sp)
    800035ca:	6b42                	ld	s6,16(sp)
    800035cc:	6ba2                	ld	s7,8(sp)
    800035ce:	6c02                	ld	s8,0(sp)
    800035d0:	6161                	addi	sp,sp,80
    800035d2:	8082                	ret
    ret = (i == n ? n : -1);
    800035d4:	5a7d                	li	s4,-1
    800035d6:	b7d5                	j	800035ba <filewrite+0xe2>
    panic("filewrite");
    800035d8:	00004517          	auipc	a0,0x4
    800035dc:	0b850513          	addi	a0,a0,184 # 80007690 <syscalls+0x278>
    800035e0:	563010ef          	jal	ra,80005342 <panic>
    return -1;
    800035e4:	5a7d                	li	s4,-1
    800035e6:	bfd1                	j	800035ba <filewrite+0xe2>
      return -1;
    800035e8:	5a7d                	li	s4,-1
    800035ea:	bfc1                	j	800035ba <filewrite+0xe2>
    800035ec:	5a7d                	li	s4,-1
    800035ee:	b7f1                	j	800035ba <filewrite+0xe2>

00000000800035f0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800035f0:	7179                	addi	sp,sp,-48
    800035f2:	f406                	sd	ra,40(sp)
    800035f4:	f022                	sd	s0,32(sp)
    800035f6:	ec26                	sd	s1,24(sp)
    800035f8:	e84a                	sd	s2,16(sp)
    800035fa:	e44e                	sd	s3,8(sp)
    800035fc:	e052                	sd	s4,0(sp)
    800035fe:	1800                	addi	s0,sp,48
    80003600:	84aa                	mv	s1,a0
    80003602:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003604:	0005b023          	sd	zero,0(a1)
    80003608:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000360c:	c75ff0ef          	jal	ra,80003280 <filealloc>
    80003610:	e088                	sd	a0,0(s1)
    80003612:	cd35                	beqz	a0,8000368e <pipealloc+0x9e>
    80003614:	c6dff0ef          	jal	ra,80003280 <filealloc>
    80003618:	00aa3023          	sd	a0,0(s4)
    8000361c:	c52d                	beqz	a0,80003686 <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000361e:	adffc0ef          	jal	ra,800000fc <kalloc>
    80003622:	892a                	mv	s2,a0
    80003624:	cd31                	beqz	a0,80003680 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    80003626:	4985                	li	s3,1
    80003628:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000362c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003630:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003634:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003638:	00004597          	auipc	a1,0x4
    8000363c:	06858593          	addi	a1,a1,104 # 800076a0 <syscalls+0x288>
    80003640:	79f010ef          	jal	ra,800055de <initlock>
  (*f0)->type = FD_PIPE;
    80003644:	609c                	ld	a5,0(s1)
    80003646:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000364a:	609c                	ld	a5,0(s1)
    8000364c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003650:	609c                	ld	a5,0(s1)
    80003652:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003656:	609c                	ld	a5,0(s1)
    80003658:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000365c:	000a3783          	ld	a5,0(s4)
    80003660:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003664:	000a3783          	ld	a5,0(s4)
    80003668:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000366c:	000a3783          	ld	a5,0(s4)
    80003670:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003674:	000a3783          	ld	a5,0(s4)
    80003678:	0127b823          	sd	s2,16(a5)
  return 0;
    8000367c:	4501                	li	a0,0
    8000367e:	a005                	j	8000369e <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003680:	6088                	ld	a0,0(s1)
    80003682:	e501                	bnez	a0,8000368a <pipealloc+0x9a>
    80003684:	a029                	j	8000368e <pipealloc+0x9e>
    80003686:	6088                	ld	a0,0(s1)
    80003688:	c11d                	beqz	a0,800036ae <pipealloc+0xbe>
    fileclose(*f0);
    8000368a:	c9bff0ef          	jal	ra,80003324 <fileclose>
  if(*f1)
    8000368e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003692:	557d                	li	a0,-1
  if(*f1)
    80003694:	c789                	beqz	a5,8000369e <pipealloc+0xae>
    fileclose(*f1);
    80003696:	853e                	mv	a0,a5
    80003698:	c8dff0ef          	jal	ra,80003324 <fileclose>
  return -1;
    8000369c:	557d                	li	a0,-1
}
    8000369e:	70a2                	ld	ra,40(sp)
    800036a0:	7402                	ld	s0,32(sp)
    800036a2:	64e2                	ld	s1,24(sp)
    800036a4:	6942                	ld	s2,16(sp)
    800036a6:	69a2                	ld	s3,8(sp)
    800036a8:	6a02                	ld	s4,0(sp)
    800036aa:	6145                	addi	sp,sp,48
    800036ac:	8082                	ret
  return -1;
    800036ae:	557d                	li	a0,-1
    800036b0:	b7fd                	j	8000369e <pipealloc+0xae>

00000000800036b2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800036b2:	1101                	addi	sp,sp,-32
    800036b4:	ec06                	sd	ra,24(sp)
    800036b6:	e822                	sd	s0,16(sp)
    800036b8:	e426                	sd	s1,8(sp)
    800036ba:	e04a                	sd	s2,0(sp)
    800036bc:	1000                	addi	s0,sp,32
    800036be:	84aa                	mv	s1,a0
    800036c0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800036c2:	79d010ef          	jal	ra,8000565e <acquire>
  if(writable){
    800036c6:	02090763          	beqz	s2,800036f4 <pipeclose+0x42>
    pi->writeopen = 0;
    800036ca:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800036ce:	21848513          	addi	a0,s1,536
    800036d2:	c5ffd0ef          	jal	ra,80001330 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800036d6:	2204b783          	ld	a5,544(s1)
    800036da:	e785                	bnez	a5,80003702 <pipeclose+0x50>
    release(&pi->lock);
    800036dc:	8526                	mv	a0,s1
    800036de:	018020ef          	jal	ra,800056f6 <release>
    kfree((char*)pi);
    800036e2:	8526                	mv	a0,s1
    800036e4:	939fc0ef          	jal	ra,8000001c <kfree>
  } else
    release(&pi->lock);
}
    800036e8:	60e2                	ld	ra,24(sp)
    800036ea:	6442                	ld	s0,16(sp)
    800036ec:	64a2                	ld	s1,8(sp)
    800036ee:	6902                	ld	s2,0(sp)
    800036f0:	6105                	addi	sp,sp,32
    800036f2:	8082                	ret
    pi->readopen = 0;
    800036f4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800036f8:	21c48513          	addi	a0,s1,540
    800036fc:	c35fd0ef          	jal	ra,80001330 <wakeup>
    80003700:	bfd9                	j	800036d6 <pipeclose+0x24>
    release(&pi->lock);
    80003702:	8526                	mv	a0,s1
    80003704:	7f3010ef          	jal	ra,800056f6 <release>
}
    80003708:	b7c5                	j	800036e8 <pipeclose+0x36>

000000008000370a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000370a:	7159                	addi	sp,sp,-112
    8000370c:	f486                	sd	ra,104(sp)
    8000370e:	f0a2                	sd	s0,96(sp)
    80003710:	eca6                	sd	s1,88(sp)
    80003712:	e8ca                	sd	s2,80(sp)
    80003714:	e4ce                	sd	s3,72(sp)
    80003716:	e0d2                	sd	s4,64(sp)
    80003718:	fc56                	sd	s5,56(sp)
    8000371a:	f85a                	sd	s6,48(sp)
    8000371c:	f45e                	sd	s7,40(sp)
    8000371e:	f062                	sd	s8,32(sp)
    80003720:	ec66                	sd	s9,24(sp)
    80003722:	1880                	addi	s0,sp,112
    80003724:	84aa                	mv	s1,a0
    80003726:	8aae                	mv	s5,a1
    80003728:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000372a:	de6fd0ef          	jal	ra,80000d10 <myproc>
    8000372e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003730:	8526                	mv	a0,s1
    80003732:	72d010ef          	jal	ra,8000565e <acquire>
  while(i < n){
    80003736:	0b405663          	blez	s4,800037e2 <pipewrite+0xd8>
    8000373a:	8ba6                	mv	s7,s1
  int i = 0;
    8000373c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000373e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003740:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003744:	21c48c13          	addi	s8,s1,540
    80003748:	a899                	j	8000379e <pipewrite+0x94>
      release(&pi->lock);
    8000374a:	8526                	mv	a0,s1
    8000374c:	7ab010ef          	jal	ra,800056f6 <release>
      return -1;
    80003750:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003752:	854a                	mv	a0,s2
    80003754:	70a6                	ld	ra,104(sp)
    80003756:	7406                	ld	s0,96(sp)
    80003758:	64e6                	ld	s1,88(sp)
    8000375a:	6946                	ld	s2,80(sp)
    8000375c:	69a6                	ld	s3,72(sp)
    8000375e:	6a06                	ld	s4,64(sp)
    80003760:	7ae2                	ld	s5,56(sp)
    80003762:	7b42                	ld	s6,48(sp)
    80003764:	7ba2                	ld	s7,40(sp)
    80003766:	7c02                	ld	s8,32(sp)
    80003768:	6ce2                	ld	s9,24(sp)
    8000376a:	6165                	addi	sp,sp,112
    8000376c:	8082                	ret
      wakeup(&pi->nread);
    8000376e:	8566                	mv	a0,s9
    80003770:	bc1fd0ef          	jal	ra,80001330 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003774:	85de                	mv	a1,s7
    80003776:	8562                	mv	a0,s8
    80003778:	b6dfd0ef          	jal	ra,800012e4 <sleep>
    8000377c:	a839                	j	8000379a <pipewrite+0x90>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000377e:	21c4a783          	lw	a5,540(s1)
    80003782:	0017871b          	addiw	a4,a5,1
    80003786:	20e4ae23          	sw	a4,540(s1)
    8000378a:	1ff7f793          	andi	a5,a5,511
    8000378e:	97a6                	add	a5,a5,s1
    80003790:	f9f44703          	lbu	a4,-97(s0)
    80003794:	00e78c23          	sb	a4,24(a5)
      i++;
    80003798:	2905                	addiw	s2,s2,1
  while(i < n){
    8000379a:	03495c63          	bge	s2,s4,800037d2 <pipewrite+0xc8>
    if(pi->readopen == 0 || killed(pr)){
    8000379e:	2204a783          	lw	a5,544(s1)
    800037a2:	d7c5                	beqz	a5,8000374a <pipewrite+0x40>
    800037a4:	854e                	mv	a0,s3
    800037a6:	d77fd0ef          	jal	ra,8000151c <killed>
    800037aa:	f145                	bnez	a0,8000374a <pipewrite+0x40>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800037ac:	2184a783          	lw	a5,536(s1)
    800037b0:	21c4a703          	lw	a4,540(s1)
    800037b4:	2007879b          	addiw	a5,a5,512
    800037b8:	faf70be3          	beq	a4,a5,8000376e <pipewrite+0x64>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800037bc:	4685                	li	a3,1
    800037be:	01590633          	add	a2,s2,s5
    800037c2:	f9f40593          	addi	a1,s0,-97
    800037c6:	0509b503          	ld	a0,80(s3)
    800037ca:	ab4fd0ef          	jal	ra,80000a7e <copyin>
    800037ce:	fb6518e3          	bne	a0,s6,8000377e <pipewrite+0x74>
  wakeup(&pi->nread);
    800037d2:	21848513          	addi	a0,s1,536
    800037d6:	b5bfd0ef          	jal	ra,80001330 <wakeup>
  release(&pi->lock);
    800037da:	8526                	mv	a0,s1
    800037dc:	71b010ef          	jal	ra,800056f6 <release>
  return i;
    800037e0:	bf8d                	j	80003752 <pipewrite+0x48>
  int i = 0;
    800037e2:	4901                	li	s2,0
    800037e4:	b7fd                	j	800037d2 <pipewrite+0xc8>

00000000800037e6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800037e6:	715d                	addi	sp,sp,-80
    800037e8:	e486                	sd	ra,72(sp)
    800037ea:	e0a2                	sd	s0,64(sp)
    800037ec:	fc26                	sd	s1,56(sp)
    800037ee:	f84a                	sd	s2,48(sp)
    800037f0:	f44e                	sd	s3,40(sp)
    800037f2:	f052                	sd	s4,32(sp)
    800037f4:	ec56                	sd	s5,24(sp)
    800037f6:	e85a                	sd	s6,16(sp)
    800037f8:	0880                	addi	s0,sp,80
    800037fa:	84aa                	mv	s1,a0
    800037fc:	892e                	mv	s2,a1
    800037fe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003800:	d10fd0ef          	jal	ra,80000d10 <myproc>
    80003804:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003806:	8b26                	mv	s6,s1
    80003808:	8526                	mv	a0,s1
    8000380a:	655010ef          	jal	ra,8000565e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000380e:	2184a703          	lw	a4,536(s1)
    80003812:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003816:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000381a:	02f71363          	bne	a4,a5,80003840 <piperead+0x5a>
    8000381e:	2244a783          	lw	a5,548(s1)
    80003822:	cf99                	beqz	a5,80003840 <piperead+0x5a>
    if(killed(pr)){
    80003824:	8552                	mv	a0,s4
    80003826:	cf7fd0ef          	jal	ra,8000151c <killed>
    8000382a:	e141                	bnez	a0,800038aa <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000382c:	85da                	mv	a1,s6
    8000382e:	854e                	mv	a0,s3
    80003830:	ab5fd0ef          	jal	ra,800012e4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003834:	2184a703          	lw	a4,536(s1)
    80003838:	21c4a783          	lw	a5,540(s1)
    8000383c:	fef701e3          	beq	a4,a5,8000381e <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003840:	07505a63          	blez	s5,800038b4 <piperead+0xce>
    80003844:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003846:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80003848:	2184a783          	lw	a5,536(s1)
    8000384c:	21c4a703          	lw	a4,540(s1)
    80003850:	02f70b63          	beq	a4,a5,80003886 <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003854:	0017871b          	addiw	a4,a5,1
    80003858:	20e4ac23          	sw	a4,536(s1)
    8000385c:	1ff7f793          	andi	a5,a5,511
    80003860:	97a6                	add	a5,a5,s1
    80003862:	0187c783          	lbu	a5,24(a5)
    80003866:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000386a:	4685                	li	a3,1
    8000386c:	fbf40613          	addi	a2,s0,-65
    80003870:	85ca                	mv	a1,s2
    80003872:	050a3503          	ld	a0,80(s4)
    80003876:	950fd0ef          	jal	ra,800009c6 <copyout>
    8000387a:	01650663          	beq	a0,s6,80003886 <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000387e:	2985                	addiw	s3,s3,1
    80003880:	0905                	addi	s2,s2,1
    80003882:	fd3a93e3          	bne	s5,s3,80003848 <piperead+0x62>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003886:	21c48513          	addi	a0,s1,540
    8000388a:	aa7fd0ef          	jal	ra,80001330 <wakeup>
  release(&pi->lock);
    8000388e:	8526                	mv	a0,s1
    80003890:	667010ef          	jal	ra,800056f6 <release>
  return i;
}
    80003894:	854e                	mv	a0,s3
    80003896:	60a6                	ld	ra,72(sp)
    80003898:	6406                	ld	s0,64(sp)
    8000389a:	74e2                	ld	s1,56(sp)
    8000389c:	7942                	ld	s2,48(sp)
    8000389e:	79a2                	ld	s3,40(sp)
    800038a0:	7a02                	ld	s4,32(sp)
    800038a2:	6ae2                	ld	s5,24(sp)
    800038a4:	6b42                	ld	s6,16(sp)
    800038a6:	6161                	addi	sp,sp,80
    800038a8:	8082                	ret
      release(&pi->lock);
    800038aa:	8526                	mv	a0,s1
    800038ac:	64b010ef          	jal	ra,800056f6 <release>
      return -1;
    800038b0:	59fd                	li	s3,-1
    800038b2:	b7cd                	j	80003894 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800038b4:	4981                	li	s3,0
    800038b6:	bfc1                	j	80003886 <piperead+0xa0>

00000000800038b8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800038b8:	1141                	addi	sp,sp,-16
    800038ba:	e422                	sd	s0,8(sp)
    800038bc:	0800                	addi	s0,sp,16
    800038be:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800038c0:	8905                	andi	a0,a0,1
    800038c2:	c111                	beqz	a0,800038c6 <flags2perm+0xe>
      perm = PTE_X;
    800038c4:	4521                	li	a0,8
    if(flags & 0x2)
    800038c6:	8b89                	andi	a5,a5,2
    800038c8:	c399                	beqz	a5,800038ce <flags2perm+0x16>
      perm |= PTE_W;
    800038ca:	00456513          	ori	a0,a0,4
    return perm;
}
    800038ce:	6422                	ld	s0,8(sp)
    800038d0:	0141                	addi	sp,sp,16
    800038d2:	8082                	ret

00000000800038d4 <exec>:

int
exec(char *path, char **argv)
{
    800038d4:	df010113          	addi	sp,sp,-528
    800038d8:	20113423          	sd	ra,520(sp)
    800038dc:	20813023          	sd	s0,512(sp)
    800038e0:	ffa6                	sd	s1,504(sp)
    800038e2:	fbca                	sd	s2,496(sp)
    800038e4:	f7ce                	sd	s3,488(sp)
    800038e6:	f3d2                	sd	s4,480(sp)
    800038e8:	efd6                	sd	s5,472(sp)
    800038ea:	ebda                	sd	s6,464(sp)
    800038ec:	e7de                	sd	s7,456(sp)
    800038ee:	e3e2                	sd	s8,448(sp)
    800038f0:	ff66                	sd	s9,440(sp)
    800038f2:	fb6a                	sd	s10,432(sp)
    800038f4:	f76e                	sd	s11,424(sp)
    800038f6:	0c00                	addi	s0,sp,528
    800038f8:	84aa                	mv	s1,a0
    800038fa:	dea43c23          	sd	a0,-520(s0)
    800038fe:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003902:	c0efd0ef          	jal	ra,80000d10 <myproc>
    80003906:	892a                	mv	s2,a0

  begin_op();
    80003908:	e00ff0ef          	jal	ra,80002f08 <begin_op>

  if((ip = namei(path)) == 0){
    8000390c:	8526                	mv	a0,s1
    8000390e:	c22ff0ef          	jal	ra,80002d30 <namei>
    80003912:	c12d                	beqz	a0,80003974 <exec+0xa0>
    80003914:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003916:	d69fe0ef          	jal	ra,8000267e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000391a:	04000713          	li	a4,64
    8000391e:	4681                	li	a3,0
    80003920:	e5040613          	addi	a2,s0,-432
    80003924:	4581                	li	a1,0
    80003926:	8526                	mv	a0,s1
    80003928:	fa7fe0ef          	jal	ra,800028ce <readi>
    8000392c:	04000793          	li	a5,64
    80003930:	00f51a63          	bne	a0,a5,80003944 <exec+0x70>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003934:	e5042703          	lw	a4,-432(s0)
    80003938:	464c47b7          	lui	a5,0x464c4
    8000393c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003940:	02f70e63          	beq	a4,a5,8000397c <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003944:	8526                	mv	a0,s1
    80003946:	f3ffe0ef          	jal	ra,80002884 <iunlockput>
    end_op();
    8000394a:	e2eff0ef          	jal	ra,80002f78 <end_op>
  }
  return -1;
    8000394e:	557d                	li	a0,-1
}
    80003950:	20813083          	ld	ra,520(sp)
    80003954:	20013403          	ld	s0,512(sp)
    80003958:	74fe                	ld	s1,504(sp)
    8000395a:	795e                	ld	s2,496(sp)
    8000395c:	79be                	ld	s3,488(sp)
    8000395e:	7a1e                	ld	s4,480(sp)
    80003960:	6afe                	ld	s5,472(sp)
    80003962:	6b5e                	ld	s6,464(sp)
    80003964:	6bbe                	ld	s7,456(sp)
    80003966:	6c1e                	ld	s8,448(sp)
    80003968:	7cfa                	ld	s9,440(sp)
    8000396a:	7d5a                	ld	s10,432(sp)
    8000396c:	7dba                	ld	s11,424(sp)
    8000396e:	21010113          	addi	sp,sp,528
    80003972:	8082                	ret
    end_op();
    80003974:	e04ff0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80003978:	557d                	li	a0,-1
    8000397a:	bfd9                	j	80003950 <exec+0x7c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000397c:	854a                	mv	a0,s2
    8000397e:	c3afd0ef          	jal	ra,80000db8 <proc_pagetable>
    80003982:	8baa                	mv	s7,a0
    80003984:	d161                	beqz	a0,80003944 <exec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003986:	e7042983          	lw	s3,-400(s0)
    8000398a:	e8845783          	lhu	a5,-376(s0)
    8000398e:	cfb9                	beqz	a5,800039ec <exec+0x118>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003990:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003992:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80003994:	6c85                	lui	s9,0x1
    80003996:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000399a:	def43823          	sd	a5,-528(s0)
    8000399e:	aadd                	j	80003b94 <exec+0x2c0>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800039a0:	00004517          	auipc	a0,0x4
    800039a4:	d0850513          	addi	a0,a0,-760 # 800076a8 <syscalls+0x290>
    800039a8:	19b010ef          	jal	ra,80005342 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800039ac:	8756                	mv	a4,s5
    800039ae:	012d86bb          	addw	a3,s11,s2
    800039b2:	4581                	li	a1,0
    800039b4:	8526                	mv	a0,s1
    800039b6:	f19fe0ef          	jal	ra,800028ce <readi>
    800039ba:	2501                	sext.w	a0,a0
    800039bc:	18aa9263          	bne	s5,a0,80003b40 <exec+0x26c>
  for(i = 0; i < sz; i += PGSIZE){
    800039c0:	6785                	lui	a5,0x1
    800039c2:	0127893b          	addw	s2,a5,s2
    800039c6:	77fd                	lui	a5,0xfffff
    800039c8:	01478a3b          	addw	s4,a5,s4
    800039cc:	1b897b63          	bgeu	s2,s8,80003b82 <exec+0x2ae>
    pa = walkaddr(pagetable, va + i);
    800039d0:	02091593          	slli	a1,s2,0x20
    800039d4:	9181                	srli	a1,a1,0x20
    800039d6:	95ea                	add	a1,a1,s10
    800039d8:	855e                	mv	a0,s7
    800039da:	a91fc0ef          	jal	ra,8000046a <walkaddr>
    800039de:	862a                	mv	a2,a0
    if(pa == 0)
    800039e0:	d161                	beqz	a0,800039a0 <exec+0xcc>
      n = PGSIZE;
    800039e2:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800039e4:	fd9a74e3          	bgeu	s4,s9,800039ac <exec+0xd8>
      n = sz - i;
    800039e8:	8ad2                	mv	s5,s4
    800039ea:	b7c9                	j	800039ac <exec+0xd8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800039ec:	4a01                	li	s4,0
  iunlockput(ip);
    800039ee:	8526                	mv	a0,s1
    800039f0:	e95fe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    800039f4:	d84ff0ef          	jal	ra,80002f78 <end_op>
  p = myproc();
    800039f8:	b18fd0ef          	jal	ra,80000d10 <myproc>
    800039fc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800039fe:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003a02:	6785                	lui	a5,0x1
    80003a04:	17fd                	addi	a5,a5,-1
    80003a06:	9a3e                	add	s4,s4,a5
    80003a08:	757d                	lui	a0,0xfffff
    80003a0a:	00aa77b3          	and	a5,s4,a0
    80003a0e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003a12:	4691                	li	a3,4
    80003a14:	6609                	lui	a2,0x2
    80003a16:	963e                	add	a2,a2,a5
    80003a18:	85be                	mv	a1,a5
    80003a1a:	855e                	mv	a0,s7
    80003a1c:	da7fc0ef          	jal	ra,800007c2 <uvmalloc>
    80003a20:	8b2a                	mv	s6,a0
  ip = 0;
    80003a22:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003a24:	10050e63          	beqz	a0,80003b40 <exec+0x26c>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003a28:	75f9                	lui	a1,0xffffe
    80003a2a:	95aa                	add	a1,a1,a0
    80003a2c:	855e                	mv	a0,s7
    80003a2e:	f6ffc0ef          	jal	ra,8000099c <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003a32:	7c7d                	lui	s8,0xfffff
    80003a34:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80003a36:	e0043783          	ld	a5,-512(s0)
    80003a3a:	6388                	ld	a0,0(a5)
    80003a3c:	c125                	beqz	a0,80003a9c <exec+0x1c8>
    80003a3e:	e9040993          	addi	s3,s0,-368
    80003a42:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80003a46:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80003a48:	885fc0ef          	jal	ra,800002cc <strlen>
    80003a4c:	2505                	addiw	a0,a0,1
    80003a4e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003a52:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80003a56:	11896a63          	bltu	s2,s8,80003b6a <exec+0x296>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003a5a:	e0043d83          	ld	s11,-512(s0)
    80003a5e:	000dba03          	ld	s4,0(s11)
    80003a62:	8552                	mv	a0,s4
    80003a64:	869fc0ef          	jal	ra,800002cc <strlen>
    80003a68:	0015069b          	addiw	a3,a0,1
    80003a6c:	8652                	mv	a2,s4
    80003a6e:	85ca                	mv	a1,s2
    80003a70:	855e                	mv	a0,s7
    80003a72:	f55fc0ef          	jal	ra,800009c6 <copyout>
    80003a76:	0e054e63          	bltz	a0,80003b72 <exec+0x29e>
    ustack[argc] = sp;
    80003a7a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003a7e:	0485                	addi	s1,s1,1
    80003a80:	008d8793          	addi	a5,s11,8
    80003a84:	e0f43023          	sd	a5,-512(s0)
    80003a88:	008db503          	ld	a0,8(s11)
    80003a8c:	c911                	beqz	a0,80003aa0 <exec+0x1cc>
    if(argc >= MAXARG)
    80003a8e:	09a1                	addi	s3,s3,8
    80003a90:	fb3c9ce3          	bne	s9,s3,80003a48 <exec+0x174>
  sz = sz1;
    80003a94:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003a98:	4481                	li	s1,0
    80003a9a:	a05d                	j	80003b40 <exec+0x26c>
  sp = sz;
    80003a9c:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80003a9e:	4481                	li	s1,0
  ustack[argc] = 0;
    80003aa0:	00349793          	slli	a5,s1,0x3
    80003aa4:	f9040713          	addi	a4,s0,-112
    80003aa8:	97ba                	add	a5,a5,a4
    80003aaa:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80003aae:	00148693          	addi	a3,s1,1
    80003ab2:	068e                	slli	a3,a3,0x3
    80003ab4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003ab8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80003abc:	01897663          	bgeu	s2,s8,80003ac8 <exec+0x1f4>
  sz = sz1;
    80003ac0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003ac4:	4481                	li	s1,0
    80003ac6:	a8ad                	j	80003b40 <exec+0x26c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003ac8:	e9040613          	addi	a2,s0,-368
    80003acc:	85ca                	mv	a1,s2
    80003ace:	855e                	mv	a0,s7
    80003ad0:	ef7fc0ef          	jal	ra,800009c6 <copyout>
    80003ad4:	0a054363          	bltz	a0,80003b7a <exec+0x2a6>
  p->trapframe->a1 = sp;
    80003ad8:	058ab783          	ld	a5,88(s5)
    80003adc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003ae0:	df843783          	ld	a5,-520(s0)
    80003ae4:	0007c703          	lbu	a4,0(a5)
    80003ae8:	cf11                	beqz	a4,80003b04 <exec+0x230>
    80003aea:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003aec:	02f00693          	li	a3,47
    80003af0:	a039                	j	80003afe <exec+0x22a>
      last = s+1;
    80003af2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003af6:	0785                	addi	a5,a5,1
    80003af8:	fff7c703          	lbu	a4,-1(a5)
    80003afc:	c701                	beqz	a4,80003b04 <exec+0x230>
    if(*s == '/')
    80003afe:	fed71ce3          	bne	a4,a3,80003af6 <exec+0x222>
    80003b02:	bfc5                	j	80003af2 <exec+0x21e>
  safestrcpy(p->name, last, sizeof(p->name));
    80003b04:	4641                	li	a2,16
    80003b06:	df843583          	ld	a1,-520(s0)
    80003b0a:	158a8513          	addi	a0,s5,344
    80003b0e:	f8cfc0ef          	jal	ra,8000029a <safestrcpy>
  oldpagetable = p->pagetable;
    80003b12:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003b16:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80003b1a:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003b1e:	058ab783          	ld	a5,88(s5)
    80003b22:	e6843703          	ld	a4,-408(s0)
    80003b26:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003b28:	058ab783          	ld	a5,88(s5)
    80003b2c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003b30:	85ea                	mv	a1,s10
    80003b32:	b0afd0ef          	jal	ra,80000e3c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003b36:	0004851b          	sext.w	a0,s1
    80003b3a:	bd19                	j	80003950 <exec+0x7c>
    80003b3c:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80003b40:	e0843583          	ld	a1,-504(s0)
    80003b44:	855e                	mv	a0,s7
    80003b46:	af6fd0ef          	jal	ra,80000e3c <proc_freepagetable>
  if(ip){
    80003b4a:	de049de3          	bnez	s1,80003944 <exec+0x70>
  return -1;
    80003b4e:	557d                	li	a0,-1
    80003b50:	b501                	j	80003950 <exec+0x7c>
    80003b52:	e1443423          	sd	s4,-504(s0)
    80003b56:	b7ed                	j	80003b40 <exec+0x26c>
    80003b58:	e1443423          	sd	s4,-504(s0)
    80003b5c:	b7d5                	j	80003b40 <exec+0x26c>
    80003b5e:	e1443423          	sd	s4,-504(s0)
    80003b62:	bff9                	j	80003b40 <exec+0x26c>
    80003b64:	e1443423          	sd	s4,-504(s0)
    80003b68:	bfe1                	j	80003b40 <exec+0x26c>
  sz = sz1;
    80003b6a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003b6e:	4481                	li	s1,0
    80003b70:	bfc1                	j	80003b40 <exec+0x26c>
  sz = sz1;
    80003b72:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003b76:	4481                	li	s1,0
    80003b78:	b7e1                	j	80003b40 <exec+0x26c>
  sz = sz1;
    80003b7a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80003b7e:	4481                	li	s1,0
    80003b80:	b7c1                	j	80003b40 <exec+0x26c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003b82:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b86:	2b05                	addiw	s6,s6,1
    80003b88:	0389899b          	addiw	s3,s3,56
    80003b8c:	e8845783          	lhu	a5,-376(s0)
    80003b90:	e4fb5fe3          	bge	s6,a5,800039ee <exec+0x11a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003b94:	2981                	sext.w	s3,s3
    80003b96:	03800713          	li	a4,56
    80003b9a:	86ce                	mv	a3,s3
    80003b9c:	e1840613          	addi	a2,s0,-488
    80003ba0:	4581                	li	a1,0
    80003ba2:	8526                	mv	a0,s1
    80003ba4:	d2bfe0ef          	jal	ra,800028ce <readi>
    80003ba8:	03800793          	li	a5,56
    80003bac:	f8f518e3          	bne	a0,a5,80003b3c <exec+0x268>
    if(ph.type != ELF_PROG_LOAD)
    80003bb0:	e1842783          	lw	a5,-488(s0)
    80003bb4:	4705                	li	a4,1
    80003bb6:	fce798e3          	bne	a5,a4,80003b86 <exec+0x2b2>
    if(ph.memsz < ph.filesz)
    80003bba:	e4043903          	ld	s2,-448(s0)
    80003bbe:	e3843783          	ld	a5,-456(s0)
    80003bc2:	f8f968e3          	bltu	s2,a5,80003b52 <exec+0x27e>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003bc6:	e2843783          	ld	a5,-472(s0)
    80003bca:	993e                	add	s2,s2,a5
    80003bcc:	f8f966e3          	bltu	s2,a5,80003b58 <exec+0x284>
    if(ph.vaddr % PGSIZE != 0)
    80003bd0:	df043703          	ld	a4,-528(s0)
    80003bd4:	8ff9                	and	a5,a5,a4
    80003bd6:	f7c1                	bnez	a5,80003b5e <exec+0x28a>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003bd8:	e1c42503          	lw	a0,-484(s0)
    80003bdc:	cddff0ef          	jal	ra,800038b8 <flags2perm>
    80003be0:	86aa                	mv	a3,a0
    80003be2:	864a                	mv	a2,s2
    80003be4:	85d2                	mv	a1,s4
    80003be6:	855e                	mv	a0,s7
    80003be8:	bdbfc0ef          	jal	ra,800007c2 <uvmalloc>
    80003bec:	e0a43423          	sd	a0,-504(s0)
    80003bf0:	d935                	beqz	a0,80003b64 <exec+0x290>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003bf2:	e2843d03          	ld	s10,-472(s0)
    80003bf6:	e2042d83          	lw	s11,-480(s0)
    80003bfa:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003bfe:	f80c02e3          	beqz	s8,80003b82 <exec+0x2ae>
    80003c02:	8a62                	mv	s4,s8
    80003c04:	4901                	li	s2,0
    80003c06:	b3e9                	j	800039d0 <exec+0xfc>

0000000080003c08 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003c08:	7179                	addi	sp,sp,-48
    80003c0a:	f406                	sd	ra,40(sp)
    80003c0c:	f022                	sd	s0,32(sp)
    80003c0e:	ec26                	sd	s1,24(sp)
    80003c10:	e84a                	sd	s2,16(sp)
    80003c12:	1800                	addi	s0,sp,48
    80003c14:	892e                	mv	s2,a1
    80003c16:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003c18:	fdc40593          	addi	a1,s0,-36
    80003c1c:	fd9fd0ef          	jal	ra,80001bf4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003c20:	fdc42703          	lw	a4,-36(s0)
    80003c24:	47bd                	li	a5,15
    80003c26:	02e7e963          	bltu	a5,a4,80003c58 <argfd+0x50>
    80003c2a:	8e6fd0ef          	jal	ra,80000d10 <myproc>
    80003c2e:	fdc42703          	lw	a4,-36(s0)
    80003c32:	01a70793          	addi	a5,a4,26
    80003c36:	078e                	slli	a5,a5,0x3
    80003c38:	953e                	add	a0,a0,a5
    80003c3a:	611c                	ld	a5,0(a0)
    80003c3c:	c385                	beqz	a5,80003c5c <argfd+0x54>
    return -1;
  if(pfd)
    80003c3e:	00090463          	beqz	s2,80003c46 <argfd+0x3e>
    *pfd = fd;
    80003c42:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003c46:	4501                	li	a0,0
  if(pf)
    80003c48:	c091                	beqz	s1,80003c4c <argfd+0x44>
    *pf = f;
    80003c4a:	e09c                	sd	a5,0(s1)
}
    80003c4c:	70a2                	ld	ra,40(sp)
    80003c4e:	7402                	ld	s0,32(sp)
    80003c50:	64e2                	ld	s1,24(sp)
    80003c52:	6942                	ld	s2,16(sp)
    80003c54:	6145                	addi	sp,sp,48
    80003c56:	8082                	ret
    return -1;
    80003c58:	557d                	li	a0,-1
    80003c5a:	bfcd                	j	80003c4c <argfd+0x44>
    80003c5c:	557d                	li	a0,-1
    80003c5e:	b7fd                	j	80003c4c <argfd+0x44>

0000000080003c60 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003c60:	1101                	addi	sp,sp,-32
    80003c62:	ec06                	sd	ra,24(sp)
    80003c64:	e822                	sd	s0,16(sp)
    80003c66:	e426                	sd	s1,8(sp)
    80003c68:	1000                	addi	s0,sp,32
    80003c6a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003c6c:	8a4fd0ef          	jal	ra,80000d10 <myproc>
    80003c70:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003c72:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd9690>
    80003c76:	4501                	li	a0,0
    80003c78:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003c7a:	6398                	ld	a4,0(a5)
    80003c7c:	cb19                	beqz	a4,80003c92 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003c7e:	2505                	addiw	a0,a0,1
    80003c80:	07a1                	addi	a5,a5,8
    80003c82:	fed51ce3          	bne	a0,a3,80003c7a <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003c86:	557d                	li	a0,-1
}
    80003c88:	60e2                	ld	ra,24(sp)
    80003c8a:	6442                	ld	s0,16(sp)
    80003c8c:	64a2                	ld	s1,8(sp)
    80003c8e:	6105                	addi	sp,sp,32
    80003c90:	8082                	ret
      p->ofile[fd] = f;
    80003c92:	01a50793          	addi	a5,a0,26
    80003c96:	078e                	slli	a5,a5,0x3
    80003c98:	963e                	add	a2,a2,a5
    80003c9a:	e204                	sd	s1,0(a2)
      return fd;
    80003c9c:	b7f5                	j	80003c88 <fdalloc+0x28>

0000000080003c9e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003c9e:	715d                	addi	sp,sp,-80
    80003ca0:	e486                	sd	ra,72(sp)
    80003ca2:	e0a2                	sd	s0,64(sp)
    80003ca4:	fc26                	sd	s1,56(sp)
    80003ca6:	f84a                	sd	s2,48(sp)
    80003ca8:	f44e                	sd	s3,40(sp)
    80003caa:	f052                	sd	s4,32(sp)
    80003cac:	ec56                	sd	s5,24(sp)
    80003cae:	e85a                	sd	s6,16(sp)
    80003cb0:	0880                	addi	s0,sp,80
    80003cb2:	8b2e                	mv	s6,a1
    80003cb4:	89b2                	mv	s3,a2
    80003cb6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003cb8:	fb040593          	addi	a1,s0,-80
    80003cbc:	88eff0ef          	jal	ra,80002d4a <nameiparent>
    80003cc0:	84aa                	mv	s1,a0
    80003cc2:	10050c63          	beqz	a0,80003dda <create+0x13c>
    return 0;

  ilock(dp);
    80003cc6:	9b9fe0ef          	jal	ra,8000267e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003cca:	4601                	li	a2,0
    80003ccc:	fb040593          	addi	a1,s0,-80
    80003cd0:	8526                	mv	a0,s1
    80003cd2:	df9fe0ef          	jal	ra,80002aca <dirlookup>
    80003cd6:	8aaa                	mv	s5,a0
    80003cd8:	c521                	beqz	a0,80003d20 <create+0x82>
    iunlockput(dp);
    80003cda:	8526                	mv	a0,s1
    80003cdc:	ba9fe0ef          	jal	ra,80002884 <iunlockput>
    ilock(ip);
    80003ce0:	8556                	mv	a0,s5
    80003ce2:	99dfe0ef          	jal	ra,8000267e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003ce6:	000b059b          	sext.w	a1,s6
    80003cea:	4789                	li	a5,2
    80003cec:	02f59563          	bne	a1,a5,80003d16 <create+0x78>
    80003cf0:	044ad783          	lhu	a5,68(s5)
    80003cf4:	37f9                	addiw	a5,a5,-2
    80003cf6:	17c2                	slli	a5,a5,0x30
    80003cf8:	93c1                	srli	a5,a5,0x30
    80003cfa:	4705                	li	a4,1
    80003cfc:	00f76d63          	bltu	a4,a5,80003d16 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003d00:	8556                	mv	a0,s5
    80003d02:	60a6                	ld	ra,72(sp)
    80003d04:	6406                	ld	s0,64(sp)
    80003d06:	74e2                	ld	s1,56(sp)
    80003d08:	7942                	ld	s2,48(sp)
    80003d0a:	79a2                	ld	s3,40(sp)
    80003d0c:	7a02                	ld	s4,32(sp)
    80003d0e:	6ae2                	ld	s5,24(sp)
    80003d10:	6b42                	ld	s6,16(sp)
    80003d12:	6161                	addi	sp,sp,80
    80003d14:	8082                	ret
    iunlockput(ip);
    80003d16:	8556                	mv	a0,s5
    80003d18:	b6dfe0ef          	jal	ra,80002884 <iunlockput>
    return 0;
    80003d1c:	4a81                	li	s5,0
    80003d1e:	b7cd                	j	80003d00 <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    80003d20:	85da                	mv	a1,s6
    80003d22:	4088                	lw	a0,0(s1)
    80003d24:	ff2fe0ef          	jal	ra,80002516 <ialloc>
    80003d28:	8a2a                	mv	s4,a0
    80003d2a:	c121                	beqz	a0,80003d6a <create+0xcc>
  ilock(ip);
    80003d2c:	953fe0ef          	jal	ra,8000267e <ilock>
  ip->major = major;
    80003d30:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003d34:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003d38:	4785                	li	a5,1
    80003d3a:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80003d3e:	8552                	mv	a0,s4
    80003d40:	88dfe0ef          	jal	ra,800025cc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003d44:	000b059b          	sext.w	a1,s6
    80003d48:	4785                	li	a5,1
    80003d4a:	02f58563          	beq	a1,a5,80003d74 <create+0xd6>
  if(dirlink(dp, name, ip->inum) < 0)
    80003d4e:	004a2603          	lw	a2,4(s4)
    80003d52:	fb040593          	addi	a1,s0,-80
    80003d56:	8526                	mv	a0,s1
    80003d58:	f3ffe0ef          	jal	ra,80002c96 <dirlink>
    80003d5c:	06054363          	bltz	a0,80003dc2 <create+0x124>
  iunlockput(dp);
    80003d60:	8526                	mv	a0,s1
    80003d62:	b23fe0ef          	jal	ra,80002884 <iunlockput>
  return ip;
    80003d66:	8ad2                	mv	s5,s4
    80003d68:	bf61                	j	80003d00 <create+0x62>
    iunlockput(dp);
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	b19fe0ef          	jal	ra,80002884 <iunlockput>
    return 0;
    80003d70:	8ad2                	mv	s5,s4
    80003d72:	b779                	j	80003d00 <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003d74:	004a2603          	lw	a2,4(s4)
    80003d78:	00004597          	auipc	a1,0x4
    80003d7c:	95058593          	addi	a1,a1,-1712 # 800076c8 <syscalls+0x2b0>
    80003d80:	8552                	mv	a0,s4
    80003d82:	f15fe0ef          	jal	ra,80002c96 <dirlink>
    80003d86:	02054e63          	bltz	a0,80003dc2 <create+0x124>
    80003d8a:	40d0                	lw	a2,4(s1)
    80003d8c:	00004597          	auipc	a1,0x4
    80003d90:	94458593          	addi	a1,a1,-1724 # 800076d0 <syscalls+0x2b8>
    80003d94:	8552                	mv	a0,s4
    80003d96:	f01fe0ef          	jal	ra,80002c96 <dirlink>
    80003d9a:	02054463          	bltz	a0,80003dc2 <create+0x124>
  if(dirlink(dp, name, ip->inum) < 0)
    80003d9e:	004a2603          	lw	a2,4(s4)
    80003da2:	fb040593          	addi	a1,s0,-80
    80003da6:	8526                	mv	a0,s1
    80003da8:	eeffe0ef          	jal	ra,80002c96 <dirlink>
    80003dac:	00054b63          	bltz	a0,80003dc2 <create+0x124>
    dp->nlink++;  // for ".."
    80003db0:	04a4d783          	lhu	a5,74(s1)
    80003db4:	2785                	addiw	a5,a5,1
    80003db6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003dba:	8526                	mv	a0,s1
    80003dbc:	811fe0ef          	jal	ra,800025cc <iupdate>
    80003dc0:	b745                	j	80003d60 <create+0xc2>
  ip->nlink = 0;
    80003dc2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	805fe0ef          	jal	ra,800025cc <iupdate>
  iunlockput(ip);
    80003dcc:	8552                	mv	a0,s4
    80003dce:	ab7fe0ef          	jal	ra,80002884 <iunlockput>
  iunlockput(dp);
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	ab1fe0ef          	jal	ra,80002884 <iunlockput>
  return 0;
    80003dd8:	b725                	j	80003d00 <create+0x62>
    return 0;
    80003dda:	8aaa                	mv	s5,a0
    80003ddc:	b715                	j	80003d00 <create+0x62>

0000000080003dde <sys_dup>:
{
    80003dde:	7179                	addi	sp,sp,-48
    80003de0:	f406                	sd	ra,40(sp)
    80003de2:	f022                	sd	s0,32(sp)
    80003de4:	ec26                	sd	s1,24(sp)
    80003de6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80003de8:	fd840613          	addi	a2,s0,-40
    80003dec:	4581                	li	a1,0
    80003dee:	4501                	li	a0,0
    80003df0:	e19ff0ef          	jal	ra,80003c08 <argfd>
    return -1;
    80003df4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80003df6:	00054f63          	bltz	a0,80003e14 <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80003dfa:	fd843503          	ld	a0,-40(s0)
    80003dfe:	e63ff0ef          	jal	ra,80003c60 <fdalloc>
    80003e02:	84aa                	mv	s1,a0
    return -1;
    80003e04:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80003e06:	00054763          	bltz	a0,80003e14 <sys_dup+0x36>
  filedup(f);
    80003e0a:	fd843503          	ld	a0,-40(s0)
    80003e0e:	cd0ff0ef          	jal	ra,800032de <filedup>
  return fd;
    80003e12:	87a6                	mv	a5,s1
}
    80003e14:	853e                	mv	a0,a5
    80003e16:	70a2                	ld	ra,40(sp)
    80003e18:	7402                	ld	s0,32(sp)
    80003e1a:	64e2                	ld	s1,24(sp)
    80003e1c:	6145                	addi	sp,sp,48
    80003e1e:	8082                	ret

0000000080003e20 <sys_read>:
{
    80003e20:	7179                	addi	sp,sp,-48
    80003e22:	f406                	sd	ra,40(sp)
    80003e24:	f022                	sd	s0,32(sp)
    80003e26:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003e28:	fd840593          	addi	a1,s0,-40
    80003e2c:	4505                	li	a0,1
    80003e2e:	de3fd0ef          	jal	ra,80001c10 <argaddr>
  argint(2, &n);
    80003e32:	fe440593          	addi	a1,s0,-28
    80003e36:	4509                	li	a0,2
    80003e38:	dbdfd0ef          	jal	ra,80001bf4 <argint>
  if(argfd(0, 0, &f) < 0)
    80003e3c:	fe840613          	addi	a2,s0,-24
    80003e40:	4581                	li	a1,0
    80003e42:	4501                	li	a0,0
    80003e44:	dc5ff0ef          	jal	ra,80003c08 <argfd>
    80003e48:	87aa                	mv	a5,a0
    return -1;
    80003e4a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003e4c:	0007ca63          	bltz	a5,80003e60 <sys_read+0x40>
  return fileread(f, p, n);
    80003e50:	fe442603          	lw	a2,-28(s0)
    80003e54:	fd843583          	ld	a1,-40(s0)
    80003e58:	fe843503          	ld	a0,-24(s0)
    80003e5c:	dceff0ef          	jal	ra,8000342a <fileread>
}
    80003e60:	70a2                	ld	ra,40(sp)
    80003e62:	7402                	ld	s0,32(sp)
    80003e64:	6145                	addi	sp,sp,48
    80003e66:	8082                	ret

0000000080003e68 <sys_write>:
{
    80003e68:	7179                	addi	sp,sp,-48
    80003e6a:	f406                	sd	ra,40(sp)
    80003e6c:	f022                	sd	s0,32(sp)
    80003e6e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80003e70:	fd840593          	addi	a1,s0,-40
    80003e74:	4505                	li	a0,1
    80003e76:	d9bfd0ef          	jal	ra,80001c10 <argaddr>
  argint(2, &n);
    80003e7a:	fe440593          	addi	a1,s0,-28
    80003e7e:	4509                	li	a0,2
    80003e80:	d75fd0ef          	jal	ra,80001bf4 <argint>
  if(argfd(0, 0, &f) < 0)
    80003e84:	fe840613          	addi	a2,s0,-24
    80003e88:	4581                	li	a1,0
    80003e8a:	4501                	li	a0,0
    80003e8c:	d7dff0ef          	jal	ra,80003c08 <argfd>
    80003e90:	87aa                	mv	a5,a0
    return -1;
    80003e92:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003e94:	0007ca63          	bltz	a5,80003ea8 <sys_write+0x40>
  return filewrite(f, p, n);
    80003e98:	fe442603          	lw	a2,-28(s0)
    80003e9c:	fd843583          	ld	a1,-40(s0)
    80003ea0:	fe843503          	ld	a0,-24(s0)
    80003ea4:	e34ff0ef          	jal	ra,800034d8 <filewrite>
}
    80003ea8:	70a2                	ld	ra,40(sp)
    80003eaa:	7402                	ld	s0,32(sp)
    80003eac:	6145                	addi	sp,sp,48
    80003eae:	8082                	ret

0000000080003eb0 <sys_close>:
{
    80003eb0:	1101                	addi	sp,sp,-32
    80003eb2:	ec06                	sd	ra,24(sp)
    80003eb4:	e822                	sd	s0,16(sp)
    80003eb6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80003eb8:	fe040613          	addi	a2,s0,-32
    80003ebc:	fec40593          	addi	a1,s0,-20
    80003ec0:	4501                	li	a0,0
    80003ec2:	d47ff0ef          	jal	ra,80003c08 <argfd>
    return -1;
    80003ec6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80003ec8:	02054063          	bltz	a0,80003ee8 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80003ecc:	e45fc0ef          	jal	ra,80000d10 <myproc>
    80003ed0:	fec42783          	lw	a5,-20(s0)
    80003ed4:	07e9                	addi	a5,a5,26
    80003ed6:	078e                	slli	a5,a5,0x3
    80003ed8:	97aa                	add	a5,a5,a0
    80003eda:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80003ede:	fe043503          	ld	a0,-32(s0)
    80003ee2:	c42ff0ef          	jal	ra,80003324 <fileclose>
  return 0;
    80003ee6:	4781                	li	a5,0
}
    80003ee8:	853e                	mv	a0,a5
    80003eea:	60e2                	ld	ra,24(sp)
    80003eec:	6442                	ld	s0,16(sp)
    80003eee:	6105                	addi	sp,sp,32
    80003ef0:	8082                	ret

0000000080003ef2 <sys_fstat>:
{
    80003ef2:	1101                	addi	sp,sp,-32
    80003ef4:	ec06                	sd	ra,24(sp)
    80003ef6:	e822                	sd	s0,16(sp)
    80003ef8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80003efa:	fe040593          	addi	a1,s0,-32
    80003efe:	4505                	li	a0,1
    80003f00:	d11fd0ef          	jal	ra,80001c10 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80003f04:	fe840613          	addi	a2,s0,-24
    80003f08:	4581                	li	a1,0
    80003f0a:	4501                	li	a0,0
    80003f0c:	cfdff0ef          	jal	ra,80003c08 <argfd>
    80003f10:	87aa                	mv	a5,a0
    return -1;
    80003f12:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80003f14:	0007c863          	bltz	a5,80003f24 <sys_fstat+0x32>
  return filestat(f, st);
    80003f18:	fe043583          	ld	a1,-32(s0)
    80003f1c:	fe843503          	ld	a0,-24(s0)
    80003f20:	cacff0ef          	jal	ra,800033cc <filestat>
}
    80003f24:	60e2                	ld	ra,24(sp)
    80003f26:	6442                	ld	s0,16(sp)
    80003f28:	6105                	addi	sp,sp,32
    80003f2a:	8082                	ret

0000000080003f2c <sys_link>:
{
    80003f2c:	7169                	addi	sp,sp,-304
    80003f2e:	f606                	sd	ra,296(sp)
    80003f30:	f222                	sd	s0,288(sp)
    80003f32:	ee26                	sd	s1,280(sp)
    80003f34:	ea4a                	sd	s2,272(sp)
    80003f36:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80003f38:	08000613          	li	a2,128
    80003f3c:	ed040593          	addi	a1,s0,-304
    80003f40:	4501                	li	a0,0
    80003f42:	cebfd0ef          	jal	ra,80001c2c <argstr>
    return -1;
    80003f46:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80003f48:	0c054663          	bltz	a0,80004014 <sys_link+0xe8>
    80003f4c:	08000613          	li	a2,128
    80003f50:	f5040593          	addi	a1,s0,-176
    80003f54:	4505                	li	a0,1
    80003f56:	cd7fd0ef          	jal	ra,80001c2c <argstr>
    return -1;
    80003f5a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80003f5c:	0a054c63          	bltz	a0,80004014 <sys_link+0xe8>
  begin_op();
    80003f60:	fa9fe0ef          	jal	ra,80002f08 <begin_op>
  if((ip = namei(old)) == 0){
    80003f64:	ed040513          	addi	a0,s0,-304
    80003f68:	dc9fe0ef          	jal	ra,80002d30 <namei>
    80003f6c:	84aa                	mv	s1,a0
    80003f6e:	c525                	beqz	a0,80003fd6 <sys_link+0xaa>
  ilock(ip);
    80003f70:	f0efe0ef          	jal	ra,8000267e <ilock>
  if(ip->type == T_DIR){
    80003f74:	04449703          	lh	a4,68(s1)
    80003f78:	4785                	li	a5,1
    80003f7a:	06f70263          	beq	a4,a5,80003fde <sys_link+0xb2>
  ip->nlink++;
    80003f7e:	04a4d783          	lhu	a5,74(s1)
    80003f82:	2785                	addiw	a5,a5,1
    80003f84:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80003f88:	8526                	mv	a0,s1
    80003f8a:	e42fe0ef          	jal	ra,800025cc <iupdate>
  iunlock(ip);
    80003f8e:	8526                	mv	a0,s1
    80003f90:	f98fe0ef          	jal	ra,80002728 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80003f94:	fd040593          	addi	a1,s0,-48
    80003f98:	f5040513          	addi	a0,s0,-176
    80003f9c:	daffe0ef          	jal	ra,80002d4a <nameiparent>
    80003fa0:	892a                	mv	s2,a0
    80003fa2:	c921                	beqz	a0,80003ff2 <sys_link+0xc6>
  ilock(dp);
    80003fa4:	edafe0ef          	jal	ra,8000267e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80003fa8:	00092703          	lw	a4,0(s2)
    80003fac:	409c                	lw	a5,0(s1)
    80003fae:	02f71f63          	bne	a4,a5,80003fec <sys_link+0xc0>
    80003fb2:	40d0                	lw	a2,4(s1)
    80003fb4:	fd040593          	addi	a1,s0,-48
    80003fb8:	854a                	mv	a0,s2
    80003fba:	cddfe0ef          	jal	ra,80002c96 <dirlink>
    80003fbe:	02054763          	bltz	a0,80003fec <sys_link+0xc0>
  iunlockput(dp);
    80003fc2:	854a                	mv	a0,s2
    80003fc4:	8c1fe0ef          	jal	ra,80002884 <iunlockput>
  iput(ip);
    80003fc8:	8526                	mv	a0,s1
    80003fca:	833fe0ef          	jal	ra,800027fc <iput>
  end_op();
    80003fce:	fabfe0ef          	jal	ra,80002f78 <end_op>
  return 0;
    80003fd2:	4781                	li	a5,0
    80003fd4:	a081                	j	80004014 <sys_link+0xe8>
    end_op();
    80003fd6:	fa3fe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80003fda:	57fd                	li	a5,-1
    80003fdc:	a825                	j	80004014 <sys_link+0xe8>
    iunlockput(ip);
    80003fde:	8526                	mv	a0,s1
    80003fe0:	8a5fe0ef          	jal	ra,80002884 <iunlockput>
    end_op();
    80003fe4:	f95fe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80003fe8:	57fd                	li	a5,-1
    80003fea:	a02d                	j	80004014 <sys_link+0xe8>
    iunlockput(dp);
    80003fec:	854a                	mv	a0,s2
    80003fee:	897fe0ef          	jal	ra,80002884 <iunlockput>
  ilock(ip);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	e8afe0ef          	jal	ra,8000267e <ilock>
  ip->nlink--;
    80003ff8:	04a4d783          	lhu	a5,74(s1)
    80003ffc:	37fd                	addiw	a5,a5,-1
    80003ffe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004002:	8526                	mv	a0,s1
    80004004:	dc8fe0ef          	jal	ra,800025cc <iupdate>
  iunlockput(ip);
    80004008:	8526                	mv	a0,s1
    8000400a:	87bfe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    8000400e:	f6bfe0ef          	jal	ra,80002f78 <end_op>
  return -1;
    80004012:	57fd                	li	a5,-1
}
    80004014:	853e                	mv	a0,a5
    80004016:	70b2                	ld	ra,296(sp)
    80004018:	7412                	ld	s0,288(sp)
    8000401a:	64f2                	ld	s1,280(sp)
    8000401c:	6952                	ld	s2,272(sp)
    8000401e:	6155                	addi	sp,sp,304
    80004020:	8082                	ret

0000000080004022 <sys_unlink>:
{
    80004022:	7151                	addi	sp,sp,-240
    80004024:	f586                	sd	ra,232(sp)
    80004026:	f1a2                	sd	s0,224(sp)
    80004028:	eda6                	sd	s1,216(sp)
    8000402a:	e9ca                	sd	s2,208(sp)
    8000402c:	e5ce                	sd	s3,200(sp)
    8000402e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004030:	08000613          	li	a2,128
    80004034:	f3040593          	addi	a1,s0,-208
    80004038:	4501                	li	a0,0
    8000403a:	bf3fd0ef          	jal	ra,80001c2c <argstr>
    8000403e:	12054b63          	bltz	a0,80004174 <sys_unlink+0x152>
  begin_op();
    80004042:	ec7fe0ef          	jal	ra,80002f08 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004046:	fb040593          	addi	a1,s0,-80
    8000404a:	f3040513          	addi	a0,s0,-208
    8000404e:	cfdfe0ef          	jal	ra,80002d4a <nameiparent>
    80004052:	84aa                	mv	s1,a0
    80004054:	c54d                	beqz	a0,800040fe <sys_unlink+0xdc>
  ilock(dp);
    80004056:	e28fe0ef          	jal	ra,8000267e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000405a:	00003597          	auipc	a1,0x3
    8000405e:	66e58593          	addi	a1,a1,1646 # 800076c8 <syscalls+0x2b0>
    80004062:	fb040513          	addi	a0,s0,-80
    80004066:	a4ffe0ef          	jal	ra,80002ab4 <namecmp>
    8000406a:	10050a63          	beqz	a0,8000417e <sys_unlink+0x15c>
    8000406e:	00003597          	auipc	a1,0x3
    80004072:	66258593          	addi	a1,a1,1634 # 800076d0 <syscalls+0x2b8>
    80004076:	fb040513          	addi	a0,s0,-80
    8000407a:	a3bfe0ef          	jal	ra,80002ab4 <namecmp>
    8000407e:	10050063          	beqz	a0,8000417e <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004082:	f2c40613          	addi	a2,s0,-212
    80004086:	fb040593          	addi	a1,s0,-80
    8000408a:	8526                	mv	a0,s1
    8000408c:	a3ffe0ef          	jal	ra,80002aca <dirlookup>
    80004090:	892a                	mv	s2,a0
    80004092:	0e050663          	beqz	a0,8000417e <sys_unlink+0x15c>
  ilock(ip);
    80004096:	de8fe0ef          	jal	ra,8000267e <ilock>
  if(ip->nlink < 1)
    8000409a:	04a91783          	lh	a5,74(s2)
    8000409e:	06f05463          	blez	a5,80004106 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800040a2:	04491703          	lh	a4,68(s2)
    800040a6:	4785                	li	a5,1
    800040a8:	06f70563          	beq	a4,a5,80004112 <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    800040ac:	4641                	li	a2,16
    800040ae:	4581                	li	a1,0
    800040b0:	fc040513          	addi	a0,s0,-64
    800040b4:	898fc0ef          	jal	ra,8000014c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b8:	4741                	li	a4,16
    800040ba:	f2c42683          	lw	a3,-212(s0)
    800040be:	fc040613          	addi	a2,s0,-64
    800040c2:	4581                	li	a1,0
    800040c4:	8526                	mv	a0,s1
    800040c6:	8edfe0ef          	jal	ra,800029b2 <writei>
    800040ca:	47c1                	li	a5,16
    800040cc:	08f51563          	bne	a0,a5,80004156 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    800040d0:	04491703          	lh	a4,68(s2)
    800040d4:	4785                	li	a5,1
    800040d6:	08f70663          	beq	a4,a5,80004162 <sys_unlink+0x140>
  iunlockput(dp);
    800040da:	8526                	mv	a0,s1
    800040dc:	fa8fe0ef          	jal	ra,80002884 <iunlockput>
  ip->nlink--;
    800040e0:	04a95783          	lhu	a5,74(s2)
    800040e4:	37fd                	addiw	a5,a5,-1
    800040e6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800040ea:	854a                	mv	a0,s2
    800040ec:	ce0fe0ef          	jal	ra,800025cc <iupdate>
  iunlockput(ip);
    800040f0:	854a                	mv	a0,s2
    800040f2:	f92fe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    800040f6:	e83fe0ef          	jal	ra,80002f78 <end_op>
  return 0;
    800040fa:	4501                	li	a0,0
    800040fc:	a079                	j	8000418a <sys_unlink+0x168>
    end_op();
    800040fe:	e7bfe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80004102:	557d                	li	a0,-1
    80004104:	a059                	j	8000418a <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004106:	00003517          	auipc	a0,0x3
    8000410a:	5d250513          	addi	a0,a0,1490 # 800076d8 <syscalls+0x2c0>
    8000410e:	234010ef          	jal	ra,80005342 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004112:	04c92703          	lw	a4,76(s2)
    80004116:	02000793          	li	a5,32
    8000411a:	f8e7f9e3          	bgeu	a5,a4,800040ac <sys_unlink+0x8a>
    8000411e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004122:	4741                	li	a4,16
    80004124:	86ce                	mv	a3,s3
    80004126:	f1840613          	addi	a2,s0,-232
    8000412a:	4581                	li	a1,0
    8000412c:	854a                	mv	a0,s2
    8000412e:	fa0fe0ef          	jal	ra,800028ce <readi>
    80004132:	47c1                	li	a5,16
    80004134:	00f51b63          	bne	a0,a5,8000414a <sys_unlink+0x128>
    if(de.inum != 0)
    80004138:	f1845783          	lhu	a5,-232(s0)
    8000413c:	ef95                	bnez	a5,80004178 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000413e:	29c1                	addiw	s3,s3,16
    80004140:	04c92783          	lw	a5,76(s2)
    80004144:	fcf9efe3          	bltu	s3,a5,80004122 <sys_unlink+0x100>
    80004148:	b795                	j	800040ac <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000414a:	00003517          	auipc	a0,0x3
    8000414e:	5a650513          	addi	a0,a0,1446 # 800076f0 <syscalls+0x2d8>
    80004152:	1f0010ef          	jal	ra,80005342 <panic>
    panic("unlink: writei");
    80004156:	00003517          	auipc	a0,0x3
    8000415a:	5b250513          	addi	a0,a0,1458 # 80007708 <syscalls+0x2f0>
    8000415e:	1e4010ef          	jal	ra,80005342 <panic>
    dp->nlink--;
    80004162:	04a4d783          	lhu	a5,74(s1)
    80004166:	37fd                	addiw	a5,a5,-1
    80004168:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000416c:	8526                	mv	a0,s1
    8000416e:	c5efe0ef          	jal	ra,800025cc <iupdate>
    80004172:	b7a5                	j	800040da <sys_unlink+0xb8>
    return -1;
    80004174:	557d                	li	a0,-1
    80004176:	a811                	j	8000418a <sys_unlink+0x168>
    iunlockput(ip);
    80004178:	854a                	mv	a0,s2
    8000417a:	f0afe0ef          	jal	ra,80002884 <iunlockput>
  iunlockput(dp);
    8000417e:	8526                	mv	a0,s1
    80004180:	f04fe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    80004184:	df5fe0ef          	jal	ra,80002f78 <end_op>
  return -1;
    80004188:	557d                	li	a0,-1
}
    8000418a:	70ae                	ld	ra,232(sp)
    8000418c:	740e                	ld	s0,224(sp)
    8000418e:	64ee                	ld	s1,216(sp)
    80004190:	694e                	ld	s2,208(sp)
    80004192:	69ae                	ld	s3,200(sp)
    80004194:	616d                	addi	sp,sp,240
    80004196:	8082                	ret

0000000080004198 <sys_open>:

uint64
sys_open(void)
{
    80004198:	7131                	addi	sp,sp,-192
    8000419a:	fd06                	sd	ra,184(sp)
    8000419c:	f922                	sd	s0,176(sp)
    8000419e:	f526                	sd	s1,168(sp)
    800041a0:	f14a                	sd	s2,160(sp)
    800041a2:	ed4e                	sd	s3,152(sp)
    800041a4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800041a6:	f4c40593          	addi	a1,s0,-180
    800041aa:	4505                	li	a0,1
    800041ac:	a49fd0ef          	jal	ra,80001bf4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800041b0:	08000613          	li	a2,128
    800041b4:	f5040593          	addi	a1,s0,-176
    800041b8:	4501                	li	a0,0
    800041ba:	a73fd0ef          	jal	ra,80001c2c <argstr>
    800041be:	87aa                	mv	a5,a0
    return -1;
    800041c0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800041c2:	0807cd63          	bltz	a5,8000425c <sys_open+0xc4>

  begin_op();
    800041c6:	d43fe0ef          	jal	ra,80002f08 <begin_op>

  if(omode & O_CREATE){
    800041ca:	f4c42783          	lw	a5,-180(s0)
    800041ce:	2007f793          	andi	a5,a5,512
    800041d2:	c3c5                	beqz	a5,80004272 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800041d4:	4681                	li	a3,0
    800041d6:	4601                	li	a2,0
    800041d8:	4589                	li	a1,2
    800041da:	f5040513          	addi	a0,s0,-176
    800041de:	ac1ff0ef          	jal	ra,80003c9e <create>
    800041e2:	84aa                	mv	s1,a0
    if(ip == 0){
    800041e4:	c159                	beqz	a0,8000426a <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800041e6:	04449703          	lh	a4,68(s1)
    800041ea:	478d                	li	a5,3
    800041ec:	00f71763          	bne	a4,a5,800041fa <sys_open+0x62>
    800041f0:	0464d703          	lhu	a4,70(s1)
    800041f4:	47a5                	li	a5,9
    800041f6:	0ae7e963          	bltu	a5,a4,800042a8 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800041fa:	886ff0ef          	jal	ra,80003280 <filealloc>
    800041fe:	89aa                	mv	s3,a0
    80004200:	0c050963          	beqz	a0,800042d2 <sys_open+0x13a>
    80004204:	a5dff0ef          	jal	ra,80003c60 <fdalloc>
    80004208:	892a                	mv	s2,a0
    8000420a:	0c054163          	bltz	a0,800042cc <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000420e:	04449703          	lh	a4,68(s1)
    80004212:	478d                	li	a5,3
    80004214:	0af70163          	beq	a4,a5,800042b6 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004218:	4789                	li	a5,2
    8000421a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000421e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004222:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004226:	f4c42783          	lw	a5,-180(s0)
    8000422a:	0017c713          	xori	a4,a5,1
    8000422e:	8b05                	andi	a4,a4,1
    80004230:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004234:	0037f713          	andi	a4,a5,3
    80004238:	00e03733          	snez	a4,a4
    8000423c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004240:	4007f793          	andi	a5,a5,1024
    80004244:	c791                	beqz	a5,80004250 <sys_open+0xb8>
    80004246:	04449703          	lh	a4,68(s1)
    8000424a:	4789                	li	a5,2
    8000424c:	06f70c63          	beq	a4,a5,800042c4 <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004250:	8526                	mv	a0,s1
    80004252:	cd6fe0ef          	jal	ra,80002728 <iunlock>
  end_op();
    80004256:	d23fe0ef          	jal	ra,80002f78 <end_op>

  return fd;
    8000425a:	854a                	mv	a0,s2
}
    8000425c:	70ea                	ld	ra,184(sp)
    8000425e:	744a                	ld	s0,176(sp)
    80004260:	74aa                	ld	s1,168(sp)
    80004262:	790a                	ld	s2,160(sp)
    80004264:	69ea                	ld	s3,152(sp)
    80004266:	6129                	addi	sp,sp,192
    80004268:	8082                	ret
      end_op();
    8000426a:	d0ffe0ef          	jal	ra,80002f78 <end_op>
      return -1;
    8000426e:	557d                	li	a0,-1
    80004270:	b7f5                	j	8000425c <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004272:	f5040513          	addi	a0,s0,-176
    80004276:	abbfe0ef          	jal	ra,80002d30 <namei>
    8000427a:	84aa                	mv	s1,a0
    8000427c:	c115                	beqz	a0,800042a0 <sys_open+0x108>
    ilock(ip);
    8000427e:	c00fe0ef          	jal	ra,8000267e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004282:	04449703          	lh	a4,68(s1)
    80004286:	4785                	li	a5,1
    80004288:	f4f71fe3          	bne	a4,a5,800041e6 <sys_open+0x4e>
    8000428c:	f4c42783          	lw	a5,-180(s0)
    80004290:	d7ad                	beqz	a5,800041fa <sys_open+0x62>
      iunlockput(ip);
    80004292:	8526                	mv	a0,s1
    80004294:	df0fe0ef          	jal	ra,80002884 <iunlockput>
      end_op();
    80004298:	ce1fe0ef          	jal	ra,80002f78 <end_op>
      return -1;
    8000429c:	557d                	li	a0,-1
    8000429e:	bf7d                	j	8000425c <sys_open+0xc4>
      end_op();
    800042a0:	cd9fe0ef          	jal	ra,80002f78 <end_op>
      return -1;
    800042a4:	557d                	li	a0,-1
    800042a6:	bf5d                	j	8000425c <sys_open+0xc4>
    iunlockput(ip);
    800042a8:	8526                	mv	a0,s1
    800042aa:	ddafe0ef          	jal	ra,80002884 <iunlockput>
    end_op();
    800042ae:	ccbfe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    800042b2:	557d                	li	a0,-1
    800042b4:	b765                	j	8000425c <sys_open+0xc4>
    f->type = FD_DEVICE;
    800042b6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800042ba:	04649783          	lh	a5,70(s1)
    800042be:	02f99223          	sh	a5,36(s3)
    800042c2:	b785                	j	80004222 <sys_open+0x8a>
    itrunc(ip);
    800042c4:	8526                	mv	a0,s1
    800042c6:	ca2fe0ef          	jal	ra,80002768 <itrunc>
    800042ca:	b759                	j	80004250 <sys_open+0xb8>
      fileclose(f);
    800042cc:	854e                	mv	a0,s3
    800042ce:	856ff0ef          	jal	ra,80003324 <fileclose>
    iunlockput(ip);
    800042d2:	8526                	mv	a0,s1
    800042d4:	db0fe0ef          	jal	ra,80002884 <iunlockput>
    end_op();
    800042d8:	ca1fe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    800042dc:	557d                	li	a0,-1
    800042de:	bfbd                	j	8000425c <sys_open+0xc4>

00000000800042e0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800042e0:	7175                	addi	sp,sp,-144
    800042e2:	e506                	sd	ra,136(sp)
    800042e4:	e122                	sd	s0,128(sp)
    800042e6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800042e8:	c21fe0ef          	jal	ra,80002f08 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800042ec:	08000613          	li	a2,128
    800042f0:	f7040593          	addi	a1,s0,-144
    800042f4:	4501                	li	a0,0
    800042f6:	937fd0ef          	jal	ra,80001c2c <argstr>
    800042fa:	02054363          	bltz	a0,80004320 <sys_mkdir+0x40>
    800042fe:	4681                	li	a3,0
    80004300:	4601                	li	a2,0
    80004302:	4585                	li	a1,1
    80004304:	f7040513          	addi	a0,s0,-144
    80004308:	997ff0ef          	jal	ra,80003c9e <create>
    8000430c:	c911                	beqz	a0,80004320 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000430e:	d76fe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    80004312:	c67fe0ef          	jal	ra,80002f78 <end_op>
  return 0;
    80004316:	4501                	li	a0,0
}
    80004318:	60aa                	ld	ra,136(sp)
    8000431a:	640a                	ld	s0,128(sp)
    8000431c:	6149                	addi	sp,sp,144
    8000431e:	8082                	ret
    end_op();
    80004320:	c59fe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80004324:	557d                	li	a0,-1
    80004326:	bfcd                	j	80004318 <sys_mkdir+0x38>

0000000080004328 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004328:	7135                	addi	sp,sp,-160
    8000432a:	ed06                	sd	ra,152(sp)
    8000432c:	e922                	sd	s0,144(sp)
    8000432e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004330:	bd9fe0ef          	jal	ra,80002f08 <begin_op>
  argint(1, &major);
    80004334:	f6c40593          	addi	a1,s0,-148
    80004338:	4505                	li	a0,1
    8000433a:	8bbfd0ef          	jal	ra,80001bf4 <argint>
  argint(2, &minor);
    8000433e:	f6840593          	addi	a1,s0,-152
    80004342:	4509                	li	a0,2
    80004344:	8b1fd0ef          	jal	ra,80001bf4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004348:	08000613          	li	a2,128
    8000434c:	f7040593          	addi	a1,s0,-144
    80004350:	4501                	li	a0,0
    80004352:	8dbfd0ef          	jal	ra,80001c2c <argstr>
    80004356:	02054563          	bltz	a0,80004380 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000435a:	f6841683          	lh	a3,-152(s0)
    8000435e:	f6c41603          	lh	a2,-148(s0)
    80004362:	458d                	li	a1,3
    80004364:	f7040513          	addi	a0,s0,-144
    80004368:	937ff0ef          	jal	ra,80003c9e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000436c:	c911                	beqz	a0,80004380 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000436e:	d16fe0ef          	jal	ra,80002884 <iunlockput>
  end_op();
    80004372:	c07fe0ef          	jal	ra,80002f78 <end_op>
  return 0;
    80004376:	4501                	li	a0,0
}
    80004378:	60ea                	ld	ra,152(sp)
    8000437a:	644a                	ld	s0,144(sp)
    8000437c:	610d                	addi	sp,sp,160
    8000437e:	8082                	ret
    end_op();
    80004380:	bf9fe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80004384:	557d                	li	a0,-1
    80004386:	bfcd                	j	80004378 <sys_mknod+0x50>

0000000080004388 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004388:	7135                	addi	sp,sp,-160
    8000438a:	ed06                	sd	ra,152(sp)
    8000438c:	e922                	sd	s0,144(sp)
    8000438e:	e526                	sd	s1,136(sp)
    80004390:	e14a                	sd	s2,128(sp)
    80004392:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004394:	97dfc0ef          	jal	ra,80000d10 <myproc>
    80004398:	892a                	mv	s2,a0
  
  begin_op();
    8000439a:	b6ffe0ef          	jal	ra,80002f08 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000439e:	08000613          	li	a2,128
    800043a2:	f6040593          	addi	a1,s0,-160
    800043a6:	4501                	li	a0,0
    800043a8:	885fd0ef          	jal	ra,80001c2c <argstr>
    800043ac:	04054163          	bltz	a0,800043ee <sys_chdir+0x66>
    800043b0:	f6040513          	addi	a0,s0,-160
    800043b4:	97dfe0ef          	jal	ra,80002d30 <namei>
    800043b8:	84aa                	mv	s1,a0
    800043ba:	c915                	beqz	a0,800043ee <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800043bc:	ac2fe0ef          	jal	ra,8000267e <ilock>
  if(ip->type != T_DIR){
    800043c0:	04449703          	lh	a4,68(s1)
    800043c4:	4785                	li	a5,1
    800043c6:	02f71863          	bne	a4,a5,800043f6 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800043ca:	8526                	mv	a0,s1
    800043cc:	b5cfe0ef          	jal	ra,80002728 <iunlock>
  iput(p->cwd);
    800043d0:	15093503          	ld	a0,336(s2)
    800043d4:	c28fe0ef          	jal	ra,800027fc <iput>
  end_op();
    800043d8:	ba1fe0ef          	jal	ra,80002f78 <end_op>
  p->cwd = ip;
    800043dc:	14993823          	sd	s1,336(s2)
  return 0;
    800043e0:	4501                	li	a0,0
}
    800043e2:	60ea                	ld	ra,152(sp)
    800043e4:	644a                	ld	s0,144(sp)
    800043e6:	64aa                	ld	s1,136(sp)
    800043e8:	690a                	ld	s2,128(sp)
    800043ea:	610d                	addi	sp,sp,160
    800043ec:	8082                	ret
    end_op();
    800043ee:	b8bfe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    800043f2:	557d                	li	a0,-1
    800043f4:	b7fd                	j	800043e2 <sys_chdir+0x5a>
    iunlockput(ip);
    800043f6:	8526                	mv	a0,s1
    800043f8:	c8cfe0ef          	jal	ra,80002884 <iunlockput>
    end_op();
    800043fc:	b7dfe0ef          	jal	ra,80002f78 <end_op>
    return -1;
    80004400:	557d                	li	a0,-1
    80004402:	b7c5                	j	800043e2 <sys_chdir+0x5a>

0000000080004404 <sys_exec>:

uint64
sys_exec(void)
{
    80004404:	7145                	addi	sp,sp,-464
    80004406:	e786                	sd	ra,456(sp)
    80004408:	e3a2                	sd	s0,448(sp)
    8000440a:	ff26                	sd	s1,440(sp)
    8000440c:	fb4a                	sd	s2,432(sp)
    8000440e:	f74e                	sd	s3,424(sp)
    80004410:	f352                	sd	s4,416(sp)
    80004412:	ef56                	sd	s5,408(sp)
    80004414:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004416:	e3840593          	addi	a1,s0,-456
    8000441a:	4505                	li	a0,1
    8000441c:	ff4fd0ef          	jal	ra,80001c10 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004420:	08000613          	li	a2,128
    80004424:	f4040593          	addi	a1,s0,-192
    80004428:	4501                	li	a0,0
    8000442a:	803fd0ef          	jal	ra,80001c2c <argstr>
    8000442e:	87aa                	mv	a5,a0
    return -1;
    80004430:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004432:	0a07c463          	bltz	a5,800044da <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80004436:	10000613          	li	a2,256
    8000443a:	4581                	li	a1,0
    8000443c:	e4040513          	addi	a0,s0,-448
    80004440:	d0dfb0ef          	jal	ra,8000014c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004444:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004448:	89a6                	mv	s3,s1
    8000444a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000444c:	02000a13          	li	s4,32
    80004450:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004454:	00391513          	slli	a0,s2,0x3
    80004458:	e3040593          	addi	a1,s0,-464
    8000445c:	e3843783          	ld	a5,-456(s0)
    80004460:	953e                	add	a0,a0,a5
    80004462:	f08fd0ef          	jal	ra,80001b6a <fetchaddr>
    80004466:	02054663          	bltz	a0,80004492 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    8000446a:	e3043783          	ld	a5,-464(s0)
    8000446e:	cf8d                	beqz	a5,800044a8 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004470:	c8dfb0ef          	jal	ra,800000fc <kalloc>
    80004474:	85aa                	mv	a1,a0
    80004476:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000447a:	cd01                	beqz	a0,80004492 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000447c:	6605                	lui	a2,0x1
    8000447e:	e3043503          	ld	a0,-464(s0)
    80004482:	f32fd0ef          	jal	ra,80001bb4 <fetchstr>
    80004486:	00054663          	bltz	a0,80004492 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    8000448a:	0905                	addi	s2,s2,1
    8000448c:	09a1                	addi	s3,s3,8
    8000448e:	fd4911e3          	bne	s2,s4,80004450 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004492:	10048913          	addi	s2,s1,256
    80004496:	6088                	ld	a0,0(s1)
    80004498:	c121                	beqz	a0,800044d8 <sys_exec+0xd4>
    kfree(argv[i]);
    8000449a:	b83fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000449e:	04a1                	addi	s1,s1,8
    800044a0:	ff249be3          	bne	s1,s2,80004496 <sys_exec+0x92>
  return -1;
    800044a4:	557d                	li	a0,-1
    800044a6:	a815                	j	800044da <sys_exec+0xd6>
      argv[i] = 0;
    800044a8:	0a8e                	slli	s5,s5,0x3
    800044aa:	fc040793          	addi	a5,s0,-64
    800044ae:	9abe                	add	s5,s5,a5
    800044b0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800044b4:	e4040593          	addi	a1,s0,-448
    800044b8:	f4040513          	addi	a0,s0,-192
    800044bc:	c18ff0ef          	jal	ra,800038d4 <exec>
    800044c0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800044c2:	10048993          	addi	s3,s1,256
    800044c6:	6088                	ld	a0,0(s1)
    800044c8:	c511                	beqz	a0,800044d4 <sys_exec+0xd0>
    kfree(argv[i]);
    800044ca:	b53fb0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800044ce:	04a1                	addi	s1,s1,8
    800044d0:	ff349be3          	bne	s1,s3,800044c6 <sys_exec+0xc2>
  return ret;
    800044d4:	854a                	mv	a0,s2
    800044d6:	a011                	j	800044da <sys_exec+0xd6>
  return -1;
    800044d8:	557d                	li	a0,-1
}
    800044da:	60be                	ld	ra,456(sp)
    800044dc:	641e                	ld	s0,448(sp)
    800044de:	74fa                	ld	s1,440(sp)
    800044e0:	795a                	ld	s2,432(sp)
    800044e2:	79ba                	ld	s3,424(sp)
    800044e4:	7a1a                	ld	s4,416(sp)
    800044e6:	6afa                	ld	s5,408(sp)
    800044e8:	6179                	addi	sp,sp,464
    800044ea:	8082                	ret

00000000800044ec <sys_pipe>:

uint64
sys_pipe(void)
{
    800044ec:	7139                	addi	sp,sp,-64
    800044ee:	fc06                	sd	ra,56(sp)
    800044f0:	f822                	sd	s0,48(sp)
    800044f2:	f426                	sd	s1,40(sp)
    800044f4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800044f6:	81bfc0ef          	jal	ra,80000d10 <myproc>
    800044fa:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800044fc:	fd840593          	addi	a1,s0,-40
    80004500:	4501                	li	a0,0
    80004502:	f0efd0ef          	jal	ra,80001c10 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004506:	fc840593          	addi	a1,s0,-56
    8000450a:	fd040513          	addi	a0,s0,-48
    8000450e:	8e2ff0ef          	jal	ra,800035f0 <pipealloc>
    return -1;
    80004512:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004514:	0a054463          	bltz	a0,800045bc <sys_pipe+0xd0>
  fd0 = -1;
    80004518:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000451c:	fd043503          	ld	a0,-48(s0)
    80004520:	f40ff0ef          	jal	ra,80003c60 <fdalloc>
    80004524:	fca42223          	sw	a0,-60(s0)
    80004528:	08054163          	bltz	a0,800045aa <sys_pipe+0xbe>
    8000452c:	fc843503          	ld	a0,-56(s0)
    80004530:	f30ff0ef          	jal	ra,80003c60 <fdalloc>
    80004534:	fca42023          	sw	a0,-64(s0)
    80004538:	06054063          	bltz	a0,80004598 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000453c:	4691                	li	a3,4
    8000453e:	fc440613          	addi	a2,s0,-60
    80004542:	fd843583          	ld	a1,-40(s0)
    80004546:	68a8                	ld	a0,80(s1)
    80004548:	c7efc0ef          	jal	ra,800009c6 <copyout>
    8000454c:	00054e63          	bltz	a0,80004568 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004550:	4691                	li	a3,4
    80004552:	fc040613          	addi	a2,s0,-64
    80004556:	fd843583          	ld	a1,-40(s0)
    8000455a:	0591                	addi	a1,a1,4
    8000455c:	68a8                	ld	a0,80(s1)
    8000455e:	c68fc0ef          	jal	ra,800009c6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004562:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004564:	04055c63          	bgez	a0,800045bc <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80004568:	fc442783          	lw	a5,-60(s0)
    8000456c:	07e9                	addi	a5,a5,26
    8000456e:	078e                	slli	a5,a5,0x3
    80004570:	97a6                	add	a5,a5,s1
    80004572:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004576:	fc042503          	lw	a0,-64(s0)
    8000457a:	0569                	addi	a0,a0,26
    8000457c:	050e                	slli	a0,a0,0x3
    8000457e:	94aa                	add	s1,s1,a0
    80004580:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004584:	fd043503          	ld	a0,-48(s0)
    80004588:	d9dfe0ef          	jal	ra,80003324 <fileclose>
    fileclose(wf);
    8000458c:	fc843503          	ld	a0,-56(s0)
    80004590:	d95fe0ef          	jal	ra,80003324 <fileclose>
    return -1;
    80004594:	57fd                	li	a5,-1
    80004596:	a01d                	j	800045bc <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004598:	fc442783          	lw	a5,-60(s0)
    8000459c:	0007c763          	bltz	a5,800045aa <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800045a0:	07e9                	addi	a5,a5,26
    800045a2:	078e                	slli	a5,a5,0x3
    800045a4:	94be                	add	s1,s1,a5
    800045a6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800045aa:	fd043503          	ld	a0,-48(s0)
    800045ae:	d77fe0ef          	jal	ra,80003324 <fileclose>
    fileclose(wf);
    800045b2:	fc843503          	ld	a0,-56(s0)
    800045b6:	d6ffe0ef          	jal	ra,80003324 <fileclose>
    return -1;
    800045ba:	57fd                	li	a5,-1
}
    800045bc:	853e                	mv	a0,a5
    800045be:	70e2                	ld	ra,56(sp)
    800045c0:	7442                	ld	s0,48(sp)
    800045c2:	74a2                	ld	s1,40(sp)
    800045c4:	6121                	addi	sp,sp,64
    800045c6:	8082                	ret
	...

00000000800045d0 <kernelvec>:
    800045d0:	7111                	addi	sp,sp,-256
    800045d2:	e006                	sd	ra,0(sp)
    800045d4:	e40a                	sd	sp,8(sp)
    800045d6:	e80e                	sd	gp,16(sp)
    800045d8:	ec12                	sd	tp,24(sp)
    800045da:	f016                	sd	t0,32(sp)
    800045dc:	f41a                	sd	t1,40(sp)
    800045de:	f81e                	sd	t2,48(sp)
    800045e0:	e4aa                	sd	a0,72(sp)
    800045e2:	e8ae                	sd	a1,80(sp)
    800045e4:	ecb2                	sd	a2,88(sp)
    800045e6:	f0b6                	sd	a3,96(sp)
    800045e8:	f4ba                	sd	a4,104(sp)
    800045ea:	f8be                	sd	a5,112(sp)
    800045ec:	fcc2                	sd	a6,120(sp)
    800045ee:	e146                	sd	a7,128(sp)
    800045f0:	edf2                	sd	t3,216(sp)
    800045f2:	f1f6                	sd	t4,224(sp)
    800045f4:	f5fa                	sd	t5,232(sp)
    800045f6:	f9fe                	sd	t6,240(sp)
    800045f8:	c82fd0ef          	jal	ra,80001a7a <kerneltrap>
    800045fc:	6082                	ld	ra,0(sp)
    800045fe:	6122                	ld	sp,8(sp)
    80004600:	61c2                	ld	gp,16(sp)
    80004602:	7282                	ld	t0,32(sp)
    80004604:	7322                	ld	t1,40(sp)
    80004606:	73c2                	ld	t2,48(sp)
    80004608:	6526                	ld	a0,72(sp)
    8000460a:	65c6                	ld	a1,80(sp)
    8000460c:	6666                	ld	a2,88(sp)
    8000460e:	7686                	ld	a3,96(sp)
    80004610:	7726                	ld	a4,104(sp)
    80004612:	77c6                	ld	a5,112(sp)
    80004614:	7866                	ld	a6,120(sp)
    80004616:	688a                	ld	a7,128(sp)
    80004618:	6e6e                	ld	t3,216(sp)
    8000461a:	7e8e                	ld	t4,224(sp)
    8000461c:	7f2e                	ld	t5,232(sp)
    8000461e:	7fce                	ld	t6,240(sp)
    80004620:	6111                	addi	sp,sp,256
    80004622:	10200073          	sret
	...

000000008000462e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000462e:	1141                	addi	sp,sp,-16
    80004630:	e422                	sd	s0,8(sp)
    80004632:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80004634:	0c0007b7          	lui	a5,0xc000
    80004638:	4705                	li	a4,1
    8000463a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000463c:	c3d8                	sw	a4,4(a5)
}
    8000463e:	6422                	ld	s0,8(sp)
    80004640:	0141                	addi	sp,sp,16
    80004642:	8082                	ret

0000000080004644 <plicinithart>:

void
plicinithart(void)
{
    80004644:	1141                	addi	sp,sp,-16
    80004646:	e406                	sd	ra,8(sp)
    80004648:	e022                	sd	s0,0(sp)
    8000464a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000464c:	e98fc0ef          	jal	ra,80000ce4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80004650:	0085171b          	slliw	a4,a0,0x8
    80004654:	0c0027b7          	lui	a5,0xc002
    80004658:	97ba                	add	a5,a5,a4
    8000465a:	40200713          	li	a4,1026
    8000465e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80004662:	00d5151b          	slliw	a0,a0,0xd
    80004666:	0c2017b7          	lui	a5,0xc201
    8000466a:	953e                	add	a0,a0,a5
    8000466c:	00052023          	sw	zero,0(a0)
}
    80004670:	60a2                	ld	ra,8(sp)
    80004672:	6402                	ld	s0,0(sp)
    80004674:	0141                	addi	sp,sp,16
    80004676:	8082                	ret

0000000080004678 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80004678:	1141                	addi	sp,sp,-16
    8000467a:	e406                	sd	ra,8(sp)
    8000467c:	e022                	sd	s0,0(sp)
    8000467e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80004680:	e64fc0ef          	jal	ra,80000ce4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80004684:	00d5179b          	slliw	a5,a0,0xd
    80004688:	0c201537          	lui	a0,0xc201
    8000468c:	953e                	add	a0,a0,a5
  return irq;
}
    8000468e:	4148                	lw	a0,4(a0)
    80004690:	60a2                	ld	ra,8(sp)
    80004692:	6402                	ld	s0,0(sp)
    80004694:	0141                	addi	sp,sp,16
    80004696:	8082                	ret

0000000080004698 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80004698:	1101                	addi	sp,sp,-32
    8000469a:	ec06                	sd	ra,24(sp)
    8000469c:	e822                	sd	s0,16(sp)
    8000469e:	e426                	sd	s1,8(sp)
    800046a0:	1000                	addi	s0,sp,32
    800046a2:	84aa                	mv	s1,a0
  int hart = cpuid();
    800046a4:	e40fc0ef          	jal	ra,80000ce4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800046a8:	00d5151b          	slliw	a0,a0,0xd
    800046ac:	0c2017b7          	lui	a5,0xc201
    800046b0:	97aa                	add	a5,a5,a0
    800046b2:	c3c4                	sw	s1,4(a5)
}
    800046b4:	60e2                	ld	ra,24(sp)
    800046b6:	6442                	ld	s0,16(sp)
    800046b8:	64a2                	ld	s1,8(sp)
    800046ba:	6105                	addi	sp,sp,32
    800046bc:	8082                	ret

00000000800046be <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800046be:	1141                	addi	sp,sp,-16
    800046c0:	e406                	sd	ra,8(sp)
    800046c2:	e022                	sd	s0,0(sp)
    800046c4:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800046c6:	479d                	li	a5,7
    800046c8:	04a7ca63          	blt	a5,a0,8000471c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800046cc:	00019797          	auipc	a5,0x19
    800046d0:	13478793          	addi	a5,a5,308 # 8001d800 <disk>
    800046d4:	97aa                	add	a5,a5,a0
    800046d6:	0187c783          	lbu	a5,24(a5)
    800046da:	e7b9                	bnez	a5,80004728 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800046dc:	00451613          	slli	a2,a0,0x4
    800046e0:	00019797          	auipc	a5,0x19
    800046e4:	12078793          	addi	a5,a5,288 # 8001d800 <disk>
    800046e8:	6394                	ld	a3,0(a5)
    800046ea:	96b2                	add	a3,a3,a2
    800046ec:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800046f0:	6398                	ld	a4,0(a5)
    800046f2:	9732                	add	a4,a4,a2
    800046f4:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800046f8:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800046fc:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004700:	953e                	add	a0,a0,a5
    80004702:	4785                	li	a5,1
    80004704:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80004708:	00019517          	auipc	a0,0x19
    8000470c:	11050513          	addi	a0,a0,272 # 8001d818 <disk+0x18>
    80004710:	c21fc0ef          	jal	ra,80001330 <wakeup>
}
    80004714:	60a2                	ld	ra,8(sp)
    80004716:	6402                	ld	s0,0(sp)
    80004718:	0141                	addi	sp,sp,16
    8000471a:	8082                	ret
    panic("free_desc 1");
    8000471c:	00003517          	auipc	a0,0x3
    80004720:	ffc50513          	addi	a0,a0,-4 # 80007718 <syscalls+0x300>
    80004724:	41f000ef          	jal	ra,80005342 <panic>
    panic("free_desc 2");
    80004728:	00003517          	auipc	a0,0x3
    8000472c:	00050513          	mv	a0,a0
    80004730:	413000ef          	jal	ra,80005342 <panic>

0000000080004734 <virtio_disk_init>:
{
    80004734:	1101                	addi	sp,sp,-32
    80004736:	ec06                	sd	ra,24(sp)
    80004738:	e822                	sd	s0,16(sp)
    8000473a:	e426                	sd	s1,8(sp)
    8000473c:	e04a                	sd	s2,0(sp)
    8000473e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80004740:	00003597          	auipc	a1,0x3
    80004744:	ff858593          	addi	a1,a1,-8 # 80007738 <syscalls+0x320>
    80004748:	00019517          	auipc	a0,0x19
    8000474c:	1e050513          	addi	a0,a0,480 # 8001d928 <disk+0x128>
    80004750:	68f000ef          	jal	ra,800055de <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004754:	100017b7          	lui	a5,0x10001
    80004758:	4398                	lw	a4,0(a5)
    8000475a:	2701                	sext.w	a4,a4
    8000475c:	747277b7          	lui	a5,0x74727
    80004760:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80004764:	14f71263          	bne	a4,a5,800048a8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80004768:	100017b7          	lui	a5,0x10001
    8000476c:	43dc                	lw	a5,4(a5)
    8000476e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80004770:	4709                	li	a4,2
    80004772:	12e79b63          	bne	a5,a4,800048a8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004776:	100017b7          	lui	a5,0x10001
    8000477a:	479c                	lw	a5,8(a5)
    8000477c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000477e:	12e79563          	bne	a5,a4,800048a8 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80004782:	100017b7          	lui	a5,0x10001
    80004786:	47d8                	lw	a4,12(a5)
    80004788:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000478a:	554d47b7          	lui	a5,0x554d4
    8000478e:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004792:	10f71b63          	bne	a4,a5,800048a8 <virtio_disk_init+0x174>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004796:	100017b7          	lui	a5,0x10001
    8000479a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000479e:	4705                	li	a4,1
    800047a0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800047a2:	470d                	li	a4,3
    800047a4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800047a6:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800047a8:	c7ffe737          	lui	a4,0xc7ffe
    800047ac:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd8d1f>
    800047b0:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800047b2:	2701                	sext.w	a4,a4
    800047b4:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800047b6:	472d                	li	a4,11
    800047b8:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800047ba:	0707a903          	lw	s2,112(a5)
    800047be:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800047c0:	00897793          	andi	a5,s2,8
    800047c4:	0e078863          	beqz	a5,800048b4 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800047c8:	100017b7          	lui	a5,0x10001
    800047cc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800047d0:	43fc                	lw	a5,68(a5)
    800047d2:	2781                	sext.w	a5,a5
    800047d4:	0e079663          	bnez	a5,800048c0 <virtio_disk_init+0x18c>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800047d8:	100017b7          	lui	a5,0x10001
    800047dc:	5bdc                	lw	a5,52(a5)
    800047de:	2781                	sext.w	a5,a5
  if(max == 0)
    800047e0:	0e078663          	beqz	a5,800048cc <virtio_disk_init+0x198>
  if(max < NUM)
    800047e4:	471d                	li	a4,7
    800047e6:	0ef77963          	bgeu	a4,a5,800048d8 <virtio_disk_init+0x1a4>
  disk.desc = kalloc();
    800047ea:	913fb0ef          	jal	ra,800000fc <kalloc>
    800047ee:	00019497          	auipc	s1,0x19
    800047f2:	01248493          	addi	s1,s1,18 # 8001d800 <disk>
    800047f6:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800047f8:	905fb0ef          	jal	ra,800000fc <kalloc>
    800047fc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800047fe:	8fffb0ef          	jal	ra,800000fc <kalloc>
    80004802:	87aa                	mv	a5,a0
    80004804:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004806:	6088                	ld	a0,0(s1)
    80004808:	cd71                	beqz	a0,800048e4 <virtio_disk_init+0x1b0>
    8000480a:	00019717          	auipc	a4,0x19
    8000480e:	ffe73703          	ld	a4,-2(a4) # 8001d808 <disk+0x8>
    80004812:	cb69                	beqz	a4,800048e4 <virtio_disk_init+0x1b0>
    80004814:	cbe1                	beqz	a5,800048e4 <virtio_disk_init+0x1b0>
  memset(disk.desc, 0, PGSIZE);
    80004816:	6605                	lui	a2,0x1
    80004818:	4581                	li	a1,0
    8000481a:	933fb0ef          	jal	ra,8000014c <memset>
  memset(disk.avail, 0, PGSIZE);
    8000481e:	00019497          	auipc	s1,0x19
    80004822:	fe248493          	addi	s1,s1,-30 # 8001d800 <disk>
    80004826:	6605                	lui	a2,0x1
    80004828:	4581                	li	a1,0
    8000482a:	6488                	ld	a0,8(s1)
    8000482c:	921fb0ef          	jal	ra,8000014c <memset>
  memset(disk.used, 0, PGSIZE);
    80004830:	6605                	lui	a2,0x1
    80004832:	4581                	li	a1,0
    80004834:	6888                	ld	a0,16(s1)
    80004836:	917fb0ef          	jal	ra,8000014c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000483a:	100017b7          	lui	a5,0x10001
    8000483e:	4721                	li	a4,8
    80004840:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004842:	4098                	lw	a4,0(s1)
    80004844:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004848:	40d8                	lw	a4,4(s1)
    8000484a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000484e:	6498                	ld	a4,8(s1)
    80004850:	0007069b          	sext.w	a3,a4
    80004854:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004858:	9701                	srai	a4,a4,0x20
    8000485a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000485e:	6898                	ld	a4,16(s1)
    80004860:	0007069b          	sext.w	a3,a4
    80004864:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004868:	9701                	srai	a4,a4,0x20
    8000486a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000486e:	4685                	li	a3,1
    80004870:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80004872:	4705                	li	a4,1
    80004874:	00d48c23          	sb	a3,24(s1)
    80004878:	00e48ca3          	sb	a4,25(s1)
    8000487c:	00e48d23          	sb	a4,26(s1)
    80004880:	00e48da3          	sb	a4,27(s1)
    80004884:	00e48e23          	sb	a4,28(s1)
    80004888:	00e48ea3          	sb	a4,29(s1)
    8000488c:	00e48f23          	sb	a4,30(s1)
    80004890:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004894:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004898:	0727a823          	sw	s2,112(a5)
}
    8000489c:	60e2                	ld	ra,24(sp)
    8000489e:	6442                	ld	s0,16(sp)
    800048a0:	64a2                	ld	s1,8(sp)
    800048a2:	6902                	ld	s2,0(sp)
    800048a4:	6105                	addi	sp,sp,32
    800048a6:	8082                	ret
    panic("could not find virtio disk");
    800048a8:	00003517          	auipc	a0,0x3
    800048ac:	ea050513          	addi	a0,a0,-352 # 80007748 <syscalls+0x330>
    800048b0:	293000ef          	jal	ra,80005342 <panic>
    panic("virtio disk FEATURES_OK unset");
    800048b4:	00003517          	auipc	a0,0x3
    800048b8:	eb450513          	addi	a0,a0,-332 # 80007768 <syscalls+0x350>
    800048bc:	287000ef          	jal	ra,80005342 <panic>
    panic("virtio disk should not be ready");
    800048c0:	00003517          	auipc	a0,0x3
    800048c4:	ec850513          	addi	a0,a0,-312 # 80007788 <syscalls+0x370>
    800048c8:	27b000ef          	jal	ra,80005342 <panic>
    panic("virtio disk has no queue 0");
    800048cc:	00003517          	auipc	a0,0x3
    800048d0:	edc50513          	addi	a0,a0,-292 # 800077a8 <syscalls+0x390>
    800048d4:	26f000ef          	jal	ra,80005342 <panic>
    panic("virtio disk max queue too short");
    800048d8:	00003517          	auipc	a0,0x3
    800048dc:	ef050513          	addi	a0,a0,-272 # 800077c8 <syscalls+0x3b0>
    800048e0:	263000ef          	jal	ra,80005342 <panic>
    panic("virtio disk kalloc");
    800048e4:	00003517          	auipc	a0,0x3
    800048e8:	f0450513          	addi	a0,a0,-252 # 800077e8 <syscalls+0x3d0>
    800048ec:	257000ef          	jal	ra,80005342 <panic>

00000000800048f0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800048f0:	7159                	addi	sp,sp,-112
    800048f2:	f486                	sd	ra,104(sp)
    800048f4:	f0a2                	sd	s0,96(sp)
    800048f6:	eca6                	sd	s1,88(sp)
    800048f8:	e8ca                	sd	s2,80(sp)
    800048fa:	e4ce                	sd	s3,72(sp)
    800048fc:	e0d2                	sd	s4,64(sp)
    800048fe:	fc56                	sd	s5,56(sp)
    80004900:	f85a                	sd	s6,48(sp)
    80004902:	f45e                	sd	s7,40(sp)
    80004904:	f062                	sd	s8,32(sp)
    80004906:	ec66                	sd	s9,24(sp)
    80004908:	e86a                	sd	s10,16(sp)
    8000490a:	1880                	addi	s0,sp,112
    8000490c:	892a                	mv	s2,a0
    8000490e:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004910:	00c52c83          	lw	s9,12(a0)
    80004914:	001c9c9b          	slliw	s9,s9,0x1
    80004918:	1c82                	slli	s9,s9,0x20
    8000491a:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000491e:	00019517          	auipc	a0,0x19
    80004922:	00a50513          	addi	a0,a0,10 # 8001d928 <disk+0x128>
    80004926:	539000ef          	jal	ra,8000565e <acquire>
  for(int i = 0; i < 3; i++){
    8000492a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000492c:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000492e:	00019b17          	auipc	s6,0x19
    80004932:	ed2b0b13          	addi	s6,s6,-302 # 8001d800 <disk>
  for(int i = 0; i < 3; i++){
    80004936:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80004938:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000493a:	00019c17          	auipc	s8,0x19
    8000493e:	feec0c13          	addi	s8,s8,-18 # 8001d928 <disk+0x128>
    80004942:	a0b5                	j	800049ae <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    80004944:	00fb06b3          	add	a3,s6,a5
    80004948:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    8000494c:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000494e:	0207c563          	bltz	a5,80004978 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80004952:	2485                	addiw	s1,s1,1
    80004954:	0711                	addi	a4,a4,4
    80004956:	1d548c63          	beq	s1,s5,80004b2e <virtio_disk_rw+0x23e>
    idx[i] = alloc_desc();
    8000495a:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    8000495c:	00019697          	auipc	a3,0x19
    80004960:	ea468693          	addi	a3,a3,-348 # 8001d800 <disk>
    80004964:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80004966:	0186c583          	lbu	a1,24(a3)
    8000496a:	fde9                	bnez	a1,80004944 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    8000496c:	2785                	addiw	a5,a5,1
    8000496e:	0685                	addi	a3,a3,1
    80004970:	ff779be3          	bne	a5,s7,80004966 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80004974:	57fd                	li	a5,-1
    80004976:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80004978:	02905463          	blez	s1,800049a0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    8000497c:	f9042503          	lw	a0,-112(s0)
    80004980:	d3fff0ef          	jal	ra,800046be <free_desc>
      for(int j = 0; j < i; j++)
    80004984:	4785                	li	a5,1
    80004986:	0097dd63          	bge	a5,s1,800049a0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    8000498a:	f9442503          	lw	a0,-108(s0)
    8000498e:	d31ff0ef          	jal	ra,800046be <free_desc>
      for(int j = 0; j < i; j++)
    80004992:	4789                	li	a5,2
    80004994:	0097d663          	bge	a5,s1,800049a0 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    80004998:	f9842503          	lw	a0,-104(s0)
    8000499c:	d23ff0ef          	jal	ra,800046be <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800049a0:	85e2                	mv	a1,s8
    800049a2:	00019517          	auipc	a0,0x19
    800049a6:	e7650513          	addi	a0,a0,-394 # 8001d818 <disk+0x18>
    800049aa:	93bfc0ef          	jal	ra,800012e4 <sleep>
  for(int i = 0; i < 3; i++){
    800049ae:	f9040713          	addi	a4,s0,-112
    800049b2:	84ce                	mv	s1,s3
    800049b4:	b75d                	j	8000495a <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800049b6:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800049ba:	00479693          	slli	a3,a5,0x4
    800049be:	00019797          	auipc	a5,0x19
    800049c2:	e4278793          	addi	a5,a5,-446 # 8001d800 <disk>
    800049c6:	97b6                	add	a5,a5,a3
    800049c8:	4685                	li	a3,1
    800049ca:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800049cc:	00019597          	auipc	a1,0x19
    800049d0:	e3458593          	addi	a1,a1,-460 # 8001d800 <disk>
    800049d4:	00a60793          	addi	a5,a2,10
    800049d8:	0792                	slli	a5,a5,0x4
    800049da:	97ae                	add	a5,a5,a1
    800049dc:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800049e0:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800049e4:	f6070693          	addi	a3,a4,-160
    800049e8:	619c                	ld	a5,0(a1)
    800049ea:	97b6                	add	a5,a5,a3
    800049ec:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800049ee:	6188                	ld	a0,0(a1)
    800049f0:	96aa                	add	a3,a3,a0
    800049f2:	47c1                	li	a5,16
    800049f4:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800049f6:	4785                	li	a5,1
    800049f8:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800049fc:	f9442783          	lw	a5,-108(s0)
    80004a00:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004a04:	0792                	slli	a5,a5,0x4
    80004a06:	953e                	add	a0,a0,a5
    80004a08:	05890693          	addi	a3,s2,88
    80004a0c:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80004a0e:	6188                	ld	a0,0(a1)
    80004a10:	97aa                	add	a5,a5,a0
    80004a12:	40000693          	li	a3,1024
    80004a16:	c794                	sw	a3,8(a5)
  if(write)
    80004a18:	100d0763          	beqz	s10,80004b26 <virtio_disk_rw+0x236>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80004a1c:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004a20:	00c7d683          	lhu	a3,12(a5)
    80004a24:	0016e693          	ori	a3,a3,1
    80004a28:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80004a2c:	f9842583          	lw	a1,-104(s0)
    80004a30:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004a34:	00019697          	auipc	a3,0x19
    80004a38:	dcc68693          	addi	a3,a3,-564 # 8001d800 <disk>
    80004a3c:	00260793          	addi	a5,a2,2
    80004a40:	0792                	slli	a5,a5,0x4
    80004a42:	97b6                	add	a5,a5,a3
    80004a44:	587d                	li	a6,-1
    80004a46:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004a4a:	0592                	slli	a1,a1,0x4
    80004a4c:	952e                	add	a0,a0,a1
    80004a4e:	f9070713          	addi	a4,a4,-112
    80004a52:	9736                	add	a4,a4,a3
    80004a54:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80004a56:	6298                	ld	a4,0(a3)
    80004a58:	972e                	add	a4,a4,a1
    80004a5a:	4585                	li	a1,1
    80004a5c:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004a5e:	4509                	li	a0,2
    80004a60:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80004a64:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004a68:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80004a6c:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004a70:	6698                	ld	a4,8(a3)
    80004a72:	00275783          	lhu	a5,2(a4)
    80004a76:	8b9d                	andi	a5,a5,7
    80004a78:	0786                	slli	a5,a5,0x1
    80004a7a:	97ba                	add	a5,a5,a4
    80004a7c:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    80004a80:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004a84:	6698                	ld	a4,8(a3)
    80004a86:	00275783          	lhu	a5,2(a4)
    80004a8a:	2785                	addiw	a5,a5,1
    80004a8c:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004a90:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004a94:	100017b7          	lui	a5,0x10001
    80004a98:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004a9c:	00492703          	lw	a4,4(s2)
    80004aa0:	4785                	li	a5,1
    80004aa2:	00f71f63          	bne	a4,a5,80004ac0 <virtio_disk_rw+0x1d0>
    sleep(b, &disk.vdisk_lock);
    80004aa6:	00019997          	auipc	s3,0x19
    80004aaa:	e8298993          	addi	s3,s3,-382 # 8001d928 <disk+0x128>
  while(b->disk == 1) {
    80004aae:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80004ab0:	85ce                	mv	a1,s3
    80004ab2:	854a                	mv	a0,s2
    80004ab4:	831fc0ef          	jal	ra,800012e4 <sleep>
  while(b->disk == 1) {
    80004ab8:	00492783          	lw	a5,4(s2)
    80004abc:	fe978ae3          	beq	a5,s1,80004ab0 <virtio_disk_rw+0x1c0>
  }

  disk.info[idx[0]].b = 0;
    80004ac0:	f9042903          	lw	s2,-112(s0)
    80004ac4:	00290793          	addi	a5,s2,2
    80004ac8:	00479713          	slli	a4,a5,0x4
    80004acc:	00019797          	auipc	a5,0x19
    80004ad0:	d3478793          	addi	a5,a5,-716 # 8001d800 <disk>
    80004ad4:	97ba                	add	a5,a5,a4
    80004ad6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004ada:	00019997          	auipc	s3,0x19
    80004ade:	d2698993          	addi	s3,s3,-730 # 8001d800 <disk>
    80004ae2:	00491713          	slli	a4,s2,0x4
    80004ae6:	0009b783          	ld	a5,0(s3)
    80004aea:	97ba                	add	a5,a5,a4
    80004aec:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004af0:	854a                	mv	a0,s2
    80004af2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004af6:	bc9ff0ef          	jal	ra,800046be <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004afa:	8885                	andi	s1,s1,1
    80004afc:	f0fd                	bnez	s1,80004ae2 <virtio_disk_rw+0x1f2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004afe:	00019517          	auipc	a0,0x19
    80004b02:	e2a50513          	addi	a0,a0,-470 # 8001d928 <disk+0x128>
    80004b06:	3f1000ef          	jal	ra,800056f6 <release>
}
    80004b0a:	70a6                	ld	ra,104(sp)
    80004b0c:	7406                	ld	s0,96(sp)
    80004b0e:	64e6                	ld	s1,88(sp)
    80004b10:	6946                	ld	s2,80(sp)
    80004b12:	69a6                	ld	s3,72(sp)
    80004b14:	6a06                	ld	s4,64(sp)
    80004b16:	7ae2                	ld	s5,56(sp)
    80004b18:	7b42                	ld	s6,48(sp)
    80004b1a:	7ba2                	ld	s7,40(sp)
    80004b1c:	7c02                	ld	s8,32(sp)
    80004b1e:	6ce2                	ld	s9,24(sp)
    80004b20:	6d42                	ld	s10,16(sp)
    80004b22:	6165                	addi	sp,sp,112
    80004b24:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80004b26:	4689                	li	a3,2
    80004b28:	00d79623          	sh	a3,12(a5)
    80004b2c:	bdd5                	j	80004a20 <virtio_disk_rw+0x130>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004b2e:	f9042603          	lw	a2,-112(s0)
    80004b32:	00a60713          	addi	a4,a2,10
    80004b36:	0712                	slli	a4,a4,0x4
    80004b38:	00019517          	auipc	a0,0x19
    80004b3c:	cd050513          	addi	a0,a0,-816 # 8001d808 <disk+0x8>
    80004b40:	953a                	add	a0,a0,a4
  if(write)
    80004b42:	e60d1ae3          	bnez	s10,800049b6 <virtio_disk_rw+0xc6>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80004b46:	00a60793          	addi	a5,a2,10
    80004b4a:	00479693          	slli	a3,a5,0x4
    80004b4e:	00019797          	auipc	a5,0x19
    80004b52:	cb278793          	addi	a5,a5,-846 # 8001d800 <disk>
    80004b56:	97b6                	add	a5,a5,a3
    80004b58:	0007a423          	sw	zero,8(a5)
    80004b5c:	bd85                	j	800049cc <virtio_disk_rw+0xdc>

0000000080004b5e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004b5e:	1101                	addi	sp,sp,-32
    80004b60:	ec06                	sd	ra,24(sp)
    80004b62:	e822                	sd	s0,16(sp)
    80004b64:	e426                	sd	s1,8(sp)
    80004b66:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004b68:	00019497          	auipc	s1,0x19
    80004b6c:	c9848493          	addi	s1,s1,-872 # 8001d800 <disk>
    80004b70:	00019517          	auipc	a0,0x19
    80004b74:	db850513          	addi	a0,a0,-584 # 8001d928 <disk+0x128>
    80004b78:	2e7000ef          	jal	ra,8000565e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004b7c:	10001737          	lui	a4,0x10001
    80004b80:	533c                	lw	a5,96(a4)
    80004b82:	8b8d                	andi	a5,a5,3
    80004b84:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80004b86:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004b8a:	689c                	ld	a5,16(s1)
    80004b8c:	0204d703          	lhu	a4,32(s1)
    80004b90:	0027d783          	lhu	a5,2(a5)
    80004b94:	04f70663          	beq	a4,a5,80004be0 <virtio_disk_intr+0x82>
    __sync_synchronize();
    80004b98:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004b9c:	6898                	ld	a4,16(s1)
    80004b9e:	0204d783          	lhu	a5,32(s1)
    80004ba2:	8b9d                	andi	a5,a5,7
    80004ba4:	078e                	slli	a5,a5,0x3
    80004ba6:	97ba                	add	a5,a5,a4
    80004ba8:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004baa:	00278713          	addi	a4,a5,2
    80004bae:	0712                	slli	a4,a4,0x4
    80004bb0:	9726                	add	a4,a4,s1
    80004bb2:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80004bb6:	e321                	bnez	a4,80004bf6 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004bb8:	0789                	addi	a5,a5,2
    80004bba:	0792                	slli	a5,a5,0x4
    80004bbc:	97a6                	add	a5,a5,s1
    80004bbe:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004bc0:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004bc4:	f6cfc0ef          	jal	ra,80001330 <wakeup>

    disk.used_idx += 1;
    80004bc8:	0204d783          	lhu	a5,32(s1)
    80004bcc:	2785                	addiw	a5,a5,1
    80004bce:	17c2                	slli	a5,a5,0x30
    80004bd0:	93c1                	srli	a5,a5,0x30
    80004bd2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004bd6:	6898                	ld	a4,16(s1)
    80004bd8:	00275703          	lhu	a4,2(a4)
    80004bdc:	faf71ee3          	bne	a4,a5,80004b98 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80004be0:	00019517          	auipc	a0,0x19
    80004be4:	d4850513          	addi	a0,a0,-696 # 8001d928 <disk+0x128>
    80004be8:	30f000ef          	jal	ra,800056f6 <release>
}
    80004bec:	60e2                	ld	ra,24(sp)
    80004bee:	6442                	ld	s0,16(sp)
    80004bf0:	64a2                	ld	s1,8(sp)
    80004bf2:	6105                	addi	sp,sp,32
    80004bf4:	8082                	ret
      panic("virtio_disk_intr status");
    80004bf6:	00003517          	auipc	a0,0x3
    80004bfa:	c0a50513          	addi	a0,a0,-1014 # 80007800 <syscalls+0x3e8>
    80004bfe:	744000ef          	jal	ra,80005342 <panic>

0000000080004c02 <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004c02:	1141                	addi	sp,sp,-16
    80004c04:	e422                	sd	s0,8(sp)
    80004c06:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004c08:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004c0c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004c10:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004c14:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004c18:	577d                	li	a4,-1
    80004c1a:	177e                	slli	a4,a4,0x3f
    80004c1c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004c1e:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004c22:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004c26:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004c2a:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004c2e:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004c32:	000f4737          	lui	a4,0xf4
    80004c36:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004c3a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004c3c:	14d79073          	csrw	0x14d,a5
}
    80004c40:	6422                	ld	s0,8(sp)
    80004c42:	0141                	addi	sp,sp,16
    80004c44:	8082                	ret

0000000080004c46 <start>:
{
    80004c46:	1141                	addi	sp,sp,-16
    80004c48:	e406                	sd	ra,8(sp)
    80004c4a:	e022                	sd	s0,0(sp)
    80004c4c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004c4e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004c52:	7779                	lui	a4,0xffffe
    80004c54:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd8dbf>
    80004c58:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004c5a:	6705                	lui	a4,0x1
    80004c5c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004c60:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004c62:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004c66:	ffffb797          	auipc	a5,0xffffb
    80004c6a:	69078793          	addi	a5,a5,1680 # 800002f6 <main>
    80004c6e:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004c72:	4781                	li	a5,0
    80004c74:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004c78:	67c1                	lui	a5,0x10
    80004c7a:	17fd                	addi	a5,a5,-1
    80004c7c:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004c80:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004c84:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004c88:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004c8c:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004c90:	57fd                	li	a5,-1
    80004c92:	83a9                	srli	a5,a5,0xa
    80004c94:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004c98:	47bd                	li	a5,15
    80004c9a:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004c9e:	f65ff0ef          	jal	ra,80004c02 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004ca2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004ca6:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004ca8:	823e                	mv	tp,a5
  asm volatile("mret");
    80004caa:	30200073          	mret
}
    80004cae:	60a2                	ld	ra,8(sp)
    80004cb0:	6402                	ld	s0,0(sp)
    80004cb2:	0141                	addi	sp,sp,16
    80004cb4:	8082                	ret

0000000080004cb6 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004cb6:	715d                	addi	sp,sp,-80
    80004cb8:	e486                	sd	ra,72(sp)
    80004cba:	e0a2                	sd	s0,64(sp)
    80004cbc:	fc26                	sd	s1,56(sp)
    80004cbe:	f84a                	sd	s2,48(sp)
    80004cc0:	f44e                	sd	s3,40(sp)
    80004cc2:	f052                	sd	s4,32(sp)
    80004cc4:	ec56                	sd	s5,24(sp)
    80004cc6:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004cc8:	04c05263          	blez	a2,80004d0c <consolewrite+0x56>
    80004ccc:	8a2a                	mv	s4,a0
    80004cce:	84ae                	mv	s1,a1
    80004cd0:	89b2                	mv	s3,a2
    80004cd2:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004cd4:	5afd                	li	s5,-1
    80004cd6:	4685                	li	a3,1
    80004cd8:	8626                	mv	a2,s1
    80004cda:	85d2                	mv	a1,s4
    80004cdc:	fbf40513          	addi	a0,s0,-65
    80004ce0:	9abfc0ef          	jal	ra,8000168a <either_copyin>
    80004ce4:	01550a63          	beq	a0,s5,80004cf8 <consolewrite+0x42>
      break;
    uartputc(c);
    80004ce8:	fbf44503          	lbu	a0,-65(s0)
    80004cec:	7e8000ef          	jal	ra,800054d4 <uartputc>
  for(i = 0; i < n; i++){
    80004cf0:	2905                	addiw	s2,s2,1
    80004cf2:	0485                	addi	s1,s1,1
    80004cf4:	ff2991e3          	bne	s3,s2,80004cd6 <consolewrite+0x20>
  }

  return i;
}
    80004cf8:	854a                	mv	a0,s2
    80004cfa:	60a6                	ld	ra,72(sp)
    80004cfc:	6406                	ld	s0,64(sp)
    80004cfe:	74e2                	ld	s1,56(sp)
    80004d00:	7942                	ld	s2,48(sp)
    80004d02:	79a2                	ld	s3,40(sp)
    80004d04:	7a02                	ld	s4,32(sp)
    80004d06:	6ae2                	ld	s5,24(sp)
    80004d08:	6161                	addi	sp,sp,80
    80004d0a:	8082                	ret
  for(i = 0; i < n; i++){
    80004d0c:	4901                	li	s2,0
    80004d0e:	b7ed                	j	80004cf8 <consolewrite+0x42>

0000000080004d10 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004d10:	7119                	addi	sp,sp,-128
    80004d12:	fc86                	sd	ra,120(sp)
    80004d14:	f8a2                	sd	s0,112(sp)
    80004d16:	f4a6                	sd	s1,104(sp)
    80004d18:	f0ca                	sd	s2,96(sp)
    80004d1a:	ecce                	sd	s3,88(sp)
    80004d1c:	e8d2                	sd	s4,80(sp)
    80004d1e:	e4d6                	sd	s5,72(sp)
    80004d20:	e0da                	sd	s6,64(sp)
    80004d22:	fc5e                	sd	s7,56(sp)
    80004d24:	f862                	sd	s8,48(sp)
    80004d26:	f466                	sd	s9,40(sp)
    80004d28:	f06a                	sd	s10,32(sp)
    80004d2a:	ec6e                	sd	s11,24(sp)
    80004d2c:	0100                	addi	s0,sp,128
    80004d2e:	8b2a                	mv	s6,a0
    80004d30:	8aae                	mv	s5,a1
    80004d32:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004d34:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80004d38:	00021517          	auipc	a0,0x21
    80004d3c:	c0850513          	addi	a0,a0,-1016 # 80025940 <cons>
    80004d40:	11f000ef          	jal	ra,8000565e <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004d44:	00021497          	auipc	s1,0x21
    80004d48:	bfc48493          	addi	s1,s1,-1028 # 80025940 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004d4c:	89a6                	mv	s3,s1
    80004d4e:	00021917          	auipc	s2,0x21
    80004d52:	c8a90913          	addi	s2,s2,-886 # 800259d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80004d56:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004d58:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80004d5a:	4da9                	li	s11,10
  while(n > 0){
    80004d5c:	07405363          	blez	s4,80004dc2 <consoleread+0xb2>
    while(cons.r == cons.w){
    80004d60:	0984a783          	lw	a5,152(s1)
    80004d64:	09c4a703          	lw	a4,156(s1)
    80004d68:	02f71163          	bne	a4,a5,80004d8a <consoleread+0x7a>
      if(killed(myproc())){
    80004d6c:	fa5fb0ef          	jal	ra,80000d10 <myproc>
    80004d70:	facfc0ef          	jal	ra,8000151c <killed>
    80004d74:	e125                	bnez	a0,80004dd4 <consoleread+0xc4>
      sleep(&cons.r, &cons.lock);
    80004d76:	85ce                	mv	a1,s3
    80004d78:	854a                	mv	a0,s2
    80004d7a:	d6afc0ef          	jal	ra,800012e4 <sleep>
    while(cons.r == cons.w){
    80004d7e:	0984a783          	lw	a5,152(s1)
    80004d82:	09c4a703          	lw	a4,156(s1)
    80004d86:	fef703e3          	beq	a4,a5,80004d6c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004d8a:	0017871b          	addiw	a4,a5,1
    80004d8e:	08e4ac23          	sw	a4,152(s1)
    80004d92:	07f7f713          	andi	a4,a5,127
    80004d96:	9726                	add	a4,a4,s1
    80004d98:	01874703          	lbu	a4,24(a4)
    80004d9c:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80004da0:	079c0063          	beq	s8,s9,80004e00 <consoleread+0xf0>
    cbuf = c;
    80004da4:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80004da8:	4685                	li	a3,1
    80004daa:	f8f40613          	addi	a2,s0,-113
    80004dae:	85d6                	mv	a1,s5
    80004db0:	855a                	mv	a0,s6
    80004db2:	88ffc0ef          	jal	ra,80001640 <either_copyout>
    80004db6:	01a50663          	beq	a0,s10,80004dc2 <consoleread+0xb2>
    dst++;
    80004dba:	0a85                	addi	s5,s5,1
    --n;
    80004dbc:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80004dbe:	f9bc1fe3          	bne	s8,s11,80004d5c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80004dc2:	00021517          	auipc	a0,0x21
    80004dc6:	b7e50513          	addi	a0,a0,-1154 # 80025940 <cons>
    80004dca:	12d000ef          	jal	ra,800056f6 <release>

  return target - n;
    80004dce:	414b853b          	subw	a0,s7,s4
    80004dd2:	a801                	j	80004de2 <consoleread+0xd2>
        release(&cons.lock);
    80004dd4:	00021517          	auipc	a0,0x21
    80004dd8:	b6c50513          	addi	a0,a0,-1172 # 80025940 <cons>
    80004ddc:	11b000ef          	jal	ra,800056f6 <release>
        return -1;
    80004de0:	557d                	li	a0,-1
}
    80004de2:	70e6                	ld	ra,120(sp)
    80004de4:	7446                	ld	s0,112(sp)
    80004de6:	74a6                	ld	s1,104(sp)
    80004de8:	7906                	ld	s2,96(sp)
    80004dea:	69e6                	ld	s3,88(sp)
    80004dec:	6a46                	ld	s4,80(sp)
    80004dee:	6aa6                	ld	s5,72(sp)
    80004df0:	6b06                	ld	s6,64(sp)
    80004df2:	7be2                	ld	s7,56(sp)
    80004df4:	7c42                	ld	s8,48(sp)
    80004df6:	7ca2                	ld	s9,40(sp)
    80004df8:	7d02                	ld	s10,32(sp)
    80004dfa:	6de2                	ld	s11,24(sp)
    80004dfc:	6109                	addi	sp,sp,128
    80004dfe:	8082                	ret
      if(n < target){
    80004e00:	000a071b          	sext.w	a4,s4
    80004e04:	fb777fe3          	bgeu	a4,s7,80004dc2 <consoleread+0xb2>
        cons.r--;
    80004e08:	00021717          	auipc	a4,0x21
    80004e0c:	bcf72823          	sw	a5,-1072(a4) # 800259d8 <cons+0x98>
    80004e10:	bf4d                	j	80004dc2 <consoleread+0xb2>

0000000080004e12 <consputc>:
{
    80004e12:	1141                	addi	sp,sp,-16
    80004e14:	e406                	sd	ra,8(sp)
    80004e16:	e022                	sd	s0,0(sp)
    80004e18:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80004e1a:	10000793          	li	a5,256
    80004e1e:	00f50863          	beq	a0,a5,80004e2e <consputc+0x1c>
    uartputc_sync(c);
    80004e22:	5d4000ef          	jal	ra,800053f6 <uartputc_sync>
}
    80004e26:	60a2                	ld	ra,8(sp)
    80004e28:	6402                	ld	s0,0(sp)
    80004e2a:	0141                	addi	sp,sp,16
    80004e2c:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80004e2e:	4521                	li	a0,8
    80004e30:	5c6000ef          	jal	ra,800053f6 <uartputc_sync>
    80004e34:	02000513          	li	a0,32
    80004e38:	5be000ef          	jal	ra,800053f6 <uartputc_sync>
    80004e3c:	4521                	li	a0,8
    80004e3e:	5b8000ef          	jal	ra,800053f6 <uartputc_sync>
    80004e42:	b7d5                	j	80004e26 <consputc+0x14>

0000000080004e44 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80004e44:	1101                	addi	sp,sp,-32
    80004e46:	ec06                	sd	ra,24(sp)
    80004e48:	e822                	sd	s0,16(sp)
    80004e4a:	e426                	sd	s1,8(sp)
    80004e4c:	e04a                	sd	s2,0(sp)
    80004e4e:	1000                	addi	s0,sp,32
    80004e50:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80004e52:	00021517          	auipc	a0,0x21
    80004e56:	aee50513          	addi	a0,a0,-1298 # 80025940 <cons>
    80004e5a:	005000ef          	jal	ra,8000565e <acquire>

  switch(c){
    80004e5e:	47d5                	li	a5,21
    80004e60:	0af48063          	beq	s1,a5,80004f00 <consoleintr+0xbc>
    80004e64:	0297c663          	blt	a5,s1,80004e90 <consoleintr+0x4c>
    80004e68:	47a1                	li	a5,8
    80004e6a:	0cf48f63          	beq	s1,a5,80004f48 <consoleintr+0x104>
    80004e6e:	47c1                	li	a5,16
    80004e70:	10f49063          	bne	s1,a5,80004f70 <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    80004e74:	861fc0ef          	jal	ra,800016d4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80004e78:	00021517          	auipc	a0,0x21
    80004e7c:	ac850513          	addi	a0,a0,-1336 # 80025940 <cons>
    80004e80:	077000ef          	jal	ra,800056f6 <release>
}
    80004e84:	60e2                	ld	ra,24(sp)
    80004e86:	6442                	ld	s0,16(sp)
    80004e88:	64a2                	ld	s1,8(sp)
    80004e8a:	6902                	ld	s2,0(sp)
    80004e8c:	6105                	addi	sp,sp,32
    80004e8e:	8082                	ret
  switch(c){
    80004e90:	07f00793          	li	a5,127
    80004e94:	0af48a63          	beq	s1,a5,80004f48 <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004e98:	00021717          	auipc	a4,0x21
    80004e9c:	aa870713          	addi	a4,a4,-1368 # 80025940 <cons>
    80004ea0:	0a072783          	lw	a5,160(a4)
    80004ea4:	09872703          	lw	a4,152(a4)
    80004ea8:	9f99                	subw	a5,a5,a4
    80004eaa:	07f00713          	li	a4,127
    80004eae:	fcf765e3          	bltu	a4,a5,80004e78 <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    80004eb2:	47b5                	li	a5,13
    80004eb4:	0cf48163          	beq	s1,a5,80004f76 <consoleintr+0x132>
      consputc(c);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	f59ff0ef          	jal	ra,80004e12 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004ebe:	00021797          	auipc	a5,0x21
    80004ec2:	a8278793          	addi	a5,a5,-1406 # 80025940 <cons>
    80004ec6:	0a07a683          	lw	a3,160(a5)
    80004eca:	0016871b          	addiw	a4,a3,1
    80004ece:	0007061b          	sext.w	a2,a4
    80004ed2:	0ae7a023          	sw	a4,160(a5)
    80004ed6:	07f6f693          	andi	a3,a3,127
    80004eda:	97b6                	add	a5,a5,a3
    80004edc:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80004ee0:	47a9                	li	a5,10
    80004ee2:	0af48f63          	beq	s1,a5,80004fa0 <consoleintr+0x15c>
    80004ee6:	4791                	li	a5,4
    80004ee8:	0af48c63          	beq	s1,a5,80004fa0 <consoleintr+0x15c>
    80004eec:	00021797          	auipc	a5,0x21
    80004ef0:	aec7a783          	lw	a5,-1300(a5) # 800259d8 <cons+0x98>
    80004ef4:	9f1d                	subw	a4,a4,a5
    80004ef6:	08000793          	li	a5,128
    80004efa:	f6f71fe3          	bne	a4,a5,80004e78 <consoleintr+0x34>
    80004efe:	a04d                	j	80004fa0 <consoleintr+0x15c>
    while(cons.e != cons.w &&
    80004f00:	00021717          	auipc	a4,0x21
    80004f04:	a4070713          	addi	a4,a4,-1472 # 80025940 <cons>
    80004f08:	0a072783          	lw	a5,160(a4)
    80004f0c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004f10:	00021497          	auipc	s1,0x21
    80004f14:	a3048493          	addi	s1,s1,-1488 # 80025940 <cons>
    while(cons.e != cons.w &&
    80004f18:	4929                	li	s2,10
    80004f1a:	f4f70fe3          	beq	a4,a5,80004e78 <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80004f1e:	37fd                	addiw	a5,a5,-1
    80004f20:	07f7f713          	andi	a4,a5,127
    80004f24:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80004f26:	01874703          	lbu	a4,24(a4)
    80004f2a:	f52707e3          	beq	a4,s2,80004e78 <consoleintr+0x34>
      cons.e--;
    80004f2e:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80004f32:	10000513          	li	a0,256
    80004f36:	eddff0ef          	jal	ra,80004e12 <consputc>
    while(cons.e != cons.w &&
    80004f3a:	0a04a783          	lw	a5,160(s1)
    80004f3e:	09c4a703          	lw	a4,156(s1)
    80004f42:	fcf71ee3          	bne	a4,a5,80004f1e <consoleintr+0xda>
    80004f46:	bf0d                	j	80004e78 <consoleintr+0x34>
    if(cons.e != cons.w){
    80004f48:	00021717          	auipc	a4,0x21
    80004f4c:	9f870713          	addi	a4,a4,-1544 # 80025940 <cons>
    80004f50:	0a072783          	lw	a5,160(a4)
    80004f54:	09c72703          	lw	a4,156(a4)
    80004f58:	f2f700e3          	beq	a4,a5,80004e78 <consoleintr+0x34>
      cons.e--;
    80004f5c:	37fd                	addiw	a5,a5,-1
    80004f5e:	00021717          	auipc	a4,0x21
    80004f62:	a8f72123          	sw	a5,-1406(a4) # 800259e0 <cons+0xa0>
      consputc(BACKSPACE);
    80004f66:	10000513          	li	a0,256
    80004f6a:	ea9ff0ef          	jal	ra,80004e12 <consputc>
    80004f6e:	b729                	j	80004e78 <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80004f70:	f00484e3          	beqz	s1,80004e78 <consoleintr+0x34>
    80004f74:	b715                	j	80004e98 <consoleintr+0x54>
      consputc(c);
    80004f76:	4529                	li	a0,10
    80004f78:	e9bff0ef          	jal	ra,80004e12 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80004f7c:	00021797          	auipc	a5,0x21
    80004f80:	9c478793          	addi	a5,a5,-1596 # 80025940 <cons>
    80004f84:	0a07a703          	lw	a4,160(a5)
    80004f88:	0017069b          	addiw	a3,a4,1
    80004f8c:	0006861b          	sext.w	a2,a3
    80004f90:	0ad7a023          	sw	a3,160(a5)
    80004f94:	07f77713          	andi	a4,a4,127
    80004f98:	97ba                	add	a5,a5,a4
    80004f9a:	4729                	li	a4,10
    80004f9c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80004fa0:	00021797          	auipc	a5,0x21
    80004fa4:	a2c7ae23          	sw	a2,-1476(a5) # 800259dc <cons+0x9c>
        wakeup(&cons.r);
    80004fa8:	00021517          	auipc	a0,0x21
    80004fac:	a3050513          	addi	a0,a0,-1488 # 800259d8 <cons+0x98>
    80004fb0:	b80fc0ef          	jal	ra,80001330 <wakeup>
    80004fb4:	b5d1                	j	80004e78 <consoleintr+0x34>

0000000080004fb6 <consoleinit>:

void
consoleinit(void)
{
    80004fb6:	1141                	addi	sp,sp,-16
    80004fb8:	e406                	sd	ra,8(sp)
    80004fba:	e022                	sd	s0,0(sp)
    80004fbc:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80004fbe:	00003597          	auipc	a1,0x3
    80004fc2:	85a58593          	addi	a1,a1,-1958 # 80007818 <syscalls+0x400>
    80004fc6:	00021517          	auipc	a0,0x21
    80004fca:	97a50513          	addi	a0,a0,-1670 # 80025940 <cons>
    80004fce:	610000ef          	jal	ra,800055de <initlock>

  uartinit();
    80004fd2:	3d8000ef          	jal	ra,800053aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80004fd6:	00017797          	auipc	a5,0x17
    80004fda:	7d278793          	addi	a5,a5,2002 # 8001c7a8 <devsw>
    80004fde:	00000717          	auipc	a4,0x0
    80004fe2:	d3270713          	addi	a4,a4,-718 # 80004d10 <consoleread>
    80004fe6:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80004fe8:	00000717          	auipc	a4,0x0
    80004fec:	cce70713          	addi	a4,a4,-818 # 80004cb6 <consolewrite>
    80004ff0:	ef98                	sd	a4,24(a5)
}
    80004ff2:	60a2                	ld	ra,8(sp)
    80004ff4:	6402                	ld	s0,0(sp)
    80004ff6:	0141                	addi	sp,sp,16
    80004ff8:	8082                	ret

0000000080004ffa <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80004ffa:	7179                	addi	sp,sp,-48
    80004ffc:	f406                	sd	ra,40(sp)
    80004ffe:	f022                	sd	s0,32(sp)
    80005000:	ec26                	sd	s1,24(sp)
    80005002:	e84a                	sd	s2,16(sp)
    80005004:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005006:	c219                	beqz	a2,8000500c <printint+0x12>
    80005008:	06054f63          	bltz	a0,80005086 <printint+0x8c>
    x = -xx;
  else
    x = xx;
    8000500c:	4881                	li	a7,0
    8000500e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005012:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005014:	00003617          	auipc	a2,0x3
    80005018:	82c60613          	addi	a2,a2,-2004 # 80007840 <digits>
    8000501c:	883e                	mv	a6,a5
    8000501e:	2785                	addiw	a5,a5,1
    80005020:	02b57733          	remu	a4,a0,a1
    80005024:	9732                	add	a4,a4,a2
    80005026:	00074703          	lbu	a4,0(a4)
    8000502a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000502e:	872a                	mv	a4,a0
    80005030:	02b55533          	divu	a0,a0,a1
    80005034:	0685                	addi	a3,a3,1
    80005036:	feb773e3          	bgeu	a4,a1,8000501c <printint+0x22>

  if(sign)
    8000503a:	00088b63          	beqz	a7,80005050 <printint+0x56>
    buf[i++] = '-';
    8000503e:	fe040713          	addi	a4,s0,-32
    80005042:	97ba                	add	a5,a5,a4
    80005044:	02d00713          	li	a4,45
    80005048:	fee78823          	sb	a4,-16(a5)
    8000504c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80005050:	02f05563          	blez	a5,8000507a <printint+0x80>
    80005054:	fd040713          	addi	a4,s0,-48
    80005058:	00f704b3          	add	s1,a4,a5
    8000505c:	fff70913          	addi	s2,a4,-1
    80005060:	993e                	add	s2,s2,a5
    80005062:	37fd                	addiw	a5,a5,-1
    80005064:	1782                	slli	a5,a5,0x20
    80005066:	9381                	srli	a5,a5,0x20
    80005068:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000506c:	fff4c503          	lbu	a0,-1(s1)
    80005070:	da3ff0ef          	jal	ra,80004e12 <consputc>
  while(--i >= 0)
    80005074:	14fd                	addi	s1,s1,-1
    80005076:	ff249be3          	bne	s1,s2,8000506c <printint+0x72>
}
    8000507a:	70a2                	ld	ra,40(sp)
    8000507c:	7402                	ld	s0,32(sp)
    8000507e:	64e2                	ld	s1,24(sp)
    80005080:	6942                	ld	s2,16(sp)
    80005082:	6145                	addi	sp,sp,48
    80005084:	8082                	ret
    x = -xx;
    80005086:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000508a:	4885                	li	a7,1
    x = -xx;
    8000508c:	b749                	j	8000500e <printint+0x14>

000000008000508e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000508e:	7155                	addi	sp,sp,-208
    80005090:	e506                	sd	ra,136(sp)
    80005092:	e122                	sd	s0,128(sp)
    80005094:	fca6                	sd	s1,120(sp)
    80005096:	f8ca                	sd	s2,112(sp)
    80005098:	f4ce                	sd	s3,104(sp)
    8000509a:	f0d2                	sd	s4,96(sp)
    8000509c:	ecd6                	sd	s5,88(sp)
    8000509e:	e8da                	sd	s6,80(sp)
    800050a0:	e4de                	sd	s7,72(sp)
    800050a2:	e0e2                	sd	s8,64(sp)
    800050a4:	fc66                	sd	s9,56(sp)
    800050a6:	f86a                	sd	s10,48(sp)
    800050a8:	f46e                	sd	s11,40(sp)
    800050aa:	0900                	addi	s0,sp,144
    800050ac:	8a2a                	mv	s4,a0
    800050ae:	e40c                	sd	a1,8(s0)
    800050b0:	e810                	sd	a2,16(s0)
    800050b2:	ec14                	sd	a3,24(s0)
    800050b4:	f018                	sd	a4,32(s0)
    800050b6:	f41c                	sd	a5,40(s0)
    800050b8:	03043823          	sd	a6,48(s0)
    800050bc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800050c0:	00021797          	auipc	a5,0x21
    800050c4:	9407a783          	lw	a5,-1728(a5) # 80025a00 <pr+0x18>
    800050c8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800050cc:	eb9d                	bnez	a5,80005102 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800050ce:	00840793          	addi	a5,s0,8
    800050d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800050d6:	00054503          	lbu	a0,0(a0)
    800050da:	24050463          	beqz	a0,80005322 <printf+0x294>
    800050de:	4981                	li	s3,0
    if(cx != '%'){
    800050e0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800050e4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800050e8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800050ec:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    800050f0:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    800050f4:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800050f8:	00002b97          	auipc	s7,0x2
    800050fc:	748b8b93          	addi	s7,s7,1864 # 80007840 <digits>
    80005100:	a081                	j	80005140 <printf+0xb2>
    acquire(&pr.lock);
    80005102:	00021517          	auipc	a0,0x21
    80005106:	8e650513          	addi	a0,a0,-1818 # 800259e8 <pr>
    8000510a:	554000ef          	jal	ra,8000565e <acquire>
  va_start(ap, fmt);
    8000510e:	00840793          	addi	a5,s0,8
    80005112:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005116:	000a4503          	lbu	a0,0(s4)
    8000511a:	f171                	bnez	a0,800050de <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000511c:	00021517          	auipc	a0,0x21
    80005120:	8cc50513          	addi	a0,a0,-1844 # 800259e8 <pr>
    80005124:	5d2000ef          	jal	ra,800056f6 <release>
    80005128:	aaed                	j	80005322 <printf+0x294>
      consputc(cx);
    8000512a:	ce9ff0ef          	jal	ra,80004e12 <consputc>
      continue;
    8000512e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005130:	0014899b          	addiw	s3,s1,1
    80005134:	013a07b3          	add	a5,s4,s3
    80005138:	0007c503          	lbu	a0,0(a5)
    8000513c:	1c050f63          	beqz	a0,8000531a <printf+0x28c>
    if(cx != '%'){
    80005140:	ff5515e3          	bne	a0,s5,8000512a <printf+0x9c>
    i++;
    80005144:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80005148:	009a07b3          	add	a5,s4,s1
    8000514c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80005150:	1c090563          	beqz	s2,8000531a <printf+0x28c>
    80005154:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80005158:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000515a:	c789                	beqz	a5,80005164 <printf+0xd6>
    8000515c:	009a0733          	add	a4,s4,s1
    80005160:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80005164:	03690463          	beq	s2,s6,8000518c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80005168:	03890e63          	beq	s2,s8,800051a4 <printf+0x116>
    } else if(c0 == 'u'){
    8000516c:	0b990d63          	beq	s2,s9,80005226 <printf+0x198>
    } else if(c0 == 'x'){
    80005170:	11a90363          	beq	s2,s10,80005276 <printf+0x1e8>
    } else if(c0 == 'p'){
    80005174:	13b90b63          	beq	s2,s11,800052aa <printf+0x21c>
    } else if(c0 == 's'){
    80005178:	07300793          	li	a5,115
    8000517c:	16f90363          	beq	s2,a5,800052e2 <printf+0x254>
    } else if(c0 == '%'){
    80005180:	03591c63          	bne	s2,s5,800051b8 <printf+0x12a>
      consputc('%');
    80005184:	8556                	mv	a0,s5
    80005186:	c8dff0ef          	jal	ra,80004e12 <consputc>
    8000518a:	b75d                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000518c:	f8843783          	ld	a5,-120(s0)
    80005190:	00878713          	addi	a4,a5,8
    80005194:	f8e43423          	sd	a4,-120(s0)
    80005198:	4605                	li	a2,1
    8000519a:	45a9                	li	a1,10
    8000519c:	4388                	lw	a0,0(a5)
    8000519e:	e5dff0ef          	jal	ra,80004ffa <printint>
    800051a2:	b779                	j	80005130 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800051a4:	03678163          	beq	a5,s6,800051c6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800051a8:	03878d63          	beq	a5,s8,800051e2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800051ac:	09978963          	beq	a5,s9,8000523e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800051b0:	03878b63          	beq	a5,s8,800051e6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800051b4:	0da78d63          	beq	a5,s10,8000528e <printf+0x200>
      consputc('%');
    800051b8:	8556                	mv	a0,s5
    800051ba:	c59ff0ef          	jal	ra,80004e12 <consputc>
      consputc(c0);
    800051be:	854a                	mv	a0,s2
    800051c0:	c53ff0ef          	jal	ra,80004e12 <consputc>
    800051c4:	b7b5                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800051c6:	f8843783          	ld	a5,-120(s0)
    800051ca:	00878713          	addi	a4,a5,8
    800051ce:	f8e43423          	sd	a4,-120(s0)
    800051d2:	4605                	li	a2,1
    800051d4:	45a9                	li	a1,10
    800051d6:	6388                	ld	a0,0(a5)
    800051d8:	e23ff0ef          	jal	ra,80004ffa <printint>
      i += 1;
    800051dc:	0029849b          	addiw	s1,s3,2
    800051e0:	bf81                	j	80005130 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800051e2:	03668463          	beq	a3,s6,8000520a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800051e6:	07968a63          	beq	a3,s9,8000525a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800051ea:	fda697e3          	bne	a3,s10,800051b8 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800051ee:	f8843783          	ld	a5,-120(s0)
    800051f2:	00878713          	addi	a4,a5,8
    800051f6:	f8e43423          	sd	a4,-120(s0)
    800051fa:	4601                	li	a2,0
    800051fc:	45c1                	li	a1,16
    800051fe:	6388                	ld	a0,0(a5)
    80005200:	dfbff0ef          	jal	ra,80004ffa <printint>
      i += 2;
    80005204:	0039849b          	addiw	s1,s3,3
    80005208:	b725                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000520a:	f8843783          	ld	a5,-120(s0)
    8000520e:	00878713          	addi	a4,a5,8
    80005212:	f8e43423          	sd	a4,-120(s0)
    80005216:	4605                	li	a2,1
    80005218:	45a9                	li	a1,10
    8000521a:	6388                	ld	a0,0(a5)
    8000521c:	ddfff0ef          	jal	ra,80004ffa <printint>
      i += 2;
    80005220:	0039849b          	addiw	s1,s3,3
    80005224:	b731                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80005226:	f8843783          	ld	a5,-120(s0)
    8000522a:	00878713          	addi	a4,a5,8
    8000522e:	f8e43423          	sd	a4,-120(s0)
    80005232:	4601                	li	a2,0
    80005234:	45a9                	li	a1,10
    80005236:	4388                	lw	a0,0(a5)
    80005238:	dc3ff0ef          	jal	ra,80004ffa <printint>
    8000523c:	bdd5                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000523e:	f8843783          	ld	a5,-120(s0)
    80005242:	00878713          	addi	a4,a5,8
    80005246:	f8e43423          	sd	a4,-120(s0)
    8000524a:	4601                	li	a2,0
    8000524c:	45a9                	li	a1,10
    8000524e:	6388                	ld	a0,0(a5)
    80005250:	dabff0ef          	jal	ra,80004ffa <printint>
      i += 1;
    80005254:	0029849b          	addiw	s1,s3,2
    80005258:	bde1                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000525a:	f8843783          	ld	a5,-120(s0)
    8000525e:	00878713          	addi	a4,a5,8
    80005262:	f8e43423          	sd	a4,-120(s0)
    80005266:	4601                	li	a2,0
    80005268:	45a9                	li	a1,10
    8000526a:	6388                	ld	a0,0(a5)
    8000526c:	d8fff0ef          	jal	ra,80004ffa <printint>
      i += 2;
    80005270:	0039849b          	addiw	s1,s3,3
    80005274:	bd75                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80005276:	f8843783          	ld	a5,-120(s0)
    8000527a:	00878713          	addi	a4,a5,8
    8000527e:	f8e43423          	sd	a4,-120(s0)
    80005282:	4601                	li	a2,0
    80005284:	45c1                	li	a1,16
    80005286:	4388                	lw	a0,0(a5)
    80005288:	d73ff0ef          	jal	ra,80004ffa <printint>
    8000528c:	b555                	j	80005130 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000528e:	f8843783          	ld	a5,-120(s0)
    80005292:	00878713          	addi	a4,a5,8
    80005296:	f8e43423          	sd	a4,-120(s0)
    8000529a:	4601                	li	a2,0
    8000529c:	45c1                	li	a1,16
    8000529e:	6388                	ld	a0,0(a5)
    800052a0:	d5bff0ef          	jal	ra,80004ffa <printint>
      i += 1;
    800052a4:	0029849b          	addiw	s1,s3,2
    800052a8:	b561                	j	80005130 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800052aa:	f8843783          	ld	a5,-120(s0)
    800052ae:	00878713          	addi	a4,a5,8
    800052b2:	f8e43423          	sd	a4,-120(s0)
    800052b6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800052ba:	03000513          	li	a0,48
    800052be:	b55ff0ef          	jal	ra,80004e12 <consputc>
  consputc('x');
    800052c2:	856a                	mv	a0,s10
    800052c4:	b4fff0ef          	jal	ra,80004e12 <consputc>
    800052c8:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800052ca:	03c9d793          	srli	a5,s3,0x3c
    800052ce:	97de                	add	a5,a5,s7
    800052d0:	0007c503          	lbu	a0,0(a5)
    800052d4:	b3fff0ef          	jal	ra,80004e12 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800052d8:	0992                	slli	s3,s3,0x4
    800052da:	397d                	addiw	s2,s2,-1
    800052dc:	fe0917e3          	bnez	s2,800052ca <printf+0x23c>
    800052e0:	bd81                	j	80005130 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800052e2:	f8843783          	ld	a5,-120(s0)
    800052e6:	00878713          	addi	a4,a5,8
    800052ea:	f8e43423          	sd	a4,-120(s0)
    800052ee:	0007b903          	ld	s2,0(a5)
    800052f2:	00090d63          	beqz	s2,8000530c <printf+0x27e>
      for(; *s; s++)
    800052f6:	00094503          	lbu	a0,0(s2)
    800052fa:	e2050be3          	beqz	a0,80005130 <printf+0xa2>
        consputc(*s);
    800052fe:	b15ff0ef          	jal	ra,80004e12 <consputc>
      for(; *s; s++)
    80005302:	0905                	addi	s2,s2,1
    80005304:	00094503          	lbu	a0,0(s2)
    80005308:	f97d                	bnez	a0,800052fe <printf+0x270>
    8000530a:	b51d                	j	80005130 <printf+0xa2>
        s = "(null)";
    8000530c:	00002917          	auipc	s2,0x2
    80005310:	51490913          	addi	s2,s2,1300 # 80007820 <syscalls+0x408>
      for(; *s; s++)
    80005314:	02800513          	li	a0,40
    80005318:	b7dd                	j	800052fe <printf+0x270>
  if(locking)
    8000531a:	f7843783          	ld	a5,-136(s0)
    8000531e:	de079fe3          	bnez	a5,8000511c <printf+0x8e>

  return 0;
}
    80005322:	4501                	li	a0,0
    80005324:	60aa                	ld	ra,136(sp)
    80005326:	640a                	ld	s0,128(sp)
    80005328:	74e6                	ld	s1,120(sp)
    8000532a:	7946                	ld	s2,112(sp)
    8000532c:	79a6                	ld	s3,104(sp)
    8000532e:	7a06                	ld	s4,96(sp)
    80005330:	6ae6                	ld	s5,88(sp)
    80005332:	6b46                	ld	s6,80(sp)
    80005334:	6ba6                	ld	s7,72(sp)
    80005336:	6c06                	ld	s8,64(sp)
    80005338:	7ce2                	ld	s9,56(sp)
    8000533a:	7d42                	ld	s10,48(sp)
    8000533c:	7da2                	ld	s11,40(sp)
    8000533e:	6169                	addi	sp,sp,208
    80005340:	8082                	ret

0000000080005342 <panic>:

void
panic(char *s)
{
    80005342:	1101                	addi	sp,sp,-32
    80005344:	ec06                	sd	ra,24(sp)
    80005346:	e822                	sd	s0,16(sp)
    80005348:	e426                	sd	s1,8(sp)
    8000534a:	1000                	addi	s0,sp,32
    8000534c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000534e:	00020797          	auipc	a5,0x20
    80005352:	6a07a923          	sw	zero,1714(a5) # 80025a00 <pr+0x18>
  printf("panic: ");
    80005356:	00002517          	auipc	a0,0x2
    8000535a:	4d250513          	addi	a0,a0,1234 # 80007828 <syscalls+0x410>
    8000535e:	d31ff0ef          	jal	ra,8000508e <printf>
  printf("%s\n", s);
    80005362:	85a6                	mv	a1,s1
    80005364:	00002517          	auipc	a0,0x2
    80005368:	4cc50513          	addi	a0,a0,1228 # 80007830 <syscalls+0x418>
    8000536c:	d23ff0ef          	jal	ra,8000508e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005370:	4785                	li	a5,1
    80005372:	00002717          	auipc	a4,0x2
    80005376:	58f72523          	sw	a5,1418(a4) # 800078fc <panicked>
  for(;;)
    8000537a:	a001                	j	8000537a <panic+0x38>

000000008000537c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000537c:	1101                	addi	sp,sp,-32
    8000537e:	ec06                	sd	ra,24(sp)
    80005380:	e822                	sd	s0,16(sp)
    80005382:	e426                	sd	s1,8(sp)
    80005384:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005386:	00020497          	auipc	s1,0x20
    8000538a:	66248493          	addi	s1,s1,1634 # 800259e8 <pr>
    8000538e:	00002597          	auipc	a1,0x2
    80005392:	4aa58593          	addi	a1,a1,1194 # 80007838 <syscalls+0x420>
    80005396:	8526                	mv	a0,s1
    80005398:	246000ef          	jal	ra,800055de <initlock>
  pr.locking = 1;
    8000539c:	4785                	li	a5,1
    8000539e:	cc9c                	sw	a5,24(s1)
}
    800053a0:	60e2                	ld	ra,24(sp)
    800053a2:	6442                	ld	s0,16(sp)
    800053a4:	64a2                	ld	s1,8(sp)
    800053a6:	6105                	addi	sp,sp,32
    800053a8:	8082                	ret

00000000800053aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800053aa:	1141                	addi	sp,sp,-16
    800053ac:	e406                	sd	ra,8(sp)
    800053ae:	e022                	sd	s0,0(sp)
    800053b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800053b2:	100007b7          	lui	a5,0x10000
    800053b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800053ba:	f8000713          	li	a4,-128
    800053be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800053c2:	470d                	li	a4,3
    800053c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800053c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800053cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800053d0:	469d                	li	a3,7
    800053d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800053d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800053da:	00002597          	auipc	a1,0x2
    800053de:	47e58593          	addi	a1,a1,1150 # 80007858 <digits+0x18>
    800053e2:	00020517          	auipc	a0,0x20
    800053e6:	62650513          	addi	a0,a0,1574 # 80025a08 <uart_tx_lock>
    800053ea:	1f4000ef          	jal	ra,800055de <initlock>
}
    800053ee:	60a2                	ld	ra,8(sp)
    800053f0:	6402                	ld	s0,0(sp)
    800053f2:	0141                	addi	sp,sp,16
    800053f4:	8082                	ret

00000000800053f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800053f6:	1101                	addi	sp,sp,-32
    800053f8:	ec06                	sd	ra,24(sp)
    800053fa:	e822                	sd	s0,16(sp)
    800053fc:	e426                	sd	s1,8(sp)
    800053fe:	1000                	addi	s0,sp,32
    80005400:	84aa                	mv	s1,a0
  push_off();
    80005402:	21c000ef          	jal	ra,8000561e <push_off>

  if(panicked){
    80005406:	00002797          	auipc	a5,0x2
    8000540a:	4f67a783          	lw	a5,1270(a5) # 800078fc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000540e:	10000737          	lui	a4,0x10000
  if(panicked){
    80005412:	c391                	beqz	a5,80005416 <uartputc_sync+0x20>
    for(;;)
    80005414:	a001                	j	80005414 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005416:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000541a:	0ff7f793          	andi	a5,a5,255
    8000541e:	0207f793          	andi	a5,a5,32
    80005422:	dbf5                	beqz	a5,80005416 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80005424:	0ff4f793          	andi	a5,s1,255
    80005428:	10000737          	lui	a4,0x10000
    8000542c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80005430:	272000ef          	jal	ra,800056a2 <pop_off>
}
    80005434:	60e2                	ld	ra,24(sp)
    80005436:	6442                	ld	s0,16(sp)
    80005438:	64a2                	ld	s1,8(sp)
    8000543a:	6105                	addi	sp,sp,32
    8000543c:	8082                	ret

000000008000543e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000543e:	00002717          	auipc	a4,0x2
    80005442:	4c273703          	ld	a4,1218(a4) # 80007900 <uart_tx_r>
    80005446:	00002797          	auipc	a5,0x2
    8000544a:	4c27b783          	ld	a5,1218(a5) # 80007908 <uart_tx_w>
    8000544e:	06e78e63          	beq	a5,a4,800054ca <uartstart+0x8c>
{
    80005452:	7139                	addi	sp,sp,-64
    80005454:	fc06                	sd	ra,56(sp)
    80005456:	f822                	sd	s0,48(sp)
    80005458:	f426                	sd	s1,40(sp)
    8000545a:	f04a                	sd	s2,32(sp)
    8000545c:	ec4e                	sd	s3,24(sp)
    8000545e:	e852                	sd	s4,16(sp)
    80005460:	e456                	sd	s5,8(sp)
    80005462:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005464:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005468:	00020a17          	auipc	s4,0x20
    8000546c:	5a0a0a13          	addi	s4,s4,1440 # 80025a08 <uart_tx_lock>
    uart_tx_r += 1;
    80005470:	00002497          	auipc	s1,0x2
    80005474:	49048493          	addi	s1,s1,1168 # 80007900 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005478:	00002997          	auipc	s3,0x2
    8000547c:	49098993          	addi	s3,s3,1168 # 80007908 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005480:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005484:	0ff7f793          	andi	a5,a5,255
    80005488:	0207f793          	andi	a5,a5,32
    8000548c:	c795                	beqz	a5,800054b8 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000548e:	01f77793          	andi	a5,a4,31
    80005492:	97d2                	add	a5,a5,s4
    80005494:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    80005498:	0705                	addi	a4,a4,1
    8000549a:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000549c:	8526                	mv	a0,s1
    8000549e:	e93fb0ef          	jal	ra,80001330 <wakeup>
    
    WriteReg(THR, c);
    800054a2:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800054a6:	6098                	ld	a4,0(s1)
    800054a8:	0009b783          	ld	a5,0(s3)
    800054ac:	fce79ae3          	bne	a5,a4,80005480 <uartstart+0x42>
      ReadReg(ISR);
    800054b0:	100007b7          	lui	a5,0x10000
    800054b4:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800054b8:	70e2                	ld	ra,56(sp)
    800054ba:	7442                	ld	s0,48(sp)
    800054bc:	74a2                	ld	s1,40(sp)
    800054be:	7902                	ld	s2,32(sp)
    800054c0:	69e2                	ld	s3,24(sp)
    800054c2:	6a42                	ld	s4,16(sp)
    800054c4:	6aa2                	ld	s5,8(sp)
    800054c6:	6121                	addi	sp,sp,64
    800054c8:	8082                	ret
      ReadReg(ISR);
    800054ca:	100007b7          	lui	a5,0x10000
    800054ce:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800054d2:	8082                	ret

00000000800054d4 <uartputc>:
{
    800054d4:	7179                	addi	sp,sp,-48
    800054d6:	f406                	sd	ra,40(sp)
    800054d8:	f022                	sd	s0,32(sp)
    800054da:	ec26                	sd	s1,24(sp)
    800054dc:	e84a                	sd	s2,16(sp)
    800054de:	e44e                	sd	s3,8(sp)
    800054e0:	e052                	sd	s4,0(sp)
    800054e2:	1800                	addi	s0,sp,48
    800054e4:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800054e6:	00020517          	auipc	a0,0x20
    800054ea:	52250513          	addi	a0,a0,1314 # 80025a08 <uart_tx_lock>
    800054ee:	170000ef          	jal	ra,8000565e <acquire>
  if(panicked){
    800054f2:	00002797          	auipc	a5,0x2
    800054f6:	40a7a783          	lw	a5,1034(a5) # 800078fc <panicked>
    800054fa:	efbd                	bnez	a5,80005578 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800054fc:	00002797          	auipc	a5,0x2
    80005500:	40c7b783          	ld	a5,1036(a5) # 80007908 <uart_tx_w>
    80005504:	00002717          	auipc	a4,0x2
    80005508:	3fc73703          	ld	a4,1020(a4) # 80007900 <uart_tx_r>
    8000550c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005510:	00020a17          	auipc	s4,0x20
    80005514:	4f8a0a13          	addi	s4,s4,1272 # 80025a08 <uart_tx_lock>
    80005518:	00002497          	auipc	s1,0x2
    8000551c:	3e848493          	addi	s1,s1,1000 # 80007900 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005520:	00002917          	auipc	s2,0x2
    80005524:	3e890913          	addi	s2,s2,1000 # 80007908 <uart_tx_w>
    80005528:	00f71d63          	bne	a4,a5,80005542 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000552c:	85d2                	mv	a1,s4
    8000552e:	8526                	mv	a0,s1
    80005530:	db5fb0ef          	jal	ra,800012e4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005534:	00093783          	ld	a5,0(s2)
    80005538:	6098                	ld	a4,0(s1)
    8000553a:	02070713          	addi	a4,a4,32
    8000553e:	fef707e3          	beq	a4,a5,8000552c <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80005542:	00020497          	auipc	s1,0x20
    80005546:	4c648493          	addi	s1,s1,1222 # 80025a08 <uart_tx_lock>
    8000554a:	01f7f713          	andi	a4,a5,31
    8000554e:	9726                	add	a4,a4,s1
    80005550:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80005554:	0785                	addi	a5,a5,1
    80005556:	00002717          	auipc	a4,0x2
    8000555a:	3af73923          	sd	a5,946(a4) # 80007908 <uart_tx_w>
  uartstart();
    8000555e:	ee1ff0ef          	jal	ra,8000543e <uartstart>
  release(&uart_tx_lock);
    80005562:	8526                	mv	a0,s1
    80005564:	192000ef          	jal	ra,800056f6 <release>
}
    80005568:	70a2                	ld	ra,40(sp)
    8000556a:	7402                	ld	s0,32(sp)
    8000556c:	64e2                	ld	s1,24(sp)
    8000556e:	6942                	ld	s2,16(sp)
    80005570:	69a2                	ld	s3,8(sp)
    80005572:	6a02                	ld	s4,0(sp)
    80005574:	6145                	addi	sp,sp,48
    80005576:	8082                	ret
    for(;;)
    80005578:	a001                	j	80005578 <uartputc+0xa4>

000000008000557a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000557a:	1141                	addi	sp,sp,-16
    8000557c:	e422                	sd	s0,8(sp)
    8000557e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005580:	100007b7          	lui	a5,0x10000
    80005584:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80005588:	8b85                	andi	a5,a5,1
    8000558a:	cb91                	beqz	a5,8000559e <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000558c:	100007b7          	lui	a5,0x10000
    80005590:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80005594:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80005598:	6422                	ld	s0,8(sp)
    8000559a:	0141                	addi	sp,sp,16
    8000559c:	8082                	ret
    return -1;
    8000559e:	557d                	li	a0,-1
    800055a0:	bfe5                	j	80005598 <uartgetc+0x1e>

00000000800055a2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800055a2:	1101                	addi	sp,sp,-32
    800055a4:	ec06                	sd	ra,24(sp)
    800055a6:	e822                	sd	s0,16(sp)
    800055a8:	e426                	sd	s1,8(sp)
    800055aa:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800055ac:	54fd                	li	s1,-1
    int c = uartgetc();
    800055ae:	fcdff0ef          	jal	ra,8000557a <uartgetc>
    if(c == -1)
    800055b2:	00950563          	beq	a0,s1,800055bc <uartintr+0x1a>
      break;
    consoleintr(c);
    800055b6:	88fff0ef          	jal	ra,80004e44 <consoleintr>
  while(1){
    800055ba:	bfd5                	j	800055ae <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800055bc:	00020497          	auipc	s1,0x20
    800055c0:	44c48493          	addi	s1,s1,1100 # 80025a08 <uart_tx_lock>
    800055c4:	8526                	mv	a0,s1
    800055c6:	098000ef          	jal	ra,8000565e <acquire>
  uartstart();
    800055ca:	e75ff0ef          	jal	ra,8000543e <uartstart>
  release(&uart_tx_lock);
    800055ce:	8526                	mv	a0,s1
    800055d0:	126000ef          	jal	ra,800056f6 <release>
}
    800055d4:	60e2                	ld	ra,24(sp)
    800055d6:	6442                	ld	s0,16(sp)
    800055d8:	64a2                	ld	s1,8(sp)
    800055da:	6105                	addi	sp,sp,32
    800055dc:	8082                	ret

00000000800055de <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800055de:	1141                	addi	sp,sp,-16
    800055e0:	e422                	sd	s0,8(sp)
    800055e2:	0800                	addi	s0,sp,16
  lk->name = name;
    800055e4:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800055e6:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800055ea:	00053823          	sd	zero,16(a0)
}
    800055ee:	6422                	ld	s0,8(sp)
    800055f0:	0141                	addi	sp,sp,16
    800055f2:	8082                	ret

00000000800055f4 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800055f4:	411c                	lw	a5,0(a0)
    800055f6:	e399                	bnez	a5,800055fc <holding+0x8>
    800055f8:	4501                	li	a0,0
  return r;
}
    800055fa:	8082                	ret
{
    800055fc:	1101                	addi	sp,sp,-32
    800055fe:	ec06                	sd	ra,24(sp)
    80005600:	e822                	sd	s0,16(sp)
    80005602:	e426                	sd	s1,8(sp)
    80005604:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80005606:	6904                	ld	s1,16(a0)
    80005608:	eecfb0ef          	jal	ra,80000cf4 <mycpu>
    8000560c:	40a48533          	sub	a0,s1,a0
    80005610:	00153513          	seqz	a0,a0
}
    80005614:	60e2                	ld	ra,24(sp)
    80005616:	6442                	ld	s0,16(sp)
    80005618:	64a2                	ld	s1,8(sp)
    8000561a:	6105                	addi	sp,sp,32
    8000561c:	8082                	ret

000000008000561e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000561e:	1101                	addi	sp,sp,-32
    80005620:	ec06                	sd	ra,24(sp)
    80005622:	e822                	sd	s0,16(sp)
    80005624:	e426                	sd	s1,8(sp)
    80005626:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005628:	100024f3          	csrr	s1,sstatus
    8000562c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80005630:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005632:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80005636:	ebefb0ef          	jal	ra,80000cf4 <mycpu>
    8000563a:	5d3c                	lw	a5,120(a0)
    8000563c:	cb99                	beqz	a5,80005652 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000563e:	eb6fb0ef          	jal	ra,80000cf4 <mycpu>
    80005642:	5d3c                	lw	a5,120(a0)
    80005644:	2785                	addiw	a5,a5,1
    80005646:	dd3c                	sw	a5,120(a0)
}
    80005648:	60e2                	ld	ra,24(sp)
    8000564a:	6442                	ld	s0,16(sp)
    8000564c:	64a2                	ld	s1,8(sp)
    8000564e:	6105                	addi	sp,sp,32
    80005650:	8082                	ret
    mycpu()->intena = old;
    80005652:	ea2fb0ef          	jal	ra,80000cf4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80005656:	8085                	srli	s1,s1,0x1
    80005658:	8885                	andi	s1,s1,1
    8000565a:	dd64                	sw	s1,124(a0)
    8000565c:	b7cd                	j	8000563e <push_off+0x20>

000000008000565e <acquire>:
{
    8000565e:	1101                	addi	sp,sp,-32
    80005660:	ec06                	sd	ra,24(sp)
    80005662:	e822                	sd	s0,16(sp)
    80005664:	e426                	sd	s1,8(sp)
    80005666:	1000                	addi	s0,sp,32
    80005668:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000566a:	fb5ff0ef          	jal	ra,8000561e <push_off>
  if(holding(lk))
    8000566e:	8526                	mv	a0,s1
    80005670:	f85ff0ef          	jal	ra,800055f4 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005674:	4705                	li	a4,1
  if(holding(lk))
    80005676:	e105                	bnez	a0,80005696 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005678:	87ba                	mv	a5,a4
    8000567a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000567e:	2781                	sext.w	a5,a5
    80005680:	ffe5                	bnez	a5,80005678 <acquire+0x1a>
  __sync_synchronize();
    80005682:	0ff0000f          	fence
  lk->cpu = mycpu();
    80005686:	e6efb0ef          	jal	ra,80000cf4 <mycpu>
    8000568a:	e888                	sd	a0,16(s1)
}
    8000568c:	60e2                	ld	ra,24(sp)
    8000568e:	6442                	ld	s0,16(sp)
    80005690:	64a2                	ld	s1,8(sp)
    80005692:	6105                	addi	sp,sp,32
    80005694:	8082                	ret
    panic("acquire");
    80005696:	00002517          	auipc	a0,0x2
    8000569a:	1ca50513          	addi	a0,a0,458 # 80007860 <digits+0x20>
    8000569e:	ca5ff0ef          	jal	ra,80005342 <panic>

00000000800056a2 <pop_off>:

void
pop_off(void)
{
    800056a2:	1141                	addi	sp,sp,-16
    800056a4:	e406                	sd	ra,8(sp)
    800056a6:	e022                	sd	s0,0(sp)
    800056a8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800056aa:	e4afb0ef          	jal	ra,80000cf4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800056ae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800056b2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800056b4:	e78d                	bnez	a5,800056de <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800056b6:	5d3c                	lw	a5,120(a0)
    800056b8:	02f05963          	blez	a5,800056ea <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800056bc:	37fd                	addiw	a5,a5,-1
    800056be:	0007871b          	sext.w	a4,a5
    800056c2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800056c4:	eb09                	bnez	a4,800056d6 <pop_off+0x34>
    800056c6:	5d7c                	lw	a5,124(a0)
    800056c8:	c799                	beqz	a5,800056d6 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800056ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800056ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800056d2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800056d6:	60a2                	ld	ra,8(sp)
    800056d8:	6402                	ld	s0,0(sp)
    800056da:	0141                	addi	sp,sp,16
    800056dc:	8082                	ret
    panic("pop_off - interruptible");
    800056de:	00002517          	auipc	a0,0x2
    800056e2:	18a50513          	addi	a0,a0,394 # 80007868 <digits+0x28>
    800056e6:	c5dff0ef          	jal	ra,80005342 <panic>
    panic("pop_off");
    800056ea:	00002517          	auipc	a0,0x2
    800056ee:	19650513          	addi	a0,a0,406 # 80007880 <digits+0x40>
    800056f2:	c51ff0ef          	jal	ra,80005342 <panic>

00000000800056f6 <release>:
{
    800056f6:	1101                	addi	sp,sp,-32
    800056f8:	ec06                	sd	ra,24(sp)
    800056fa:	e822                	sd	s0,16(sp)
    800056fc:	e426                	sd	s1,8(sp)
    800056fe:	1000                	addi	s0,sp,32
    80005700:	84aa                	mv	s1,a0
  if(!holding(lk))
    80005702:	ef3ff0ef          	jal	ra,800055f4 <holding>
    80005706:	c105                	beqz	a0,80005726 <release+0x30>
  lk->cpu = 0;
    80005708:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000570c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80005710:	0f50000f          	fence	iorw,ow
    80005714:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80005718:	f8bff0ef          	jal	ra,800056a2 <pop_off>
}
    8000571c:	60e2                	ld	ra,24(sp)
    8000571e:	6442                	ld	s0,16(sp)
    80005720:	64a2                	ld	s1,8(sp)
    80005722:	6105                	addi	sp,sp,32
    80005724:	8082                	ret
    panic("release");
    80005726:	00002517          	auipc	a0,0x2
    8000572a:	16250513          	addi	a0,a0,354 # 80007888 <digits+0x48>
    8000572e:	c15ff0ef          	jal	ra,80005342 <panic>
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
