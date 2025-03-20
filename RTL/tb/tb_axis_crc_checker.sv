`default_nettype none

`timescale 1ns/1ps

module tb_axis_crc_checker ();

import test_cls_pkg::*;
import test_param_pkg::*;

localparam bit TEST_SV = 1'b0;
localparam bit TEST_CHISEL = 1'b1;

parameter bit TEST_TYPE = 1'b0;

localparam CLK_PERIOD = 4ns;
localparam RST_QTY = 3;

logic clk;
logic rst;

AXIS_Bus #(.DW(DATA_WIDTH)) axis_in_if (.clk(clk));
AXIS_Bus #(.DW(DATA_WIDTH)) axis_out_if (.clk(clk));

test_cls test;

initial begin
    clk <= 1'b0;
    forever begin
        #(CLK_PERIOD / 2);
        clk <= ~clk;
    end
end

initial begin
    rst <= 1'b1;
    repeat (RST_QTY) begin
        @(posedge clk);
    end
    rst <= 1'b0;
end

initial begin
    $display("\n\n");
    $display("------------------------------------------------------------");
    $display("                   TEST PARAMS");

    if (TEST_TYPE === TEST_SV) begin
        $display("                   TEST SYSTEM VERILOG SOURCES");
    end
    else begin
        $display("                   TEST CHISEL SOURCES");
    end

    if ($test$plusargs("SEED")) begin
        int seed;
        $value$plusargs("SEED=%d", seed);
        $display("Simalation run with random seed = %0d", seed);
        $urandom(seed);
    end
    else begin
        $display("Simulation run with default random seed");
    end
    $display("------------------------------------------------------------");

    test = new(.vif_axis_in(axis_in_if), .vif_axis_out(axis_out_if));
    test.init();
    @(negedge rst);
    test.run();
    #100ns;
    $stop;
end

generate
    if (TEST_TYPE === TEST_SV) begin
        axis_crc_checker UUT (
            .CLK_I          (clk),
            .RST_I          (rst),
            .AXIS_SLV_IF    (axis_in_if),
            .AXIS_MST_IF    (axis_out_if)
        );
    end
    else begin
        AxisCrcChecker UUT(
            .clock                  (clk),
            .reset                  (rst),
            .io_AxisSlv_ready       (axis_in_if.tready),
            .io_AxisSlv_valid       (axis_in_if.tvalid),
            .io_AxisSlv_bits_Tlast  (axis_in_if.tlast),
            .io_AxisSlv_bits_Tdata  (axis_in_if.tdata),
            .io_AxisMst_ready       (axis_out_if.tready),
            .io_AxisMst_valid       (axis_out_if.tvalid),
            .io_AxisMst_bits_Tlast  (axis_out_if.tlast),
            .io_AxisMst_bits_Tdata  (axis_out_if.tdata)
        );
    end
endgenerate

endmodule

`resetall
