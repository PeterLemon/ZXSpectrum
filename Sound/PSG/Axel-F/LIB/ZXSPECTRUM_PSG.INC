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