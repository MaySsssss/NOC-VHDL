----------------------------------------------------------------------------------
-- Key value for every node 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_table is
    Port ( k0 : out  STD_LOGIC_VECTOR (7 downto 0);
           k1 : out  STD_LOGIC_VECTOR (7 downto 0);
           k2 : out  STD_LOGIC_VECTOR (7 downto 0);
           k3 : out  STD_LOGIC_VECTOR (7 downto 0);
           k4 : out  STD_LOGIC_VECTOR (7 downto 0);
           k5 : out  STD_LOGIC_VECTOR (7 downto 0);
           k6 : out  STD_LOGIC_VECTOR (7 downto 0);
           k7 : out  STD_LOGIC_VECTOR (7 downto 0);
           k8 : out  STD_LOGIC_VECTOR (7 downto 0);
           k9 : out  STD_LOGIC_VECTOR (7 downto 0);
           k10 : out  STD_LOGIC_VECTOR (7 downto 0);
           k11 : out  STD_LOGIC_VECTOR (7 downto 0);
           k12 : out  STD_LOGIC_VECTOR (7 downto 0);
           k13 : out  STD_LOGIC_VECTOR (7 downto 0);
           k14 : out  STD_LOGIC_VECTOR (7 downto 0);
           k15 : out  STD_LOGIC_VECTOR (7 downto 0));
end key_table;

architecture Behavioral of key_table is

begin
	key_0 : k0		<= x"1C";
	key_1 : k1			<= x"47";
	key_2 : k2		<= x"C8";
	key_3 : k3		<= x"01";
	key_4 : k4		<= x"AC";
	key_5 : k5		<= x"78";
	key_6 : k6		<= x"11";
	key_7 : k7		<= x"5C";
	key_8 : k8		<= x"D9";
	key_9 : k9		<= x"09";
	key_10 : k10		<= x"85";
	key_11 : k11		<= x"55";
	key_12 : k12		<= x"9A";
	key_13 : k13		<= x"5C";
	key_14 : k14		<= x"3F";
	key_15 : k15		<= x"E7";

end Behavioral;

