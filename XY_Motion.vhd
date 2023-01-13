-- Jeffrey Zhen and Justin Chow
-- ECE124
-- Lab 4
-- Section 003 
-- XY_Motion.vhd
-- State Machine Used: Moore 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity XY_Motion IS Port
(
 clk_input, reset, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT,	extender_out		: IN std_logic;
 clk_en_x, clk_en_y, up_down_x, up_down_y, Capture_XY, error, extender_en 			: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of XY_Motion is
 
  
 TYPE STATE_NAMES IS (getMotionInput, motionRelease, getCompXYInput, xUpYUp, xDownYDown, xUpYDown, xDownYUp, 
 getCompxInput, xCountUp, xCountDown, getCompyInput, yCountUp, yCountDown, errorStateOn, errorStateOff);   -- list all the STATE_NAMES values
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

BEGIN

 
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, reset, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (reset = '1') THEN
		current_state <= getMotionInput;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out, current_state) 

BEGIN
     CASE current_state IS
			-- Check when motion motion is pushed and if extender is extended or retracted. 
			--If the button is not intially pressed, keep checking for button press (loops back to the beginning of the same state)
         WHEN getMotionInput =>		
				IF(motion='1' AND extender_out = '0') THEN
					next_state <= motionRelease;
				ELSIF (motion = '1' and extender_out = '1') THEN
					next_state <= errorStateOn;
				ELSE
					next_state <= getMotionInput;
				END IF;
			
			-- Check when motion button is released
         WHEN motionRelease =>
				IF (motion = '0') THEN
					next_state <= getCompXYInput;
				ELSE
					next_state <= motionRelease;
				END IF;
			
			-- Checks both X and Y LT, GT, EQ
			WHEN getCompXYInput =>
				--X and Y both increment up (both X_LT and Y_LT is true)
				IF(X_LT = '1' and Y_LT ='1') THEN
					next_state <= xUpYUp;
					
				-- X and Y both increment down (both X_GT and Y_GT is true)
				ELSIF(X_GT='1' and Y_GT = '1') THEN
					next_state <= xDownYDown;
					
				-- X increment up and Y increment down (both X_LT and Y_GT is true)
				ELSIF (X_LT = '1' and Y_GT ='1') THEN
					next_state <= xUpYDown;
					
				-- x increment down and Y increment up (both X_GT and Y_LR is true)
				ELSIF (X_GT = '1' and Y_LT ='1') THEN
					next_state <= xDownYUp;
					
				-- If X_EQ or Y_EQ is true (x and y is finished counting), individually continue counting X or Y; Goes to getCompxInput by default
				ELSIF (X_EQ = '1' or Y_EQ = '1') THEN
					next_state <= getCompxInput;
				
				-- Loop back to the beginning of the state if none of the conditions are true
				ELSE
					next_state <= getCompXYInput;
				END IF;
			
			--Increment both X and Y up by 1 (goes back to getCompXYInput)
			WHEN xUpYUp =>
				next_state <= getCompXYInput;
			
			--Increment both X and Y down by 1 (goes back to getCompXYInput)
			WHEN xDownYDown =>
				next_state <= getCompXYInput;
				
			--Increment X up by 1 and Y down by 1 (goes back to getCompXYInput)
			WHEN xUpYDown =>
				next_state <= getCompXYInput;
				
			--Increment X down by 1 and Y up by 1 (goes back to getCompXYInput)
			WHEN xDownYUp =>
				next_state <= getCompXYInput;
			
			-- Get compx values (Same thing as getCompXYInput state but for individual X value)
         WHEN getCompxInput =>		
				IF(X_LT='1') THEN
					next_state <= xCountUp;
				ELSIF(X_GT='1') THEN
					next_state <= xCountDown;
				ELSIF (X_EQ = '1') THEN
					next_state <= getCompyInput;
				ELSE
					next_state <= getCompxInput;
				END IF;
			
			-- Count X coordinate up by 1
         WHEN xCountUp =>	
				next_state <= getCompxInput;
			
			-- Count X coordinate down by 1
         WHEN xCountDown =>		
					next_state <= getCompxInput;
			
			-- Get compy values (Same thing as getCompXYInput state but for individual y value)
			WHEN getCompyInput =>		
				IF(Y_LT='1') THEN
					next_state <= yCountUp;
				ELSIF(Y_GT='1') THEN
					next_state <= yCountDown;
				ELSIF (Y_EQ = '1') THEN
					next_state <= getMotionInput;
				ELSE
					next_state <= getCompyInput;
				END IF;
			
			-- Count Y coordinate up by 1
         WHEN yCountUp =>	
				next_state <= getCompyInput;
			
			-- Count Y coordinate up by 1
         WHEN yCountDown =>		
				next_state <= getCompyInput;
			
			-- When motion button is pressed during extended extender (Flash the error light; Go between light on and off state until extender is retracted).
			WHEN errorStateOn =>
				IF (extender_out = '0') THEN
					next_state <= getMotionInput;
				ELSE
					next_state <= errorStateOff;
				END IF;
			WHEN errorStateOff =>
				next_state <= errorStateOn;
 		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out, current_state) 

