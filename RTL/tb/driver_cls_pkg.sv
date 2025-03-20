`ifndef DRIVER_CLS_PKG__SV
`define DRIVER_CLS_PKG__SV

package driver_cls_pkg;

    import transaction_cls_pkg::*;
    import test_param_pkg::*;

    class driver_cls;

        virtual AXIS_Bus    #(.DW(DATA_WIDTH))  vif_axis;
        mailbox             #(transaction_cls)  mbx_agt2drv;
        transaction_cls                         transaction;
        event                                   drv_done;

        function new (
            input virtual AXIS_Bus #(.DW(DATA_WIDTH)) vif_axis,
            input mailbox #(transaction_cls) mbx_agt2drv,
            input event drv_done
        );
            this.vif_axis       = vif_axis;
            this.mbx_agt2drv    = mbx_agt2drv;
            this.drv_done       = drv_done;
        endfunction : new

        task init ();
            vif_axis.tvalid <= 1'b0;
        endtask : init

        task run (
            input int count
        );
            repeat (count) begin
                mbx_agt2drv.peek(transaction);

                for (int i = 0; i < transaction.data_buf.size(); i ++) begin
                    vif_axis.tdata  <= transaction.data_buf[i];
                    vif_axis.tvalid <= 1'b1;
                    vif_axis.tlast  <= (i == transaction.data_buf.size() - 1) ? 1'b1 : 1'b0;
                    @(posedge vif_axis.clk);
                    while (vif_axis.tready === 1'b0) begin
                        @(posedge vif_axis.clk);
                    end
                    vif_axis.tvalid <= 1'b0;
                    if ($urandom_range(0, 3) === 0) begin
                        repeat ($urandom_range(1, 15)) begin
                            @(posedge vif_axis.clk);
                        end
                    end
                end

                mbx_agt2drv.get(transaction);
            end
            -> drv_done;
        endtask : run

    endclass : driver_cls

endpackage : driver_cls_pkg

`endif //DRIVER_CLS_PKG__SV