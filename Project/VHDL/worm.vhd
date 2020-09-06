library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity worm is
    Port ( clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			row_cout : out std_logic_vector(3 downto 0);
			col_cout : out std_logic_vector(3 downto 0);
			trojan_location : in std_logic_vector(15 downto 0);
			trojan_id : out std_logic_vector(3 downto 0);
			trojan_found : out std_logic
	);
end worm;

architecture Behavioral of worm is
	component worm_node is
	generic (node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
		   
			trojan : in std_logic;
			col_done : out std_logic;
			row_done : out std_logic;
			
			row_found : out std_logic;
			col_found : out std_logic;

			pkt_data : in std_logic_vector(48 downto 0);

			north_pkt_in : in std_logic_vector(48 downto 0);
			north_pkt_out : out std_logic_vector(48 downto 0);

			east_pkt_in : in std_logic_vector(48 downto 0);
			east_pkt_out : out std_logic_vector(48 downto 0);

			south_pkt_in : in std_logic_vector(48 downto 0);
			south_pkt_out : out std_logic_vector(48 downto 0);

			west_pkt_in : in std_logic_vector(48 downto 0);
			west_pkt_out : out std_logic_vector(48 downto 0);
			  
			tag_seg : in std_logic_vector(7 downto 0);
			key_in : in std_logic_vector(7 downto 0)

	);
	end component;
	
	component  trojan_localization is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
		   done : in std_logic;
           row : in  STD_LOGIC_VECTOR (3 downto 0);
           col : in  STD_LOGIC_VECTOR (3 downto 0);
		   trojan_found : out std_logic;
           trojan : out  STD_LOGIC_VECTOR (3 downto 0)
	);
	end component;
	
	component key_table is
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
	end component;
	
	component lfsr is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           pkt_in : in  STD_LOGIC_VECTOR (48 downto 0);
           pkt_out : out  STD_LOGIC_VECTOR (48 downto 0)
	);
	end component;
	
	signal sig_packet : std_logic_vector(48 downto 0) := "0000001001010000000000000000000000000000011000101";
	signal sig_packet_out : std_logic_vector(48 downto 0); -- := "0000001001010000000000000000000000000000011000101";

	type pkt_array_type is array(integer range 3 downto 0, integer range 3 downto 0) of std_logic_vector(48 downto 0);
	signal north_pkt_in 	: pkt_array_type;
	signal north_pkt_out : pkt_array_type;
	signal east_pkt_in 	: pkt_array_type;
	signal east_pkt_out 	: pkt_array_type;
	signal south_pkt_in 	: pkt_array_type;
	signal south_pkt_out	: pkt_array_type;
	signal west_pkt_in 	: pkt_array_type;
	signal west_pkt_out 	: pkt_array_type;

	type tag_array_type is array(integer range 15 downto 0) of std_logic_vector(7 downto 0);
	signal tag_array : tag_array_type;
	signal key_array : tag_array_type;
	
	signal sig_flagdata : std_logic_vector(7 downto 0);
	
	signal sig_row_found : std_logic_vector(15 downto 0);
	signal sig_col_found : std_logic_vector(15 downto 0);
	
	signal sig_row_done : std_logic_vector(15 downto 0);
	signal sig_col_done : std_logic_vector(15 downto 0);
	
	signal sig_done : std_logic;
	signal sig_trojan_found : std_logic;

