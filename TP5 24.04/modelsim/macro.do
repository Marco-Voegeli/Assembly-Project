restart
force A 11110000
force B 11110000
force C 00000000
force start 1
force sel 1
force reset_n 0 0, 1 5
force clk 1 10, 0 20 -repeat 20
run