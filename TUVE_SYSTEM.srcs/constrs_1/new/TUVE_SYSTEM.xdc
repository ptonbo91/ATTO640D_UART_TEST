set_property IOSTANDARD  LVDS_25 [get_ports {mipi_phy_if_clk_hs_p}]

set_property IOSTANDARD  LVDS_25 [get_ports {mipi_phy_if_clk_hs_n}]

set_property IOSTANDARD  LVDS_25 [get_ports {mipi_phy_if_data_hs_p}]

set_property IOSTANDARD  LVDS_25 [get_ports {mipi_phy_if_data_hs_n}]

set_property IOSTANDARD LVCMOS25 [get_ports {mipi_phy_if_clk_lp_p}]

set_property IOSTANDARD LVCMOS25 [get_ports {mipi_phy_if_clk_lp_n}]

set_property IOSTANDARD LVCMOS25 [get_ports {mipi_phy_if_data_lp_p}]

set_property IOSTANDARD LVCMOS25 [get_ports {mipi_phy_if_data_lp_n}]

#mipi out pins configuration
set_property PACKAGE_PIN C9  [get_ports {mipi_phy_if_clk_hs_p}]
set_property PACKAGE_PIN B9  [get_ports {mipi_phy_if_clk_hs_n}]
set_property PACKAGE_PIN B8  [get_ports {mipi_phy_if_data_hs_p}]
set_property PACKAGE_PIN A8  [get_ports {mipi_phy_if_data_hs_n}]
set_property PACKAGE_PIN C11 [get_ports {mipi_phy_if_clk_lp_p}]
set_property PACKAGE_PIN C10 [get_ports {mipi_phy_if_clk_lp_n}]
set_property PACKAGE_PIN A10 [get_ports {mipi_phy_if_data_lp_p}]
set_property PACKAGE_PIN A9  [get_ports {mipi_phy_if_data_lp_n}]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO8]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO8]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO8]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO9]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO9]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO9]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO10]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO10]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO10]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO11]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO11]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO11]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO12]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO12]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO12]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO13]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO13]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO13]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO14]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO14]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO14]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO15]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO15]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO15]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO_VSYNC]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO_VSYNC]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO_VSYNC]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_PVO_HSYNC]
set_property DRIVE 12 [get_ports FPGA_B2B_M_PVO_HSYNC]
set_property SLEW SLOW [get_ports FPGA_B2B_M_PVO_HSYNC]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SPI_DQ0]
set_property DRIVE 12 [get_ports FPGA_SPI_DQ0]
set_property SLEW SLOW [get_ports FPGA_SPI_DQ0]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SPI_DQ1]
set_property DRIVE 12 [get_ports FPGA_SPI_DQ1]
set_property SLEW SLOW [get_ports FPGA_SPI_DQ1]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SPI_DQ2]
set_property DRIVE 12 [get_ports FPGA_SPI_DQ2]
set_property SLEW SLOW [get_ports FPGA_SPI_DQ2]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SPI_DQ3]
set_property DRIVE 12 [get_ports FPGA_SPI_DQ3]
set_property SLEW SLOW [get_ports FPGA_SPI_DQ3]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SPI_CS]
set_property DRIVE 12 [get_ports FPGA_SPI_CS]
set_property SLEW SLOW [get_ports FPGA_SPI_CS]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_CKE]
set_property DRIVE 12 [get_ports FPGA_SDRAM_CKE]
set_property SLEW SLOW [get_ports FPGA_SDRAM_CKE]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_CS_N]
set_property DRIVE 12 [get_ports FPGA_SDRAM_CS_N]
set_property SLEW SLOW [get_ports FPGA_SDRAM_CS_N]


