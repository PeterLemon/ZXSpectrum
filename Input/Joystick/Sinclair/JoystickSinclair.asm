// ZX Spectrum Joystick Sinclair P@ort 1 & 2 Input demo by krom (Peter Lemon):
arch zxs.cpu
output "JoystickSinclair.z80", create
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

// Print Text 1 Characters To Screen Bitmap Area
ld c,30*8 // C = Byte Copy Count (30 Characters * 8 Bytes)
ld de,SCR_BMP+1+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 1, ROW = 3, SCREEN BLOCK = 1)
ld ix,Text1 // IX = Text 1 Offset

LoopText1:
  ld h,0 // H = 0
  ld l,(ix+$00) // L = Next Text Character (L = IX[0])
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld a,c // A = Byte Copy Count (C)
  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)
  ld c,a // C = Byte Copy Count (A)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopText1Byte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopText1Byte // Decrement Count (B--), IF (Count != 0) Loop Text 1 Byte

  xor a // A = 0
  cp c  // Compare C To A
  jr z,Text1End // IF (Z Flag Set) Text 1 End

  ld a,-7 // A = -7
  add a,d // Subtract 7 From Screen Bitmap Area Address MSB (D -= 7) (7 Scanlines Up)
  ld d,a  // D = A
  inc ix  // Increment Text 1 Offset (IX++)
  jr LoopText1
  Text1End:

// Print Text 2 Characters To Screen Bitmap Area
ld c,30*8 // C = Byte Copy Count (30 Characters * 8 Bytes)
ld de,SCR_BMP+1+(32*4)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 1, ROW = 4, SCREEN BLOCK = 1)
ld ix,Text2 // IX = Text 2 Offset

LoopText2:
  ld h,0 // H = 0
  ld l,(ix+$00) // L = Next Text Character (L = IX[0])
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld a,c // A = Byte Copy Count (C)
  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)
  ld c,a // C = Byte Copy Count (A)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopText2Byte:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopText2Byte // Decrement Count (B--), IF (Count != 0) Loop Text 2 Byte

  xor a // A = 0
  cp c  // Compare C To A
  jr z,Text2End // IF (Z Flag Set) Text 2 End

  ld a,-7 // A = -7
  add a,d // Subtract 7 From Screen Bitmap Area Address MSB (D -= 7) (7 Scanlines Up)
  ld d,a  // D = A
  inc ix  // Increment Text 2 Offset (IX++)
  jr LoopText2
  Text2End:

Loop:
  // Print Joystick Sinclair Port 1 Text Character To Screen Bitmap Area
  call ReadJoystickSinclair1 // A = Character Byte Code From Pressed Button
  cp 0 // Compare A To 0
  jr z,Skip1 // IF (A = 0) Skip 1

  ld de,SCR_BMP+29+(32*3)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 29, ROW = 3, SCREEN BLOCK = 1)
  ld h,0 // H = 0
  ld l,a // L = Text Character (A)
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopButtonTextByte1:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopButtonTextByte1 // Decrement Count (B--), IF (Count != 0) Loop Button Text Byte 1

  Skip1:

  // Print Joystick Sinclair Port 2 Text Character To Screen Bitmap Area
  call ReadJoystickSinclair2 // A = Character Byte Code From Pressed Button
  cp 0 // Compare A To 0
  jr z,Skip2 // IF (A = 0) Skip 2

  ld de,SCR_BMP+29+(32*4)+($800*1) // DE = Screen Bitmap Area Address ($4000..$57FF) (Starting Position Of Text: COLUMN = 29, ROW = 4, SCREEN BLOCK = 1)
  ld h,0 // H = 0
  ld l,a // L = Text Character (A)
  add hl,hl // HL *= 8
  add hl,hl
  add hl,hl // HL = Text Character Address

  ld bc,Font8x8-($20*8) // BC = Font Address
  add hl,bc // Text Character Address (HL) += Font Address (BC)

  ld b,7 // B = Count (7)
  ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
  LoopButtonTextByte2:
    dec de // Decrement Screen Bitmap Area Address (DE--) (8 Pixels Back)
    inc d  // Increment Screen Bitmap Area Address MSB (D++) (1 Scanline Down)
    ldi    // Copy Text Character Data To Screen Bitmap Area (LD (DE),(HL), DE++, HL++, BC--)
    djnz LoopButtonTextByte2 // Decrement Count (B--), IF (Count != 0) Loop Button Text Byte 2

  Skip2:
    jr Loop

ReadJoystickSinclair1: // Read Joystick Sinclair Port 1 (A = Character Byte Code From Pressed Button)
  ld hl,Sinclair1Map // HL = Sinclair Map Address
  ld bc,$EFFE // BC = Sinclair Port 1 ($EFFE)
  in a,(c)   // A = Buttons From Sinclair Port 1 (BC)
  and $1F    // A &= $1F (Mask 1st 5 Bits)
  ld b,5     // B = Button Count (Number Of Buttons = 5)
  ReadButton1:
    srl a              // Logical Shift A Right, Carry Flag = Bit 0
    jr nc,ButtonFound1 // IF (Carry Flag = 0) Button Found 1
    inc hl             // ELSE: Increment Sinclair Map Address (HL++) For Next Table Address
    djnz ReadButton1   // Decrement Button Count (B--), IF (Button Count != 0) Read Button 1
    ret                // Button Not Found: A = 0
  ButtonFound1:
    ld a,(hl) // Button Found: A = Character Byte Code
    ret
Sinclair1Map:
  db "F","U","D","R","L" // Character 0..4

ReadJoystickSinclair2: // Read Joystick Sinclair Port 2 (A = Character Byte Code From Pressed Button)
  ld hl,Sinclair2Map // HL = Sinclair Map Address
  ld bc,$F7FE // BC = Sinclair Port 2 ($F7FE)
  in a,(c)   // A = Buttons From Sinclair Port 2 (BC)
  and $1F    // A &= $1F (Mask 1st 5 Bits)
  ld b,5     // B = Button Count (Number Of Buttons = 5)
  ReadButton2:
    srl a              // Logical Shift A Right, Carry Flag = Bit 0
    jr nc,ButtonFound2 // IF (Carry Flag = 0) Button Found 2
    inc hl             // ELSE: Increment Sinclair Map Address (HL++) For Next Table Address
    djnz ReadButton2   // Decrement Button Count (B--), IF (Button Count != 0) Read Button 2
    ret                // Button Not Found: A = 0
  ButtonFound2:
    ld a,(hl) // Button Found: A = Character Byte Code
    ret
Sinclair2Map:
  db "L","R","D","U","F" // Character 0..4

Text1:
  db "Joystick Sinclair Port 1 = \d \d" // Joystick Sinclair Port 1 Input Text (30 Bytes)
Text2:
  db "Joystick Sinclair Port 2 = \d \d" // Joystick Sinclair Port 2 Input Text (30 Bytes)

Font8x8:
  include "Font8x8.asm" // Include 8x8 Font