BEGIN
     CASE current_state IS
			-- Whenever the arm is not moving, extender_en is 1 (is allowed to extend), error light is 0 (not in error state), and both x and y clocks (for counter) is 0. 
			-- This is the default state whenever the arm is not moving in x and y direction or when the arm is extended.
         WHEN getMotionInput =>		
				extender_en <= '1';
				clk_en_y	<= '0';
				Capture_XY <= '0';
				clk_en_x	<= '0';
				error <= '0';
			
			-- On Motion Button Release, extender_en is turned off and capture the XY inputs
         WHEN motionRelease =>		
				extender_en <= '0';
				Capture_XY <= '1';
				error <= '0';
			
			-- Increment the X coordinate by up 1 (Clock_en for x counter is enabled. For y, it is disabled). Counting X coord, up_down for x is 1.
         WHEN xCountUp =>
				extender_en <= '0';
				clk_en_y <= '0';
				clk_en_x <= '1';
				up_down_x <= '1';
			
			-- Increment the X coordinate by down 1 (Clock_en for x counter is enabled. For y, it is disabled). Counting X coord, up_down for x is 0.
         WHEN xCountDown =>
				extender_en <= '0';	
				clk_en_x <= '1';	
				clk_en_y <= '0';
				up_down_x <= '0';
			
			-- Same thing as xCountUp state; Clock_en for x counter is disabled.
         WHEN yCountUp =>	
				extender_en <= '0';
				clk_en_x <= '0';
				clk_en_y	<= '1';
				up_down_y <= '1';
			
			-- Same thing as xCountDown state; Clock_en for x counter is disabled.
         WHEN yCountDown =>
				extender_en <= '0';
				clk_en_y	<= '1';
				clk_en_x <= '0';		
				up_down_y <= '0';
			
			-- Turn error light on
         WHEN errorStateOn =>		
				error <= '1';
				clk_en_x <= '0';
				clk_en_y <= '0';
				extender_en <= '1';
			
			-- Turn error light off
			WHEN errorStateOff =>
				error <= '0';
				clk_en_x <= '0';
				clk_en_y <= '0';
				extender_en <= '1';
			
			-- Get compx Input
			WHEN getCompxInput =>
				extender_en <= '0';
				clk_en_x <= '0';	
				Capture_XY <= '0';
			
			-- Get compy Input	
			WHEN getCompyInput =>
				extender_en <= '0';
				clk_en_y <= '0';	
				Capture_XY <= '0';
			
			-- Set clk_en for x and y to be 0. Ensure Capture XY is set to 0.
			WHEN getCompXYInput =>
				clk_en_x <= '0';
				clk_en_y <= '0';
				Capture_XY <= '0';
				extender_en <= '0';
			
			--Increment both X and Y up by 1 (goes back to getCompXYInput)
			WHEN xUpYUp =>
				clk_en_x <= '1';
				clk_en_y <= '1';
				up_down_y <= '1';
				up_down_x <= '1';
				extender_en <= '0';
			
			--Increment both X and Y down by 1 (goes back to getCompXYInput)
			WHEN xDownYDown =>
				clk_en_x <= '1';
				clk_en_y <= '1';
				up_down_y <= '0';
				up_down_x <= '0';
				
			--Increment X up by 1 and Y down by 1 (goes back to getCompXYInput)
			WHEN xUpYDown =>
				clk_en_x <= '1';
				clk_en_y <= '1';
				up_down_y <= '0';
				up_down_x <= '1';
				
			--Increment X down by 1 and Y up by 1 (goes back to getCompXYInput)
			WHEN xDownYUp =>
				clk_en_x <= '1';
				clk_en_y <= '1';
				up_down_y <= '1';
				up_down_x <= '0';
		
				
	  END CASE;
 END PROCESS;
 
 
 END ARCHITECTURE SM;
