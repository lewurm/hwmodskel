library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gen_pkg.all;

entity beh_foo_tb is
end entity beh_foo_tb;

architecture sim of beh_foo_tb is
	component foo is
		port
		(
			sys_clk : in std_logic;
			sys_res_n : in std_logic;
			a : in myvec;
			c : out std_logic
		);
	end component foo;

	signal sys_clk, sys_res_n, c : std_logic;
	signal a : myvec;
	signal stop : boolean := false;
begin
	inst : foo
	port map
	(
		sys_clk => sys_clk,
		sys_res_n => sys_res_n,
		a => a,
		c => c
	);

	process
	begin
		sys_clk <= '0';
		wait for 15 ns;
		sys_clk <= '1';
		wait for 15 ns;
		if stop = true then
			wait;
		end if;
	end process;

	process
		type foo_testv is record
			input : myvec;
			erg : std_logic;
		end record foo_testv;

		-- ggf. groesse des arrays erhoehen
		type foo_testv_array is array (natural range 0 to 5) of foo_testv;

		variable testmatrix : foo_testv_array :=
			( 0 => ("00", '0'),
			  1 => ("01", '1'),
			  2 => ("10", '1'),
			  3 => ("11", '0'),
			  others => ("11", '0')
			);

	begin
		-- init & reset
		sys_res_n <= '0';
		a <= "00";

		wait for 300 ns;
		sys_res_n <= '1';

		for i in testmatrix'range loop
			wait for 100 ns;

			a <= testmatrix(i).input;

			wait for 60 ns;

			assert c = testmatrix(i).erg
				report "" & std_logic'image(testmatrix(i).input(0)) &
				" xor " & std_logic'image(testmatrix(i).input(1)) &
				" /= " & std_logic'image(c) &
				" -- erwartet: " & std_logic'image(testmatrix(i).erg);
		end loop;

		assert false
			report "alle testfaelle waren erfolgreich!";
		stop <= true;
		wait;
	end process;
end architecture sim;
