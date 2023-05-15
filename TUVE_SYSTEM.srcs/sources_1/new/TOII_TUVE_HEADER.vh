localparam [7:0] HEADER_BYTE          = 8'hE0,
                HEADER_RESPONSE_BYTE = 8'hE1,
                DEV_ID               = 8'h3E,
                DEV_NUM              = 8'hFF,
                FOOTER_BYTE1         = 8'hFF,
                FOOTER_BYTE2         = 8'hFE;


localparam [31:0]  QSPI_ADDR_ADV_PAL_INIT  = 32'h00649000;
localparam [31:0]  QSPI_ADDR_ADV_NTSC_INIT = 32'h0064A000;

localparam [31:0]  QSPI_ADDR_TEMPERATURE_DATA       = 32'h00641000;
localparam [31:0]  QSPI_TEMPERATURE_DATA_BLOCK_SIZE = 32'h1; //256 byte =1 block;

localparam [31:0]  QSPI_ADDR_SENSOR_INIT_DATA       = 32'h00642000;
localparam [31:0]  QSPI_SENSOR_INIT_DATA_BLOCK_SIZE = 32'h1; //256 byte =1 block;

localparam [31:0]  QSPI_ADDR_OLED_GAMMA_CORR_DATA   = 32'h00647000;

localparam [31:0]  QSPI_ADDR_OLED_INIT_DATA         = 32'h00648000;
localparam [31:0]  QSPI_OLED_INIT_DATA_BLOCK_SIZE   = 32'h1;
 
localparam [31:0]  QSPI_ADDR_USER_SETTINGS_DATA         = 32'h00643000;
localparam [31:0]  QSPI_ADDR_USER_SETTINGS_DATA_SIZE    = 32'h00000400;
localparam [31:0]  QSPI_ADDR_FACTORY_SETTINGS_DATA      = 32'h00645000;
localparam [31:0]  QSPI_ADDR_FACTORY_SETTINGS_DATA_SIZE = 32'h00000400;



localparam [31:0]  QSPI_RETICLE_SIZE    = 32'h00012C00,
                  QSPI_ADDR_RETICLE_1  = 32'h03E2B000,//035D0000,
                  QSPI_ADDR_RETICLE_2  = 32'h03E3DC00,//035E2C00,
                  QSPI_ADDR_RETICLE_3  = 32'h03E50800,//035F5800,
                  QSPI_ADDR_RETICLE_4  = 32'h03E63400,//03608400,
                  QSPI_ADDR_RETICLE_5  = 32'h03E76000,//0361B000,
                  QSPI_ADDR_RETICLE_6  = 32'h03E88C00,//0362DC00,
                  QSPI_ADDR_RETICLE_7  = 32'h03E9B800,//03640800,
                  QSPI_ADDR_RETICLE_8  = 32'h03EAE400,//03653400,
                  QSPI_ADDR_RETICLE_9  = 32'h03EC1000,//03666000,
                  QSPI_ADDR_RETICLE_10 = 32'h03ED3C00,//03678C00,
                  QSPI_ADDR_RETICLE_11 = 32'h03EE6800,//0368B800,
                  QSPI_ADDR_RETICLE_12 = 32'h03EF9400,//0369E400,
                  QSPI_ADDR_RETICLE_13 = 32'h03F0C000,//036B1000,
                  QSPI_ADDR_RETICLE_14 = 32'h03F1EC00,//036C3C00,
                  QSPI_ADDR_RETICLE_15 = 32'h03F31800,//036D6800,
                  QSPI_ADDR_RETICLE_16 = 32'h03F44400;//036E9400;
                  
localparam [31:0]  NUC_TABLE_SIZE = 32'h00096000;

localparam NO_OF_OFFSET_TABLE = 45;

