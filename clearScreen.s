.global clearScreen

clearScreen:

  #prelogue
  subi sp, sp, 44
  stw r6, 0(sp)
  stw r5, 4(sp)
  stw r7, 8(sp)
  stw r16, 12(sp)
  stw r17, 16(sp)
  stw r18, 20(sp)
  stw r19, 24(sp)
  stw r20, 28(sp)
  stw r21, 32(sp)
  stw r22, 36(sp)
  stw ra, 40(sp)

  #move address into reg r6 has char r7 has pixel
  movia r6, 0x09000000
  movia r7, 0x08000000

  #clear pixel buffer
  movia r16, 0
  movia r17, 0
  movui r20, 0x0000
  #pixel formula is 2*x + 1024*y (320 columns by 240 rows) 
  OUTERLOOP:
  movia r16, 0 
  INNERLOOP:
  add r19, r7, r16
  add r19, r17, r19 
  sthio r20, 0(r19)
  addi r16, r16, 2
  movia r18, 638
  bne r16, r18, INNERLOOP
  addi r17, r17, 1024
  movia r18, 245760
  bne r17, r18, OUTERLOOP

  #clear character buffer
  movia r16, 0
  movia r17, 0
  movi r20, 0x20
  #pixel formula is x + 128*y (80 columns by 60 rows) 
  OUTERLOOP2:
  movia r16, 0 
  INNERLOOP2:
  add r19, r6, r16
  add r19, r17, r19 
  sthio r20, 0(r19)
  addi r16, r16, 1
  movia r18, 80
  bne r16, r18, INNERLOOP2
  addi r17, r17, 128
  movia r18, 7680
  bne r17, r18, OUTERLOOP2

  #epilogue
  ldw r16, 12(sp)
  ldw r17, 16(sp)
  ldw r18, 20(sp)
  ldw r19, 24(sp)
  ldw r20, 28(sp)
  ldw r21, 32(sp)
  ldw r22, 36(sp)
  ldw r7, 8(sp)
  ldw r5, 4(sp)
  ldw r6, 0(sp)
  ldw ra, 40(sp)
  addi sp, sp, 44
  
ret
