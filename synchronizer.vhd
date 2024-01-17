-- Author: Group 17, Mohamed, Sadiq
library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is
	
	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN

process(clk) is
begin 

	--First DFF
	--if clock is on then the function runs
	if(rising_edge(clk)) then
		
		--if the reset is on, then the output is 0
		if(reset = '1') then
			sreg <= "00";
		
		--if reset is 0, then set the 1st bit of sreg (output from the DFF) to din
		elsif(reset = '0') then
		
			sreg(0) <= din;
			
		end if;
	
	end if;
	
	--Second DFF
	--if clock is on then the function runs
	if(rising_edge(clk)) then
		
		--if the reset is on, then the output is 0
		if(reset = '1') then
			sreg <= "00";
		
		--if reset is 0, then set the 2nd bit of sreg (output from the 2nd DFF) to to the first bit of sreg
		elsif(reset = '0') then
		
			sreg(1) <= sreg(0);
			
		end if;
	
	end if;
	
	--set the final output to the second bit of sreg
	dout <= sreg(1);

end process;
	
end;