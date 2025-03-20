`ifndef ENVIRONMENT_CLS_PKG__SV
`define ENVIRONMENT_CLS_PKG__SV

package environment_cls_pkg;

    `include "rand_check.svh"
    import config_cls_pkg::*;
    import test_param_pkg::*;
    import transaction_cls_pkg::*;
    import generator_cls_pkg::*;
    import agent_cls_pkg::*;
    import driver_cls_pkg::*;
    import scoreboard_cls_pkg::*;
    import monitor_cls_pkg::*;
    import checker_cls_pkg::*;

    class environment_cls;

        config_cls      cfg;
        generator_cls   gen;
        agent_cls       agt;
        driver_cls      drv;
        scoreboard_cls  scb;
        monitor_cls     mon;
        checker_cls     chk;

        mailbox #(transaction_cls) mbx_gen2agt, mbx_agt2drv, mbx_agt2scb, mbx_scb2chk, mbx_mon2chk;

        virtual AXIS_Bus #(.DW(DATA_WIDTH)) vif_axis_in, vif_axis_out;
        event mon_done, drv_done;

        function new (
            input virtual AXIS_Bus #(.DW(DATA_WIDTH)) vif_axis_in, vif_axis_out
        );
            this.vif_axis_in = vif_axis_in;
            this.vif_axis_out = vif_axis_out;
            cfg = new();
        endfunction : new

        function void gen_cfg();
             `SV_RAND_CHECK(cfg.randomize());
             $display("[ENV] Run count = %0d", cfg.run_count);
        endfunction : gen_cfg

        function void build ();
            mbx_gen2agt = new(1);
            mbx_agt2drv = new(1);
            mbx_agt2scb = new(1);
            mbx_scb2chk = new(1);
            mbx_mon2chk = new(1);

            gen = new(.mbx_gen(mbx_gen2agt));
            agt = new(.mbx_gen2agt(mbx_gen2agt), .mbx_agt2drv(mbx_agt2drv), .mbx_agt2scb(mbx_agt2scb));
            drv = new(.vif_axis(vif_axis_in), .mbx_agt2drv(mbx_agt2drv), .drv_done(drv_done));
            scb = new(.mbx_agt2scb(mbx_agt2scb), .mbx_scb2chk(mbx_scb2chk));
            mon = new(.vif_axis(vif_axis_out), .mbx_mon2chk(mbx_mon2chk), .mon_done(mon_done));
            chk = new(.mbx_scb2chk(mbx_scb2chk), .mbx_mon2chk(mbx_mon2chk));
        endfunction : build

        task init ();
            drv.init();
            mon.init();
        endtask : init

        task run_send ();
            fork
                gen.run(.count(cfg.run_count));
                agt.run(.count(cfg.run_count));
                drv.run(.count(cfg.run_count));
                scb.run(.count(cfg.run_count));
            join
        endtask : run_send

        task run_receive ();
            fork
                fork
                    mon.run();
                    chk.run();
                join
                forever begin
                    @(drv_done);
                    if (scb.cnt_good === mon.cnt_handle) begin
                        break;
                    end
                    forever begin
                        @(mon_done);
                        if (scb.cnt_good === mon.cnt_handle) begin
                            break;
                        end
                    end
                    break;
                end
            join_any
            $display("[ENV] Socreboard good packet = %4d, scoreboard bad packet = %4d", scb.cnt_good, scb.cnt_bad);
            $display(">>>>> SUCCESS");
            $finish;
        endtask : run_receive

    endclass : environment_cls

endpackage : environment_cls_pkg

`endif //ENVIRONMENT_CLS_PKG__SV