begin
--================================================
	worm_node0 : worm_node
	generic map(node_ID	=> "0000"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(0),
				col_done		=> sig_col_done(0),
				row_done 		=> sig_row_done(0),

				
				row_found 		=> sig_row_found(0),
				col_found 		=> sig_col_found(0),

				pkt_data			=> sig_packet,
				
				north_pkt_in 	=> north_pkt_in(0,0),
				north_pkt_out 	=> north_pkt_out(0,0),

				east_pkt_in 	=> east_pkt_in(0,0),
				east_pkt_out 	=> east_pkt_out(0,0),

				south_pkt_in 	=> south_pkt_in(0,0),
				south_pkt_out 	=> south_pkt_out(0,0),

				west_pkt_in 	=> west_pkt_in(0,0),
				west_pkt_out 	=> west_pkt_out(0,0), 
				
				tag_seg		=> tag_array(0),
				key_in		=> key_array(0)

	);

	worm_node1 : worm_node
	generic map(node_ID	=> "0001"	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(1),	 
				col_done		=> sig_col_done(1),
				row_done 		=> sig_row_done(1),

				row_found 		=> sig_row_found(1),
				col_found 		=> sig_col_found(1),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(1,0),
				north_pkt_out 	=> north_pkt_out(1,0),

				east_pkt_in 	=> east_pkt_in(1,0),
				east_pkt_out 	=> east_pkt_out(1,0),

				south_pkt_in 	=> south_pkt_in(1,0),
				south_pkt_out 	=> south_pkt_out(1,0),

				west_pkt_in 	=> west_pkt_in(1,0),
				west_pkt_out 	=> west_pkt_out(1,0), 
				
				tag_seg		=> tag_array(1),
				key_in		=> key_array(1)

	);
	
	worm_node2 :worm_node
	generic map(node_ID	=> "0010"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(2),
				col_done		=> sig_col_done(2),
				row_done 		=> sig_row_done(2),

				row_found 		=> sig_row_found(2),
				col_found 		=> sig_col_found(2),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(2,0),
				north_pkt_out 	=> north_pkt_out(2,0),

				east_pkt_in 	=> east_pkt_in(2,0),
				east_pkt_out 	=> east_pkt_out(2,0),

				south_pkt_in 	=> south_pkt_in(2,0),
				south_pkt_out 	=> south_pkt_out(2,0),

				west_pkt_in 	=> west_pkt_in(2,0),
				west_pkt_out 	=> west_pkt_out(2,0), 
				
				tag_seg		=> tag_array(2),
				key_in		=> key_array(2)

	);
	
	worm_node3 :worm_node
	generic map(node_ID	=> "0011"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(3),
				col_done		=> sig_col_done(3),
				row_done 		=> sig_row_done(3),

				row_found 		=> sig_row_found(3),
				col_found 		=> sig_col_found(3),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(3,0),
				north_pkt_out 	=> north_pkt_out(3,0),

				east_pkt_in 	=> east_pkt_in(3,0),
				east_pkt_out 	=> east_pkt_out(3,0),

				south_pkt_in 	=> south_pkt_in(3,0),
				south_pkt_out 	=> south_pkt_out(3,0),

				west_pkt_in 	=> west_pkt_in(3,0),
				west_pkt_out 	=> west_pkt_out(3,0), 
				
				tag_seg		=> tag_array(3),
				key_in		=> key_array(3)

	);
	
	worm_node4 :worm_node
	generic map(node_ID	=> "0100"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(4),
				col_done		=> sig_col_done(4),
				row_done 		=> sig_row_done(4),

				row_found 		=> sig_row_found(4),
				col_found 		=> sig_col_found(4),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(0,1),
				north_pkt_out 	=> north_pkt_out(0,1),

				east_pkt_in 	=> east_pkt_in(0,1),
				east_pkt_out 	=> east_pkt_out(0,1),

				south_pkt_in 	=> south_pkt_in(0,1),
				south_pkt_out 	=> south_pkt_out(0,1),

				west_pkt_in 	=> west_pkt_in(0,1),
				west_pkt_out 	=> west_pkt_out(0,1), 
				
				tag_seg		=> tag_array(4),
				key_in 		=> key_array(4)

	);
	
	worm_node5 :worm_node
	generic map(node_ID	=> "0101"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(5),
				col_done		=> sig_col_done(5),
				row_done 		=> sig_row_done(5),

				row_found 		=> sig_row_found(5),
				col_found 		=> sig_col_found(5),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(1,1),
				north_pkt_out 	=> north_pkt_out(1,1),

				east_pkt_in 	=> east_pkt_in(1,1),
				east_pkt_out 	=> east_pkt_out(1,1),

				south_pkt_in 	=> south_pkt_in(1,1),
				south_pkt_out 	=> south_pkt_out(1,1),

				west_pkt_in 	=> west_pkt_in(1,1),
				west_pkt_out 	=> west_pkt_out(1,1), 
				
				tag_seg		=> tag_array(5),
				key_in		=> key_array(5)
	);
	
	worm_node6 :worm_node
	generic map(node_ID	=> "0110"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(6),
				col_done		=> sig_col_done(6),
				row_done 		=> sig_row_done(6),

				row_found 		=> sig_row_found(6),
				col_found 		=> sig_col_found(6),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(2,1),
				north_pkt_out 	=> north_pkt_out(2,1),

				east_pkt_in 	=> east_pkt_in(2,1),
				east_pkt_out 	=> east_pkt_out(2,1),

				south_pkt_in 	=> south_pkt_in(2,1),
				south_pkt_out 	=> south_pkt_out(2,1),

				west_pkt_in 	=> west_pkt_in(2,1),
				west_pkt_out 	=> west_pkt_out(2,1), 
				
				tag_seg		=> tag_array(6),
				key_in		=> key_array(6)
	);
	
	worm_node7 :worm_node
	generic map(node_ID	=> "0111"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(7),
				col_done		=> sig_col_done(7),
				row_done 		=> sig_row_done(7),

				row_found 		=> sig_row_found(7),
				col_found 		=> sig_col_found(7),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(3,1),
				north_pkt_out 	=> north_pkt_out(3,1),

				east_pkt_in 	=> east_pkt_in(3,1),
				east_pkt_out 	=> east_pkt_out(3,1),

				south_pkt_in 	=> south_pkt_in(3,1),
				south_pkt_out 	=> south_pkt_out(3,1),

				west_pkt_in 	=> west_pkt_in(3,1),
				west_pkt_out 	=> west_pkt_out(3,1), 
				
				tag_seg		=> tag_array(7),
				key_in		=> key_array(7)

	);
	
	worm_node8 :worm_node
	generic map(node_ID	=> "1000"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(8),
				col_done		=> sig_col_done(8),
				row_done 		=> sig_row_done(8),

				row_found 		=> sig_row_found(8),
				col_found 		=> sig_col_found(8),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(0,2),
				north_pkt_out 	=> north_pkt_out(0,2),

				east_pkt_in 	=> east_pkt_in(0,2),
				east_pkt_out 	=> east_pkt_out(0,2),

				south_pkt_in 	=> south_pkt_in(0,2),
				south_pkt_out 	=> south_pkt_out(0,2),

				west_pkt_in 	=> west_pkt_in(0,2),
				west_pkt_out 	=> west_pkt_out(0,2), 
				
				tag_seg		=> tag_array(8),
				key_in		=> key_array(8)

	);
	
	worm_node9 :worm_node
	generic map(node_ID	=> "1001"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(9),
				col_done		=> sig_col_done(9),
				row_done 		=> sig_row_done(9),

				row_found 		=> sig_row_found(9),
				col_found 		=> sig_col_found(9),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(1,2),
				north_pkt_out 	=> north_pkt_out(1,2),

				east_pkt_in 	=> east_pkt_in(1,2),
				east_pkt_out 	=> east_pkt_out(1,2),

				south_pkt_in 	=> south_pkt_in(1,2),
				south_pkt_out 	=> south_pkt_out(1,2),

				west_pkt_in 	=> west_pkt_in(1,2),
				west_pkt_out 	=> west_pkt_out(1,2), 
				
				tag_seg		=> tag_array(9),
				key_in		=> key_array(9)

	);
	
	worm_node10 :worm_node
	generic map(node_ID	=> "1010"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(10),
				col_done		=> sig_col_done(10),
				row_done 		=> sig_row_done(10),

				row_found 		=> sig_row_found(10),
				col_found 		=> sig_col_found(10),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(2,2),
				north_pkt_out 	=> north_pkt_out(2,2),

				east_pkt_in 	=> east_pkt_in(2,2),
				east_pkt_out 	=> east_pkt_out(2,2),

				south_pkt_in 	=> south_pkt_in(2,2),
				south_pkt_out 	=> south_pkt_out(2,2),

				west_pkt_in 	=> west_pkt_in(2,2),
				west_pkt_out 	=> west_pkt_out(2,2), 
				
				tag_seg		=> tag_array(10),
				key_in		=> key_array(10)

	);
	
	worm_node11 :worm_node
	generic map(node_ID	=> "1011"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(11),
				col_done		=> sig_col_done(11),
				row_done 		=> sig_row_done(11),

				row_found 		=> sig_row_found(11),
				col_found 		=> sig_col_found(11),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(3,2),
				north_pkt_out 	=> north_pkt_out(3,2),

				east_pkt_in 	=> east_pkt_in(3,2),
				east_pkt_out 	=> east_pkt_out(3,2),

				south_pkt_in 	=> south_pkt_in(3,2),
				south_pkt_out 	=> south_pkt_out(3,2),

				west_pkt_in 	=> west_pkt_in(3,2),
				west_pkt_out 	=> west_pkt_out(3,2), 
				
				tag_seg		=> tag_array(11),
				key_in		=> key_array(11)

	);
	
	worm_node12 :worm_node
	generic map(node_ID	=> "1100"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(12),
				col_done		=> sig_col_done(12),
				row_done 		=> sig_row_done(12),

				row_found 		=> sig_row_found(12),
				col_found 		=> sig_col_found(12),
				
				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(0,3),
				north_pkt_out 	=> north_pkt_out(0,3),

				east_pkt_in 	=> east_pkt_in(0,3),
				east_pkt_out 	=> east_pkt_out(0,3),

				south_pkt_in 	=> south_pkt_in(0,3),
				south_pkt_out 	=> south_pkt_out(0,3),

				west_pkt_in 	=> west_pkt_in(0,3),
				west_pkt_out 	=> west_pkt_out(0,3), 
				
				tag_seg		=> tag_array(12),
				key_in		=> key_array(12)

	);
	
	worm_node13 :worm_node
	generic map(node_ID	=> "1101"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(13),
				col_done		=> sig_col_done(13),
				row_done 		=> sig_row_done(13),

				row_found 		=> sig_row_found(13),
				col_found 		=> sig_col_found(13),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(1,3),
				north_pkt_out 	=> north_pkt_out(1,3),

				east_pkt_in 	=> east_pkt_in(1,3),
				east_pkt_out 	=> east_pkt_out(1,3),

				south_pkt_in 	=> south_pkt_in(1,3),
				south_pkt_out 	=> south_pkt_out(1,3),

				west_pkt_in 	=> west_pkt_in(1,3),
				west_pkt_out 	=> west_pkt_out(1,3), 
				
				tag_seg		=> tag_array(13),
				key_in		=> key_array(13)

	);
	
	worm_node14 :worm_node
	generic map(node_ID	=> "1110"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(14),
				col_done		=> sig_col_done(14),
				row_done 		=> sig_row_done(14),

				row_found 		=> sig_row_found(14),
				col_found 		=> sig_col_found(14),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(2,3),
				north_pkt_out 	=> north_pkt_out(2,3),

				east_pkt_in 	=> east_pkt_in(2,3),
				east_pkt_out 	=> east_pkt_out(2,3),

				south_pkt_in 	=> south_pkt_in(2,3),
				south_pkt_out 	=> south_pkt_out(2,3),

				west_pkt_in 	=> west_pkt_in(2,3),
				west_pkt_out 	=> west_pkt_out(2,3), 
				
				tag_seg		=> tag_array(14),
				key_in		=> key_array(14)

	);
	
	worm_node15 :worm_node
	generic map(node_ID	=> "1111"
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(15),
				col_done		=> sig_col_done(15),
				row_done 		=> sig_row_done(15),

				row_found 		=> sig_row_found(15),
				col_found 		=> sig_col_found(15),

				pkt_data			=> sig_packet,

				north_pkt_in 	=> north_pkt_in(3,3),
				north_pkt_out 	=> north_pkt_out(3,3),

				east_pkt_in 	=> east_pkt_in(3,3),
				east_pkt_out 	=> east_pkt_out(3,3),

				south_pkt_in 	=> south_pkt_in(3,3),
				south_pkt_out 	=> south_pkt_out(3,3),

				west_pkt_in 	=> west_pkt_in(3,3),
				west_pkt_out 	=> west_pkt_out(3,3), 
				
				tag_seg		=> tag_array(15),
				key_in		=> key_array(15)

	);
	