localparam [31:0]  QSPI_ADDR_GAINM_START  = 32'h00650000,
                  QSPI_ADDR_GAINM_OFFSET = 32'h00096000,
                  QSPI_ADDR_GAINM_A      = QSPI_ADDR_GAINM_START,
                  QSPI_ADDR_GAINM_B      = QSPI_ADDR_GAINM_A  + QSPI_ADDR_GAINM_OFFSET, //0x6e6000
                  QSPI_ADDR_GAINM_C      = QSPI_ADDR_GAINM_B  + QSPI_ADDR_GAINM_OFFSET, //0x77c000
                  QSPI_ADDR_GAINM_D      = QSPI_ADDR_GAINM_C  + QSPI_ADDR_GAINM_OFFSET, //0x812000
                  QSPI_ADDR_GAINM_E      = QSPI_ADDR_GAINM_D  + QSPI_ADDR_GAINM_OFFSET, //0x812000
                  QSPI_ADDR_GAINM_F      = QSPI_ADDR_GAINM_E  + QSPI_ADDR_GAINM_OFFSET, //0x812000
                  QSPI_ADDR_GAINM_G      = QSPI_ADDR_GAINM_F  + QSPI_ADDR_GAINM_OFFSET, //0x812000
                  QSPI_ADDR_IMG_COLD     = QSPI_ADDR_GAINM_G  + QSPI_ADDR_GAINM_OFFSET, //0x8a8000
                  QSPI_ADDR_IMG_HOT      = QSPI_ADDR_IMG_COLD + QSPI_ADDR_GAINM_OFFSET, // 0x93E000                  
                  QSPI_ADDR_OFFM_START   = 32'h00DF0000,//32'h009E0000,//32'h006f0000,
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


localparam [31:0] ADDR_FACTORY_SETTINGS = 32'h03ffd000;
localparam [31:0] ADDR_GAINM_OFFSET     = 32'h00096000;
localparam [31:0] ADDR_GAINM_START      = 32'h000F0000;


localparam [31:0] ADDR_GAIN_BADPIX_A =  ADDR_GAINM_START,
                 ADDR_GAIN_BADPIX_B =  ADDR_GAIN_BADPIX_A + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_C =  ADDR_GAIN_BADPIX_B + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_D =  ADDR_GAIN_BADPIX_C + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_E =  ADDR_GAIN_BADPIX_D + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_F =  ADDR_GAIN_BADPIX_E + ADDR_GAINM_OFFSET,
                 ADDR_GAIN_BADPIX_G =  ADDR_GAIN_BADPIX_F + ADDR_GAINM_OFFSET,
                 ADDR_IMG_COLD      =  ADDR_GAIN_BADPIX_G + ADDR_GAINM_OFFSET,
                 ADDR_IMG_HOT       =  ADDR_IMG_COLD + ADDR_GAINM_OFFSET,
                 ADDR_GAIN          =  ADDR_IMG_HOT +  ADDR_GAINM_OFFSET; 



localparam [31:0] ADDR_COARSE_OFFSET_START   = 32'h006CC000;
localparam [31:0] ADDR_COARSE_OFFSET_OFFSET  = 32'h00052800;
    
localparam [31:0] ADDR_COARSE_OFFSET_0  = ADDR_COARSE_OFFSET_START,
                 ADDR_COARSE_OFFSET_1  = ADDR_COARSE_OFFSET_0 + ADDR_COARSE_OFFSET_OFFSET,
                 ADDR_COARSE_OFFSET_2  = ADDR_COARSE_OFFSET_1 + ADDR_COARSE_OFFSET_OFFSET,   
                 ADDR_COARSE_OFFSET_3  = ADDR_COARSE_OFFSET_2 + ADDR_COARSE_OFFSET_OFFSET,   
                 ADDR_COARSE_OFFSET_4  = ADDR_COARSE_OFFSET_3 + ADDR_COARSE_OFFSET_OFFSET,
                 ADDR_COARSE_OFFSET_5  = ADDR_COARSE_OFFSET_4 + ADDR_COARSE_OFFSET_OFFSET,
                 ADDR_COARSE_OFFSET_6  = ADDR_COARSE_OFFSET_5 + ADDR_COARSE_OFFSET_OFFSET;    

     
localparam [31:0] ADDR_OFFM_COEFF_START     = 32'h0090D800,//x"0050A000";--x"00348000";--x"000E0000";
                 ADDR_OFFM_COEFF_OFFSET    = 32'h0012C000,
                 ADDR_OFFM_OFFSET          = 32'h00096000;

