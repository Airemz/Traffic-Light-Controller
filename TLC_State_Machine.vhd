-- Author: Group 17, Mohamed, Sadiq

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity TLC_State_Machine IS Port

(
 -- inputs
 clk_input, reset, sm_clken, blink_sig			: IN std_logic;
 
 --pedestrians crossing request input
 NS_request, EW_request								: IN std_logic;
 
 --lights outputs
 NS_red, NS_yellow, NS_green						: OUT std_logic;
 EW_red, EW_yellow, EW_green						: OUT std_logic;
 
 --Pedestrian crossing signals
 NS_crossing, EW_crossing							: OUT std_logic;
 
 --pedestrians crossing output
 NS_clear, EW_clear									: OUT std_logic;
 
 --4 bit state leds outputs
 state_leds												: OUT std_logic_vector(3 downto 0)
 );
 
END ENTITY;
 

 Architecture SM of TLC_State_Machine is
 
 -- list all the STATE_NAMES values
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);   
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES



 BEGIN

 
 -------------------------------------------------------------------------------
											--Register Logic Process--
 -------------------------------------------------------------------------------

 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		-- if the reset is on then the current state will be set to state 0
		IF (reset = '1') THEN
			current_state <= S0;
		
		-- only change states when the reset is off and sm_clken is enabled
		ELSIF ((reset = '0') AND (sm_clken = '1')) THEN
			current_state <= next_State;
			
		END IF;
		
	END IF;
	
END PROCESS;	



 -------------------------------------------------------------------------------
											--Transition Logic Process--
 -------------------------------------------------------------------------------

 
-- Most states follow apropriate logic (when state_x, jump to the next consecutive state)
-- Few states check for conditions and jump states --> States 0,1,8,9

Transition_Section: PROCESS (current_state, NS_request, EW_request) 

BEGIN
  CASE current_state IS
			
        WHEN S0 =>
				-- check if the EW request to cross is on and the NS request to cross is off
				-- if so then jump to state 6 so that EW pedestrians can cross faster
				if (EW_request = '1' AND NS_request = '0') then
					next_state <= S6;
					
				else
					next_state <= S1;
				
				end if;

         WHEN S1 =>
				-- check if the EW request to cross is on and the NS request to cross is off
				-- if so then jump to state 6 so that EW pedestrians can cross faster
				if (EW_request = '1' AND NS_request = '0') then
					next_state <= S6;
				
				else	
					next_state <= S2;
				
				end if;

         WHEN S2 =>		
					next_state <= S3;
				
         WHEN S3 =>		
				next_state <= S4;

         WHEN S4 =>		
				next_state <= S5;

         WHEN S5 =>		
					next_state <= S6;
				
         WHEN S6 =>		
					next_state <= S7;
				
         WHEN S7 =>		
					next_state <= S8;

			WHEN S8 =>
				-- check if the NS request to cross is on and the EW request to cross is off
				-- if so jump to state 14 so that NS pedestrians can cross faster
				if (NS_request = '1' AND EW_request  = '0') then
					next_state <= S14;
				
				else	
					next_state <= S9;
					
				end if;
				
			WHEN S9 =>	
				-- check if the NS request to cross is on and the EW request to cross is off
				-- if so jump to state 14 so that NS pedestrians can cross faster
				if (NS_request = '1' AND EW_request  = '0') then
					next_state <= S14;
				
				else	
					next_state <= S10;
					
				end if;
					
			WHEN S10 =>		
					next_state <= S11;
					
			WHEN S11 =>		
					next_state <= S12;
					
			WHEN S12 =>		
					next_state <= S13;
			
			WHEN S13 =>		
					next_state <= S14;
					
			WHEN S14 =>		
					next_state <= S15;
			
			WHEN S15 => 
					next_state <= S0;
		
	  END CASE;
 END PROCESS;
 

--------------------------------------------------------------------------------
											--Decoder Logic Process--
--------------------------------------------------------------------------------
-- Set the outputs of the statemachine for each state
-- The NS and EW lights are determined in each state using each respective segment on the 7segment display
-- For example in state 0, there should be a blinking green light for NS and red light for EW
-- This is produced by setting the NS green to blinking and NS yellow and NS red to 0. EW_red will be on only.
-- The State nums are produced in each state too using binary bits
-- The crossing displays are also outputted in each state according to the light
-- Similarily when the request to cross is also cleared in specific states

