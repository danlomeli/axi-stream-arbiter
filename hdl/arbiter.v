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


reg [31:0] dat0_nxt, m0k_data1;
wire en0, sle0;

wire m0k_r1;
reg m0k_v1;
wire s0m_r1;
reg s0m_v1;

assign en0 = s0m_v1 & s0m_r1;
assign s0m_r1 = ~m0k_v1 | m0k_r1;
always @(posedge axis_aclk or negedge axis_aresetn) if (~axis_aresetn) m0k_v1 <= 1'b0; else m0k_v1 <= ~s0m_r1 | s0m_v1;

always @(posedge axis_aclk) if (en0) m0k_data1 <= dat0_nxt;

// Master
assign m0k_r1 = m0k_axis_tready;
assign m0k_axis_tvalid = m0k_v1;
assign m0k_axis_tdata = m0k_data1;


assign dat0_nxt = (sle0) ? s0a_axis_tdata : s0b_axis_tdata;


// Now assign s0m_data1, s0m_v1 the correct values.

parameter  IDLE  = 3'b000,
           READA = 3'b010,
           READB = 3'b100;

reg [2:0] state, next;
always @(posedge axis_aclk or negedge axis_aresetn) begin
    if (~axis_aresetn) state <= IDLE;
    else               state <= next;
end
 
always @* begin
    case (state)
    IDLE : begin
        next = IDLE;
        if (s0a_axis_tvalid & s0a_axis_tready) next = READA;
        if (s0b_axis_tvalid & s0b_axis_tready) next = READB;
    end
    READA : if (s0a_axis_tlast) next = IDLE;
    READB : if (s0b_axis_tlast) next = IDLE;
    default : next = IDLE;
    endcase
end

endmodule
`default_nettype wire