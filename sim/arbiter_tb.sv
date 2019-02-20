`timescale 1 ps / 1 ps
`default_nettype none

module arbiter_tb;

localparam  ONE_NS      = 1000;
localparam time PERIOD = 5.0*ONE_NS; // 5 ns clock

reg axis_aclk    = 0;
reg axis_aresetn = 1;
// s0a
reg [31:0] s0a_axis_tdata = 0;
reg s0a_axis_tvalid       = 0;
wire s0a_axis_tready;
reg s0a_axis_tlast        = 0;
// s0b
reg [31:0] s0b_axis_tdata = 0;
reg s0b_axis_tvalid       = 0;
wire s0b_axis_tready;
reg s0b_axis_tlast        = 0;
// m0k
wire [31:0] m0k_axis_tdata;
wire m0k_axis_tvalid;
reg m0k_axis_tready = 1;
reg m0k_axis_tlast;

wire m0k_axis_a;
wire m0k_axis_b;

always
axis_aclk = #(PERIOD/2)~axis_aclk;

task write(reg [31:0] data, reg tlast);
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

task reset_all();
    axis_aresetn    = 0;
    s0a_axis_tdata  = 0;
    s0a_axis_tvalid = 0;
    s0a_axis_tlast  = 0;
    s0b_axis_tdata  = 0;
    s0b_axis_tvalid = 0;
    s0b_axis_tlast  = 0;
endtask

int burst_size = 10;

initial begin 
    $display($time, " << Starting the Simulation >>");
    @(posedge axis_aclk);
    reset_all();
    repeat(2)@(posedge axis_aclk);
    axis_aresetn = 1'b1;
    repeat(5)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) write(idx, 1);
        else write(idx, 0);
    end
    repeat(5)@(posedge axis_aclk);
    for (int idx = 1; idx <= burst_size; idx++) begin
        if (idx == burst_size) write(idx, 1);
        else write(idx, 0);
    end
    // $finish;
end

arbiter DUT(.*); //implicit port


endmodule

`default_nettype wire