----------------------------------------------------------------------------------
-- Example network
-- To determine what the packet will be create
-- case 1: 			-- from 0000 to 0100 in addr x"0000000"
-- case 2: 			-- from 0101 to 0001 in addr x"0011000"
-- case 3: 			-- write packet from 1001 to 0011
-- case 4: 			-- from 0110 to 1111
-- case 5: 			-- from 1110 to 0010
-- case 6: 			-- from 1100 to 0011
-- case 7: 			-- from 1001 to 1011
-- case 8: 			-- from 0010 to 1101 
-- case 9: 			-- from 1000 to 0111
-- case 10: 			-- from 1010 to 0000

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc is
    Generic (
				node_ID : STD_LOGIC_VECTOR(3 DOWNTO 0));
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  wr : out STD_LOGIC;
			  wr_data : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			  
			  rd_request : out STD_LOGIC;
			  
			  dest_addr : out STD_LOGIC_VECTOR(31 DOWNTO 0);
			  
			  rd_return : in STD_LOGIC;
			  rd_data : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			  
			  not_ready : in STD_LOGIC);
end proc;

architecture Behavioral of proc is
	signal counter : unsigned(31 downto 0);
	signal targetid : std_logic_vector(3 downto 0);
	signal addr : std_logic_vector(27 downto 0);
begin

	process(clk, reset) 
	begin
		if reset = '1' then
			counter <= (others => '0');
			wr <= '0';
			rd_request <= '0';
		elsif rising_edge(clk) then
			-- write packet from 0000 to 0100 in addr x"0000000"
			wr <= '1';
			rd_request <= '0';
			targetid <= "1110";
			wr_data <= "01110011"; 
			addr <= x"0000000";
		end if;
	end process;
	
	dest_addr <= targetid & addr;

end Behavioral;

