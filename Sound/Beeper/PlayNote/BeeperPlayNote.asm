// ZX Spectrum Beeper Play Note demo by krom (Peter Lemon):
arch zxs.cpu
output "BeeperPlayNote.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5B00); Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

xor a // A = 0
LoopNote:
  xor %00010111    // A = Beeper Attributes (---S-BBB: S = BEEPER Sound, B = BORDER Color)
  out (SND_BCOL),a // Write Beeper Attributes To Beeper Register Port ($FE)
  ld bc,1000       // BC = Pitch (Lower Number = Higher Pitch)
  Wait:
    dec c       // Decrement Pitch LSB (C--)
    jr nz,Wait  // IF (Pitch LSB != 0) Wait
    dec b       // Decrement Pitch MSB (B--)
    jr nz,Wait  // IF (Pitch MSB != 0) Wait
    jr LoopNote // ELSE Loop Note