`timescale 1 ns / 1 ps
`default_nettype none

module arbiter
(
	input  wire          axis_aclk,
	input  wire          axis_aresetn,
	// Ports of Axi Slave Bus Interface S0a_AXIS
	input  wire [31 : 0] s0a_axis_tdata,
	input  wire  		 s0a_axis_tvalid,                             
	output wire  		 s0a_axis_tready,
	input  wire  		 s0a_axis_tlast,
	// Ports of Axi Slave Bus Interface S0b_AXIS
	input  wire [31 : 0] s0b_axis_tdata,
	input  wire          s0b_axis_tvalid,                             
	output wire          s0b_axis_tready,                           
	input  wire          s0b_axis_tlast,
	// Ports of Axi Master Bus Interface M0k_AXIS
	output wire [31 : 0] m0k_axis_tdata,  
	output wire          m0k_axis_tvalid,                            
	input wire           m0k_axis_tready,                              
	output wire          m0k_axis_tlast,

    output wire          m0k_axis_a,
    output wire          m0k_axis_b
);

reg arb;

wire [31:0] dat0, dat1;
wire dat0_last, dat1_last;

wire en, en1, sel1;
// Targets
wire ack0, req0;
// Initiators
wire ack1, req1;

wire s_valid, s_ready;

elbuf u_elbuf0(
	.clk      (axis_aclk       ),
    .reset_n  (axis_aresetn    ),
    // Targets
    .s0_data  ({s0a_axis_tlast, s0a_axis_tdata}),
    .s0_valid (s0a_axis_tvalid ),
    .s0_ready (s0a_axis_tready ),
    // Initiators
    .m0_data ({dat0_last, dat0}),
    .m0_valid (req0),
    .m0_ready (ack0)
);

elbuf u_elbuf1(
	.clk      (axis_aclk       ),
    .reset_n  (axis_aresetn    ),
    // Targets
    .s0_data  ({s0b_axis_tlast, s0b_axis_tdata}),
    .s0_valid (s0b_axis_tvalid ),
    .s0_ready (s0b_axis_tready ),
    // Initiators
    .m0_data ({dat1_last, dat1}),
    .m0_valid (req1),
    .m0_ready (ack1)
);


wire [31:0] dat0_nxt;
wire dat0_nlast, dat0_nreq;

// Muxs
assign dat0_nxt = (arb) ? dat1 : dat0;
assign dat0_nlast = (arb) ? dat1_last: dat0_last;
assign dat0_nreq = (arb) ? req1 : req0;

// Demux 
assign {ack1, ack0} = (arb) ? {s_ready, 1'b0} : {1'b0, s_ready};

parameter S0 = 6'b0_1_0_10_0;
parameter S1 = 6'b0_1_1_01_0;
parameter S2 = 6'b0_0_1_00_0;
parameter S3 = 6'b0_1_1_10_1;
parameter S4 = 6'b0_0_1_00_1;
parameter S5 = 6'b0_0_0_00_0;  //unlocked empty
parameter S6 = 6'b1_0_1_00_0;  //unlocked half-full
parameter S7 = 6'b1_0_1_00_1;  //unlocked half-full

// State machine
reg [5:0] state, state_nxt;

always @(posedge axis_aclk or negedge axis_aresetn)
    if (~axis_aresetn) state <= S5;
    else          state <= state_nxt;

//  state   d0  d1  s_rdy   m_rdy   en0     en1     sel
//  0       x   x   1       0       s_vld   0       0       0_1_0_10_0 #20
//  1       0   x   1       1       0       s_vld   0       0_1_1_01_0 #26
//  2       0   1   0       1       0       0       0       0_0_1_00_0 #8
//  3       x   0   1       1       s_vld   0       1       0_1_1_10_1 #29
//  4       1   0   0       1       0       0       1       0_0_1_00_1 #9
//  5       x   x   0       0       0       0       0       0_0_0_00_0 #0
//  6       x   x   0       1       0       0       0       1_0_1_00_0 #40
//  7       x   x   0       1       0       0       1       1_0_1_00_1 #41

wire unlock, m_ready, m_valid, en0_0, en0_1, sel0;


always @*
    casez({state, unlock, dat0_nreq, m_ready})
        {S0, 3'b?1?} : state_nxt = S1;

        {S1, 3'b001} : state_nxt = S0;
        {S1, 3'b010} : state_nxt = S2;
        {S1, 3'b011} : state_nxt = S3;
        {S1, 3'b1?1} : state_nxt = S7;

        {S2, 3'b0?1} : state_nxt = S3;
        {S2, 3'b1?1} : state_nxt = S5;

        {S3, 3'b001} : state_nxt = S0;
        {S3, 3'b010} : state_nxt = S4;
        {S3, 3'b011} : state_nxt = S1;
        {S3, 3'b1?1} : state_nxt = S6;

        {S4, 3'b??1} : state_nxt = S1;

        {S5, 3'b?1?} : state_nxt = S0;

        {S6, 3'b??1} : state_nxt = S5; 
        {S7, 3'b??1} : state_nxt = S5;

        default       state_nxt = state;
    endcase

// arbiter
reg unlock2;
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) arb <= 1'b0; else if (state_nxt == S5) arb <= ~arb;
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) unlock2 <= 1'b0; else if (state_nxt == S5) unlock2 <= 1'b0; else if (dat0_nlast) unlock2 <= 1'b1;
assign unlock = dat0_nlast | unlock2;

wire dat0_tail;

assign dat0_tail = state[5];
assign s_ready = state[4];
assign m_valid = state[3];
assign en0_0   = state[2] & dat0_nreq;
assign en0_1   = state[1] & dat0_nreq;
assign sel0    = state[0];


reg [31:0] dat0_r0, dat0_r1;
wire [31:0] dat0_r;

always @(posedge axis_aclk) if (en0_0) dat0_r0 <= dat0_nxt;
always @(posedge axis_aclk) if (en0_1) dat0_r1 <= dat0_nxt;

assign dat0_r = sel0 ? dat0_r1 : dat0_r0;

// Initiators
assign m_ready = m0k_axis_tready;
assign m0k_axis_tvalid = m_valid;
assign m0k_axis_tdata = dat0_r;
assign m0k_axis_tlast = dat0_tail;
assign m0k_axis_a = ~arb;
assign m0k_axis_b = arb;

endmodule
`default_nettype wire