set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[0]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[0]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[1]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[1]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[2]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[2]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[3]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[3]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_DQM[0]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_DQM[0]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_DQM[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[4]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[4]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[5]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[5]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[6]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[6]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[7]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[7]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_RAS_N]
set_property DRIVE 12 [get_ports FPGA_SDRAM_RAS_N]
set_property SLEW SLOW [get_ports FPGA_SDRAM_RAS_N]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_CAS_N]
set_property DRIVE 12 [get_ports FPGA_SDRAM_CAS_N]
set_property SLEW SLOW [get_ports FPGA_SDRAM_CAS_N]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_WE_N]
set_property DRIVE 12 [get_ports FPGA_SDRAM_WE_N]
set_property SLEW SLOW [get_ports FPGA_SDRAM_WE_N]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[0]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[0]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[1]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[1]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[2]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[2]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[3]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[3]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[4]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[4]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[5]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[5]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[6]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[6]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[7]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[7]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[8]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[8]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[8]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[9]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[9]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[9]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[10]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[10]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[10]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[11]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[11]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[11]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[12]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[12]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[12]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_A[13]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_A[13]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_A[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[16]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[16]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[16]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[17]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[17]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[17]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[18]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[18]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[18]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[19]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[19]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[19]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_DQM[2]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_DQM[2]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_DQM[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[20]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[20]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[20]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[21]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[21]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[21]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[22]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[22]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[22]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[23]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[23]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[23]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_BA[0]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_BA[0]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_BA[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_BA[1]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_BA[1]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_BA[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[0]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[0]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[5]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[5]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[6]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[6]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[7]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[7]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[1]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[1]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[4]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[4]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[2]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[2]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_DAC_P[3]}]
set_property DRIVE 12 [get_ports {FPGA_DAC_P[3]}]
set_property SLEW SLOW [get_ports {FPGA_DAC_P[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_DAC_CLK]
set_property DRIVE 12 [get_ports FPGA_DAC_CLK]
set_property SLEW SLOW [get_ports FPGA_DAC_CLK]


set_property IOSTANDARD LVCMOS18 [get_ports FPGA_I2C1_SCL]
set_property DRIVE 12 [get_ports FPGA_I2C1_SCL]
set_property SLEW SLOW [get_ports FPGA_I2C1_SCL]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_I2C1_SDA]
set_property DRIVE 12 [get_ports FPGA_I2C1_SDA]
set_property SLEW SLOW [get_ports FPGA_I2C1_SDA]

set_property IOSTANDARD LVCMOS18 [get_ports DAC_RESET]
set_property DRIVE 12 [get_ports DAC_RESET]
set_property SLEW SLOW [get_ports DAC_RESET]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_DAC_SFL]
set_property DRIVE 12 [get_ports FPGA_DAC_SFL]
set_property SLEW SLOW [get_ports FPGA_DAC_SFL]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_DAC_VSYNC]
set_property DRIVE 12 [get_ports FPGA_DAC_VSYNC]
set_property SLEW SLOW [get_ports FPGA_DAC_VSYNC]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_DAC_HSYNC]
set_property DRIVE 12 [get_ports FPGA_DAC_HSYNC]
set_property SLEW SLOW [get_ports FPGA_DAC_HSYNC]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_27MHz_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports DAC_FILTER_DIS]
set_property DRIVE 12 [get_ports DAC_FILTER_DIS]
set_property SLEW SLOW [get_ports DAC_FILTER_DIS]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[24]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[24]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[24]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[25]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[25]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[25]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[27]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[27]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[27]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_DQM[3]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_DQM[3]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_DQM[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[28]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[28]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[28]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[29]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[29]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[29]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[30]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[30]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[30]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[31]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[31]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[31]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[26]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[26]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[26]}]


set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[8]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[8]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[8]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[9]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[9]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[9]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[10]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[10]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[10]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[11]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[11]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[11]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_DQM[1]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_DQM[1]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_DQM[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_SDRAM_CLK]
set_property DRIVE 12 [get_ports FPGA_SDRAM_CLK]
set_property SLEW SLOW [get_ports FPGA_SDRAM_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[12]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[12]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[12]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[13]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[13]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[14]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[14]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[14]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_SDRAM_D[15]}]
set_property DRIVE 12 [get_ports {FPGA_SDRAM_D[15]}]
set_property SLEW SLOW [get_ports {FPGA_SDRAM_D[15]}]


set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[0]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[0]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[1]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[1]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[2]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[2]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[3]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[3]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[4]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[4]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[5]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[5]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[6]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[6]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {FPGA_B2B_M_BT656_D[7]}]
set_property DRIVE 12 [get_ports {FPGA_B2B_M_BT656_D[7]}]
set_property SLEW SLOW [get_ports {FPGA_B2B_M_BT656_D[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_BT656_CLK]
set_property DRIVE 12 [get_ports FPGA_B2B_M_BT656_CLK]
set_property SLEW SLOW [get_ports FPGA_B2B_M_BT656_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_I2C2_SCL]
set_property DRIVE 12 [get_ports FPGA_B2B_M_I2C2_SCL]
set_property SLEW SLOW [get_ports FPGA_B2B_M_I2C2_SCL]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_I2C2_SDA]
set_property DRIVE 12 [get_ports FPGA_B2B_M_I2C2_SDA]
set_property SLEW SLOW [get_ports FPGA_B2B_M_I2C2_SDA]


set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_DAT0]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_DAT1]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_DAT2]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_DAT3]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_SDCD]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_CMD]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_SD_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_GPIO1]
set_property DRIVE 12 [get_ports FPGA_B2B_M_GPIO1]
set_property SLEW SLOW [get_ports FPGA_B2B_M_GPIO1]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_GPIO2]
set_property DRIVE 12 [get_ports FPGA_B2B_M_GPIO2]
set_property SLEW SLOW [get_ports FPGA_B2B_M_GPIO2]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_GPIO3]
set_property DRIVE 12 [get_ports FPGA_B2B_M_GPIO3]
set_property SLEW SLOW [get_ports FPGA_B2B_M_GPIO3]

set_property PACKAGE_PIN F1 [get_ports FPGA_B2B_M_I2C2_SCL]
set_property PACKAGE_PIN E1 [get_ports FPGA_B2B_M_I2C2_SDA]

