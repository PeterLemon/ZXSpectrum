// ZX Spectrum Plot Line demo by krom (Peter Lemon):
// Original Code by John Metcalf
arch zxs.cpu
output "PlotLine.z80", create
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

// Plot Line Using Recursive Divide & Conquer Over Screen Bitmap Area
ld de,$0000 // DE = Line End1 (D = X Position, E = Y Position)
ld hl,$FFBF // HL = Line End2 (H = X Position, L = Y Position)
call DRAWLINE

Loop:
  jr Loop

DRAWLINE:
  call PLOT
  push hl

  // Calculate Centre Pixel (HL)
  ld a,l
  add a,e
  rra
  ld l,a
  ld a,h
  add a,d
  rra
  ld h,a

  or a
  sbc hl,de
  jr z,EXIT // IF (DE (End1) = HL (Centre)) Exit
  add hl,de

  ex de,hl
  call DRAWLINE // DE = Centre, HL = End1
  ex (sp),hl
  ex de,hl
  call DRAWLINE // DE = End2, HL = Centre

  ex de,hl
  pop de
  ret

EXIT:
  pop hl
  ret

PLOT: // Plot Pixel (D = X Position, E = Y Position)
  push hl
  ld a,d
  and 7
  ld b,a
  inc b
  ld a,e
  rra
  scf
  rra
  or a
  rra
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
  ld a,1
PLOTBIT:
  rrca
  djnz PLOTBIT
  or (hl)
  ld (hl),a
  pop hl
  ret