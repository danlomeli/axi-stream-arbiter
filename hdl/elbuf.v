module elbuf (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input       [31:0] t_0_dat,
    input              t_0_req,
    output             t_0_ack,
    output      [31:0] i_1_dat,
    output             i_1_req,
    input              i_1_ack
);
wire      [31:0] dat0, dat0_nxt;
// per node
assign dat0_nxt = t_0_dat; // node:0 is target port
assign i_1_dat = dat0; // node:1 is initiator port

wire en0_0, en0_1, sel0;
reg [31:0] dat0_r0, dat0_r1;
always @(posedge clk) if (en0_0) dat0_r0 <= dat0_nxt;
always @(posedge clk) if (en0_1) dat0_r1 <= dat0_nxt;

assign dat0 = sel0 ? dat0_r1 : dat0_r0;

elbuf_ctrl uctrl (
    .clk(clk),
    .reset_n(reset_n),
    .t_0_req(t_0_req),
    .t_0_ack(t_0_ack),
    .i_1_req(i_1_req),
    .i_1_ack(i_1_ack),
    .en0_0(en0_0),
    .en0_1(en0_1),
    .sel0(sel0)
);
endmodule // elbuf