Decoder_Section: PROCESS (current_state) 

BEGIN
     CASE current_state IS
	  
         WHEN S0 =>	-- NS is blinking green and EW is Red, no crossing and no clearing	
							NS_green 	<= blink_sig; 
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							
							-- For State 0
							state_leds <= "0000";
			
			
			
			
         WHEN S1 =>	-- NS is blinking green and EW is Red, no crossing and no clearing		
							NS_green 	<= blink_sig;
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 1
							state_leds <= "0001";
			
			
			

         WHEN S2 =>	-- NS is solid green and EW is Red, NS pedestrians are allowed to cross		
							NS_green 	<= '1';
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '1';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 2
							state_leds <= "0010";
			
			
			
			
         WHEN S3 =>	-- NS is solid green and EW is Red, NS pedestrians are allowed to cross			
							NS_green 	<= '1';
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '1';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 3
							state_leds <= "0011";
			
			
			

         WHEN S4 =>	-- NS is solid green and EW is Red, NS pedestrians are allowed to cross			
							NS_green 	<= '1';
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '1';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 4
							state_leds <= "0100";
							
							
							

         WHEN S5 =>	-- NS is solid green and EW is Red, NS pedestrians are allowed to cross			
							NS_green 	<= '1';
							NS_yellow 	<= '0';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '1';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 5
							state_leds 	<= "0101";
							
							
							
				
         WHEN S6 =>	-- NS is solid green and EW is Red, NS crossing requests are cleared			
							NS_green 	<= '0';
							NS_yellow 	<= '1';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '0';
							NS_clear 	<= '1';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 6
							state_leds <= "0110";
							
							
				
         WHEN S7 =>	-- NS is yellow and EW is Red, no crossing and no clearing		
							NS_green 	<= '0';
							NS_yellow 	<= '1';
							NS_red 		<= '0';
							
							EW_green 	<= '0';
							EW_yellow 	<= '0';
							EW_red 		<= '1';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 7
							state_leds <= "0111";
							
							
							
			WHEN S8 =>	-- NS is red and EW is blinking green, no crossing and no clearing	
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= blink_sig;
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 8
							state_leds <= "1000";
							
							
			WHEN S9 =>	-- NS is red and EW is blinking green, no crossing and no clearing		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= blink_sig;
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 9
							state_leds <= "1001";
							
							
							
			WHEN S10 =>	-- NS is red and EW is solid green, EW pedestrians are allowed to cross		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '1';
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '1';
							EW_clear 	<= '0';
							
							-- For State 10
							state_leds <= "1010";	
							
							
			WHEN S11 =>	-- NS is red and EW is solid green, EW pedestrians are allowed to cross		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '1';
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '1';
							EW_clear 	<= '0';
							
							-- For State 11
							state_leds <= "1011";
							
							
			WHEN S12 =>	-- NS is red and EW is solid green, EW pedestrians are allowed to cross		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '1';
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '1';
							EW_clear 	<= '0';
							
							-- For State 12
							state_leds <= "1100";
											
							
			WHEN S13 =>	-- NS is red and EW is solid green, EW pedestrians are allowed to cross		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '1';
							EW_yellow 	<= '0';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '1';
							EW_clear 	<= '0';
							
							-- For State 13
							state_leds <= "1101";
							
							
			WHEN S14 =>	-- NS is red and EW is yellow, EW request to cross is cleared		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '0';
							EW_yellow 	<= '1';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '1';
							
							-- For State 14
							state_leds 	<= "1110";
								
							
			WHEN S15 =>	-- NS is red and EW is yellow, EW request to cross is cleared		
							NS_green 	<= '0';
							NS_yellow 	<= '0';
							NS_red 		<= '1';
							
							EW_green 	<= '0';
							EW_yellow 	<= '1';
							EW_red 		<= '0';
							
							NS_crossing <= '0';
							NS_clear 	<= '0';
							EW_crossing <= '0';
							EW_clear 	<= '0';
							
							-- For State 15
							state_leds <= "1111";

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
