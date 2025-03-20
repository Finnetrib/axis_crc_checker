`ifndef CHECKER_CLS_PKG__SV
`define CHECKER_CLS_PKG__SV

package checker_cls_pkg;

    import transaction_cls_pkg::*;

    class checker_cls;

        mailbox #(transaction_cls)  mbx_scb2chk, mbx_mon2chk;
        transaction_cls             scb_transaction, mon_transaction;

        function new (
            input mailbox #(transaction_cls) mbx_scb2chk, mbx_mon2chk
        );
            this.mbx_scb2chk = mbx_scb2chk;
            this.mbx_mon2chk = mbx_mon2chk;
        endfunction : new

        task run ();
            forever begin
                fork
                    mbx_scb2chk.get(scb_transaction);
                    mbx_mon2chk.get(mon_transaction);
                join
                if (scb_transaction.data_buf.size() !== mon_transaction.data_buf.size()) begin
                    $display("[CHK] Received different buffer size. Scoreboard size %d, monitor size %d", scb_transaction.data_buf.size(), mon_transaction.data_buf.size());
                    $display(">>>>> FAIL");
                    $finish;
                end
                foreach (scb_transaction.data_buf[i]) begin
                    if (scb_transaction.data_buf[i] !== mon_transaction.data_buf[i]) begin
                        $display("[CHK] Fount mismath in buffer. Buffer offset %d, scoreboard value %h, monitor value %h", i, scb_transaction.data_buf[i], mon_transaction.data_buf[i]);
                        $display(">>>>> FAIL");
                        $finish;
                    end
                end
            end
        endtask : run

    endclass : checker_cls

endpackage : checker_cls_pkg

`endif //CHECKER_CLS_PKG__SV