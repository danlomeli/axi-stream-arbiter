module elbuf_ctrl (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input              t_0_req,
    output             t_0_ack,
    output             i_1_req,
    input              i_1_ack,
    output             en0_0,
    output             en0_1,
    output             sel0
);
wire             req0, ack0, ack0_0, req0_0;
// node:t_0 target
assign req0 = t_0_req;
assign t_0_ack = ack0;

// edge:0 EB1.5
wire ack0m, req0m;
eb15_ctrl uctrl_0 (
    .t_0_req(req0), .t_0_ack(ack0),
    .i_0_req(req0m), .i_0_ack(ack0m),
    .en0(en0_0), .en1(en0_1), .sel(sel0),
    .clk(clk), .reset_n(reset_n)
);

// edge:0 fork
assign req0_0 = req0m;
assign ack0m = ack0_0;
// node:1 initiator
assign i_1_req = req0_0;
assign ack0_0 = i_1_ack;
endmodule // elbuf_ctrl
