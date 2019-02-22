// ZX Spectrum Fill Pixel demo by krom (Peter Lemon):
// Original Code by Introspec
arch zxs.cpu
output "FillPixel.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5B00) ; Start: // Entry Point Of Code
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

Loop:
  jr Loop