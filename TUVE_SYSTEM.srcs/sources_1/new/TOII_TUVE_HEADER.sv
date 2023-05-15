parameter [7:0] HEADER_BYTE            = 8'hE0,
                HEADER_RESPONSE_BYTE   = 8'hE1,
                DEV_ID                 = 8'h3E,
                DEV_NUM                = 8'hFF,
                FOOTER_BYTE1           = 8'hFF,
                FOOTER_BYTE2           = 8'hFE;


parameter [31:0]  QSPI_ADDR_TEMPERATURE_DATA = 32'h00641000;
parameter [31:0]  QSPI_TEMPERATURE_DATA_BLOCK_SIZE = 32'h1; //256 byte =1 block;

parameter [31:0]  QSPI_ADDR_SENSOR_INIT_DATA = 32'h00642000;
parameter [31:0]  QSPI_SENSOR_INIT_DATA_BLOCK_SIZE = 32'h1; //256 byte =1 block;

parameter [31:0]  NUC_TABLE_SIZE = 32'h00096000;

parameter NO_OF_OFFSET_TABLE = 45;

parameter [31:0]  QSPI_ADDR_GAINM_START  = 32'h00650000,
                  QSPI_ADDR_GAINM_OFFSET = 32'h00096000,
                  QSPI_ADDR_GAINM_1      = QSPI_ADDR_GAINM_START,
                  QSPI_ADDR_GAINM_2      = QSPI_ADDR_GAINM_1  + QSPI_ADDR_GAINM_OFFSET, //0x6e6000
                  QSPI_ADDR_GAINM_3      = QSPI_ADDR_GAINM_2  + QSPI_ADDR_GAINM_OFFSET, //0x77c000
                  QSPI_ADDR_GAINM_4      = QSPI_ADDR_GAINM_3  + QSPI_ADDR_GAINM_OFFSET, //0x812000
                  QSPI_ADDR_IMG_COLD     = QSPI_ADDR_GAINM_4  + QSPI_ADDR_GAINM_OFFSET, //0x8a8000
                  QSPI_ADDR_IMG_HOT      = QSPI_ADDR_IMG_COLD + QSPI_ADDR_GAINM_OFFSET, // 0x93E000                  
                  QSPI_ADDR_OFFM_START   = 32'h009E0000,//32'h006f0000,
                  QSPI_ADDR_OFFM_OFFSET  = 32'h00096000,
                  QSPI_ADDR_OFFM_TEMP_1  = QSPI_ADDR_OFFM_START, 
                  QSPI_ADDR_OFFM_TEMP_2  = QSPI_ADDR_OFFM_TEMP_1  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_3  = QSPI_ADDR_OFFM_TEMP_2  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_4  = QSPI_ADDR_OFFM_TEMP_3  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_5  = QSPI_ADDR_OFFM_TEMP_4  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_6  = QSPI_ADDR_OFFM_TEMP_5  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_7  = QSPI_ADDR_OFFM_TEMP_6  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_8  = QSPI_ADDR_OFFM_TEMP_7  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_9  = QSPI_ADDR_OFFM_TEMP_8  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_10 = QSPI_ADDR_OFFM_TEMP_9  + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_11 = QSPI_ADDR_OFFM_TEMP_10 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_12 = QSPI_ADDR_OFFM_TEMP_11 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_13 = QSPI_ADDR_OFFM_TEMP_12 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_14 = QSPI_ADDR_OFFM_TEMP_13 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_15 = QSPI_ADDR_OFFM_TEMP_14 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_16 = QSPI_ADDR_OFFM_TEMP_15 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_17 = QSPI_ADDR_OFFM_TEMP_16 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_18 = QSPI_ADDR_OFFM_TEMP_17 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_19 = QSPI_ADDR_OFFM_TEMP_18 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_20 = QSPI_ADDR_OFFM_TEMP_19 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_21 = QSPI_ADDR_OFFM_TEMP_20 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_22 = QSPI_ADDR_OFFM_TEMP_21 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_23 = QSPI_ADDR_OFFM_TEMP_22 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_24 = QSPI_ADDR_OFFM_TEMP_23 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_25 = QSPI_ADDR_OFFM_TEMP_24 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_26 = QSPI_ADDR_OFFM_TEMP_25 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_27 = QSPI_ADDR_OFFM_TEMP_26 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_28 = QSPI_ADDR_OFFM_TEMP_27 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_29 = QSPI_ADDR_OFFM_TEMP_28 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_30 = QSPI_ADDR_OFFM_TEMP_29 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_31 = QSPI_ADDR_OFFM_TEMP_30 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_32 = QSPI_ADDR_OFFM_TEMP_31 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_33 = QSPI_ADDR_OFFM_TEMP_32 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_34 = QSPI_ADDR_OFFM_TEMP_33 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_35 = QSPI_ADDR_OFFM_TEMP_34 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_36 = QSPI_ADDR_OFFM_TEMP_35 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_37 = QSPI_ADDR_OFFM_TEMP_36 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_38 = QSPI_ADDR_OFFM_TEMP_37 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_39 = QSPI_ADDR_OFFM_TEMP_38 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_40 = QSPI_ADDR_OFFM_TEMP_39 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_41 = QSPI_ADDR_OFFM_TEMP_40 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_42 = QSPI_ADDR_OFFM_TEMP_41 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_43 = QSPI_ADDR_OFFM_TEMP_42 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_44 = QSPI_ADDR_OFFM_TEMP_43 + QSPI_ADDR_OFFM_OFFSET,
                  QSPI_ADDR_OFFM_TEMP_45 = QSPI_ADDR_OFFM_TEMP_44 + QSPI_ADDR_OFFM_OFFSET;

