library ieee;
use ieee.std_logic_1164.all;


Entity Synch_inverter is port(
	sync_clk			: in std_logic := '0';
	input3,input2,input1,input0	: in std_logic := '0';
	reset,sync_motion,sync_extender,sync_grappler	: out std_logic
	);
	end Entity;

	
Architecture synchronize of synch_inverter is

signal stages_pb0, stages_pb1, stages_pb2, stages_pb3 : std_logic_vector(1 downto 0);

begin

synchronizing: process(sync_clk) is

begin
	IF (rising_edge(sync_clk)) then
	stages_pb3(1 downto 0) <= stages_pb3(0) & NOT(input3);
	stages_pb2(1 downto 0) <= stages_pb2(0) & NOT(input2);
	stages_pb1(1 downto 0) <= stages_pb1(0) & NOT(input1);
	stages_pb0(1 downto 0) <= stages_pb0(0) & NOT(input0);
	
	reset <= stages_pb3(1);
	sync_motion <= stages_pb2(1);
	sync_extender <= stages_pb1(1);
	sync_grappler <= stages_pb0(1);
	END IF;
end process;


end synchronize;	