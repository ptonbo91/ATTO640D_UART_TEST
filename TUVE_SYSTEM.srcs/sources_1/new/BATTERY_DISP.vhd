library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
   

----------------------------------
entity BATTERY_DISPLAY is
----------------------------------
  generic ( 

    PIX_BITS          : positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line
    LIN_BITS          : positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image  
    CH_ROM_ADDR_WIDTH : positive;
    CH_ROM_DATA_WIDTH : positive;
    CH_PER_BYTE       : positive;
    BATTERY_DIV_W     : positive
  );
  port (
    -- clock and reset
    clk                         : in  std_logic;                              -- module clock
    rst                         : in  std_logic;                              -- module reset (asynchronous active high)
    OSD_EN_OUT                  : in std_logic;
    battery_disp_en             : in  std_logic;                              -- enable battery display   
--    battery_disp_color_info     : in  std_logic_vector( 23 downto 0);     
--    ch_color_info1              : in  std_logic_vector( 23 downto 0);     
--    ch_color_info2              : in  std_logic_vector( 23 downto 0);     
    battery_disp_color_info     : in  std_logic_vector(7 downto 0);     
    ch_color_info1              : in  std_logic_vector(7 downto 0);     
    ch_color_info2              : in  std_logic_vector(7 downto 0);    
    battery_disp_pos_x          : in  std_logic_vector(PIX_BITS-1 downto 0);  -- battery display position x
    battery_disp_pos_y          : in  std_logic_vector(LIN_BITS-1 downto 0);  -- battery display position y
    battery_disp_x_offset       : in  std_logic_vector(PIX_BITS-1 downto 0);  -- battery display position x offset to draw battry symbol
    battery_disp_y_offset       : in  std_logic_vector(LIN_BITS-1 downto 0);  -- battery display position y offset to draw battry symbol
    bat_per_disp_en             : in  std_logic;             
--    bat_per_disp_color_info     : in  std_logic_vector( 23 downto 0);      
--    bat_per_disp_ch_color_info1 : in  std_logic_vector( 23 downto 0);   
--    bat_per_disp_ch_color_info2 : in  std_logic_vector( 23 downto 0);   
    bat_per_disp_color_info     : in  std_logic_vector(7 downto 0);
    bat_per_disp_ch_color_info1 : in  std_logic_vector(7 downto 0);
    bat_per_disp_ch_color_info2 : in  std_logic_vector(7 downto 0);
    bat_per_disp_pos_x          : in  std_logic_vector(PIX_BITS-1 downto 0);            
    bat_per_disp_pos_y          : in  std_logic_vector(LIN_BITS-1 downto 0);  
    bat_per_disp_req_xsize      : in  std_logic_vector(PIX_BITS-1 downto 0);
    bat_per_disp_req_ysize      : in  std_logic_vector(LIN_BITS-1 downto 0);    
    bat_chg_symbol_en           : in  std_logic;
    bat_chg_symbol_pos_offset   : in  std_logic_vector(PIX_BITS downto 0);      
    bat_per_conv_reg1           : in  std_logic_vector(23 downto 0);
    bat_per_conv_reg2           : in  std_logic_vector(23 downto 0);
    bat_per_conv_reg3           : in  std_logic_vector(23 downto 0);
    bat_per_conv_reg4           : in  std_logic_vector(23 downto 0);
    bat_per_conv_reg5           : in  std_logic_vector(23 downto 0);
    bat_per_conv_reg6           : in  std_logic_vector(23 downto 0);
            
    ch_img_width                : in  std_logic_vector( 9 downto 0);          
    ch_img_height               : in  std_logic_vector( 9 downto 0);          
    battery_disp_req_v          : in  std_logic;                              -- scaler new frame request
    battery_disp_req_h          : in  std_logic;                              -- scaler new line request
    battery_disp_field          : in  std_logic;                              -- field
    battery_disp_req_xsize      : in  std_logic_vector(pix_bits-1 downto 0);   
    battery_disp_req_ysize      : in  std_logic_vector(lin_bits-1 downto 0);  
--    battery_percentage          : in  std_logic_vector(7 downto 0);
    battery_disp_tg_wait_frames : in std_logic_vector(7 downto 0);
    battery_voltage             : in  std_logic_vector(15 downto 0);
    battery_pix_map             : in  std_logic_vector(7 downto 0);
    battery_charging_start      : in  std_logic;
    battery_charge_inc          : in  std_logic_Vector(15 downto 0); -- LSB INTERVAL , MSB INC STEP SIZE
    polarity                    : in  std_logic;   
    video_in_v                  : in  std_logic;                             
    video_in_h                  : in  std_logic;
    video_in_dav                : in  std_logic;                            
--    video_in_data               : in  std_logic_vector(23 downto 0);  
    video_in_data               : in  std_logic_vector(7 downto 0);         
    video_in_eoi                : in  std_logic;
    video_in_xsize              : in  std_logic_vector(pix_bits-1 downto 0);  
    video_in_ysize              : in  std_logic_vector(lin_bits-1 downto 0);     
    battery_disp_v_out          : out std_logic;                              
    battery_disp_h_out          : out std_logic;
    battery_disp_dav_out        : out std_logic;                              
--    battery_disp_data_out       : out std_logic_vector(23 downto 0);  
    battery_disp_data_out       : out std_logic_vector(7 downto 0);          
    battery_disp_eoi_out        : out std_logic
   
  );
