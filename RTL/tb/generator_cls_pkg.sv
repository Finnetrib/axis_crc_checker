`ifndef GENERATOR_CLS_PKG__SV
`define GENERATOR_CLS_PKG__SV

package generator_cls_pkg;

    import transaction_cls_pkg::*;
    `include "rand_check.svh"

    class generator_cls;

        transaction_cls             transaction;
        mailbox #(transaction_cls)  mbx_gen;

        function new (
            input mailbox #(transaction_cls) mbx_gen
        );
            this.mbx_gen = mbx_gen;
        endfunction : new

        task run (
            input int count
        );
            repeat (count) begin
                transaction = new();
                `SV_RAND_CHECK(transaction.randomize());
                mbx_gen.put(transaction);
            end
        endtask : run

    endclass : generator_cls

endpackage : generator_cls_pkg

`endif //GENERATOR_CLS_PKG__SV