----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/14/2018 12:40:32 PM
-- Design Name: 
-- Module Name: zoom_control - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity zoom_control is
generic (
  VIDEO_XSIZE         : positive := 640;
  VIDEO_YSIZE         : positive := 480;
  PIX_BITS            : positive := 10;
  LIN_BITS            : positive := 10;
  VIDEO_X_OFFSET_PAL  : integer  := 38;
  VIDEO_Y_OFFSET_PAL  : integer  := 48;
  VIDEO_X_OFFSET_OLED : integer  := 160;
  VIDEO_Y_OFFSET_OLED : integer  := 120;
  VIDEO_X_OFFSET_NTSC : integer  := 38;
  VIDEO_Y_OFFSET_NTSC : integer  := 0
  );
port (

clk                   : in  std_logic;
rst                   : in  std_logic;
sel_oled_analog_video_out : in std_logic;
fit_to_screen_en      : in  std_logic;
scaling_disable       : in  std_logic;
sight_mode            : in  std_logic_vector(1 downto 0);
zoom_enable           : in  std_logic;
zoom_mode             : in  std_logic_vector(2 downto 0);
PAL_nNTSC             : in  std_logic;
reticle_pos_x         : in  std_logic_vector(PIX_BITS-1 downto 0);
reticle_pos_y         : in  std_logic_vector(LIN_BITS-1 downto 0);
scal_bl_in_x_size     : out std_logic_vector(PIX_BITS-1 downto 0);
scal_bl_in_y_size     : out std_logic_vector(LIN_BITS-1 downto 0);
scal_bl_in_x_off      : out std_logic_vector(PIX_BITS-1 downto 0);
scal_bl_in_y_off      : out std_logic_vector(LIN_BITS-1 downto 0);
scal_bl_out_x_size    : out std_logic_vector(PIX_BITS-1 downto 0);
scal_bl_out_y_size    : out std_logic_vector(LIN_BITS-1 downto 0);
reticle_pos_x_out     : out std_logic_vector(PIX_BITS-1 downto 0);
reticle_pos_y_out     : out std_logic_vector(LIN_BITS-1 downto 0)
  );
end zoom_control;

architecture RTL of zoom_control is


signal  flag_1x : std_logic;
signal  flag_2x : std_logic;
signal VIDEO_X_OFFSET : unsigned(PIX_BITS-1 downto 0);
signal VIDEO_Y_OFFSET : unsigned(LIN_BITS-1 downto 0);

begin

process(clk, rst)
variable scal_bl_in_x_off_temp : unsigned (PIX_BITS-1 downto 0);
variable scal_bl_in_x_off_temp1 : unsigned (23 downto 0);
variable scal_bl_in_y_off_temp : unsigned (LIN_BITS-1 downto 0);
variable scal_bl_in_y_off_temp1 : unsigned (23 downto 0);
begin
  if (rst='1') then
    scal_bl_in_x_size  <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_in_x_size'length));
    scal_bl_in_y_size  <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_in_y_size'length));
--    scal_bl_out_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_out_x_size'length));
--    scal_bl_out_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_out_y_size'length));
    scal_bl_out_x_size <= std_logic_vector(to_unsigned(1280, scal_bl_out_x_size'length));
    scal_bl_out_y_size <= std_logic_vector(to_unsigned(720, scal_bl_out_y_size'length));
    scal_bl_in_x_off   <= (others =>'0');
    scal_bl_in_y_off   <= (others => '0');
    flag_1x            <= '0';
    flag_2x            <= '0';
    VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_OLED,PIX_BITS);
    VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_OLED,LIN_BITS);
  
  elsif rising_edge(CLK) then
    if(sel_oled_analog_video_out='1')then
     VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_PAL,PIX_BITS);
     VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_PAL,LIN_BITS);
    else
     VIDEO_X_OFFSET <= to_unsigned(VIDEO_X_OFFSET_OLED,PIX_BITS);
     VIDEO_Y_OFFSET <= to_unsigned(VIDEO_Y_OFFSET_OLED,LIN_BITS);     
    end if;
