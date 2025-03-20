`ifndef MONITOR_CLS_PKG__SV
`define MONITOR_CLS_PKG__SV

package monitor_cls_pkg;

    import transaction_cls_pkg::*;
    import test_param_pkg::*;

    class monitor_cls;

        virtual AXIS_Bus    #(.DW(DATA_WIDTH))  vif_axis;
        mailbox             #(transaction_cls)  mbx_mon2chk;
        transaction_cls                         transaction;
        event                                   mon_done;
        int                                     cnt_handle;

        function new (
            input virtual AXIS_Bus #(.DW(DATA_WIDTH)) vif_axis,
            input mailbox #(transaction_cls) mbx_mon2chk,
            input event mon_done
        );
            this.vif_axis       = vif_axis;
            this.mbx_mon2chk    = mbx_mon2chk;
            this.mon_done       = mon_done;
        endfunction : new

        task init ();
            vif_axis.tready <= 1'b0;
        endtask : init

        task receive (
            ref logic [DATA_WIDTH-1:0] data_buf []
        );
            logic [DATA_WIDTH-1:0]      data_q[$];

            forever begin
                vif_axis.tready <= 1'b1;
                if (vif_axis.tready & vif_axis.tvalid) begin
                    data_q.push_back(vif_axis.tdata);
                    if (vif_axis.tlast) begin
                        vif_axis.tready <= 1'b0;
                        @(posedge vif_axis.clk);
                        break;
                    end
                end
                @(posedge vif_axis.clk);
            end

            data_buf.delete();
            data_buf = new[data_q.size()];
            foreach (data_buf[i]) begin
                data_buf[i] = data_q.pop_front();
            end
        endtask : receive

        task run ();
            forever begin
                transaction = new();
                receive(.data_buf(transaction.data_buf));
                mbx_mon2chk.put(transaction);
                cnt_handle++;
                -> mon_done;
            end
        endtask : run

    endclass : monitor_cls

endpackage : monitor_cls_pkg

`endif //MONITOR_CLS_PKG__SV