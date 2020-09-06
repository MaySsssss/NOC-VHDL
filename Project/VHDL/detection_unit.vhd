----------------------------------------------------------------------------------
-- Detection Unit
-- Has the same network as before 
-- Contains its reset signal - sig_done
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
  
entity detection_unit is
    Port ( clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			trojan_location : in std_logic_vector(15 downto 0)
	);
end detection_unit;

architecture Behavioral of detection_unit is
	component worm is
    Port ( clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			row_cout : out std_logic_vector(3 downto 0);
			col_cout : out std_logic_vector(3 downto 0);
			trojan_location : in std_logic_vector(15 downto 0);
			trojan_id : out  STD_LOGIC_VECTOR (3 downto 0);
			trojan_found : out std_logic
	);
	end component;

	signal sig_trojan_location : std_logic_vector(15 downto 0);
	signal trojan_id : std_logic_vector(3 downto 0);
	signal trojan_pos : std_logic_vector(3 downto 0);
	
	signal sig_done : std_logic;
	
	signal catch_res : std_logic;
	
	signal x0 : integer := 0;
	signal x1 : integer := 0;
	signal x2 : integer := 0;
	signal x3 : integer := 0;
	
	signal y0 : integer := 0;
	signal y1 : integer := 0;
	signal y2 : integer := 0;
	signal y3 : integer := 0;
	
	signal sig_row_count : std_logic_vector(3 downto 0);
	signal sig_col_count : std_logic_vector(3 downto 0);
	
	signal sig_stop : std_logic;
	signal sig_trojan_found : std_logic;
begin
	-- trojan location 
	sig_trojan_location <= trojan_location;

	-- catch the tampered packet
	LU_inst : worm 
	Port map ( clk			=> clk,
					reset 		=> sig_done,
					row_cout	=> sig_row_count,
					col_cout 	=> sig_col_count,
					trojan_location	=> trojan_location,
					trojan_id	=> trojan_id,
					trojan_found 	=> sig_trojan_found
	);

	-- new clock  and reset
	process(clk, reset)
		variable clk_count : unsigned(31 downto 0);
	begin
		if reset = '1' then
			clk_count := (others => '0');
			sig_done <= '0';
			catch_res <= '0';
		elsif rising_edge(clk) then
			if clk_count = 0 then
				if sig_stop = '1' then
					sig_done <= '0';
				else
					sig_done <= '1';
				end if;
				clk_count := clk_count + 1;
			elsif clk_count = 1 then
				sig_done <= '0';
				clk_count := clk_count + 1;
			elsif clk_count = 11 then
				if sig_stop = '1' then
					catch_res <= '0';
				else
					catch_res <= '1';
				end if;
				clk_count := clk_count + 1;
			elsif clk_count = 12 then
				catch_res <= '0';
				clk_count := (others => '0');
			else
				clk_count := clk_count + 1;
			end if;
		end if;	
	end process;
	
	-- waiting time
	process(clk, reset)
		variable counter : unsigned(31 downto 0);
	begin
		if reset = '1' then
			sig_stop <= '0';
			counter := (others => '0');
		elsif rising_edge(clk) then
			if counter = 60 then	
				sig_stop <= '1';
			else
				sig_stop <= '0';
				counter := counter + 1;
			end if;
		end if;
	end process;
	
	-- catching the result 
	process(clk)
	begin
		if rising_edge(clk) then
			if sig_stop = '0' then
				if catch_res = '1' and sig_trojan_found = '1' then 
					if sig_col_count(0) = '1' then
						x0 <= x0+1;
					elsif sig_col_count(1) = '1' then
						x1 <= x1+1;
					elsif sig_col_count(2) = '1' then
						x2 <= x2+1;
					elsif sig_col_count(3) = '1' then
						x3 <= x3+1;
					end if;
					
					if sig_row_count(0) = '1' then
						y0 <= y0+1;
					elsif sig_row_count(1) = '1' then 
						y1 <= y1+1;
					elsif sig_row_count(2) = '1' then
						y2 <= y2+1;
					elsif sig_row_count(3) = '1' then
						y3 <= y3+1;
					end if;
				else 
					trojan_pos <= trojan_pos;
				end if;
				
				if x0 > x1 and x0 > x2 and x0 > x3 then
					trojan_pos(1 downto 0) <= "00";
				elsif x1 > x0 and x1 > x2 and x1 > x3 then
					trojan_pos(1 downto 0) <= "01";
				elsif x2 > x0 and x2 > x1 and x2 > x3 then
					trojan_pos(1 downto 0) <= "10";
				elsif x3 > x0 and x3 > x1 and x3 > x2 then
					trojan_pos(1 downto 0) <= "11";				
				end if;
				
				if y0 > y1 and y0 > y2 and y0 > y3 then
					trojan_pos(3 downto 2) <= "00";
				elsif y1 > y0 and y1 > y2 and y1 > y3 then
					trojan_pos(3 downto 2) <= "01";
				elsif y2 > y0 and y2 > y1 and y2 > y3 then
					trojan_pos(3 downto 2) <= "10";
				elsif y3 > y0 and y3 > y1 and y3 > y2 then
					trojan_pos(3 downto 2) <= "11";				
				end if;
			end if;
		end if;
	end process;
	
end Behavioral;
 