localparam [31:0]     ADDR_OFFM_PING            = ADDR_OFFM_COEFF_START,
                     ADDR_OFFM_PONG            = ADDR_OFFM_COEFF_START     + ADDR_OFFM_OFFSET,   
                     ADDR_OFFM_COEFF_C1_TEMP_0 = ADDR_OFFM_COEFF_START     + ADDR_OFFM_COEFF_OFFSET, 
                     ADDR_OFFM_COEFF_C2_TEMP_0 = ADDR_OFFM_COEFF_C1_TEMP_0 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_0 = ADDR_OFFM_COEFF_C2_TEMP_0 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_1 = ADDR_OFFM_COEFF_C3_TEMP_0 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C2_TEMP_1 = ADDR_OFFM_COEFF_C1_TEMP_1 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_1 = ADDR_OFFM_COEFF_C2_TEMP_1 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_2 = ADDR_OFFM_COEFF_C3_TEMP_1 + ADDR_OFFM_COEFF_OFFSET, 
                     ADDR_OFFM_COEFF_C2_TEMP_2 = ADDR_OFFM_COEFF_C1_TEMP_2 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_2 = ADDR_OFFM_COEFF_C2_TEMP_2 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_3 = ADDR_OFFM_COEFF_C3_TEMP_2 + ADDR_OFFM_COEFF_OFFSET, 
                     ADDR_OFFM_COEFF_C2_TEMP_3 = ADDR_OFFM_COEFF_C1_TEMP_3 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_3 = ADDR_OFFM_COEFF_C2_TEMP_3 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_4 = ADDR_OFFM_COEFF_C3_TEMP_3 + ADDR_OFFM_COEFF_OFFSET, 
                     ADDR_OFFM_COEFF_C2_TEMP_4 = ADDR_OFFM_COEFF_C1_TEMP_4 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_4 = ADDR_OFFM_COEFF_C2_TEMP_4 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_5 = ADDR_OFFM_COEFF_C3_TEMP_4 + ADDR_OFFM_COEFF_OFFSET, 
                     ADDR_OFFM_COEFF_C2_TEMP_5 = ADDR_OFFM_COEFF_C1_TEMP_5 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_5 = ADDR_OFFM_COEFF_C2_TEMP_5 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C1_TEMP_6 = ADDR_OFFM_COEFF_C3_TEMP_5 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C2_TEMP_6 = ADDR_OFFM_COEFF_C1_TEMP_6 + ADDR_OFFM_COEFF_OFFSET,
                     ADDR_OFFM_COEFF_C3_TEMP_6 = ADDR_OFFM_COEFF_C2_TEMP_6 + ADDR_OFFM_COEFF_OFFSET;


      

	
localparam [31:0] ADDR_OFFM_NUC1PT  = 32'h03D00000;//32'h033EA000;//32'h03228000;
//localparam [31:0] ADDR_RETICLE_INFO = 32'h03516000;//32'h03354000;

localparam [31:0] ADDR_OFFM_NUC1PTM2 = 32'h03D96000;

//localparam [31:0] ADDR_IMG_COLD     = 32'h033EA000;
//localparam [31:0] ADDR_IMG_HOT      = 32'h03516000;
//localparam [31:0] ADDR_GAIN         = 32'h03642000;

//localparam [31:0] QSPI_ADDR_IMG_COLD = 32'h03700000,
//localparam [31:0] QSPI_ADDR_IMG_HOT  = 32'h03796000;
localparam TOTAL_FRAME_BUFFERS = 32;
localparam [31:0] ADDR_SNAPSHOT_BASE     = 32'h021AA000,//32'h02000000,
                 ADDR_SNAPSHOT_OFFSET_1 = 32'h000aa000,
                 ADDR_SNAPSHOT_OFFSET_2 = 32'h00055000;
                 
localparam [31:0] QSPI_ADDR_SNAPSHOT_BASE = 32'h0284E000;//32'h02450000;

