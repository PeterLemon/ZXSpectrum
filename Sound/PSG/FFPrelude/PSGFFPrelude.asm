// ZX Spectrum 128K AY8912 PSG Final Fantasy Prelude Song Pattern demo by krom (Peter Lemon):
arch zxs.cpu
output "PSGFFPrelude.z80", create
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

// Constants
constant MaxQuant(180)    // Maximum Quantization ms
constant PatternSize(256) // Pattern Size (1..256)
constant ChannelCount(3)  // Channel Count

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
ld e,$10            // E = PSG Channel A Mode/Volume (Bit 4 Mode = 1, Bits 0..3 Volume = 0)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_MODE_VOL_B // D = PSG Channel B Mode/Volume Address ($09)
ld e,$0D            // E = PSG Channel B Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 13)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

ld d,PSG_MODE_VOL_C // D = PSG Channel C Mode/Volume Address ($0A)
ld e,$0D            // E = PSG Channel C Mode/Volume (Bit 4 Mode = 0, Bits 0..3 Volume = 13)
call PSGWrite       // PSG Write Data (D = PSG Address, E = PSG Data)

StartSong:
  ld ix,PATTERNLIST // IX = Pattern List Address
  ld de,$0000       // DE = 0 (Pattern Offset Index)

LoopSong:
  ld a,PSG_ENV_SHAPE   // A = PSG Channel Volume Envelope Shape Address ($0D)
  ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
  out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,$0B             // A = PSG Channel Volume Envelope Shape (Bits 0..3 Shape = 11)
  ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
  out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ld a,PSG_ENV_FINE_TUNE // A = PSG Channel Volume Envelope Period Fine Tune Address ($0B)
  ld b,AY8912_ADDR>>8    // BC = AY8912 Address Port ($FFFD)
  out (c),a              // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,$FF               // A = PSG Channel Volume Envelope Period Fine Tune (Bits 0..7 Fine Tune = 256)
  ld b,AY8912_WRITE>>8   // BC = AY8912 Write Data Port ($BFFD)
  out (c),a              // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ld a,PSG_ENV_COARSE_TUNE // A = PSG Channel Channel Volume Envelope Period Coarse Tune Address ($0C)
  ld b,AY8912_ADDR>>8      // BC = AY8912 Address Port ($FFFD)
  out (c),a                // Write PSG Address (A) To AY8912 Address Port (BC)
  ld a,$A0                 // A = Channel Channel Volume Envelope Period Coarse Tune (Bits 0..7 Coarse Tune = 256)
  ld b,AY8912_WRITE>>8     // BC = AY8912 Write Data Port ($BFFD)
  out (c),a                // Write PSG Data (A) To AY8912 Write Data Port (BC)

  ChannelPatternTone(A, 0, PeriodTable) // Channel A Tone Pattern Calculation: Channel, Key, Period Table
  ChannelPatternTone(B, 1, PeriodTable) // Channel B Tone Pattern Calculation: Channel, Key, Period Table
  ChannelPatternTone(C, 2, PeriodTable) // Channel C Tone Pattern Calculation: Channel, Key, Period Table

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
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 5
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 6
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 7
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 8
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 9
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 10
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 11
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 12
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 13
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 14
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 15
  db REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST, REST // 16

PATTERN01: // Pattern 01: Synth Harp (Channel A Tone)
  db  C2, D2,  E2, G2,  C3, D3,  E3, G3,  C4, D4,  E4, G4,  C5, D5,  E5, G5 // 1
  db  C6, G5,  E5, D5,  C5, G4,  E4, D4,  C4, G3,  E3, D3,  C3, G2,  E2, D2 // 2
  db  A1, B1,  C2, E2,  A2, B2,  C3, E3,  A3, B3,  C4, E4,  A4, B4,  C5, E5 // 3
  db  A5, E5,  C5, B4,  A4, E4,  C4, B3,  A3, E3,  C3, B2,  A2, E2,  C2, B1 // 4
  db  C2, D2,  E2, G2,  C3, D3,  E3, G3,  C4, D4,  E4, G4,  C5, D5,  E5, G5 // 5
  db  C6, G5,  E5, D5,  C5, G4,  E4, D4,  C4, G3,  E3, D3,  C3, G2,  E2, D2 // 6
  db  A1, B1,  C2, E2,  A2, B2,  C3, E3,  A3, B3,  C4, E4,  A4, B4,  C5, E5 // 7
  db  A5, E5,  C5, B4,  A4, E4,  C4, B3,  A3, E3,  C3, B2,  A2, E2,  C2, B1 // 8
  db  A1, C2,  F2, G2,  A2, C3,  F3, G3,  A3, C4,  F4, G4,  A4, C5,  F5, G5 // 9
  db  A5, G5,  F5, C5,  A4, G4,  F4, C4,  A3, G3,  F3, C3,  A2, G2,  F2, C2 // 10
  db  B1, D2,  G2, A2,  B2, D3,  G3, A3,  B3, D4,  G4, A4,  B4, D5,  G5, A5 // 11
  db  B5, A5,  G5, D5,  B4, A4,  G4, D4,  B3, A3,  G3, D3,  B2, A2,  G2, D2 // 12
  db G1s, C2, E2b, G2, G2s, C3, E3b, G3, G3s, C4, E4b, G4, G4s, C5, E5b, G5 // 13
  db G5s, G5, E5b, C5, G4s, G4, E4b, C4, G3s, G3, E3b, C3, G2s, G2, E2b, C2 // 14
  db B1b, D2,  F2, A2, B2b, D3,  F3, A3, B3b, D4,  F4, A4, B4b, D5,  F5, A5 // 15
  db B5b, A5,  F5, D5, B4b, A4,  F4, D4, B3b, A3,  F3, D3, B2b, A2,  F2, D2 // 16

