##################################
# A very simple modelsim do file #
##################################

# 1) Create a library for working in
vlib work

# 2) Compile the half adder
vlog -work work ../hdl/arbiter.v
vlog -sv -work work ../hdl/arbiter_tb.sv

# 3) Load it for simulation
vsim HalfAdder

# 4) Open some selected windows for viewing
view structure
view signals
view wave

# 5) Show some of the signals in the wave window
# add wave -noupdate -divider -height 32 Inputs
# add wave -noupdate a
# add wave -noupdate b
# add wave -noupdate -divider -height 32 Outputs
# add wave -noupdate s
# add wave -noupdate c

# 6) Set some test patterns

# a = 0, b = 0 at 0 ns
# force a 0 0
# force b 0 0

# a = 1, b = 0 at 10 ns
# force a 1 10

# a = 0, b = 1 at 20 ns
# force a 0 20
# force b 1 20

# a = 1, b = 1 at 30 ns
# force a 1 30

# 7) Run the simulation for 40 ns
run 40