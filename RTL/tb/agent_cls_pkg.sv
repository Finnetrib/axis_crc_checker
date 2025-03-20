`ifndef AGENT_CLS_PKG__SV
`define AGENT_CLS_PKG__SV

package agent_cls_pkg;

    import transaction_cls_pkg::*;

    class agent_cls;

        transaction_cls             transaction;
        mailbox #(transaction_cls)  mbx_gen2agt, mbx_agt2drv, mbx_agt2scb;

        function new (
            input mailbox #(transaction_cls) mbx_gen2agt, mbx_agt2drv, mbx_agt2scb
        );
            this.mbx_gen2agt = mbx_gen2agt;
            this.mbx_agt2drv = mbx_agt2drv;
            this.mbx_agt2scb = mbx_agt2scb;
        endfunction : new

        task run (
            input int count
        );
            repeat (count) begin
                mbx_gen2agt.get(transaction);
                mbx_agt2drv.put(transaction);
                mbx_agt2scb.put(transaction);
            end
        endtask : run

    endclass : agent_cls

endpackage : agent_cls_pkg

`endif //AGENT_CLS_PKG__SV