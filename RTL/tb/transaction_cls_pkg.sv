`ifndef TRANSACTION_CLS_PKG__SV
`define TRANSACTION_CLS_PKG__SV

package transaction_cls_pkg;

    import test_param_pkg::*;

    class transaction_cls;

        localparam int MIN_PACK_SIZE = 10;
        localparam int MAX_PACK_SIZE = 1024;

        rand bit [$clog2(MAX_PACK_SIZE)-1:0] pack_size;
        rand bit bad_pack;

        constraint c_transaction {
            pack_size inside {[MIN_PACK_SIZE : MAX_PACK_SIZE]};
        }

        logic [DATA_WIDTH-1:0] data_buf [];
        logic [DATA_WIDTH-1:0] crc_field;

        function void post_randomize ();
            int select_index;
            data_buf = new[pack_size];

            crc_field = '1;
            for (int i = 0; i < data_buf.size() - 1; i++) begin
                data_buf[i] = $urandom_range(0, 2**DATA_WIDTH - 1);
                crc_field = calc_crc(.CRC_I(crc_field), .DATA_I(data_buf[i]));
            end
            data_buf[data_buf.size() - 1] = crc_field;

            if (bad_pack === 1'b1) begin
                select_index = $urandom_range(0, data_buf.size());
                data_buf[select_index] = $urandom_range(0, 2**DATA_WIDTH - 1);
            end

        endfunction : post_randomize

    endclass : transaction_cls

endpackage : transaction_cls_pkg

`endif //TRANSACTION_CLS_PKG__SV