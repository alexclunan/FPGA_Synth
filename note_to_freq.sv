// Converts Inputted Notes on the Western Scale A4 = 440Hz to values usable by a 25 MHz Clock

/*
25 MHz clock
Number of cycles per note:
Note: NumCycles|  Hex  |  Hex -0 bit  | Binary -0 bit  |     Verfied?     |
C0:  1 528 903 | 17 54 47 | BAA2 3 | 10 1110 1010100010 10 1110 1010100010
C#0: 1 443 091 | 16 05 13 | B028 9 | 10 1100 0000101000 10 1100 0000101000
D0:  1 362 097 | 14 C8 B1 | A645 8 | 10 1001 1001000101 10 1001 1001000101
D#0: 1 285 649 | 13 9E 11 | 9CF0 8 | 10 0111 0011110000 10 0111 0011110000
E0:  1 213 490 | 12 84 32 | 9421 9 | 10 0101 0000100001 10 0101 0000100001
F0:  1 145 383 | 11 7A 27 | 8BD1 3 | 10 0010 1111010001 10 0010 1111010001
F#0: 1 081 097 | 10 7F 09 | 83F8 4 | 10 0000 1111111000 10 0000 1111111000
G0:  1 020 420 |  F 92 04 | 7C90 2 | 01 1111 0010010000 01 1111 0010010000
G#0:   963 148 |  E B2 4C | 7592 6 | 01 1101 0110010010 01 1101 0110010010
A0:    909 091 |  D DF 23 | 6EF9 1 | 01 1011 1011111001 01 1011 1011111001
A#0:   858 068 |  D 17 D4 | 68BE A | 01 1010 0010111110 01 1010 0010111110
B0:    809 908 |  C 5B B4 | 62DD A | 01 1000 1011011101 01 1000 1011011101

C10 =    1 493 (Max Frequency)
*/

/*
Strategy:
8 bit code
Top 4 bits are note letter
bottom 4 bits are note number
Assume 0.05 Hz ringing is acceptable

Remove bottom 5 bits (reduces sampling to 781,250 KHz from 25 MHz)

Encoding uses bits 10-13 to generate a unique command name for each note:

Note  | Encoding |
C     | 1110 | E |
C#    | 1100 | C |
D     | 1001 | 9 |
D#    | 0111 | 7 |
E     | 0101 | 5 |
F     | 0010 | 2 |
F#    | 0000 | 0 |
G     | 1111 | F |
G#    | 1101 | D |
A     | 1011 | B |
A#    | 1010 | A |
B     | 1000 | 8 |


*/


module note_2_freq (
    input           i_note_ready,
    input [7:0]     i_uart_RX,
    output [15:0]   cycles_per_note
);

logic [1:0] top_bits;
logic [3:0]  cmd_bits;
logic [9:0]  bot_bits;

always @(posedge(i_note_ready)) begin

    case (i_uart_RX[7:4])

    4'hE: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1010100010; end // C0
    4'hC: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0000101000; end // C#0
    4'h9: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1001000101; end // D0
    4'h7: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0011110000; end // D#0
    4'h5: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0000100001; end // E0
    4'h2: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1111010001; end // F0
    4'h0: begin top_bits <= 2'b10; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1111111000; end // F#0
    4'hF: begin top_bits <= 2'b01; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0010010000; end // G0
    4'hD: begin top_bits <= 2'b01; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0110010010; end // G#0
    4'hB: begin top_bits <= 2'b01; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1011111001; end // A0
    4'hA: begin top_bits <= 2'b01; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b0010111110; end // A#0
    4'h8: begin top_bits <= 2'b01; cmd_bits <= i_uart_RX[7:4]; bot_bits <= 10'b1011011101; end // B0
    default: begin top_bits <= 2'b00; cmd_bits <= 4'b0000;     bot_bits <= 10'b0000000000; end
    endcase

end

assign cycles_per_note = {top_bits, cmd_bits, bot_bits};

endmodule