----------------------------------
end entity battery_display;
----------------------------------

------------------------------------------
architecture rtl of battery_display is
------------------------------------------

COMPONENT ila_0

PORT (
  clk : IN STD_LOGIC;



  probe0 : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
);
END COMPONENT;

 signal probe0 : std_logic_vector(127 downto 0);
 signal latch_battery_disp_en         : std_logic;
 signal latch_battery_disp_pos_x      : std_logic_vector(PIX_BITS-1 downto 0);
 signal latch_battery_disp_pos_y      : std_logic_vector(LIN_BITS-1 downto 0);
 signal latch_battery_disp_req_xsize  : std_logic_vector(PIX_BITS-1 downto 0);
 signal latch_battery_disp_req_ysize  : std_logic_vector(LIN_BITS-1 downto 0);
 signal latch_battery_disp_x_offset   : std_logic_vector(PIX_BITS-1 downto 0);
 signal latch_battery_disp_y_offset   : std_logic_vector(LIN_BITS-1 downto 0);
-- signal latch_battery_disp_color_info : std_logic_vector(23 downto 0);
-- signal latch_ch_color_info1          : std_logic_vector(23 downto 0);
-- signal latch_ch_color_info2          : std_logic_vector(23 downto 0);
 signal latch_battery_disp_color_info : std_logic_vector(7 downto 0);
 signal latch_ch_color_info1          : std_logic_vector(7 downto 0);
 signal latch_ch_color_info2          : std_logic_vector(7 downto 0);
 signal line_cnt                      : unsigned(LIN_BITS-1 downto 0);
 signal pix_cnt                       : unsigned(PIX_BITS-1 downto 0);
 signal video_in_v_d                  : std_logic;
 signal video_in_v_dd                 : std_logic;
 signal video_in_v_ddd                : std_logic;
 signal video_in_h_d                  : std_logic;
 signal video_in_h_dd                 : std_logic;
 signal video_in_h_ddd                : std_logic;
 signal video_in_dav_d                : std_logic;
 signal video_in_dav_dd               : std_logic;
 signal video_in_dav_ddd              : std_logic;
-- signal video_in_data_d               : std_logic_vector(23 downto 0);
-- signal video_in_data_dd              : std_logic_vector(23 downto 0);
-- signal video_in_data_ddd             : std_logic_vector(23 downto 0);
 signal video_in_data_d               : std_logic_vector(7 downto 0);
 signal video_in_data_dd              : std_logic_vector(7 downto 0);
 signal video_in_data_ddd             : std_logic_vector(7 downto 0);
 signal video_in_eoi_d                : std_logic;
 signal video_in_eoi_dd               : std_logic;
 signal video_in_eoi_ddd              : std_logic;
 signal battery_per_disp_offset       : std_logic_vector(7 downto 0);
 signal start_div                     : std_logic;
 signal dvsr                          : std_logic_vector(BATTERY_DIV_W -1 downto 0);
 signal dvnd                          : std_logic_vector(BATTERY_DIV_W -1 downto 0);
 signal done_tick                     : std_logic;
 signal quo                           : std_logic_vector(BATTERY_DIV_W -1 downto 0);
 signal rmd                           : std_logic_vector(BATTERY_DIV_W -1 downto 0);
 signal battery_percentage_d          : std_logic_vector(7 downto 0);  -- to show battry display bar
 signal battery_pix_map_d             : std_logic_vector(7 downto 0);
 signal cnt                           : unsigned(7 downto 0);
 signal first_time                    : std_logic;
 signal battery_disp_v                : std_logic;                              
 signal battery_disp_h                : std_logic;
 signal battery_disp_dav              : std_logic;                             
-- signal battery_disp_data             : std_logic_vector(23 downto 0);    
 signal battery_disp_data             : std_logic_vector(7 downto 0);       
 signal battery_disp_eoi              : std_logic;  
 signal battery_disp_toggle           : std_logic;
 signal battery_disp_toggle_en        : std_logic;
 signal battery_disp_toggle_cnt       : unsigned(7 downto 0);
 signal battery_percentage            : std_logic_vector(7 downto 0); -- to show battery percentage number 


