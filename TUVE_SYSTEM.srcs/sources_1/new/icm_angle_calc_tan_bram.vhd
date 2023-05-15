----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2022 10:51:40 AM
-- Design Name: 
-- Module Name: icm_angle_calc_cordic - Behavioral
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
use IEEE.STD_LOGIC_Unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity icm_angle_calc_tan_bram is
 Port ( 
        clk       : in std_logic;
        rst       : in std_logic;
--        magneto_x : in std_logic_vector(15 downto 0);---inputs for magneto_meter 
        magneto_y : in std_logic_vector(15 downto 0);
        magneto_z : in std_logic_vector(15 downto 0 );
--        conv_factor : in std_logic_vector(31 downto 0);
--        yaw_radians: out std_logic_vector(31 downto 0);
        yaw_degree : out std_logic_vector(15 downto 0)      -- 0 to 360   
  );  
end icm_angle_calc_tan_bram;

architecture Behavioral of icm_angle_calc_tan_bram is

COMPONENT magneto_division_ip
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_divisor_tvalid : IN STD_LOGIC;
    s_axis_divisor_tready : OUT STD_LOGIC;
    s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_dividend_tvalid : IN STD_LOGIC;
    s_axis_dividend_tready : OUT STD_LOGIC;
    s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
  );
END COMPONENT;

