`ifndef CONGIG_CLS_PKG__SV
`define CONGIG_CLS_PKG__SV

package config_cls_pkg;

    class config_cls;

        rand bit[15:0] run_count;

        constraint c_constraint {
            run_count inside {[1000:2000]};
        }

    endclass : config_cls

endpackage : config_cls_pkg

`endif //CONGIG_CLS_PKG__SV