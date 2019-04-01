// ZX Spectrum 128K AY8912 PSG Axel-F Song Pattern demo by krom (Peter Lemon):
arch zxs.cpu
output "PSGAxel-F.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

macro ChannelPatternTone(CHANNEL, KEY, PERIODTABLE) { // Channel Pattern Tone Calculation
  ld l,(ix+({KEY}*2))   // L = Pattern List (LSB)
  ld h,(ix+({KEY}*2)+1) // H = Pattern List (MSB)
  add hl,de // HL += Pattern Offset Index (DE)

  ld a,(hl)      // A = Period Table Offset
  cp SUST        // Compare A To SUST Character ($FE)
  jr z,{#}KEYEND // IF (A == SUST) Key End

  // Key OFF
  ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
  ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  set {KEY},a          // A = PSG Channel Tone Disable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ld a,(hl)      // A = Period Table Offset
  cp REST        // Compare A To REST Character ($FF)
  jr z,{#}KEYEND // IF (A == REST) Key End

  // ELSE Channel: Key ON
  ld b,$00            // B = $00
  ld c,a              // C = Period Table Offset (A)
  ld hl,{PERIODTABLE} // HL = PeriodTable 16-Bit Address
  add hl,bc           // HL += BC

  ld a,PSG_FINE_TUNE_{CHANNEL} // A = PSG Channel Fine Tune Address
  ld bc,AY8912_ADDR            // BC = AY8912 Address Port ($FFFD)
  out (c),a                    // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,(hl)                    // A = PSG Channel Fine Tune
  inc hl                       // Increment Period Table Offset (HL++)
  ld b,AY8912_WRITE>>8         // BC = AY8912 Write Data Port ($BFFD)
  out (c),a                    // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ld a,PSG_COARSE_TUNE_{CHANNEL} // A = PSG Channel Course Tune Address
  ld b,AY8912_ADDR>>8            // BC = AY8912 Address Port ($FFFD)
  out (c),a                      // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,(hl)                      // A = Channel Course Tune
  ld b,AY8912_WRITE>>8           // BC = AY8912 Write Data Port ($BFFD)
  out (c),a                      // Write PSG Data (A) To AY8912 Write Data Port (BC)

  // Key ON
  ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
  ld b,AY8912_ADDR>>8  // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  res {KEY},a          // A = PSG Channel Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)
  {#}KEYEND: // Key End
}

macro ChannelPatternNoise(KEY) { // Channel Pattern Noise Calculation
  ld l,(ix+({KEY}*2))   // L = Pattern List (LSB)
  ld h,(ix+({KEY}*2)+1) // H = Pattern List (MSB)
  add hl,de // HL += Pattern Offset Index (DE)

  ld a,(hl)      // A = Period Table Offset
  cp SUST        // Compare A To SUST Character ($FE)
  jr z,{#}KEYEND // IF (A == SUST) Key End

  // Key OFF
  ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
  ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  set {KEY},a          // A = PSG Channel Tone Disable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ld a,(hl)      // A = Period Table Offset
  cp REST        // Compare A To REST Character ($FF)
  jr z,{#}KEYEND // IF (A == REST) Key End

  // ELSE Channel: Key ON
  ld a,PSG_NOISE_TUNE  // A = PSG Noise Tune Address ($06)
  ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,(hl)            // A = PSG Channel Noise Tune
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

  // Key ON
  ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
  ld b,AY8912_ADDR>>8  // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  res {KEY},a          // A = PSG Channel Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)
  {#}KEYEND: // Key End
}

// Constants
constant MaxQuant(128)   // Maximum Quantization ms
constant PatternSize(64) // Pattern Size (1..256)
constant ChannelCount(6) // Channel Count

seek($8000); Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions
include "LIB/ZXSPECTRUM_PSG.INC" // Include ZX Spectrum PSG Definitions

di   // Disable Interrupts
im 1 // Set Interrupt Mode 1
ei   // Enable Interrupts

// Disable All Channels
ld d,PSG_KEY        // D = PSG Channel Enable Address ($07)
ld e,%00111111      // E = PSG Channel Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

// Setup Channel A,B,C Tones
ld d,PSG_MODE_VOL_A // D = PSG Channel A Mode/Volume Address ($08)
ld e,$0F            // E = PSG Channel A Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 15)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_MODE_VOL_B // D = PSG Channel B Mode/Volume Address ($09)
ld e,$0F            // E = PSG Channel B Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 15)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_MODE_VOL_C // D = PSG Channel C Mode/Volume Address ($0A)
ld e,$0F            // E = PSG Channel C Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 15)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

StartSong:
  ld ix,PATTERNLIST // IX = Pattern List Address
  ld de,$0000       // DE = 0 (Pattern Offset Index)

LoopSong:
  ChannelPatternTone(A, 0, PeriodTable) // Channel A Tone Pattern Calculation: Channel, Key, Period Table
  ChannelPatternTone(B, 1, PeriodTable) // Channel B Tone Pattern Calculation: Channel, Key, Period Table
  ChannelPatternTone(C, 2, PeriodTable) // Channel C Tone Pattern Calculation: Channel, Key, Period Table

  ChannelPatternNoise(3) // Channel A Noise Pattern Calculation: Key
  ChannelPatternNoise(4) // Channel A Noise Pattern Calculation: Key
  ChannelPatternNoise(5) // Channel A Noise Pattern Calculation: Key

  // Delay (VSYNCS)
  ld b,MaxQuant/20 // B = Count
  Wait:
    halt // Power Down CPU Until An Interrupt Occurs
    djnz Wait // Decrement Count (B--), IF (Count != 0) Wait

  inc e                 // Increment Pattern Index Offset (LSB)
  ld a,e                // A = E (Pattern Index Offset)
  cp PatternSize        // Compare A To Pattern Size
  jr z,PatternIncrement // IF (A == Pattern Size) Pattern Increment
  jr PatternEnd         // ELSE Pattern End

  PatternIncrement: // Channel A..C Pattern Increment
    ld bc,ChannelCount*2 // BC = Channel Count * 2
    add ix,bc            // IX += BC (Pattern List Offset += Channel Count * 2)

    // Compare Pattern List End Address
    ld a,PATTERNLISTEND    // A = Pattern List End Offset (LSB)
    cp ixl                 // Compare A To Pattern List Offset (LSB)
    jr nz,PatternIncEnd    // IF (Pattern List Offset != Pattern List End Offset) Pattern Increment End, ELSE Set Pattern Loop Offset
    ld a,PATTERNLISTEND>>8 // A = Pattern List End Offset (MSB)
    cp ixh                 // Compare A To Pattern List Offset (MSB)
    jr nz,PatternIncEnd    // IF (Pattern List Offset != Pattern List End Offset) Pattern Increment End, ELSE Set Pattern Loop Offset

    // Set Pattern Loop Offset
    ld ix,PATTERNLISTLOOP // IX = Pattern List Loop

  PatternIncEnd:
    ld de,$0000 // DE = 0 (Pattern Offset Index)

  PatternEnd:
    jp LoopSong // Loop Song

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

PeriodTable: // Period Table Used For PSG Tone Freqencies
  PeriodTable() // Timing, 9 Octaves: A0..G9# (108 Words)

PATTERN00: // Pattern 00: Rest (Channel A..C)
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 1
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 2
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 3
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 4

PATTERN01: // Pattern 01: Saw Tooth (Channel A Tone)
  db F4,   SUST, SUST, REST, G4s,  SUST, REST, F4,   SUST, F4,   A4s,  SUST, F4,   SUST, D4s,  SUST // 1
  db F4,   SUST, SUST, REST, C5,   SUST, REST, F4,   SUST, F4,   C5s,  SUST, C5,   SUST, G4s,  SUST // 2
  db F4,   SUST, C5,   SUST, F5,   SUST, F4,   D4s,  SUST, D4s,  C4,   SUST, G4,   SUST, F4,   SUST // 3
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 4

PATTERN02: // Pattern 02: Bass (Channel B Tone)
  db F2,   SUST, SUST, SUST, F3,   SUST, SUST, D2s,  SUST, D3s,  C2,   SUST, C3,   SUST, D2s,  SUST // 9
  db F2,   SUST, SUST, SUST, F3,   SUST, SUST, SUST, SUST, C2,   C3,   SUST, D3s,  SUST, F3,   SUST // 10
  db C2s,  SUST, SUST, SUST, C3s,  SUST, SUST, D2s,  SUST, D3s,  C2,   SUST, C3,   SUST, D2s,  SUST // 11
  db F2,   SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, F3,   C3,   SUST, A2s,  SUST, G2s,  SUST // 12
PATTERN03: // Pattern 03: Bass (Channel B Tone)
  db F2,   SUST, SUST, SUST, F3,   SUST, SUST, D2s,  SUST, D3s,  C2,   SUST, C3,   SUST, D2s,  SUST // 21
  db F2,   SUST, SUST, SUST, F3,   SUST, SUST, SUST, SUST, C2,   C3,   SUST, D3s,  SUST, F3,   SUST // 22
  db C2s,  SUST, SUST, SUST, C3s,  SUST, SUST, D2s,  SUST, SUST, SUST, SUST, D3s,  SUST, SUST, SUST // 23
  db F2,   SUST, SUST, SUST, F3,   SUST, SUST, SUST, SUST, F3,   C3,   SUST, A2s,  SUST, G2s,  SUST // 24

PATTERN04: // Pattern 04: Staccato Saw Tooth (Channel A Tone)
  db REST, REST, F4,   SUST, SUST, SUST, F4,   G4,   SUST, G4,   SUST, G4,   F4,   SUST, F4,   SUST // 21
  db SUST, REST, F4,   SUST, F4,   SUST, F4,   G4,   SUST, G4,   F4,   SUST, F4,   SUST, SUST, SUST // 22
  db SUST, REST, C4s,  SUST, C4s,  SUST, C4s,  SUST, C4s,  D4s,  SUST, D4s,  SUST, D4s,  SUST, D4s  // 23
  db D4s,  SUST, F4,   SUST, F4,   SUST, F4,   SUST, D4s,  F4,   SUST, F4,   SUST, SUST, SUST, REST // 24

PATTERN05: // Pattern 05: Staccato Saw Tooth (Channel C Tone)
  db REST, REST, C5,   SUST, SUST, SUST, C5,   D5s,  SUST, D5s,  SUST, D5s,  D5,   SUST, D5,   SUST // 21
  db SUST, REST, C5,   SUST, C5,   SUST, C5,   D5s,  SUST, D5s,  D5,   SUST, C5,   SUST, SUST, SUST // 22
  db SUST, REST, G4s,  SUST, G4s,  SUST, G4s,  SUST, G4s,  A4s,  SUST, A4s,  SUST, A4s,  SUST, A4s  // 23
  db A4s,  SUST, C5,   SUST, C5,   SUST, C5,   SUST, A4s,  C5,   SUST, C5,   SUST, SUST, SUST, REST // 24

PATTERN06: // Pattern 06: Kick Drum (Channel A Noise)
  db 15,   REST, REST, REST, REST, REST, REST, 15,   REST, 15,   15,   REST, REST, REST, REST, REST // 13
  db 15,   REST, REST, REST, 15,   REST, REST, REST, REST, 15,   15,   REST, REST, REST, REST, REST // 14
  db 15,   REST, REST, REST, 15,   REST, REST, 15,   REST, 15,   15,   REST, 15,   REST, 15,   REST // 15
  db 15,   REST, REST, REST, 15,   REST, REST, REST, REST, 15,   15,   REST, 15,   REST, 15,   REST // 16

PATTERN07: // Pattern 07: Snare (Channel B Noise)
  db REST, REST, REST, REST, 1,    REST, REST, REST, REST, REST, REST, REST, 1,    REST, REST, REST // 17
  db REST, REST, REST, REST, 1,    REST, REST, REST, REST, REST, REST, REST, 1,    REST, REST, REST // 18
  db REST, REST, REST, REST, 1,    REST, REST, REST, REST, REST, REST, REST, 1,    REST, REST, REST // 19
  db REST, REST, REST, REST, 1,    REST, REST, REST, REST, REST, REST, REST, 1,    REST, REST, REST // 20

PATTERN08: // Pattern 08: Clap (Channel C Noise)
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 9
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 10
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 11
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, 3,    3,    REST, 3,    REST, 3,    REST // 12
PATTERN09: // Pattern 09: Clap (Channel C Noise)
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 13
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, 3,    REST, 3,    REST, 3,    REST // 14
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 15
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, 3,    3,    REST, 3,    REST, 3,    REST // 16

PATTERNLIST:
  dw PATTERN01,PATTERN00,PATTERN00,PATTERN00,PATTERN00,PATTERN00 // Channel A..C Tone, Channel A..C Noise Pattern Address List
  dw PATTERN01,PATTERN00,PATTERN01,PATTERN00,PATTERN00,PATTERN00 // Channel A..C Tone, Channel A..C Noise Pattern Address List
  dw PATTERN00,PATTERN02,PATTERN00,PATTERN00,PATTERN00,PATTERN08 // Channel A..C Tone, Channel A..C Noise Pattern Address List
  dw PATTERN00,PATTERN02,PATTERN00,PATTERN06,PATTERN00,PATTERN09 // Channel A..C Tone, Channel A..C Noise Pattern Address List
PATTERNLISTLOOP:
  dw PATTERN01,PATTERN02,PATTERN01,PATTERN06,PATTERN07,PATTERN08 // Channel A..C Tone, Channel A..C Noise Pattern Address List
  dw PATTERN01,PATTERN02,PATTERN01,PATTERN06,PATTERN07,PATTERN08 // Channel A..C Tone, Channel A..C Noise Pattern Address List

  dw PATTERN04,PATTERN03,PATTERN05,PATTERN06,PATTERN07,PATTERN08 // Channel A..C Tone, Channel A..C Noise Pattern Address List
  dw PATTERN04,PATTERN03,PATTERN05,PATTERN06,PATTERN07,PATTERN08 // Channel A..C Tone, Channel A..C Noise Pattern Address List
PATTERNLISTEND: