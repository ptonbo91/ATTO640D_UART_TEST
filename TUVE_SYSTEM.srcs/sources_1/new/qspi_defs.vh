`define CMD_RESET_ENABLE        8'h66 
`define CMD_RESET_MEMORY        8'h99
`define CMD_RECOVERY            8'haa
`define CMD_POWER_LOSS_RECOVERY 8'hbb
`define CMD_INTERFACE_RESCUE    8'hcc

`define CMD_RDID 8'h9F
`define CMD_MIORDID 8'hAF
`define CMD_RDSR 8'h05
`define CMD_RFSR 8'h70
`define CMD_RDVECR 8'h65
`define CMD_WRVECR 8'h61
`define CMD_WREN 8'h06
`define CMD_SE_64KB 8'hD8  // D8- Sector erase 20 = 4Kb erase 52= 32kb Erase
`define CMD_SE_32KB 8'h52
`define CMD_SE_4KB 8'h20
`define CMD_BE 8'hC7
`define CMD_PP 8'h12
`define CMD_QCFR 8'h0B

`define JEDEC_ID 8'h20

`define tPPmax 'd5 //ms
`define tBEmax 'd250_000 //ms
`define tSEmax 'd3_000 //ms
`define input_freq 'd31_250 //kHz

`define CMD_READ 8'h0C   // 03=SPIX1 Read, 0B = SPIX4 Read 0c = 4byte
`define CMD_WRDIS 8'h04
`define CMD_WREXADDR 8'hc5
`define CMD_RDEXADDR 8'hc8
`define CMD_EN4BYTE 8'hb7   // 4-Byte Address Mode Enable 
`define CMD_DIS4BYTE 8'he9   // 4-Byte Address Mode Enable 
