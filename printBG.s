.data
BGIMG: .incbin "bg.bmp"

.global printBG

.text
printBG:
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

call clearScreen

#move address into r6 img adress into r7
movia r6, 0x08000000
movia r7, BGIMG

movia r16, 0
movia r17, 0
movia r21, 0 #change 0 to header skip
#pixel formula is 2*x + 1024*y (320 columns by 240 rows)

OUTERLOOP:
movia r16, 0 
INNERLOOP:
add r19, r6, r16
add r19, r17, r19 
add r20, r7, r21
ldwio r20, 0(r20) # r20 contains the current color
sthio r20, 0(r19) # store color in r20 into address r19
addi r16, r16, 2
addi r21, r21, 1 # increment counter for bmp file
movia r18, 638
bne r16, r18, INNERLOOP
addi r17, r17, 1024
movia r18, 245760
bne r17, r18, OUTERLOOP

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