localparam [15:0]  FAILURE_CMD                     = 16'hDEAD,
                  PING_CMD                        = 16'hB0B0,
                  FPGA_RD_REGS                    = 16'h5000,
                  FPGA_WR_REGS                    = 16'h5000,
                  SET_SDRAM_ADDR                  = 16'h6000,
                  SET_SDRAM_DATA                  = 16'h6004,
                  GET_SDRAM_DATA                  = 16'h6004,
                  SET_I2C                         = 16'h7004,
                  GET_I2C                         = 16'h7004,
                  SET_I2C_16B                     = 16'h7005,
                  GET_I2C_16B                     = 16'h7005,
                  SET_SENSOR_I2C                  = 16'h7104,
                  GET_SENSOR_I2C                  = 16'h7104,
                  SET_SPI                         = 16'h3004,
                  GET_SPI                         = 16'h3004,
                  SET_SD_ADDR                     = 16'h2000,
                  SET_SD_DATA                     = 16'h2004,
                  GET_SD_DATA                     = 16'h2004,
                  RD_QSPI_WR_SDRAM                = 16'hE000,
                  RD_QSPI_WR_BATTERY_ADC          = 16'hE01E,
                  RD_QSPI_WR_BATTERY_GAUGE        = 16'hE01F,
                  RD_QSPI_WR_OLED_CF              = 16'hE020,
                  RD_QSPI_WR_OLED_VGN_GAMMA       = 16'hE021,
                  RD_QSPI_WR_OLED_VGN_ADC         = 16'hE022,
                  RD_QSPI_WR_OLED_GAMMA_COEFF     = 16'hE002,
                  RD_QSPI_WR_OLED                 = 16'hE003,
                  RD_QSPI_WR_TEMPERATURE          = 16'hE004,
//                  RD_QSPI_WR_ADV                  = 16'hE005,
                  RD_QSPI_WR_ADV_PAL              = 16'hE005,
                  RD_QSPI_WR_ADV_NTSC             = 16'hE015,  
                  RD_QSPI_WR_LOGO                 = 16'hE006,
                  RD_QSPI_WR_RETICLE              = 16'hE007,
                  RD_QSPI_WR_RETICLE_OFFSET       = 16'hE017,
                  RD_QSPI_WR_SENSOR_INIT          = 16'hE008,
                  RD_QSPI_WR_USER_SETTINGS        = 16'hE009,
                  RD_QSPI_WR_PRDCT_NAME           = 16'hE00A,
                  TEMPERATURE_WR_QSPI             = 16'hE00C,
                  TEMP_RANGE0_SENSOR_INIT_WR_QSPI = 16'hE00D,
                  TEMP_RANGE1_SENSOR_INIT_WR_QSPI = 16'hE00E,
                  TEMP_RANGE2_SENSOR_INIT_WR_QSPI = 16'hE00F,
                  TEMP_RANGE3_SENSOR_INIT_WR_QSPI = 16'hE010,        
                  TEMP_RANGE4_SENSOR_INIT_WR_QSPI = 16'hE011,
                  TEMP_RANGE5_SENSOR_INIT_WR_QSPI = 16'hE012,
                  TEMP_RANGE6_SENSOR_INIT_WR_QSPI = 16'hE013,          
//                  LOW_TEMP_SENSOR_INIT_WR_QSPI   = 16'hE00D,
//                  HIGH_TEMP_SENSOR_INIT_WR_QSPI  = 16'hE00E,
                  END_INIT_CMD                    = 16'hEEDD,
                  ERASE_QSPI_64KB                 = 16'hA000,
                  ERASE_QSPI_32KB                 = 16'hA001,
                  ERASE_QSPI_4KB                  = 16'hA002,
                  TRANS_SDRAM_TO_QSPI             = 16'hA003,
                  ERASE_QSPI                      = 16'hA004,
                  SAVE_USER_SETTINGS              = 16'hA005,
                  SWITCH_TO_FACTORY_SETTINGS      = 16'hA006,
                  SAVE_OLED_SETTINGS              = 16'hA007,
                  QSPI_STATUS_CMD                 = 16'hA008,
                  LOAD_USER_SETTINGS              = 16'hA009,
                  LOAD_FACTORY_SETTINGS           = 16'hA00A,
                  MARK_BADPIX                     = 16'hA00C,
                  UNMARK_BADPIX                   = 16'hA00D,
                  SNAPSHOT                        = 16'hA00E; 

//localparam [5:0]  low_temp_sensor_init_gsk_addr   = 6'd3,
//                 low_temp_sensor_init_gfid_addr  = 6'd4,
//                 high_temp_sensor_init_gsk_addr  = 6'd5,
//                 high_temp_sensor_init_gfid_addr = 6'd6;

