// ZX Spectrum Beeper Play Sample demo by krom (Peter Lemon):
// Original Code by Miguel Angel Rodriguez Jodar. (mcleod_ideafix)
// Simple player for 1-bit samples. See file 8tosigmadelta.c for sigma-delta
// offline conversion of RAW 8-bit PCM sample files to 1-bit sample files.

arch zxs.cpu
output "BeeperPlaySample.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($8000); Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

di // Disable Interrupts
Loop:
  ld hl,Sample
  ld de,Sample.size
  call PlaySample
  jr Loop

PlaySample: // Play Sigma-Delta Sample On Beeper (DE = Sample Length, HL = Sample Address) (Requires Disabled Interrupts)
  ld a,(hl) // Load 8 Samples
  ld b,8    // B = Count (8)
  LoopSample:
    ld c,a  // Backup To C
    and $80 // Isolate High Bit
    sra a   // A >>= 3 (Shift To Beeper Sound Bit)
    sra a
    sra a
    or I_BLACK // Apply Desired Border Color
    out (SND_BCOL),a // Write Beeper Attributes To Beeper Register Port ($FE)
    ld a,c // Restore From C
    rla // Next Sample Now In High Bit
//    nop // Place NOPs Here To Slow Down Playback Rate
    djnz LoopSample // Decrement Count (B--), IF (Count != 0) Process Next Sample
    inc hl
    dec de
    ld a,d
    or e
  jp nz,PlaySample // Process Next 8 Samples
  ret

insert Sample, "sample.bin" // Include 22050Hz 4-Bit Sigma-Delta Sample Data (8856 Bytes)