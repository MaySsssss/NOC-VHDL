library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trojan_localization is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
		   done : in std_logic;
           row : in  STD_LOGIC_VECTOR (3 downto 0);
           col : in  STD_LOGIC_VECTOR (3 downto 0);
		   trojan_found : out std_logic;
           trojan : out  STD_LOGIC_VECTOR (3 downto 0));
end trojan_localization;

architecture Behavioral of trojan_localization is
	signal sig_y : std_logic_vector(1 downto 0);
	signal sig_x : std_logic_vector(1 downto 0);
begin
	process(clk, reset)
	begin
		if reset = '1' then
			trojan_found <= '0';
		elsif rising_edge(clk) then
			if done = '1' then
				if row(3) = '1' then
					sig_y <= "11";
				elsif row(2) = '1' then
					sig_y <= "10";
				elsif row(1) = '1' then
					sig_y <= "01";
				elsif row(0) = '1' then
					sig_y <= "00";
				end if;
				
				if col(3) = '1' then
					sig_x <= "11";
				elsif col(2) = '1' then
					sig_x <= "10";
				elsif col(1) = '1' then
					sig_x <= "01";
				elsif col(0) = '1' then
					sig_x <= "00";
				end if;
				
				if row = "0000" or col = "0000" then
					trojan_found <= '0';
				else
					trojan_found <= '1';
				end if;
			end if;
		end if;
	end process;
	
	trojan <= sig_y & sig_x;
	
end Behavioral;