set_property PACKAGE_PIN B18 [get_ports DAC_FILTER_DIS]
set_property PACKAGE_PIN F14 [get_ports DAC_RESET]
set_property PACKAGE_PIN E15 [get_ports FPGA_27MHz_CLK]
set_property PACKAGE_PIN D5 [get_ports FPGA_B2B_M_BT656_CLK]
set_property PACKAGE_PIN B7 [get_ports {FPGA_B2B_M_BT656_D[0]}]
set_property PACKAGE_PIN B6 [get_ports {FPGA_B2B_M_BT656_D[1]}]
set_property PACKAGE_PIN A6 [get_ports {FPGA_B2B_M_BT656_D[2]}]
set_property PACKAGE_PIN A5 [get_ports {FPGA_B2B_M_BT656_D[3]}]
set_property PACKAGE_PIN D8 [get_ports {FPGA_B2B_M_BT656_D[4]}]
set_property PACKAGE_PIN C7 [get_ports {FPGA_B2B_M_BT656_D[5]}]
set_property PACKAGE_PIN E6 [get_ports {FPGA_B2B_M_BT656_D[6]}]
set_property PACKAGE_PIN E5 [get_ports {FPGA_B2B_M_BT656_D[7]}]

#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[0]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[1]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[2]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[3]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[4]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[5]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[6]}]
#set_property PULLUP TRUE [get_ports {FPGA_B2B_M_BT656_D[7]}]


set_property PACKAGE_PIN G6 [get_ports FPGA_B2B_M_SD_DAT0]
#set_property PACKAGE_PIN F6 [get_ports FPGA_B2B_M_SD_DAT1]
set_property PACKAGE_PIN J4 [get_ports FPGA_B2B_M_SD_DAT1]
set_property PACKAGE_PIN G4 [get_ports FPGA_B2B_M_SD_DAT2]
set_property PACKAGE_PIN G3 [get_ports FPGA_B2B_M_SD_DAT3]
#set_property PACKAGE_PIN J4 [get_ports FPGA_B2B_M_SD_SDCD]
set_property PACKAGE_PIN F6 [get_ports FPGA_B2B_M_SD_SDCD]
set_property PACKAGE_PIN J3 [get_ports FPGA_B2B_M_SD_CMD]
set_property PACKAGE_PIN H4 [get_ports FPGA_B2B_M_SD_CLK]

#set_property PULLUP true [get_ports FPGA_B2B_M_SD_DAT0]
set_property PULLUP true [get_ports FPGA_B2B_M_SD_DAT1]
set_property PULLUP true [get_ports FPGA_B2B_M_SD_DAT2]
set_property PULLUP true [get_ports FPGA_B2B_M_SD_DAT3]
set_property PULLUP true [get_ports FPGA_B2B_M_SD_SDCD]

set_property PACKAGE_PIN F4 [get_ports FPGA_B2B_M_GPIO1]
set_property PACKAGE_PIN F3 [get_ports FPGA_B2B_M_GPIO2]
set_property PACKAGE_PIN E2 [get_ports FPGA_B2B_M_GPIO3]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets FPGA_B2B_M_GPIO1_IBUF[0]]

#set_property PULLDOWN TRUE [get_ports FPGA_B2B_M_GPIO3]


set_property PACKAGE_PIN C12 [get_ports FPGA_DAC_CLK]

set_property PACKAGE_PIN F13 [get_ports {FPGA_DAC_P[0]}]
set_property PACKAGE_PIN D14 [get_ports {FPGA_DAC_P[1]}]
set_property PACKAGE_PIN B14 [get_ports {FPGA_DAC_P[2]}]
set_property PACKAGE_PIN C14 [get_ports {FPGA_DAC_P[3]}]
set_property PACKAGE_PIN A11 [get_ports {FPGA_DAC_P[4]}]
set_property PACKAGE_PIN B13 [get_ports {FPGA_DAC_P[5]}]
set_property PACKAGE_PIN B11 [get_ports {FPGA_DAC_P[6]}]
set_property PACKAGE_PIN B12 [get_ports {FPGA_DAC_P[7]}]
set_property PACKAGE_PIN A15 [get_ports FPGA_DAC_SFL]
set_property PACKAGE_PIN B16 [get_ports FPGA_DAC_VSYNC]
set_property PACKAGE_PIN B17 [get_ports FPGA_DAC_HSYNC]

set_property PACKAGE_PIN D12 [get_ports FPGA_I2C1_SCL]
set_property PACKAGE_PIN D13 [get_ports FPGA_I2C1_SDA]

