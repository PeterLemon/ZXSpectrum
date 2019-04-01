//===================================== (Key: RW = Read/Write)
// ZX Spectrum 128K AY8912 PSG Include
//=====================================
//---------------------
// I/O Map (Z80 Ports)
//---------------------
//--------
// AY8912
//--------
constant AY8912_ADDR($FFFD)  // $FFFD: AY8912 - Address                                                                               W

// AY8912 - Read (Write Address Port $FFFD, Read Data Port $FFFD)
constant AY8912_READ($FFFD)  // $FFFD: AY8912 - Read Data                                                                            R

// AY8912 - Write (Write Address Port $FFFD, Write Data Port $BFFD)
constant AY8912_WRITE($BFFD) // $BFFD: AY8912 - Write Data                                                                            W

//------------
// AY8912 PSG
//------------
constant PSG_FINE_TUNE_A($00)     // $00: AY8912 PSG - Channel A Fine   Tune (Bits 0..7)                                             RW
constant PSG_COARSE_TUNE_A($01)   // $01: AY8912 PSG - Channel A Coarse Tune (Bits 0..3)                                             RW
constant PSG_FINE_TUNE_B($02)     // $02: AY8912 PSG - Channel B Fine   Tune (Bits 0..7)                                             RW
constant PSG_COARSE_TUNE_B($03)   // $03: AY8912 PSG - Channel B Coarse Tune (Bits 0..3)                                             RW
constant PSG_FINE_TUNE_C($04)     // $04: AY8912 PSG - Channel C Fine   Tune (Bits 0..7)                                             RW
constant PSG_COARSE_TUNE_C($05)   // $05: AY8912 PSG - Channel C Coarse Tune (Bits 0..3)                                             RW
constant PSG_NOISE_TUNE($06)      // $06: AY8912 PSG - Channel Noise    Tune (Bits 0..4)                                             RW

constant PSG_KEY($07)             // $07: AY8912 PSG - Port A/B Mode (Bits 6..7), Channel Enable Noise (Bits 3..5), Tone (Bits 0..2) RW

constant PSG_MODE_VOL_A($08)      // $08: AY8912 PSG - Channel A Mode (Bit 4), Volume (Bits 0..3)                                    RW
constant PSG_MODE_VOL_B($09)      // $09: AY8912 PSG - Channel B Mode (Bit 4), Volume (Bits 0..3)                                    RW
constant PSG_MODE_VOL_C($0A)      // $0A: AY8912 PSG - Channel C Mode (Bit 4), Volume (Bits 0..3)                                    RW

constant PSG_ENV_FINE_TUNE($0B)   // $0B: AY8912 PSG - Volume Envelope Period Fine   Tune (Bits 0..7)                                RW
constant PSG_ENV_COARSE_TUNE($0C) // $0C: AY8912 PSG - Volume Envelope Period Coarse Tune (Bits 0..7)                                RW

// AY8912 PSG - Volume Envelope Shape (8 = |\|\|\|\, 9 = |\____, 10 = |\/\/, 11 = |\/''', 12= /|/|/|/|, 13 = /''', 14 = /\/\, 15 = /|___)
constant PSG_ENV_SHAPE($0D)       // $0D: AY8912 PSG - Volume Envelope Shape (Bits 0..3)                                             RW

constant PSG_PORT_A($0E)          // $0E: AY8912 PSG - Port A (With External Pinouts On AY8910 & AY8912)                             RW
constant PSG_PORT_B($0F)          // $0F: AY8910 PSG - Port B (With External Pinouts On AY8910 Only)                                 RW

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

macro PeriodTable() { // Timing, 9 Octaves: A0..G9# (108 Words)
  dw $FE4,$F00,$E28,$D5D,$C9D,$BE7,$B3D,$A9B,$A03,$973,$8EB,$86B // A0..G1#
  dw $7F2,$780,$714,$6AE,$64E,$5F3,$59E,$54D,$501,$4B9,$475,$435 // A1..G2#
  dw $3F9,$3C0,$38A,$357,$327,$2F9,$2CF,$2A6,$280,$25C,$23A,$21A // A2..G3#
  dw $1FC,$1E0,$1C5,$1AB,$193,$17C,$167,$153,$140,$12E,$11D,$10D // A3..G4#
  dw $0FE,$0F0,$0E2,$0D5,$0C9,$0BE,$0B3,$0A9,$0A0,$097,$08E,$086 // A4..G5#
  dw $07F,$078,$071,$06A,$064,$05F,$059,$054,$050,$04B,$047,$043 // A5..G6#
  dw $03F,$03C,$038,$035,$032,$02F,$02C,$02A,$028,$025,$023,$021 // A6..G7#
  dw $01F,$01E,$01C,$01A,$019,$017,$016,$015,$014,$012,$011,$010 // A7..G8#
  dw $00F,$00F,$00E,$00D,$00C,$00B,$00B,$00A,$00A,$009,$008,$008 // A8..G9#
}