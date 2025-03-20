// vim: ts=4 sw=4 expandtab

// THIS IS GENERATED VERILOG CODE.
// https://bues.ch/h/crcgen
// 
// This code is Public Domain.
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
// RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.

`ifndef CALC_CRC_V_
`define CALC_CRC_V_

// CRC polynomial coefficients: x^8 + x^2 + x + 1
//                              0x7 (hex)
// CRC width:                   8 bits
// CRC shift direction:         left (big endian)
// Input word width:            8 bits

module calc_crc (
    input [7:0] CRC_I,
    input [7:0] DATA_I,
    output [7:0] CRC_O
);
    assign CRC_O[0] = CRC_I[0] ^ CRC_I[6] ^ CRC_I[7] ^ DATA_I[0] ^ DATA_I[6] ^ DATA_I[7];
    assign CRC_O[1] = CRC_I[0] ^ CRC_I[1] ^ CRC_I[6] ^ DATA_I[0] ^ DATA_I[1] ^ DATA_I[6];
    assign CRC_O[2] = CRC_I[0] ^ CRC_I[1] ^ CRC_I[2] ^ CRC_I[6] ^ DATA_I[0] ^ DATA_I[1] ^ DATA_I[2] ^ DATA_I[6];
    assign CRC_O[3] = CRC_I[1] ^ CRC_I[2] ^ CRC_I[3] ^ CRC_I[7] ^ DATA_I[1] ^ DATA_I[2] ^ DATA_I[3] ^ DATA_I[7];
    assign CRC_O[4] = CRC_I[2] ^ CRC_I[3] ^ CRC_I[4] ^ DATA_I[2] ^ DATA_I[3] ^ DATA_I[4];
    assign CRC_O[5] = CRC_I[3] ^ CRC_I[4] ^ CRC_I[5] ^ DATA_I[3] ^ DATA_I[4] ^ DATA_I[5];
    assign CRC_O[6] = CRC_I[4] ^ CRC_I[5] ^ CRC_I[6] ^ DATA_I[4] ^ DATA_I[5] ^ DATA_I[6];
    assign CRC_O[7] = CRC_I[5] ^ CRC_I[6] ^ CRC_I[7] ^ DATA_I[5] ^ DATA_I[6] ^ DATA_I[7];
endmodule

`endif // CALC_CRC_V_