--  ATTRIBUTE KEEP : string;
--  ATTRIBUTE KEEP of  line_cnt: SIGNAL IS "TRUE";
--  ATTRIBUTE KEEP of  pix_cnt: SIGNAL IS "TRUE";
-- ATTRIBUTE KEEP of  VIDEO_IN_H       : SIGNAL IS "TRUE";             
-- ATTRIBUTE KEEP of  VIDEO_IN_V       : SIGNAL IS "TRUE";             
-- ATTRIBUTE KEEP of  VIDEO_IN_DAV     : SIGNAL IS "TRUE";           
-- ATTRIBUTE KEEP of  video_in_v_d     : SIGNAL IS "TRUE" ;     
-- ATTRIBUTE KEEP of  video_in_v_dd    : SIGNAL IS "TRUE" ;     
-- ATTRIBUTE KEEP of  video_in_v_ddd   : SIGNAL IS "TRUE" ;     
-- ATTRIBUTE KEEP of  video_in_h_d     : SIGNAL IS "TRUE" ;     
-- ATTRIBUTE KEEP of  video_in_h_dd    : SIGNAL IS "TRUE" ;     
-- ATTRIBUTE KEEP of  video_in_h_ddd   : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_dav_d   : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_dav_dd  : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_dav_ddd : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_eoi_d   : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_eoi_dd  : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of  video_in_eoi_ddd : SIGNAL IS "TRUE";      
-- ATTRIBUTE KEEP of latch_battery_disp_pos_y     : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of latch_battery_disp_req_ysize : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of video_in_data_dd             : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of video_in_data_ddd            : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of battery_disp_en              : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of battery_disp_y_offset        : SIGNAL IS "TRUE"; 
-- ATTRIBUTE KEEP of OSD_EN_OUT                   : SIGNAL IS "TRUE"; 
  
  
--------
begin
--------


  -- ---------------------------------
  --  dma master read process
  -- ---------------------------------
  process(clk, rst)
  begin
    if rst = '1' then
      latch_battery_disp_en         <= '0';
      latch_battery_disp_pos_x      <= (others=>'0');
      latch_battery_disp_pos_y      <= (others=>'0');
      latch_battery_disp_req_xsize  <= (others=>'0');
      latch_battery_disp_req_ysize  <= (others=>'0');
      latch_battery_disp_color_info <= (others=>'0');
      latch_ch_color_info1          <= (others=>'0');
      latch_ch_color_info2          <= (others=>'0');
      line_cnt                      <= (others=>'0');
      pix_cnt                       <= (others=>'0');
      video_in_v_d                  <= '0';
      video_in_v_dd                 <= '0';
      video_in_v_ddd                <= '0';
      video_in_h_d                  <= '0';
      video_in_h_dd                 <= '0';
      video_in_h_ddd                <= '0';
      video_in_dav_d                <= '0';
      video_in_dav_dd               <= '0';
      video_in_dav_ddd              <= '0';
      video_in_data_d               <= (others=>'0');
      video_in_data_dd              <= (others=>'0');
      video_in_data_ddd             <= (others=>'0');
      video_in_eoi_d                <= '0';
      video_in_eoi_dd               <= '0';
      video_in_eoi_ddd              <= '0';
      battery_per_disp_offset       <= (others=>'0');
      start_div                     <= '0'; 
      dvsr                          <= (others=>'0');
      latch_battery_disp_x_offset   <= std_logic_vector(to_unsigned(4,latch_battery_disp_x_offset'length));
      latch_battery_disp_y_offset   <= std_logic_vector(to_unsigned(4,latch_battery_disp_y_offset'length));
      battery_percentage_d          <= (others=>'0');
      battery_percentage            <= (others=>'0');
      battery_pix_map_d             <= (others=>'0');
      cnt                           <= (others=>'0');
      first_time                    <= '1';
      battery_disp_toggle           <= '0';
      battery_disp_toggle_en        <= '0';
      battery_disp_toggle_cnt       <= (others=>'0');
    elsif rising_edge(clk) then

      video_in_v_d      <= video_in_v;
      video_in_v_dd     <= video_in_v_d;
      video_in_v_ddd    <= video_in_v_dd;
      video_in_h_d      <= video_in_h;
      video_in_h_dd     <= video_in_h_d;
      video_in_h_ddd    <= video_in_h_dd;
      video_in_dav_d    <= video_in_dav;
      video_in_dav_dd   <= video_in_dav_d;
      video_in_dav_ddd  <= video_in_dav_dd;
      video_in_data_d   <= video_in_data;
      video_in_data_dd  <= video_in_data_d;
      video_in_data_ddd <= video_in_data_dd; 
      video_in_eoi_d    <= video_in_eoi;
      video_in_eoi_dd   <= video_in_eoi_d;
      video_in_eoi_ddd  <= video_in_eoi_dd;
      start_div         <= '0';
      
      if video_in_v = '1' then
          line_cnt <= (others=>'0');
          pix_cnt  <= (others=>'0');
          
          if(battery_disp_field = '0')then                                                                       
--             latch_battery_disp_en         <= battery_disp_en ;
             if(battery_disp_en = '1')then
                latch_battery_disp_en <='1' and not(battery_disp_toggle);
             else
                latch_battery_disp_en         <= '0' ;
             end if;   
             latch_battery_disp_pos_x      <= battery_disp_pos_x;
             latch_battery_disp_pos_y      <= battery_disp_pos_y;
             latch_battery_disp_req_xsize  <= battery_disp_req_xsize;
             latch_battery_disp_req_ysize  <= battery_disp_req_ysize;             
             
             if(unsigned(battery_disp_x_offset)<unsigned(battery_disp_req_xsize))then
                latch_battery_disp_x_offset   <= battery_disp_x_offset;
             else
                latch_battery_disp_x_offset   <= std_logic_vector(unsigned(battery_disp_req_xsize) -1);
             end if;
             if(unsigned(battery_disp_y_offset) < (unsigned(battery_disp_req_ysize(LIN_BITS-1 downto 0))))then
                latch_battery_disp_y_offset   <= battery_disp_y_offset;
             else
                latch_battery_disp_y_offset   <= std_logic_vector((unsigned(battery_disp_req_ysize(LIN_BITS-1 downto 0))-1));
             end if;
             if(battery_charging_start= '1')then
                if(cnt >= unsigned(battery_charge_inc(7 downto 0)))then
                    if(unsigned(battery_percentage_d) >= 100)then
                        battery_percentage_d <= (others=>'0');
                    else
                        battery_percentage_d <= std_logic_Vector(unsigned(battery_percentage_d) + unsigned(battery_charge_inc(15 downto 8)));
                        cnt                  <= (others=>'0');
                    end if;    
                else
                    cnt <= cnt + 1; 
                    if(first_time = '1')then
                        battery_percentage_d <= (others=>'0');
                        first_time           <= '0';
                    end if;     
                end if;
                battery_pix_map_d    <= battery_pix_map;
                if(battery_voltage >= bat_per_conv_reg6(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg6(23 downto 16);
                elsif(battery_voltage >= bat_per_conv_reg5(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg5(23 downto 16);
                elsif(battery_voltage >= bat_per_conv_reg4(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg4(23 downto 16);
                elsif(battery_voltage >= bat_per_conv_reg3(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg3(23 downto 16);
                elsif(battery_voltage >= bat_per_conv_reg2(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg2(23 downto 16);
                elsif(battery_voltage >= bat_per_conv_reg1(15 downto 0))then
                    battery_percentage    <= bat_per_conv_reg1(23 downto 16);
                else
                    battery_percentage    <= std_logic_vector(to_unsigned(1,battery_percentage_d'length));
                end if;                
             else
--                if(battery_voltage <= bat_per_conv_reg1(15 downto 0))then
--                    battery_percentage_d  <= std_logic_vector(to_unsigned(0,battery_percentage_d'length));
--                    battery_percentage    <= bat_per_conv_reg1(23 downto 16);
--                    battery_disp_toggle_en<= '1';
--                elsif(battery_voltage <= bat_per_conv_reg2(15 downto 0))then
--                    battery_percentage_d  <= std_logic_vector(to_unsigned(0,battery_percentage_d'length));
--                    battery_percentage    <= bat_per_conv_reg2(23 downto 16);
--                    battery_disp_toggle_en<= '0';
--                elsif(battery_voltage <= bat_per_conv_reg3(15 downto 0))then
--                    battery_percentage_d  <= bat_per_conv_reg3(23 downto 16);
--                    battery_percentage    <= bat_per_conv_reg3(23 downto 16);
--                    battery_disp_toggle_en<= '0';
--                elsif(battery_voltage <= bat_per_conv_reg4(15 downto 0))then
--                    battery_percentage_d  <= bat_per_conv_reg4(23 downto 16);
--                    battery_percentage    <= bat_per_conv_reg4(23 downto 16);
--                    battery_disp_toggle_en<= '0';
--                elsif(battery_voltage <= bat_per_conv_reg5(15 downto 0))then
--                    battery_percentage_d  <= bat_per_conv_reg5(23 downto 16);
--                    battery_percentage    <= bat_per_conv_reg5(23 downto 16);
--                    battery_disp_toggle_en<= '0';
--                elsif(battery_voltage >= bat_per_conv_reg6(15 downto 0))then
--                    battery_percentage_d  <= bat_per_conv_reg6(23 downto 16);
--                    battery_percentage    <= bat_per_conv_reg6(23 downto 16);
--                    battery_disp_toggle_en<= '0';
--                end if;

                if(battery_voltage >= bat_per_conv_reg6(15 downto 0))then
                    battery_percentage_d  <= bat_per_conv_reg6(23 downto 16);
                    battery_percentage    <= bat_per_conv_reg6(23 downto 16);
                    battery_disp_toggle_en<= '0';
                elsif(battery_voltage >= bat_per_conv_reg5(15 downto 0))then
                    battery_percentage_d  <= bat_per_conv_reg5(23 downto 16);
                    battery_percentage    <= bat_per_conv_reg5(23 downto 16);
                    battery_disp_toggle_en<= '0';
                elsif(battery_voltage >= bat_per_conv_reg4(15 downto 0))then
                    battery_percentage_d  <= bat_per_conv_reg4(23 downto 16);
                    battery_percentage    <= bat_per_conv_reg4(23 downto 16);
                    battery_disp_toggle_en<= '0';
                elsif(battery_voltage >= bat_per_conv_reg3(15 downto 0))then
                    battery_percentage_d  <= bat_per_conv_reg3(23 downto 16);
                    battery_percentage    <= bat_per_conv_reg3(23 downto 16);
                    battery_disp_toggle_en<= '0';
                elsif(battery_voltage >= bat_per_conv_reg2(15 downto 0))then
                    battery_percentage_d  <= std_logic_vector(to_unsigned(0,battery_percentage_d'length));
                    battery_percentage    <= bat_per_conv_reg2(23 downto 16);
                    battery_disp_toggle_en<= '0';
                elsif(battery_voltage >= bat_per_conv_reg1(15 downto 0))then
                    battery_percentage_d  <= std_logic_vector(to_unsigned(0,battery_percentage_d'length));
                    battery_percentage    <= bat_per_conv_reg1(23 downto 16);
                    battery_disp_toggle_en<= '1';
                else
                    battery_percentage_d  <= std_logic_vector(to_unsigned(0,battery_percentage_d'length));
                    battery_percentage    <= std_logic_vector(to_unsigned(1,battery_percentage_d'length));
                    battery_disp_toggle_en<= '1';
                end if;
             
                if(battery_disp_toggle_en = '1')then
                    if(battery_disp_toggle_cnt >= unsigned(battery_disp_tg_wait_frames))then
                        if(battery_disp_toggle = '0')then
                            battery_disp_toggle <= '1';
                        else
                            battery_disp_toggle <= '0';
                        end if;
                        battery_disp_toggle_cnt <= (others=>'0');    
                    else
                        battery_disp_toggle_cnt <= battery_disp_toggle_cnt + 1;                        
                    end if;     
                else
                    battery_disp_toggle     <= '0';
                    battery_disp_toggle_cnt <= (others=>'0');
                end if;
                
                  
--                battery_percentage_d <= battery_percentage;  
                battery_pix_map_d    <= battery_pix_map;
                cnt                  <= (others=>'0');
                first_time            <= '1';
             end if;
             latch_battery_disp_color_info <= battery_disp_color_info;
             latch_ch_color_info1          <= ch_color_info1;
             latch_ch_color_info2          <= ch_color_info2; 
             dvnd                          <= battery_percentage_d; 
             dvsr                          <= battery_pix_map_d; 
             start_div                     <= '1';
                    
          else
             latch_battery_disp_en         <= latch_battery_disp_en;
             latch_battery_disp_pos_x      <= latch_battery_disp_pos_x;
             latch_battery_disp_pos_y      <= latch_battery_disp_pos_y;
             latch_battery_disp_req_xsize  <= latch_battery_disp_req_xsize;
             latch_battery_disp_req_ysize  <= latch_battery_disp_req_ysize;  
             latch_battery_disp_x_offset   <= latch_battery_disp_x_offset;
             latch_battery_disp_y_offset   <= latch_battery_disp_y_offset;         
             latch_battery_disp_color_info <= latch_battery_disp_color_info;
             latch_ch_color_info1          <= latch_ch_color_info1;
             latch_ch_color_info2          <= latch_ch_color_info2;
--             battery_per_disp_offset       <= battery_per_disp_offset;
          end if;
          
      end if;

      if done_tick ='1'then
        battery_per_disp_offset <= quo;
      else
        battery_per_disp_offset <= battery_per_disp_offset;
      end if;
      
      if video_in_h_d = '1'then
        line_cnt <= line_cnt + 1;
        pix_cnt  <= (others=>'0');
      end if;  
      
      if video_in_dav_dd = '1'then
        pix_cnt  <= pix_cnt + 1;
      end if;  


      if(((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0))))) and(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))))) and (latch_battery_disp_en ='1')) then
         if((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))+ unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0)) - unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))))))then
           if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset))))then
            battery_disp_data <= ch_color_info2; 
           else
            battery_disp_data <= battery_disp_color_info; 
           end if;
         elsif((((line_cnt -1)=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))+ unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))-1) or ((line_cnt -1) =(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0)) - unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))))))then
           if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned(latch_battery_disp_x_offset))))then
             if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset))))then
              battery_disp_data <= ch_color_info2; 
             else
              battery_disp_data <= battery_disp_color_info; 
             end if;
           else                
              if(((pix_cnt -1)>=(unsigned(latch_battery_disp_pos_x)))and((pix_cnt -1)<=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))))then
                  battery_disp_data <= ch_color_info1;
              else 
                  battery_disp_data <= video_in_data_ddd;
              end if;
           end if;          
         else
           if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned(latch_battery_disp_x_offset))))then
             if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset))))then
              battery_disp_data <= ch_color_info2; 
             else
              battery_disp_data <= battery_disp_color_info; 
             end if;
           else                
              if(((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned(latch_battery_disp_x_offset)) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))+1 - unsigned(latch_battery_disp_x_offset))))then
                  battery_disp_data <= ch_color_info1;
              else 
                  battery_disp_data <= video_in_data_ddd;
              end if;
           end if; 
         end if;  
      else
        if((((line_cnt -1)= unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))-1) or ((line_cnt -1) =(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0))))) and (latch_battery_disp_en ='1'))then
            if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)-2) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) +2 - unsigned(latch_battery_disp_x_offset))))then
                battery_disp_data <= ch_color_info1;
            else              
               if(unsigned(latch_battery_disp_y_offset) = 0 or unsigned(latch_battery_disp_y_offset) = 1)then
                if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)-2) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) +2 )))then
                    battery_disp_data <= ch_color_info1;
                else
                    battery_disp_data <= video_in_data_ddd;
                end if;    
               else   
                battery_disp_data <= video_in_data_ddd;
               end if; 
            end if;    
        elsif((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0)))))and (latch_battery_disp_en ='1'))then 
              if((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0))+ unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))-1) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 0)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 0)) - unsigned(latch_battery_disp_y_offset(LIN_BITS-1 downto 0))+1))))then              