PATTERN02: // Pattern 02: Flute (Channel B Tone)
  db   E4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 17
  db   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   F4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 18
  db   E4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 19
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 20
  db   E4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 21
  db   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   F4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 22
  db   F4, SUST,   G4, SUST,   E4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 23
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 24
  db   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 25
  db   B3, SUST, SUST, SUST, SUST, SUST, SUST, REST,   C4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 26
  db   D4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST,   E4, SUST, SUST, REST // 27
  db   F4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 28
  db   D4, SUST, SUST, SUST,   C4, SUST, B3b, SUST,   G3s, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 29
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 30
  db  E4b, SUST, SUST, SUST,   D4, SUST,   C4, SUST,  B3b, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 31
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 32
PATTERN03: // Pattern 03: Strings (Channel B Tone)
  db   E5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 33
  db   D5, SUST, SUST, SUST, SUST, SUST, SUST, REST,   F5, SUST, SUST, SUST, SUST, SUST, SUST, REST // 34
  db   E5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 35
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 36
  db   E5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 37
  db   D5, SUST, SUST, SUST, SUST, SUST, SUST, REST,   F5, SUST, SUST, SUST, SUST, SUST, SUST, REST // 38
  db   F5, SUST,   G5, SUST,   E5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 39
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 40
  db   F5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 41
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 42
  db   G5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 43
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 44
  db   F5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 45
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 46
  db   G5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 47
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 48

PATTERN04: // Pattern 04: Oboe (Channel C Tone)
  db   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 17
  db   B3, SUST, SUST, SUST, SUST, SUST, SUST, REST,   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 18
  db   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 19
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 20
  db   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 21
  db   B3, SUST, SUST, SUST, SUST, SUST, SUST, REST,   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 22
  db   D4, SUST,   E4, SUST,   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 23
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 24
  db   A3, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 25
  db   G3, SUST, SUST, SUST, SUST, SUST, SUST, REST,   A3, SUST, SUST, SUST, SUST, SUST, SUST, REST // 26
  db   B3, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST,   C4, SUST, SUST, REST // 27
  db   D4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   G4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 28
  db   F4, SUST, SUST, SUST,  E4b, SUST,   D4, SUST,   C4, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 29
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 30
  db   G4, SUST, SUST, SUST,   F4, SUST,  E4b, SUST,   D4, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 31
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 32
PATTERN05: // Pattern 05: FrenchHorn (Channel C Tone)
  db   C5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 33
  db   B4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   D5, SUST, SUST, SUST, SUST, SUST, SUST, REST // 34
  db   C5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 35
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 36
  db   C5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 37
  db   B4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   D5, SUST, SUST, SUST, SUST, SUST, SUST, REST // 38
  db   D5, SUST,   E5, SUST,   C5, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 39
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 40
  db   A4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 41
  db   G4, SUST, SUST, SUST, SUST, SUST, SUST, REST,   A4, SUST, SUST, SUST, SUST, SUST, SUST, REST // 42
  db   B4, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST,   C5, SUST, SUST, REST // 43
  db   D5, SUST, SUST, SUST, SUST, SUST, SUST, REST,   G5, SUST, SUST, SUST, SUST, SUST, SUST, REST // 44
  db   F5, SUST, SUST, REST,  E5b, SUST,   D5, SUST,   C5, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 45
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST // 46
  db   G5, SUST, SUST, REST,   F5, SUST,  E5b, SUST,   D5, SUST, SUST, SUST, SUST, SUST, SUST, SUST // 47
  db SUST, SUST, SUST, SUST, SUST, SUST, SUST, REST,  B4b, SUST, SUST, SUST, SUST, SUST, SUST, REST // 48

PATTERNLIST:
  dw PATTERN01,PATTERN00,PATTERN00 // Channel A..C Pattern Address List
PATTERNLISTLOOP:
  dw PATTERN01,PATTERN02,PATTERN04 // Channel A..C Pattern Address List
  dw PATTERN01,PATTERN03,PATTERN05 // Channel A..C Pattern Address List
PATTERNLISTEND: