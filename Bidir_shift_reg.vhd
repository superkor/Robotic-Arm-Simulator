-- Jeffrey Zhen and Justin Chow
-- ECE124
-- Lab 4
-- Section 003 
-- Bidir_shift_reg.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bidir_shift_reg is

	port
	(
		CLK					: in  std_logic;
		RESET					: in  std_logic; 
		CLK_EN				: in  std_logic;
		LEFT0_RIGHT1		: in  std_logic;
		REG_BITS				: out std_logic_vector (3 downto 0)
	);

end entity;

architecture one of Bidir_shift_reg is

signal sreg 			: std_logic_vector (3 downto 0);


begin

process (CLK, RESET) is
begin
	if (RESET = '1') then
		sreg <= "0000";
	
	elsif (rising_edge(CLK) AND (CLK_EN = '1')) then
	
		if (LEFT0_RIGHT1 = '1') then -- TRUE for RIGHT shift
			
			sreg (3 downto 0) <= '1' & sreg(3 downto 1); -- right-shift of bits
			
		elsif (LEFT0_RIGHT1 = '0') then
		
			sreg (3 downto 0) <= sreg(2 downto 0) & '0'; -- left-shift of bits
			
		end if;
		
	end if;
	REG_BITS <= sreg;

end process;


end one;


