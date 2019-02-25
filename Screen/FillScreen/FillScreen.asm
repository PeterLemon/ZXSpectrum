// ZX Spectrum Fill Screen demo by krom (Peter Lemon):
arch zxs.cpu
output "FillScreen.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5CCB) ; Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

// Fill Screen Bitmap & Color Area With Screen Data
ld bc,Screen.size // BE = Screen Data Size Count (6912 Bytes)
ld de,SCR_BMP     // DE = Screen Bitmap Area Start Address ($4000)
ld hl,Screen      // HL = Screen Data Start Address
ldir // Copy Screen Data To Screen Bitmap/Color Area (WHILE BC > 0 (LD (DE),(HL), DE++, HL++, BC--))

Loop:
  jr Loop

insert Screen, "GFX/Lenna.scr" // Include Screen Data (6912 Bytes)