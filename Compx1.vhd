library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Compx1 is port(
	A_in: in std_logic;
	B_in: in std_logic;
	AGTB: out std_logic;
	AEQB: out std_logic;
	ALTB: out std_logic
);
END Compx1;

architecture gates of Compx1 is
 
BEGIN

	AGTB <= A_in AND (NOT B_in);
	AEQB <= NOT (A_in XOR B_in);
	ALTB <= (NOT A_in) AND B_in;

END gates;
