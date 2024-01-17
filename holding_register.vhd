-- Author: Group 17, Mohamed, Sadiq
library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk						: in std_logic;
			reset						: in std_logic;
			register_clr			: in std_logic;
			din						: in std_logic;
			dout						: out std_logic
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;

BEGIN

process(clk) is
begin
		
	--if clock is on then the function runs	
	if(rising_edge(clk)) then
		
		--if the reset is on, then the output is 0
		if(reset = '1') then
			sreg <= '0';
		
		--if reset is 0, then the function runs 
		elsif(reset = '0') then
			
			--if register clear is 1 then sreg is 0 due to the NOR gate
			if (register_clr = '1') then
				sreg <= '0';
				
			else
				--Follow the logic process on the schematic
				sreg <= (din OR sreg) AND (register_clr NOR reset);

			end if;
			
		end if;
	
	end if;
	
	--set the output to the sreg
	dout <= sreg;
	
end process;

end;