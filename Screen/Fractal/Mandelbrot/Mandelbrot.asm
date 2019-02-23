// ZX Spectrum Mandelbrot Fractal demo by krom (Peter Lemon):
// Original Code by John Metcalf
arch zxs.cpu
output "Mandelbrot.z80", create
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

// Plot Mandelbrot Fractal
ld de,255*256+191
XLOOP:
  push de
  ld hl,-180 // X Coordinate
  ld e,d
  call SCALE
  ld (XPOS),bc
  pop de
YLOOP:
  push de
  ld hl,-96  // Y Coordinate
  call SCALE
  ld (YPOS),bc
  ld hl,0
  ld (IMAG),hl
  ld (REAL),hl
  ld b,15 // Iterations
ITER:
  push bc
  ld bc,(IMAG)
  ld hl,(REAL)
  or a
  sbc hl,bc
  ld d,h
  ld e,l
  add hl,bc
  add hl,bc
  call FIXMUL
  ld de,(XPOS)
  add hl,de
  ld de,(REAL)
  ld (REAL),hl
  ld hl,(IMAG)
  call FIXMUL
  rla
  adc hl,hl
  ld de,(YPOS)
  add hl,de
  ld (IMAG),hl
  call ABSVAL
  ex de,hl
  ld hl,(REAL)
  call ABSVAL
  add hl,de
  ld a,h
  cp 46 // 46 ~= 2 * V 2 << 4
  pop bc
  jr nc,ESCAPE
  djnz ITER
  pop de
  call PLOT
  db 254 // Trick To Skip Next Instruction ("cp $D1" Instruction On Return From CALL)
ESCAPE:
  pop de
  dec e
  jr nz,YLOOP
  dec d
  jr nz,XLOOP
  ret

FIXMUL: // HL = HL * DE >> 24
  call MULT16BY16
  ld a,b
  ld b,4
FMSHIFT:
  rla
  adc hl,hl
  djnz FMSHIFT 
  ret

SCALE: // BC = (HL + E) * Zoom
  ld d,0
  add hl,de
  ld de,48 // Zoom

MULT16BY16: // HL:BC (Signed 32-Bit) = HL * DE
  xor a
  call ABSVAL
  ex de,hl
  call ABSVAL
  push af
  ld c,h
  ld a,l
  call MULT8BY16
  ld b,a
  ld a,c
  ld c,h
  push bc
  ld c,l
  call MULT8BY16
  pop de
  add hl,de
  adc a,b
  ld b,l
  ld l,h
  ld h,a
  pop af
  rra
  ret nc
  ex de,hl
  xor a
  ld h,a
  ld l,a
  sbc hl,bc
  ld b,h
  ld c,l
  ld h,a
  ld l,a
  sbc hl,de
  ret

MULT8BY16: // Return A:HL (24-Bit) = A * DE
  ld hl,0
  ld b,8
M816LOOP:
  add hl,hl
  rla
  jr nc,M816SKIP
  add hl,de
  adc a,0
M816SKIP:
  djnz M816LOOP
  ret

PLOT: // Plot Pixel (D = X Position, E = Y Position)
  ld a,7
  and d
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
  ld a,d
  xor l
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
  ret

ABSVAL: // Returns HL = |HL|, Increments A IF Sign Bit Has Changed
  bit 7,h
  ret z
  ld b,h
  ld c,l
  ld hl,0
  or a
  sbc hl,bc
  inc a
  ret

XPOS:
  dw 0
YPOS:
  dw 0
REAL:
  dw 0
IMAG:
  dw 0