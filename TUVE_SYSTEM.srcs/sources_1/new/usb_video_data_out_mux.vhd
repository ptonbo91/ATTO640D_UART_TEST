library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity usb_video_data_out_mux is
----------------------------------
  generic ( 

    PIX_BITS          : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS          : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image  
    DATA_BITS         : positive               
  );
  port (
    -- Clock and Reset
    clk                         : in  std_logic;                              -- Module Clock
    rst                         : in  std_logic;                              -- Module Reset (Asynchronous active high)
    mux_sel                     : in  std_logic;                              -- USB data out selection signal
    video_i_v_sn                : in  std_logic;         
    video_i_h_sn                : in  std_logic;
    video_i_dav_sn              : in  std_logic;
    video_i_data_sn             : in  std_logic_vector(DATA_BITS-1 downto 0);
    video_i_eoi_sn              : in  std_logic;
    video_i_xsize_sn            : in  std_logic_vector(PIX_BITS-1 downto 0);
    video_i_ysize_sn            : in  std_logic_vector(LIN_BITS-1 downto 0);
    video_v_proc                : in  std_logic;
    video_h_proc                : in  std_logic;
    video_dav_proc              : in  std_logic;
    video_data_proc             : in  std_logic_vector(DATA_BITS-1 downto 0);
    video_eoi_proc              : in  std_logic;
    video_xsize_proc            : in  std_logic_vector(PIX_BITS-1 downto 0);
    video_ysize_proc            : in  std_logic_vector(LIN_BITS-1 downto 0);
    disable_update_gfid_gsk     : out std_logic;
    usb_v                       : out std_logic;
    usb_h                       : out std_logic;
    usb_dav                     : out std_logic;
    usb_data                    : out std_logic_vector(DATA_BITS-1 downto 0);
    usb_eoi                     : out std_logic;
    usb_video_xsize             : out std_logic_vector(PIX_BITS-1 downto 0);
    usb_video_ysize             : out std_logic_vector(LIN_BITS-1 downto 0)
  );
----------------------------------
end entity usb_video_data_out_mux;
----------------------------------


architecture RTL of usb_video_data_out_mux is

signal latch_mux_sel : std_logic;

begin

    process(clk, rst)                
        begin                             
        if rst = '1' then              
            usb_v           <= '0';
            usb_h           <= '0';
            usb_dav         <= '0';
            usb_data        <= (others=>'0');
            usb_eoi         <= '0';
            latch_mux_sel   <= '0';  
            usb_video_xsize <= std_logic_vector(to_unsigned(640,PIX_BITS));
            usb_video_ysize <= std_logic_vector(to_unsigned(480,LIN_BITS));
        elsif rising_edge(clk)then
            if(video_eoi_proc = '1' and latch_mux_sel = '0')then
                latch_mux_sel <= mux_sel;
            elsif(video_i_eoi_sn = '1' and latch_mux_sel = '1')then
                latch_mux_sel <= mux_sel;
            end if;    

            if(latch_mux_sel ='1')then
                usb_v           <= video_i_v_sn   ;
                usb_h           <= video_i_h_sn   ;
                usb_dav         <= video_i_dav_sn ;
                usb_data        <= video_i_data_sn(7 downto 0) & video_i_data_sn(15 downto 8); 
                usb_eoi         <= video_i_eoi_sn ;
                usb_video_xsize <= video_i_xsize_sn;
                usb_video_ysize <= video_i_ysize_sn;
                disable_update_gfid_gsk <= '1';
            else             
                usb_v           <= video_v_proc;    
                usb_h           <= video_h_proc;     
                usb_dav         <= video_dav_proc;   
                usb_data        <= video_data_proc;  
                usb_eoi         <= video_eoi_proc; 
                usb_video_xsize <= video_xsize_proc;
                usb_video_ysize <= video_ysize_proc;
                disable_update_gfid_gsk <= '0';
            end if;      
--                usb_v           <= video_i_v_sn   ;
--                usb_h           <= video_i_h_sn   ;
--                usb_dav         <= video_i_dav_sn ;
--                usb_data        <= video_i_data_sn(7 downto 0) & video_i_data_sn(15 downto 8); 
--                usb_eoi         <= video_i_eoi_sn ;
--                usb_video_xsize <= video_i_xsize_sn;
--                usb_video_ysize <= video_i_ysize_sn;
--                disable_update_gfid_gsk <= '0';


        end if;
    end process;     

--------------------------
end architecture RTL;
--------------------------
    