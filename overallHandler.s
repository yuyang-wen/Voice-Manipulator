.global buffer_index
.global rightbuffer
.global leftbuffer
.global BUF_SIZE
.global audio_ptr
.equ BUF_SIZE, 2000000
.equ audio_ptr, 0xFF203040

.equ LEDR, 0xFF200000
.equ TIMER, 0xFF202000
.section .data
rightbuffer: .skip 2000000
leftbuffer: .skip 2000000
buffer_index: .word 0

.section .exceptions, "ax"
handler:
subi		sp, sp, 128
stw		et, 96(sp)
rdctl	et, ctl4
beq		et, r0, SKIP_EA_DEC #internal interrupt       
subi		ea, ea, 4

SKIP_EA_DEC:		# Save all registers 
stw	r2,  8(sp)
stw	r3,  12(sp)
stw	r4,  16(sp)
stw	r5,  20(sp)
stw	r6,  24(sp)
stw	r7,  28(sp)
stw	r8,  32(sp)
stw	r9,  36(sp)
stw	r10, 40(sp)
stw	r11, 44(sp)
stw	r12, 48(sp)
stw	r13, 52(sp)
stw	r14, 56(sp)
stw	r15, 60(sp)
stw	r16, 64(sp)
stw	r17, 68(sp)
stw	r18, 72(sp)
stw	r19, 76(sp)
stw	r20, 80(sp)
stw	r21, 84(sp)
stw	r22, 88(sp)
stw	r23, 92(sp)		# r25 = bt (skip r24 = et, because it is saved above)
stw	r26, 104(sp)		# r26 = gp
# skip r27 because it is sp, and there is no point in saving this
stw	r28, 112(sp)		# r28 = fp
stw	r29, 116(sp)		# r29 = ea		# r30 = ba
stw	r31, 124(sp)		# r31 = ra
addi fp,  sp, 128

#main handler, et contains cctrl4
movia r5, 0x100
and r6, r5, et
beq r5, r6, JTAGISR

CHECKTIMER:
movia r5, 0x01
and r6, r5, et
beq r5, r6, TIMERISR

CHECKAUDIO:
movia r5, 0x40
and r6, r5, et
beq r5, r6, AUDIOISR

br EPILOGUE

#JTAG interrupt
JTAGISR:
call UARTinterrupt
br CHECKTIMER

#timer interrupt
TIMERISR:
#write end screen on VGA
call printEnd
#clear timeout flag and disable interrupt
movia r7, 0xFF202000
stwio r0, 0(r7) 
#stop timer
movia r10, 8
stwio r10, 4(r7)
#continue to check other interrupts
br CHECKAUDIO

#audio interrupt
AUDIOISR:
#move audio port address in r10
#audio read interrupt
movia r10, audio_ptr
ldwio r10, 0(r10)
movia r5, 0x100
and r6, r10, r5
beq r6, r5, AUDIO_RI 
#audio write interrupt
CHECK_AUDIO_WI:
movia r10, 0xFF203040
ldwio r10, 0(r10)
movia r5, 0x200
and r6, r10, r5
beq r6, r5, AUDIO_WI 
br EPILOGUE
AUDIO_RI:
#read audio port fifo
#disable the audio interrupts
movia r10, audio_ptr

ldwio r11, 4(r10)
#initilaize buffer counter
movia r15, buffer_index #r15 cpntains the buffer index address
ldw r13, 0(r15) #r13 contains the buffer index value

RI_WHILE:
#while condition 1
andi r12, r11, 0x000000FF
beq r12, r0, CHECK_AUDIO_WI
#while condition 2
movia r14, BUF_SIZE
bge r13, r14, CHECK_AUDIO_WI

movia r14, leftbuffer
movia r17, rightbuffer

add r12, r13, r14 
#get all of the left data from the MIC FIFO
ldwio r16, 8(r10)
#store it into the left buffer
stw r16, 0(r12)

add r12, r13, r17 
#get all of the right data from the MIC FIFO
ldwio r16, 12(r10)
#store it into the right buffer
stw r16, 0(r12)

#increment the buffer index
addi r13, r13, 4
stw r13, 0(r15) #store the buffer index back into the buffer index address

#check if the buffer index is max 

movia r14, BUF_SIZE
bne r13, r14, end_of_rwhile

#done recording
#may need a record = 0  line here 
#make ledr turn up here
movia r18, LEDR
stwio r0, 0(r18)
#clears the audio interrupts
stwio r0, 0(r10) 

end_of_rwhile:


#read audio port fifo
ldwio r11, 4(r10)

br RI_WHILE


AUDIO_WI:
#read audio port fifo
#disable the audio interrupts
movia r10, audio_ptr

ldwio r11, 4(r10)
#initilaize buffer counter
movia r15, buffer_index #r15 cpntains the buffer index address
ldw r13, 0(r15) #r13 contains the buffer index value

WI_WHILE:

#while condition 1
movia r12, 0x00FF0000
and r12, r11, r12
beq r12, r0, EPILOGUE
#while condition 2
movia r14, BUF_SIZE
bge r13, r14, EPILOGUE

movia r14, leftbuffer
movia r17, rightbuffer

add r12, r13, r14 
#load data from the into the left buffer
ldw r16, 0(r12)
#store the left data to the MIC FIFO
stwio r16, 8(r10)

add r12, r13, r17 
#load data from the right buffer
ldw r16, 0(r12)
#store the right data to the MIC FIFO
stwio r16, 12(r10)

#increment the buffer index
addi r13, r13, 4
stw r13, 0(r15) #store the buffer index back into the buffer index address

#check if the buffer index is max 

movia r14, BUF_SIZE
bne r13, r14, end_of_wwhile

#done recording
#may need a record = 0  line here 
#make ledr turn up here
movia r18, LEDR
stwio r0, 0(r18)
#clears the audio interrupts
stwio r0, 0(r10) 

end_of_wwhile:


#read audio port fifo
ldwio r11, 4(r10)

br WI_WHILE
EPILOGUE:		# Restore all registers
ldw	r2,  8(sp)
ldw	r3,  12(sp)
ldw	r4,  16(sp)
ldw	r5,  20(sp)
ldw	r6,  24(sp)
ldw	r7,  28(sp)
ldw	r8,  32(sp)
ldw	r9,  36(sp)
ldw	r10, 40(sp)
ldw	r11, 44(sp)
ldw	r12, 48(sp)
ldw	r13, 52(sp)
ldw	r14, 56(sp)
ldw	r15, 60(sp)
ldw	r16, 64(sp)
ldw	r17, 68(sp)
ldw	r18, 72(sp)
ldw	r19, 76(sp)
ldw	r20, 80(sp)
ldw	r21, 84(sp)
ldw	r22, 88(sp)
ldw	r23, 92(sp)
ldw	r24, 96(sp)		# r25 = bt
ldw	r26, 104(sp)		# r26 = gp
# skip r27 because it is sp, and we did not save this on the stack
ldw	r28, 112(sp)		# r28 = fp
ldw	r29, 116(sp)		# r29 = ea		# r30 = ba
ldw	r31, 124(sp)		# r31 = ra
addi	sp,  sp, 128

eret







