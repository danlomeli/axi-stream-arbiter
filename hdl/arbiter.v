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
	output wire          m0k_axis_tlast
);


wire [31:0] dat0_nxt, dat1_nxt;
wire dat0_tlast, dat0_en, dat1_tlast, dat1_en;
reg  [31:0] dat0, dat1;

wire en, en1, sel1;
// Targets
wire ack0, req0;
// Initiators
wire ack1, req1;

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
    .m0_valid (req1),
    .m0_ready (ack1)
);

assign dat1_en = req1 & ack1;

parameter S0 = 2'b0_0;
parameter S1 = 2'b1_0;
parameter S2 = 2'b0_1;

reg [1:0] state, state_nxt;
always @(posedge axis_aclk or negedge axis_aresetn) begin
    if (~axis_aresetn) state <= S0;
    else               state <= state_nxt;
end

//  state   d0  d1  en0     en1     en    sel
//  0       x   x   1       0       0     0       0_0
//  1       1   0   0       1       1     0       1_0
//  2       0   1   0       0       1     1       1_1

always @*
    casez({state, dat0_tlast, dat1_tlast, dat0_en, dat1_en})
        {S0, 4'b??1?} : state_nxt = S1;
        {S0, 4'b???1} : state_nxt = S2;
        {S1, 4'b1?1?} : state_nxt = S0;
        {S2, 4'b?1?1} : state_nxt = S0;
        default       state_nxt = state;
    endcase

assign sel1 = state[0];
assign en1 = state[1];

reg ireq, ilast, ack;
wire slast, tack, iack, treq;
wire [31:0] tdata;
reg [31:0] idata;

// Muxs
assign tdata = (sel1) ? dat1_nxt : dat0_nxt;
assign slast = (sel1) ? dat1_tlast : dat0_tlast;
assign treq = (sel1) ? req1 : req0;

// Demux
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) ack <= 1'b0; else if (state_nxt == S0) ack <= ~ack;
assign ack0 = ~ack;
assign ack1 = ack;

// Regs
assign en = treq & tack;
assign tack = ~ireq | iack;
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) ireq <= 1'b0; else ireq <= ~tack | treq;
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) ilast <= 1'b0; else if (en) ilast <= slast; else ilast <= 1'b0;
always @(posedge axis_aclk) if (en) idata <= tdata;

// Initiators
assign iack = m0k_axis_tready;
assign m0k_axis_tvalid = ireq;
assign m0k_axis_tdata = idata;
assign m0k_axis_tlast = ilast;

endmodule
`default_nettype wire