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
  jr z,{#}KEYEND // IF (A == REST) Key End

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
  jr z,{#}KEYEND // IF (A == REST) Key End

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
    ld b,ChannelCount*2   // B = Count
    PatternIncLoop:
      inc ix              // IX++ (Pattern List Offset++)
      djnz PatternIncLoop // Decrement Count (B--), IF (Count != 0) Pattern Increment

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

// Frequency WORD Offsets For Period Table
constant A0($00)
constant A0s($02)
constant B0b($02)
constant B0($04)
constant C1($06)
constant C1s($08)
constant D1b($08)
constant D1($0A)
constant D1s($0C)
constant E1b($0C)
constant E1($0E)
constant F1($10)
constant F1s($12)
constant G1b($12)
constant G1($14)
constant G1s($16)
constant A1b($16)

constant A1($18)
constant A1s($1A)
constant B1b($1A)
constant B1($1C)
constant C2($1E)
constant C2s($20)
constant D2b($20)
constant D2($22)
constant D2s($24)
constant E2b($24)
constant E2($26)
constant F2($28)
constant F2s($2A)
constant G2b($2A)
constant G2($2C)
constant G2s($2E)
constant A2b($2E)

constant A2($30)
constant A2s($32)
constant B2b($32)
constant B2($34)
constant C3($36)
constant C3s($38)
constant D3b($38)
constant D3($3A)
constant D3s($3C)
constant E3b($3C)
constant E3($3E)
constant F3($40)
constant F3s($42)
constant G3b($42)
constant G3($44)
constant G3s($46)
constant A3b($46)

constant A3($48)
constant A3s($4A)
constant B3b($4A)
constant B3($4C)
constant C4($4E)
constant C4s($50)
constant D4b($50)
constant D4($52)
constant D4s($54)
constant E4b($54)
constant E4($56)
constant F4($58)
constant F4s($5A)
constant G4b($5A)
constant G4($5C)
constant G4s($5E)
constant A4b($5E)

constant A4($60)
constant A4s($62)
constant B4b($62)
constant B4($64)
constant C5($66)
constant C5s($68)
constant D5b($68)
constant D5($6A)
constant D5s($6C)
constant E5b($6C)
constant E5($6E)
constant F5($70)
constant F5s($72)
constant G5b($72)
constant G5($74)
constant G5s($76)
constant A5b($76)

constant A5($78)
constant A5s($7A)
constant B5b($7A)
constant B5($7C)
constant C6($7E)
constant C6s($80)
constant D6b($80)
constant D6($82)
constant D6s($84)
constant E6b($84)
constant E6($86)
constant F6($88)
constant F6s($8A)
constant G6b($8A)
constant G6($8C)
constant G6s($8E)
constant A6b($8E)

constant A6($90)
constant A6s($92)
constant B6b($92)
constant B6($94)
constant C7($96)
constant C7s($98)
constant D7b($98)
constant D7($9A)
constant D7s($9C)
constant E7b($9C)
constant E7($9E)
constant F7($A0)
constant F7s($A2)
constant G7b($A2)
constant G7($A4)
constant G7s($A6)
constant A7b($A6)

constant A7($A8)
constant A7s($AA)
constant B7b($AA)
constant B7($AC)
constant C8($AE)
constant C8s($B0)
constant D8b($B0)
constant D8($B2)
constant D8s($B4)
constant E8b($B4)
constant E8($B6)
constant F8($B8)
constant F8s($BA)
constant G8b($BA)
constant G8($BC)
constant G8s($BE)
constant A8b($BE)

constant A8($B0)
constant A8s($B2)
constant B8b($B2)
constant B8($B4)
constant C9($B6)
constant C9s($B8)
constant D9b($B8)
constant D9($BA)
constant D9s($BC)
constant E9b($BC)
constant E9($BE)
constant F9($C0)
constant F9s($C2)
constant G9b($C2)
constant G9($C4)
constant G9s($C6)
constant A9b($C6)

constant SUST($FE)
constant REST($FF)

PeriodTable: // Period Table Used For PSG Tone Freqencies
dw $FE4,$F00,$E28,$D5D,$C9D,$BE7,$B3D,$A9B,$A03,$973,$8EB,$86B // A0..G1#
dw $7F2,$780,$714,$6AE,$64E,$5F3,$59E,$54D,$501,$4B9,$475,$435 // A1..G2#
dw $3F9,$3C0,$38A,$357,$327,$2F9,$2CF,$2A6,$280,$25C,$23A,$21A // A2..G3#
dw $1FC,$1E0,$1C5,$1AB,$193,$17C,$167,$153,$140,$12E,$11D,$10D // A3..G4#
dw $0FE,$0F0,$0E2,$0D5,$0C9,$0BE,$0B3,$0A9,$0A0,$097,$08E,$086 // A4..G5#
dw $07F,$078,$071,$06A,$064,$05F,$059,$054,$050,$04B,$047,$043 // A5..G6#
dw $03F,$03C,$038,$035,$032,$02F,$02C,$02A,$028,$025,$023,$021 // A6..G7#
dw $01F,$01E,$01C,$01A,$019,$017,$016,$015,$014,$012,$011,$010 // A7..G8#
dw $00F,$00F,$00E,$00D,$00C,$00B,$00B,$00A,$00A,$009,$008,$008 // A8..G9#

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