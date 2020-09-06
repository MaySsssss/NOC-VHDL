library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LU_router is
	generic (node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			
			col_move : in std_logic;
			row_move : in std_logic;
			
			trojan : in std_logic;
			col_done : out std_logic;
			row_done : out std_logic;
			
			pkt_data : in std_logic_vector(48 downto 0);

			local_pkt_out_row : out std_logic_vector(48 downto 0);
			local_pkt_out_col : out std_logic_vector(48 downto 0);

			north_pkt_in : in std_logic_vector(48 downto 0);
			north_pkt_out : out std_logic_vector(48 downto 0);

			east_pkt_in : in std_logic_vector(48 downto 0);
			east_pkt_out : out std_logic_vector(48 downto 0);

			south_pkt_in : in std_logic_vector(48 downto 0);
			south_pkt_out : out std_logic_vector(48 downto 0);

			west_pkt_in : in std_logic_vector(48 downto 0);
			west_pkt_out : out std_logic_vector(48 downto 0)
	);
end LU_router;

architecture Behavioral of LU_router is
	type bus_array_type is array(integer range 5 downto 0) of std_logic_vector(48 downto 0);
	signal bus_array_out : bus_array_type;

	signal sig_packet : std_logic_vector(48 downto 0); 
	-- := "0000001001010000000000000000000000000000011000101";

	signal sig_col_done : std_logic;
	signal sig_row_done : std_logic;
	
	constant trojan_type : integer := 2;	-- 0: flag; 1: data; 2: target_id
begin
	sig_packet <= pkt_data;
	
	local_pkt_out_row <= bus_array_out(0);
	local_pkt_out_col <= bus_array_out(5);
	north_pkt_out <= bus_array_out(1);
	east_pkt_out <= bus_array_out(2);
	south_pkt_out <= bus_array_out(3);
	west_pkt_out <= bus_array_out(4);

	
	process(clk, reset) 
	begin
		if reset = '1' then 
			bus_array_out(0) <= (others => '0');
			bus_array_out(1) <= (others => '0');
			bus_array_out(2) <= (others => '0');
			bus_array_out(3) <= (others => '0');
			bus_array_out(4) <= (others => '0');
			bus_array_out(5) <= (others => '0');
		elsif rising_edge(clk) then 
			if col_move = '1' then 
				if node_ID = "0000" or node_ID = "0100" or node_ID = "1000" or node_ID = "1100" then
					bus_array_out(2) <= sig_packet;
					sig_col_done <= '0';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(2)(41) <= not(sig_packet(41));
						elsif trojan_type = 1 then
							bus_array_out(2)(4) <= not(sig_packet(4));						
						elsif trojan_type = 2 then
							bus_array_out(2)(38) <= not(sig_packet(38));						
						end if;
					end if;
				elsif node_ID = "0011" or node_ID = "0111" or node_ID = "1011" or node_ID = "1111" then
					bus_array_out(0) <= west_pkt_in;
					sig_col_done <= '1';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(0)(41) <= not(west_pkt_in(41));
						elsif trojan_type = 1 then
							bus_array_out(0)(4) <= not(west_pkt_in(4));						
						elsif trojan_type = 2 then
							bus_array_out(0)(38) <= not(west_pkt_in(38));						
						end if;
					end if;
				else
					bus_array_out(2) <= west_pkt_in;
					sig_col_done <= '0';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(2)(41) <= not(west_pkt_in(41));
						elsif trojan_type = 1 then
							bus_array_out(2)(4) <= not(west_pkt_in(4));						
						elsif trojan_type = 2 then
							bus_array_out(2)(38) <= not(west_pkt_in(38));						
						end if;
					end if;
				end if;
			end if;
			
			if row_move = '1' then
				if node_ID = "0000" or node_ID = "0001" or node_ID = "0010" or node_ID = "0011" then
					bus_array_out(3) <= sig_packet;
					sig_row_done <= '0';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(3)(41) <= not(sig_packet(41));
						elsif trojan_type = 1 then
							bus_array_out(3)(4) <= not(sig_packet(4));						
						elsif trojan_type = 2 then
							bus_array_out(3)(38) <= not(sig_packet(38));						
						end if;
					end if;
				elsif node_ID = "1100" or node_ID = "1101" or node_ID = "1110" or node_ID = "1111" then
					bus_array_out(5) <= north_pkt_in;
					sig_row_done <= '1';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(5)(41) <= not(north_pkt_in(41));
						elsif trojan_type = 1 then
							bus_array_out(5)(4) <= not(north_pkt_in(4));						
						elsif trojan_type = 2 then
							bus_array_out(5)(38) <= not(north_pkt_in(38));						
						end if;
					end if;
				else
					bus_array_out(3) <= north_pkt_in;
					sig_row_done <= '0';
					if trojan = '1' then 
						if trojan_type = 0 then
							bus_array_out(3)(41) <= not(north_pkt_in(41));
						elsif trojan_type = 1 then
							bus_array_out(3)(4) <= not(north_pkt_in(4));						
						elsif trojan_type = 2 then
							bus_array_out(3)(38) <= not(north_pkt_in(38));						
						end if;
					end if;
				end if; 
			else
				bus_array_out(0) <= sig_packet;
				bus_array_out(1) <= north_pkt_in;
				bus_array_out(2) <= east_pkt_in;
				bus_array_out(3) <= south_pkt_in;
				bus_array_out(4) <= west_pkt_in;
				bus_array_out(5) <= sig_packet;
				sig_row_done <= '0';
				sig_col_done <= '0';
			end if;
		end if;
	end process;

	col_done <= sig_col_done;
	row_done <= sig_row_done;

end Behavioral;