--              else
                  if(((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-1 or (pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-2) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize)) or (pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))+1))then
                      battery_disp_data <= ch_color_info1;
                  else 
                      battery_disp_data <= video_in_data_ddd;
                  end if; 
              else
                if(unsigned(latch_battery_disp_x_offset) = 0)then
                  if(((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-1 or (pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-2) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize)) or (pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))+1))then
                      battery_disp_data <= ch_color_info1;
                  else 
                      battery_disp_data <= video_in_data_ddd;
                  end if;  
                else
                  if(((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-1 or (pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-2))then
                      battery_disp_data <= ch_color_info1;
                  else 
                      battery_disp_data <= video_in_data_ddd;
                  end if;

                end if;                  
                
              end if;  
        else
            battery_disp_data <= video_in_data_ddd;          
        end if;     
      end if;


--      if(((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))))) and(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))))) and (latch_battery_disp_en ='1')) then
--       if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset))))then
--        battery_disp_data <= ch_color_info2; 
--       else
--        battery_disp_data <= battery_disp_color_info; 
--       end if;
--      else
--        if((((line_cnt -1)= unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))-1) or ((line_cnt -1) =(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))))) and (latch_battery_disp_en ='1'))then
--            if(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)-2) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) +2)))then
--                battery_disp_data <= ch_color_info1;
--            else
--                battery_disp_data <= video_in_data_ddd;
--            end if;    
--        elsif((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1)))))and (latch_battery_disp_en ='1'))then 
--            if(((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-1 or (pix_cnt -1)=unsigned(latch_battery_disp_pos_x)-2) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize)) or (pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))+1))then
--                battery_disp_data <= ch_color_info1;
--            else 
--                battery_disp_data <= video_in_data_ddd;
--            end if;   
--        else
--            battery_disp_data <= video_in_data_ddd; 
--        end if;     
--      end if;

