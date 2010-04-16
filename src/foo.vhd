library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gen_pkg.all;

entity foo is
	port
	(
		sys_clk : in std_logic;
		sys_res_n : in std_logic;
		a : in myvec;
		c : out std_logic
	);
end entity foo;

architecture beh of foo is
begin
	process(sys_clk, sys_res_n)
	begin
		if sys_res_n = '0' then
			c <= '0';
		elsif rising_edge(sys_clk) then
			c <= a(1) xor a(0);
		end if;
	end process;
end architecture beh;