set_property PACKAGE_PIN P15 [get_ports {FPGA_SDRAM_A[0]}]
set_property PACKAGE_PIN R15 [get_ports {FPGA_SDRAM_A[1]}]
set_property PACKAGE_PIN U16 [get_ports {FPGA_SDRAM_A[10]}]
set_property PACKAGE_PIN V17 [get_ports {FPGA_SDRAM_A[11]}]
set_property PACKAGE_PIN T11 [get_ports {FPGA_SDRAM_A[12]}]
set_property PACKAGE_PIN U11 [get_ports {FPGA_SDRAM_A[13]}]
set_property PACKAGE_PIN T14 [get_ports {FPGA_SDRAM_A[2]}]
set_property PACKAGE_PIN T15 [get_ports {FPGA_SDRAM_A[3]}]
set_property PACKAGE_PIN R16 [get_ports {FPGA_SDRAM_A[4]}]
set_property PACKAGE_PIN T16 [get_ports {FPGA_SDRAM_A[5]}]
set_property PACKAGE_PIN V15 [get_ports {FPGA_SDRAM_A[6]}]
set_property PACKAGE_PIN V16 [get_ports {FPGA_SDRAM_A[7]}]
set_property PACKAGE_PIN U17 [get_ports {FPGA_SDRAM_A[8]}]
set_property PACKAGE_PIN U18 [get_ports {FPGA_SDRAM_A[9]}]
set_property PACKAGE_PIN T10 [get_ports {FPGA_SDRAM_BA[0]}]
set_property PACKAGE_PIN R10 [get_ports {FPGA_SDRAM_BA[1]}]
set_property PACKAGE_PIN P17 [get_ports FPGA_SDRAM_CAS_N]
set_property PACKAGE_PIN R12 [get_ports FPGA_SDRAM_CKE]
set_property PACKAGE_PIN E16 [get_ports FPGA_SDRAM_CLK]
set_property PACKAGE_PIN R13 [get_ports FPGA_SDRAM_CS_N]
set_property PACKAGE_PIN R18 [get_ports {FPGA_SDRAM_D[0]}]
set_property PACKAGE_PIN T18 [get_ports {FPGA_SDRAM_D[1]}]
set_property PACKAGE_PIN C16 [get_ports {FPGA_SDRAM_D[10]}]
set_property PACKAGE_PIN C17 [get_ports {FPGA_SDRAM_D[11]}]
set_property PACKAGE_PIN G18 [get_ports {FPGA_SDRAM_D[12]}]
set_property PACKAGE_PIN F18 [get_ports {FPGA_SDRAM_D[13]}]
set_property PACKAGE_PIN J17 [get_ports {FPGA_SDRAM_D[14]}]
set_property PACKAGE_PIN J18 [get_ports {FPGA_SDRAM_D[15]}]
set_property PACKAGE_PIN U12 [get_ports {FPGA_SDRAM_D[16]}]
set_property PACKAGE_PIN V12 [get_ports {FPGA_SDRAM_D[17]}]
set_property PACKAGE_PIN V10 [get_ports {FPGA_SDRAM_D[18]}]
set_property PACKAGE_PIN V11 [get_ports {FPGA_SDRAM_D[19]}]
set_property PACKAGE_PIN N14 [get_ports {FPGA_SDRAM_D[2]}]
set_property PACKAGE_PIN V14 [get_ports {FPGA_SDRAM_D[20]}]
set_property PACKAGE_PIN T13 [get_ports {FPGA_SDRAM_D[21]}]
set_property PACKAGE_PIN U13 [get_ports {FPGA_SDRAM_D[22]}]
set_property PACKAGE_PIN T9 [get_ports {FPGA_SDRAM_D[23]}]
set_property PACKAGE_PIN H16 [get_ports {FPGA_SDRAM_D[24]}]
set_property PACKAGE_PIN G16 [get_ports {FPGA_SDRAM_D[25]}]
set_property PACKAGE_PIN F15 [get_ports {FPGA_SDRAM_D[26]}]
set_property PACKAGE_PIN F16 [get_ports {FPGA_SDRAM_D[27]}]
set_property PACKAGE_PIN G14 [get_ports {FPGA_SDRAM_D[28]}]
set_property PACKAGE_PIN E17 [get_ports {FPGA_SDRAM_D[29]}]
set_property PACKAGE_PIN P14 [get_ports {FPGA_SDRAM_D[3]}]
set_property PACKAGE_PIN D17 [get_ports {FPGA_SDRAM_D[30]}]
set_property PACKAGE_PIN K13 [get_ports {FPGA_SDRAM_D[31]}]
set_property PACKAGE_PIN P18 [get_ports {FPGA_SDRAM_D[4]}]
set_property PACKAGE_PIN M16 [get_ports {FPGA_SDRAM_D[5]}]
set_property PACKAGE_PIN M17 [get_ports {FPGA_SDRAM_D[6]}]
set_property PACKAGE_PIN N15 [get_ports {FPGA_SDRAM_D[7]}]
set_property PACKAGE_PIN J14 [get_ports {FPGA_SDRAM_D[8]}]
set_property PACKAGE_PIN H15 [get_ports {FPGA_SDRAM_D[9]}]
set_property PACKAGE_PIN N17 [get_ports {FPGA_SDRAM_DQM[0]}]
set_property PACKAGE_PIN E18 [get_ports {FPGA_SDRAM_DQM[1]}]
set_property PACKAGE_PIN U14 [get_ports {FPGA_SDRAM_DQM[2]}]
set_property PACKAGE_PIN H14 [get_ports {FPGA_SDRAM_DQM[3]}]
set_property PACKAGE_PIN N16 [get_ports FPGA_SDRAM_RAS_N]
set_property PACKAGE_PIN R17 [get_ports FPGA_SDRAM_WE_N]


