`ifndef TEST_CLS_PKG__SV
`define TEST_CLS_PKG__SV

package test_cls_pkg;

    import environment_cls_pkg::*;
    import test_param_pkg::*;

    class test_cls;

        environment_cls env;

        function new (
            input virtual AXIS_Bus #(.DW(DATA_WIDTH)) vif_axis_in, vif_axis_out
        );
            env = new(.vif_axis_in(vif_axis_in), .vif_axis_out(vif_axis_out));
        endfunction : new

        task init();
            env.gen_cfg();
            env.build();
            env.init();
        endtask : init

        task run();
            fork
                env.run_send();
                env.run_receive();
            join
        endtask : run

    endclass : test_cls

endpackage : test_cls_pkg

`endif //TEST_CLS_PKG__SV