create_clock -period 20.00 -name clk [get_ports clk]

derive_pll_clocks
derive_clock_uncertainty