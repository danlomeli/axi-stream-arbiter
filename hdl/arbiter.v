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
wire en0, sle0;
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


// assign dat0_nxt = (sle0) ? s0a_axis_tdata : s0b_axis_tdata;

wire dat0_tlast;


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


parameter S0 = 5'b1_0_10_0;

reg [4:0] state, state_nxt;
always @(posedge axis_aclk or negedge axis_aresetn) begin
    if (~axis_aresetn) state <= S0;
    else               state <= state_nxt;
end



endmodule
`default_nettype wire