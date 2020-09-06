library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compare_local_pkt is
	generic (node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           
		   row_out : in  STD_LOGIC_VECTOR (48 downto 0);
           col_out : in  STD_LOGIC_VECTOR (48 downto 0);
		   
           local_row_pkt_out : out  STD_LOGIC_VECTOR (48 downto 0);
           local_col_pkt_out : out  STD_LOGIC_VECTOR (48 downto 0);
           
		   row_found : out  STD_LOGIC;
           col_found : out  STD_LOGIC;
		   
		   row_done : out STD_LOGIC;
		   col_done : out STD_LOGIC;
           
		   key_in : in std_logic_vector(7 downto 0);
		   tag_seg : in  STD_LOGIC_VECTOR (7 downto 0));
end compare_local_pkt;

architecture Behavioral of compare_local_pkt is
	signal sig_row_tag : std_logic_vector(7 downto 0);
	signal sig_col_tag : std_logic_vector(7 downto 0);
	
	signal sig_row_found : std_logic;
	signal sig_col_found : std_logic;
begin
	sig_row_tag <= std_logic_vector(1 + to_unsigned((to_integer(unsigned(row_out(42 downto 40))) + to_integer(unsigned(row_out(39 downto 36)))  + to_integer(unsigned(row_out(7 downto 0))) + to_integer(unsigned(key_in)) + to_integer(unsigned(node_ID))), 8));
	local_row_pkt_out <= row_out when sig_row_tag = tag_seg else (others => '0');
--	row_found <= '0' when sig_row_tag = tag_seg else '1';
	row_found <= sig_row_found;

	sig_col_tag <= std_logic_vector(1 + to_unsigned((to_integer(unsigned(col_out(42 downto 40))) + to_integer(unsigned(col_out(39 downto 36))) + to_integer(unsigned(col_out(7 downto 0))) + to_integer(unsigned(key_in)) + to_integer(unsigned(node_ID))), 8));
	local_col_pkt_out <= col_out when sig_col_tag = tag_seg else (others => '0');
--	col_found <= '0' when sig_col_tag = tag_seg else '1';
	col_found <= sig_col_found;
	
	process(clk, reset, tag_seg) 
	begin
		if reset = '1' then
			sig_row_found <= '0';
			sig_col_found <= '0';
		elsif rising_edge(clk) then
			if node_ID = "1100" or node_ID = "1101" or node_ID = "1110" or node_ID = "1111" then	-- 15, 14, 13, 12
				if sig_col_tag = tag_seg then
					sig_col_found <= '0';
				else 
					sig_col_found <= '1';
				end if;
			else 
				sig_col_found <= '0';
			end if;
			
			if node_ID = "0011" or node_ID = "0111" or node_ID = "1011" or node_ID = "1111" then -- 15, 11, 7, 3
				if sig_row_tag = tag_seg then
					sig_row_found <= '0';
				else 
					sig_row_found <= '1';
				end if;
			else
				sig_row_found <= '0';
			end if;

		end if;
	end process;
	
end Behavioral;

