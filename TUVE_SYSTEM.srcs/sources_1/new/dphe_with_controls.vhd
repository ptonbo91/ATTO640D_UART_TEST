----------------------------------------------------------------
-- Copyright    : Tonbo Imaging
-- Project Name : Tonboimaging - Thermal Camera Project
-- Block Name   : DPHE
-- Description  : Top module for DPHE Algorithm
-- Author       : ARDRA SINGH
-- Date         : July 2015
-- Notes        : works for all resolutions, pixel bitwidths, and interframe times
----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Library xpm;
use xpm.vcomponents.all;
----------------------------------------------------------------
entity dphe_with_controls is
	generic (
		bit_width                     : positive := 13;            -- bitdepth of pixel_in
		PIX_BITS                      : positive := 10;            -- 2**PIX_BITS = Maximum Number of pixels in a line 
		LIN_BITS                      : positive := 10;            -- 2**LIN_BITS = Maximum Number of  lines in an image 
		bitdepth_inter                : positive := 8;             -- bitdepth of pixel stored in intermediate histogram
		bitdepth_out                  : positive := 8;             -- bitdepth of pixel_out
		image_width                   : positive := 640;           -- width of image
		image_height                  : positive := 512            -- height of image
		);
	port (
		CLK              : in  std_logic;                                     --  Clock
		RST              : in  std_logic;                                     --  Reset
		pixel_vld        : in  std_logic;                                     --  Pixel Valid    
		pixel_in         : in  std_logic_vector(bit_width downto 0);          --  Video Pixel Input
		video_i_h        : in  std_logic;                                     --  New line flag
		video_i_v        : in  std_logic;                                     --  New frame flag
		video_i_xsize    : in  std_logic_vector(PIX_BITS-1 downto 0);         --  No. of pixels in a row
		video_i_ysize    : in  std_logic_vector(LIN_BITS-1 downto 0);         --  No. of pixels in a column
		video_o_dav      : out std_logic;                                     --  Pixel Valid Output  
		video_o_data     : out std_logic_vector(bitdepth_out-1 downto 0);     --  Output Pixel Value (8 bits)
		video_o_h        : out std_logic;                                     --  New line flag                                    
		video_o_v        : out std_logic;                                     --  New frame flag
		video_o_xcnt     : out std_logic_vector(PIX_BITS-1 downto 0);         --  Pixel's column position
		video_o_ycnt     : out std_logic_vector(LIN_BITS-1 downto 0);         --  Pixel's row position
		video_o_xsize    : out std_logic_vector(PIX_BITS-1 downto 0);         --  No. of pixels in a row
		video_o_ysize    : out std_logic_vector(LIN_BITS-1 downto 0);         --  No. of pixels in a column
		video_o_eoi      : out std_logic;                                     --  End of image flag  
		dphe_max_limiter : in  std_logic_vector(23 downto 0);                 --  Signal for controlling the maximum output level (valid input range: 256-16384)
		cntrl_min_dphe   : in  std_logic_vector(23 downto 0);                 --  Signal for controlling the start index
		cntrl_max_dphe   : in  std_logic_vector(23 downto 0);                 --  Signal for controlling the end index
		cntrl_hist1_dphe : in  std_logic_vector(23 downto 0);                 --  Signal for controlling the history parameter for updating the start and end indices
		cntrl_hist2_dphe : in  std_logic_vector(23 downto 0);                 --  Signal for controlling the history parameter for updating the clip position, max output level, and low and high thresholds
		cntrl_clip_dphe  : in  std_logic_vector(23 downto 0);                  --  Signal for controlling the peak clip threshold
		roi_x_offset 	 : in std_logic_vector(PIX_BITS-1 downto 0);
		roi_y_offset 	 : in std_logic_vector(LIN_BITS-1 downto 0);
		roi_x_size 		 : in std_logic_vector(PIX_BITS-1 downto 0);
		roi_y_size  	 : in std_logic_vector(LIN_BITS-1 downto 0);
		linear_hist_en   : in std_logic;
		max_gain 		: in std_logic_vector(7 downto 0);
		roi_mode 		: in std_logic;
		adaptive_clipping_mode : in std_logic;                        --  Flag for turning adaptive clipping on
		enhance_low_contrast :in std_logic
		);
end dphe_with_controls;
----------------------------------------------------------------

----------------------------------------------------------------
architecture RTL of dphe_with_controls is


COMPONENT TOII_TUVE_ila

PORT (
	clk : IN STD_LOGIC;
	probe0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0)
);
END COMPONENT;

signal probe0: std_logic_vector(255 downto 0);

----------------------------------------------------------------
--The following function calculates ceil(log2(x))
function ceil_log2(input:positive) return integer is
	variable temp,log:integer;
	begin
 		temp:=input;
  		log:=0;
  		while (temp /= 0) loop
   			temp:=temp/2;
   			log:=log+1;
   		end loop;
   return log;
