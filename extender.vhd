-- Jeffrey Zhen and Justin Chow
-- ECE124
-- Lab 4
-- Section 003 
-- extender.vhd
-- State Machine Used: Moore 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity extender IS Port
(
 clk_input, reset, extender, extender_en					: IN std_logic;
 ext_pos 															: IN std_logic_vector (3 downto 0);
 clk_en, left_right, extender_out, grappler_en 			: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of extender is
 
  
 TYPE STATE_NAMES IS (initialExtender, getExtenderInput, getExtender_en, extenderRelease, extenderExtend, extenderFullExtend, extenderRetract);   -- list all the STATE_NAMES values
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES
 signal extender_extend : std_logic; --(Declaring temporary signal for extender_out. extender_extend = 1 : extender is extended. extender_extend = 0 : extender is retracted)

BEGIN

 
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= initialExtender;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (extender, extender_en, ext_pos, current_state) 

BEGIN
     CASE current_state IS
			-- Initial State for Extender
			WHEN initialExtender =>
				next_state <= getExtenderInput;
			
			-- Wait for extender button is pushed. If not pushed, go back to same state
			WHEN getExtenderInput =>
				IF (extender = '1') THEN
					next_state <= getExtender_en;
				ELSE
					next_state <= getExtenderInput;
				END IF;
			
			-- If button is pushed, check if extender_en signal is high (extender is enabled by XY motion). If extender is not enabled, go back to getExtenderInput state.
         WHEN getExtender_en =>
				IF (extender_en = '1') THEN
					next_state <= extenderRelease;
				ELSE
					next_state <= getExtenderInput;
				END IF;
				
			-- If extender is enabled, wait for button release. Check if extender is extended or retacted. If extended, go to extenderRe state. If retacted, go to extenderExtend state.
			WHEN extenderRelease =>
				IF (extender = '0' and extender_extend = '0') THEN
					next_state <= extenderExtend;
				ELSIF (extender = '0' and extender_extend = '1') THEN
					next_state <= extenderRetract;
				ELSE
					next_state <= extenderRelease;
				END IF;
				
			-- Bit shift using bidirectional bitshifter. Wait until bit shifting is complete (all 1111 for extender position). Once completed,  go to extenderFullExtend state.
			WHEN extenderExtend =>
				IF (ext_pos = "1111") THEN
					next_state <= extenderFullExtend;
				ELSE 
					next_state <= extenderExtend;
				END IF;
			
			-- Bit shift using bidirectional bitshifter. Wait until bit shifting is complete (all 0000 for extender position). Once completed,  go to getExtenderInput state.
			WHEN extenderRetract =>
				IF (ext_pos = "0000") THEN
					next_state <= getExtenderInput;
				ELSE 
					next_state <= extenderRetract;
				END IF;
			
			-- Go to getExtenderInput (values will be set below to prepare for upcoming extender retraction)
			WHEN extenderFullExtend =>
				next_state <= getExtenderInput;
 		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (extender_en, ext_pos, current_state) 

BEGIN
     CASE current_state IS
			-- Ensure clock_en is false for bitshfiter.
         WHEN getExtender_en =>
				clk_en <= '0';
			
			--Grapper_en is set false. Extender is extending; left_right signal is set to 1 (bit shifting right), with clk_en set to 1. 
			--Internal signal for extender_extend is the same as extender_out (will be outputted to XY Motion)
         WHEN extenderExtend =>
				grappler_en <= '0';	
				left_right <= '1';
				extender_extend <= '1';
				extender_out <= extender_extend;
				clk_en <= '1';
			
			-- When bit shifting is complete for extender extending, enable grappler. Ensure clk_en for bitshifter is set 0.
         WHEN extenderFullExtend =>
				grappler_en <= '1';
				clk_en <= '0';
			
			-- Opposite of extenderExtend. Retracts the extender (left_right set to 0; bit shifts lefts in bit shifter). grappler_en is set to 0 (since no longer fully extended).
			-- extender_out is set to 0 since not extended.
         WHEN extenderRetract =>
				left_right <= '0';
				grappler_en <= '0';
				clk_en <= '1';
				extender_out <= '0';
				extender_extend <= '0';
				
			-- ensure clk_en is 0.
			WHEN getExtenderInput =>
				clk_en <= '0';
				
			-- on button release, extender_out will continue to be the same value as the internal signal, extender_extend.
			WHEN extenderRelease =>
				extender_out <= extender_extend;
			
			-- initial values for extender state machine: extender_extend (temporary signal for extender_out), is set to 0 (be default extender is retracted). clk_en and grappler_en is also 0.
			WHEN initialExtender =>
				extender_extend <=  '0';
				extender_out <= extender_extend;
				clk_en <= '0';
				grappler_en <= '0';
	  END CASE;
 END PROCESS;
 
 
 END ARCHITECTURE SM;