parameter [31:0] ADDR_GAINM_OFFSET = 32'h00096000;
parameter [31:0] ADDR_GAINM_START  = 32'h000F0000;


parameter [31:0] ADDR_GAIN_BADPIX_A =  ADDR_GAINM_START,
                 ADDR_GAIN_BADPIX_B =  ADDR_GAIN_BADPIX_A + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_C =  ADDR_GAIN_BADPIX_B + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_D =  ADDR_GAIN_BADPIX_C + ADDR_GAINM_OFFSET,
                 ADDR_IMG_COLD     =   ADDR_GAIN_BADPIX_D + ADDR_GAINM_OFFSET,
                 ADDR_IMG_HOT      =   ADDR_IMG_COLD + ADDR_GAINM_OFFSET,
                 ADDR_GAIN         =   ADDR_IMG_HOT +  ADDR_GAINM_OFFSET; 

     
parameter [31:0] ADDR_OFFM_START  = 32'h0050A000,//32'h00348000,
                 ADDR_OFFM_OFFSET = 32'h00096000;


parameter [31:0] ADDR_OFFM_TEMP_1 =  ADDR_OFFM_START, 
                 ADDR_OFFM_TEMP_2 =  ADDR_OFFM_TEMP_1  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_3 = ADDR_OFFM_TEMP_2  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_4 = ADDR_OFFM_TEMP_3  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_5 = ADDR_OFFM_TEMP_4  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_6 = ADDR_OFFM_TEMP_5  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_7 = ADDR_OFFM_TEMP_6  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_8 = ADDR_OFFM_TEMP_7  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_9 = ADDR_OFFM_TEMP_8  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_10= ADDR_OFFM_TEMP_9  + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_11= ADDR_OFFM_TEMP_10 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_12= ADDR_OFFM_TEMP_11 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_13= ADDR_OFFM_TEMP_12 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_14= ADDR_OFFM_TEMP_13 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_15= ADDR_OFFM_TEMP_14 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_16= ADDR_OFFM_TEMP_15 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_17= ADDR_OFFM_TEMP_16 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_18= ADDR_OFFM_TEMP_17 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_19= ADDR_OFFM_TEMP_18 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_20= ADDR_OFFM_TEMP_19 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_21= ADDR_OFFM_TEMP_20 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_22= ADDR_OFFM_TEMP_21 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_23= ADDR_OFFM_TEMP_22 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_24= ADDR_OFFM_TEMP_23 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_25= ADDR_OFFM_TEMP_24 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_26= ADDR_OFFM_TEMP_25 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_27= ADDR_OFFM_TEMP_26 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_28= ADDR_OFFM_TEMP_27 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_29= ADDR_OFFM_TEMP_28 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_30= ADDR_OFFM_TEMP_29 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_31= ADDR_OFFM_TEMP_30 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_32= ADDR_OFFM_TEMP_31 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_33= ADDR_OFFM_TEMP_32 + ADDR_OFFM_OFFSET,
                 ADDR_OFFM_TEMP_34= ADDR_OFFM_TEMP_33 + ADDR_OFFM_OFFSET;
	
parameter [31:0] ADDR_OFFM_NUC1PT  = 32'h033EA000;//32'h03228000;
parameter [31:0] ADDR_RETICLE_INFO = 32'h03516000;//32'h03354000;

//parameter [31:0] ADDR_IMG_COLD     = 32'h033EA000;
//parameter [31:0] ADDR_IMG_HOT      = 32'h03516000;
//parameter [31:0] ADDR_GAIN         = 32'h03642000;

//parameter [31:0] QSPI_ADDR_IMG_COLD = 32'h03700000,
//parameter [31:0] QSPI_ADDR_IMG_HOT  = 32'h03796000;



parameter [15:0]  FAILURE_CMD = 16'hDEAD,
                  PING_CMD = 16'hB0B0,
                  FPGA_RD_REGS = 16'h5000,
                  FPGA_WR_REGS = 16'h5000,
                  SET_SDRAM_ADDR = 16'h6000,
                  SET_SDRAM_DATA = 16'h6004,
                  GET_SDRAM_DATA = 16'h6004,
                  SET_I2C = 16'h7004,
                  GET_I2C = 16'h7004,
