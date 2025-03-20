interface AXIS_Bus #(parameter DW=8) (input clk);

    logic [DW-1:0]  tdata;
    logic           tvalid;
    logic           tlast;
    logic           tready;

    modport slave (
        input   tdata,
        input   tvalid,
        input   tlast,
        output  tready
    );

    modport master (
        output  tdata,
        output  tvalid,
        output  tlast,
        input   tready
    );

endinterface