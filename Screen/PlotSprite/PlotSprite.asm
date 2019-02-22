// ZX Spectrum Plot Sprite demo by krom (Peter Lemon):
// Original Code by John Metcalf
arch zxs.cpu
output "PlotSprite.z80", create
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

// Fill Screen Bitmap Area With Alternating Pixels Each Scanline
ld hl,SCR_BMP+6143 // HL = Screen Bitmap Area End Address ($4000+6143)
FillBMP:
  ld a,h
  rra
  sbc a,a
  xor %01010101
  ld (hl),a
  dec hl
  bit 6,h
  jr nz,FillBMP

// Plot Sprite Over Screen Bitmap Area
ld hl,Sprite // HL = Sprite Address
ld de,$8050  // DE = Sprite Position On Screen (D = X Position, E = Y Position)

PutSprite:
  ld c,16
NextLine:
  ld a,d
  and 7
  inc a
  ld b,a
  ld a,e
  rra
  cp 96
  ret nc
  rra
  or a
  rra
  push de
  push hl
  ld l,a
  xor e
  and 248
  xor e
  ld h,a
  ld a,l
  xor d
  and 7
  xor d
  rrca
  rrca
  rrca
  ld l,a

  ld e,255
SPD:
  ex (sp),hl
  ld a,(hl)
  inc hl
  ld d,(hl)
  inc hl
  ex (sp),hl

  push bc
  rrc e
  jr NoShift
ShiftSPR:
  rra
  rr d
  rr e
NoShift:
  djnz ShiftSPR

  push hl
  ld b,3
Mask:
  bit 0,e
  jr z,BM1
  and (hl)
db 254 // jr BM2
BM1:
  xor (hl)
BM2:
  ld (hl),a
  inc l
  ld a,l
  and 31
  ld a,d
  ld d,e
  jr z,Clip
  djnz Mask
Clip:
  bit 0,e
  ld e,0
  pop hl
  pop bc
  jr nz,SPD
  pop hl
  pop de
  inc e
  dec c
  jr nz,NextLine

Loop:
  jr Loop

Sprite:
  db %11111100, %00111111, %00000000, %00000000
  db %11110000, %00001111, %00000011, %11000000
  db %11100000, %00000111, %00001100, %00110000
  db %11000000, %00000011, %00010000, %00001000

  db %10000000, %00000001, %00100010, %00000100
  db %10000000, %00000001, %00100111, %00000100
  db %00000000, %00000000, %01000010, %00010010
  db %00000000, %00000000, %01000000, %00001010

  db %00000000, %00000000, %01000000, %00010010
  db %00000000, %00000000, %01000000, %00101010
  db %10000000, %00000001, %00100000, %01010100
  db %10000000, %00000001, %00100010, %10100100

  db %11000000, %00000011, %00010001, %01001000
  db %11100000, %00000111, %00001100, %00110000
  db %11110000, %00001111, %00000011, %11000000
  db %11111100, %00111111, %00000000, %00000000