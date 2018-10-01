.global printStart

printStart:

  #prelogue
  subi sp, sp, 12
  stw r3, 0(sp)
  stw r5, 4(sp)
  stw ra, 8(sp)

  call clearScreen

  #move address into reg
  movia r3, 0x09000000

  #put characters into the character buffer
  movi  r5, 0x53   /* ASCII for 'S */
  stbio r5,3747(r3) /* character (35,29) is x + y*128 so (35 + 3712 = 3747) */
  movi  r5, 0x54   /* ASCII for 'T' */
  stbio r5,3749(r3) /* character (37,29) is x + y*128 so (37 + 3712 = 3749) */
  movi  r5, 0x41   /* ASCII for 'A' */
  stbio r5,3751(r3) /* character (39,29) is x + y*128 so (39 + 3712 = 3751) */
  movi  r5, 0x52   /* ASCII for 'R' */
  stbio r5,3753(r3) /* character (41,29) is x + y*128 so (41 + 3712 = 3753) */
  movi  r5, 0x54   /* ASCII for 'T' */
  stbio r5,3755(r3) /* character (43,29) is x + y*128 so (43 + 3712 = 3755) */

  #epilogue
  ldw ra, 8(sp)
  ldw r5, 4(sp)
  ldw r3, 0(sp)
  addi sp, sp, 12
  
ret