//                  SET_SENSOR_I2C = 16'h7104,
//                  GET_SENSOR_I2C = 16'h7104,
                  SET_SPI     = 16'h3004,
                  GET_SPI     = 16'h3004,
                  SET_SD_ADDR = 16'h2000,
                  SET_SD_DATA = 16'h2004,
                  GET_SD_DATA = 16'h2004,
                  RD_QSPI_WR_SDRAM       = 16'hE000,
                  RD_QSPI_WR_TEMPERATURE = 16'hE004,
                  RD_QSPI_WR_SENSOR_INIT = 16'hE008,
                  TEMPERATURE_WR_QSPI    = 16'hE00C,
                  TEMP_RANGE0_SENSOR_INIT_WR_QSPI = 16'hE00D,
                  TEMP_RANGE1_SENSOR_INIT_WR_QSPI = 16'hE00E,
                  TEMP_RANGE2_SENSOR_INIT_WR_QSPI = 16'hE00F,
                  TEMP_RANGE3_SENSOR_INIT_WR_QSPI = 16'hE010,                  
//                  LOW_TEMP_SENSOR_INIT_WR_QSPI  = 16'hE00D,
//                  HIGH_TEMP_SENSOR_INIT_WR_QSPI = 16'hE00E,
                  END_INIT_CMD           = 16'hEEDD,
                  ERASE_QSPI_64KB        = 16'hA000,
                  ERASE_QSPI_32KB        = 16'hA001,
                  ERASE_QSPI_4KB         = 16'hA002,
                  ERASE_QSPI             = 16'hA004,
                  TRANS_SDRAM_TO_QSPI    = 16'hA003,
                  QSPI_STATUS_CMD        = 16'hA008,
                  MARK_BADPIX            = 16'hA00C,
                  UNMARK_BADPIX          = 16'hA00D; 

//parameter [5:0]  low_temp_sensor_init_gsk_addr   = 6'd3,
//                 low_temp_sensor_init_gfid_addr  = 6'd4,
//                 high_temp_sensor_init_gsk_addr  = 6'd5,
//                 high_temp_sensor_init_gfid_addr = 6'd6;

//parameter [5:0]  low_temp_sensor_init_gfid_addr       = 6'd3,
//                 low_temp_sensor_init_gsk_addr        = 6'd4,
//                 low_temp_sensor_init_int_time_addr   = 6'd5,
//                 low_temp_sensor_init_gain_addr       = 6'd6,
//                 high_temp_sensor_init_gfid_addr      = 6'd7,
//                 high_temp_sensor_init_gsk_addr       = 6'd8,
//                 high_temp_sensor_init_int_time_addr  = 6'd9,
//                 high_temp_sensor_init_gain_addr      = 6'd10;
                 

parameter [5:0]  temp_range0_sensor_init_gfid_addr       = 6'd3,
                 temp_range0_sensor_init_gsk_addr        = 6'd4,
                 temp_range0_sensor_init_int_time_addr   = 6'd5,
                 temp_range0_sensor_init_gain_addr       = 6'd6,
                 temp_range1_sensor_init_gfid_addr       = 6'd7,
                 temp_range1_sensor_init_gsk_addr        = 6'd8,
                 temp_range1_sensor_init_int_time_addr   = 6'd9,
                 temp_range1_sensor_init_gain_addr       = 6'd10,
                 temp_range2_sensor_init_gfid_addr       = 6'd11, 
                 temp_range2_sensor_init_gsk_addr        = 6'd12,
                 temp_range2_sensor_init_int_time_addr   = 6'd13,
                 temp_range2_sensor_init_gain_addr       = 6'd14,                 
                 temp_range3_sensor_init_gfid_addr       = 6'd15, 
                 temp_range3_sensor_init_gsk_addr        = 6'd16,
                 temp_range3_sensor_init_int_time_addr   = 6'd17,
                 temp_range3_sensor_init_gain_addr       = 6'd18;

                 
parameter [7:0]  SENSOR_GFID_ADDR = 3,
                 SENSOR_GSK_ADDR  = 2,
                 SENSOR_INT_TIME_ADDR =1,
                 SENSOR_GAIN_ADDR = 5;

parameter   [31:0] OFFSET_64KB = 32'h10000,
                   OFFSET_32KB = 32'h08000,
                   OFFSET_4KB  = 32'h01000;   

parameter [31:0] qspi_init_st_addr = 32'h00640000; //(sector 100th)
parameter [8:0]  qspi_init_rd_len  = 9'd14;   //(cmd = 2byte, src_addr = 4byte,dest_addr = 4byte,data_transfer_len = 4byte)
parameter [8:0]  qspi_block_rd_size = 256; // 256 byte read data
parameter [8:0]  qspi_block_wr_size = 256; // 256 byte write data                   

            
parameter  QSPI_ADDR_WIDTH = 32,
           QSPI_DATA_WIDTH = 8,
           QSPI_CMD_WIDTH  = 8;            