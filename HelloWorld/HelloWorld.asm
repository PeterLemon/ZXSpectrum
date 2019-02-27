// ZX Spectrum Hello World Text Printing demo by krom (Peter Lemon):
arch zxs.cpu
output "HelloWorld.z80", create
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
ld c,13*8 // C = Byte Copy Count (13 Characters * 8 Bytes)
ld de,SCR_BMP+9+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 9, ROW = 3, SCREEN BLOCK = 1)
ld ix,Text // IX = Text Offset

LoopText:
  ld h,0 // H = 0
  ld l,(ix+$00) // HL = Text Character Address
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl

  ld a,Font8x8-($20*8) // A = Font Address LSB
  add a,l // A += L
  jr nc,NoIncrement
  inc h   // IF (Carry Set): H++
  NoIncrement:
  ld l,a  // L = A

  ld a,Font8x8-($20*8)>>8 // A = Font Address MSB
  add a,h // A += H
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
  jr Loop

Text:
  db "Hello, World!" // Hello World Text (13 Bytes)

Font8x8:
  include "Font8x8.asm" // Include 8x8 Font