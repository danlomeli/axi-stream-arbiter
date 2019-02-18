module eb15_ctrl #(
    parameter S0 = 5'b1_0_10_0,
    parameter S1 = 5'b1_1_01_0,
    parameter S2 = 5'b0_1_00_0,
    parameter S3 = 5'b1_1_10_1,
    parameter S4 = 5'b0_1_00_1
) (
    input  s_valid,
    output s_ready,
    output m_valid,
    input  m_ready,
    output en0, en1, sel,
    input  clk, reset_n
);

// State machine
reg [4:0] state, state_nxt;

always @(posedge clk or negedge reset_n)
    if (~reset_n) state <= S0;
    else          state <= state_nxt;

//  state   d0  d1  s_rdy   m_rdy   en0     en1     sel
//  0       x   x   1       0       s_vld   0       0       1_0_10_0
//  1       0   x   1       1       0       s_vld   0       1_1_01_0
//  2       0   1   0       1       0       0       0       0_1_00_0
//  3       x   0   1       1       s_vld   0       1       1_1_10_1
//  4       1   0   0       1       0       0       1       0_1_00_1

always @*
    casez({state, s_valid, m_ready})
        {S0, 2'b1?} : state_nxt = S1;

        {S1, 2'b01} : state_nxt = S0;
        {S1, 2'b10} : state_nxt = S2;
        {S1, 2'b11} : state_nxt = S3;

        {S2, 2'b?1} : state_nxt = S3;

        {S3, 2'b01} : state_nxt = S0;
        {S3, 2'b10} : state_nxt = S4;
        {S3, 2'b11} : state_nxt = S1;

        {S4, 2'b?1} : state_nxt = S1;
        default       state_nxt = state;
    endcase

assign s_ready = state[4];
assign m_valid = state[3];
assign en0     = state[2] & s_valid;
assign en1     = state[1] & s_valid;
assign sel     = state[0];

endmodule