--    scal_bl_out_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_out_x_size'length));
--    scal_bl_out_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_out_y_size'length));
    scal_bl_out_x_size <= std_logic_vector(to_unsigned(1280, scal_bl_out_x_size'length));
    scal_bl_out_y_size <= std_logic_vector(to_unsigned(720, scal_bl_out_y_size'length));
    if((zoom_enable='1' and unsigned(zoom_mode)=to_unsigned(0, zoom_mode'length)) or (sight_mode = "01" and sel_oled_analog_video_out='0')) then
      
      if(fit_to_screen_en = '1')then
        scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_in_x_size'length));
        scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_in_y_size'length));
      else
        if(scaling_disable = '1')then
          scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_in_x_size'length));
          scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_in_y_size'length));
        else
            scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_in_x_size'length));
            scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_in_y_size'length));
--            scal_bl_in_y_size <= std_logic_vector(to_unsigned(400, scal_bl_in_y_size'length));      
        end if;
      end if;
      scal_bl_in_x_off  <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
      scal_bl_in_y_off  <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));
      flag_1x           <= '0';
      flag_2x           <= '0';
      if(PAL_nNTSC = '1')then     
          reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  VIDEO_X_OFFSET);
          reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  VIDEO_Y_OFFSET);  
      else
          reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  to_unsigned(VIDEO_X_OFFSET_NTSC,reticle_pos_x_out'length));
          reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  to_unsigned(VIDEO_Y_OFFSET_NTSC,reticle_pos_y_out'length));      
      end if;
    elsif (zoom_enable='1' and unsigned(zoom_mode)=to_unsigned(1, zoom_mode'length)) then
----      scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2, scal_bl_in_x_size'length));
----      scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE/2, scal_bl_in_y_size'length)); 
--      if(fit_to_screen_en = '1')then
--          scal_bl_in_x_size <= std_logic_vector(to_unsigned(320, scal_bl_in_x_size'length));
--          scal_bl_in_y_size <= std_logic_vector(to_unsigned(240, scal_bl_in_y_size'length));      
----          scal_bl_in_x_size <= std_logic_vector(to_unsigned(400, scal_bl_in_x_size'length));
----          scal_bl_in_y_size <= std_logic_vector(to_unsigned(300, scal_bl_in_y_size'length));
----          scal_bl_in_x_off  <= std_logic_vector(to_unsigned(120, scal_bl_in_x_off'length));
----          scal_bl_in_y_off  <= std_logic_vector(to_unsigned(90, scal_bl_in_y_off'length));        
--          if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
----                scal_bl_in_x_off_temp := unsigned(reticle_pos_x)+1;
----               if(reticle_pos_x(0) = '0')then
----                scal_bl_in_x_off <= '0' & std_logic_Vector(reticle_pos_x(PIX_BITS-1 downto 1));
----               else
----                scal_bl_in_x_off <= '0' &std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 1));
----               end if; 
--               scal_bl_in_x_off_temp1 :=(to_unsigned(6159,14)* unsigned(reticle_pos_x));
--               scal_bl_in_x_off <= std_logic_vector(scal_bl_in_x_off_temp1(23 downto 14));
--          else    
--                scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--          end if;
          
--          if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
----               scal_bl_in_y_off_temp := unsigned(reticle_pos_y)+1;
----               if(reticle_pos_y(0) = '0')then
----                scal_bl_in_y_off <= '0' & std_logic_Vector(reticle_pos_y(LIN_BITS-1 downto 1));
----               else
----                scal_bl_in_y_off <= '0' &std_logic_Vector(scal_bl_in_y_off_temp(LIN_BITS-1 downto 1));
----               end if; 
--               scal_bl_in_y_off_temp1 :=(to_unsigned(6159,14)* unsigned(reticle_pos_y));
--               scal_bl_in_y_off <= std_logic_vector(scal_bl_in_y_off_temp1(23 downto 14));
--          else
--            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--          end if;
--      else
--          scal_bl_in_x_size <= std_logic_vector(to_unsigned(320, scal_bl_in_x_size'length));
--          scal_bl_in_y_size <= std_logic_vector(to_unsigned(240, scal_bl_in_y_size'length));
          if(scaling_disable = '1')then
            scal_bl_in_x_size <= std_logic_vector(to_unsigned(320, scal_bl_in_x_size'length));
            scal_bl_in_y_size <= std_logic_vector(to_unsigned(240, scal_bl_in_y_size'length));
          else 
            scal_bl_in_x_size <= std_logic_vector(to_unsigned(320, scal_bl_in_x_size'length));
--            scal_bl_in_y_size <= std_logic_vector(to_unsigned(200, scal_bl_in_y_size'length));  
            scal_bl_in_y_size <= std_logic_vector(to_unsigned(240, scal_bl_in_y_size'length));        
          end if;
--          scal_bl_in_x_off <= std_logic_vector(to_unsigned(160, scal_bl_in_x_off'length));
--          scal_bl_in_y_off <= std_logic_vector(to_unsigned(120, scal_bl_in_y_off'length));   
          if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
                scal_bl_in_x_off_temp := unsigned(reticle_pos_x)+1;
               if(reticle_pos_x(0) = '0')then
                scal_bl_in_x_off <= '0' & std_logic_Vector(reticle_pos_x(PIX_BITS-1 downto 1));
               else
                scal_bl_in_x_off <= '0' &std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 1));
               end if; 
          else    
                scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
          end if;
          
          if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
               scal_bl_in_y_off_temp := unsigned(reticle_pos_y)+1;
               if(reticle_pos_y(0) = '0')then
                scal_bl_in_y_off <= '0' & std_logic_Vector(reticle_pos_y(LIN_BITS-1 downto 1));
               else
                scal_bl_in_y_off <= '0' &std_logic_Vector(scal_bl_in_y_off_temp(LIN_BITS-1 downto 1));
               end if; 
          else
            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
          end if; 
              
--      end if;    
      flag_1x           <= '0';
      flag_2x           <= '0';
      if(PAL_nNTSC = '1')then
       reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  VIDEO_X_OFFSET);
       reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  VIDEO_Y_OFFSET);     
      else
       reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  to_unsigned(VIDEO_X_OFFSET_NTSC,reticle_pos_x_out'length));
       reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  to_unsigned(VIDEO_Y_OFFSET_NTSC,reticle_pos_y_out'length));      
      end if;
--      reticle_pos_x_out <= std_logic_vector(to_unsigned(357,reticle_pos_x_out'length));
--      reticle_pos_y_out <= std_logic_vector(to_unsigned(287,reticle_pos_y_out'length));
--      if((unsigned(reticle_pos_x) > to_unsigned(37,scal_bl_in_x_size'length)) and (unsigned(reticle_pos_x) <=  to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)+to_unsigned(37,scal_bl_in_x_size'length)))then
--      if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
----          if((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/4), scal_bl_in_x_size'length))then 
----            scal_bl_in_x_off <= std_logic_vector(to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/2), scal_bl_in_x_off'length));
----          elsif((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length))then 
----            scal_bl_in_x_off  <= std_logic_vector(((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)))-to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length));
----          else    
----            scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
----          end if; 
----            scal_bl_in_x_off_temp := unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_off_temp'length);
----            scal_bl_in_x_off <= '0' & std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 1));
--            scal_bl_in_x_off_temp := unsigned(reticle_pos_x)+1;
--           if(reticle_pos_x(0) = '0')then
--            scal_bl_in_x_off <= '0' & std_logic_Vector(reticle_pos_x(PIX_BITS-1 downto 1));
--           else
--            scal_bl_in_x_off <= '0' &std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 1));
--           end if;

----              scal_bl_in_x_off <= '0' & std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 1));    
--      else    
--            scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--      end if;  
      
--      if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
----          if((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/4), scal_bl_in_y_size'length))then 
----            scal_bl_in_y_off <= std_logic_vector(to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/2), scal_bl_in_y_off'length));       
----          elsif((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length))then
----            scal_bl_in_y_off  <= std_logic_vector(((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)))-to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length));
----          else
----            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
----          end if; 
----        scal_bl_in_y_off  <= std_logic_vector(resize((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)),scal_bl_in_y_off'length));
--            scal_bl_in_y_off_temp := unsigned(reticle_pos_y)+1;
----            scal_bl_in_y_off <= '0' &std_logic_Vector(scal_bl_in_y_off_temp(LIN_BITS-1 downto 1));
--       if(reticle_pos_y(0) = '0')then
--        scal_bl_in_y_off <= '0' & std_logic_Vector(reticle_pos_y(LIN_BITS-1 downto 1));
--       else
--        scal_bl_in_y_off <= '0' &std_logic_Vector(scal_bl_in_y_off_temp(LIN_BITS-1 downto 1));
--       end if; 
--      else
--        scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--      end if;  

    elsif (zoom_enable='1' and unsigned(zoom_mode)=to_unsigned(2, zoom_mode'length)) then
----      scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length));
----      scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length));
--      if(fit_to_screen_en = '1')then
--          scal_bl_in_x_size <= std_logic_vector(to_unsigned(200, scal_bl_in_x_size'length));
--          scal_bl_in_y_size <= std_logic_vector(to_unsigned(150, scal_bl_in_y_size'length));
----          scal_bl_in_x_off <= std_logic_vector(to_unsigned(220, scal_bl_in_x_off'length));
----          scal_bl_in_y_off <= std_logic_vector(to_unsigned(165, scal_bl_in_y_off'length));
--          if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
----             if(reticle_pos_x(1 downto 0) = "00")then
----                scal_bl_in_x_off <= std_logic_Vector(unsigned('0' &reticle_pos_x(PIX_BITS-1 downto 1))+unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
----             else
----                scal_bl_in_x_off <= std_logic_Vector(unsigned(reticle_pos_x)- unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
----             end if;   
--               scal_bl_in_x_off_temp1 :=(to_unsigned(11264,14)* unsigned(reticle_pos_x));
--               scal_bl_in_x_off <= std_logic_vector(scal_bl_in_x_off_temp1(23 downto 14));
--          else
--            scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--          end if;  
          
--          if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
----             if(reticle_pos_y(1 downto 0) = "00")then
----                scal_bl_in_y_off <= std_logic_Vector(unsigned('0' &reticle_pos_y(LIN_BITS-1 downto 1))+unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
----             else
----                scal_bl_in_y_off <= std_logic_Vector(unsigned(reticle_pos_y)- unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
----             end if;   
--               scal_bl_in_y_off_temp1 :=(to_unsigned(11264,14)* unsigned(reticle_pos_y));
--               scal_bl_in_y_off <= std_logic_vector(scal_bl_in_y_off_temp1(23 downto 14));
--          else
--            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--          end if;     
--      else
--          scal_bl_in_x_size <= std_logic_vector(to_unsigned(160, scal_bl_in_x_size'length));
--          scal_bl_in_y_size <= std_logic_vector(to_unsigned(120, scal_bl_in_y_size'length));
          if(scaling_disable = '1')then
            scal_bl_in_x_size <= std_logic_vector(to_unsigned(160, scal_bl_in_x_size'length));
            scal_bl_in_y_size <= std_logic_vector(to_unsigned(120, scal_bl_in_y_size'length));
          else 
            scal_bl_in_x_size <= std_logic_vector(to_unsigned(160, scal_bl_in_x_size'length));
            scal_bl_in_y_size <= std_logic_vector(to_unsigned(120, scal_bl_in_y_size'length));
--            scal_bl_in_y_size <= std_logic_vector(to_unsigned(100, scal_bl_in_y_size'length));          
          end if;
--          scal_bl_in_x_off <= std_logic_vector(to_unsigned(240, scal_bl_in_x_off'length));
--          scal_bl_in_y_off <= std_logic_vector(to_unsigned(180, scal_bl_in_y_off'length));     
          if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
             if(reticle_pos_x(1 downto 0) = "00")then
                scal_bl_in_x_off <= std_logic_Vector(unsigned('0' &reticle_pos_x(PIX_BITS-1 downto 1))+unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
             else
                scal_bl_in_x_off <= std_logic_Vector(unsigned(reticle_pos_x)- unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
             end if;   
          
          else
            scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
          end if;  
          
          if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
             if(reticle_pos_y(1 downto 0) = "00")then
                scal_bl_in_y_off <= std_logic_Vector(unsigned('0' &reticle_pos_y(LIN_BITS-1 downto 1))+unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
             else
                scal_bl_in_y_off <= std_logic_Vector(unsigned(reticle_pos_y)- unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
             end if;   
          else
            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
          end if;           
--      end if;    
      flag_1x           <= '0';
      flag_2x           <= '0';
      if(PAL_nNTSC = '1')then
       reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  VIDEO_X_OFFSET);
       reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  VIDEO_Y_OFFSET);        
      else
       reticle_pos_x_out <= std_logic_vector(unsigned(reticle_pos_x) +  to_unsigned(VIDEO_X_OFFSET_NTSC,reticle_pos_x_out'length));
       reticle_pos_y_out <= std_logic_vector(unsigned(reticle_pos_y) +  to_unsigned(VIDEO_Y_OFFSET_NTSC,reticle_pos_y_out'length));      
      end if;
--      reticle_pos_x_out <= std_logic_vector(to_unsigned(357,reticle_pos_x_out'length));
--      reticle_pos_y_out <= std_logic_vector(to_unsigned(287,reticle_pos_y_out'length));
--      if((unsigned(reticle_pos_x) < to_unsigned(VIDEO_XSIZE,scal_bl_in_x_size'length)))then
----          if((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/8), scal_bl_in_x_size'length))then 
----            scal_bl_in_x_off <= std_logic_vector(to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/4), scal_bl_in_x_off'length));
----          elsif((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned(VIDEO_XSIZE/8, scal_bl_in_x_size'length))then 
----            scal_bl_in_x_off  <= std_logic_vector(((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)))-to_unsigned(VIDEO_XSIZE/8, scal_bl_in_x_size'length));
----          else
----            scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
----          end if;  
----        scal_bl_in_x_off <= std_logic_vector(resize((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)),scal_bl_in_x_off'length));
----            scal_bl_in_x_off_temp := unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_off_temp'length);
----            scal_bl_in_x_off <= std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 0));
----        scal_bl_in_x_off <= std_logic_Vector(scal_bl_in_x_off_temp(PIX_BITS-1 downto 0));
--         if(reticle_pos_x(1 downto 0) = "00")then
--            scal_bl_in_x_off <= std_logic_Vector(unsigned('0' &reticle_pos_x(PIX_BITS-1 downto 1))+unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
--         else
--            scal_bl_in_x_off <= std_logic_Vector(unsigned(reticle_pos_x)- unsigned("00" &reticle_pos_x(PIX_BITS-1 downto 2)));
--         end if;   
      
--      else
--        scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--      end if;  
--      if((unsigned(reticle_pos_y) < to_unsigned(VIDEO_YSIZE,scal_bl_in_y_size'length)))then
----          if((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/8), scal_bl_in_y_size'length))then 
----            scal_bl_in_y_off <= std_logic_vector(to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/4), scal_bl_in_y_off'length));       
----          elsif((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned(VIDEO_YSIZE/8, scal_bl_in_y_size'length))then
----            scal_bl_in_y_off  <= std_logic_vector(((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)))-to_unsigned(VIDEO_YSIZE/8, scal_bl_in_y_size'length));
----          else
----            scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
----          end if; 
----        scal_bl_in_y_off <= std_logic_vector(resize((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)),scal_bl_in_y_off'length));
----            scal_bl_in_y_off_temp := unsigned(reticle_pos_y)-to_unsigned(48,scal_bl_in_y_off_temp'length);
----            scal_bl_in_y_off <= "00" & std_logic_Vector(scal_bl_in_y_off_temp(LIN_BITS-1 downto 2));
----         scal_bl_in_y_off_temp := unsigned(reticle_pos_y);
--         if(reticle_pos_y(1 downto 0) = "00")then
--            scal_bl_in_y_off <= std_logic_Vector(unsigned('0' &reticle_pos_y(LIN_BITS-1 downto 1))+unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
--         else
--            scal_bl_in_y_off <= std_logic_Vector(unsigned(reticle_pos_y)- unsigned("00" &reticle_pos_y(LIN_BITS-1 downto 2)));
--         end if;   
--      else
--        scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--      end if;  

--   elsif (zoom_enable='1' and unsigned(zoom_mode)=to_unsigned(3, zoom_mode'length)) then
--      scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE/2, scal_bl_in_x_size'length));
--      scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE/2, scal_bl_in_y_size'length)); 
--      flag_2x           <= '0';
--      reticle_pos_x_out <= reticle_pos_x;
--      reticle_pos_y_out <= reticle_pos_y;
--      if(flag_1x = '0')then
--        flag_1x  <= '1';
--        if(unsigned(reticle_pos_x) > to_unsigned(37,scal_bl_in_x_size'length))then
--            if((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/4), scal_bl_in_x_size'length))then 
--              scal_bl_in_x_off <= std_logic_vector(to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/2), scal_bl_in_x_off'length));
--            elsif((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length))then 
--              scal_bl_in_x_off  <= std_logic_vector(((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)))-to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length));
--           else
--              scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--           end if;
--        else    
--              scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--        end if;  
        
--        if(unsigned(reticle_pos_y) > to_unsigned(47,scal_bl_in_y_size'length))then
--            if((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/4), scal_bl_in_y_size'length))then 
--              scal_bl_in_y_off <= std_logic_vector(to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/2), scal_bl_in_y_off'length));       
--            elsif((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length))then
--              scal_bl_in_y_off  <= std_logic_vector(((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)))-to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length));
--           else
--              scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));
--           end if;
--        else
--          scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--        end if;              
--      end if;   
--    elsif (zoom_enable='1' and unsigned(zoom_mode)=to_unsigned(4, zoom_mode'length)) then
--      scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE/4, scal_bl_in_x_size'length));
--      scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE/4, scal_bl_in_y_size'length));
--      flag_1x           <= '0';
--      reticle_pos_x_out <= reticle_pos_x;
--      reticle_pos_y_out <= reticle_pos_y;
--      if(flag_2x = '0')then
--        flag_2x <= '1';
--        if(unsigned(reticle_pos_x) > to_unsigned(37,scal_bl_in_x_size'length))then
--            if((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/8), scal_bl_in_x_size'length))then 
--              scal_bl_in_x_off <= std_logic_vector(to_unsigned((VIDEO_XSIZE - VIDEO_XSIZE/4), scal_bl_in_x_off'length));
--            elsif((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)) >=  to_unsigned(VIDEO_XSIZE/8, scal_bl_in_x_size'length))then 
--              scal_bl_in_x_off  <= std_logic_vector(((unsigned(reticle_pos_x)-to_unsigned(37,scal_bl_in_x_size'length)))-to_unsigned(VIDEO_XSIZE/8, scal_bl_in_x_size'length));
--           else
--              scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--           end if;
--        else
--          scal_bl_in_x_off <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
--        end if;  
--        if(unsigned(reticle_pos_y) > to_unsigned(47,scal_bl_in_y_size'length))then
--            if((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/8), scal_bl_in_y_size'length))then 
--              scal_bl_in_y_off <= std_logic_vector(to_unsigned((VIDEO_YSIZE - VIDEO_YSIZE/4), scal_bl_in_y_off'length));       
--            elsif((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)) >=  to_unsigned(VIDEO_YSIZE/8, scal_bl_in_y_size'length))then
--              scal_bl_in_y_off  <= std_logic_vector(((unsigned(reticle_pos_y)-to_unsigned(47,scal_bl_in_y_size'length)))-to_unsigned(VIDEO_YSIZE/8, scal_bl_in_y_size'length));
--            else
--              scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));
--            end if;
--        else
--          scal_bl_in_y_off <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));   
--        end if; 
--      end if;  
    elsif(zoom_enable='0') then
      scal_bl_in_x_size <= std_logic_vector(to_unsigned(VIDEO_XSIZE, scal_bl_in_x_size'length));
      scal_bl_in_y_size <= std_logic_vector(to_unsigned(VIDEO_YSIZE, scal_bl_in_y_size'length));
      scal_bl_in_x_off  <= std_logic_vector(to_unsigned(0, scal_bl_in_x_off'length));
      scal_bl_in_y_off  <= std_logic_vector(to_unsigned(0, scal_bl_in_y_off'length));
      flag_1x           <= '0';
      flag_2x           <= '0';
      reticle_pos_x_out <= reticle_pos_x;
      reticle_pos_y_out <= reticle_pos_y;

    end if;
  
  end if;
end process;

end RTL;