// ZX Spectrum Fill Screen demo by krom (Peter Lemon):
arch zxs.cpu
output "FillScreen.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5B00) ; Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

// Fill Screen Bitmap & Color Area With Screen Data
ld de,Screen+Screen.size-1 // DE = Screen Data End Address
ld hl,SCR_COL+767 // HL = Screen Color Area End Address ($5800+767)
FillSCR:
  ld a,(de)     // A = Screen Data Byte
  dec de        // Decrement Screen Data Address (HL--)
  ld (hl),a     // Store Screen Data (A) To Screen Address (HL)
  dec hl        // Decrement Screen Address (HL--)
  bit 6,h       // Test Bit 6 Of Screen Address MSB (H)
  jr nz,FillSCR // IF (Bit 6 Of Screen Address MSB != 0) Fill Screen

Loop:
  jr Loop

insert Screen, "GFX/Lenna.scr" // Include Screen Data (6912 Bytes)