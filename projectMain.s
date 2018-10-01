.global _start

.section .text
_start:
#initialize stack pointer
movia sp, 0x04061A8F

#initialize and reset timer
movia r8, 0xFF202000
movui r9, %lo(1000000000)
stwio r9, 8(r8)
movui r9, %hi(1000000000)
stwio r9, 12(r8)
stwio r0, 0(r8)

#enable interrupts on CPU (0 timer, 6 audio, 8JTAG)
movia r10, 0x141
wrctl ctl3, r10

#turn off all LEDS
movia r10, LEDR
stwio r0, 0(r10)

#disable the audio interrupts
movia r10, audio_ptr
stwio r0, 0(r10)

#enable interrupt switch
movia r10, 0x1
wrctl ctl0, r10 

#enable JTAG interrupt
movia r10, 0xFF201000
movia r11, 0x1
stwio r11, 4(r10)

#draw beginning screen
call printStart

LOOP:
br LOOP
.end