#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_BIT0_1]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_BIT2_3]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_BIT4_5]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_BIT6_7]

##set_property IOSTANDARD LVCMOS33 [get_ports {SNSR_FPGA_DATA[4]}]

##set_property IOSTANDARD LVCMOS33 [get_ports {SNSR_FPGA_DATA[5]}]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT0_1]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT2_3]

##set_property IOSTANDARD LVCMOS33 [get_ports SNSR_FPGA_NRST_SPI_CS]
##set_property DRIVE 12 [get_ports SNSR_FPGA_NRST_SPI_CS]
##set_property SLEW SLOW [get_ports SNSR_FPGA_NRST_SPI_CS]

##set_property IOSTANDARD LVCMOS33 [get_ports SNSR_FPGA_SEQTRIG]
##set_property DRIVE 12 [get_ports SNSR_FPGA_SEQTRIG]
##set_property SLEW SLOW [get_ports SNSR_FPGA_SEQTRIG]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_PIXCLKIN]
#set_property DRIVE 12 [get_ports SNSR_PIXCLKIN]
#set_property SLEW SLOW [get_ports SNSR_PIXCLKIN]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_SSC]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FB0_1]

##set_property IOSTANDARD LVCMOS33 [get_ports SNSR_FPGA_FRAMEVALID]

##set_property IOSTANDARD LVCMOS33 [get_ports SNSR_FPGA_RFU]


#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT4_5]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT6_7]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT8_9]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT10_11]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_OUT12_13]

#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_RX_BNO_TX]
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TX_BNO_RX]
#set_property IOSTANDARD LVCMOS33 [get_ports BNO_RST]
#set_property IOSTANDARD LVCMOS33 [get_ports BNO_INT]
#set_property IOSTANDARD LVCMOS33 [get_ports BNO_PS1]
#set_property IOSTANDARD LVCMOS33 [get_ports BNO_PS0]

##set_property IOSTANDARD LVCMOS33 [get_ports {SNSR_FPGA_DATA[13]}]

##set_property IOSTANDARD LVCMOS33 [get_ports {SNSR_FPGA_DATA[14]}]

##set_property IOSTANDARD LVCMOS33 [get_ports {SNSR_FPGA_DATA[15]}]



#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_CMD0_1]
#set_property DRIVE 12 [get_ports SNSR_CMD0_1]
#set_property SLEW SLOW [get_ports SNSR_CMD0_1]

#set_property IOSTANDARD LVCMOS18 [get_ports SNSR_CMD2_3]
#set_property DRIVE 12 [get_ports SNSR_CMD2_3]
#set_property SLEW SLOW [get_ports SNSR_CMD2_3]

#set_property PACKAGE_PIN L1 [get_ports SNSR_BIT0_1]
#set_property PACKAGE_PIN M1 [get_ports SNSR_BIT2_3]
#set_property PACKAGE_PIN R1 [get_ports SNSR_OUT8_9]
#set_property PACKAGE_PIN T1 [get_ports SNSR_OUT10_11]
#set_property PACKAGE_PIN M6 [get_ports SNSR_OUT12_13]

#set_property PACKAGE_PIN N6 [get_ports FPGA_RX_BNO_TX]
#set_property PACKAGE_PIN R6 [get_ports FPGA_TX_BNO_RX]
#set_property PACKAGE_PIN R5 [get_ports BNO_RST]
#set_property PACKAGE_PIN U4 [get_ports BNO_INT]
#set_property PACKAGE_PIN V1 [get_ports BNO_PS1]
#set_property PACKAGE_PIN K5 [get_ports BNO_PS0]

##set_property PACKAGE_PIN N6 [get_ports {SNSR_FPGA_DATA[13]}]
##set_property PACKAGE_PIN R6 [get_ports {SNSR_FPGA_DATA[14]}]
##set_property PACKAGE_PIN R5 [get_ports {SNSR_FPGA_DATA[15]}]
#set_property PACKAGE_PIN K3 [get_ports SNSR_BIT4_5]
#set_property PACKAGE_PIN L3 [get_ports SNSR_BIT6_7]
##set_property PACKAGE_PIN N2 [get_ports {SNSR_FPGA_DATA[4]}]
##set_property PACKAGE_PIN N1 [get_ports {SNSR_FPGA_DATA[5]}]
#set_property PACKAGE_PIN M3 [get_ports SNSR_OUT0_1]
#set_property PACKAGE_PIN M2 [get_ports SNSR_OUT2_3]
#set_property PACKAGE_PIN M4 [get_ports SNSR_OUT4_5]
#set_property PACKAGE_PIN N4 [get_ports SNSR_OUT6_7]
##set_property PACKAGE_PIN N4 [get_ports {SNSR_FPGA_DATA[9]}]
##set_property PACKAGE_PIN V1 [get_ports SNSR_FPGA_FRAMEVALID]
#set_property PACKAGE_PIN N5 [get_ports SNSR_CMD0_1]
#set_property PACKAGE_PIN P5 [get_ports SNSR_CMD2_3]
#set_property PACKAGE_PIN U1 [get_ports SNSR_FB0_1]
#set_property PACKAGE_PIN T5 [get_ports SNSR_PIXCLKIN]
##set_property PACKAGE_PIN K5 [get_ports SNSR_FPGA_NRST_SPI_CS]
#set_property PACKAGE_PIN T3 [get_ports SNSR_SSC]
##set_property PACKAGE_PIN U4 [get_ports SNSR_SSC]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SNSR_SSC_IBUF]
#set_property PACKAGE_PIN L4 [get_ports SNSR_FPGA_SEQTRIG]


