module elbuf (
    input              clk,
    input              reset_n,
    input       [32:0] s0_data,
    input              s0_valid,
    output             s0_ready,
    output      [32:0] m0_data,
    output             m0_valid,
    input              m0_ready
);
wire      [32:0] dat0, dat0_nxt;
// per node
assign dat0_nxt = s0_data; 
assign m0_data = dat0; 

wire en0_0, en0_1, sel0;
reg [32:0] dat0_r0, dat0_r1;
always @(posedge clk) if (en0_0) dat0_r0 <= dat0_nxt;
always @(posedge clk) if (en0_1) dat0_r1 <= dat0_nxt;

assign dat0 = sel0 ? dat0_r1 : dat0_r0;

elbuf_ctrl u_elbuf_ctrl(
	.clk      (clk      ),
    .reset_n  (reset_n  ),
    .s0_valid (s0_valid ),
    .s0_ready (s0_ready ),
    .m0_valid (m0_valid ),
    .m0_ready (m0_ready ),
    .en0_0    (en0_0    ),
    .en0_1    (en0_1    ),
    .sel0     (sel0     )
);

endmodule
