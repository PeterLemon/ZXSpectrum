// ZX Spectrum 128K AY8912 PSG Twinkle 3 Channel Song demo by krom (Peter Lemon):
arch zxs.cpu
output "PSGTwinkle3Channel.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

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

LoopSong:
  ld de,SONGCHANA // DE = SONGCHANA 16-Bit Address

  PSGCHANA: // PSG Channel A
    ld a,(de)         // A = Channel A: Period Table Offset
    cp SUST           // Compare A To SUST Character ($FE)
    jr z,PSGCHANAEnd  // IF (A == SUST) Channel A: PSGCHANA End

    // Key OFF
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    set 0,a              // A = PSG Channel A Tone Disable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,(de)        // A = Channel A: Period Table Offset
    cp REST          // Compare A To REST Character ($FF)
    jr z,PSGCHANAEnd // IF (A == REST) Channel A: PSGCHANA End

    // ELSE Channel A: Key ON
    ld b,$00          // B = $00
    ld c,a            // C = Period Table Offset (A)
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,bc         // HL += BC

    ld a,PSG_FINE_TUNE_A // A = PSG Channel A Fine Tune Address ($00)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)            // A = PSG Channel A Fine Tune
    inc hl               // Increment Period Table Offset (HL++)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,PSG_COARSE_TUNE_A // A = PSG Channel A Course Tune Address ($01)
    ld b,AY8912_ADDR>>8    // BC = AY8912 Address Port ($FFFD)
    out (c),a              // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)              // A = Channel A Course Tune
    ld b,AY8912_WRITE>>8   // BC = AY8912 Write Data Port ($BFFD)
    out (c),a              // Write PSG Data (A) To AY8912 Write Data Port (BC)

    // Key ON
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld b,AY8912_ADDR>>8  // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    res 0,a              // A = PSG Channel A Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)
  PSGCHANAEnd:

  ld hl,SongEnd-SongStart
  add hl,de
  ex de,hl // Exchange DE/HL

  PSGCHANB: // PSG Channel B
    ld a,(de)         // A = Channel B: Period Table Offset
    cp SUST           // Compare A To SUST Character ($FE)
    jr z,PSGCHANBEnd  // IF (A == SUST) Channel B: PSGCHANB End

    // Key OFF
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    set 1,a              // A = PSG Channel B Tone Disable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,(de)        // A = Channel B: Period Table Offset
    cp REST          // Compare A To REST Character ($FF)
    jr z,PSGCHANBEnd // IF (A == REST) Channel B: PSGCHANB End

    // ELSE Channel B: Key ON
    ld b,$00          // B = $00
    ld c,a            // C = Period Table Offset (A)
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,bc         // HL += BC

    ld a,PSG_FINE_TUNE_B // A = PSG Channel B Fine Tune Address ($02)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)            // A = PSG Channel B Fine Tune
    inc hl               // Increment Period Table Offset (HL++)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,PSG_COARSE_TUNE_B // A = PSG Channel B Course Tune Address ($03)
    ld b,AY8912_ADDR>>8    // BC = AY8912 Address Port ($FFFD)
    out (c),a              // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)              // A = Channel B Course Tune
    ld b,AY8912_WRITE>>8   // BC = AY8912 Write Data Port ($BFFD)
    out (c),a              // Write PSG Data (A) To AY8912 Write Data Port (BC)

    // Key ON
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld b,AY8912_ADDR>>8  // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    res 1,a              // A = PSG Channel B Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)
  PSGCHANBEnd:

  ld hl,SongEnd-SongStart
  add hl,de
  ex de,hl // Exchange DE/HL

  PSGCHANC: // PSG Channel C
    ld a,(de)         // A = Channel C: Period Table Offset
    cp SUST           // Compare A To SUST Character ($FE)
    jr z,PSGCHANCEnd  // IF (A == SUST) Channel C: PSGCHANC End

    // Key OFF
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    set 2,a              // A = PSG Channel C Tone Disable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,(de)        // A = Channel C: Period Table Offset
    cp REST          // Compare A To REST Character ($FF)
    jr z,PSGCHANCEnd // IF (A == REST) Channel C: PSGCHANC End

    // ELSE Channel C: Key ON
    ld b,$00          // B = $00
    ld c,a            // C = Period Table Offset (A)
    ld hl,PeriodTable // HL = PeriodTable 16-Bit Address
    add hl,bc         // HL += BC

    ld a,PSG_FINE_TUNE_C // A = PSG Channel C Fine Tune Address ($04)
    ld bc,AY8912_ADDR    // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)            // A = PSG Channel C Fine Tune
    inc hl               // Increment Period Table Offset (HL++)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)

    ld a,PSG_COARSE_TUNE_C // A = PSG Channel C Course Tune Address ($05)
    ld b,AY8912_ADDR>>8    // BC = AY8912 Address Port ($FFFD)
    out (c),a              // Write PSG Address (A) To AY8912 Address Port (BC)
    ld a,(hl)              // A = Channel C Course Tune
    ld b,AY8912_WRITE>>8   // BC = AY8912 Write Data Port ($BFFD)
    out (c),a              // Write PSG Data (A) To AY8912 Write Data Port (BC)

    // Key ON
    ld a,PSG_KEY         // A = PSG Channel Enable Address ($07)
    ld b,AY8912_ADDR>>8  // BC = AY8912 Address Port ($FFFD)
    out (c),a            // Write PSG Address (A) To AY8912 Address Port (BC)
    in a,(c)             // A = PSG Channel Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    res 2,a              // A = PSG Channel C Tone Enable (Bits 6..7 Port A/B Mode, Bits 3..5 Channel A..C Enable Noise, Bits 0..2 Channel A..C Enable Tone)
    ld b,AY8912_WRITE>>8 // BC = AY8912 Write Data Port ($BFFD)
    out (c),a            // Write PSG Data (A) To AY8912 Write Data Port (BC)
  PSGCHANCEnd:

  ld hl,-((SongEnd-SongStart) * 2)
  add hl,de
  ex de,hl // Exchange DE/HL

  // 250 MS Delay (15 VSYNCS)
  ld b,15 // B = Count
  Wait:
    halt // Power Down CPU Until An Interrupt Occurs
    djnz Wait // Decrement Count (B--), IF (Count != 0) Wait
    
  inc de // DE++ (Increment Song Offset)

  ld a,SongEnd>>8 // IF (Song Offset != Song End) PSG Channel A
  cp d
  jp nz,PSGCHANA
  ld a,SongEnd
  cp e
  jp nz,PSGCHANA

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

