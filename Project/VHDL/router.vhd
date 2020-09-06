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

entity router is
	generic (node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  trojan	: in std_logic;

			  busy_in : in std_logic_vector(4 downto 0);
			  busy_out : out std_logic_vector(4 downto 0);
			  
			  local_pkt_in : in std_logic_vector(48 downto 0);
			  local_pkt_out : out std_logic_vector(48 downto 0);
			  
			  north_pkt_in : in std_logic_vector(48 downto 0);
			  north_pkt_out : out std_logic_vector(48 downto 0);
			  
			  east_pkt_in : in std_logic_vector(48 downto 0);
			  east_pkt_out : out std_logic_vector(48 downto 0);
			  
			  south_pkt_in : in std_logic_vector(48 downto 0);
			  south_pkt_out : out std_logic_vector(48 downto 0);
			  
			  west_pkt_in : in std_logic_vector(48 downto 0);
			  west_pkt_out : out std_logic_vector(48 downto 0)
			  );
end router;

architecture Behavioral of router is
	-- local: 0; north: 1; east: 2; south: 3; west: 4
	type bus_array_type is array(integer range 4 downto 0) of std_logic_vector(48 downto 0);
	signal bus_boundary_in : bus_array_type;
	signal bus_array_out : bus_array_type;
	
	signal buf_level1 : bus_array_type;

	signal buf_used : std_logic_vector(4 downto 0) := "00000";
	
	constant trojan_type : integer := 2;	-- 0: flag; 1: data; 2: target_id
	
begin
	bus_boundary_in(0) <= local_pkt_in;
	bus_boundary_in(1) <= north_pkt_in;
	bus_boundary_in(2) <= east_pkt_in;
	bus_boundary_in(3) <= south_pkt_in;
	bus_boundary_in(4) <= west_pkt_in;
	
	local_pkt_out <= bus_array_out(0);
	north_pkt_out <= bus_array_out(1);
	east_pkt_out <= bus_array_out(2);
	south_pkt_out <= bus_array_out(3);
	west_pkt_out <= bus_array_out(4);
	
	busy_out <= buf_used;
	
	process(clk, reset)
		variable is_collision 	: std_logic_vector(4 downto 0); 
		type direction_type is array(integer range 4 downto 0) of natural range 0 to 6;
		variable direction : direction_type; 
		
		type bus_array_type is array(integer range 4 downto 0) of std_logic_vector(48 downto 0);
		variable bus_array_in : bus_array_type;
	
	begin
		if reset = '1' then
				bus_array_out(0) <= (others => '0' );
				bus_array_out(1) <= (others => '0' );
				bus_array_out(2) <= (others => '0' );
				bus_array_out(3) <= (others => '0' );
				bus_array_out(4) <= (others => '0' );
				
				buf_used <= (others => '0');
				
				buf_level1(0) <= (others => '0' );
				buf_level1(1) <= (others => '0' );
				buf_level1(2) <= (others => '0' );
				buf_level1(3) <= (others => '0' );
				buf_level1(4) <= (others => '0' );
				
		elsif rising_edge(clk) then
				for i in 0 to 4 loop
				
					if buf_used(i) = '1' then
						bus_array_in(i) := buf_level1(i);
					else
						bus_array_in(i) := bus_boundary_in(i);
					end if;

					if  bus_array_in(i)(42) = '0' and bus_array_in(i)(41) = '0' and bus_array_in(i)(40) = '0' then
							direction(i) := 6;		-- null
					elsif bus_array_in(i)(47 downto 46) /= "00" then
						if bus_array_in(i)(48) = '1' then
							direction(i) := 1;		-- north
						else
							direction(i) := 3;		-- south
						end if;
					elsif bus_array_in(i)(44 downto 43) /= "00" then
						if bus_array_in(i)(45) = '1' then
							direction(i) := 4;		-- west
						else
							direction(i) := 2;		-- east
						end if;
					else
						direction(i) := 0;			-- local
					end if;
					
					if  bus_array_in(i)(42) = '1' or bus_array_in(i)(41) = '1' or bus_array_in(i)(40) = '1' then
					
						is_collision(i) := '0'; --flag
						if busy_in(direction(i)) = '1' then 
							is_collision(i) := '1';
						elsif( i > 0 ) then
								--check bus_array_in's with higher priority
								for j in 0 to i-1 loop 
									if(direction(i) = direction(j)) then --this does not include if they're both empty due to outer if statement above
										is_collision(i) := '1';
									end if;
								end loop;
						end if;
						
