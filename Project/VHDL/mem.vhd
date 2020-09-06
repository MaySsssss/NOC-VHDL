----------------------------------------------------------------------------------
-- Memory file to store the data from write packet and return a data to 
-- read_request packet 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity mem is
	generic ( node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;

           addr : in  STD_LOGIC_VECTOR (31 downto 0);

           wr_data : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;

           rd_request : in  STD_LOGIC;

           rd_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rd_return : out  STD_LOGIC);
end mem;

architecture Behavioral of mem is
	subtype register_led is std_logic_vector(7 downto 0);
	type memory_array is array(integer range 0 to 7) of register_led;
	signal register_array : memory_array;
begin
	process(clk) 
	begin
		if rising_edge(clk) then
			if wr = '1' then 
				register_array(to_integer(unsigned(addr(27 downto 25)))) <= wr_data;
				rd_return <= '0'; 
			elsif rd_request = '1' then
				rd_data <= register_array(to_integer(unsigned(addr(27 downto 25))));
				register_array <= register_array;
				rd_return <= '1';
			else 
				register_array <= register_array;
				rd_return <= '0';
			end if;
		end if;
	end process;
end Behavioral;

