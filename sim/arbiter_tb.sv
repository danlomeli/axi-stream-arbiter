`timescale 1 ps / 1 ps
`default_nettype none

module arbiter_tb;

integer fp_a; //file pointer

localparam  ONE_NS      = 1000;
localparam time PERIOD = 5.0*ONE_NS; // 5 ns clock

logic axis_aclk    = 0;
logic axis_aresetn = 1;
// s0a
logic [31:0] s0a_axis_tdata = 0;
logic s0a_axis_tvalid       = 0;
logic s0a_axis_tready;
logic s0a_axis_tlast        = 0;
// s0b
logic [31:0] s0b_axis_tdata = 0;
logic s0b_axis_tvalid       = 0;
logic s0b_axis_tready;
logic s0b_axis_tlast        = 0;
// m0k
logic [31:0] m0k_axis_tdata;
logic m0k_axis_tvalid;
logic  m0k_axis_tready;
logic  m0k_axis_tlast;

logic m0k_axis_a;
logic m0k_axis_b;

logic [31:0] counter1;
logic [31:0] random_ready;
logic [31:0] i_seed = 1;
logic rand_ready = 1;

always
axis_aclk = #(PERIOD/2)~axis_aclk;

// pseudorandom ready
always_ff @(posedge axis_aclk) begin
    random_ready = counter1 % (5 * 32);
end

initial fp_a = $fopen("m0k_axis_tdata.mif","w");

always_ff @(posedge axis_aclk) begin
    m0k_axis_tready <= (rand_ready) ? random_ready[0] : 1;
    if (m0k_axis_tready && m0k_axis_tvalid) begin
        if (m0k_axis_a) $fwrite(fp_a,"a %h %t\n",m0k_axis_tdata, $time);
        if (m0k_axis_b) $fwrite(fp_a,"b %h %t\n",m0k_axis_tdata, $time);
    end
end

task writea(logic [31:0] data, logic tlast);
    s0a_axis_tdata <= data;
    s0a_axis_tlast <= tlast;
    s0a_axis_tvalid <= 1'b1;
    while (1) begin
        @(posedge axis_aclk);
        if (s0a_axis_tready) begin
            break;
        end
    end
    s0a_axis_tvalid <= 1'b0;
endtask

task writeb(logic [31:0] data, logic tlast);
    s0b_axis_tdata <= data;
    s0b_axis_tlast <= tlast;
    s0b_axis_tvalid <= 1'b1;
    while (1) begin
        @(posedge axis_aclk);
        if (s0b_axis_tready) begin
            break;
        end
    end
    s0b_axis_tvalid <= 1'b0;
endtask

task reset_all();
    axis_aresetn    = 0;
    s0a_axis_tdata  = 0;
    s0a_axis_tvalid = 0;
    s0a_axis_tlast  = 0;
    s0b_axis_tdata  = 0;
    s0b_axis_tvalid = 0;
    s0b_axis_tlast  = 0;
endtask

int burst_size = 31;

initial begin 
    fp_a = $fopen("m0k_axis_tdata.mif","w");
    $display($time, " << Starting the Simulation >>");
    @(posedge axis_aclk);
    reset_all();
    repeat(2)@(posedge axis_aclk);
    axis_aresetn = 1'b1;
    repeat(5)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) writea(idx, 1);
        else writea(idx, 0);
    end
    repeat(5)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) writea(idx, 1);
        else writea(idx, 0);
    end
    // $finish;
end

initial begin 
    fp_a = $fopen("m0k_axis_tdata.mif","w");
    $display($time, " << Starting the Simulation >>");
    @(posedge axis_aclk);
    reset_all();
    repeat(2)@(posedge axis_aclk);
    axis_aresetn = 1'b1;
    repeat(6)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) writeb(idx, 1);
        else writeb(idx, 0);
    end
    repeat(10)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) writeb(idx, 1);
        else writeb(idx, 0);
    end
    // $finish;
end


arbiter DUT(.*); //implicit port

// LFSR
typedef enum {
    ST_IDLE,         // switch from here
    PAT1_WORK        // pattern generation using a lfsr
} genfsm_states_t;

genfsm_states_t curr_state;
genfsm_states_t next_state;


// lfsr of 6 bits
logic [5:0] lfsr_pattern;

always_ff @(posedge axis_aclk) begin

    if (~axis_aresetn) begin
        curr_state <= ST_IDLE;
        next_state <= ST_IDLE;
        counter1 <= {32{1'b0}};

        lfsr_pattern <= {1'b1,{5{1'b0}}}; // initializing lfsr by 100000

    end else begin

        counter1 <= {32{1'b0}};


        // next_state
        curr_state <= next_state;

        case (curr_state)

            ST_IDLE: begin
                next_state <= PAT1_WORK;
                counter1 <= i_seed;
            end

            PAT1_WORK: begin

                lfsr_pattern <= {lfsr_pattern[4:0],lfsr_pattern[5]}; //circular shift
                lfsr_pattern[1] <= lfsr_pattern[0] ^ lfsr_pattern[5];

                counter1 <= counter1 + lfsr_pattern;

                end
            endcase

        end // if i_reset
    end // always_ff i_clock

endmodule

`default_nettype wire