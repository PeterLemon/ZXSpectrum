// ZX Spectrum Plot Pixel demo by krom (Peter Lemon):
arch zxs.cpu
output "PlotPixel.z80", create
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

// Plot Pixel In Screen Bitmap Area
ld hl,SCR_BMP+$810 // HL = Screen Bitmap Area Address ($4000+$810)
ld a,%10000000     // A = Bitmap Byte (1st Pixel Set)
ld (hl),a          // Store Bitmap Byte (A) To Screen Color Area Address (HL)

Loop:
  jr Loop