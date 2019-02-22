//=====================
// ZX Spectrum Include
//=====================
// Memory Map (1st 16KB Is Read Only ROM, Rest Of Memory Map Is Read/Write RAM)
constant SYS_ROM($0000) // $0000..$3FFF: System ROM (16KB)
constant SCR_BMP($4000) // $4000..$57FF: Screen Memory - Bitmap Data (6KB)
constant SCR_COL($5800) // $5800..$5AFF: Screen Memory - Color Data (768 Bytes)
constant PRN_BUF($5B00) // $5B00..$5BFF: Printer Buffer (256 Bytes)
constant SYS_VAR($5C00) // $5C00..$5CBF: System Variables (192 Bytes)
                        // $5CC0..$5CCA: Reserved (10 Bytes)
constant SYS_RAM($5CCB) // $5CCB..$FF57: System RAM (Program) (40KB)
constant RAM_TOP($FF58) // $FF58..$FFFF: Reserved (168 Bytes)

// Screen Bitmap Color Attributes (%FBPPPIII: F = FLASH Mode, B = BRIGHTNESS Mode, P = PAPER Color, I = INK Color)
constant I_BLACK(%00000000)   // Ink Color 0: Black
constant I_BLUE(%00000001)    // Ink Color 1: Blue
constant I_RED(%00000010)     // Ink Color 2: Red
constant I_MAGENTA(%00000011) // Ink Color 3: Magenta
constant I_GREEN(%00000100)   // Ink Color 4: Green
constant I_CYAN(%00000101)    // Ink Color 5: Cyan
constant I_YELLOW(%00000110)  // Ink Color 6: Yellow
constant I_WHITE(%00000111)   // Ink Color 7: White

constant P_BLACK(%00000000)   // Paper Color 0: Black
constant P_BLUE(%00001000)    // Paper Color 1: Blue
constant P_RED(%00010000)     // Paper Color 2: Red
constant P_MAGENTA(%00011000) // Paper Color 3: Magenta
constant P_GREEN(%00100000)   // Paper Color 4: Green
constant P_CYAN(%00101000)    // Paper Color 5: Cyan
constant P_YELLOW(%00110000)  // Paper Color 6: Yellow
constant P_WHITE(%00111000)   // Paper Color 7: White

constant BRIGHT(%01000000)    // Britness Mode: 0 = Dark, 1 = Bright
constant FLASH(%10000000)     // Flashing Mode: 0 = Non Flashing, 1 = Flashing

// I/O Map (Z80 Ports)
constant SND_BCOL($FE) // $FE: Beeper Sound & Border Color (---S-BBB: S = BEEPER Sound, B = BORDER Color)

macro align(size) { // Align Byte Amount
  while (pc() % {size}) {
    db 0
  }
}