`ifndef SCOREBOARD_CLS_PKG__SV
`define SCOREBOARD_CLS_PKG__SV

package scoreboard_cls_pkg;

    import transaction_cls_pkg::*;
    import test_param_pkg::*;

    class scoreboard_cls;

        mailbox #(transaction_cls)  mbx_agt2scb, mbx_scb2chk;
        transaction_cls             input_transaction, output_transaction;
        int                         cnt_good;
        int                         cnt_bad;

        function new (
            input mailbox #(transaction_cls) mbx_agt2scb, mbx_scb2chk
        );
            this.mbx_agt2scb = mbx_agt2scb;
            this.mbx_scb2chk = mbx_scb2chk;
            cnt_good = 0;
            cnt_bad = 0;
        endfunction : new

        task run (
            input int count
        );
            logic [DATA_WIDTH-1:0] crc;

            repeat (count) begin
                mbx_agt2scb.get(input_transaction);
                crc = '1;

                foreach (input_transaction.data_buf[i]) begin
                    crc = calc_crc(.CRC_I(crc), .DATA_I(input_transaction.data_buf[i]));
                end

                if (crc === '0) begin
                    output_transaction = new;
                    output_transaction.data_buf = input_transaction.data_buf;
                    mbx_scb2chk.put(output_transaction);
                    cnt_good++;
                end
                else begin
                    cnt_bad++;
                end
            end
        endtask : run

    endclass : scoreboard_cls

endpackage : scoreboard_cls_pkg

`endif //SCOREBOARD_CLS_PKG__SV