--================================================
	-- moving packets
	EW_y_generate : for j in 0 to 3 generate
		EW_x_generate : for i in 1 to 3 generate
			west_pkt_in(i,j)		<= east_pkt_out(i-1,j);
			east_pkt_in(i-1,j)	<= west_pkt_out(i,j);
		end generate;
	end generate;
	
	NS_x_generate : for j in 0 to 3 generate
		NS_y_generate : for i in 1 to 3 generate
			north_pkt_in(j,i)	<= south_pkt_out(j,i-1);
			south_pkt_in(j,i-1)	<= north_pkt_out(j,i);
		end generate;
	end generate;
	
	-- initial boundary 
	north_pkt_in(0,0) <= (others => '0');
	north_pkt_in(1,0) <= (others => '0');
	north_pkt_in(2,0) <= (others => '0');
	north_pkt_in(3,0) <= (others => '0');
	south_pkt_in(0,3) <= (others => '0');
	south_pkt_in(1,3) <= (others => '0');
	south_pkt_in(2,3) <= (others => '0');
	south_pkt_in(3,3) <= (others => '0');
	east_pkt_in(3,0) <= (others => '0');
	east_pkt_in(3,1) <= (others => '0');
	east_pkt_in(3,2) <= (others => '0');
	east_pkt_in(3,3) <= (others => '0');
	west_pkt_in(0,0) <= (others => '0');
	west_pkt_in(0,1) <= (others => '0');
	west_pkt_in(0,2) <= (others => '0');
	west_pkt_in(0,3) <= (others => '0');

