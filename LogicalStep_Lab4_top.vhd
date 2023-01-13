-- Jeffrey Zhen and Justin Chow
-- ECE124
-- Lab 4
-- Section 003 
-- LogicalStep_Lab4_top.vhd

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
	Clkin_50			: in	std_logic;
	pb_n			: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); 
	leds			: out std_logic_vector(7 downto 0);

------------------------------------------------------------------	
	xreg, yreg	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
	xPOS, yPOS	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
------------------------------------------------------------------	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment display (for LogicalStep only)
	seg7_char1  : out	std_logic;				    		-- seg7 digit1 selector (for LogicalStep only)
	seg7_char2  : out	std_logic				    		-- seg7 digit2 selector (for LogicalStep only)
	
	);
END LogicalStep_Lab4_top;

ARCHITECTURE Circuit OF LogicalStep_Lab4_top IS

-- Provided Project Components Used
------------------------------------------------------------------- 
COMPONENT Clock_Source 	port (SIM_FLAG: in boolean;clk_input: in std_logic;clock_out: out std_logic);
END COMPONENT;

component SevenSegment
  port 
   (
      hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
      sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
   ); 
end component SevenSegment;

component segment7_mux 
  port 
   (
      clk        : in  std_logic := '0';
		DIN2 		: in  std_logic_vector(6 downto 0);	
		DIN1 		: in  std_logic_vector(6 downto 0);
		DOUT			: out	std_logic_vector(6 downto 0);
		DIG2			: out	std_logic;
		DIG1			: out	std_logic
   );
end component segment7_mux;
------------------------------------------------------------------
-- Add any Other Components here
------------------------------------------------------------------

COMPONENT Bidir_shift_reg

	port
	(
		CLK					: in  std_logic;
		reset					: in  std_logic; 
		CLK_EN				: in  std_logic;
		LEFT0_RIGHT1		: in  std_logic;
		REG_BITS				: out std_logic_vector (3 downto 0)
	);

end COMPONENT;

COMPONENT U_D_Bin_Counter4bit

	port
	(
		CLK					: in  std_logic;
		reset					: in  std_logic; 
		CLK_EN				: in  std_logic;
		UP1_DOWN0			: in  std_logic;
		COUNTER_BITS		: out std_logic_vector (3 downto 0)
	);

end COMPONENT;

COMPONENT XY_Motion Port
(
 clk_input, reset, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT,	extender_out		: IN std_logic;
 clk_en_x, clk_en_y, up_down_x, up_down_y, Capture_XY, error, extender_en 			: OUT std_logic
 );
END COMPONENT;

COMPONENT Compx4 port(
	A_in : in std_logic_vector (3 downto 0);
	B_in : in std_logic_vector (3 downto 0);
	AGTB: out std_logic;
	AEQB: out std_logic;
	ALTB: out std_logic
);
END COMPONENT;

COMPONENT Switch_Register

	port
	(
		clock					: in std_logic;
		Capture_XY			: in 	std_logic; 
		target_in			: in  std_logic_vector (3 downto 0);
		target_out			: out std_logic_vector (3 downto 0)
	);

end COMPONENT;

component Synch_inverter port(
	sync_clk			: in std_logic;
	input3,input2,input1,input0	: in std_logic;
	reset,sync_motion,sync_extender,sync_grappler	: out std_logic
	);
end component;

component extender Port
(
 clk_input, reset, extender, extender_en					: IN std_logic;
 ext_pos 															: IN std_logic_vector (3 downto 0);
 clk_en, left_right, extender_out, grappler_en 			: OUT std_logic
 );
END component;

component grappler IS Port
(
 clk_input, reset, grappler, grappler_en					: IN std_logic;
 grappler_on 			: OUT std_logic
 );
END component;

------------------------------------------------------------------
-- provided signals
-------------------------------------------------------------------
------------------------------------------------------------------	
constant SIM_FLAG : boolean := TRUE; -- set to FALSE when compiling for FPGA download to LogicalStep board
------------------------------------------------------------------	
------------------------------------------------------------------	
-- Create any additional internal signals to be used
signal clk_in, clock	: std_logic;
signal extender_out, extender_en : std_logic;
signal clk_en_x, clk_en_y, up_down_x, up_down_y, Capture_XY : std_logic;
signal x_pos, y_pos, ext_pos : std_logic_vector(3 downto 0);
signal x_reg, y_reg : std_logic_vector(3 downto 0);
signal X_GT, X_EQ, X_LT, Y_GT, Y_EQ, Y_LT, xy_clock : std_logic;
signal seg7_2, seg7_1 : std_logic_vector(6 downto 0); 
signal reset, motion, extender_input, grappler_input :std_logic;
signal clk_en, left_right, grappler_en : std_logic;


BEGIN
clk_in <= clkin_50;

--Led Output for extender position
leds(5 downto 2) <= ext_pos;

--Simulation Outputs
 xreg <= x_reg;
 yreg <= y_reg;
 xPOS <= x_pos;
 yPOS <= y_pos;


Clock_Selector: Clock_source port map(SIM_FLAG, clk_in, clock);

-- new instances

-- XY Motion State Machine
inst1: XY_Motion port map (clock, reset, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out, clk_en_x, clk_en_y, up_down_x, up_down_y, Capture_XY, leds(0), extender_en);

-- Up Down Binary Counter for X Coords
inst2: U_D_Bin_Counter4bit port map (clock, reset, clk_en_x, up_down_x,  x_pos);

-- Compx4 for X Coords
inst3: Compx4 port map (x_pos, x_reg, X_GT, X_EQ, X_LT);

--Register for X Coords
inst4: Switch_Register port map (clock, Capture_XY, sw(7 downto 4), x_reg);

--------------------

-- Up Down Binary Counter for Y Coords
inst5: U_D_Bin_Counter4bit port map (clock, reset, clk_en_y, up_down_y,  y_pos);

-- Compx4 for y Coords
inst6: Compx4 port map (y_pos, y_reg, Y_GT, Y_EQ, Y_LT);

--Register for y Coords
inst7: Switch_Register port map (clock, Capture_XY, sw(3 downto 0), y_reg);

-------------------

--X Coord 7 Segment
inst8: SevenSegment port map (x_pos, seg7_2);

--Y Coord 7 Segment
inst9: SevenSegment port map (y_pos, seg7_1);

--7 Segment Mux
inst10: segment7_mux port map (clk_in, seg7_2, seg7_1, seg7_data, seg7_char1, seg7_char2);

------------

--Synch Inverter block for buttons
inst11: Synch_inverter port map(clock, pb_n(3), pb_n(2), pb_n(1), pb_n(0), reset, motion, extender_input, grappler_input);

----------

--Extender State Machine
inst12: extender port map (clock, reset, extender_input, extender_en, ext_pos, clk_en, left_right, extender_out, grappler_en);

--Bidirectional Shift Register for Extender
inst13: Bidir_shift_reg port map (clock, reset, clk_en, left_right, ext_pos);

---------

-- Grappler State Machine
inst14: grappler port map (clock, reset, grappler_input, grappler_en, leds(1));

end Circuit;