//localparam [5:0]  low_temp_sensor_init_gfid_addr       = 6'd3,
//                 low_temp_sensor_init_gsk_addr        = 6'd4,
//                 low_temp_sensor_init_int_time_addr   = 6'd5,
//                 low_temp_sensor_init_gain_addr       = 6'd6,
//                 high_temp_sensor_init_gfid_addr      = 6'd7,
//                 high_temp_sensor_init_gsk_addr       = 6'd8,
//                 high_temp_sensor_init_int_time_addr  = 6'd9,
//                 high_temp_sensor_init_gain_addr      = 6'd10;
                 

//localparam [5:0]  temp_range0_sensor_init_dbias_addr         = 6'd0,
//                 temp_range0_sensor_init_coarse_offset_addr = 6'd1,
//                 temp_range0_sensor_init_heat_comp_addr     = 6'd2,
//                 temp_range0_sensor_init_temp_offset_addr   = 6'd3,
//                 temp_range1_sensor_init_dbias_addr         = 6'd4,
//                 temp_range1_sensor_init_coarse_offset_addr = 6'd5,
//                 temp_range1_sensor_init_heat_comp_addr     = 6'd6,
//                 temp_range1_sensor_init_temp_offset_addr   = 6'd7,
//                 temp_range2_sensor_init_dbias_addr         = 6'd8,
//                 temp_range2_sensor_init_coarse_offset_addr = 6'd9,
//                 temp_range2_sensor_init_heat_comp_addr     = 6'd10,
//                 temp_range2_sensor_init_temp_offset_addr   = 6'd11,                
//                 temp_range3_sensor_init_dbias_addr         = 6'd12,
//                 temp_range3_sensor_init_coarse_offset_addr = 6'd13,
//                 temp_range3_sensor_init_heat_comp_addr     = 6'd14,
//                 temp_range3_sensor_init_temp_offset_addr   = 6'd15,
//                 temp_range4_sensor_init_dbias_addr         = 6'd16,
//                 temp_range4_sensor_init_coarse_offset_addr = 6'd17,
//                 temp_range4_sensor_init_heat_comp_addr     = 6'd18,
//                 temp_range4_sensor_init_temp_offset_addr   = 6'd19,
//                 temp_range5_sensor_init_dbias_addr         = 6'd20,
//                 temp_range5_sensor_init_coarse_offset_addr = 6'd21,
//                 temp_range5_sensor_init_heat_comp_addr     = 6'd22,
//                 temp_range5_sensor_init_temp_offset_addr   = 6'd23,                                  
//                 temp_range6_sensor_init_dbias_addr         = 6'd24,
//                 temp_range6_sensor_init_coarse_offset_addr = 6'd25,
//                 temp_range6_sensor_init_heat_comp_addr     = 6'd26,
//                 temp_range6_sensor_init_temp_offset_addr   = 6'd27;   

parameter [5:0]  temp_range0_sensor_init_gfid_addr       = 6'd3,
                 temp_range0_sensor_init_gsk_addr        = 6'd4,
                 temp_range0_sensor_init_gsk_addr1       = 6'd5,
                 temp_range0_sensor_init_int_time_addr   = 6'd6,
                 temp_range0_sensor_init_int_time_addr1  = 6'd7,
                 temp_range0_sensor_init_gain_addr       = 6'd8,
                 temp_range1_sensor_init_gfid_addr       = 6'd9,
                 temp_range1_sensor_init_gsk_addr        = 6'd10,
                 temp_range1_sensor_init_gsk_addr1       = 6'd11,
                 temp_range1_sensor_init_int_time_addr   = 6'd12,
                 temp_range1_sensor_init_int_time_addr1  = 6'd13,
                 temp_range1_sensor_init_gain_addr       = 6'd14,
                 temp_range2_sensor_init_gfid_addr       = 6'd15, 
                 temp_range2_sensor_init_gsk_addr        = 6'd16,
                 temp_range2_sensor_init_gsk_addr1       = 6'd17,
                 temp_range2_sensor_init_int_time_addr   = 6'd18,
                 temp_range2_sensor_init_int_time_addr1  = 6'd19,
                 temp_range2_sensor_init_gain_addr       = 6'd20,                 
                 temp_range3_sensor_init_gfid_addr       = 6'd21, 
                 temp_range3_sensor_init_gsk_addr        = 6'd22,
                 temp_range3_sensor_init_gsk_addr1       = 6'd23,
                 temp_range3_sensor_init_int_time_addr   = 6'd24,
                 temp_range3_sensor_init_int_time_addr1  = 6'd25,
                 temp_range3_sensor_init_gain_addr       = 6'd26;  


