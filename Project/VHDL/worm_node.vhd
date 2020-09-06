library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity worm_node is
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
end worm_node;

architecture Behavioral of worm_node is
	component LU_router is
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
	end component;

	component checksum is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           north_in : in  STD_LOGIC_VECTOR (48 downto 0);
           east_in : in  STD_LOGIC_VECTOR (48 downto 0);
           south_in : in  STD_LOGIC_VECTOR (48 downto 0);
           west_in : in  STD_LOGIC_VECTOR (48 downto 0);
           north_out : out  STD_LOGIC_VECTOR (48 downto 0);
           east_out : out  STD_LOGIC_VECTOR (48 downto 0);
           south_out : out  STD_LOGIC_VECTOR (48 downto 0);
           west_out : out  STD_LOGIC_VECTOR (48 downto 0);
           local_tag : in  STD_LOGIC_VECTOR(7 DOWNTO 0);
           tag_seg : in  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	end component;
	
	component compare_local_pkt is
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
	end component;
	
	signal local_row_pkt_out : std_logic_vector(48 downto 0);
	signal local_col_pkt_out : std_logic_vector(48 downto 0);
	signal row_out : std_logic_vector(48 downto 0);
	signal col_out : std_logic_vector(48 downto 0);

	signal sig_north_pkt_out : std_logic_vector(48 downto 0);
	signal sig_east_pkt_out : std_logic_vector(48 downto 0);
	signal sig_south_pkt_out : std_logic_vector(48 downto 0);
	signal sig_west_pkt_out : std_logic_vector(48 downto 0);
	
	signal sig_local_flag : std_logic_vector(2 downto 0);	
	signal sig_local_data : std_logic_vector(7 downto 0);	
	signal sig_local_target : std_logic_vector(3 downto 0);
	
	signal sig_tag : std_logic_vector(7 downto 0);
	signal sig_row_tag : std_logic_vector(7 downto 0);
	signal sig_col_tag : std_logic_vector(7 downto 0);

	signal sig_packet : std_logic_vector(48 downto 0);
--	:= "0000001001010000000000000000000000000000011000101";

	signal sig_row_found : std_logic;
	signal sig_col_found : std_logic;

	signal sig_row_done : std_logic;
	signal sig_col_done : std_logic;

begin
	sig_packet <= pkt_data;
	
	LU_router_init : LU_router 
	generic map (node_ID 	=> node_ID)
    Port map ( clk 				=> clk,
				reset 				=> reset,
				
				trojan				=> trojan,
				col_done 			=> col_done,
				row_done 			=> row_done,
				
				pkt_data			=> sig_packet,
				
				col_move 			=> '1',
				row_move 		=> '1',

				local_pkt_out_row 	=> row_out,
				local_pkt_out_col		=> col_out,

				north_pkt_in 	=> sig_north_pkt_out,
				north_pkt_out 	=> north_pkt_out,

				east_pkt_in 		=> sig_east_pkt_out,
				east_pkt_out 	=> east_pkt_out,

				south_pkt_in 	=> sig_south_pkt_out,
				south_pkt_out 	=> south_pkt_out,

				west_pkt_in 		=> sig_west_pkt_out,
				west_pkt_out 	=> west_pkt_out
	);
	
	-- check input packet
	sig_local_flag <= north_pkt_in(42 downto 40) OR south_pkt_in(42 downto 40) OR east_pkt_in(42 downto 40) OR west_pkt_in(42 downto 40);
	sig_local_data <= north_pkt_in(7 downto 0) OR south_pkt_in(7 downto 0) OR east_pkt_in(7 downto 0) OR west_pkt_in(7 downto 0);
	sig_local_target <= north_pkt_in(39 downto 36) OR south_pkt_in(39 downto 36)OR east_pkt_in(39 downto 36) OR west_pkt_in(39 downto 36);
	
	sig_tag <= std_logic_vector(1 + to_unsigned((to_integer(unsigned(sig_local_flag)) + to_integer(unsigned(sig_local_target)) + to_integer(unsigned(sig_local_data)) + to_integer(unsigned(key_in)) + to_integer(unsigned(node_ID))), 8));

	-- compare local tag with the tag generated in process node
	compare_tags : checksum 
		Port map ( clk 		=> clk,
				   reset			=> reset, 
				   north_in		=> north_pkt_in, 
				   east_in 		=> east_pkt_in,
				   south_in		=> south_pkt_in,
				   west_in 		=> west_pkt_in,
				   north_out	=> sig_north_pkt_out,
				   east_out	=> sig_east_pkt_out,
				   south_out	=> sig_south_pkt_out,
				   west_out 	=> sig_west_pkt_out,
				   local_tag 	=> sig_tag,
				   tag_seg 		=> tag_seg
		);
		
	compare_local_inst : compare_local_pkt 
	generic map (node_ID 	=> node_ID)
    Port map ( clk 			=> clk,
				   reset			=> reset,
				   
				   row_out 	=> row_out,
				   col_out		=> col_out,
				   
				   local_row_pkt_out 	=> local_row_pkt_out,
				   local_col_pkt_out 	=> local_col_pkt_out,
				   
				   row_found		=> row_found,
				   col_found 		=> col_found,

				   row_done		=> sig_row_done,
				   col_done 		=> sig_col_done,				   
				   
				   key_in			=> key_in,
				   tag_seg 			=> tag_seg
	);

end Behavioral;

