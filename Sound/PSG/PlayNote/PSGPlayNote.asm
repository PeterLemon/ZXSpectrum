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
ld d,PSG_FINE_TUNE_A // D = PSG Channel A Fine Tune Address ($00)
ld e,0               // E = PSG Channel A Fine Tune (Bits 0..7 Fine Tune = 0)
call PSGWrite        // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_COARSE_TUNE_A // D = PSG Channel A Course Tune Address ($01)
ld e,1                 // E = PSG Channel A Coarse Tune (Bits 0..3 Course Tune = 1)
call PSGWrite          // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_MODE_VOL_A // D = PSG Channel A Mode/Volume Address ($08)
ld e,15             // E = PSG Channel A Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 15)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_KEY   // D = PSG Channel Enable Address ($07)
ld e,%00111110 // E = PSG Channel A Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
call PSGWrite  // PSG Write Data (D = PSG Address, E = PSG Data)

Loop:
  jr Loop

PSGRead: // PSG Read Data (A = PSG Address, Return A = PSG Data)
  ld bc,AY8912_ADDR // BC = AY8912 Address/Read Data Port ($FFFD)
  out (c),a         // Write PSG Address (A) To AY8912 Address Port (BC)
  in a,(c)          // Read PSG Data (A) From AY8912 Read Data Port (BC)
  ret

PSGWrite: // PSG Write Data (D = PSG Address, E = PSG Data)
  ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
  out (c),d            // Write PSG Address (D) To AY8912 Address Port (BC)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),e            // Write PSG Data (E) To AY8912 Write Data Port (BC)
  ret