--      if(((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))))) and(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))))) and (latch_battery_disp_en ='1')) then
--       if(((line_cnt -1)= unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) or ((line_cnt -1) =(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))-1)) or ((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - 1)))then
--        battery_disp_data <= ch_color_info1; 
--       elsif(((pix_cnt -1)>unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset)) +1))then
--        battery_disp_data <= ch_color_info2; 
--       else
--        battery_disp_data <= battery_disp_color_info; 
--       end if;
--      else
--       battery_disp_data <= video_in_data_ddd; 
--      end if;
 
--      if(((((line_cnt -1)>=unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) and ((line_cnt -1) <(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))))) and(((pix_cnt -1)>=unsigned(latch_battery_disp_pos_x)) and ((pix_cnt -1) <(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize))))) and (latch_battery_disp_en ='1')) then
--       if(((line_cnt -1)= unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1))) or ((line_cnt -1) =(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))-1)) or ((pix_cnt -1)=unsigned(latch_battery_disp_pos_x)) or ((pix_cnt -1)=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - 1)))then
--        if((((pix_cnt -1)>=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned(battery_disp_x_offset))) and (((line_cnt -1) <=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) +unsigned(battery_disp_y_offset)))) and ((line_cnt -1) >=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))- unsigned(battery_disp_y_offset)))))then
--          battery_disp_data <= video_in_data_ddd;
--        else
--          battery_disp_data <= ch_color_info1;
--        end if;  
--       elsif(((pix_cnt -1)>unsigned(latch_battery_disp_pos_x)) and ((pix_cnt-1) <(unsigned(latch_battery_disp_pos_x) + unsigned(battery_per_disp_offset)+1)))then
--        if((((pix_cnt -1)>=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned((battery_disp_x_offset))) and(((line_cnt -1) <=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) +unsigned(battery_disp_y_offset)))) and ((line_cnt -1) >=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))-unsigned(battery_disp_y_offset))))))then
--          battery_disp_data <= video_in_data_ddd; 
--        else
--          battery_disp_data <= ch_color_info2;
--        end if;  
--       else
--        if(((((pix_cnt -1)>=(unsigned(latch_battery_disp_pos_x) + unsigned(latch_battery_disp_req_xsize) - unsigned(battery_disp_x_offset))) and (((line_cnt -1) <=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) +unsigned(battery_disp_y_offset)))) and ((line_cnt -1) >=(unsigned(latch_battery_disp_pos_y(LIN_BITS-1 downto 1)) + unsigned(latch_battery_disp_req_ysize(LIN_BITS-1 downto 1))-unsigned(battery_disp_y_offset))))))then
--          battery_disp_data <= video_in_data_ddd; 
--        else
--          battery_disp_data <= battery_disp_color_info; 
--        end if;
--       end if;
--      else
--       battery_disp_data <= video_in_data_ddd; 
--      end if; 
      
      battery_disp_v     <= video_in_v_ddd;   
      battery_disp_h     <= video_in_h_ddd;
      battery_disp_dav   <= video_in_dav_ddd;
      battery_disp_eoi   <= video_in_eoi_ddd;
    end if;

      
 end process;   


 i_BATTERY_PERCENTAGE_DISPLAY :entity WORK.BATTERY_PERCENTAGE_DISPLAY                                                                                            
 generic map(                                                                                                                                   
 PIX_BITS  => PIX_BITS,--: positive;                    -- 2**PIX_BITS = Maximum Number of pixels in a line                                   
 LIN_BITS  => LIN_BITS,--: positive;                    -- 2**LIN_BITS = Maximum Number of  lines in an image                                 
 CH_ROM_ADDR_WIDTH => 8,--7,
 CH_ROM_DATA_WIDTH => 16,--8
 CH_PER_BYTE       => 1
 )                                                                                                                                              
 port map (                                                                                                                                     
   -- Clock and Reset                                                                                                                           
   CLK                         => CLK,                                                      
   RST                         => RST,                            
   BAT_PER_DISP_EN             => bat_per_disp_en            ,   
   bat_per_disp_toggle         => battery_disp_toggle        ,
   BAT_CHG_SYMBOL_EN           => bat_chg_symbol_en          , 
   BATTERY_CHARGING_START      => battery_charging_start     ,                                                                                                                                                                               
   BAT_PER_DISP_COLOR_INFO     => bat_per_disp_color_info    ,
   CH_COLOR_INFO1              => bat_per_disp_ch_color_info1,                                                                                                 
   CH_COLOR_INFO2              => bat_per_disp_ch_color_info2,                                                                                              
   BAT_PER_DISP_POS_X          => bat_per_disp_pos_x         ,                                                                                               
   BAT_PER_DISP_POS_Y          => bat_per_disp_pos_y         ,
   BAT_CHG_SYMBOL_POS_OFFSET   => bat_chg_symbol_pos_offset  ,                                                                                                                                                                                                   
   CH_IMG_WIDTH_IN             => STD_LOGIC_VECTOR(to_unsigned(16, 10)),--STD_LOGIC_VECTOR(to_unsigned(8, 10)),
   CH_IMG_HEIGHT_IN            => STD_LOGIC_VECTOR(to_unsigned(16, LIN_BITS)), --STD_LOGIC_VECTOR(to_unsigned(8, LIN_BITS)),                                       
   BAT_PER_DISP_REQ_V          => battery_disp_req_v  ,                                         
   BAT_PER_DISP_REQ_H          => battery_disp_req_h  ,                                         
   BAT_PER_DISP_FIELD          => battery_disp_field  ,                                                                                                         
   BAT_PER_DISP_REQ_XSIZE1     => bat_per_disp_req_xsize,
   BAT_PER_DISP_REQ_YSIZE1     => bat_per_disp_req_ysize,                                                                                                                                                           
   VIDEO_IN_V                  => battery_disp_v   ,                   
   VIDEO_IN_H                  => battery_disp_h   ,                   
   VIDEO_IN_DAV                => battery_disp_dav ,                    
   VIDEO_IN_DATA               => battery_disp_data,                   
   VIDEO_IN_EOI                => battery_disp_eoi ,                  
   VIDEO_IN_XSIZE              => video_in_xsize  ,                                         
   VIDEO_IN_YSIZE              => video_in_ysize  ,                                                                                                                                                                                                                                                            
   BAT_PER_DISP_V              => battery_disp_v_out    ,  
   BAT_PER_DISP_H              => battery_disp_h_out    ,  
   BAT_PER_DISP_DAV            => battery_disp_dav_out  ,  
   BAT_PER_DISP_DATA           => battery_disp_data_out , 
   BAT_PER_DISP_EOI            => battery_disp_eoi_out  ,                                                                                                          
   POLARITY                    => polarity,
   BAT_PER                     => battery_percentage

 );   