end function ceil_log2;
----------------------------------------------------------------

  	constant bitdepth_in                : positive := bit_width+1;                                     -- bitwidth of pixel_in
  	constant num_in_levels              : positive := 2**bitdepth_in;                                  -- 2^bitdepth_in          
  	constant num_inter_levels           : positive := 2**bitdepth_inter;                               -- 2^bitdepth_inter

  	constant num_out_levels_nroi             : positive := 236;                                 -- 2^bitdepth_out
  	constant nbits_num_pixels_nroi           : integer  := ceil_log2(image_width*image_height);   -- ceil(log2(num_pixels))
  	constant dphe_max_peaks_nroi             : positive := 10;                                              -- maximum number of peaks in intermediate histogram
  	constant nbits_dphe_max_peaks_nroi       : integer  := ceil_log2(dphe_max_peaks_nroi);                       -- ceil(log2(dphe_max_peaks))
  	--constant dphe_peak_high_threshold   : positive := (5*num_pixels)/3072;                             -- (5/3072) * num_pixels (If 5 consecutive bins in the histogram contain more pixels than this number, it means a peak is starting.)
  	constant dphe_peak_high_threshold_nroi   : positive := 1000;
  	constant dphe_window_length_nroi         : positive := 5;                                               -- length of window used for finding peaks
	constant dphe_walk_length_nroi		     : positive := 5;                                               -- limit for refining peak start and end points
	constant nbits_dphe_walk_length_nroi     : integer  := ceil_log2(dphe_walk_length_nroi);                     -- ceil(log2(dphe_walk_length))
	constant dphe_required_sum_nroi          : positive := dphe_window_length_nroi*dphe_peak_high_threshold_nroi;     -- dphe_window_length * dphe_peak_high_threshold

	--constant roi_x_size : positive:= 256;
	--constant roi_y_size : positive:= 256;
 

  	signal  num_out_levels             : positive;
  	signal  num_pixels                 : unsigned(nbits_num_pixels_nroi-1 downto 0);
  	signal  dphe_max_peaks             : positive;
  	signal  nbits_dphe_max_peaks       : integer ;
  	signal  dphe_peak_high_threshold   : positive;
  	signal  dphe_window_length         : positive;
	signal  dphe_walk_length           : positive;
	signal  nbits_dphe_walk_length     : integer ;
	signal  dphe_required_sum          : positive;
	signal  dphe_min_peak_area         : unsigned(nbits_num_pixels_nroi-1 downto 0);

	type state is (idle, new_clip_1, get_end_points, rd_shifted_hist, comp_shifted_cdf, 
						compare1, compare2, find_peaks, rd_inter_hist, generate_window, update_window_1, 
						rd_inter_hist_prev, update_window_2, check_start_end_peak,	refine_peak_start, 
					    read_inter_hist_walk_low, store_temp_low, compare_low, refine_peak_end, 
					    read_inter_hist_walk_high, store_temp_high, compare_high, store_peak, 
					    compute_avg_low_sum, compute_avg_high_sum, compute_thresholds_1_1,
						compute_thresholds_1_2, compute_thresholds_1_3, compute_thresholds_1_4,
						compute_thresholds_2, round, decide_clipping_point, compute_lut_val_3,
						compute_multiplication_1, compute_multiplication_2, compute_clip_num,
						compute_division_start, compute_division_wait,compute_original_clipping_position_1_buff,
						compute_original_clipping_position_1, compute_original_clipping_position_2,
						compute_original_clipping_position_3, compute_original_clipping_position_4,
						fix_output_range, calculate_max_output_level_1, calculate_max_output_level_2,
						new_clip_2, calculate_num_clipped, rd_inter_hist_clip, update_num_clipped, 
						averaging_1, averaging_2_mul1, averaging_2_mul2, averaging_2_mul3,
						averaging_2_mul4, averaging_3, update, averaging_start_end_1, 
						generate_cdf, rd_inter_hist_cdf, update_old_dump, decide_threshold, 
						apply_threshold, update_new_dump,update_new_dump_1,update_new_dump_2, write_cdf, update_lut, read_cdf, 
						compute_lut_val_1, compute_lut_val_2, rest, calculate_bin_size, rewind, 
						calculate_inv_bin_size_1, calculate_inv_bin_size_2, compute_lut_val_4, 
						averaging_2_end, update2, averaging_start_end_mul1, averaging_start_end_mul2,
						averaging_start_end_2, averaging_start_end_3, average_start_end_done,
						decide_max_output_level, clear_mems, calculate_max_gain1, calculate_max_gain2,
						calculate_brightness1, calculate_brightness2, calculate_brightness2n, 
						calculate_brightness3_avg, calculate_brightness4_avg,
						calculate_brightness5_avg, calculate_brightness6_avg, decide_intensity_shift);
	signal dphe_st                                                                                : state;
	type array1 is array (0 to 9) of unsigned(bitdepth_inter-1 downto 0);                                                   
	signal peak_start_points, peak_end_points                                                     : array1 := (others => (others => '0'));
	type array2 is array (0 to 9) of unsigned(nbits_num_pixels_nroi-1 downto 0);                                                                                    -- bitdepth of dphe_num_pixels                                         
	signal area_before_peak,peak_area_count                                                       : array2 := (others => (others => '0'));
	signal clip_den,clip_num_1,clip_num_2,clip_num                                                : unsigned(35 downto 0);
	signal is_first_frame_flag, rd_is_first_frame_flag                                            : unsigned(1 downto 0) := "11";              -- skip averaging for first 2 frames
	signal count4, max, peak_extend                                                               : unsigned(nbits_dphe_walk_length_nroi-1 downto 0) ;                     -- bitdepth of dphe_walk_length
	signal peak_count                                                                             : unsigned(nbits_dphe_max_peaks_nroi-1 downto 0);                      -- bitdepth of dphe_max_peaks 
	signal dvsr_18, dvnd_18, quo_18, rmd_18                                                       : std_logic_vector(nbits_num_pixels_nroi downto 0); 
	signal inv_bin_size, prev_inv_bin_size, prev_bin_size, prev_bin_size_for_output,
           prev_inv_bin_size_for_output, new_bin_size, new_inv_bin_size, bin_size_for_calc, 
           inv_bin_size_for_calc                                                        		  : unsigned(nbits_num_pixels_nroi downto 0);

    signal gain_mult, prev_gain_mult, prev_gain_mult_for_calc, inv_max_gain 			     	  : unsigned(nbits_num_pixels_nroi downto 0);
    signal brightness_inter 																	  : unsigned(nbits_num_pixels_nroi+bitdepth_in downto 0);
	signal window_sum, total_sum, low_sum, peak_area, temp, peak_sum_till_start, 
           peak_start_count, peak_end_count, temp2, avg_low_sum, avg_high_sum, t_high, t_low, 
           num_clipped, effective_t_high, effective_t_low, effective_low_lim, effective_count,
           effective_count_1,effective_count_2,old_dump, prev_t_high, prev_t_low, rem_pixel_count, diff_t_high, diff_t_low, dec, 
		   cdf_val                                                                                : unsigned(nbits_num_pixels_nroi-1 downto 0);                   	 -- bitdepth of dphe_num_pixels
	signal dump1 																				  : unsigned(nbits_num_pixels_nroi downto 0);
	--signal dec                                                                                  : unsigned(prev_inv_bin_size'length-2 downto 0);
	signal d2, new_dump                                                                           : unsigned((nbits_num_pixels_nroi + bitdepth_inter) downto 0);
	--signal count2, non_zero_levels, non_zero_lowliers, clip_pos_mod, sum_start_end                : unsigned(bitdepth_inter downto 0);
	signal non_zero_levels, non_zero_lowliers, clip_pos_mod, sum_start_end                		  : unsigned(bitdepth_inter downto 0);
	signal count2                                                                                 : unsigned(bitdepth_in downto 0);
	signal peak_start, peak_end, count3, peak_width, clip_pos,clip_pos_buff, inflection_point     : unsigned(bitdepth_inter-1 downto 0);
	signal max_output_level, prev_max_output_level, output_val_1, diff_max_output_level,
           avail_range, extra_whole, output_val_1_m, output_val_1_mm, output_val_2,
           prev_max_output_level_for_output                                             	      : unsigned(bitdepth_out-1 downto 0);

    signal intensity_shift, prev_intensity_shift, prev_intensity_shift_for_output, 
    	   diff_intensity_shift   																  : unsigned(bitdepth_out-1 downto 0);

	signal start_index, end_index, prev_start_index, prev_end_index, orig_clip_pos, prev_clip_pos, 
           quant1, quant2, diff_start_index, diff_end_index, diff_clip_pos, ratio1, ratio2, 
		   quant1_mul, quant2_mul, ratio3, 
		   prev_start_index_for_output, prev_end_index_for_calc, prev_start_index_for_calc        : unsigned(bitdepth_in-1 downto 0);
	signal quant2_mul_mm, quant2_mul_m 															  : signed(bitdepth_in+1 downto 0);
	signal lin_mul1 																			  : unsigned(bitdepth_in-1 downto 0);
	signal lin_mul2 																		      : signed(bitdepth_in+2 downto 0);
	signal lin_mul3 																			  : signed(bitdepth_in+3 downto 0);
	signal brightness, prev_brightness, prev_brightness_for_output				  : unsigned(bitdepth_in-1 downto 0);
	signal diff_brightness 																		  : unsigned(bitdepth_in-1 downto 0);
	signal hist_span, whole, dphe_range_threshold, half_dphe_range_threshold                      : unsigned(bitdepth_in downto 0);
	signal we1_1a, rd1_1b, we1_2a, rd1_2b, we2_1a, rd2_1b, we2_2a, rd2_2b, we3a, rd3b, we4_1a, rd4_1b, we4_2a,
	       rd4_2b, start_found, end_found, peak_found, changed, start_18, done_tick_18, start_33, 
		   done_tick_33, pixel_vld_out, we_mem_no, rd_mem_no, is_prev_calc_done, switch_lut, 
           rd_lut_prev_no, wr_lut_prev_no, start_calc, video_eoi_d, start_algo, mems_cleared      : std_logic := '0';
	signal we1_1b, rd1_1a, we1_2b, rd1_2a, we2_1b, rd2_1a, we2_2b, rd2_2a, we3b, rd3a, we4_1b, rd4_1a, we4_2b, rd4_2a : std_logic:='0';
	signal din1_1a, dout1_1b, din1_2a, dout1_2b, din2_1a, dout2_1b, din2_2a, dout2_2b                     : std_logic_vector(nbits_num_pixels_nroi-1 downto 0);
	signal din1_1b, dout1_1a, din1_2b, dout1_2a, din2_1b, dout2_1a, din2_2b, dout2_2a                     : std_logic_vector(nbits_num_pixels_nroi-1 downto 0);
	signal din3a, dout3b                                                                            : std_logic_vector((nbits_num_pixels_nroi + bitdepth_inter) downto 0);
	signal din3b, dout3a                                                                            : std_logic_vector((nbits_num_pixels_nroi + bitdepth_inter) downto 0);
	signal din4_1a, dout4_1b, din4_2a, dout4_2b                                                       : std_logic_vector(bitdepth_out-1 downto 0);
	signal din4_1b, dout4_1a, din4_2b, dout4_2a                                                       : std_logic_vector(bitdepth_out-1 downto 0);
	--signal add1_1a, add1_1b, add1_2a, add1_2b, add2_1a, add2_1b, add2_2a, add2_2b, 
	--       add3a, add3b, add4_1a, add4_1b, add4_2a, add4_2b, add2_m                       		  : std_logic_vector(bitdepth_inter-1 downto 0);
	signal add2_1a, add2_1b, add2_2a, add2_2b, 
	       add3a, add3b, add4_1a, add4_1b, add4_2a, add4_2b, add2_m                       		  : std_logic_vector(bitdepth_inter-1 downto 0);
	signal add1_1a, add1_1b, add1_2a, add1_2b                                                     : std_logic_vector(bitdepth_in-1 downto  0); 
	signal pixel_out                                                                              : std_logic_vector(bitdepth_out-1 downto 0);
	signal video_xcnt                                                                             : unsigned(PIX_BITS-1 downto 0);
	signal video_ycnt                                                                             : unsigned(LIN_BITS-1 downto 0);
	signal dvsr_33, dvnd_33, quo_33, rmd_33                                                       : std_logic_vector((new_dump'length + max_output_level'length - 1) downto 0); 
	signal t_high_high_portion, t_high_low_portion, t_low_high_portion, t_low_low_portion,
           t_high_without_rounding, t_low_without_rounding                                        : unsigned((avg_high_sum'length + 16 - 1) downto 0);	
	signal d1                                                                                     : unsigned((new_dump'length + max_output_level'length - 1) downto 0);
	signal mul_t_high, mul_t_low                                                                  : unsigned((diff_t_high'length + 17 - 1) downto 0);
	signal mul_brightness 																		  : unsigned((diff_brightness'length + 17 -1) downto 0);
	signal max_output_level_with_rounding                                                         : unsigned(quo_33'length-1 downto 0);
	signal mul_orig_clip_pos                                                                      : unsigned((diff_clip_pos'length + 17 - 1) downto 0);
    signal ratio                                                                                  : unsigned((bitdepth_in + prev_inv_bin_size'length - 1) downto 0);	
	signal mul_max_output_level                                                                   : unsigned((diff_max_output_level'length + 17 - 1) downto 0);
	signal mul_intensity_shift                                                                    : unsigned((diff_intensity_shift'length + 17 - 1) downto 0);
	signal extra_dec, extra_dec_1                                                                 : unsigned((dec'length + avail_range'length - 1) downto 0);
	signal clip_mul                                                                               : unsigned((clip_pos_mod'length + bin_size_for_calc'length - 1) downto 0);
	signal mul_start_index, mul_end_index                                                         : unsigned((diff_start_index'length + 16 - 1) downto 0);	
	
	constant ALGO_PIPE_CLKS                                                                       : positive := 9;
	signal ALGO_STAGE                                                                             : std_logic_vector(ALGO_PIPE_CLKS-1 downto 0);
	type ALGO_input_val_t is array (ALGO_PIPE_CLKS-1 downto 0) of unsigned(bitdepth_in-1 downto 0);
	signal ALGO_input_val                                                                         : ALGO_input_val_t;
	type ALGO_output_val_t is array (ALGO_PIPE_CLKS-1 downto 0) of unsigned(bitdepth_out-1 downto 0);
	signal ALGO_output_val                                                     : ALGO_output_val_t; 

	type lin_output_val_t is array(0 to 3) of unsigned(bitdepth_out-1 downto 0);
	signal lin_output_val : lin_output_val_t;

	signal calculated                                                                             : std_logic_vector(ALGO_PIPE_CLKS-1 downto 0);
 
	signal min_per                  : unsigned(10 downto 0);                                                           -- should accomodate values 0-100
	signal max_per                  : unsigned(10 downto 0);                                                           -- should accomodate values 0-100
	signal clip_per                 : unsigned(6 downto 0);
	constant NUM_PIX_BY100            : unsigned(17 downto 0) := to_unsigned((image_width*image_height*64)/100, 18);    -- (512*640)/100 in 12.6 format
	constant NUM_PIX_BY1000            : unsigned(17 downto 0) := to_unsigned((image_width*image_height*64)/1000, 18);    -- (512*640)/1000 in 12.6 format
	signal history1_by100           : unsigned(15 downto 0);
	signal history2_by100           : unsigned(16 downto 0);
	signal dphe_area_for_start      : unsigned (31 downto 0); --:= to_unsigned(image_width*image_height*2/100,32);
	signal dphe_area_for_end        : unsigned (31 downto 0);-- := to_unsigned(image_width*image_height*99/100,32);
	signal dphe_peak_clip_threshold : unsigned(31 downto 0) := to_unsigned(image_width*image_height*25/100,32);

	--pipeline signals
	signal video_v : std_logic_vector(0 to 8);
	signal video_h : std_logic_vector(0 to 8);
	signal video_eoi : std_logic_vector(0 to 8);

	-- ROI related signals
	signal roi_en: std_logic;
	signal video_xcnt_roi : unsigned(PIX_BITS-1 downto 0);
	signal video_ycnt_roi : unsigned(LIN_BITS-1 downto 0);

	signal check_range, check_range_for_calc: unsigned(quo_18'range);
	signal small_range, small_range_for_calc: std_logic;


	------------------------------debug strings---------------------------------------------
	attribute mark_debug : string;

	attribute mark_debug of  video_eoi       :signal is "true"; 
	attribute mark_debug of  video_i_v       :signal is "true"; 
	attribute mark_debug of  prev_start_index       :signal is "true"; 
	attribute mark_debug of  prev_end_index       :signal is "true"; 
	attribute mark_debug of  brightness       :signal is "true"; 
	attribute mark_debug of  prev_brightness       :signal is "true"; 
	attribute mark_debug of  diff_brightness       :signal is "true"; 
	attribute mark_debug of  gain_mult       :signal is "true"; 
	attribute mark_debug of  new_inv_bin_size       :signal is "true"; 
	attribute mark_debug of  inv_max_gain       :signal is "true"; 
	attribute mark_debug of  lin_mul1       :signal is "true"; 
	attribute mark_debug of  lin_mul2       :signal is "true"; 
	attribute mark_debug of  lin_mul3       :signal is "true"; 
	attribute mark_debug of  lin_output_val       :signal is "true"; 
	attribute mark_debug of  pixel_in       :signal is "true"; 
	attribute mark_debug of  pixel_vld       :signal is "true"; 
	attribute mark_debug of  dphe_st       :signal is "true"; 
	attribute mark_debug of  start_found       :signal is "true"; 
	attribute mark_debug of  end_found       :signal is "true"; 
	attribute mark_debug of  dphe_area_for_end       :signal is "true"; 
	attribute mark_debug of  count2       : signal is "true"; 
	attribute mark_debug of  dump1       : signal is "true"; 


	attribute keep : string;

	attribute keep of start_found : signal is "true";
	attribute keep of  end_found       :signal is "true"; 
	attribute keep of  dphe_area_for_end       :signal is "true"; 
	attribute keep of  count2       : signal is "true"; 
	attribute keep of  dump1       : signal is "true"; 


begin

	
		num_out_levels           <= num_out_levels_nroi 			;
		num_pixels               <= resize(unsigned(roi_x_size)*unsigned(roi_y_size), nbits_num_pixels_nroi) when roi_mode='1' else 
									to_unsigned(image_width*image_height, nbits_num_pixels_nroi);
		dphe_max_peaks           <= dphe_max_peaks_nroi 			;
		nbits_dphe_max_peaks     <= nbits_dphe_max_peaks_nroi 		;
		dphe_peak_high_threshold <= dphe_peak_high_threshold_nroi  	;
		dphe_window_length       <= dphe_window_length_nroi 		;
		dphe_walk_length         <= dphe_walk_length_nroi 			;
		nbits_dphe_walk_length   <= nbits_dphe_walk_length_nroi 	;
		dphe_required_sum        <= dphe_required_sum_nroi 			;
		dphe_min_peak_area       <= resize(shift_right(to_unsigned(20, 8)*num_pixels, 8), dphe_min_peak_area'length); -- 8/100 -> 20.48/256 of total pixels


	process(CLK,RST)
	begin
		if RST = '1' then
			we1_1a <= '0';
			rd1_1b <= '0';
			we1_2a <= '0';
			rd1_2b <= '0';
			we2_1a <= '0';
			rd2_1b <= '0';
			we2_2a <= '0';
			rd2_2b <= '0';
			we3a <= '0';
			rd3b <= '0';
			we4_1a <= '0';
			rd4_1b <= '0';
			we4_2a <= '0';
			rd4_2b <= '0';

			rd1_1a <= '0';
			rd1_2a <= '0';
			rd2_1a <= '0';
			rd2_2a <= '0';
			rd3a <= '0';
			rd4_1a <= '0';
			rd4_2a <= '0';
			we1_1b <= '0';
			we1_2b <= '0';
			we2_1b <= '0';
			we2_2b <= '0';
			we3b <= '0';
			we4_1b <= '0';
			we4_2b <= '0';

			add1_1a <= (others => '0');
			add1_2a <= (others => '0');
			add2_1a <= (others => '0');
			add2_2a <= (others => '0');
			add3a <= (others => '0');
			add4_1a <= (others => '0');
			add4_2a <= (others => '0');
			add1_1b <= (others => '0');
			add1_2b <= (others => '0');
			add2_1b <= (others => '0');
			add2_2b <= (others => '0');
			add3b <= (others => '0');
			add4_1b <= (others => '0');
			add4_2b <= (others => '0');

			peak_start_points <= (others => (others => '0'));
			peak_end_points <= (others => (others => '0'));
			area_before_peak <= (others => (others => '0'));
			peak_area_count <= (others => (others => '0'));
			count2 <= (others => '0');
			count3 <= (others => '0');
			count4 <= (others => '0');
			max <= (others => '0');
			peak_count <= (others => '0');
			dump1 <= (others => '0');
			window_sum  <= (others => '0');
			total_sum <= (others => '0');
			low_sum <= (others => '0');
			peak_area <= (others => '0');
			temp <= (others => '0');
			temp2 <= (others => '0');
			num_clipped <= (others => '0');
			old_dump <= (others => '0');
			new_dump <= (others => '0');
			non_zero_levels <= (others => '0');
			non_zero_lowliers <= (others => '0');
			is_first_frame_flag <= "11";
			rd_is_first_frame_flag <= "11";
			prev_clip_pos <= (others => '0');
			prev_max_output_level <= (others => '0');
			prev_t_high <= (others => '0');
			prev_t_low <= (others => '0');
			prev_start_index <= (others => '0');
			prev_end_index <= (others => '1');
			inv_bin_size <= (inv_bin_size'length-1 downto 1 => '0') & "1";
			prev_inv_bin_size <= (prev_inv_bin_size'length-1 downto 1 => '0') & "1";
			peak_sum_till_start <= (others => '0');
			peak_start_count <= (others => '0');
			peak_end_count <= (others => '0');
			avg_low_sum <= (others => '0');
			avg_high_sum <= (others => '0');
			t_high <= (others => '0');
			t_low <= (others => '0');
			effective_t_high <= (others => '0');
			effective_t_low <= (others => '0');
			effective_low_lim <= (others => '0');
			effective_count <= (others => '0');
			rem_pixel_count <= (others => '0');
			t_high_high_portion <= (others => '0');
			t_high_low_portion <= (others => '0');
			t_low_high_portion <= (others => '0');
			t_low_low_portion <= (others => '0');
			t_high_without_rounding <= (others => '0');
			t_low_without_rounding <= (others => '0');
			peak_start <= (others => '0');
			peak_end <= (others => '0');
			peak_width <= (others => '0');
			clip_pos <= (others => '0');
			max_output_level <= (others => '0');
			inflection_point <= (others => '0');
			ALGO_STAGE <= (others => '0');
			ALGO_output_val <= (others => (others => '0'));
			ALGO_input_val <= (others => (others => '0'));
			calculated <= (others => '0');
			start_index <= (others => '0');
			end_index <= (others => '0');
			orig_clip_pos <= (others => '0');
			hist_span <= (others => '0');
			quant1 <= (others => '0');
			quant2 <= (others => '0');
			quant1_mul <= (others => '0');
			quant2_mul <= (others => '0');
			quant2_mul_m <= (others => '0');
			quant2_mul_mm <= (others => '0');
			ratio3 <= (others => '0');
			add2_m <= (others => '0');
			output_val_1 <= (others => '0');
			output_val_1_m <= (others => '0');
			output_val_1_mm <= (others => '0');
			output_val_2 <= (others => '0');
			dvsr_18 <= (others => '0');
			dvnd_18 <= (others => '0');
			dvsr_33 <= (others => '0');
			dvnd_33 <= (others => '0');
			start_found <= '0';
			end_found <= '0';
			peak_found <= '0';
			changed <= '0';
			start_18 <= '0';
			start_33 <= '0';
			d1 <= (others => '0');
			d2 <= (others => '0');
			clip_pos_mod <= (others => '0');
			clip_mul <= (others => '0');
			ratio <= (others => '0');
			ratio1 <= (others => '0');
			ratio2 <= (others => '0');
			prev_bin_size <= (prev_bin_size'length-1 downto 1 => '0') & "1";
			avail_range <= (others => '0');
			extra_whole <= (others => '0');
			extra_dec <= (others => '0');
			extra_dec_1 <= (others => '0');
			whole <= (others => '0');
			dec <= (others => '0');
			diff_t_low <= (others => '0');
			diff_t_high <= (others => '0');
			diff_max_output_level <= (others => '0');
		    diff_clip_pos <= (others => '0');
			diff_start_index <= (others => '0');
			diff_end_index <= (others => '0');
			mul_t_low <= (others => '0');
			mul_t_high <= (others => '0');
			mul_orig_clip_pos <= (others => '0');
			mul_max_output_level <= (others => '0');
			mul_start_index <= (others => '0');
			mul_end_index <= (others => '0');
			max_output_level_with_rounding <= (others => '0');
			peak_extend <= (others => '0');
			sum_start_end <= (others => '0');
			pixel_out <= (others => '0');
			pixel_vld_out <= '0';
			video_xcnt <= (others => '0');
			video_ycnt <= (others => '0');
			we_mem_no <= '0';
			rd_mem_no <= '0';
			is_prev_calc_done <= '0';
			switch_lut <= '0';
			rd_lut_prev_no <= '0';
			wr_lut_prev_no <= '0';
			start_calc <= '0';
			prev_bin_size_for_output <= (others => '0');
			prev_start_index_for_output <= (others => '0');
			prev_max_output_level_for_output <= (others => '0');
			prev_inv_bin_size_for_output <= (others => '0');
			new_bin_size <= (others => '0');
			new_inv_bin_size <= (others => '0');
			bin_size_for_calc <= (others => '0');
			inv_bin_size_for_calc <= (others => '0');
			prev_start_index_for_calc <= (others => '0');
			prev_end_index_for_calc <= (others => '0');
			dphe_range_threshold <= (others => '0');
			half_dphe_range_threshold <= (others => '0');
			cdf_val <= (others => '0');

			start_algo <= '0';
			mems_cleared <= '0';
			min_per <= (others => '0');
			max_per <= (others => '0');
			clip_per <= (others => '0');
			history1_by100 <= (others => '0');
			history2_by100 <= (others => '0');
			dphe_st <= clear_mems;

			video_v <= (others=>'0');
			video_h <= (others=>'0');
			video_eoi <= (others=>'0');

			--roi signals
			roi_en <= '0';
			video_xcnt_roi <= (others=>'0');
			video_ycnt_roi <= (others=>'0');
			brightness <= (others=>'0');
			prev_brightness <= (others=>'0');
			prev_brightness_for_output <= (others=>'0');
			diff_brightness <= (others=>'0');
			mul_brightness <= (others=>'0');
			check_range <= (others=>'0');
			check_range_for_calc <= (others=>'0');
			inv_max_gain <= (others=>'0');
			small_range <= '0';
			small_range_for_calc <= '0';
			gain_mult <= (others=>'0');
			prev_gain_mult <= (others=>'0');
			lin_mul3 <= (others=>'0');
			lin_mul1 <= (others=>'0');
			lin_mul2 <= (others=>'0');
			lin_output_val <= (others=>(others=>'0'));
			prev_gain_mult_for_calc <= (others=>'0');
			intensity_shift <= (others=>'0');
			prev_intensity_shift <= (others=>'0');
			prev_intensity_shift_for_output <= (others=>'0');
			diff_intensity_shift <= (others=>'0');
			mul_intensity_shift <= (others=>'0');

			dphe_area_for_start <= to_unsigned(image_width*image_height*20/1000, dphe_area_for_start'length);
			dphe_area_for_end	<= to_unsigned(image_width*image_height*950/1000, dphe_area_for_end'length);

		elsif rising_edge(CLK) then
			video_v(0) <=video_i_v;
			video_h(0) <= video_i_h;
			for i in 0 to 7 loop
				video_v(i+1)<=video_v(i);
				video_h(i+1)<=video_h(i);
				video_eoi(i+1)<=video_eoi(i);
			end loop;
		
			pixel_vld_out <= '0';
			calculated <= (others => '0');
		
			if pixel_vld_out = '1' then
				video_xcnt <= video_xcnt + 1;
			end if;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
			-- ROI mode writing to histogram
			-- use an enable signal for ROI and then
			-- 'and' it with the write signal for hist memory
			-- In non-ROI mode this signal will always be 1.
----------------------------------------------------------------------------------------------------------------------------------------------------------------			
			if ALGO_STAGE(2)='1' then
				video_xcnt_roi <= video_xcnt_roi +1;
			end if;

			if video_xcnt_roi=image_width-1  and ALGO_STAGE(2)='1' then
				video_xcnt_roi <= (others=>'0');
				if video_ycnt_roi=image_height-1 then
					video_ycnt_roi <=(others=>'0');	
				else
					video_ycnt_roi <= video_ycnt_roi +1;
				end if;
			end if;

			if roi_mode='1' then
				if (video_xcnt_roi >= unsigned(roi_x_offset) and video_xcnt_roi < (unsigned(roi_x_offset)+unsigned(roi_x_size))
					and video_ycnt_roi >= unsigned(roi_y_offset) and video_ycnt_roi < (unsigned(roi_y_offset)+unsigned(roi_y_size))) then
						roi_en <='1';
				else
					roi_en <='0';
				end if;
			else
				roi_en <='1';
			end if;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
			if video_h(8) = '1' then
				video_xcnt <= (others => '0');
				video_ycnt <= video_ycnt + 1;
			end if;
			
			if video_i_v = '1' then
				min_per	<= unsigned(cntrl_min_dphe(min_per'length-1 downto 0));			--Value gets registered only at the beginning of frame
				max_per	<= unsigned(cntrl_max_dphe(max_per'length-1 downto 0));			--Value gets registered only at the beginning of frame
				clip_per <= unsigned(cntrl_clip_dphe(clip_per'length-1 downto 0));      --Value gets registered only at the beginning of frame
				video_ycnt <= (others => '1');
				if (rd_is_first_frame_flag = "11") then 
					we_mem_no <= '0';
					rd_mem_no <= '0';
				else
					if we_mem_no = '1' then
						we_mem_no <= '0';
					else
						we_mem_no <= '1';
					end if;
				end if;
			end if;
			

			if (video_xcnt = image_width-1) and (video_ycnt = image_height-1) and (pixel_vld_out = '1') then
				video_eoi(0) <= '1';
			end if;
			
			if (video_eoi(0) = '1') then
				video_eoi(0) <= '0';
			end if;
			 
			
			if (is_prev_calc_done = '1') and (video_xcnt = image_width and video_ycnt = image_height-1) then
				is_prev_calc_done <= '0';
				switch_lut <= '0';
				check_range_for_calc <= check_range;
				prev_start_index_for_output <= prev_start_index;
				prev_bin_size_for_output <= prev_bin_size;
				prev_brightness_for_output <= prev_brightness;
				prev_max_output_level_for_output <= prev_max_output_level;
				prev_inv_bin_size_for_output <= prev_inv_bin_size;
				dphe_range_threshold <= resize(unsigned(dphe_max_limiter), dphe_range_threshold'length);                          
				dphe_peak_clip_threshold <= resize(shift_right(NUM_PIX_BY1000*clip_per,6),dphe_peak_clip_threshold'length);        --NUM_PIX_BY100 has 6 decimal bits 
				history1_by100 <= resize(unsigned(cntrl_hist1_dphe(6 downto 0))*to_unsigned(655,11), history1_by100'length);	  --(2^16)/100 = 655. Will multiply with diff and then shift right by 16.
				history2_by100 <= resize(unsigned(cntrl_hist2_dphe(6 downto 0))*to_unsigned(1311,11), history2_by100'length);     --(2^17)/100 = 1311. Will multiply with diff and then shift right by 17.
				dphe_area_for_start <= resize(shift_right(NUM_PIX_BY1000*min_per,6),dphe_area_for_start'length);                   --NUM_PIX_BY100 has 6 decimal bits
				dphe_area_for_end <= resize(shift_right(NUM_PIX_BY1000*max_per,6),dphe_area_for_end'length);                       --NUM_PIX_BY100 has 6 decimal bits 
				small_range_for_calc <= small_range;
				prev_gain_mult_for_calc <= prev_gain_mult;
				prev_intensity_shift_for_output <= prev_intensity_shift;
			end if;			
			
			if (video_i_v = '1') and (mems_cleared = '1') then
				start_algo <= '1';
			end if;

							
			rd1_1b <= '0';
			rd1_2b <= '0';
			rd2_1b <= '0';
			rd2_2b <= '0';
			rd3b <= '0';
			rd4_1b <= '0';
			rd4_2b <= '0';
			we1_1a <= '0';
			we1_2a <= '0';
			we2_1a <= '0';
			we2_2a <= '0';
			we3a <= '0';
			we4_1a <= '0';
			we4_2a <= '0';

			rd1_1a <= '0';
			rd1_2a <= '0';
			rd2_1a <= '0';
			rd2_2a <= '0';
			rd3a <= '0';
			rd4_1a <= '0';
			rd4_2a <= '0';
			we1_1b <= '0';
			we1_2b <= '0';
			we2_1b <= '0';
			we2_2b <= '0';
			we3b <= '0';
			we4_1b <= '0';
			we4_2b <= '0';

			--dout1_1m <= dout1_1b;
			--dout1_2m <= dout1_2b;
			--dout3m <= dout3b;
			--dout2_1m <= dout2_1b;
			--dout2_2m <= dout2_2b;
			--dout4_1m <= dout4_1b;
			--dout4_2m <= dout4_2b;
			--dout4_1mm <= dout4_1b;
			--dout4_2mm <= dout4_2b;



			if start_algo = '1' then
				ALGO_STAGE <= ALGO_STAGE(ALGO_STAGE'high-1 downto 0) & pixel_vld;
				if pixel_vld = '1' then
					ALGO_input_val(0) <= unsigned(pixel_in);
					if rd_is_first_frame_flag <= 2 then
						if unsigned(pixel_in) > prev_start_index then
							quant1 <= unsigned(pixel_in) - prev_start_index;
						else
							quant1 <= (others => '0');
						end if;
						if rd_is_first_frame_flag = "00" then
							if unsigned(pixel_in) >= prev_start_index_for_output then 
								quant2 <= unsigned(pixel_in) - prev_start_index_for_output;
							else 
								ALGO_output_val(0) <= (others => '0');
								calculated(0) <= '1';
							end if;
						end if;
					end if;
				end if;
			
				if ALGO_STAGE(0) = '1' then
					ALGO_input_val(1) <= ALGO_input_val(0);
					ALGO_output_val(1) <= ALGO_output_val(0);
					lin_mul1 <= resize(shift_right(ALGO_input_val(0)*prev_gain_mult_for_calc, prev_gain_mult_for_calc'length -1), lin_mul1'length);
					calculated(1) <= calculated(0);
					if rd_is_first_frame_flag <= 2 then
						if ALGO_input_val(0) > prev_start_index then
							quant1_mul <= resize(shift_right((quant1 * inv_bin_size), inv_bin_size'length-1), quant1_mul'length);
						else 
							quant1_mul <= quant1;
						end if;
						if rd_is_first_frame_flag = "00" and (calculated(0) = '0') then
							quant2_mul <= resize(shift_right((quant2 * prev_inv_bin_size_for_output), prev_inv_bin_size_for_output'length-1), quant2_mul'length);
						end if;
					end if;	
				end if;
		  
				if ALGO_STAGE(1) = '1' then 
					ALGO_input_val(2) <= ALGO_input_val(1);
					quant2_mul_m <= resize(signed('0' & quant2_mul), quant2_mul_m'length);
					lin_mul2 <= resize(signed(resize(lin_mul1, prev_brightness_for_output'length) - prev_brightness_for_output), lin_mul2'length);
					if we_mem_no = '0' then
						rd1_1b <= '1';
						--add1_1b <= std_logic_vector(ALGO_input_val(1)((bitdepth_in-1) downto (bitdepth_in-bitdepth_inter)));
						add1_1b <= std_logic_vector(ALGO_input_val(1)((bitdepth_in-1) downto 0));
					else
						rd1_2b <= '1';
						add1_2b <= std_logic_vector(ALGO_input_val(1)((bitdepth_in-1) downto 0));
					end if;
					if rd_is_first_frame_flag <= 2 then
						if quant1_mul >= num_inter_levels then
							if we_mem_no = '0' then
								add2_1b <= "11111111";
								rd2_1b <= '1';
							else
								add2_2b <= "11111111";
								rd2_2b <= '1';
							end if;
						else
							if we_mem_no = '0' then
								add2_1b <= std_logic_vector(resize(quant1_mul, bitdepth_inter));
								rd2_1b <= '1';
							else
								add2_2b <= std_logic_vector(resize(quant1_mul, bitdepth_inter));
								rd2_2b <= '1';
							end if;
						end if;
						if (rd_is_first_frame_flag = "00") and (calculated(1) = '0') then
							if quant2_mul = 0 then
								if switch_lut = '1' then
									add3b <= "00000000";
									rd3b <= '1';
								else
									if rd_lut_prev_no = '0' then
										add4_1b <= "00000000";
										rd4_1b <= '1';
									else
										add4_2b <= "00000000";
										rd4_2b <= '1';
									end if;
								end if;
							elsif quant2_mul >= num_inter_levels then
								ALGO_output_val(2) <= prev_max_output_level_for_output;
								calculated(2) <= '1';
							else 
								if switch_lut = '1' then
									add3b <= std_logic_vector(resize(quant2_mul-1, bitdepth_inter));
									rd3b <= '1';
								else
									if rd_lut_prev_no = '0' then
										add4_1b <= std_logic_vector(resize(quant2_mul-1, bitdepth_inter));
										rd4_1b <= '1';
									else
										add4_2b <= std_logic_vector(resize(quant2_mul-1, bitdepth_inter));
										rd4_2b <= '1';
									end if;
								end if;
								ratio1 <= resize((quant2_mul * prev_bin_size_for_output), ratio1'length);
								ratio2 <= ALGO_input_val(1) - prev_start_index_for_output;
							end if;
						elsif (rd_is_first_frame_flag = "00") and (calculated(1) = '1') then
							ALGO_output_val(2) <= ALGO_output_val(1);
							calculated(2) <= calculated(1);
						end if;
					end if;			
				end if;
		  
				if ALGO_STAGE(2) = '1' then
					ALGO_input_val(3) <= ALGO_input_val(2);
					ALGO_output_val(3) <= ALGO_output_val(2);
					lin_mul3 <= resize(to_signed(128, lin_mul3'length) + lin_mul2, lin_mul3'length);
					calculated(3) <= calculated(2);
					if we_mem_no = '0' then
						add2_m <= add2_1b;
					else 
						add2_m <= add2_2b;
					end if;	
					quant2_mul_mm <= quant2_mul_m;
					if (rd_is_first_frame_flag = "00") and (calculated(2) = '0') then
						if quant2_mul_m /= 0 then
							if switch_lut = '1' then
								add3a <= std_logic_vector(unsigned(add3b) + 1);
								rd3a <= '1';
							else
								if rd_lut_prev_no = '0' then
									add4_1a <= std_logic_vector(unsigned(add4_1b) + 1);
									rd4_1a <= '1';
								else
									add4_2a <= std_logic_vector(unsigned(add4_2b) + 1);
									rd4_2a <= '1';
								end if;
							end if;					
							if ratio2 > ratio1 then
								ratio3 <= ratio2 - ratio1;
							else
								ratio3 <= (others => '0');
							end if;
						end if;
					end if;
				end if;

				if ALGO_STAGE(3) = '1' then
					ALGO_input_val(4) <= ALGO_input_val(3);

					if we_mem_no = '0' then 
						--add1_1a <= std_logic_vector(ALGO_input_val(3)((bitdepth_in-1) downto (bitdepth_in-bitdepth_inter)));
						add1_1a <= std_logic_vector(ALGO_input_val(3)((bitdepth_in-1) downto 0));
						we1_1a <= '1' and roi_en;
						din1_1a <= std_logic_vector(unsigned(dout1_1b) + 1);
					else
						--add1_2a <= std_logic_vector(ALGO_input_val(3)((bitdepth_in-1) downto (bitdepth_in-bitdepth_inter)));
						add1_2a <= std_logic_vector(ALGO_input_val(3)((bitdepth_in-1) downto 0));
						we1_2a <= '1' and roi_en;
						din1_2a <= std_logic_vector(unsigned(dout1_2b) + 1);
					end if;
					if rd_is_first_frame_flag <= 2 then
						if we_mem_no = '0' then 
							add2_1a <= add2_m;
							we2_1a <= '1' and roi_en;
							din2_1a <= std_logic_vector(unsigned(dout2_1b) + 1);	
						else
							add2_2a <= add2_m;
							we2_2a <= '1' and roi_en;
							din2_2a <= std_logic_vector(unsigned(dout2_2b) + 1);
						end if;
						if (rd_is_first_frame_flag = "00") and (calculated(3) = '0') then
							if quant2_mul_mm = 0 then
								if switch_lut = '1' then
									ALGO_output_val(4) <= resize(unsigned(dout3b), bitdepth_out);
								else
									if rd_lut_prev_no = '0' then
										ALGO_output_val(4) <= unsigned(dout4_1b);
									else
										ALGO_output_val(4) <= unsigned(dout4_2b);
									end if;
								end if;
								calculated(4) <= '1';
							else
								if switch_lut = '1' then
									output_val_1 <= resize(unsigned(dout3b), bitdepth_out);
								else
									if rd_lut_prev_no = '0' then
										output_val_1 <= unsigned(dout4_1b);
									else
										output_val_1 <= unsigned(dout4_2b);
									end if;
								end if;
								ratio <= ratio3 * prev_inv_bin_size_for_output;
							end if;
						elsif (rd_is_first_frame_flag = "00") and (calculated(3) = '1') then 
							calculated(4) <= calculated(3);
							ALGO_output_val(4) <= ALGO_output_val(3);
						end if;
					end if;
					if (lin_mul3 <= (to_signed(0, lin_mul3'length))) then
						lin_output_val(0) <= to_unsigned(0, lin_output_val(0)'length);
					elsif (lin_mul3 >= (to_signed(num_out_levels_nroi, lin_mul3'length))) then
						lin_output_val(0) <= to_unsigned(num_out_levels_nroi, lin_output_val(0)'length);
					else
						lin_output_val(0) <= unsigned(lin_mul3(lin_output_val(0)'length-1 downto 0));
					end if;
				end if; 
						
				if ALGO_STAGE(4) = '1' then
					ALGO_input_val(5) <= ALGO_input_val(4);
					calculated(5) <= calculated(4);
					ALGO_output_val(5) <= ALGO_output_val(4);
					lin_output_val(1) <= lin_output_val(0);
					output_val_1_m <= output_val_1;
					if (rd_is_first_frame_flag = "00") and (calculated(4) = '0') then
						if switch_lut = '1' then
							avail_range <= resize(unsigned(dout3a),bitdepth_out) - output_val_1;
						else
							if rd_lut_prev_no = '0' then
								avail_range <= unsigned(dout4_1a) - output_val_1;
							else
								avail_range <= unsigned(dout4_2a) - output_val_1;
							end if;
						end if;
						whole <= resize(shift_right(ratio, prev_inv_bin_size_for_output'length-1), whole'length);
						dec <= resize(ratio, prev_inv_bin_size_for_output'length-1);
					end if;
				end if;
					
				if ALGO_STAGE(5) = '1' then
					ALGO_input_val(6) <= ALGO_input_val(5);
					calculated(6) <= calculated(5);
					ALGO_output_val(6) <= ALGO_output_val(5);
					lin_output_val(2) <= lin_output_val(1);
					output_val_1_mm <= output_val_1_m;
					if (rd_is_first_frame_flag = "00") and (calculated(5) = '0') then
						extra_whole <= resize((whole * avail_range), bitdepth_out);
						extra_dec <= dec * avail_range;
					end if;
				end if;
					
				if ALGO_STAGE(6) = '1' then
					ALGO_input_val(7) <= ALGO_input_val(6);
					calculated(7) <= calculated(6);
					ALGO_output_val(7) <= ALGO_output_val(6);
					lin_output_val(3) <= lin_output_val(2);
					if (rd_is_first_frame_flag = "00") and (calculated(6) = '0') then
						if extra_dec(prev_inv_bin_size_for_output'length-2) = '1' then
							output_val_2 <= output_val_1_mm + extra_whole + 1;
						else
							output_val_2 <= output_val_1_mm + extra_whole;
						end if;
						extra_dec_1 <= shift_right(extra_dec, prev_inv_bin_size_for_output'length-1);
					end if;
				end if;
				
				if ALGO_STAGE(7) = '1' then
					if(linear_hist_en='1') then
						ALGO_output_val(8) <= lin_output_val(3);
					else
						if (rd_is_first_frame_flag = "00") and (calculated(7) = '0') then
							ALGO_output_val(8) <= output_val_2 + resize(extra_dec_1, bitdepth_out)+prev_intensity_shift_for_output;
							calculated(8) <= '1';
						elsif (rd_is_first_frame_flag = "00") and (calculated(7) = '1') then
							calculated(8) <= calculated(7);
							ALGO_output_val(8) <= ALGO_output_val(7)+prev_intensity_shift_for_output;
						end if;
					end if;
				end if;
					
				if ALGO_STAGE(8) = '1' then
					pixel_vld_out <= '1';
					if (rd_is_first_frame_flag = "00") then
						pixel_out <= std_logic_vector(ALGO_output_val(8) + 16);
					else 
						pixel_out <= std_logic_vector(ALGO_input_val(8)((bitdepth_in-1) downto (bitdepth_in-bitdepth_out)));
					end if;
--					if (video_xcnt = image_width-1) and (video_ycnt = image_height-1) then
--						switch_lut <= '0';
--						if rd_is_first_frame_flag = 1 then
--							rd_lut_prev_no <=  '0';
--						elsif rd_is_first_frame_flag = 0 then
--							if rd_lut_prev_no = '0' then
--								rd_lut_prev_no <= '1';
--							else
--								rd_lut_prev_no <= '0';
--							end if;
--						end if;
--						start_calc <= '1';
--						if rd_is_first_frame_flag >= 1 then
--							rd_is_first_frame_flag <= rd_is_first_frame_flag - 1;
--						end if;
--					end if;
				end if;
			    if (video_xcnt = image_width-1) and (video_ycnt = image_height-1) and (pixel_vld_out = '1') then
                    switch_lut <= '0';
                    if rd_is_first_frame_flag = 1 then
                        rd_lut_prev_no <=  '0';
                    elsif rd_is_first_frame_flag = 0 then
                        if rd_lut_prev_no = '0' then
                            rd_lut_prev_no <= '1';
                        else
                            rd_lut_prev_no <= '0';
                        end if;
                    end if;
                    start_calc <= '1';
                    if rd_is_first_frame_flag >= 1 then
                        rd_is_first_frame_flag <= rd_is_first_frame_flag - 1;
                    end if;
                end if;
				
				
				
					
			end if;
					
			case dphe_st is
			
				when clear_mems =>
					if count2 < num_in_levels then
						count2 <= count2 + 1;
						we1_1a <= '1';
						add1_1a <= std_logic_vector(count2(bitdepth_in-1 downto 0));
						din1_1a <= (others => '0');
						we1_2a <= '1';
						add1_2a <= std_logic_vector(count2(bitdepth_in-1 downto 0));
						din1_2a <= (others => '0');
						if count2 < num_inter_levels then
							we2_1a <= '1';
							add2_1a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
							din2_1a <= (others => '0');
							we2_2a <= '1';
							add2_2a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
							din2_2a <= (others => '0');
							we3a <= '1';
							add3a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
							din3a <= (others => '0');
							we4_1a <= '1';
							add4_1a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
							din4_1a <= (others => '0');
							we4_2a <= '1';
							add4_2a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
							din4_2a <= (others => '0');
						end if;
						dphe_st <= clear_mems;
					else
						count2 <= (others => '0');
						we1_1a <= '0';
						we1_2a <= '0';
						we2_1a <= '0';
						we2_2a <= '0';
						we3a <= '0';
						we4_1a  <= '0';
						we4_2a <= '0';
						mems_cleared <= '1';
						dphe_st <= idle;
					end if;
             
				when idle =>
					if start_calc = '1' then
						dphe_st <= get_end_points;
						start_calc <= '0';
					end if;
					
				when get_end_points =>
					if count2 < num_in_levels then
						if rd_mem_no = '0' then
							add1_1b <= std_logic_vector(count2(bitdepth_in-1 downto 0));
							rd1_1b <= '1';
						else
							add1_2b <= std_logic_vector(count2(bitdepth_in-1 downto 0));
							rd1_2b <= '1';
						end if;
						dphe_st <= rd_shifted_hist;  
					else
						if is_first_frame_flag <= 1 then
							count2 <= (others => '0');
							start_found <= '0';
							end_found <= '0';
							dphe_st <= averaging_start_end_1;
						else
							count2 <= (others => '0');
							start_found <= '0';
							end_found <= '0';
							dvnd_18 <= std_logic_vector(resize((end_index - start_index + 1), nbits_num_pixels_nroi+1));
							dvsr_18 <= std_logic_vector(to_unsigned(256, nbits_num_pixels_nroi+1));
							start_18 <= '1';
							dphe_st <= calculate_bin_size;
						end if;
					end if;
        
				when rd_shifted_hist =>
					if rd_mem_no = '0' then
						rd1_1b <= '0';
					else
						rd1_2b <= '0';
					end if;
					dphe_st <= comp_shifted_cdf;
           
				when comp_shifted_cdf =>
					if rd_mem_no = '0' then
						dump1 <= dump1 + resize(unsigned(dout1_1b), dump1'length);
					else 
						dump1 <= dump1 + resize(unsigned(dout1_2b), dump1'length);
					end if;
					if(start_found='1') then
						dphe_st <= compare2;
					else
						dphe_st <= compare1;
					end if;

				when compare1 =>
					count2 <= count2 + 1;
					if (resize(dump1, dphe_area_for_start'length) >= dphe_area_for_start) and (start_found = '0') then
						--start_index <= count2(bitdepth_inter-1 downto 0) & ((bitdepth_in - bitdepth_inter - 1) downto 0 => '0');
						--start_index <= count2(bitdepth_in-1 downto 0);
						if (count2(bitdepth_in-1 downto 0) > to_unsigned(64,bitdepth_in))  then
							start_index <= count2(bitdepth_in-1 downto 0) - 64;
						else 
							start_index <= to_unsigned(0,bitdepth_in);
						end if;
						start_found <= '1';
					end if;
					dphe_st <= get_end_points;				

				when compare2 =>
					count2 <= count2 + 1;
					if (resize(dump1, dphe_area_for_end'length) >= dphe_area_for_end)  and (end_found = '0' and start_found='1') then
						--end_index <= (count2(bitdepth_inter-1 downto 0) + 3) & ((bitdepth_in - bitdepth_inter - 1) downto 0 => '0');
						--end_index <= (count2(bitdepth_in-1 downto 0) + 3);
						if (count2(bitdepth_in-1 downto 0) < to_unsigned(16255,bitdepth_in))  then
							end_index <= count2(bitdepth_in-1 downto 0) + 128;
						else 
							end_index <= to_unsigned(16383,bitdepth_in);
						end if;
						end_found <= '1';	
					end if;
					dphe_st <= get_end_points;				
														
				when averaging_start_end_1 =>
					if start_index > prev_start_index_for_calc then
						diff_start_index <= start_index - prev_start_index_for_calc;
					else
						diff_start_index <= prev_start_index_for_calc - start_index;
					end if;
					if end_index > prev_end_index_for_calc then
						diff_end_index <= end_index - prev_end_index_for_calc;
					else
						diff_end_index <= prev_end_index_for_calc - end_index;
					end if;
					dphe_st <= averaging_start_end_mul1;
					
				when averaging_start_end_mul1 =>
					mul_start_index <= diff_start_index * history1_by100;                           -- multiply by 0.200012207031250
					dphe_st <= averaging_start_end_mul2;
					
				when averaging_start_end_mul2 =>
					mul_end_index <= diff_end_index * history1_by100;                               -- multiply by 0.200012207031250
					dphe_st <= averaging_start_end_2;
					
				when averaging_start_end_2 =>
					if start_index < prev_start_index_for_calc then
						mul_start_index <= mul_start_index - resize(diff_start_index, mul_start_index'length);
					end if;
					if end_index < prev_end_index_for_calc then
						mul_end_index <= mul_end_index - resize(diff_end_index, mul_end_index'length);
					end if;
					dphe_st <= averaging_start_end_3;

				when averaging_start_end_3 =>
					if start_index > prev_start_index_for_calc then
						start_index <= resize(shift_right(((prev_start_index_for_calc & "0000000000000000") + mul_start_index), 16), start_index'length);
					else
						start_index <= resize(shift_right(((prev_start_index_for_calc & "0000000000000000") - mul_start_index), 16), start_index'length);
					end if;
					if end_index > prev_end_index_for_calc then
						end_index <= resize(shift_right(((prev_end_index_for_calc & "0000000000000000") + mul_end_index), 16), end_index'length);
					else
						end_index <= resize(shift_right(((prev_end_index_for_calc & "0000000000000000") - mul_end_index), 16), end_index'length);
					end if;
					dphe_st <= average_start_end_done;

					
				when average_start_end_done =>
					dvnd_18 <= std_logic_vector(resize((end_index - start_index + 1), nbits_num_pixels_nroi+1));
					dvsr_18 <= std_logic_vector(to_unsigned(256, nbits_num_pixels_nroi+1));
					start_18 <= '1';
					dphe_st <= calculate_bin_size;					
					
				when calculate_bin_size =>
					if done_tick_18 = '1' then
						if unsigned(rmd_18) = 0 then
							new_bin_size <= unsigned(quo_18);
						else
							new_bin_size <= unsigned(quo_18) + 1;
						end if;
						dphe_st <= calculate_inv_bin_size_1;
					else
						start_18 <= '0';
						dphe_st <= calculate_bin_size;
					end if;

				--when calculate_range1 =>
				--	dvnd_18 <= (std_logic_vector(to_unsigned(num_out_levels_nroi, nbits_num_pixels_nroi+1-8)) & x"00");
				--	dvsr_18 <= std_logic_vector(resize(unsigned(max_gain), dvsr_18'length));
				--	start_18 <= '1';
				--	dphe_st <= calculate_range2;

				--when calculate_range2 =>
				--	if done_tick_18='1' then
				--		check_range <= unsigned(quo_18)/2;
				--		dphe_st <= calculate_max_gain1;
				--	else
				--		start_18 <= '0';
				--	end if;
					
											
				when calculate_inv_bin_size_1 =>
					dvnd_18 <= "1" & (nbits_num_pixels_nroi-1 downto 0 => '0');
					dvsr_18 <= std_logic_vector(new_bin_size);
					start_18 <= '1';
					dphe_st <= calculate_inv_bin_size_2;
					
				when calculate_inv_bin_size_2 =>
					if done_tick_18 = '1' then
						dphe_st <= calculate_max_gain1;
						new_inv_bin_size <= unsigned(quo_18);
						if is_first_frame_flag = "11" then
							prev_start_index <= start_index;
							prev_end_index <= end_index;
							inv_bin_size <= unsigned(quo_18);
							prev_start_index_for_calc <= start_index;
							prev_end_index_for_calc <= end_index;
							--dphe_st <= rest;
						else
							prev_start_index <= start_index;
							prev_end_index <= end_index;
							inv_bin_size <= unsigned(quo_18);
							--dphe_st <= find_peaks;
						end if;
					else
						start_18 <= '0';
						dphe_st <= calculate_inv_bin_size_2;
					end if;

				when calculate_max_gain1=>
					inv_max_gain <= unsigned(max_gain & (nbits_num_pixels_nroi-7-1 downto 0 => '0'));
					dphe_st <= calculate_max_gain2;

				when calculate_max_gain2 =>
					if(new_inv_bin_size > inv_max_gain) then
						gain_mult <= inv_max_gain;
					else
						gain_mult <= new_inv_bin_size;
					end if;
					if (is_first_frame_flag="11") then
						dphe_st <= rest;
					else
						dphe_st <= find_peaks;
					end if;
          
				when find_peaks =>
					if count2 < num_inter_levels then
						if rd_mem_no = '0' then
							rd2_1b <= '1';
							add2_1b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						else
							rd2_2b <= '1';
							add2_2b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						end if;
						dphe_st <= rd_inter_hist;
					else
						count2 <= (others => '0');
						dvnd_18 <= std_logic_vector(resize(low_sum, nbits_num_pixels_nroi+1));
						if non_zero_lowliers /= 0 then
							dvsr_18 <= std_logic_vector(resize(non_zero_lowliers, nbits_num_pixels_nroi+1));
						else 
							dvsr_18 <= (nbits_num_pixels_nroi downto 1 => '0') & "1";
						end if;
						start_18 <= '1';
						dphe_st <= compute_avg_low_sum;
					end if;
			 
				when rd_inter_hist =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					if count2 < dphe_window_length then
						dphe_st <= generate_window;
					else
						dphe_st <= update_window_1;
					end if;
      
				when generate_window =>
					if rd_mem_no = '0' then
						window_sum <= window_sum + unsigned(dout2_1b);
						low_sum <= low_sum + unsigned(dout2_1b);
						total_sum <= total_sum + unsigned(dout2_1b);
						if unsigned(dout2_1b) /= 0 then
							non_zero_levels <= non_zero_levels + 1;
							non_zero_lowliers <= non_zero_lowliers + 1;
						end if;
					else
						window_sum <= window_sum + unsigned(dout2_2b);
						low_sum <= low_sum + unsigned(dout2_2b);
						total_sum <= total_sum + unsigned(dout2_2b);
						if unsigned(dout2_2b) /= 0 then
							non_zero_levels <= non_zero_levels + 1;
							non_zero_lowliers <= non_zero_lowliers + 1;
						end if;
					end if;					
					count2 <= count2 + 1;
					dphe_st <= find_peaks;
          
				when update_window_1 =>
					if rd_mem_no = '0' then 
						rd2_1b <= '1';
						add2_1b <= std_logic_vector(count2(bitdepth_inter-1 downto 0) - dphe_window_length);
						window_sum <= window_sum + unsigned(dout2_1b);
						low_sum <= low_sum + unsigned(dout2_1b);
						total_sum <= total_sum + unsigned(dout2_1b);
						temp <= unsigned(dout2_1b);
					else
						rd2_2b <= '1';
						add2_2b <= std_logic_vector(count2(bitdepth_inter-1 downto 0) - dphe_window_length);
						window_sum <= window_sum + unsigned(dout2_2b);
						low_sum <= low_sum + unsigned(dout2_2b);
						total_sum <= total_sum + unsigned(dout2_2b);
						temp <= unsigned(dout2_2b);
					end if;
					dphe_st <= rd_inter_hist_prev;
          
				when rd_inter_hist_prev =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					dphe_st <= update_window_2;
          
				when update_window_2 =>
					if temp = 0 then
						count2 <= count2 + 1;
						if rd_mem_no = '0' then 
							window_sum <= window_sum - unsigned(dout2_1b);
						else
							window_sum <= window_sum - unsigned(dout2_2b);
						end if;
						dphe_st <= find_peaks;
					else
						if rd_mem_no = '0' then 
							window_sum <= window_sum - unsigned(dout2_1b);
						else
							window_sum <= window_sum - unsigned(dout2_2b);
						end if;
						non_zero_levels <= non_zero_levels + 1;
						non_zero_lowliers <= non_zero_lowliers + 1;
						dphe_st <= check_start_end_peak;
					end if;
          
				when check_start_end_peak =>
					if (peak_count >= 1) and (count2 <= peak_end_points(to_integer(peak_count-1))) then
						count2 <= count2 + 1;
						dphe_st <= find_peaks;
					elsif (window_sum >= dphe_required_sum) and (peak_found = '0') then 
						peak_start <= count2(bitdepth_inter-1 downto 0);
						peak_start_count <= temp;
						peak_end <= count2(bitdepth_inter-1 downto 0);
						peak_area <= temp;
						peak_sum_till_start <= total_sum - temp;
						peak_found <= '1';
						count2 <= count2 + 1;
						peak_width <= to_unsigned(1, bitdepth_inter);
						dphe_st <= find_peaks;
					elsif (window_sum >= dphe_required_sum) and (peak_found = '1') then
						peak_end <= count2(bitdepth_inter-1 downto 0);
						peak_end_count <= temp;
						peak_area <= peak_area + temp;
						count2 <= count2 + 1;
						peak_width <= peak_width + 1;
						dphe_st <= find_peaks;
					elsif (window_sum < dphe_required_sum) and (peak_found = '1') and (peak_area < dphe_min_peak_area) then
						peak_found <= '0';
						count2 <= count2 + 1;
						peak_width <= (others => '0');
						peak_area <= (others => '0');
						dphe_st <= find_peaks;
					elsif (window_sum < dphe_required_sum) and (peak_found = '1') and (peak_area >= dphe_min_peak_area) then
						count3 <= peak_start - 1;
						count4 <= (others => '0');
						temp2 <= (others => '0');
						peak_extend <= (others => '0');
						if peak_start < dphe_walk_length then
							max <= peak_start(nbits_dphe_walk_length_nroi-1 downto 0);
						else
							max <= to_unsigned(dphe_walk_length, nbits_dphe_walk_length_nroi);
						end if;
						dphe_st <= refine_peak_start;
					else 
						count2 <= count2 + 1;
						dphe_st <= find_peaks;
					end if;
          
				when refine_peak_start =>
					if ((peak_count >= 1) and (count3 = peak_end_points(to_integer(peak_count-1)))) or (count3 = 0) or (count4 >= max) then
						count3 <= peak_end + 1;
						count4 <= (others => '0');
						temp2 <= (others => '0');
						peak_extend <= (others => '0');
						if (num_inter_levels - 1 - peak_end) < dphe_walk_length then
							max <= resize((num_inter_levels - 1 - peak_end), nbits_dphe_walk_length_nroi);
						else
							max <= to_unsigned(dphe_walk_length,  nbits_dphe_walk_length_nroi);
						end if;
						dphe_st <= refine_peak_end;					
					elsif count4 < max then
						if rd_mem_no = '0' then
							rd2_1b <= '1';
							add2_1b <= std_logic_vector(count3);
						else 
							rd2_2b <= '1';
							add2_2b <= std_logic_vector(count3);
						end if;
						dphe_st <= read_inter_hist_walk_low;
					end if;
          
				when read_inter_hist_walk_low =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					dphe_st <= store_temp_low;
          
				when store_temp_low =>
					if rd_mem_no = '0' then
						temp2 <= temp2 + unsigned(dout2_1b);
						if unsigned(dout2_1b) /= 0 then
							peak_extend <= peak_extend + 1;
						end if;
					else
						temp2 <= temp2 + unsigned(dout2_2b);
						if unsigned(dout2_2b) /= 0 then
							peak_extend <= peak_extend + 1;
						end if;
					end if;
					dphe_st <= compare_low;
          
				when compare_low =>
					if rd_mem_no = '0' then
						if (unsigned(dout2_1b) < peak_start_count) and (unsigned(dout2_1b) /= 0) then
							peak_start_count <= unsigned(dout2_1b);
							peak_start <= count3;
							peak_area <= peak_area + temp2;
							peak_sum_till_start <= peak_sum_till_start - temp2;
							temp2 <= (others => '0');
							peak_width <= peak_width + resize(peak_extend, bitdepth_inter);
							peak_extend <= (others => '0');
						end if;
					else
						if (unsigned(dout2_2b) < peak_start_count) and (unsigned(dout2_2b) /= 0) then
							peak_start_count <= unsigned(dout2_2b);
							peak_start <= count3;
							peak_area <= peak_area + temp2;
							peak_sum_till_start <= peak_sum_till_start - temp2;
							temp2 <= (others => '0');
							peak_width <= peak_width + resize(peak_extend, bitdepth_inter);
							peak_extend <= (others => '0');
						end if;
					end if;
					count3 <= count3 - 1;
					count4 <= count4 + 1;
					dphe_st <= refine_peak_start;
          
				when refine_peak_end =>
					if count4 < max then
						if rd_mem_no = '0' then
							rd2_1b <= '1';
							add2_1b <= std_logic_vector(count3);
						else
							rd2_2b <= '1';
							add2_2b <= std_logic_vector(count3);
						end if;
						dphe_st <= read_inter_hist_walk_high;
					else
						count3 <= (others => '0');
						count4 <= (others => '0');
						temp2 <= (others => '0');
						dphe_st <= store_peak;
					end if;
          
				when read_inter_hist_walk_high =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					dphe_st <= store_temp_high;
          
				when store_temp_high =>
					if rd_mem_no = '0' then
						temp2 <= temp2 + unsigned(dout2_1b);
						if unsigned(dout2_1b) /= 0 then
							peak_extend <= peak_extend + 1;
						end if;
					else
						temp2 <= temp2 + unsigned(dout2_2b);
						if unsigned(dout2_2b) /= 0 then
							peak_extend <= peak_extend + 1;
						end if;
					end if;
					dphe_st <= compare_high;
        
				when compare_high =>
					if rd_mem_no = '0' then
						if (unsigned(dout2_1b) < peak_end_count) and (unsigned(dout2_1b) /= 0) then
							peak_end_count <= unsigned(dout2_1b);
							peak_end <= count3;
							peak_area <= peak_area + temp2;
							temp2 <= (others => '0');
							peak_width <= peak_width + resize(peak_extend, bitdepth_inter);
							peak_extend <= (others => '0');
						end if;
					else
						if (unsigned(dout2_2b) < peak_end_count) and (unsigned(dout2_2b) /= 0) then
							peak_end_count <= unsigned(dout2_2b);
							peak_end <= count3;
							peak_area <= peak_area + temp2;
							temp2 <= (others => '0');
							peak_width <= peak_width + resize(peak_extend, bitdepth_inter);
							peak_extend <= (others => '0');
						end if;
					end if;					
					count3 <= count3 + 1;
					count4 <= count4 + 1;
					dphe_st <= refine_peak_end;
          
				when store_peak =>
					low_sum <= low_sum - peak_area;
					non_zero_lowliers <= non_zero_lowliers - peak_width;
					peak_start_points(to_integer(peak_count)) <= peak_start;
					peak_end_points(to_integer(peak_count)) <= peak_end;
					area_before_peak(to_integer(peak_count)) <= peak_sum_till_start;
					peak_area_count(to_integer(peak_count)) <= peak_area;
					peak_found <= '0';
					peak_count <= peak_count + 1;
					peak_area <= (others => '0');
					peak_width <= (others => '0');
					count2 <= count2 + 1;
					dphe_st <= find_peaks;
									
				when compute_avg_low_sum =>
					if done_tick_18 = '1' then
						avg_low_sum <= resize((unsigned(quo_18)), nbits_num_pixels_nroi);
						dvnd_18 <= std_logic_vector(resize(num_pixels, nbits_num_pixels_nroi+1));
						if non_zero_levels /= 0 then
							dvsr_18 <= std_logic_vector(resize(non_zero_levels, nbits_num_pixels_nroi+1));
						else
							dvsr_18 <= (nbits_num_pixels_nroi downto 1 => '0') & "1";
						end if;
						start_18 <= '1';
						dphe_st <= compute_avg_high_sum;
					else
						start_18 <= '0';
						dphe_st <= compute_avg_low_sum;
					end if;
				
				when compute_avg_high_sum =>
					if done_tick_18 = '1' then
						avg_high_sum <= resize((unsigned(quo_18)), nbits_num_pixels_nroi);
						dphe_st <= compute_thresholds_1_1;
					else
						start_18 <= '0';
						dphe_st <= compute_avg_high_sum;
					end if;
          
				when compute_thresholds_1_1 =>
					t_high_high_portion <= avg_high_sum * "0100110011001101";                      -- multiply by 0.300003051757813
					dphe_st <= compute_thresholds_1_2;
					
				when compute_thresholds_1_2 =>
					t_high_low_portion <= avg_low_sum * "1011001100110011";                        -- multiply by 0.699996948242188
					dphe_st <= compute_thresholds_1_3;
					
				when compute_thresholds_1_3 =>
					t_low_high_portion <= avg_high_sum * "0011001100110100";                       -- multiply by 0.200012207031250
					dphe_st <= compute_thresholds_1_4;
					
				when compute_thresholds_1_4 =>
					t_low_low_portion <= avg_low_sum * "1100110011001100";                         -- multiply by 0.799987792968750
					dphe_st <= compute_thresholds_2;
          
				when compute_thresholds_2 =>
					t_high_without_rounding <= t_high_high_portion + t_high_low_portion;
					t_low_without_rounding <= t_low_high_portion + t_low_low_portion;					
					dphe_st <= round;
          
				when round =>
					if t_high_without_rounding(15) = '1' then
						t_high <= resize(shift_right(t_high_without_rounding, 16), nbits_num_pixels_nroi) + 1;
					else 
						t_high <= resize(shift_right(t_high_without_rounding, 16), nbits_num_pixels_nroi);
					end if;
					if t_low_without_rounding(15) = '1' then
						t_low <= resize(shift_right(t_low_without_rounding, 16), nbits_num_pixels_nroi) + 1;
					else	
						t_low <= resize(shift_right(t_low_without_rounding, 16), nbits_num_pixels_nroi);
					end if;
					dphe_st <= decide_clipping_point;

				when decide_clipping_point =>
					if adaptive_clipping_mode = '0' then
						clip_pos_buff <= (others => '0');
						num_clipped <= (others => '0');
						dphe_st <= compute_original_clipping_position_1;
					elsif peak_count = 0 then	
						clip_pos_buff <= (others => '0');
						num_clipped <= (others => '0');
						dphe_st <= compute_original_clipping_position_1;
					elsif peak_count = 1 then	
						clip_pos_buff <= peak_start_points(0) - 1;
						num_clipped <= area_before_peak(0);
						dphe_st <= compute_original_clipping_position_1;
					elsif adaptive_clipping_mode = '1' then
					--	clip_num <= area_before_peak(1)*peak_start_points(1) + area_before_peak(0)*peak_start_points(0)
						clip_den <= resize((peak_area_count(1) + peak_area_count(0)), 36);
						num_clipped <= area_before_peak(1);
						dphe_st <= compute_multiplication_1;
					end if;

				--	if peak_count = 0 then	
				--		clip_pos_buff <= (others => '0');
				--		num_clipped <= (others => '0');
				--		dphe_st <= compute_original_clipping_position_1;
				--	elsif peak_count = 1 then	
				--		clip_pos_buff <= peak_start_points(0) - 1;
				--		num_clipped <= area_before_peak(0);
				--		dphe_st <= compute_original_clipping_position_1;
				--	elsif adaptive_clipping_mode = '1' then
				--	--	clip_num <= area_before_peak(1)*peak_start_points(1) + area_before_peak(0)*peak_start_points(0)
				--		clip_den <= resize(peak_area_count(1) + peak_area_count(0), 36);
				--		num_clipped <= area_before_peak(1);
				--		dphe_st <= compute_multiplication_1;

				--	--	dphe_st <= compute_division_start;
				--	elsif (peak_count >= 2) and (area_before_peak(1) <= dphe_peak_clip_threshold) then
				--		clip_pos_buff <= peak_start_points(1) - 1;
				--		num_clipped <= area_before_peak(1);
				--		dphe_st <= compute_original_clipping_position_1;
				--	else
				--		clip_pos_buff <= peak_start_points(0) - 1;
				--		num_clipped <= area_before_peak(0);
				--		dphe_st <= compute_original_clipping_position_1;
				--	end if;

        
				--when decide_clipping_point =>
				--	if peak_count = 0 then	
				--		clip_pos <= (others => '0');
				--		num_clipped <= (others => '0');
				--		dphe_st <= compute_original_clipping_position_1;
				--	elsif peak_count = 1 then	
				--		clip_pos <= peak_start_points(0) - 1;
				--		num_clipped <= area_before_peak(0);
				--		dphe_st <= compute_original_clipping_position_1;
				--	else 
				--	--	clip_num <= area_before_peak(1)*peak_start_points(1) + area_before_peak(0)*peak_start_points(0)
				--		clip_den <= resize(area_before_peak(1) + area_before_peak(0), 36);
				--		num_clipped <= area_before_peak(1);
				--		dphe_st <= compute_multiplication_1;

					--	dphe_st <= compute_division_start;
					--if (peak_count >= 2) and (area_before_peak(1) <= dphe_peak_clip_threshold) then
					--	clip_pos <= peak_start_points(1) - 1;
					--	num_clipped <= area_before_peak(1);
					--else
					--	clip_pos <= peak_start_points(0) - 1;
					--	num_clipped <= area_before_peak(0);
				--	end if;
					--dphe_st <= compute_original_clipping_position_1;

				when compute_multiplication_1 =>
					clip_num_1 <= resize(unsigned(peak_area_count(1)*peak_start_points(1)),36);
					dphe_st <= compute_multiplication_2;

				when compute_multiplication_2 =>
					clip_num_2 <= resize(unsigned(peak_area_count(0)*peak_start_points(0)),36);
					dphe_st <= compute_clip_num;

				when compute_clip_num =>
					clip_num <= clip_num_1 + clip_num_2;
					dphe_st <= compute_division_start;

				when compute_division_start =>
					dvnd_33 <= std_logic_vector(clip_num(dvnd_33'length-1 downto 0));
					dvsr_33 <= std_logic_vector(clip_den(dvsr_33'length-1 downto 0));
					start_33 <= '1';
					dphe_st <= compute_division_wait;

				when compute_division_wait =>
					if done_tick_33 = '1' then
						clip_pos_buff <=resize(unsigned(quo_33),bitdepth_inter);
						dphe_st <= compute_original_clipping_position_1;
					else 
						start_33 <= '0';
						dphe_st <= compute_division_wait;
					end if;
					
				
				--when decide_clipping_point =>
				--	if peak_count = 0 then	
				--		clip_pos <= (others => '0');
				--		num_clipped <= (others => '0');
				--	elsif peak_count = 1 then	
				--		clip_pos <= peak_start_points(0) - 1;
				--		num_clipped <= area_before_peak(0);
				--	elsif (peak_count >= 2) and (area_before_peak(1) <= dphe_peak_clip_threshold) then
				--		clip_pos <= peak_start_points(1) - 1;
				--		num_clipped <= area_before_peak(1);
				--	else
				--		clip_pos <= peak_start_points(0) - 1;
				--		num_clipped <= area_before_peak(0);
				--	end if;
				--	dphe_st <= compute_original_clipping_position_1;

				when compute_original_clipping_position_1 =>
					clip_pos <= resize(shift_right(clip_pos_buff,2),clip_pos'length);
					dphe_st <= compute_original_clipping_position_1_buff;
					
				when compute_original_clipping_position_1_buff =>
					clip_pos_mod <= clip_pos & "1";
					dphe_st <= compute_original_clipping_position_2;
					
				when compute_original_clipping_position_2 =>
					clip_mul <= resize(clip_pos_mod * bin_size_for_calc,clip_mul'length);
					dphe_st <= compute_original_clipping_position_3;
        
				when compute_original_clipping_position_3 =>
					orig_clip_pos <= resize(shift_right(clip_mul, 1), orig_clip_pos'length);
					dphe_st <= compute_original_clipping_position_4;
					
				when compute_original_clipping_position_4 =>
					orig_clip_pos <= orig_clip_pos + prev_start_index_for_calc;
					dphe_st <= fix_output_range;
		  
				when fix_output_range =>
					hist_span <= resize((prev_end_index_for_calc - orig_clip_pos + 1), bitdepth_in + 1);
					dphe_st <= calculate_brightness1;

				when calculate_brightness1 =>
					brightness <= unsigned('0' & prev_start_index(prev_start_index'length-1 downto 1)) + 
					               unsigned('0' & prev_end_index(prev_end_index'length-1 downto 1));
					dphe_st <= calculate_brightness2;

				when calculate_brightness2 =>
					brightness_inter <= brightness*gain_mult;
					dphe_st <= calculate_brightness2n;

				when calculate_brightness2n=>
					brightness <= resize(shift_right(brightness_inter, gain_mult'length-1), brightness'length);
					if(is_first_frame_flag <= 1) then
						--dphe_st <= calculate_brightness3_avg;
						dphe_st <= calculate_max_output_level_1;
					else
						dphe_st <= calculate_max_output_level_1;
					end if;

				when calculate_brightness3_avg =>
					if (brightness > prev_brightness) then
						diff_brightness <= brightness - prev_brightness;
					else
						diff_brightness <= prev_brightness - brightness; 
					end if;
					dphe_st <= calculate_brightness4_avg;

				when calculate_brightness4_avg =>
					mul_brightness <= diff_brightness* history2_by100;
					dphe_st <= calculate_brightness5_avg;

				when calculate_brightness5_avg =>
					if(brightness < prev_brightness) then
						mul_brightness <= mul_brightness - resize(diff_brightness, mul_brightness'length);
					end if;
					dphe_st <= calculate_brightness6_avg;

				when calculate_brightness6_avg =>
					if(brightness > prev_brightness) then
						brightness <= (resize(shift_right((prev_brightness & "00000000000000000")+mul_brightness, 17), brightness'length));
					else
						brightness <= (resize(shift_right((prev_brightness & "00000000000000000")-mul_brightness, 17), brightness'length));
					end if;
					dphe_st <= calculate_max_output_level_1;
				
				when calculate_max_output_level_1 =>
					dvnd_33 <= std_logic_vector(resize((hist_span & "00000000"), d1'length));
					dvsr_33 <= std_logic_vector(resize(dphe_range_threshold, d1'length));
					start_33 <= '1';
					half_dphe_range_threshold <= shift_right(dphe_range_threshold,1);
					dphe_st <= calculate_max_output_level_2;
										
				when calculate_max_output_level_2 =>
					if done_tick_33 = '1' then
						if unsigned(rmd_33) >= half_dphe_range_threshold then
							max_output_level_with_rounding <= unsigned(quo_33) - 22 + 1;
						else 
							max_output_level_with_rounding <= unsigned(quo_33) -22 ;
						end if;
						dphe_st <= decide_max_output_level;
					else 
						start_33 <= '0';
						dphe_st <= calculate_max_output_level_2;
					end if;
			
				when decide_max_output_level =>
					if max_output_level_with_rounding >= num_out_levels then
						max_output_level <= to_unsigned((num_out_levels-1), bitdepth_out);
					else
						max_output_level <= resize(max_output_level_with_rounding-1, bitdepth_out);
					end if;
					dphe_st <= decide_intensity_shift;

				when decide_intensity_shift =>
					intensity_shift <= shift_right(to_unsigned((num_out_levels-1), bitdepth_out) - max_output_level, 1);
					if is_first_frame_flag <= 1 then
						dphe_st <= averaging_1;
					else 
						dphe_st <= update;
					end if;
					
				when averaging_1 =>
					if orig_clip_pos > prev_clip_pos then
						diff_clip_pos <= orig_clip_pos - prev_clip_pos;
					else
						diff_clip_pos <= prev_clip_pos - orig_clip_pos;
					end if;
					if max_output_level > prev_max_output_level then
						diff_max_output_level <= max_output_level - prev_max_output_level;
					else
						diff_max_output_level <= prev_max_output_level - max_output_level;
					end if;
					if t_high > prev_t_high then
						diff_t_high <= t_high - prev_t_high;
					else	
						diff_t_high <= prev_t_high - t_high;
					end if;
					if t_low > prev_t_low then
						diff_t_low <= t_low - prev_t_low;
					else	
						diff_t_low <= prev_t_low - t_low;
					end if;
					if intensity_shift > prev_intensity_shift then
						diff_intensity_shift <= intensity_shift - prev_intensity_shift;
					else
						diff_intensity_shift <= prev_intensity_shift - intensity_shift;
					end if;
					dphe_st <= averaging_2_mul1;
					
				when averaging_2_mul1 =>
					mul_orig_clip_pos <= diff_clip_pos * history2_by100;                           -- multiply by 0.100006103515625
					dphe_st <= averaging_2_mul2;
				
				when averaging_2_mul2 =>
					mul_max_output_level <= diff_max_output_level * history2_by100;                -- multiply by 0.100006103515625
					mul_intensity_shift <= diff_intensity_shift * history2_by100;
					dphe_st <= averaging_2_mul3;
					
				when averaging_2_mul3 =>
					mul_t_high <= diff_t_high * history2_by100;                                    -- multiply by 0.100006103515625
					dphe_st <=  averaging_2_mul4;
					
				when averaging_2_mul4 =>
					mul_t_low <= diff_t_low * history2_by100;                                      -- multiply by 0.100006103515625
					dphe_st <= averaging_2_end;
					
				when averaging_2_end =>
					if orig_clip_pos < prev_clip_pos then
						mul_orig_clip_pos <= mul_orig_clip_pos - resize(diff_clip_pos, mul_orig_clip_pos'length);
					end if;
					if max_output_level < prev_max_output_level then
						mul_max_output_level <= mul_max_output_level - resize(diff_max_output_level, mul_max_output_level'length);
					end if;
					if t_high < prev_t_high then
						mul_t_high <= mul_t_high - resize(diff_t_high, mul_t_high'length);
					end if;
					if t_low < prev_t_low then
						mul_t_low <= mul_t_low - resize(diff_t_low, mul_t_low'length);
					end if;
					if intensity_shift < prev_intensity_shift then
						mul_intensity_shift <= mul_intensity_shift - resize(diff_intensity_shift, mul_intensity_shift'length);
					end if;
					dphe_st <= averaging_3;

				when averaging_3 =>
					if orig_clip_pos > prev_clip_pos then
						orig_clip_pos <= resize(shift_right(((prev_clip_pos & "00000000000000000") + mul_orig_clip_pos), 17), orig_clip_pos'length);
					else
						orig_clip_pos <= resize(shift_right(((prev_clip_pos & "00000000000000000") - mul_orig_clip_pos), 17), orig_clip_pos'length);
					end if;
					if max_output_level > prev_max_output_level then
						max_output_level <= resize(shift_right(((prev_max_output_level & "00000000000000000") + mul_max_output_level), 17), bitdepth_out);
					else
						max_output_level <= resize(shift_right(((prev_max_output_level & "00000000000000000") - mul_max_output_level), 17), bitdepth_out);
					end if;
					if t_high > prev_t_high then
						t_high <= resize(shift_right(((prev_t_high & "00000000000000000") + mul_t_high), 17), t_high'length);
					else
						t_high <= resize(shift_right(((prev_t_high & "00000000000000000") - mul_t_high), 17), t_high'length);
					end if;
					if t_low > prev_t_low then
						t_low <= resize(shift_right(((prev_t_low & "00000000000000000") + mul_t_low), 17), t_low'length);
					else
						t_low <= resize(shift_right(((prev_t_low & "00000000000000000") - mul_t_low), 17), t_low'length);
					end if;
					if intensity_shift > prev_intensity_shift then
						intensity_shift <= resize(shift_right(((prev_intensity_shift & "00000000000000000") + mul_intensity_shift), 17), intensity_shift'length);
					else
						intensity_shift <= resize(shift_right(((prev_intensity_shift & "00000000000000000") - mul_intensity_shift), 17), intensity_shift'length);
					end if;
					dphe_st <= new_clip_1;
      
				when new_clip_1 =>
					num_clipped <= (others => '0');
					count2 <= (others => '0');
					if orig_clip_pos > prev_start_index_for_calc then
						dvnd_18 <= std_logic_vector(resize((orig_clip_pos - prev_start_index_for_calc), nbits_num_pixels_nroi+1));
						dvsr_18 <= std_logic_vector(bin_size_for_calc);
						start_18 <= '1';
						dphe_st <= new_clip_2;
					else 
						clip_pos <= (others => '0');
						dphe_st <= calculate_num_clipped;
					end if;
			 
				when new_clip_2 =>
					if done_tick_18 = '1' then
						if unsigned(rmd_18) = 0 then
							clip_pos <= resize(shift_right((unsigned(quo_18)),2), bitdepth_inter);
						else
							clip_pos <= resize(shift_right((unsigned(quo_18)),2), bitdepth_inter) + 1;
						end if;
						dphe_st <= calculate_num_clipped;
					else
						start_18 <= '0';
						dphe_st <= new_clip_2;
					end if;	
        
				when calculate_num_clipped =>
					if count2 <= clip_pos then
						if rd_mem_no = '0' then
							rd2_1b <= '1';
							add2_1b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						else
							rd2_2b <= '1';
							add2_2b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						end if;
						dphe_st <= rd_inter_hist_clip;
					else 
						count2 <= (others => '0');
						count3 <= (others => '0');
						dphe_st <= update;
					end if;
        
				when rd_inter_hist_clip =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					dphe_st <= update_num_clipped;
          
				when update_num_clipped =>
					if rd_mem_no = '0' then
						num_clipped <= num_clipped + unsigned(dout2_1b);
					else
						num_clipped <= num_clipped + unsigned(dout2_2b);
					end if;
					count2 <= count2 + 1;
					dphe_st <= calculate_num_clipped;
          
				when update =>
					inv_bin_size <= new_inv_bin_size;
					prev_start_index_for_calc <= start_index;
					prev_end_index_for_calc <= end_index;
					prev_bin_size <= bin_size_for_calc;
					prev_inv_bin_size <= inv_bin_size_for_calc;
					prev_clip_pos <= orig_clip_pos;
					prev_max_output_level <= max_output_level;
					prev_t_high <= t_high;
					prev_t_low <= t_low;
					rem_pixel_count <= num_pixels - num_clipped;
					old_dump <= (others => '0');
					new_dump <= (others => '0');
					changed <= '0';
					count2 <= (others => '0');
					prev_brightness <= brightness;
					prev_gain_mult <= gain_mult;
					prev_intensity_shift <= intensity_shift;
					--effective_t_high <= t_high;
					--effective_t_low <= t_low;
					if enhance_low_contrast = '1' then
						effective_t_high <= shift_left(t_high, 1);
						effective_t_low <= shift_left(t_low, 1);
					else
						effective_t_high <= shift_right(t_high, 1);
						effective_t_low <= shift_right(t_low, 1);
					end if;
					effective_low_lim <= resize(shift_right((t_low * "0011001100110100"), 16), effective_low_lim'length);
					-- if t_high(0) = '1' then
					-- 	effective_t_high <= shift_right(t_high, 1) + 1;
					-- else	
					-- 	effective_t_high <= shift_right(t_high,1);
					-- end if;
					-- if t_low(0) = '1' then
					-- 	effective_t_low <= shift_right(t_low, 1) + 1;
					-- else	
					-- 	effective_t_low <= shift_right(t_low,1);
					-- end if;
					-- if t_low(0) = '1' then
					-- 	effective_low_lim <= resize(shift_right(((("0" & t_low(nbits_num_pixels_nroi-1 downto 1)) + 1) * "0011001100110100"), 16), effective_low_lim'length);       -- multiply by 0.200012207031250
					-- else
					-- 	effective_low_lim <= resize(shift_right((("0" & t_low(nbits_num_pixels_nroi-1 downto 1)) * "0011001100110100"), 16), effective_low_lim'length);             -- multiply by 0.200012207031250
					-- end if;
					if peak_count >= 1 then
						sum_start_end <= resize(peak_start_points(0), bitdepth_inter+1) + resize(peak_end_points(0), bitdepth_inter+1);
					else
						inflection_point <= clip_pos;
					end if;
					dphe_st <= update2;
					
				when update2 =>
					if peak_count >= 1 then
						inflection_point <= resize((shift_right(sum_start_end, 1)), bitdepth_inter);
					end if;
					dphe_st <= generate_cdf;
				
				when generate_cdf =>
					we3a <= '0';
					if count2 < num_inter_levels then
						if rd_mem_no = '0' then
							rd2_1b <= '1';
							add2_1b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						else
							rd2_2b <= '1';
							add2_2b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						end if;
						dphe_st <= rd_inter_hist_cdf;
					else
						count2 <= (others => '0');
						dphe_st <= update_lut;
					end if;
        
				when rd_inter_hist_cdf =>
					if rd_mem_no = '0' then
						rd2_1b <= '0';
					else
						rd2_2b <= '0';
					end if;
					dphe_st <= update_old_dump;
        
				when update_old_dump =>
					if count2 > clip_pos then
						if rd_mem_no = '0' then
							old_dump <= old_dump + unsigned(dout2_1b);
							cdf_val <= unsigned(dout2_1b);
						else	
							old_dump <= old_dump + unsigned(dout2_2b);
							cdf_val <= unsigned(dout2_2b);
						end if;
					end if;
					if count2 <= clip_pos then
						count2 <= count2 + 1;
						we3a <= '1';
						add3a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						din3a <= (others => '0');
						dphe_st <= generate_cdf;
					else 
						dphe_st <= decide_threshold;
					end if;
					
				when decide_threshold =>
					if (old_dump >= shift_right(rem_pixel_count, 1)) and (changed = '0') then
						if enhance_low_contrast = '1' then
							effective_t_high <= shift_right(effective_t_high, 1);
							effective_t_low <= shift_right(effective_t_low, 1);
						else
							effective_t_high <= shift_left(effective_t_high, 1);
							effective_t_low <= shift_left(effective_t_low, 1);
						end if;
						effective_low_lim <= resize(shift_right(((effective_t_low(nbits_num_pixels_nroi-2 downto 0) & "0") * "0011001100110100"), 16), effective_low_lim'length);          -- multiply by 0.200012207031250
						changed <= '1';
					end if;
					dphe_st <= apply_threshold;
          
				when apply_threshold =>
					if cdf_val > effective_t_high then
						effective_count <= effective_t_high;
					elsif (cdf_val < effective_t_low) and (cdf_val > effective_low_lim) and (count2(bitdepth_inter-1 downto 0) >= inflection_point) then
						effective_count <= effective_t_low;
					--elsif (cdf_val < effective_t_low) and (count2(bitdepth_inter-1 downto 0) < inflection_point) then
					--	effective_count <= shift_right(effective_t_low,2);
					else
						effective_count <= cdf_val;
					end if;
					dphe_st <= update_new_dump;
          		
          		when update_new_dump_1 =>
          			--if adaptive_clipping_mode = '1' then
          			--	effective_count_2 <= resize(effective_count_1*115 + 26000,effective_count_2'length);
          			--else 
          				effective_count_2 <= effective_count_1;
          			--end if;
          			dphe_st <= update_new_dump_2;

          		when update_new_dump_2 =>
          			--if adaptive_clipping_mode = '1' then
          			--	effective_count <= resize(shift_right(effective_count_2,7),effective_count'length);
          			--else
						effective_count <= resize(effective_count_2,effective_count'length);
					--end if;
          			dphe_st <= update_new_dump;

				when update_new_dump =>
					new_dump <= new_dump + resize(effective_count, new_dump'length);
					dphe_st <= write_cdf;
          
				when write_cdf =>
					we3a <= '1';
					din3a <= std_logic_vector(new_dump);
					add3a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
					count2 <= count2 + 1;
					dphe_st <= generate_cdf;
          
				when update_lut => 
					we3a <= '0';
					we4_1a <= '0';
					we4_2a <= '0';
					if count2 < num_inter_levels then
						rd3b <= '1';
						add3b <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						dphe_st <= read_cdf;
					else
						count2 <= (others => '0');
						dphe_st <= rest;
					end if;
          
				when read_cdf =>
					rd3b <= '0';
					dphe_st <= compute_lut_val_1;
					
				when compute_lut_val_1 =>
					d1 <= unsigned(dout3b) * max_output_level;
					dphe_st <= compute_lut_val_2;
          
				when compute_lut_val_2 =>
					dvnd_33 <= std_logic_vector(d1);
					dvsr_33 <= std_logic_vector(resize(new_dump, d1'length));
					start_33 <= '1';
					dphe_st <= compute_lut_val_3;
					
				when compute_lut_val_3 =>
					if done_tick_33 = '1' then
						d2 <= resize(unsigned(quo_33), d2'length);
						dphe_st <= compute_lut_val_4;
					else 
						start_33 <= '0';
						dphe_st <= compute_lut_val_3;
					end if;
					
				when compute_lut_val_4 =>
					if is_first_frame_flag = 2 then
						din4_1a <= std_logic_vector(resize(d2,bitdepth_out));
						we4_1a <= '1';
						add4_1a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
					elsif is_first_frame_flag = 1 then
						din4_2a <= std_logic_vector(resize(d2,bitdepth_out));
						we4_2a <= '1';
						add4_2a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
					elsif is_first_frame_flag = 0 then
						if wr_lut_prev_no = '0' then
							din4_1a <= std_logic_vector(resize(d2,bitdepth_out));
							we4_1a <= '1';
							add4_1a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						else
							din4_2a <= std_logic_vector(resize(d2,bitdepth_out));
							we4_2a <= '1';
							add4_2a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
						end if;
					end if;
					din3a <= std_logic_vector(d2);
					we3a <= '1';
					add3a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));		
					count2 <= count2 + 1;
					dphe_st <= update_lut;
          
				when rest =>
					--if count2 < num_inter_levels then
					if count2 < num_in_levels then
						count2 <= count2 + 1;
						if rd_mem_no = '0' then
							we1_1a <= '1';
							add1_1a <= std_logic_vector(count2(bitdepth_in-1 downto 0));
							din1_1a <= (others => '0');
						else
							we1_2a <= '1';
							add1_2a <= std_logic_vector(count2(bitdepth_in-1 downto 0));
							din1_2a <= (others => '0');
						end if;
						if count2 < num_inter_levels then
							if rd_mem_no = '0' then
								we2_1a <= '1';
								add2_1a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
								din2_1a <= (others => '0');
							else
								we2_2a <= '1';
								add2_2a <= std_logic_vector(count2(bitdepth_inter-1 downto 0));
								din2_2a <= (others => '0');
							end if;
							dphe_st <= rest;
						end if;
					else
						count2 <= (others => '0');
						if rd_mem_no = '0' then
							we1_1a <= '0';
						else
							we1_2a <= '0';
						end if;
						if rd_mem_no = '0' then
							we2_1a <= '0';
						else
							we2_2a <= '0';
						end if;
						dphe_st <= rewind;
					end if;
					
				when rewind =>
					bin_size_for_calc <= new_bin_size;
					inv_bin_size_for_calc <= new_inv_bin_size;
					dump1 <= (others => '0');
					window_sum <= (others => '0');
					total_sum <= (others => '0');
					low_sum <= (others => '0');
					old_dump <= (others => '0');
					new_dump <= (others => '0');
					peak_count <= (others => '0');
					non_zero_levels <= (others => '0');
					non_zero_lowliers <= (others => '0');
					peak_start_points <= (others => (others => '0'));
					peak_end_points <= (others => (others => '0'));
					area_before_peak <= (others => (others => '0'));
					peak_area_count <= (others => (others => '0'));
					peak_area <= (others => '0');
					peak_width <= (others => '0');
					peak_found <= '0';
					changed <= '0';
					if is_first_frame_flag = 2 then
						wr_lut_prev_no <= '1';
					elsif is_first_frame_flag <= 1 then
						if wr_lut_prev_no = '0' then
							wr_lut_prev_no <= '1';
						else
							wr_lut_prev_no <= '0';
						end if;
					end if;
					if is_first_frame_flag >= 1 then
						is_first_frame_flag <= is_first_frame_flag - 1;
					end if;
					is_prev_calc_done <= '1';
					if (rd_mem_no = '0') then
						rd_mem_no <= '1';
					else
						rd_mem_no <= '0';
					end if;							
					dphe_st <= idle;
					
				when others =>
					null;
			end case;
		end if;
	end process;
	
	
	
	video_o_data <= pixel_out;
	video_o_dav <= pixel_vld_out;
	video_o_xcnt <= std_logic_vector(video_xcnt);
	video_o_ycnt <= std_logic_vector(video_ycnt);
	video_o_eoi <= video_eoi(4);	
	video_o_h <= video_h(8);
	video_o_v <= video_v(8);
	video_o_xsize <= video_i_xsize;
	video_o_ysize <= video_i_ysize;

--inst_shifted_histogram_1:entity WORK.DPRAM_GENERIC_DC
---------------------------------
--  Generic map(
--    ADDR_WIDTH  =>     bitdepth_in,       -- RAM Address Width
--    DATA_WIDTH  =>     nbits_num_pixels_nroi,     -- RAM Data Width
--    RAM_STYLE   =>     "block",               -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
--    BYPASS_RW   =>     true,                 -- Returned Write Data when Read and Write at same address
--    SIMPLE_DP   =>     false,                -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
--    SINGLE_CLK  =>     true,                 -- Advertise that A_CLK = B_CLK
--    OUTPUT_REG  =>     false                 -- Output Registered if True
--  )
--  Port map(
--    A_CLK       => CLK,
--    A_ADDR      => add1_1a,
--    A_WRREQ     => we1_1a,
--    A_WRDATA    => din1_1a,
--    A_RDREQ     => open,
--    A_RDDATA    => open,
--    B_CLK       => CLK,
--    B_ADDR      => add1_1b,
--    B_WRREQ     => open,
--    B_WRDATA    => open,
--    B_RDREQ     => rd1_1b,
--    B_RDDATA    => dout1_1b
--  );
 
  inst_shifted_histogram_1 : xpm_memory_sdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (nbits_num_pixels_nroi)*(2**bitdepth_in),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (nbits_num_pixels_nroi ),              --positive integer
    BYTE_WRITE_WIDTH_A      => (nbits_num_pixels_nroi ),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_in,               --positive integer

    -- Port B module generics
    READ_DATA_WIDTH_B       => (nbits_num_pixels_nroi ),              --positive integer
    ADDR_WIDTH_B            => bitdepth_in,               --positive integer
    READ_RESET_VALUE_B      => "0",            --string
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	    -- Common module ports
    sleep                   => '0',

    -- Port A module ports
    clka                    => CLK,
    ena                     => '1',
    wea(0)                     => we1_1a,
    addra                   => add1_1a,
    dina                    => din1_1a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    addrb                   => add1_1b,
    doutb                   => dout1_1b,
    sbiterrb                => open,
    dbiterrb                => open
  );
 
--inst_shifted_histogram_2:entity WORK.DPRAM_GENERIC_DC
---------------------------------
--  Generic map(
--    ADDR_WIDTH  =>     bitdepth_in,        -- RAM Address Width
--    DATA_WIDTH  =>     nbits_num_pixels_nroi,      -- RAM Data Width
--    RAM_STYLE   =>     "block",                -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
--    BYPASS_RW   =>     true,                  -- Returned Write Data when Read and Write at same address
--    SIMPLE_DP   =>     false,                 -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
--    SINGLE_CLK  =>     true,                  -- Advertise that A_CLK = B_CLK
--    OUTPUT_REG  =>     false                  -- Output Registered if True
--  )
--  Port map(
--    A_CLK       => CLK,
--    A_ADDR      => add1_2a,
--    A_WRREQ     => we1_2a,
--    A_WRDATA    => din1_2a,
--    A_RDREQ     => open,
--    A_RDDATA    => open,
--    B_CLK       => CLK,
--    B_ADDR      => add1_2b,
--    B_WRREQ     => open,
--    B_WRDATA    => open,
--    B_RDREQ     => rd1_2b,
--    B_RDDATA    => dout1_2b
--  );

 inst_shifted_histogram_2 : xpm_memory_sdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (nbits_num_pixels_nroi)*(2**bitdepth_in),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (nbits_num_pixels_nroi ),              --positive integer
    BYTE_WRITE_WIDTH_A      => (nbits_num_pixels_nroi ),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_in,               --positive integer

    -- Port B module generics
    READ_DATA_WIDTH_B       => (nbits_num_pixels_nroi ),              --positive integer
    ADDR_WIDTH_B            => bitdepth_in,               --positive integer
    READ_RESET_VALUE_B      => "0",            --string
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	    -- Common module ports
    sleep                   => '0',

    -- Port A module ports
    clka                    => CLK,
    ena                     => '1',
    wea(0)                     => we1_2a,
    addra                   => add1_2a,
    dina                    => din1_2a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    addrb                   => add1_2b,
    doutb                   => dout1_2b,
    sbiterrb                => open,
    dbiterrb                => open
  );
 
--inst_intermediate_histogram_1:entity WORK.DPRAM_GENERIC_DC
---------------------------------
--  Generic map(
--    ADDR_WIDTH  =>     bitdepth_inter,         -- RAM Address Width
--    DATA_WIDTH  =>     nbits_num_pixels_nroi,       -- RAM Data Width
--    RAM_STYLE   =>     "block",                 -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
--    BYPASS_RW   =>     true,                   -- Returned Write Data when Read and Write at same address
--    SIMPLE_DP   =>     false,                  -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
--    SINGLE_CLK  =>     true,                   -- Advertise that A_CLK = B_CLK
--    OUTPUT_REG  =>     false                   -- Output Registered if True
--  )
--  Port map(
--    A_CLK       => CLK,
--    A_ADDR      => add2_1a,
--    A_WRREQ     => we2_1a,
--    A_WRDATA    => din2_1a,
--    A_RDREQ     => open,
--    A_RDDATA    => open,
--    B_CLK       => CLK,
--    B_ADDR      => add2_1b,
--    B_WRREQ     => open,
--    B_WRDATA    => open,
--    B_RDREQ     => rd2_1b,
--    B_RDDATA    => dout2_1b
--  );	

  inst_intermediate_histogram_1 : xpm_memory_sdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (nbits_num_pixels_nroi)*(2**bitdepth_inter),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (nbits_num_pixels_nroi ),              --positive integer
    BYTE_WRITE_WIDTH_A      => (nbits_num_pixels_nroi ),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_inter,               --positive integer

    -- Port B module generics
    READ_DATA_WIDTH_B       => (nbits_num_pixels_nroi ),              --positive integer
    ADDR_WIDTH_B            => bitdepth_inter,               --positive integer
    READ_RESET_VALUE_B      => "0",            --string
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	    -- Common module ports
    sleep                   => '0',

    -- Port A module ports
    clka                    => CLK,
    ena                     => '1',
    wea(0)                     => we2_1a,
    addra                   => add2_1a,
    dina                    => din2_1a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    addrb                   => add2_1b,
    doutb                   => dout2_1b,
    sbiterrb                => open,
    dbiterrb                => open
  );
    	
--inst_intermediate_histogram_2:entity WORK.DPRAM_GENERIC_DC
---------------------------------
--  Generic map(
--    ADDR_WIDTH  =>     bitdepth_inter,         -- RAM Address Width
--    DATA_WIDTH  =>     nbits_num_pixels_nroi,       -- RAM Data Width
--    RAM_STYLE   =>     "block",                 -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
--    BYPASS_RW   =>     true,                   -- Returned Write Data when Read and Write at same address
--    SIMPLE_DP   =>     false,                  -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
--    SINGLE_CLK  =>     true,                   -- Advertise that A_CLK = B_CLK
--    OUTPUT_REG  =>     false                   -- Output Registered if True
--  )
--  Port map(
--    A_CLK       => CLK,
--    A_ADDR      => add2_2a,
--    A_WRREQ     => we2_2a,
--    A_WRDATA    => din2_2a,
--    A_RDREQ     => open,
--    A_RDDATA    => open,
--    B_CLK       => CLK,
--    B_ADDR      => add2_2b,
--    B_WRREQ     => open,
--    B_WRDATA    => open,
--    B_RDREQ     => rd2_2b,
--    B_RDDATA    => dout2_2b
--  );

inst_intermediate_histogram_2 : xpm_memory_sdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (nbits_num_pixels_nroi)*(2**bitdepth_inter),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (nbits_num_pixels_nroi ),              --positive integer
    BYTE_WRITE_WIDTH_A      => (nbits_num_pixels_nroi ),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_inter,               --positive integer

    -- Port B module generics
    READ_DATA_WIDTH_B       => (nbits_num_pixels_nroi ),              --positive integer
    ADDR_WIDTH_B            => bitdepth_inter,               --positive integer
    READ_RESET_VALUE_B      => "0",            --string
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	    -- Common module ports
    sleep                   => '0',

    -- Port A module ports
    clka                    => CLK,
    ena                     => '1',
    wea(0)                     => we2_2a,
    addra                   => add2_2a,
    dina                    => din2_2a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    addrb                   => add2_2b,
    doutb                   => dout2_2b,
    sbiterrb                => open,
    dbiterrb                => open
  );

--inst_cdf_look_up_table:entity WORK.DPRAM_GENERIC_DC
--  -------------------------------
--    Generic map(
--      ADDR_WIDTH  =>     bitdepth_inter,                             -- RAM Address Width
--      DATA_WIDTH  =>     (nbits_num_pixels + bitdepth_inter + 1),    -- RAM Data Width
--      RAM_STYLE   =>     "block",                                     -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
--      BYPASS_RW   =>     true,                                       -- Returned Write Data when Read and Write at same address
--      SIMPLE_DP   =>     false,                                      -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
--      SINGLE_CLK  =>     true,                                       -- Advertise that A_CLK = B_CLK
--      OUTPUT_REG  =>     false                                       -- Output Registered if True
--    )
--    Port map(
--      A_CLK       => CLK,
--      A_ADDR      => add3a,
--      A_WRREQ     => we3a,
--      A_WRDATA    => din3a,
--      A_RDREQ     => rd3a,
--      A_RDDATA    => dout3a,
--      B_CLK       => CLK,
--      B_ADDR      => add3b,
--      B_WRREQ     => we3b,
--      B_WRDATA    => din3b,
--      B_RDREQ     => rd3b,
--      B_RDDATA    => dout3b
--    );

inst_cdf_look_up_table : xpm_memory_tdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (nbits_num_pixels_nroi + bitdepth_inter + 1)*(2**bitdepth_inter),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --positive integer
    READ_DATA_WIDTH_A       => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --positive integer
    BYTE_WRITE_WIDTH_A      => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_inter,               --positive integer
    READ_LATENCY_A          => 1,               --non-negative integer
    WRITE_MODE_A            => "read_first",     --string; "write_first", "read_first", "no_change" 

    -- Port B module generics
    WRITE_DATA_WIDTH_B      => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --positive integer
    READ_DATA_WIDTH_B       => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --positive integer
    BYTE_WRITE_WIDTH_B      => (nbits_num_pixels_nroi + bitdepth_inter + 1),              --integer; 8, 9, or WRITE_DATA_WIDTH_B value
    ADDR_WIDTH_B            => bitdepth_inter,               --positive integer
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	sleep 					=> '0',

    -- Port A module ports
    clka                    => CLK,
    rsta                    => RST,
    ena                     => '1',
    regcea                  => '1',
    wea(0)                     => we3a,
    addra                   => add3a,
    dina                    => din3a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',
    douta                   => dout3a,
    

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    web(0)                     => we3b,
    addrb                   => add3b,
    dinb                    => din3b,
    injectsbiterrb          => '0',
    injectdbiterrb          => '0',
    doutb                   => dout3b
  );
  
  --lut_memory_prev_prev_1:entity WORK.DPRAM_GENERIC_DC
  ---------------------------------
  --  Generic map(
  --    ADDR_WIDTH  =>     bitdepth_inter,        -- RAM Address Width
  --    DATA_WIDTH  =>     bitdepth_inter,        -- RAM Data Width
  --    RAM_STYLE   =>     "block",                -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
  --    BYPASS_RW   =>     true,                  -- Returned Write Data when Read and Write at same address
  --    SIMPLE_DP   =>     false,                 -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
  --    SINGLE_CLK  =>     true,                  -- Advertise that A_CLK = B_CLK
  --    OUTPUT_REG  =>     false                  -- Output Registered if True
  --  )
  --  Port map(
  --    A_CLK       => CLK,
  --    A_ADDR      => add4_1a,
  --    A_WRREQ     => we4_1a,
  --    A_WRDATA    => din4_1a,
  --    A_RDREQ     => rd4_1a,
  --    A_RDDATA    => dout4_1a,
  --    B_CLK       => CLK,
  --    B_ADDR      => add4_1b,
  --    B_WRREQ     => we4_1b,
  --    B_WRDATA    => din4_1b,
  --    B_RDREQ     => rd4_1b,
  --    B_RDDATA    => dout4_1b
  --  );

  lut_memory_prev_prev_1 : xpm_memory_tdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (bitdepth_inter)*(2**bitdepth_inter),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (bitdepth_inter),              --positive integer
    READ_DATA_WIDTH_A       => (bitdepth_inter),              --positive integer
    BYTE_WRITE_WIDTH_A      => (bitdepth_inter),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_inter,               --positive integer
    READ_LATENCY_A          => 1,               --non-negative integer
    WRITE_MODE_A            => "read_first",     --string; "write_first", "read_first", "no_change" 

    -- Port B module generics
    WRITE_DATA_WIDTH_B      => (bitdepth_inter),              --positive integer
    READ_DATA_WIDTH_B       => (bitdepth_inter),              --positive integer
    BYTE_WRITE_WIDTH_B      => (bitdepth_inter),              --integer; 8, 9, or WRITE_DATA_WIDTH_B value
    ADDR_WIDTH_B            => bitdepth_inter,               --positive integer
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	sleep 					=> '0',

    -- Port A module ports
    clka                    => CLK,
    rsta                    => RST,
    ena                     => '1',
    regcea                  => '1',
    wea(0)                     => we4_1a,
    addra                   => add4_1a,
    dina                    => din4_1a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',
    douta                   => dout4_1a,
    

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    web(0)                     => we4_1b,
    addrb                   => add4_1b,
    dinb                    => din4_1b,
    injectsbiterrb          => '0',
    injectdbiterrb          => '0',
    doutb                   => dout4_1b
  );    
    
  --lut_memory_prev_prev_2:entity WORK.DPRAM_GENERIC_DC
  ---------------------------------
  --  Generic map(
  --    ADDR_WIDTH  =>     bitdepth_inter,        -- RAM Address Width
  --    DATA_WIDTH  =>     bitdepth_inter,        -- RAM Data Width
  --    RAM_STYLE   =>     "block",                -- Lattice: "auto" "distributed" "block_ram" "registers" | Altera: "M512", "M4K", "M9K", "M20K", "M144K", "MLAB", or "M-RAM" | can append a ", no_rw_check"
  --    BYPASS_RW   =>     true,                  -- Returned Write Data when Read and Write at same address
  --    SIMPLE_DP   =>     false,                 -- When set, it enables only the A_write port & B_read port, optimize on Lattice devices
  --    SINGLE_CLK  =>     true,                  -- Advertise that A_CLK = B_CLK
  --    OUTPUT_REG  =>     false                  -- Output Registered if True
  --  )
  --  Port map(
  --    A_CLK       => CLK,
  --    A_ADDR      => add4_2a,
  --    A_WRREQ     => we4_2a,
  --    A_WRDATA    => din4_2a,
  --    A_RDREQ     => rd4_2a,
  --    A_RDDATA    => dout4_2a,
  --    B_CLK       => CLK,
  --    B_ADDR      => add4_2b,
  --    B_WRREQ     => we4_2b,
  --    B_WRDATA    => din4_2b,
  --    B_RDREQ     => rd4_2b,
  --    B_RDDATA    => dout4_2b
  --  );

  lut_memory_prev_prev_2 : xpm_memory_tdpram
generic map (

    -- Common module generics
    MEMORY_SIZE             => (bitdepth_inter)*(2**bitdepth_inter),            --positive integer
    MEMORY_PRIMITIVE        => "block",          --string; "auto", "distributed", "block" or "ultra" ;
    CLOCKING_MODE           => "common_clock",  --string; "common_clock", "independent_clock" 

    -- Port A module generics
    WRITE_DATA_WIDTH_A      => (bitdepth_inter),              --positive integer
    READ_DATA_WIDTH_A       => (bitdepth_inter),              --positive integer
    BYTE_WRITE_WIDTH_A      => (bitdepth_inter),              --integer; 8, 9, or WRITE_DATA_WIDTH_A value
    ADDR_WIDTH_A            => bitdepth_inter,               --positive integer
    READ_LATENCY_A          => 1,               --non-negative integer
    WRITE_MODE_A            => "read_first",     --string; "write_first", "read_first", "no_change" 

    -- Port B module generics
    WRITE_DATA_WIDTH_B      => (bitdepth_inter),              --positive integer
    READ_DATA_WIDTH_B       => (bitdepth_inter),              --positive integer
    BYTE_WRITE_WIDTH_B      => (bitdepth_inter),              --integer; 8, 9, or WRITE_DATA_WIDTH_B value
    ADDR_WIDTH_B            => bitdepth_inter,               --positive integer
    READ_LATENCY_B          => 1,               --non-negative integer
    WRITE_MODE_B            => "read_first"      --string; "write_first", "read_first", "no_change" 
  )
  port map (

  	sleep 					=> '0',

    -- Port A module ports
    clka                    => CLK,
    rsta                    => RST,
    ena                     => '1',
    regcea                  => '1',
    wea(0)                     => we4_2a,
    addra                   => add4_2a,
    dina                    => din4_2a,
    injectsbiterra          => '0',
    injectdbiterra          => '0',
    douta                   => dout4_2a,
    

    -- Port B module ports
    clkb                    => CLK,
    rstb                    => RST,
    enb                     => '1',
    regceb                  => '1',
    web(0)                     => we4_2b,
    addrb                   => add4_2b,
    dinb                    => din4_2b,
    injectsbiterrb          => '0',
    injectdbiterrb          => '0',
    doutb                   => dout4_2b
  );      
		
inst_div_18:entity WORK.div
	generic map (
		W => (nbits_num_pixels_nroi + 1),
		CBIT => 5
		)
	port map (
		clk => CLK,
		reset => RST,
		start => start_18,
		dvsr => dvsr_18,
		dvnd => dvnd_18,
		done_tick => done_tick_18,
		quo => quo_18,
		rmd => rmd_18
		);
		
		
inst_div_33:entity WORK.div
	generic map (
		W => (nbits_num_pixels_nroi + 2*bitdepth_inter +  1),
		CBIT => 6
		)
	port map (
		clk => CLK,
		reset => RST,
		start => start_33,
		dvsr => dvsr_33,
		dvnd => dvnd_33,
		done_tick => done_tick_33,
		quo => quo_33,
		rmd => rmd_33
		);


--i_TOII_TUVE_ila: TOII_TUVE_ila
--PORT MAP (
--	clk => CLK,
--	probe0 => probe0
--);

--probe0(13 downto 0) <= std_logic_vector(brightness);
--probe0(27 downto 14) <= std_logic_vector(prev_start_index);
--probe0(41 downto 28) <= std_logic_vector(prev_end_index);
--probe0(55 downto 42) <= std_logic_vector(diff_brightness);
--probe0(69 downto 56) <= std_logic_vector(prev_brightness);
--probe0(89 downto 70) <= std_logic_vector(gain_mult);
----probe0(103 downto 90) <= std_logic_vector(lin_mul1);
----probe0(120 downto 104) <= std_logic_vector(lin_mul2);
----probe0(138 downto 121)  <= std_logic_vector(lin_mul3);
----probe0(150 downto 139) <= (others=>'0');
--probe0(14+90 downto 90) <= std_logic_vector(count2);
--probe0( 19+105 downto 105) <= std_logic_vector(dump1);
----probe0(123) <= '0';
----probe0(124) <= start_found;
--probe0(125) <= end_found;
--probe0(31+126 downto 126) <= std_logic_vector(dphe_area_for_end);
--probe0(158) <= start_found;
----probe0(158 downto 151) <= std_logic_vector(lin_output_val(0));
--probe0(178 downto 159) <= std_logic_vector(new_inv_bin_size);
--probe0(198 downto 179) <= std_logic_vector(inv_max_gain);
--probe0(205 downto 199) <= std_logic_vector(to_unsigned(state'POS(dphe_st), 7));
--probe0(206) <= pixel_vld;
--probe0(207) <= video_i_v;
--probe0(208) <= video_eoi(0);
--probe0(222 downto 209) <= pixel_in;
--probe0(255 downto 223) <= (others=>'0');

end RTL;