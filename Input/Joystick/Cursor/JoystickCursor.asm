// ZX Spectrum Joystick Cursor Input demo by krom (Peter Lemon):
arch zxs.cpu
output "JoystickCursor.z80", create
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
ld c,27*8 // C = Byte Copy Count (27 Characters * 8 Bytes)
ld de,SCR_BMP+2+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 2, ROW = 3, SCREEN BLOCK = 1)
ld ix,Text // IX = Text Offset

LoopText:
  ld h,0 // H = 0
  ld l,(ix+$00) // L = Next Text Character (L = IX[0])
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld a,c // A = Byte Copy Count (C)
  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)
  ld c,a // C = Byte Copy Count (A)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopTextByte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopTextByte // Decrement Count (B--), IF (Count != 0) Loop Text Byte

  xor a // A = 0
  cp c  // Compare C To A
  jr z,TextEnd // IF (Z Flag Set) Text End

  ld a,-7 // A = -7
  add a,d // Subtract 7 From Screen Bitmap Area Address MSB (D -= 7) (7 Scanlines Up)
  ld d,a  // D = A
  inc ix  // Increment Text Offset (IX++)
  jr LoopText
  TextEnd:

Loop:
  // Print Joystick Cursor Text Character To Screen Bitmap Area
  call ReadJoystickCursor // A = Character Byte Code From Pressed Button
  cp 0 // Compare A To 0
  jr z,Skip // IF (A = 0) Skip

  ld de,SCR_BMP+27+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 27, ROW = 3, SCREEN BLOCK = 1)
  ld h,0 // H = 0
  ld l,a // L = Text Character (A)
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopButtonTextByte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopButtonTextByte // Decrement Count (B--), IF (Count != 0) Loop Button Text Byte

  Skip:
    jr Loop

ReadJoystickCursor: // Read Joystick Cursor (A = Character Byte Code From Pressed Button)
  ld hl,CursorMap // HL = Cursor Map Address
  ld bc,$F7FE // BC = Cursor Address A ($F7FE)
  in a,(c)    // A = Buttons From Cursor Address A (BC)
  and $10     // A &= $10 (Mask Bit 4)
  srl a       // A >>= 3
  srl a
  srl a
  ld d,a      // D = A
  ld b,$EF    // BC = Cursor Address B ($EFFE)
  in a,(c)    // A = Buttons From Cursor Address B (BC)
  and $1D     // A &= $1D (Mask Bits 0,2,3,4)
  or d        // A |= D
  ld b,5      // B = Button Count (Number Of Buttons = 5)
  ReadButton:
    srl a             // Logical Shift A Right, Carry Flag = Bit 0
    jr nc,ButtonFound // IF (Carry Flag = 0) Button Found
    inc hl            // ELSE: Increment Cursor Map Address (HL++) For Next Table Address
    djnz ReadButton   // Decrement Button Count (B--), IF (Button Count != 0) Read Button
    ret               // Button Not Found: A = 0
  ButtonFound:
    ld a,(hl) // Button Found: A = Character Byte Code
    ret
CursorMap:
  db "F","L","R","U","D" // Character 0..4

Text:
  db "Joystick Cursor Input = \d \d" // Joystick Cursor Input Text (27 Bytes)

Font8x8:
  include "Font8x8.asm" // Include 8x8 Font