set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_NRST_SPI_CS]
set_property DRIVE 12 [get_ports SNSR_FPGA_NRST_SPI_CS]
set_property SLEW SLOW [get_ports SNSR_FPGA_NRST_SPI_CS]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_SEQTRIG]
set_property DRIVE 12 [get_ports SNSR_FPGA_SEQTRIG]
set_property SLEW SLOW [get_ports SNSR_FPGA_SEQTRIG]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_MASTER_CLK]
set_property DRIVE 12 [get_ports SNSR_FPGA_MASTER_CLK]
set_property SLEW SLOW [get_ports SNSR_FPGA_MASTER_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_PIXEL_CLK]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_LINEVALID]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_FRAMEVALID]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_RFU]


set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[8]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[9]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[10]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[11]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[12]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[14]}]

set_property IOSTANDARD LVCMOS18 [get_ports {SNSR_FPGA_DATA[15]}]



set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_I2C2_SCL_SPI_SCK]
set_property DRIVE 12 [get_ports SNSR_FPGA_I2C2_SCL_SPI_SCK]
set_property SLEW SLOW [get_ports SNSR_FPGA_I2C2_SCL_SPI_SCK]

set_property IOSTANDARD LVCMOS18 [get_ports SNSR_FPGA_I2C2_SDA_SPI_SDO]
set_property DRIVE 12 [get_ports SNSR_FPGA_I2C2_SDA_SPI_SDO]
set_property SLEW SLOW [get_ports SNSR_FPGA_I2C2_SDA_SPI_SDO]


set_property PACKAGE_PIN L1 [get_ports {SNSR_FPGA_DATA[0]}]
set_property PACKAGE_PIN M1 [get_ports {SNSR_FPGA_DATA[1]}]
set_property PACKAGE_PIN R1 [get_ports {SNSR_FPGA_DATA[10]}]
set_property PACKAGE_PIN T1 [get_ports {SNSR_FPGA_DATA[11]}]
set_property PACKAGE_PIN M6 [get_ports {SNSR_FPGA_DATA[12]}]
set_property PACKAGE_PIN N6 [get_ports {SNSR_FPGA_DATA[13]}]
set_property PACKAGE_PIN R6 [get_ports {SNSR_FPGA_DATA[14]}]
set_property PACKAGE_PIN R5 [get_ports {SNSR_FPGA_DATA[15]}]
set_property PACKAGE_PIN K3 [get_ports {SNSR_FPGA_DATA[2]}]
set_property PACKAGE_PIN L3 [get_ports {SNSR_FPGA_DATA[3]}]
set_property PACKAGE_PIN N2 [get_ports {SNSR_FPGA_DATA[4]}]
set_property PACKAGE_PIN N1 [get_ports {SNSR_FPGA_DATA[5]}]
set_property PACKAGE_PIN M3 [get_ports {SNSR_FPGA_DATA[6]}]
set_property PACKAGE_PIN M2 [get_ports {SNSR_FPGA_DATA[7]}]
set_property PACKAGE_PIN M4 [get_ports {SNSR_FPGA_DATA[8]}]
set_property PACKAGE_PIN N4 [get_ports {SNSR_FPGA_DATA[9]}]
set_property PACKAGE_PIN V1 [get_ports SNSR_FPGA_FRAMEVALID]
set_property PACKAGE_PIN N5 [get_ports SNSR_FPGA_I2C2_SCL_SPI_SCK]
set_property PACKAGE_PIN P5 [get_ports SNSR_FPGA_I2C2_SDA_SPI_SDO]
set_property PACKAGE_PIN U1 [get_ports SNSR_FPGA_LINEVALID]
set_property PACKAGE_PIN T5 [get_ports SNSR_FPGA_MASTER_CLK]
set_property PACKAGE_PIN K5 [get_ports SNSR_FPGA_NRST_SPI_CS]
set_property PACKAGE_PIN T3 [get_ports SNSR_FPGA_PIXEL_CLK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets SNSR_FPGA_PIXEL_CLK_IBUF]
set_property PACKAGE_PIN U4 [get_ports SNSR_FPGA_RFU]
set_property PACKAGE_PIN L4 [get_ports SNSR_FPGA_SEQTRIG]



set_property IOSTANDARD LVCMOS18 [get_ports FPGA_LDO_VA4_EN]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_LDO_VD2_EN] 