localparam [5:0] oled_init_mem_dispmode_addr        = 6'd53,//6'd0,
                 oled_init_mem_vinmode_addr         = 6'd1, //     (reg address 0x02 , data =0x04)          
                 oled_init_mem_lftpos_msb_addr      = 6'd3,//6'd45,//(reg addr 0x31 = 0x0)
                 oled_init_mem_lftpos_addr          = 6'd45,//6'd3, //(reg addr 0x32 = 0x8)
                 oled_init_mem_rgtpos_msb_addr      = 6'd2,//6'd44,//(reg addr 0x33 = 0x0)
                 oled_init_mem_rgtpos_addr          = 6'd44,//6'd2, //(reg addr 0x34= 0x8)
                 oled_init_mem_toppos_addr          = 6'd4, //(reg addr 0x35= 0x8)
                 oled_init_mem_botpos_addr          = 6'd5, //(reg addr 0x36= 0x8)
                 oled_init_mem_brightness_addr      = 6'd6,
                 oled_init_mem_contrast_addr        = 6'd7,
                 oled_init_mem_row_start_msb_addr   = 6'd40, //(reg addr 0x37 = 0x2)
                 oled_init_mem_row_start_lsb_addr   = 6'd41, //(reg addr 0x38 = 0xD7)
                 oled_init_mem_row_end_msb_addr     = 6'd42, //(reg addr 0x39 = 0x0)
                 oled_init_mem_row_end_lsb_addr     = 6'd43, //(reg addr 0x3A = 0x08)
                 oled_init_mem_gammaset_addr        = 6'd14,
                 oled_init_mem_vcommode_addr        = 6'd15, 
                 oled_init_mem_idrf_addr            = 6'd19,
                 oled_init_mem_dimctl_addr          = 6'd20,
                 oled_init_mem_tpmode_addr          = 6'd26,//(reg addr 0x06= 0x0)
                 oled_init_mem_lut_addr_addr        = 6'd31,  //  (reg addr 0x21= 0x0)             
                 oled_init_mem_lut_datal_addr       = 6'd32, //(reg addr 0x23= 0x0)             
                 oled_init_mem_lut_datah_addr       = 6'd33,
                 oled_init_mem_lut_update_addr      = 6'd34;  

localparam [7:0]OLED_LUT_UPDATE_REG_ADDR = 8'h20, //8'h24,     
                OLED_R_LUT_ADDR_REG_ADDR = 8'h21, //8'h21,     
                OLED_R_LUT_DATAL_REG_ADDR= 8'h23, //8'h22,     
                OLED_R_LUT_DATAH_REG_ADDR= 8'h22, //8'h23,     
                OLED_G_LUT_ADDR_REG_ADDR = 8'h24, //8'h21,     
                OLED_G_LUT_DATAL_REG_ADDR= 8'h26, //8'h22,     
                OLED_G_LUT_DATAH_REG_ADDR= 8'h25, //8'h23, 
                OLED_B_LUT_ADDR_REG_ADDR = 8'h27, //8'h21,     
                OLED_B_LUT_DATAL_REG_ADDR= 8'h29, //8'h22,     
                OLED_B_LUT_DATAH_REG_ADDR= 8'h28, //8'h23,                 
                OLED_TOPPOS_REG_ADDR     = 8'h35, //8'h05,     
                OLED_BOTPOS_REG_ADDR     = 8'h36, //8'h06, 
                OLED_LFTPOS_MSB_REG_ADDR = 8'h31,                    
                OLED_LFTPOS_REG_ADDR     = 8'h32, //8'h03,   
                OLED_RGTPOS_MSB_REG_ADDR = 8'h33,                   
                OLED_RGTPOS_REG_ADDR     = 8'h34, //8'h04,     
                OLED_IDRF_REG_ADDR       = 8'h14,     
                OLED_DIMCTL_REG_ADDR     = 8'h15,
                OLED_DISPMODE_REG_ADDR   = 8'h30, //8'h02,     
                OLED_BRIGHTNESS_REG_ADDR = 8'h07,     
                OLED_CONTRAST_REG_ADDR   = 8'h08,
                OLED_GAMMASET_REG_ADDR   = 8'h0F,
                OLED_CATHODE_VOLTAGE_REG_ADDR = 8'h00,
                OLED_ROW_START_MSB_REG_ADDR = 8'h37,
                OLED_ROW_START_LSB_REG_ADDR = 8'h38,
                OLED_ROW_END_MSB_REG_ADDR   = 8'h39,
                OLED_ROW_END_LSB_REG_ADDR   = 8'h3A,
                OLED_TP_MODE_ADDR           = 8'h06;
                   

