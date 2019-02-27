// ZX Spectrum Keyboard Input demo by krom (Peter Lemon):
arch zxs.cpu
output "Keyboard.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5CCB) ; Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

// Fill Screen Color Area With Full Brightness, White Paper Color, Black Ink Color
ld hl,SCR_COL+767 // HL = Screen Color Area End Address ($5800+767)
ld a,BRIGHT+P_WHITE+I_BLACK // A = Color Attributes (%FBPPPIII: F = FLASH Mode, B = BRIGHTNESS Mode, P = PAPER Color, I = INK Color)
FillCOL:
  ld (hl),a     // Store Color Attributes (A) To Screen Color Area Address (HL)
  dec hl        // Decrement Screen Color Address (HL--)
  bit 3,h       // Test Bit 3 Of Screen Color Address MSB (H)
  jr nz,FillCOL // IF (Bit 3 Of Screen Color Address MSB != 0) Fill Color

// Print Text Characters To Screen Bitmap Area
ld c,20*8 // C = Byte Copy Count (20 Characters * 8 Bytes)
ld de,SCR_BMP+6+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 6, ROW = 3, SCREEN BLOCK = 1)
ld ix,Text // IX = Text Offset

LoopText:
  ld h,0 // H = 0
  ld l,(ix+$00) // L = Next Text Character (L = IX[0])
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld a,Font8x8-($20*8) // A = Font Address LSB
  add a,l // A += L
  ld l,a  // L = A
  ld a,Font8x8-($20*8)>>8 // A = Font Address MSB
  adc a,h // A += H + Carry
  ld h,a  // H = A

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopTextByte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopTextByte // Decrement Count (B--), IF (Count != 0): Loop Text Byte

  xor a // A = 0
  cp c  // Compare C To A
  jr z,TextEnd // IF (Z Flag Set): Text End

  ld a,-7 // A = -7
  add a,d // Subtract 7 From Screen Bitmap Area Address MSB (D -= 7) (7 Scanlines Up)
  ld d,a  // D = A
  inc ix  // Increment Text Offset (IX++)
  jr LoopText
  TextEnd:

Loop:
  // Print Keyboard Text Character To Screen Bitmap Area
  call ReadKeyboard // A = Character Byte Code From Pressed Key
  cp 0 // Compare A To 0
  jr z,Skip // IF (A = 0): Skip

  ld de,SCR_BMP+24+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 24, ROW = 3, SCREEN BLOCK = 1)
  ld h,0 // H = 0
  ld l,a // L = Text Character (A)
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld a,Font8x8-($20*8) // A = Font Address LSB
  add a,l // A += L
  ld l,a  // L = A
  ld a,Font8x8-($20*8)>>8 // A = Font Address MSB
  adc a,h // A += H + Carry
  ld h,a  // H = A

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopKeyTextByte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopKeyTextByte // Decrement Count (B--), IF (Count != 0): Loop Key Text Byte

  Skip:
    jr Loop

ReadKeyboard: // Read Keyboard (A = Character Byte Code From Pressed Key)
  ld hl,KeyboardMap // HL = Keyboard Map Address
  ld d,8            // D = Keyboard ROW Count (Number Of Keyboard Ports To Check = 8)
  ld c,$FE          // C = Keyboard Port LSB Address (Always $FE For Reading Keyboard Ports)
  ReadPort:
    ld b,(hl) // B = Keyboard Port MSB Address From Table (BC = Keyboard Port)
    inc hl    // Increment Keyboard Map Address (HL++) To Get Key List
    in a,(c)  // A = Row Of Keys From Keyboard Port (BC)
    and $1F   // A &= $1F (Mask 1st 5 Bits)
    ld e,5    // E = Key Count (Number Of Keys In Row = 5)
    ReadKey:
      srl a          // Logical Shift A Right, Carry Flag = Bit 0
      jr nc,KeyFound // IF (Carry = 0): Key Found
      inc hl         // ELSE: Increment Keyboard Map Address (HL++) For Next Table Address
      dec e          // Decrement Key Count (E--)
      jr nz,ReadKey  // IF (Key Count != 0) Read Key
      dec d          // Decrement Keyboard ROW Count (D--)
      jr nz,ReadPort // IF (Keyboard ROW Count != 0) Read Port
      and a          // Key Not Found: A = 0
      ret
    KeyFound:
      ld a,(hl) // Key Found: A = Character Byte Code
      ret
KeyboardMap:
  db $FE, "#","Z","X","C","V" // ROW 0: Keyboard Port MSB, Character 0..4
  db $FD, "A","S","D","F","G" // ROW 1: Keyboard Port MSB, Character 0..4
  db $FB, "Q","W","E","R","T" // ROW 2: Keyboard Port MSB, Character 0..4
  db $F7, "1","2","3","4","5" // ROW 3: Keyboard Port MSB, Character 0..4
  db $EF, "0","9","8","7","6" // ROW 4: Keyboard Port MSB, Character 0..4
  db $DF, "P","O","I","U","Y" // ROW 5: Keyboard Port MSB, Character 0..4
  db $BF, "#","L","K","J","H" // ROW 6: Keyboard Port MSB, Character 0..4
  db $7F, " ","#","M","N","B" // ROW 7: Keyboard Port MSB, Character 0..4

Text:
  db "Keyboard Input = \d \d" // Keyboard Input Text (20 Bytes)

Font8x8:
  include "Font8x8.asm" // Include 8x8 Font