// ZX Spectrum Mouse Kempston Input demo by krom (Peter Lemon):
arch zxs.cpu
output "MouseKempston.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5CCB) ; Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

// Fill Screen Color Area With Full Brightness, White Paper Color, Black Ink Color
ld hl,SCR_COL+767 // HL = Screen Color Area End Address ($5800+767)
ld a,BRIGHT+P_WHITE+I_BLACK // A = Color Attributes (%FBPPPIII: F = FLASH Mode, B = BRIGHTNESS Mode, P = PAPER Color, I = INK Color)
FillCOL:
  ld (hl),a     // Store Color Attributes (A) To Screen Color Area Address (HL)
  dec hl        // Decrement Screen Color Address (HL--)
  bit 3,h       // Test Bit 3 Of Screen Color Address MSB (H)
  jr nz,FillCOL // IF (Bit 3 Of Screen Color Address MSB != 0) Fill Color

Loop:
  // Plot Mouse Kempston Sprite To Screen Bitmap Area
  call ReadMouseKempston // Read Mouse Kempston Buttons & X/Y Position (A = Buttons, D = X Position, E = Y Position)
  push de // Push DE To Stack (Mouse X/Y Position)

  // Plot Sprite Over Screen Bitmap Buffer Area
  cp 3 // Compare A To 3
  jr nz,MouseButton1 // IF (A = 3) No Buttons Pressed
  ld hl,Sprite0 // HL = Sprite Address
  jr PlotSprite // Plot Sprite
  MouseButton1:
    bit 0,a // Test A Bit 0 (Mouse Button 1)
    jr nz,MouseButton2
    ld hl,Sprite1 // HL = Sprite Address
    jr PlotSprite // Plot Sprite
  MouseButton2:
    ld hl,Sprite2 // HL = Sprite Address

  PlotSprite:
    call PutSprite // Plot Sprite (HL = Sprite Adress, D = X Position, E = Y Position)

  // Fill Screen Bitmap Area With Screen Bitmap Buffer Data
  ld bc,6144    // BC = Screen Data Size Count (6144 Bytes)
  ld de,SCR_BMP // DE = Screen Bitmap Area Start Address ($4000)
  ld hl,$C000   // HL = Screen Data Start Address
  ldir // Copy Screen Data To Screen Bitmap/Color Area (WHILE BC > 0 (LD (DE),(HL), DE++, HL++, BC--))

  // Clear Sprite Over Screen Bitmap Buffer Area
  pop de // Pop DE Off The Stack (Mouse X/Y Position)
  ld hl,SpriteClear // HL = Sprite Address
  call PutSprite // Plot Sprite (HL = Sprite Adress, D = X Position, E = Y Position)

  jr Loop

ReadMouseKempston: // Read Mouse Kempston Buttons & X/Y Position (A = Buttons, D = X Position, E = Y Position)
  ld bc,$FBDF // BC = Kempston Mouse X Postion Port ($FBDF)
  in a,(c)    // A = X Position From Kempston Mouse Port ($FBDF)
  ld d,a      // D = X Position (A)
  ld b,$FF    // BC = Kempston Mouse Y Postion Port ($FFDF)
  in a,(c)    // A = Y Position From Kempston Mouse Port ($FFDF)
  ld e,a      // Negate Y Position
  ld a,191    // A = 191
  sub e       // A -= Y Position
  ld e,a      // E = Y Position (A)
  ld b,$FA    // BC = Kempston Mouse Buttons Port ($FADF)
  in a,(c)    // A = Button Flags From Kempston Mouse Buttons Port ($FADF)
  and 3       // Mask Mouse Buttons (Bits 0..1)
  ret

