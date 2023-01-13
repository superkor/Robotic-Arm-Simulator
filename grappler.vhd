-- Jeffrey Zhen and Justin Chow
-- ECE124
-- Lab 4
-- Section 003 
-- grappler.vhd
-- State Machine Used: Moore 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity grappler IS Port
(
 clk_input, reset, grappler, grappler_en					: IN std_logic;
 grappler_on 														: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of grappler is
 
  
 TYPE STATE_NAMES IS (get_grapplerEnabled, get_grapplerInput, grapplerRelease, grappleOn, grappleOff);   -- list all the STATE_NAMES values
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES
 signal grapplerTemp : std_logic; -- (Internally stores grappler_on)

BEGIN

 
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= grappleOff;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (grappler, grappler_en, current_state) 

BEGIN
     CASE current_state IS
			-- check if grappler is enabled (grappler_en signal is output from extender state machine; only enabled with extender is fully extended: 1111)
         WHEN get_grapplerEnabled =>
				IF (grappler_en = '1') THEN
					next_state <= grapplerRelease;
				ELSE
					next_state <= get_grapplerInput;
				END IF;
			
			-- check if grappler button is pushed
			WHEN get_grapplerInput =>
				IF (grappler = '1') THEN
					next_state <= get_grapplerEnabled;
				ELSE
					next_state <= get_grapplerInput;
				END IF;
				
			-- check if grappler button is released. If grapplerTemp (temporary variable for grappler_on) is 0, turn on the grappler. Otherwise, turn off the grappler.
			WHEN grapplerRelease =>
				IF (grapplerTemp = '0') THEN
					next_state <= grappleOn;
				ELSE
					next_state <= grappleOff;
				END IF;
			
			-- when grappler is on
			WHEN grappleOn =>
				next_state <= get_grapplerInput;
			
			-- when grappler is off
			WHEN grappleOff =>
				next_state <= get_grapplerInput;
 		END CASE;
 END PROCESS;
 
-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (grapplerTemp, grappler, grappler_en, current_state) 

BEGIN
     CASE current_state IS
	  
			-- the first three states have no values that need to be assigned
         WHEN get_grapplerEnabled =>		

         WHEN get_grapplerInput =>	

         WHEN grapplerRelease =>
			
			-- when grappler is on, turn the grappler LED on. Set the temporary variable grapplerTemp to 1 as well (to later turn it off when grappler button is pushed again).
			WHEN grappleOn =>
				grapplerTemp <= '1';
				grappler_on <= grapplerTemp;
				
			-- when grappler is off, turn the grappler LED off. Set the temporary variable grapplerTemp to 0 as well (to later turn it on when grappler button is pushed again).
			WHEN grappleOff =>
				grapplerTemp <= '0';
				grappler_on <= grapplerTemp;

	  END CASE;
 END PROCESS;
 
 
 END ARCHITECTURE SM;
