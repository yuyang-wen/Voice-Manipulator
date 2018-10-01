.global printEnd

printEnd:

  #prelogue
  subi sp, sp, 12
  stw r6, 0(sp)
  stw r5, 4(sp)
  stw ra, 8(sp)

  call clearScreen

  #move address into reg r6 has char r7 has pixel
  movia r6, 0x09000000


  #put characters into the character buffer
  movi  r5, 0x45   /* ASCII for 'E' */
  stbio r5,3749(r6) /* character (37,29) is x + y*128 so (37 + 3712 = 3749) */
  movi  r5, 0x4E   /* ASCII for 'N' */
  stbio r5,3751(r6) /* character (39,29) is x + y*128 so (39 + 3712 = 3751) */
  movi  r5, 0x44   /* ASCII for 'D' */
  stbio r5,3753(r6) /* character (41,29) is x + y*128 so (41 + 3712 = 3753) */

  #epilogue
  ldw r5, 4(sp)
  ldw r6, 0(sp)
  ldw ra, 8(sp)
  addi sp, sp, 12
  
ret