COMPONENT tan_bram
  PORT (
    clka : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

signal s_axis_divisor_tvalid : std_logic := '0';
signal s_axis_divisor_tready : std_logic;
signal s_axis_divisor_tdata  : std_logic_vector(15 downto 0);
signal s_axis_dividend_tvalid: std_logic := '0';
signal s_axis_dividend_tready: std_logic;
signal s_axis_dividend_tdata : std_logic_vector(31 downto 0);
signal m_axis_dout_tvalid    : std_logic;
signal m_axis_dout_tdata     : std_logic_vector(47 downto 0);

signal div_out    : std_logic_vector(24 downto 0);
signal target     : std_logic_vector(15 downto 0);

type cor_cal is (st_idle,st_absolute,st_mul_dividend,st_div_start,st_div_done,st_find_index_corner_case,st_find_index,st_find_index1,st_find_index2,st_find_index3,
                 st_find_index4,st_find_index5,st_find_index6,st_find_index7,st_find_index8,st_find_index9,
                 st_find_index10,st_find_index11,st_find_index12,st_find_index13,st_find_index14,st_find_index15,
                 st_find_index16,st_index_done,st_angle_cal);
signal state_cal : cor_cal ;

signal magneto_y_abs     : std_logic_vector(15 downto 0);
signal magneto_z_abs     : std_logic_vector(15 downto 0);
signal magneto_y_abs_mul : std_logic_vector(31 downto 0);

signal i         : unsigned(6 downto 0);
signal j         : unsigned(6 downto 0);
signal temp_addr : unsigned(7 downto 0);
signal mid       : unsigned(6 downto 0);
signal index     : std_logic_vector(6 downto 0);
signal addra     : std_logic_vector(6 downto 0);
signal douta     : std_logic_vector(15 downto 0);
signal val1      : std_logic_vector(15 downto 0);
signal val2      : std_logic_vector(15 downto 0);
signal quad      : std_logic_Vector(1 downto 0); -- "00" - 1st quad, "01" 2nd quad, "11" 3rd quad, "10" 4th quad
begin

process(clk,rst)
begin 
    if rst = '1' then
        state_cal <= st_idle;
        target   <= (others=>'0');
        quad     <= (others=>'0');
        div_out  <= (others=>'0'); 
        s_axis_divisor_tvalid  <= '0';
        s_axis_divisor_tdata   <= (others=>'1');
        s_axis_dividend_tvalid <= '0';
        s_axis_dividend_tdata  <= (others=>'0');       
        magneto_y_abs          <= (others=>'0');
        magneto_z_abs          <= (others=>'0');
        magneto_y_abs_mul      <= (others=>'0');
        i         <= (others=>'0'); 
        j         <= (others=>'0'); 
        temp_addr <= (others=>'0'); 
        mid       <= (others=>'0'); 
        index     <= (others=>'0'); 
        addra     <= (others=>'0'); 
        val1      <= (others=>'0'); 
        val2      <= (others=>'0'); 
        quad      <= (others=>'0'); 

        
    elsif (rising_edge (clk))then     
     case state_cal is 
        when st_idle => 
            s_axis_divisor_tvalid  <= '0';
            s_axis_divisor_tdata   <= (others=>'1');
            s_axis_dividend_tvalid <= '0';
            s_axis_dividend_tdata  <= (others=>'0');
            state_cal <= st_absolute;
        
        when st_absolute =>
            if(magneto_z(15)='1')then
              magneto_z_abs  <= std_logic_vector((not unsigned(magneto_z)) + 1);
            else
              magneto_z_abs  <= magneto_z;
            end if;        
            
            if(magneto_y(15)='1')then
              magneto_y_abs  <= std_logic_vector((not unsigned(magneto_y)) + 1);
            else
              magneto_y_abs  <= magneto_y;
            end if;
            
            quad <= magneto_y(15) & magneto_z(15);
            
            state_cal <= st_mul_dividend;
        when st_mul_dividend => 
            magneto_y_abs_mul  <= std_logic_vector(to_unsigned(1000,16) * unsigned(magneto_y_abs));
            state_cal      <= st_div_start;
        
        when st_div_start =>
            s_axis_divisor_tvalid  <= '1';
            s_axis_divisor_tdata   <= magneto_z_abs; 
            s_axis_dividend_tvalid <= '1';
            s_axis_dividend_tdata  <= magneto_y_abs_mul;
            state_cal <=st_div_done;

        when st_div_done =>
            if(s_axis_divisor_tready ='1')then
                s_axis_divisor_tvalid  <= '0';
            end if;  
            if(s_axis_dividend_tready ='1')then  
                s_axis_dividend_tvalid <= '0';
            end if;      
            if(m_axis_dout_tvalid='1')then
                if(magneto_y_abs = x"0000" and magneto_z_abs = x"0000")then
                    div_out   <= (others=>'0');
                else 
                    div_out   <= m_axis_dout_tdata(40 downto 16);
                end if;    
                state_cal <= st_find_index_corner_case;
            end if;    
        
        when st_find_index_corner_case =>
         if(div_out >= 57292)then           
            index     <= std_logic_vector(to_unsigned(90,7));
            state_cal <= st_index_done;
         else
            target    <= div_out(15 downto 0);
            state_cal <= st_find_index;
            i         <= to_unsigned(0,7);
            j         <= to_unsigned(89,7);
         end if; 
        
        when st_find_index =>
            if(i<j)then 
                state_cal <= st_find_index1;
            else
                state_cal <= st_index_done;
                index     <= std_logic_vector(mid);
            end if;  
              
        
        when st_find_index1 =>
            temp_addr <= ('0' &i) + ('0' &j);
            state_cal <= st_find_index2;
 
         when st_find_index2 =>
            mid <= temp_addr(7 downto 1);
            state_cal <= st_find_index3;
 
          when st_find_index3 =>
            addra     <= std_logic_vector(mid);
            state_cal <= st_find_index4;
 
          when st_find_index4 =>
            state_cal <= st_find_index5;
          
          when st_find_index5 => 
             val1 <= douta;
             if(douta = target)then
                state_cal <= st_index_done;
                index     <= std_logic_vector(mid);
             elsif(target < douta)then
                state_cal <= st_find_index6;  
             else
                state_cal <= st_find_index10;    
             end if;   
 
          when st_find_index6 =>
            if(mid > 0)then
                addra <= std_logic_vector(mid -1);
                state_cal <= st_find_index7;
            else
                state_cal <= st_find_index1;
                j <= mid;
            end if;    
          when st_find_index7 =>
                state_cal <= st_find_index8;
          
          when st_find_index8 =>
               val2 <= douta;
               if(target > douta)then
                state_cal <= st_find_index9;
               else
                state_cal <= st_find_index1;
                j <= mid;              
               end if;
          
          when st_find_index9 =>
               if((val1 - target) >= (target - val2))then 
                index <= std_logic_vector(mid -1);
               else
                index <= std_logic_vector(mid);
               end if;
               state_Cal <= st_index_done;
          
          when st_find_index10 =>
            if(mid<89)then
                state_Cal <= st_find_index11;
            else
                state_Cal <= st_find_index;
                i <= mid +1;
            end if;     

        when st_find_index11 =>
                addra <= std_logic_vector(mid +1);
                state_cal <= st_find_index12;
                  
          when st_find_index12 =>
                state_cal <= st_find_index13;
          
          when st_find_index13 =>
               val2 <= douta;
               if(target < douta)then
                state_cal <= st_find_index14;
               else
                state_cal <= st_find_index1;
                i <= mid +1;              
               end if;
          
          when st_find_index14 =>
               if((target - val1) >= (val2 - target))then 
                index <= std_logic_vector(mid +1);
               else
                index <= std_logic_vector(mid);
               end if;
               state_Cal <= st_index_done; 
          
          when st_index_done =>
               state_Cal <= st_angle_cal;        

          when st_angle_cal =>
               state_Cal <= st_index_done; 
               if(quad = "00")then
                yaw_degree <= std_logic_vector(x"00" & "0" & unsigned(index));
               elsif(quad = "01")then
                yaw_degree <=std_logic_vector(to_unsigned(180,16)- unsigned(index));
               elsif(quad = "11")then
                yaw_degree <= std_logic_vector(to_unsigned(180,16)+ unsigned(index));
               else
                yaw_degree <=std_logic_vector(to_unsigned(360,16)- unsigned(index));
               end if;
               state_Cal <=st_idle;
               
  

               
            
        when others                       =>  state_cal <= st_idle ;                                                       
     end case ;
    
    end if ;

end process ;



i_magneto_division_ip : magneto_division_ip
  PORT MAP (
    aclk => clk,
    s_axis_divisor_tvalid  => s_axis_divisor_tvalid,
    s_axis_divisor_tready  => s_axis_divisor_tready,   
    s_axis_divisor_tdata   => s_axis_divisor_tdata,
    s_axis_dividend_tvalid => s_axis_dividend_tvalid,
    s_axis_dividend_tready => s_axis_dividend_tready,
    s_axis_dividend_tdata  => s_axis_dividend_tdata,
    m_axis_dout_tvalid     => m_axis_dout_tvalid,
    m_axis_dout_tdata      => m_axis_dout_tdata
  );
  
i_tan_bram : tan_bram
  PORT MAP (
    clka  => clk,
    addra => addra,
    douta => douta
  );

end Behavioral;
