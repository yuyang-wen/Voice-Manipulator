.global LEDR
.equ JTAG_UART_BASE, 0xFF201000
.equ JTAG_UART_RR, 0
.equ JTAG_UART_TR, 0
.equ JTAG_UART_CSR, 4
.equ LEDR, 0xFF200000
.equ TIMER, 0xFF202000


.section .data
thechar:    .byte ''               # the character that will be sent. It is read by our program and overwritten by the interrupt handler.
record: .byte 'r'
play: .byte 'p'

.global UARTinterrupt
.section .text 
.align 2


UARTinterrupt:  

 

      # PROLOGUE
      subi  sp, sp, 12               # we will be saving two registers on the stack
      stw r2, 0(sp)               
      stw r5, 4(sp)
	  stw ra, 8(sp)               
 
      #get address for base
      movia r5, JTAG_UART_BASE

RIP:     

      ldwio r5, JTAG_UART_RR(r5)    # read RR in r2
                                    # this clears the IRQ1 request
      andi  r5, r5, 0xff            # a character was received, copy the lower 8 bits to r9
      movia r2, thechar             # write it to memory
      stb r5, 0(r2)

wait:
	  movia et, JTAG_UART_BASE	
      ldwio r2, JTAG_UART_CSR(et)   # read CSR in et
      srli  r2, r2, 16              # keep only the upper 16 bits
      beq   r2, r0, wait            # as long as the upper 16 bits were zero keep trying
      movia r5, thechar             # read the character from memory
      ldbu r4, 0(r5)       
      stwio r4, JTAG_UART_TR(et)    # place it in the output FIFO
		
	
	  movia r5, record             # read the character from memory
      ldbu r5, 0(r5) 
      beq r4, r5, recordingScreen
	  movia r5, play             # read the character from memory
      ldbu r5, 0(r5) 
      beq r4, r5, playback 

epilogue:

      # EPILOGUE
	  ldw ra, 8(sp)
      ldw r5, 4(sp)               # restore r5
      ldw r2, 0(sp)               # restore r2
      addi  sp, sp, 12               # restore stack pointer
      ret

recordingScreen:


call clearScreen

#reset the buffer index for recording
movia r2, buffer_index
ldw r0, 0(r2)

#clear the audio in FIFO 
movia r2, audio_ptr
movi r5, 0x4
stwio r5, 0(r2)

#turn off clear and enable audio in interrupts
movi r5, 0x1
stwio r5, 0(r2)


br ledr_and_timer_R

playback:

call  printPlaying

#reset the buffer index for playback
movia r2, buffer_index
stw r0, 0(r2)

#clear the audio out FIFO 
movia r2, audio_ptr
movi r5, 0x8
stwio r5, 0(r2)

#turn off clear and enable audio out interrupts
movi r5, 0x2
stwio r5, 0(r2)

br ledr_and_timer_W


ledr_and_timer_R: #right now it reverses it though
 #read LEDR value, reverse the value
      
      #initialize counter value
      movia r5, TIMER
       #reset the TIMER
      stwio r0, 0(r5)

      #enable start, enable cont, enable interrupt
      movui r2, 0b101
      stwio r2, 4(r5)



      movia r5, LEDR
      movi r2, 0x01
      stwio r2, 0(r5) #turn on LEDR 0
      br epilogue

ledr_and_timer_W: #right now it reverses it though
 #read LEDR value, reverse the value
      
      #initialize counter value
      movia r5, TIMER
       #reset the TIMER
      stwio r0, 0(r5)

      #enable start, enable cont, enable interrupt
      movui r2, 0b101
      stwio r2, 4(r5)



      movia r5, LEDR
      movi r2, 0x02
      stwio r2, 0(r5) #turn on LEDR 1
      br epilogue
