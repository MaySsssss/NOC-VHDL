----------------------------------------------------------------------------------
-- Example network
-- Create the write and read_request packet 
-- Deal with the read_return packet and get the data 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity master is
    Generic (
				node_ID : STD_LOGIC_VECTOR(3 DOWNTO 0));
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  busy : in std_logic;
			  not_ready : out std_logic;
			  
			  packet_in : in std_logic_vector(48 downto 0);
			  packet_out : out std_logic_vector(48 downto 0);
			  
			  addr : in std_logic_vector(31 downto 0);
			  
			  rd_return : out std_logic;
			  rd_data : out std_logic_vector(7 downto 0);
			  
			  wr : in std_logic;
			  wr_data : in std_logic_vector(7 downto 0);
			  
			  rd_request : in std_logic);
end master;

architecture Behavioral of master is

	signal y_neg, x_neg : std_logic;
	signal y_count, x_count : std_logic_vector(1 downto 0);
	signal y_diff, x_diff : integer;
begin
	
	y_diff <= to_integer(unsigned(addr(31 downto 30))) - to_integer(unsigned(node_ID(3 DOWNTO 2)));
	x_diff <= to_integer(unsigned(addr(29 downto 28))) - to_integer(unsigned(node_ID(1 DOWNTO 0)));

	y_neg <= '1' when TO_INTEGER(unsigned((addr(31 downto 30)))) < TO_INTEGER(unsigned(node_ID(3 downto 2))) else '0'; --check direction
	y_count <= std_logic_vector(TO_UNSIGNED((-y_diff), 2)) when y_neg = '1' else std_logic_vector(TO_UNSIGNED((y_diff), 2));
	x_neg <= '1' when TO_INTEGER(unsigned(addr(29 downto 28))) < TO_INTEGER(unsigned(node_ID(1 downto 0))) else '0';
	x_count <= std_logic_vector(TO_UNSIGNED((-x_diff), 2)) when x_neg = '1' else std_logic_vector(TO_UNSIGNED((x_diff), 2));

	process(clk)
	begin
		if rising_edge(clk) then
			if busy = '1' then
				not_ready <= '1'; 
			else 
				not_ready <= '0';
				
				if rd_request = '1' then
					-- read request packet
					packet_out(48 downto 43) <= y_neg & y_count & x_neg & x_count;
					packet_out(42 downto 40) <= "010";
					packet_out(39 downto 8) <= addr;
					packet_out(7 downto 4) <= node_ID;
					packet_out(3 downto 0) <= (others => '0');
				elsif wr = '1' then 
					-- write packet
					packet_out(48 downto 43) <= y_neg & y_count & x_neg & x_count;
					packet_out(42 downto 40) <= "100";
					packet_out(39 downto 8) <= addr;
					packet_out(7 downto 0) <= wr_data;
				else
					packet_out(42 downto 40) <= "000";
				end if;
				
				if packet_in(40) = '1' then
					-- a read return packet
					rd_data <= packet_in(35 downto 28);
					rd_return <= '1';
				else 
					rd_return <= '0';
				end if;
			end if;
		end if;
	end process;


end Behavioral;

