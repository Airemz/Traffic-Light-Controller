-- Author: Group 17, Mohamed, Sadiq

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
	-- These are temporary outputs for the simulations
	sm_clken_sim 		:out std_logic;
	blink_sig_sim 		:out std_logic;
	
	NS_red_sim 			:out std_logic;
	NS_yellow_sim		:out std_logic;
	NS_green_sim 		:out std_logic;
	
	EW_red_sim 			:out std_logic;
	EW_yellow_sim 		:out std_logic;
	EW_green_sim 		:out std_logic;	
	--------------------------------
	
	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

   component segment7_mux port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 		: in  std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;
	
   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
         clkin      		: in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;
	
	component PB_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	: out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	: out	std_logic_vector(3 downto 0)							 
	); 
	end component;
	
   component PB_inverters port (
			rst_n_filtered		: in 	std_logic;
			rst					: out std_logic;
			pb_n_filtered		: in  std_logic_vector (3 downto 0);
			pb						: out	std_logic_vector(3 downto 0)	
	); 

	end component;
	
	component synchronizer port (
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
	);
	
	end component;

	
	component holding_register port (
	
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
			
	);
	
	end component;
	
	component TLC_State_Machine port (
	
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
	 
	end component;
	
----------------------------------------------------------------------------------------------------
	-- Constant value used only for simulations
	-- set to FALSE for LogicalStep board downloads  -- set to TRUE for SIMULATIONS
	CONSTANT	sim_mode											: boolean := TRUE; 
	
	-- reset signals to reset the states, leds, 7seg digits,pb buttons, 
	SIGNAL rst, rst_n_filtered, synch_rst 				: std_logic; 
	
	-- clock outputs from the clock generators which are used in the state machine, blink_sig creates the blinking lights
	SIGNAL sm_clken, blink_sig								: std_logic; 
	
	--signals used for the pb_filters instance
	SIGNAL pb_n_filtered, pb								: std_logic_vector(3 downto 0); 
	
	-- used to carry the output form the synchronizers and into the holding registers
	SIGNAL synch_EW,synch_NS								: std_logic;
	
	-- Signals for crossing requests, displays, holding registers and the state numbers, used by synchronizer, holding register and state machine instances
	SIGNAL NS_request,EW_request							: std_logic;
	SIGNAL NS_cross_display,EW_cross_display			: std_logic;
	SIGNAL NS_cross_clear,EW_cross_clear				: std_logic;
	SIGNAL NS_holding_register, EW_holding_register	: std_logic;
	signal State_number										: std_logic_vector(3 downto 0);
	
	-- Signals for the red, green and yellow lights which are outputted from the state machine and into the 7seg mux
	SIGNAL NS_red, NS_yellow, NS_green					: std_logic;
	SIGNAL EW_red, EW_yellow, EW_green					: std_logic;
	SIGNAL NS_light, EW_light								: std_logic_vector(6 downto 0);
		
BEGIN
----------------------------------------------------------------------------------------------------
												--Preliminary Instances--
----------------------------------------------------------------------------------------------------	

-- Utilizing the global clock, reset and pb inputs and removing "cross-talk noise glithces"
INST0: pb_filters				port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);

-- inverts the rst_n inputs and pb inputs so that the default state is changed from high to low
INST1: pb_inverters			port map (rst_n_filtered, rst, pb_n_filtered, pb);

-- utilizes the synchorinzed reset, sim_mode constant and global clock and outputs the state machine clock and blink signal.
INST2: clock_generator 		port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

----------------------------------------------------------------------------------------------------
								--Synchonizers and Holding Register Instances--
----------------------------------------------------------------------------------------------------	
-- utilizes the EW_request from the pb(1) and synchronizes it with the clock and reset to output into holding register
INST3: synchronizer	 		port map (clkin_50, synch_rst, EW_request, synch_EW);
 
