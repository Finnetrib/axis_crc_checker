`default_nettype none

module sync_fifo #(
    parameter int FIFO_DEPTH            = 8,
    parameter int DATA_WIDTH            = 32
)(
    input  wire logic                   CLK_I,
    input  wire logic                   RST_I,

    input  wire logic                   WR_EN_I,
    input  wire logic [DATA_WIDTH-1:0]  WR_DATA_I,
    output var  logic                   FULL_O,

    input  wire logic                   RD_EN_I,
    output var  logic [DATA_WIDTH-1:0]  RD_DATA_O,
    output var  logic                   EMPTY_O
);

localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);

logic [ADDR_WIDTH:0]    wr_ptr;
logic [ADDR_WIDTH:0]    rd_ptr;
logic [DATA_WIDTH-1:0]  fifo_cell [FIFO_DEPTH-1:0];

always_comb begin : pc_full_o
    FULL_O = (  (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                (wr_ptr[ADDR_WIDTH - 1:0] == rd_ptr[ADDR_WIDTH - 1:0]) ) ? 1'b1 : 1'b0;
end : pc_full_o

always_comb begin : pc_empty_o
    EMPTY_O = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
end : pc_empty_o

always_ff @(posedge CLK_I) begin : ps_wr_ptr
    if (RST_I) begin
        wr_ptr <= '0;
    end
    else begin
        if (FULL_O == 1'b0 && WR_EN_I == 1'b1) begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
end : ps_wr_ptr

always_ff @(posedge CLK_I) begin : ps_rd_ptr
    if (RST_I) begin
        rd_ptr <= '0;
    end
    else begin
        if (EMPTY_O == 1'b0 && RD_EN_I == 1'b1) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end : ps_rd_ptr

always_ff @(posedge CLK_I) begin : ps_fifo_cell
    if (FULL_O == 1'b0 && WR_EN_I == 1'b1) begin
        fifo_cell[wr_ptr[ADDR_WIDTH-1:0]] <= WR_DATA_I;
    end
end : ps_fifo_cell

always_comb begin : pc_rd_data_o
    RD_DATA_O = fifo_cell[rd_ptr[ADDR_WIDTH-1:0]];
end : pc_rd_data_o

endmodule

`resetall
