// ZX Spectrum LZ77 Decode demo by krom (Peter Lemon):
arch zxs.cpu
output "LZ77Decode.z80", create
include "LIB/Z80_HEADER.ASM" // Include .Z80 Header (30 Bytes)
fill $C000 // Fill 48KB Program Code With Zero Bytes

macro seek(variable offset) {
  origin (offset-$4000)+30
  base offset
}

seek($5CCB) ; Start: // Entry Point Of Code
include "LIB/ZXSPECTRUM.INC" // Include ZX Spectrum Definitions

// Decode LZ77/LZSS Data To Screen Bitmap & Color Area
ld hl,Screen+4 // HL = LZ Source Offset (Skip LZ Header)
ld de,SCR_BMP  // DE = Destination Address
LZLoop:
  ld a,(hl) // A = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
  inc hl // HL++
  ld b,a // B = A
  ld c,%10000000 // C = Flag Data Block Type Shifter
  LZBlockLoop:
    ld a,(Screen+2) // A = Data Length Hi Byte
    add a,SCR_COL+767>>8 // A = Destination End Offset Hi Byte
    cp d // Compare Destination End Offset Hi Byte With Destination Address Hi Byte
    jr nz,LZContinue
    ld a,(Screen+1) // A = Destination End Offset Lo Byte
    cp e // Compare Destination End Offset Lo Byte With Destination Address Lo Byte
    jr z,LZEnd // IF (Destination Address == Destination End Offset) LZ End
  LZContinue:
    xor a // A = 0
    cp c // IF (Flag Data Block Type Shifter == 0) LZ Loop
    jr z,LZLoop
    ld a,b // A = Flag Data For Next 8 Blocks (0 = Uncompressed Byte, 1 = Compressed Bytes)
    and c // Test Block Type
    jr nz,LZDecode // IF (Block Type != 0) LZ Decode Bytes
    srl c // Shift C To Next Flag Data Block Type
    ld a,(hl) // ELSE Copy Uncompressed Byte
    inc hl // HL++
    ld (de),a // Store Uncompressed Byte To Destination Address
    inc de // Destination Address++
    jr LZBlockLoop
    LZDecode:
      srl c // Shift C To Next Flag Data Block Type
      push bc // Push BC To Stack
      ld a,(hl) // A = Number Of Bytes To Copy & Disp MSB's
      inc hl // HL++
      ld b,a // B = A
      ld a,(hl) // A = Disp LSB's
      inc hl // HL++
      push hl // Push HL To Stack
      cpl // Complement A
      ld l,a // L = A
      ld a,b // A = B
      and $0F // A &= $0F
      cpl // Complement A
      ld h,a // H = A (HL = -Disp - 1)
      add hl,de // HL = Destination - Disp - 1
      srl b
      srl b
      srl b
      srl b // B = Number Of Bytes To Copy (Minus 3)
      inc b
      inc b
      inc b // B = Number Of Bytes To Copy
      LZCopy:
        ld a,(hl) // A = Byte To Copy
        inc hl // HL++
        ld (de),a // Store Uncompressed Byte To Destination Address
        inc de // Destination Address++
        dec b // Number Of Bytes To Copy--
        jr nz,LZCopy // IF (Number Of Bytes To Copy != 0) LZ Copy Bytes
        pop hl // Pop HL Off Stack
        pop bc // Pop BC Off Stack
        jr LZBlockLoop
LZEnd:

Loop:
  jr Loop

insert Screen, "GFX/Lenna.lz" // Include LZ Compressed Screen Data (???? Bytes)