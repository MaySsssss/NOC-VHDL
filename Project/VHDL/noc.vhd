library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity noc is
    Port ( clk 					: in  STD_LOGIC;
           reset 				: in  STD_LOGIC;
		   network				: out std_logic_vector(23 downto 0)
		   );
end noc;

architecture Behavioral of noc is
	component dmu is
    Port ( clk 					: in  STD_LOGIC;
           reset 				: in  STD_LOGIC;
		   trojan_detect	: out std_logic_vector(15 downto 0);
		   trojan_id			: out std_logic_vector(3 downto 0);
		   network				: out std_logic_vector(23 downto 0)
	);
	end component;
	
	component localization_unit is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           trojan_id : out  STD_LOGIC_VECTOR (3 downto 0)
	);
	end component;
		
	signal trojan_detect : std_logic_vector(15 downto 0);
	
	signal trojan_activated : std_logic := '0';
	signal trojan_id_LU : std_logic_vector(3 downto 0);
	
	signal sig_network : std_logic_vector(23 downto 0);	
	
begin
	dmu_inst : dmu 
    Port map ( clk 				=> clk,
			   reset 				=> reset,
			   trojan_detect	=> trojan_detect,
			   trojan_id			=> trojan_id_LU,
			   network				=> network 
	);
	
	
	countloop : process(clk, reset) 
	begin
		if reset = '1' then 
			trojan_activated <= '0';
		elsif rising_edge(clk) then
			if trojan_detect = "0000000000000000" then
				trojan_activated <= '0';
				report "Trojan node id " & integer'image(to_integer(unsigned(trojan_id)));
			else 
				trojan_activated <= '1';
				report "No trojan detect";
			end if;
		end if;
	end process; 

end Behavioral;

