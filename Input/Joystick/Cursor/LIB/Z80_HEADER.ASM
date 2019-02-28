//=========================
// ZX Spectrum .Z80 Header
//=========================
db $00   // A Register
db $00   // F Register
db $00   // C Register
db $00   // B Register
db $00   // L Register
db $00   // H Register
dw Start // Program Counter
dw $0000 // Stack Pointer
db $00   // Interrupt Register
db $00   // Refresh Register (Bit 7 Not Used)
db $00   // Bit 0   : Bit 7 Of Refresh Register
         // Bit 1..3: Border Color
         // Bit 4   : 1 = Basic SamRom Switched In
         // Bit 5   : 0 = Block Data Uncompressed, 1 = Block Data Compressed
         // Bit 6..7: Unused
db $00   // E Register
db $00   // D Register
db $00   // C' Register
db $00   // B' Register
db $00   // E' Register
db $00   // D' Register
db $00   // L' Register
db $00   // H' Register
db $00   // A' Register
db $00   // F' Register
dw $0000 // IY Register
dw $0000 // IX Register
db $00   // Interrupt Flipflop, 0 = DI, 1..255 = EI
db $00   // IFF2
db $01   // Bit 0..1: Interrupt Mode (0, 1, 2)
         // Bit 2   : 1 = Issue 2 Emulation
         // Bit 3   : 1 = Double Interrupt Frequency
         // Bit 4..5: 0 = Normal, 1 = High Video Synchronisation, 2 = Normal, 3 = Low Video Synchronisation
         // Bit 6..7: 0 = Cursor/Protek/AGF, 1 = Kempston, 2 = Sinclair 2 Left, 3 = Sinclair 2 Right Joystick