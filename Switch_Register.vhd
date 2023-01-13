library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Switch_Register is

	port
	(
		clock					: in std_logic;
		Capture_XY			: in 	std_logic; 
		target_in			: in  std_logic_vector (3 downto 0);
		target_out			: out std_logic_vector (3 downto 0)
	);

end entity;

architecture goose of Switch_Register is

signal sreg 			: std_logic_vector (3 downto 0);


begin

process (clock, Capture_XY) is
begin
	if (rising_edge(clock) and Capture_XY = '1') then
		sreg <= target_in;
	
	END IF;
	
	target_out <= sreg;
	
end process;


end goose;