PutSprite: // Plot Sprite To Screen (HL = Sprite Adress, D = X Position, E = Y Position)
  ld a,e            // A = Sprite Y Position (E)
  and $C0           // A &= $C0 (Bits 6 & 7)
  cp $C0            // Compare A To $C0
  jp z,PutSpriteEnd // IF (Sprite Y Position >= 192) Put Sprite End (Sprite Fully Off Screen)
  ld c,16           // C = Sprite Scanlines To Draw
  ld a,e            // A = Sprite Y Position (E)
  and $B0           // A &= $B0 (Bits 4,5 & 7)
  cp $B0            // Compare A To $B0
  jp nz,NextLine    // IF (Sprite Y Position < 176) Next Line
  ld c,e            // C = Sprite Y Position (E)
  ld a,192          // A = 192
  sub c             // A -= C
  ld c,a            // C = Sprite Scanlines To Draw (Y Clip)
  NextLine:
    ld a,d
    and 7
    inc a
    ld b,a
    ld a,e
    rra
    cp 96
    ret nc
    rra
    or a
    rra
    push de
    push hl
    ld l,a
    xor e
    and 248
    xor e
    ld h,a
    ld a,l
    xor d
    and 7
    xor d
    rrca
    rrca
    rrca
    ld l,a

    set 7,h // Output To $C000 Instead Of $4000

    ld e,255
  SPD:
    ex (sp),hl
    ld a,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ex (sp),hl
    push bc
    rrc e
    jr NoShift
  ShiftSPR:
    rra
    rr d
    rr e
  NoShift:
    djnz ShiftSPR

  push hl
  ld b,3
  Mask:
    bit 0,e
    jr z,BM1
    and (hl)
  db 254 // jr BM2
  BM1:
    xor (hl)
  BM2:
    ld (hl),a
    inc l
    ld a,l
    and 31
    ld a,d
    ld d,e
    jr z,Clip
    djnz Mask
  Clip:
    bit 0,e
    ld e,0
    pop hl
    pop bc
    jr nz,SPD
    pop hl
    pop de
    inc e
    dec c
    jr nz,NextLine
  PutSpriteEnd:
  ret

SpriteClear: // Sprite Mask & Bitmap
  db %00000000,%00001111, %00000000,%00000000
  db %00000000,%00011111, %00000000,%00000000
  db %00000000,%00111111, %00000000,%00000000
  db %00000000,%01111111, %00000000,%00000000
  db %00000000,%11111111, %00000000,%00000000
  db %00000000,%01111111, %00000000,%00000000
  db %00000000,%00111111, %00000000,%00000000
  db %00000000,%00011111, %00000000,%00000000
  db %00000000,%00001111, %00000000,%00000000
  db %00010000,%00000111, %00000000,%00000000
  db %00111000,%00000011, %00000000,%00000000
  db %01111100,%00000001, %00000000,%00000000
  db %11111110,%00000011, %00000000,%00000000
  db %11111111,%00000111, %00000000,%00000000
  db %11111111,%10001111, %00000000,%00000000
  db %11111111,%11011111, %00000000,%00000000

Sprite0: // Sprite Mask & Bitmap
  db %00000000,%00001111, %11111111,%11110000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00111111, %10000000,%01000000
  db %00000000,%01111111, %10000000,%10000000
  db %00000000,%11111111, %10000001,%00000000
  db %00000000,%01111111, %10000000,%10000000
  db %00000000,%00111111, %10000000,%01000000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00001111, %10010000,%00010000
  db %00010000,%00000111, %10101000,%00001000
  db %00111000,%00000011, %11000100,%00000100
  db %01111100,%00000001, %10000010,%00000010
  db %11111110,%00000011, %00000001,%00000100
  db %11111111,%00000111, %00000000,%10001000
  db %11111111,%10001111, %00000000,%01010000
  db %11111111,%11011111, %00000000,%00100000

Sprite1: // Sprite Mask & Bitmap
  db %00000000,%00001111, %11111111,%11110000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00111111, %10001000,%01000000
  db %00000000,%01111111, %10011000,%10000000
  db %00000000,%11111111, %10001001,%00000000
  db %00000000,%01111111, %10001000,%10000000
  db %00000000,%00111111, %10011100,%01000000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00001111, %10010000,%00010000
  db %00010000,%00000111, %10101000,%00001000
  db %00111000,%00000011, %11000100,%00000100
  db %01111100,%00000001, %10000010,%00000010
  db %11111110,%00000011, %00000001,%00000100
  db %11111111,%00000111, %00000000,%10001000
  db %11111111,%10001111, %00000000,%01010000
  db %11111111,%11011111, %00000000,%00100000

Sprite2: // Sprite Mask & Bitmap
  db %00000000,%00001111, %11111111,%11110000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00111111, %10011000,%01000000
  db %00000000,%01111111, %10100100,%10000000
  db %00000000,%11111111, %10001001,%00000000
  db %00000000,%01111111, %10010000,%10000000
  db %00000000,%00111111, %10111100,%01000000
  db %00000000,%00011111, %10000000,%00100000
  db %00000000,%00001111, %10010000,%00010000
  db %00010000,%00000111, %10101000,%00001000
  db %00111000,%00000011, %11000100,%00000100
  db %01111100,%00000001, %10000010,%00000010
  db %11111110,%00000011, %00000001,%00000100
  db %11111111,%00000111, %00000000,%10001000
  db %11111111,%10001111, %00000000,%01010000
  db %11111111,%11011111, %00000000,%00100000