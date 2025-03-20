`ifndef TEST_PARAM_PKG__SV
`define TEST_PARAM_PKG__SV

package test_param_pkg;

    localparam int DATA_WIDTH = 8;

    function automatic [7:0] calc_crc;
        input [7:0] CRC_I;
        input [7:0] DATA_I;
    begin
        calc_crc[0] = CRC_I[0] ^ CRC_I[6] ^ CRC_I[7] ^ DATA_I[0] ^ DATA_I[6] ^ DATA_I[7];
        calc_crc[1] = CRC_I[0] ^ CRC_I[1] ^ CRC_I[6] ^ DATA_I[0] ^ DATA_I[1] ^ DATA_I[6];
        calc_crc[2] = CRC_I[0] ^ CRC_I[1] ^ CRC_I[2] ^ CRC_I[6] ^ DATA_I[0] ^ DATA_I[1] ^ DATA_I[2] ^ DATA_I[6];
        calc_crc[3] = CRC_I[1] ^ CRC_I[2] ^ CRC_I[3] ^ CRC_I[7] ^ DATA_I[1] ^ DATA_I[2] ^ DATA_I[3] ^ DATA_I[7];
        calc_crc[4] = CRC_I[2] ^ CRC_I[3] ^ CRC_I[4] ^ DATA_I[2] ^ DATA_I[3] ^ DATA_I[4];
        calc_crc[5] = CRC_I[3] ^ CRC_I[4] ^ CRC_I[5] ^ DATA_I[3] ^ DATA_I[4] ^ DATA_I[5];
        calc_crc[6] = CRC_I[4] ^ CRC_I[5] ^ CRC_I[6] ^ DATA_I[4] ^ DATA_I[5] ^ DATA_I[6];
        calc_crc[7] = CRC_I[5] ^ CRC_I[6] ^ CRC_I[7] ^ DATA_I[5] ^ DATA_I[6] ^ DATA_I[7];
    end
endfunction

endpackage : test_param_pkg

`endif //TEST_PARAM_PKG__SV