--						if buf_used(i) = '1' and is_collision(i) = '1' then 
--							buf_level1(i) <= buf_level1(i);
--							buf_used(i) <= '1';
--						elsif (bus_boundary_in(i)(42) = '1' or bus_boundary_in(i)(41) = '1' or bus_boundary_in(i)(40) = '1') 
--									and buf_used(i) = '1' and is_collision(i) = '0' then 
--							buf_level1(i) <= bus_boundary_in(i);
--							buf_used(i) <= '1';
--						elsif (bus_boundary_in(i)(42) = '1' or bus_boundary_in(i)(41) = '1' or bus_boundary_in(i)(40) = '1') 
--									and buf_used(i) = '0' and is_collision(i) = '1' then 
--							buf_level1(i) <= bus_boundary_in(i);
--							buf_used(i) <= '1';
--						else 
--							buf_level1(i) <= (others => '0');
--							buf_used(i) <= '0';
--						end if;
						
						if is_collision(i) = '0' then 
							if bus_array_in(i)(47 downto 46) /= "00" then
								if bus_array_in(i)(48) = '1' then
									bus_array_out(1) <= bus_array_in(i)(48) & std_logic_vector(unsigned(bus_array_in(i)(47 downto 46))-1) & bus_array_in(i)(45) & bus_array_in(i)(44 downto 43) & bus_array_in(i)(42 downto 0);
									buf_used(1) <= '1';
									if trojan = '1' then
										-- modify flags
										if trojan_type = 0 then
											bus_array_out(1)(41) <= not(bus_array_in(i)(41));
										elsif trojan_type = 1 then
										-- modify data 
											bus_array_out(1)(0) <= not(bus_array_in(i)(0));
										elsif trojan_type = 2 then
										-- modify targetid
											bus_array_out(1)(36) <= not(bus_array_out(i)(36)); 
										end if;
									end if;
								else
									bus_array_out(3) <= bus_array_in(i)(48) & std_logic_vector(unsigned(bus_array_in(i)(47 downto 46))-1) & bus_array_in(i)(45) & bus_array_in(i)(44 downto 43) & bus_array_in(i)(42 downto 0);
									buf_used(3) <= '1';
									if trojan = '1' then
										if trojan_type = 0 then
										-- modify flags
											bus_array_out(3)(41) <= not(bus_array_in(i)(41));
										elsif trojan_type = 1 then
										-- modify data 
											bus_array_out(3)(0) <= not(bus_array_in(i)(0));
										elsif trojan_type = 2 then
										-- modify targetid
											bus_array_out(3)(36) <= not(bus_array_out(i)(36)); 
										end if;
									end if;
								end if;
							elsif bus_array_in(i)(44 downto 43) /= "00" then
								if bus_array_in(i)(45) = '1' then
									bus_array_out(4) <= bus_array_in(i)(48) & bus_array_in(i)(47 downto 46) &  bus_array_in(i)(45) & std_logic_vector(unsigned(bus_array_in(i)(44 downto 43))-1) & bus_array_in(i)(42 downto 0);
									buf_used(4) <= '1';
									if trojan = '1' then
										if trojan_type = 0 then
										-- modify flags
											bus_array_out(4)(41) <= not(bus_array_in(i)(41));
										elsif trojan_type = 1 then
										-- modify data 
											bus_array_out(4)(0) <= not(bus_array_in(i)(0));
										elsif trojan_type = 2 then
										-- modify targetid
											bus_array_out(4)(36) <= not(bus_array_out(i)(36)); 
										end if;
									end if;
								else
									bus_array_out(2) <= bus_array_in(i)(48) & bus_array_in(i)(47 downto 46) &  bus_array_in(i)(45) & std_logic_vector(unsigned(bus_array_in(i)(44 downto 43))-1) & bus_array_in(i)(42 downto 0);
									buf_used(2) <= '1';
									if trojan = '1' then
										if trojan_type = 0 then
										-- modify flags
											bus_array_out(2)(41) <= not(bus_array_in(i)(41));
										elsif trojan_type = 1 then
										-- modify data 
											bus_array_out(2)(0) <= not(bus_array_in(i)(0));
										elsif trojan_type = 2 then
										-- modify targetid
											bus_array_out(2)(36) <= not(bus_array_out(i)(36)); 
										end if;										
									end if;
								end if;
							else
								bus_array_out(0) <= bus_array_in(i);
								buf_used(0) <= '1';
								if trojan = '1' then
									if trojan_type = 0 then
									-- modify flags
										bus_array_out(0)(41) <= not(bus_array_in(i)(41));
									elsif trojan_type = 1 then
										-- modify data 
										bus_array_out(0)(0) <= not(bus_array_in(i)(0));
									elsif trojan_type = 2 then
										-- modify targetid
										bus_array_out(0)(36) <= not(bus_array_out(i)(36)); 
									end if;
								end if;
							end if;
						end if;
					end if;
				end loop;
		end if;
	end process;

	
end Behavioral;