set_property PACKAGE_PIN C2 [get_ports FPGA_LDO_VA4_EN]
set_property PULLDOWN TRUE [get_ports FPGA_LDO_VA4_EN]
set_property PACKAGE_PIN C1 [get_ports FPGA_LDO_VD2_EN]
set_property PULLDOWN TRUE [get_ports FPGA_LDO_VD2_EN]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_UART_TX]
set_property DRIVE 12 [get_ports FPGA_B2B_M_UART_TX]
set_property SLEW SLOW [get_ports FPGA_B2B_M_UART_TX]

set_property IOSTANDARD LVCMOS18 [get_ports FPGA_B2B_M_UART_RX]

set_property PACKAGE_PIN G1 [get_ports FPGA_B2B_M_UART_RX]
set_property PACKAGE_PIN H1 [get_ports FPGA_B2B_M_UART_TX]

#set_property PACKAGE_PIN H1 [get_ports FPGA_B2B_M_UART_RX]
#set_property PACKAGE_PIN G1 [get_ports FPGA_B2B_M_UART_TX]

set_property IOSTANDARD LVCMOS18 [get_ports TH_SNR_ADR]
set_property DRIVE 12 [get_ports TH_SNR_ADR]
set_property SLEW SLOW [get_ports TH_SNR_ADR]

set_property IOSTANDARD LVCMOS18 [get_ports TH_SNR_DRDY_INT]

set_property PACKAGE_PIN A13 [get_ports TH_SNR_ADR]
set_property PACKAGE_PIN A14 [get_ports TH_SNR_DRDY_INT]

set_property PACKAGE_PIN L13 [get_ports FPGA_SPI_CS]
set_property PACKAGE_PIN K17 [get_ports FPGA_SPI_DQ0]
set_property PACKAGE_PIN K18 [get_ports FPGA_SPI_DQ1]
set_property PACKAGE_PIN L14 [get_ports FPGA_SPI_DQ2]
set_property PACKAGE_PIN M14 [get_ports FPGA_SPI_DQ3]


set_property PACKAGE_PIN E7 [get_ports FPGA_B2B_M_PVO8]
set_property PACKAGE_PIN D7 [get_ports FPGA_B2B_M_PVO9]
set_property PACKAGE_PIN C4 [get_ports FPGA_B2B_M_PVO10]
set_property PACKAGE_PIN B4 [get_ports FPGA_B2B_M_PVO11]
set_property PACKAGE_PIN A4 [get_ports FPGA_B2B_M_PVO12]
set_property PACKAGE_PIN A3 [get_ports FPGA_B2B_M_PVO13]
set_property PACKAGE_PIN B1 [get_ports FPGA_B2B_M_PVO14]
set_property PACKAGE_PIN A1 [get_ports FPGA_B2B_M_PVO15]
set_property PACKAGE_PIN B3 [get_ports FPGA_B2B_M_PVO_VSYNC]
set_property PACKAGE_PIN B2 [get_ports FPGA_B2B_M_PVO_HSYNC]

set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

set_clock_groups -name async_group -asynchronous -group [get_clocks -regexp .*clk_out1.*] -group [get_clocks -regexp .*clk_out2.*] -group [get_clocks -regexp .*clk_out3.*] -group [get_clocks -regexp .*clk_out4.*] -group [get_clocks -regexp .*clk_out5.*]
#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets FPGA_SDRAM_CLK_OBUF]

create_generated_clock -name cclk -source [get_pins STARTUPE2_inst/USRCCLKO] -combinational [get_pins STARTUPE2_inst/USRCCLKO]