i_battery_div : entity WORK.div
    generic map(
    W    => BATTERY_DIV_W,
    CBIT => 4
    )
    port map(
    clk       => CLK,
    reset     => RST,
    start     => start_div ,
    dvsr      => dvsr, 
    dvnd      => dvnd,
    done_tick => done_tick,
    quo       => quo, 
    rmd       => rmd
    );


--probe0(0)<= PRESET_INFO_DISP_DAVi;
--probe0(1)<= FIFO_EMP_PRESET_INFO_DISP;
--probe0(0) <= OSD_EN_OUT;
--probe0(1) <= battery_disp_toggle;
--probe0(2) <= VIDEO_IN_H;
--probe0(3) <= VIDEO_IN_V;
--probe0(4) <= VIDEO_IN_DAV;       
--probe0(5) <= video_in_v_d      ;
--probe0(6) <= video_in_v_dd     ;
--probe0(7) <= video_in_v_ddd    ;
--probe0(8) <= video_in_h_d      ;
--probe0(9) <= video_in_h_dd     ;
--probe0(10)<= video_in_h_ddd   ;
--probe0(11)<= video_in_dav_d   ;
--probe0(12)<= video_in_dav_dd  ;
--probe0(13)<= video_in_dav_ddd ;
--probe0(14)<= '0';
--probe0(15)<= '0';
--probe0(16)<= '0';
--probe0(17)<= video_in_eoi_d   ;
--probe0(18)<= video_in_eoi_dd  ;
--probe0(19)<= video_in_eoi_ddd ;
--probe0(29 downto 20)<= std_logic_Vector(line_cnt);          
--probe0(39 downto 30)<= std_logic_vector(pix_cnt);   
--probe0(49 downto 40)<= std_logic_vector(latch_battery_disp_pos_y);
--probe0(59 downto 50)<= std_logic_vector(latch_battery_disp_req_ysize);
--probe0(83 downto 60)<= video_in_data_dd  ;
--probe0(107 downto 84)<= video_in_data_ddd ;
--probe0(108) <=battery_disp_en;
--probe0(118 downto 109)<= battery_disp_y_offset;
--probe0(127 downto 119)<= (others=>'0');