//localparam [5:0] oled_init_mem_dispmode_addr        = 6'd53, //6'd0,
//                 oled_init_mem_vinmode_addr         = 6'd1,                 
//                 oled_init_mem_lftpos_addr          = 6'd2,
//                 oled_init_mem_rgtpos_addr          = 6'd3,
//                 oled_init_mem_toppos_addr          = 6'd4,
//                 oled_init_mem_botpos_addr          = 6'd5,
//                 oled_init_mem_brightness_addr      = 6'd6,
//                 oled_init_mem_contrast_addr        = 6'd7,
//                 oled_init_mem_gammaset_addr        = 6'd14,
//                 oled_init_mem_vcommode_addr        = 6'd15, 
//                 oled_init_mem_idrf_addr            = 6'd19,
//                 oled_init_mem_dimctl_addr          = 6'd20,
//                 oled_init_mem_tpmode_addr          = 6'd26,
//                 oled_init_mem_lut_addr_addr        = 6'd31,                 
//                 oled_init_mem_lut_datal_addr       = 6'd32,
//                 oled_init_mem_lut_datah_addr       = 6'd33,
//                 oled_init_mem_lut_update_addr      = 6'd34;  

//localparam [7:0]OLED_LUT_UPDATE_REG_ADDR = 8'h24,     
//                OLED_LUT_ADDR_REG_ADDR   = 8'h21,     
//                OLED_LUT_DATAL_REG_ADDR  = 8'h22,     
//                OLED_LUT_DATAH_REG_ADDR  = 8'h23,     
//                OLED_TOPPOS_REG_ADDR     = 8'h05,     
//                OLED_BOTPOS_REG_ADDR     = 8'h06,     
//                OLED_LFTPOS_REG_ADDR     = 8'h03,     
//                OLED_RGTPOS_REG_ADDR     = 8'h04,     
//                OLED_IDRF_REG_ADDR       = 8'h14,     
//                OLED_DIMCTL_REG_ADDR     = 8'h15,
//                OLED_DISPMODE_REG_ADDR   = 8'h02,     
//                OLED_BRIGHTNESS_REG_ADDR = 8'h07,     
//                OLED_CONTRAST_REG_ADDR   = 8'h08,
//                OLED_GAMMASET_REG_ADDR   = 8'h0F;   
                                   
localparam [7:0] OLED_POS_V_MAX_OFFSET = 8'h54; //8'd84 //8'h30, //8'd48
localparam [8:0] OLED_POS_H_MAX_OFFSET = 9'h150;//8'hFF //8'h80;//8'd128 // 8'h68; //8'd104

localparam [7:0]  OLED_VGN_ADC_CONV_REG_ADDR    = 8'h00,
                 OLED_VGN_ADC_ALERT_REG_ADDR   = 8'h01,
                 OLED_VGN_ADC_CONFIG_REG_ADDR  = 8'h02,
                 OLED_VGN_ADC_LLIMIT_REG_ADDR  = 8'h03,
                 OLED_VGN_ADC_HLIMIT_REG_ADDR  = 8'h04,
                 OLED_VGN_ADC_HYST_REG_ADDR    = 8'h05,
                 OLED_VGN_ADC_LCONV_REG_ADDR   = 8'h06,
                 OLED_VGN_ADC_HCONV_REG_ADDR   = 8'h07;

