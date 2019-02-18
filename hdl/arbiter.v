`timescale 1 ns / 1 ps
`default_nettype none

module arbiter
(
	input  wire          axis_aclk,
	input  wire          axis_aresetn,
	// Ports of Axi Slave Bus Interface S0a_AXIS
	input  wire [31 : 0] s0a_axis_tdata,
	input  wire  		 s0a_axis_tvalid,                             //req
	output wire  		 s0a_axis_tready,                             //ack
	input  wire  		 s0a_axis_tlast,
	// Ports of Axi Slave Bus Interface S0b_AXIS
	input  wire [31 : 0] s0b_axis_tdata,
	input  wire          s0b_axis_tvalid,                             //req
	output wire          s0b_axis_tready,                             //ack
	input  wire          s0b_axis_tlast,
	// Ports of Axi Master Bus Interface M0k_AXIS
	output wire [31 : 0] m0k_axis_tdata,  //done
	output wire          m0k_axis_tvalid, //done                            
	input wire           m0k_axis_tready,                              
	output wire          m0k_axis_tlast
);


wire [31:0] dat0_nxt;
reg  [31:0] dat0;
wire [31:0] dat1_nxt;
reg  [31:0] dat1;

wire en0, sel0, en1, sel1;
// Targets
wire ack0;
wire req0;
// Initiators
wire ack1;
reg req1;
// 
assign en0 = req0 & ack0;
assign ack0 = ~req1 | ack1;
// Regs
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) req1 <= 1'b0; else req1 <= ~ack0 | req0;
always @(posedge axis_aclk) if (en0) dat0 <= dat0_nxt;

// Initiators
assign ack1 = m0k_axis_tready;
assign m0k_axis_tvalid = req1;
assign m0k_axis_tdata = dat0;


// assign dat0_nxt = (sel0) ? s0a_axis_tdata : s0b_axis_tdata;

wire dat0_tlast, dat0_en, dat1_tlast, dat1_en;


elbuf u_elbuf0(
	.clk      (axis_aclk       ),
    .reset_n  (axis_aresetn    ),
    // Targets
    .s0_data  ({s0a_axis_tlast, s0a_axis_tdata}),
    .s0_valid (s0a_axis_tvalid ),
    .s0_ready (s0a_axis_tready ),
    // Initiators
    .m0_data ({dat0_tlast, dat0_nxt}),
    .m0_valid (req0),
    .m0_ready (ack0)
);

assign dat0_en = req0 & ack0;

elbuf u_elbuf1(
	.clk      (axis_aclk       ),
    .reset_n  (axis_aresetn    ),
    // Targets
    .s0_data  ({s0b_axis_tlast, s0b_axis_tdata}),
    .s0_valid (s0b_axis_tvalid ),
    .s0_ready (s0b_axis_tready ),
    // Initiators
    .m0_data ({dat1_tlast, dat1_nxt}),
    .m0_valid (),
    .m0_ready ()
);

// assign dat1_en = req1 & ack1;
assign dat1_en = 0;


parameter S0 = 2'b0_0;
parameter S1 = 2'b1_0;
parameter S2 = 2'b0_1;

reg [1:0] state, state_nxt;
always @(posedge axis_aclk or negedge axis_aresetn) begin
    if (~axis_aresetn) state <= S0;
    else               state <= state_nxt;
end

//  state   d0  d1  en0     en1     en    sel
//  0       x   x   s_vld   0       0     0       0_0
//  1       0   x   0       s_vld   1     0       1_0
//  2       0   1   0       0       1     1       1_1

always @*
    casez({state, dat0_tlast, dat1_tlast, dat0_en, dat1_en})
        {S0, 4'b??1?} : state_nxt = S1;
        {S0, 4'b???1} : state_nxt = S2;
        {S1, 4'b1?1?} : state_nxt = S0;
        {S1, 4'b?1?1} : state_nxt = S0;
        default       state_nxt = state;
    endcase

assign sel1 = state[0];
assign en1 = state[1];

endmodule
`default_nettype wire