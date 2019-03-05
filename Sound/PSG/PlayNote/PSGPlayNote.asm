// ZX Spectrum 128K AY8912 PSG Play Note demo by krom (Peter Lemon):
arch zxs.cpu
output "PSGPlayNote.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($8000); Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions
include "LIB/ZXSPECTRUM_PSG.INC" // Include ZX Spectrum PSG Definitions

// Play Note On Tone Channel A
ld a,PSG_FINE_TUNE_A // A = PSG Channel A Fine Tune Address ($00)
ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
ld a,0               // A = PSG Channel A Fine Tune (Bits 0..7 Fine Tune = 0)
ld bc,AY8912_WRITE   // BC = AY8912 Write Data Port ($BFFD)
out (c),a            // Write PSG Channel A Fine Tune (A) To AY8912 Write Data Port (BC)

ld a,PSG_COARSE_TUNE_A // A = PSG Channel A Course Tune Address ($01)
ld bc,AY8912_ADDR      // BC = AY8912 Address Port ($FFFD)
out (c),a              // Write PSG Address (A) To AY8912 Address Port (BC)
ld a,1                 // A = PSG Channel A Coarse Tune (Bits 0..3 Course Tune = 1)
ld bc,AY8912_WRITE     // BC = AY8912 Write Data Port ($BFFD)
out (c),a              // Write PSG Channel A Course Tune (A) To AY8912 Write Data Port (BC)

ld a,PSG_MODE_VOL_A // A = PSG Channel A Mode/Volume Address ($08)
ld bc,AY8912_ADDR   // BC = AY8912 Address Port ($FFFD)
out (c),a           // Write PSG Address (A) To AY8912 Address Port (BC)
ld a,15             // A = PSG Channel A Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 15)
ld bc,AY8912_WRITE  // BC = AY8912 Write Data Port ($BFFD)
out (c),a           // Write PSG Channel A Course Tune (A) To AY8912 Write Data Port (BC)

ld a,PSG_KEY       // A = PSG Channel Enable Address ($07)
ld bc,AY8912_ADDR  // BC = AY8912 Address Port ($FFFD)
out (c),a          // Write PSG Address (A) To AY8912 Address Port (BC)
ld a,%00111110     // A = PSG Channel A Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
ld bc,AY8912_WRITE // BC = AY8912 Write Data Port ($BFFD)
out (c),a          // Write PSG Channel A Course Tune (A) To AY8912 Write Data Port (BC)

Loop:
  jr Loop