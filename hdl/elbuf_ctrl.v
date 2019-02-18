`default_nettype none

module elbuf_ctrl (
    // per node (target / initiator)
    input   wire           clk,
    input   wire           reset_n,
    input   wire           s0_valid,
    output  wire           s0_ready,
    output  wire           m0_valid,
    input   wire           m0_ready,
    output  wire           en0_0,
    output  wire           en0_1,
    output  wire           sel0
);
wire             req0, ack0, ack0_0, req0_0;
// target
assign req0 = s0_valid;
assign s0_ready = ack0;

wire ack0m, req0m;

eb15_ctrl u_eb15_ctrl(
	.s_valid (req0 ),
    .s_ready (ack0 ),
    .m_valid (req0m ),
    .m_ready (ack0m ),
    .en0     (en0_0 ),
    .en1     (en0_1 ),
    .sel     (sel0  ),
    .clk     (clk   ),
    .reset_n (reset_n )
);

assign req0_0 = req0m;
assign ack0m = ack0_0;
// initiator
assign m0_valid = req0_0;
assign ack0_0 = m0_ready;
endmodule // elbuf_ctrl

`default_nettype wire
