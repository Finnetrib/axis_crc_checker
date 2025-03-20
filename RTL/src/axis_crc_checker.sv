`default_nettype none

module axis_crc_checker (
    input wire logic    CLK_I,
    input wire logic    RST_I,

    AXIS_Bus.slave      AXIS_SLV_IF,
    AXIS_Bus.master     AXIS_MST_IF
);

localparam int AXIS_DW = $bits(AXIS_SLV_IF.tdata);

enum logic [1:0] {ST_RECEIVE, ST_CHECK, ST_RESET, ST_SEND} checker_st;

typedef struct packed {
    logic               tlast;
    logic [AXIS_DW-1:0] tdata;
} fifo_data_t;

logic       packet_received;
logic       packet_sended;
logic [7:0] crc_in;
logic [7:0] crc_out;
logic       fifo_rst;
fifo_data_t fifo_data_w;
logic       fifo_write;
logic       fifo_empty;
logic       fifo_read;
fifo_data_t fifo_data_r;

always_comb begin : pc_packet_received
    packet_received = AXIS_SLV_IF.tvalid & AXIS_SLV_IF.tready & AXIS_SLV_IF.tlast;
end : pc_packet_received

always_comb begin : pc_packet_sended
    packet_sended = AXIS_MST_IF.tvalid & AXIS_MST_IF.tready & AXIS_MST_IF.tlast;
end : pc_packet_sended

always_ff @(posedge CLK_I) begin : ps_checker_st
    if (RST_I) begin
        checker_st <= ST_RECEIVE;
    end
    else begin
        case (checker_st)
            ST_RECEIVE : begin
                if (packet_received) begin
                    checker_st <= ST_CHECK;
                end
            end
            ST_CHECK : begin
                if (crc_in == '0) begin
                    checker_st <= ST_SEND;
                end
                else begin
                    checker_st <= ST_RESET;
                end
            end
            ST_RESET : begin
                checker_st <= ST_RECEIVE;
            end
            ST_SEND : begin
                if (packet_sended) begin
                    checker_st <= ST_RECEIVE;
                end
            end
        endcase
    end
end : ps_checker_st

always_ff @(posedge CLK_I) begin : ps_axis_slv_if_tready
    if (RST_I) begin
        AXIS_SLV_IF.tready <= 1'b0;
    end
    else begin
        if (packet_received == 1'b1) begin
            AXIS_SLV_IF.tready <= 1'b0;
        end
        else if (checker_st == ST_RECEIVE) begin
            AXIS_SLV_IF.tready <= 1'b1;
        end
    end
end : ps_axis_slv_if_tready

always_ff @(posedge CLK_I) begin : ps_crc_in
    if (RST_I) begin
        crc_in <= '1;
    end
    else begin
        if (AXIS_SLV_IF.tvalid & AXIS_SLV_IF.tready) begin
            crc_in <= crc_out;
        end
        else if (checker_st == ST_CHECK) begin
            crc_in <= '1;
        end
    end
end : ps_crc_in

calc_crc u_calc_crc(
    .CRC_I  (crc_in),
    .DATA_I (AXIS_SLV_IF.tdata),
    .CRC_O  (crc_out)
);

always_ff @(posedge CLK_I) begin : ps_fifo_rst
    if (RST_I) begin
        fifo_rst <= 1'b1;
    end
    else begin
        fifo_rst <= (checker_st == ST_RESET) ? 1'b1 : 1'b0;
    end
end : ps_fifo_rst

always_comb begin : pc_fifo_data_w
    fifo_data_w.tdata = AXIS_SLV_IF.tdata;
    fifo_data_w.tlast = AXIS_SLV_IF.tlast;
end : pc_fifo_data_w

always_comb begin : pc_fifo_write
    fifo_write = AXIS_SLV_IF.tvalid & AXIS_SLV_IF.tready;
end : pc_fifo_write

sync_fifo #(
    .FIFO_DEPTH (1024),
    .DATA_WIDTH ($bits(fifo_data_t))
)
u_sync_fifo (
    .CLK_I      (CLK_I),
    .RST_I      (fifo_rst),
    .WR_EN_I    (fifo_write),
    .WR_DATA_I  (fifo_data_w),
    .FULL_O     (),
    .RD_EN_I    (fifo_read),
    .RD_DATA_O  (fifo_data_r),
    .EMPTY_O    (fifo_empty)
);

always_comb begin : pc_fifo_read
    fifo_read = (checker_st == ST_SEND && AXIS_MST_IF.tready == 1'b1) ? 1'b1 : 1'b0;
end : pc_fifo_read

always_comb begin : pc_axis_mst_if_tvalid
    AXIS_MST_IF.tvalid = (checker_st == ST_SEND && fifo_empty == 1'b0) ? 1'b1 : 1'b0;
end : pc_axis_mst_if_tvalid

always_comb begin : pc_axis_mst_if_out
    AXIS_MST_IF.tdata = (AXIS_MST_IF.tvalid) ? fifo_data_r.tdata : 'x;
    AXIS_MST_IF.tlast = (AXIS_MST_IF.tvalid) ? fifo_data_r.tlast : 'x;
end : pc_axis_mst_if_out

endmodule

`resetall