localparam [7:0]  BAT_GUAGE_STATUS_REG_ADDR      = 8'h00,
                 BAT_GUAGE_CONTROL_REG_ADDR     = 8'h01,
                 BAT_GUAGE_ACC_CHARGEM_REG_ADDR = 8'h02,
                 BAT_GUAGE_ACC_CHARGEL_REG_ADDR = 8'h03,
                 BAT_GUAGE_HTH_CHARGEM_REG_ADDR = 8'h04,
                 BAT_GUAGE_HTH_CHARGEL_REG_ADDR = 8'h05,
                 BAT_GUAGE_LTH_CHARGEM_REG_ADDR = 8'h06,
                 BAT_GUAGE_LTH_CHARGEL_REG_ADDR = 8'h07,
                 BAT_GUAGE_VOLTAGEM_REG_ADDR    = 8'h08,
                 BAT_GUAGE_VOLTAGEL_REG_ADDR    = 8'h09,
                 BAT_GUAGE_HTH_VOLTAGE_REG_ADDR = 8'h0A,
                 BAT_GUAGE_LTH_VOLTAGE_REG_ADDR = 8'h0B,
                 BAT_GUAGE_TEMPM_REG_ADDR       = 8'h0C,
                 BAT_GUAGE_TEMPL_REG_ADDR       = 8'h0D,
                 BAT_GUAGE_HTH_TEMP_REG_ADDR    = 8'h0E, 
                 BAT_GUAGE_LTH_TEMP_REG_ADDR    = 8'h0F;                  


localparam [7:0] cf_reg_cnt    = 8'd9;
localparam [7:0] gl_gc_reg_cnt = 8'd9;

localparam [7:0] gl1_addr = 8'd0,
                gc0_addr = gl1_addr + gl_gc_reg_cnt,
                gc1_addr = gc0_addr + gl_gc_reg_cnt,
                gc2_addr = gc1_addr + gl_gc_reg_cnt,
                gc3_addr = gc2_addr + gl_gc_reg_cnt,
                gc4_addr = gc3_addr + gl_gc_reg_cnt,
                gc5_addr = gc4_addr + gl_gc_reg_cnt,
                gc6_addr = gc5_addr + gl_gc_reg_cnt,
                gc7_addr = gc6_addr + gl_gc_reg_cnt;
         
localparam [6:0] SHUTTER_ADDR         = 7'b1010010;
localparam [7:0] SHUTTER_REG_ADDRESS  = 8'h17,
                 SHUTTER_ON_DATA_LSB  = 8'h01,
                 SHUTTER_ON_DATA_MSB  = 8'h00,
                 SHUTTER_OFF_DATA_LSB = 8'h00,
                 SHUTTER_OFF_DATA_MSB = 8'h00,
                 SHUTTER_DATA_LSB     = 8'h00,
                 SHUTTER_DATA_MSB     = 8'h00;
                                  
//localparam [7:0] SENSOR_DBIAS          = 1,       
//                SENSOR_COARSE_OFFSET  = 5,               
//                SENSOR_HEAT_COMP      = 4,           
//                SENSOR_TEMP_OFFSET    = 3;             

parameter [15:0] SENSOR_GFID_ADDR      = 16'h004B,
                 SENSOR_GSK_ADDR       = 16'h004C,
                 SENSOR_GSK_ADDR1      = 16'h004D,
                 SENSOR_INT_TIME_ADDR  = 16'h004F,
                 SENSOR_INT_TIME_ADDR1 = 16'h0050,
                 SENSOR_GAIN_ADDR      = 16'h0040;                 
                 

localparam   [31:0] OFFSET_64KB = 32'h10000,
                   OFFSET_32KB = 32'h08000,
                   OFFSET_4KB  = 32'h01000;   

localparam [31:0] qspi_init_st_addr  = 32'h00640000; //(sector 100th)
localparam [8:0]  qspi_init_rd_len   = 9'd14;   //(cmd = 2byte, src_addr = 4byte,dest_addr = 4byte,data_transfer_len = 4byte)
localparam [8:0]  qspi_block_rd_size = 256; // 256 byte read data
localparam [8:0]  qspi_block_wr_size = 256; // 256 byte write data                   

            
localparam  QSPI_ADDR_WIDTH = 32,
           QSPI_DATA_WIDTH = 8,
           QSPI_CMD_WIDTH  = 8;            