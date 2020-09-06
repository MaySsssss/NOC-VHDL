----------------------------------------------------------------------------------
-- interface betwwen a slave device and a rounter
-- decodes a packet coming from the router
-- mainly deals with the read_return packet 
-- makes the writer and read packets
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity slave is
	generic (node_ID : STD_LOGIC_VECTOR(3 DOWNTO 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  packet_in : in std_logic_vector(48 downto 0);
			  packet_out : out std_logic_vector(48 downto 0);
			  
			  addr : out std_logic_vector(31 downto 0);
			  
			  rounter_not_rdy : in std_logic;
			  na_not_rdy : out std_logic;
			  slave_not_rdy : in std_logic;
			  
			  rd_return : in std_logic;
			  rd_data : in std_logic_vector(7 downto 0);
			  
			  wr : out std_logic;
			  wr_data : out std_logic_vector(7 downto 0);
			  
			  rd_request : out std_logic );
end slave;

architecture Behavioral of slave is
	signal y_neg : std_logic;
	signal x_neg : std_logic;
	signal y_count : std_logic_vector(1 downto 0);
	signal X_count : std_logic_vector(1 downto 0);
	signal y_diff : integer;
	signal x_diff : integer;
	signal rd_dest : std_logic_vector(3 downto 0); 
begin
	y_diff <= to_integer(unsigned(rd_dest(3 downto 2))) - to_integer(unsigned(node_ID(3 DOWNTO 2)));
	x_diff <= to_integer(unsigned(rd_dest(1 downto 0))) - to_integer(unsigned(node_ID(1 DOWNTO 0)));
	
	y_neg <= '1' when TO_INTEGER(unsigned((rd_dest(3 downto 2)))) < TO_INTEGER(unsigned(node_ID(3 downto 2))) else '0'; --check direction
	y_count <= std_logic_vector(TO_UNSIGNED((-y_diff), 2)) when y_neg = '1' else std_logic_vector(TO_UNSIGNED((y_diff), 2));
	x_neg <= '1' when TO_INTEGER(unsigned(rd_dest(1 downto 0))) < TO_INTEGER(unsigned(node_ID(1 downto 0))) else '0';
	x_count <= std_logic_vector(TO_UNSIGNED((-x_diff), 2)) when x_neg = '1' else std_logic_vector(TO_UNSIGNED((x_diff), 2));

	
	process(clk, reset) 
	begin
		if rising_edge(clk) then
			if slave_not_rdy = '1' then
				na_not_rdy <= '1'; 
			else 
				na_not_rdy <= '0';
				if packet_in(41) = '1' then
					-- read request packet
					addr <= packet_in(39 downto 8);
					rd_request <= '1';
					wr <= '0';
					wr_data <= (others => '0');
					rd_dest <= packet_in(7 downto 4);
				elsif packet_in(42) = '1' then 
					-- write packet
					addr <= packet_in(39 downto 8);
					rd_request <= '0';
					wr <= '1';
					wr_data <= packet_in(7 downto 0);
				else 
					addr <= (others => '0');
					rd_request <= '0';
					wr <= '0';
					wr_data <= (others => '0');
				end if;
				
				if rd_return = '1' then
					-- a read return packet
					packet_out(48 downto 43) <= y_neg & y_count & x_neg & x_count;
					packet_out(42 downto 40) <= "001";
					packet_out(39 downto 36) <= rd_dest;
					packet_out(7 downto 0) <= rd_data;
				else 
					packet_out(48 downto 0) <= (others => '0');
				end if;
			end if;
		end if;
	end process;

end Behavioral;