set_input_delay -clock [get_clocks cclk] -clock_fall -min -add_delay 1.000 [get_ports {FPGA_SPI_DQ0}]
set_input_delay -clock [get_clocks cclk] -clock_fall -max -add_delay 6.000 [get_ports {FPGA_SPI_DQ0}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -3.000 [get_ports {FPGA_SPI_DQ0}]
set_output_delay -clock [get_clocks cclk] -max -add_delay 2.000 [get_ports {FPGA_SPI_DQ0}]

set_input_delay -clock [get_clocks cclk] -clock_fall -min -add_delay 1.000 [get_ports {FPGA_SPI_DQ1}]
set_input_delay -clock [get_clocks cclk] -clock_fall -max -add_delay 6.000 [get_ports {FPGA_SPI_DQ1}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -3.000 [get_ports {FPGA_SPI_DQ1}]
set_output_delay -clock [get_clocks cclk] -max -add_delay 2.000 [get_ports {FPGA_SPI_DQ1}]

set_input_delay -clock [get_clocks cclk] -clock_fall -min -add_delay 1.000 [get_ports {FPGA_SPI_DQ2}]
set_input_delay -clock [get_clocks cclk] -clock_fall -max -add_delay 6.000 [get_ports {FPGA_SPI_DQ2}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -3.000 [get_ports {FPGA_SPI_DQ2}]
set_output_delay -clock [get_clocks cclk] -max -add_delay 2.000 [get_ports {FPGA_SPI_DQ2}]

set_input_delay -clock [get_clocks cclk] -clock_fall -min -add_delay 1.000 [get_ports {FPGA_SPI_DQ3}]
set_input_delay -clock [get_clocks cclk] -clock_fall -max -add_delay 6.000 [get_ports {FPGA_SPI_DQ3}]
set_output_delay -clock [get_clocks cclk] -min -add_delay -3.000 [get_ports {FPGA_SPI_DQ3}]
set_output_delay -clock [get_clocks cclk] -max -add_delay 2.000 [get_ports {FPGA_SPI_DQ3}]

set_output_delay -clock [get_clocks cclk] -min -add_delay -4.000 [get_ports FPGA_SPI_CS]
set_output_delay -clock [get_clocks cclk] -max -add_delay 4.000 [get_ports FPGA_SPI_CS]

#set_false_path -from [get_pins {sensor_controller_inst/dut/coarse_offset_corr_inst/coarse_ycounter_start_reg_reg[*]/C}] -to [get_pins sensor_controller_inst/dut/coarse_offset_corr_inst/xpm_cdc_5/src_ff_reg/D]
#set_false_path -from [get_pins {sensor_controller_inst/dut/coarse_offset_corr_inst/coarse_ycounter_start_reg_reg[*]/C}] -to [get_pins sensor_controller_inst/dut/coarse_offset_corr_inst/xpm_cdc_4/src_ff_reg/D]
#set_false_path -from [get_pins {sensor_controller_inst/dut/coarse_offset_corr_inst/coarse_ycounter_start_reg_reg[*]/C}] -to [get_pins sensor_controller_inst/dut/coarse_offset_corr_inst/xpm_cdc_3/src_ff_reg/D]

create_clock -period 51.348 -name SNSR_SSC -waveform {0.000 25.674} [get_ports SNSR_SSC]
create_generated_clock -name SNSR_PIXCLKIN -source [get_pins sensor_controller_inst/ODDR_sensor_pixclk/C] -divide_by 1 -invert [get_ports SNSR_PIXCLKIN]

#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_FB0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_FB0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_FB0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_FB0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT0_1]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT10_11]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT10_11]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT10_11]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT10_11]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT12_13]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT12_13]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT12_13]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT12_13]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT2_3]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT2_3]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT2_3]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT2_3]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT4_5]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT4_5]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT4_5]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT4_5]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT6_7]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT6_7]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT6_7]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT6_7]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -min -add_delay 7.000 [get_ports SNSR_OUT8_9]
#set_input_delay -clock [get_clocks SNSR_SSC] -clock_fall -max -add_delay 9.674 [get_ports SNSR_OUT8_9]
#set_input_delay -clock [get_clocks SNSR_SSC] -min -add_delay 7.000 [get_ports SNSR_OUT8_9]
#set_input_delay -clock [get_clocks SNSR_SSC] -max -add_delay 9.674 [get_ports SNSR_OUT8_9]


set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[0]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[0]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[1]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[1]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[2]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[2]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[3]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[3]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[4]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[4]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[5]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[5]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[6]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[6]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[7]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[7]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[8]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[8]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[9]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[9]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[10]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[10]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[11]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[11]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[12]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[12]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[13]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[13]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[14]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[14]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[15]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[15]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[16]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[16]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[17]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[17]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[18]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[18]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[19]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[19]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[20]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[20]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[21]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[21]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[22]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[22]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[23]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[23]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[24]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[24]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[25]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[25]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[26]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[26]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[27]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[27]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[28]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[28]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[29]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[29]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[30]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[30]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay 1.000 [get_ports FPGA_SDRAM_D[31]]
set_input_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 9.000 [get_ports FPGA_SDRAM_D[31]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[3]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[3]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[4]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[4]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[5]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[5]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[6]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[6]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[7]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[7]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[8]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[8]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[9]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[9]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[10]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[10]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[11]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[11]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[12]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[12]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[13]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[13]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[14]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[14]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[15]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[15]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[16]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[16]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[17]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[17]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[18]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[18]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[19]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[19]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[20]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[20]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[21]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[21]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[22]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[22]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[23]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[23]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[24]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[24]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[25]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[25]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[26]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[26]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[27]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[27]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[28]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[28]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[29]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[29]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[30]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[30]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_D[31]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_D[31]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[3]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[3]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[4]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[4]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[5]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[5]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[6]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[6]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[7]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[7]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[8]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[8]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[9]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[9]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[10]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[10]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[11]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[11]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[12]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[12]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_A[13]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_A[13]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_DQM[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_DQM[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_DQM[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_DQM[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_DQM[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_DQM[2]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_DQM[3]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_DQM[3]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_BA[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_BA[0]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_BA[1]]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_BA[1]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_RAS_N]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_RAS_N]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_CAS_N]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_CAS_N]]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_WE_N]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_WE_N]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_CKE]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_CKE]

set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -min -add_delay -1.000 [get_ports FPGA_SDRAM_CS_N]
set_output_delay -clock [get_clocks FPGA_SDRAM_CLK] -max -add_delay 1.500  [get_ports FPGA_SDRAM_CS_N]

#set_multicycle_path 2 -setup -from [get_clocks CLK_100MHZ] -to [get_clocks FPGA_SDRAM_CLK]
set_multicycle_path 2 -setup -from [get_clocks FPGA_SDRAM_CLK] -to [get_clocks CLK_100MHZ]