-- creates a synchronized reset which is used in the synchonizers, holding registers and clock generator
INST4: synchronizer	 		port map (clkin_50, synch_rst, rst , synch_rst); 

-- utilizes the NS_request from the pb(0) and synchronizes it with the clock and reset to output into holding register
INST5: synchronizer	 		port map (clkin_50, synch_rst, NS_request, synch_NS); 

-- holds the EW request to cross for a pedestrian
-- also clears the request if the output clear from the statemachine is true
INST6: holding_register	 	port map (clkin_50, synch_rst, EW_cross_clear, synch_EW, EW_holding_register); 

-- holds the NS request to cross for a pedestrian 
-- also clears the request if the output clear from the statemachine is true
INST7: holding_register	 	port map (clkin_50, synch_rst, NS_cross_clear, synch_NS, NS_holding_register); 

----------------------------------------------------------------------------------------------------
								--Moore Style State Machine Instance--
----------------------------------------------------------------------------------------------------	

-- Utilizes a Moore style state machine to create the NS light and EW light
-- Uses outputs from the holding registers to determine when to jump states
-- Uses outputs from the clock generator to determine the next state cycle and also to create the blinking green light
-- The state machine also outputs when the pedestrians can cross their respective lights
-- Finally the state machine also outputs the State number in the form of leds(7 downto 4)
INST8: TLC_State_Machine 	port map (clkin_50, synch_rst, sm_clken, blink_sig, NS_holding_register, EW_holding_register, NS_red, NS_yellow, NS_green, EW_red, EW_yellow, EW_green, NS_cross_display, EW_cross_display, NS_cross_clear, EW_cross_clear, State_number);

-- Creates the appropraite NS and EW lights on the 7 segment display
INST9: segment7_mux 		 	port map (clkin_50, NS_light, EW_light, seg7_data, seg7_char2, seg7_char1);



----------------------------------------------------------------------------------------------------
											--Conecting Signals--
----------------------------------------------------------------------------------------------------	

	-- Displays the current state number on leds(7 downto 4) in binary form
	-- i.e. state 4 = 0100 so led(6) will be on while the others will be off
	leds(7 downto 4) <= State_number(3 downto 0);
	
	-- Displays the pedestrian crossing requests (for NS --> led(1)) (for EW --> led(3))
	-- Displays when it is safe for a pedestrian to cross (for NS --> led(0)) and (for EW --> led(2))
	leds(3) 	<= 	EW_holding_register; 
	leds(2) 	<= 	EW_cross_display;
	leds(1) 	<= 	NS_holding_register;
	leds(0) 	<= 	NS_cross_display;
	
	
	-- Inputs the requests from pedestrians to cross (for NS --> pb(0)) and (for EW --> pb(1))
	EW_request <=  pb(1);
	NS_request <=  pb(0);
	
	-- For the 7 segment display we need to display A(0000001)=red light, D(0001000)=green light, G(1000000)=yellow
	-- We need to concatanate to create a 7 bit signal which will be inputed to the 7 seg mux
	-- The yellow, green and red signals will alternate between 0 and 1, according to the state machine
	-- The appropriate lights will be displayed according to state number
	NS_light <= NS_yellow  & "00" & NS_green & "00" & NS_red;
	EW_light <= EW_yellow  & "00" & EW_green & "00" & EW_red;
	
	-- Connecting the simulation output ports to their respective signals to view on the waveform
	-- these are only used for the simulations and will be commented out when uploading to the board
	sm_clken_sim 		<= 	sm_clken;
	blink_sig_sim 		<=		blink_sig;
	
	NS_green_sim 		<= 	NS_green;
	NS_yellow_sim 		<= 	NS_yellow;
	NS_red_sim 			<= 	NS_red;
	
	EW_green_sim 		<= 	EW_green;
	EW_yellow_sim 		<= 	EW_yellow;
	EW_red_sim 			<= 	EW_red;
	
END SimpleCircuit;