--probe0(31 downto 22)<= std_logic_vector(to_unsigned(count,10));--FIFO_OUT;
--probe0(41 downto 32)<= std_logic_Vector(line_cnt);
--probe0(51 downto 42)<= std_logic_Vector(pix_cnt);
--probe0(52)<= PRESET_INFO_DISP_EN;
--probe0(53)<= PRESET_INFO_DISP_EN_D;
--probe0(54)<= FIFO_RD_PRESET_INFO_DISP;
--probe0(55)<= FIFO_WR_PRESET_INFO_DISP;
--probe0(65 downto 56)<=  std_logic_Vector(POS_X_CH_D);
--probe0(75 downto 66)<=  std_logic_Vector(pix_cnt_d);
--probe0(83 downto 76)<=  std_logic_Vector(lin_block_cnt_dd);
--probe0(91 downto 84)<=  std_logic_Vector(lin_block_cnt_d);
--probe0(99 downto 92)<=  std_logic_Vector(lin_block_cnt);
--probe0(107 downto 100)<=  std_logic_Vector(clm_block_cnt);
--probe0(117 downto 108)<=  std_logic_Vector(POS_X_CH_DD);
--probe0(127 downto 118)<=  std_logic_Vector(POS_X_CH);


--i_ila_battery_disp: ila_0
--PORT MAP (
--  clk => CLK,
--  probe0 => probe0
--);

--------------------------
end architecture rtl;
--------------------------