SongStart:
  SONGCHANA: // PSG Channel A Tone Song Data At 250ms (15 VSYNCS)
    db C5, REST, C5, REST, G5, REST, G5, REST, A5, REST, A5, REST, G5, SUST, SUST, REST // 1. Twinkle Twinkle Little Star...
    db F5, REST, F5, REST, E5, REST, E5, REST, D5, REST, D5, REST, C5, SUST, SUST, REST // 2.   How I Wonder What You Are...
    db G5, REST, G5, REST, F5, REST, F5, REST, E5, REST, E5, REST, D5, SUST, SUST, REST // 3.  Up Above The World So High...
    db G5, REST, G5, REST, F5, REST, F5, REST, E5, REST, E5, REST, D5, SUST, SUST, REST // 4.   Like A Diamond In The Sky...
    db C5, REST, C5, REST, G5, REST, G5, REST, A5, REST, A5, REST, G5, SUST, SUST, REST // 5. Twinkle Twinkle Little Star...
    db F5, REST, F5, REST, E5, REST, E5, REST, D5, REST, D5, REST, C5, SUST, SUST, REST // 6.   How I Wonder What You Are...
SongEnd:

  SONGCHANB: // PSG Channel B Tone Song Data At 250ms (15 VSYNCS)
    db C3, REST, C3, REST, G3, REST, G3, REST, A3, REST, A3, REST, G3, SUST, SUST, REST // 1.
    db F3, REST, F3, REST, E3, REST, E3, REST, D3, REST, D3, REST, C3, SUST, SUST, REST // 2.
    db G3, REST, G3, REST, F3, REST, F3, REST, E3, REST, E3, REST, D3, SUST, SUST, REST // 3.
    db G3, REST, G3, REST, F3, REST, F3, REST, E3, REST, E3, REST, D3, SUST, SUST, REST // 4.
    db C3, REST, C3, REST, G3, REST, G3, REST, A3, REST, A3, REST, G3, SUST, SUST, REST // 5.
    db F3, REST, F3, REST, E3, REST, E3, REST, D3, REST, D3, REST, C3, SUST, SUST, REST // 6.

  SONGCHANC: // APU Channel C Tone Song Data At 250ms (15 VSYNCS)
    db C7, REST, C7, REST, G7, REST, G7, REST, A7, REST, A7, REST, G7, SUST, SUST, REST // 1.
    db F7, REST, F7, REST, E7, REST, E7, REST, D7, REST, D7, REST, C7, SUST, SUST, REST // 2.
    db G7, REST, G7, REST, F7, REST, F7, REST, E7, REST, E7, REST, D7, SUST, SUST, REST // 3.
    db G7, REST, G7, REST, F7, REST, F7, REST, E7, REST, E7, REST, D7, SUST, SUST, REST // 4.
    db C7, REST, C7, REST, G7, REST, G7, REST, A7, REST, A7, REST, G7, SUST, SUST, REST // 5.
    db F7, REST, F7, REST, E7, REST, E7, REST, D7, REST, D7, REST, C7, SUST, SUST, REST // 6.