restart
force reset_n 0 0, 1 5
force pipeline_clk 0 5
force Button1 1 20, 0 25
force Button0 1 10, 0 15
force clk 1 0, 0 10 -repeat 20
force pipeline_clk 1 0, 0 10 -repeat 20
run