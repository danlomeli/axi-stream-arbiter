onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /arbiter_tb/ONE_NS
add wave -noupdate /arbiter_tb/PERIOD
add wave -noupdate /arbiter_tb/fp_a
add wave -noupdate /arbiter_tb/axis_aclk
add wave -noupdate /arbiter_tb/axis_aresetn
add wave -noupdate /arbiter_tb/s0a_axis_tdata
add wave -noupdate /arbiter_tb/s0a_axis_tvalid
add wave -noupdate /arbiter_tb/s0a_axis_tready
add wave -noupdate /arbiter_tb/s0a_axis_tlast
add wave -noupdate /arbiter_tb/s0b_axis_tdata
add wave -noupdate /arbiter_tb/s0b_axis_tvalid
add wave -noupdate /arbiter_tb/s0b_axis_tready
add wave -noupdate /arbiter_tb/s0b_axis_tlast
add wave -noupdate /arbiter_tb/m0k_axis_tdata
add wave -noupdate /arbiter_tb/m0k_axis_tvalid
add wave -noupdate /arbiter_tb/m0k_axis_tready
add wave -noupdate /arbiter_tb/m0k_axis_tlast
add wave -noupdate /arbiter_tb/m0k_axis_a
add wave -noupdate /arbiter_tb/m0k_axis_b
add wave -noupdate /arbiter_tb/counter1
add wave -noupdate /arbiter_tb/random_ready
add wave -noupdate /arbiter_tb/i_seed
add wave -noupdate /arbiter_tb/rand_ready
add wave -noupdate /arbiter_tb/burst_size
add wave -noupdate /arbiter_tb/curr_state
add wave -noupdate /arbiter_tb/next_state
add wave -noupdate /arbiter_tb/lfsr_pattern
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {557934 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 347
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1193358 ps}