--================================================
	trojan_loca_init : trojan_localization 
    Port map ( clk 			=> clk,
				   reset			=> reset,
				   done			=> sig_done,
				   trojan_found	=> trojan_found,
				   row 			=> sig_row_found(15) & sig_row_found(11) & sig_row_found(7) & sig_row_found(3),
				   col 			=> sig_col_found(15) & sig_col_found(14) & sig_col_found(13) & sig_col_found(12),
				   trojan 		=> trojan_id
	);
	
	row_cout <= sig_row_found(15) & sig_row_found(11) & sig_row_found(7) & sig_row_found(3);
	col_cout <= sig_col_found(15) & sig_col_found(14) & sig_col_found(13) & sig_col_found(12);
	
--================================================
	sig_flagdata <= std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_packet(42 downto 40))) + to_integer(unsigned(sig_packet(39 downto 36))) + to_integer(unsigned(sig_packet(7 downto 0)))), 8));

--================================================
	-- tag table
	-- key : 28, 71, 200, 1, 172, 120, 17, 92, 217, 9, 133, 97, 85, 154, 92, 63
	tag_0 : tag_array(0)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 1 + to_integer(unsigned(key_array(0)))), 8));
	tag_1 : tag_array(1) 		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 2 + to_integer(unsigned(key_array(1)))), 8));
	tag_2 : tag_array(2)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 3 + to_integer(unsigned(key_array(2)))), 8));
	tag_3 : tag_array(3)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 4 + to_integer(unsigned(key_array(3)))), 8));
	tag_4 : tag_array(4)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 5 + to_integer(unsigned(key_array(4)))), 8));
	tag_5 : tag_array(5)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 6 + to_integer(unsigned(key_array(5)))), 8));
	tag_6 : tag_array(6)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 7 + to_integer(unsigned(key_array(6)))), 8));
	tag_7 : tag_array(7)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 8 + to_integer(unsigned(key_array(7)))), 8));
	tag_8 : tag_array(8)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 9 + to_integer(unsigned(key_array(8)))), 8));
	tag_9 : tag_array(9)		<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 10 + to_integer(unsigned(key_array(9)))), 8));
	tag_10 : tag_array(10)	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 11 + to_integer(unsigned(key_array(10)))), 8));
	tag_11 : tag_array(11)	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 12 + to_integer(unsigned(key_array(11)))), 8));
	tag_12 : tag_array(12) 	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 13 + to_integer(unsigned(key_array(12)))), 8));
	tag_13 : tag_array(13) 	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 14 + to_integer(unsigned(key_array(13)))), 8));
	tag_14 : tag_array(14) 	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 15 + to_integer(unsigned(key_array(14)))), 8));
	tag_15 : tag_array(15) 	<=  std_logic_vector(TO_UNSIGNED((to_integer(unsigned(sig_flagdata)) + 16 + to_integer(unsigned(key_array(15)))), 8));
	
	-- key table
	key_table_gen : key_table 
    Port map ( k0 	=> key_array(0),
				   k1  	=> key_array(1),
				   k2  	=> key_array(2),
				   k3 	=> key_array(3),
				   k4 	=> key_array(4),
				   k5  	=> key_array(5),
				   k6 	=> key_array(6),
				   k7  	=> key_array(7),
				   k8 	=> key_array(8),
				   k9 	=> key_array(9),
				   k10 	=> key_array(10),
				   k11  	=> key_array(11),
				   k12  	=> key_array(12),
				   k13  	=> key_array(13),
				   k14 	=> key_array(14),
				   k15  	=> key_array(15)
	);

--================================================
	process(clk, reset)
	begin
		if reset = '1' then
			sig_done <= '0';
		elsif rising_edge(clk) then
			if sig_col_done(3) = '1' and sig_col_done(7) = '1' and sig_col_done(11) = '1' and sig_col_done(15) = '1' then 
				if sig_row_done(12) = '1' and sig_row_done(13) = '1' and sig_row_done(14) = '1' and sig_row_done(15) = '1' then 
					sig_done <= '1';
				else
					sig_done <= '0';
				end if;
			else 
				sig_done <= '0';
			end if;
		end if;
	end process;

--================================================
	-- lfsr : linear feedback shift register
	-- packet update
	packet_update : process(reset, clk)
	begin
		if reset = '1' then
			sig_packet(48 downto 43) <= "000000";
			sig_packet(42 downto 40) <= sig_packet(40) & sig_packet(42) & not(sig_packet(41));
			sig_packet(39 downto 36) <= sig_packet(36) & sig_packet(39 downto 38) & not(sig_packet(37));
			sig_packet(35 downto 0) <= sig_packet(0) & sig_packet(35 downto 2) & not(sig_packet(1));
		elsif rising_edge(clk) then
			sig_packet <= sig_packet;
		end if;
	end process;

end Behavioral;

