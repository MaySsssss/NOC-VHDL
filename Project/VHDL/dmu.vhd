library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dmu is
    Port ( clk 					: in  STD_LOGIC;
           reset 				: in  STD_LOGIC;
		   trojan_detect	: out std_logic_vector(15 downto 0);
		   trojan_id			: out std_logic_vector(3 downto 0);
		   network				: out std_logic_vector(23 downto 0)
	);
end dmu;

architecture Behavioral of dmu is
	component node is
	generic (node_ID : std_logic_vector(3 downto 0);
				node_type : integer );
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  trojan	: in std_logic;
			  pkt_drop : out std_logic;

   			  busy_in : in std_logic_vector(4 downto 1);
			  busy_out : out std_logic_vector(4 downto 1);

			  local_busy_in : out std_logic;
			  local_busy_out : out std_logic;
			  
			  north_pkt_in : in std_logic_vector(48 downto 0);
			  north_pkt_out : out std_logic_vector(48 downto 0);
			  
			  east_pkt_in : in std_logic_vector(48 downto 0);
			  east_pkt_out : out std_logic_vector(48 downto 0);
			  
			  south_pkt_in : in std_logic_vector(48 downto 0);
			  south_pkt_out : out std_logic_vector(48 downto 0);
			  
			  west_pkt_in : in std_logic_vector(48 downto 0);
			  west_pkt_out : out std_logic_vector(48 downto 0);
			  
			  tag_seg : in std_logic_vector(7 downto 0);
			  key_in : in std_logic_vector(7 downto 0);

			  flag_data : out std_logic_vector(7 downto 0);
			  we : out std_logic
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
	

	component detection_unit is
    Port ( clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			trojan_location : in std_logic_vector(15 downto 0)
	);
	end component;
	
	type pkt_array_type is array(integer range 3 downto 0, integer range 3 downto 0) of std_logic_vector(48 downto 0);
	signal north_pkt_in 	: pkt_array_type;
	signal north_pkt_out : pkt_array_type;
	signal east_pkt_in 	: pkt_array_type;
	signal east_pkt_out 	: pkt_array_type;
	signal south_pkt_in 	: pkt_array_type;
	signal south_pkt_out	: pkt_array_type;
	signal west_pkt_in 	: pkt_array_type;
	signal west_pkt_out 	: pkt_array_type;
	
	type busy_array_type is array(integer range 3 downto 0, integer range 3 downto 0) of std_logic_vector(4 downto 1);
	signal busy_in		 	: busy_array_type;
	signal busy_out		 	: busy_array_type;
	
	type local_busy_array_type is array(integer range 3 downto 0, integer range 3 downto 0) of std_logic;
	signal local_busy_in	: local_busy_array_type;
	signal local_busy_out	: local_busy_array_type;
	
	signal trojan_location : std_logic_vector(15 downto 0) := (others => '0');
	signal sig_trojan_location : std_logic_vector(15 downto 0);

	type tag_array_type is array(integer range 15 downto 0) of std_logic_vector(7 downto 0);
	signal tag_array : tag_array_type;
	signal key_array : tag_array_type;
	
	type flagdata_array_type is array(integer range 3 downto 0, integer range 3 downto 0) of std_logic_vector(7 downto 0);
	signal flagdata_array : flagdata_array_type;
	
	signal sig_we : std_logic_vector(15 downto 0);
	signal sig_flagdata : std_logic_vector(7 downto 0);
	
	signal sig_trojan_detect : std_logic_vector(15 downto 0) := (others => '0');
	
	signal sig_net_1 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net_2 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net_3 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net_4 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net_5 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net_6 : std_logic_vector(3 downto 0) := (others => '0');
	signal sig_net : std_logic_vector(23 downto 0) := (others => '0');

begin
--================================================
	router_inst0 : node
	generic map(node_ID	=> "0000",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(0),
				pkt_drop 		=> sig_trojan_detect(0),

				busy_in 		=> busy_in(0,0),
				busy_out 		=> busy_out(0,0),
		
				local_busy_in	=> local_busy_in(0,0), 
				local_busy_out	=> local_busy_out(0,0),

				north_pkt_in 	=> north_pkt_in(0,0),
				north_pkt_out 	=> north_pkt_out(0,0),

				east_pkt_in 	=> east_pkt_in(0,0),
				east_pkt_out 	=> east_pkt_out(0,0),

				south_pkt_in 	=> south_pkt_in(0,0),
				south_pkt_out 	=> south_pkt_out(0,0),

				west_pkt_in 	=> west_pkt_in(0,0),
				west_pkt_out 	=> west_pkt_out(0,0), 
				
				tag_seg		=> tag_array(0),
				key_in		=> key_array(0)	,
				
				flag_data 	=> flagdata_array(0,0),
				we 			=> sig_we(0)

	);

	-- router only
	router_inst1 : node
	generic map(node_ID	=> "0001",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(1),	
				pkt_drop 		=> sig_trojan_detect(1),

				busy_in 		=> busy_in(1,0),
				busy_out 		=> busy_out(1,0),
		
				local_busy_in	=> local_busy_in(1,0), 
				local_busy_out	=> local_busy_out(1,0),

				north_pkt_in 	=> north_pkt_in(1,0),
				north_pkt_out 	=> north_pkt_out(1,0),

				east_pkt_in 	=> east_pkt_in(1,0),
				east_pkt_out 	=> east_pkt_out(1,0),

				south_pkt_in 	=> south_pkt_in(1,0),
				south_pkt_out 	=> south_pkt_out(1,0),

				west_pkt_in 	=> west_pkt_in(1,0),
				west_pkt_out 	=> west_pkt_out(1,0), 
				
				tag_seg		=> tag_array(1),
				key_in		=> key_array(1),

				flag_data 	=> flagdata_array(1,0),
				we 			=> sig_we(1)

	);
	
	-- router only
	router_inst2 : node
	generic map(node_ID	=> "0010",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(2),
				pkt_drop 		=> sig_trojan_detect(2),

				busy_in 		=> busy_in(2,0),
				busy_out 		=> busy_out(2,0),
		
				local_busy_in	=> local_busy_in(2,0), 
				local_busy_out	=> local_busy_out(2,0),

				north_pkt_in 	=> north_pkt_in(2,0),
				north_pkt_out 	=> north_pkt_out(2,0),

				east_pkt_in 	=> east_pkt_in(2,0),
				east_pkt_out 	=> east_pkt_out(2,0),

				south_pkt_in 	=> south_pkt_in(2,0),
				south_pkt_out 	=> south_pkt_out(2,0),

				west_pkt_in 	=> west_pkt_in(2,0),
				west_pkt_out 	=> west_pkt_out(2,0), 
				
				tag_seg		=> tag_array(2),
				key_in		=> key_array(2),

				flag_data 	=> flagdata_array(2,0),
				we 			=> sig_we(2)

	);
	
	-- router only
	router_inst3 : node
	generic map(node_ID	=> "0011",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(3),
				pkt_drop 		=> sig_trojan_detect(3),

				busy_in 		=> busy_in(3,0),
				busy_out 		=> busy_out(3,0),
		
				local_busy_in	=> local_busy_in(3,0), 
				local_busy_out	=> local_busy_out(3,0),

				north_pkt_in 	=> north_pkt_in(3,0),
				north_pkt_out 	=> north_pkt_out(3,0),

				east_pkt_in 	=> east_pkt_in(3,0),
				east_pkt_out 	=> east_pkt_out(3,0),

				south_pkt_in 	=> south_pkt_in(3,0),
				south_pkt_out 	=> south_pkt_out(3,0),

				west_pkt_in 	=> west_pkt_in(3,0),
				west_pkt_out 	=> west_pkt_out(3,0), 
				
				tag_seg		=> tag_array(3),
				key_in		=> key_array(3), 

				flag_data 	=> flagdata_array(3,0),
				we 			=> sig_we(3)

	);
	
	-- router only
	router_inst4 : node
	generic map(node_ID	=> "0100",
				node_type 	=> 0
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(4),
				pkt_drop 		=> sig_trojan_detect(4),

				busy_in 		=> busy_in(0,1),
				busy_out 		=> busy_out(0,1),
		
				local_busy_in	=> local_busy_in(0,1), 
				local_busy_out	=> local_busy_out(0,1),

				north_pkt_in 	=> north_pkt_in(0,1),
				north_pkt_out 	=> north_pkt_out(0,1),

				east_pkt_in 	=> east_pkt_in(0,1),
				east_pkt_out 	=> east_pkt_out(0,1),

				south_pkt_in 	=> south_pkt_in(0,1),
				south_pkt_out 	=> south_pkt_out(0,1),

				west_pkt_in 	=> west_pkt_in(0,1),
				west_pkt_out 	=> west_pkt_out(0,1), 
				
				tag_seg		=> tag_array(4),
				key_in 		=> key_array(4),

				flag_data 	=> flagdata_array(0,1),
				we 			=> sig_we(4)

	);
	
	-- router only
	router_inst5 : node
	generic map(node_ID	=> "0101",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(5),
				pkt_drop 		=> sig_trojan_detect(5),

				busy_in 		=> busy_in(1,1),
				busy_out 		=> busy_out(1,1),
		
				local_busy_in	=> local_busy_in(1,1), 
				local_busy_out	=> local_busy_out(1,1),

				north_pkt_in 	=> north_pkt_in(1,1),
				north_pkt_out 	=> north_pkt_out(1,1),

				east_pkt_in 	=> east_pkt_in(1,1),
				east_pkt_out 	=> east_pkt_out(1,1),

				south_pkt_in 	=> south_pkt_in(1,1),
				south_pkt_out 	=> south_pkt_out(1,1),

				west_pkt_in 	=> west_pkt_in(1,1),
				west_pkt_out 	=> west_pkt_out(1,1), 
				
				tag_seg		=> tag_array(5),
				key_in		=> key_array(5),

				flag_data 	=> flagdata_array(1,1),
				we 			=> sig_we(5)

	);
	
	-- router only
	router_inst6 : node
	generic map(node_ID	=> "0110",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(6),
				pkt_drop 		=> sig_trojan_detect(6),

				busy_in 		=> busy_in(2,1),
				busy_out 		=> busy_out(2,1),
		
				local_busy_in	=> local_busy_in(2,1), 
				local_busy_out	=> local_busy_out(2,1),

				north_pkt_in 	=> north_pkt_in(2,1),
				north_pkt_out 	=> north_pkt_out(2,1),

				east_pkt_in 	=> east_pkt_in(2,1),
				east_pkt_out 	=> east_pkt_out(2,1),

				south_pkt_in 	=> south_pkt_in(2,1),
				south_pkt_out 	=> south_pkt_out(2,1),

				west_pkt_in 	=> west_pkt_in(2,1),
				west_pkt_out 	=> west_pkt_out(2,1), 
				
				tag_seg		=> tag_array(6),
				key_in		=> key_array(6),
				
				flag_data 	=> flagdata_array(2,1),
				we 			=> sig_we(6)

	);
	
	-- router only
	router_inst7 : node
	generic map(node_ID	=> "0111",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(7),
				pkt_drop 		=> sig_trojan_detect(7),

				busy_in 		=> busy_in(3,1),
				busy_out 		=> busy_out(3,1),
		
				local_busy_in	=> local_busy_in(3,1), 
				local_busy_out	=> local_busy_out(3,1),

				north_pkt_in 	=> north_pkt_in(3,1),
				north_pkt_out 	=> north_pkt_out(3,1),

				east_pkt_in 	=> east_pkt_in(3,1),
				east_pkt_out 	=> east_pkt_out(3,1),

				south_pkt_in 	=> south_pkt_in(3,1),
				south_pkt_out 	=> south_pkt_out(3,1),

				west_pkt_in 	=> west_pkt_in(3,1),
				west_pkt_out 	=> west_pkt_out(3,1), 
				
				tag_seg		=> tag_array(7),
				key_in		=> key_array(7),

				flag_data 	=> flagdata_array(3,1),
				we 			=> sig_we(7)

	);
	
	-- router only
	router_inst8 : node
	generic map(node_ID	=> "1000",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(8),
				pkt_drop 		=> sig_trojan_detect(8),

				busy_in 		=> busy_in(0,2),
				busy_out 		=> busy_out(0,2),
		
				local_busy_in	=> local_busy_in(0,2),
				local_busy_out	=> local_busy_out(0,2),

				north_pkt_in 	=> north_pkt_in(0,2),
				north_pkt_out 	=> north_pkt_out(0,2),

				east_pkt_in 	=> east_pkt_in(0,2),
				east_pkt_out 	=> east_pkt_out(0,2),

				south_pkt_in 	=> south_pkt_in(0,2),
				south_pkt_out 	=> south_pkt_out(0,2),

				west_pkt_in 	=> west_pkt_in(0,2),
				west_pkt_out 	=> west_pkt_out(0,2), 
				
				tag_seg		=> tag_array(8),
				key_in		=> key_array(8),

				flag_data 	=> flagdata_array(0,2),
				we 			=> sig_we(8)

	);
	
	-- router only
	router_inst9 : node
	generic map(node_ID	=> "1001",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(9),
				pkt_drop 		=> sig_trojan_detect(9),

				busy_in 		=> busy_in(1,2),
				busy_out 		=> busy_out(1,2),
		
				local_busy_in	=> local_busy_in(1,2),
				local_busy_out	=> local_busy_out(1,2),

				north_pkt_in 	=> north_pkt_in(1,2),
				north_pkt_out 	=> north_pkt_out(1,2),

				east_pkt_in 	=> east_pkt_in(1,2),
				east_pkt_out 	=> east_pkt_out(1,2),

				south_pkt_in 	=> south_pkt_in(1,2),
				south_pkt_out 	=> south_pkt_out(1,2),

				west_pkt_in 	=> west_pkt_in(1,2),
				west_pkt_out 	=> west_pkt_out(1,2), 
				
				tag_seg		=> tag_array(9),
				key_in		=> key_array(9),

				flag_data 	=> flagdata_array(1,2),
				we 			=> sig_we(9)

	);
	
	-- router only
	router_inst10 : node
	generic map(node_ID	=> "1010",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(10),
				pkt_drop 		=> sig_trojan_detect(10),

				busy_in 		=> busy_in(2,2),
				busy_out 		=> busy_out(2,2),
		
				local_busy_in	=> local_busy_in(2,2),
				local_busy_out	=> local_busy_out(2,2),

				north_pkt_in 	=> north_pkt_in(2,2),
				north_pkt_out 	=> north_pkt_out(2,2),

				east_pkt_in 	=> east_pkt_in(2,2),
				east_pkt_out 	=> east_pkt_out(2,2),

				south_pkt_in 	=> south_pkt_in(2,2),
				south_pkt_out 	=> south_pkt_out(2,2),

				west_pkt_in 	=> west_pkt_in(2,2),
				west_pkt_out 	=> west_pkt_out(2,2), 
				
				tag_seg		=> tag_array(10),
				key_in		=> key_array(10),

				flag_data 	=> flagdata_array(2,2),
				we 			=> sig_we(10)

	);
	
	-- router only
	router_inst11 : node
	generic map(node_ID	=> "1011",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(11),
				pkt_drop 		=> sig_trojan_detect(11),

				busy_in 		=> busy_in(3,2),
				busy_out 		=> busy_out(3,2),
		
				local_busy_in	=> local_busy_in(3,2),
				local_busy_out	=> local_busy_out(3,2),

				north_pkt_in 	=> north_pkt_in(3,2),
				north_pkt_out 	=> north_pkt_out(3,2),

				east_pkt_in 	=> east_pkt_in(3,2),
				east_pkt_out 	=> east_pkt_out(3,2),

				south_pkt_in 	=> south_pkt_in(3,2),
				south_pkt_out 	=> south_pkt_out(3,2),

				west_pkt_in 	=> west_pkt_in(3,2),
				west_pkt_out 	=> west_pkt_out(3,2), 
				
				tag_seg		=> tag_array(11),
				key_in		=> key_array(11),

				flag_data 	=> flagdata_array(3,2),
				we 			=> sig_we(11)

	);
	
	-- router only
	router_inst12 : node
	generic map(node_ID	=> "1100",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(12),
				pkt_drop 		=> sig_trojan_detect(12),

				busy_in 		=> busy_in(0,3),
				busy_out 		=> busy_out(0,3),
		
				local_busy_in	=> local_busy_in(0,3),
				local_busy_out	=> local_busy_out(0,3),

				north_pkt_in 	=> north_pkt_in(0,3),
				north_pkt_out 	=> north_pkt_out(0,3),

				east_pkt_in 	=> east_pkt_in(0,3),
				east_pkt_out 	=> east_pkt_out(0,3),

				south_pkt_in 	=> south_pkt_in(0,3),
				south_pkt_out 	=> south_pkt_out(0,3),

				west_pkt_in 	=> west_pkt_in(0,3),
				west_pkt_out 	=> west_pkt_out(0,3), 
				
				tag_seg		=> tag_array(12),
				key_in		=> key_array(12),

				flag_data 	=> flagdata_array(0,3),
				we 			=> sig_we(12)

	);
	
	-- router only
	router_inst13 : node
	generic map(node_ID	=> "1101",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(13),
				pkt_drop 		=> sig_trojan_detect(13),

				busy_in 		=> busy_in(1,3),
				busy_out 		=> busy_out(1,3),
		
				local_busy_in	=> local_busy_in(1,3),
				local_busy_out	=> local_busy_out(1,3),

				north_pkt_in 	=> north_pkt_in(1,3),
				north_pkt_out 	=> north_pkt_out(1,3),

				east_pkt_in 	=> east_pkt_in(1,3),
				east_pkt_out 	=> east_pkt_out(1,3),

				south_pkt_in 	=> south_pkt_in(1,3),
				south_pkt_out 	=> south_pkt_out(1,3),

				west_pkt_in 	=> west_pkt_in(1,3),
				west_pkt_out 	=> west_pkt_out(1,3), 
				
				tag_seg		=> tag_array(13),
				key_in		=> key_array(13),

				flag_data 	=> flagdata_array(1,3),
				we 			=> sig_we(13)

	);
	
	-- router only
	router_inst14 : node
	generic map(node_ID	=> "1110",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(14),
				pkt_drop 		=> sig_trojan_detect(14),

				busy_in 		=> busy_in(2,3),
				busy_out 		=> busy_out(2,3),
		
				local_busy_in	=> local_busy_in(2,3),
				local_busy_out	=> local_busy_out(2,3),

				north_pkt_in 	=> north_pkt_in(2,3),
				north_pkt_out 	=> north_pkt_out(2,3),

				east_pkt_in 	=> east_pkt_in(2,3),
				east_pkt_out 	=> east_pkt_out(2,3),

				south_pkt_in 	=> south_pkt_in(2,3),
				south_pkt_out 	=> south_pkt_out(2,3),

				west_pkt_in 	=> west_pkt_in(2,3),
				west_pkt_out 	=> west_pkt_out(2,3), 
				
				tag_seg		=> tag_array(14),
				key_in		=> key_array(14),

				flag_data 	=> flagdata_array(2,3),
				we 			=> sig_we(14)

	);
	
	-- router only
	router_inst15 : node
	generic map(node_ID	=> "1111",
				node_type 	=> 3
	)
   Port map( clk 				=> clk, 
				reset 			=> reset, 
				
				trojan			=> trojan_location(15),
				pkt_drop 		=> sig_trojan_detect(15),

				busy_in 		=> busy_in(3,3),
				busy_out 		=> busy_out(3,3),
		
				local_busy_in	=> local_busy_in(3,3),
				local_busy_out	=> local_busy_out(3,3),

				north_pkt_in 	=> north_pkt_in(3,3),
				north_pkt_out 	=> north_pkt_out(3,3),

				east_pkt_in 	=> east_pkt_in(3,3),
				east_pkt_out 	=> east_pkt_out(3,3),

				south_pkt_in 	=> south_pkt_in(3,3),
				south_pkt_out 	=> south_pkt_out(3,3),

				west_pkt_in 	=> west_pkt_in(3,3),
				west_pkt_out 	=> west_pkt_out(3,3), 
				
				tag_seg		=> tag_array(15),
				key_in		=> key_array(15),

				flag_data 	=> flagdata_array(3,3),
				we 			=> sig_we(15)

	);
	
--================================================
	-- moving packets
	EW_y_generate : for j in 0 to 3 generate
		EW_x_generate : for i in 1 to 3 generate
			west_pkt_in(i,j)		<= east_pkt_out(i-1,j);
			east_pkt_in(i-1,j)	<= west_pkt_out(i,j);
			busy_in(i,j)(4)		<= busy_out(i-1,j)(2);
			busy_in(i-1,j)(2)		<= busy_out(i,j)(4);
		end generate;
	end generate;
	
	NS_x_generate : for j in 0 to 3 generate
		NS_y_generate : for i in 1 to 3 generate
			north_pkt_in(j,i)	<= south_pkt_out(j,i-1);
			south_pkt_in(j,i-1)	<= north_pkt_out(j,i);
			busy_in(j,i)(1)		<= busy_out(j,i-1)(3);
			busy_in(j,i-1)(3)		<= busy_out(j,i)(1);
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
	-- generate tag table 
	process(clk, reset)
	begin
		if reset = '1' then
			sig_flagdata <= (others => '0');
		elsif rising_edge(clk) then
			case sig_we is 
				when "0000000000000001"	=> sig_flagdata <= flagdata_array(0,0);
				when "0000000000000010"	=> sig_flagdata <= flagdata_array(1,0);
				when "0000000000000100"	=> sig_flagdata <= flagdata_array(2,0);
				when "0000000000001000"	=> sig_flagdata <= flagdata_array(3,0);
				when "0000000000010000"	=> sig_flagdata <= flagdata_array(0,1);
				when "0000000000100000"	=> sig_flagdata <= flagdata_array(1,1);
				when "0000000001000000"	=> sig_flagdata <= flagdata_array(2,1);
				when "0000000010000000"	=> sig_flagdata <= flagdata_array(3,1);
				when "0000000100000000"	=> sig_flagdata <= flagdata_array(0,2);
				when "0000001000000000"	=> sig_flagdata <= flagdata_array(1,2);
				when "0000010000000000"	=> sig_flagdata <= flagdata_array(2,2);
				when "0000100000000000"	=> sig_flagdata <= flagdata_array(3,2);
				when "0001000000000000"	=> sig_flagdata <= flagdata_array(0,3);
				when "0010000000000000"	=> sig_flagdata <= flagdata_array(1,3);
				when "0100000000000000"	=> sig_flagdata <= flagdata_array(2,3);
				when "1000000000000000"	=> sig_flagdata <= flagdata_array(3,3);
				when "0000000000000000"	=> sig_flagdata <= (others => '0');
				when others	=> sig_flagdata <= (others => '0');
			end case;
		end if;
	end process;


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
	trojan_detect <= sig_trojan_detect;
	
	-- activate the worm searching 
	process(clk, reset)
	begin
		if reset = '1' then
			sig_trojan_location <= (others => '0');
		elsif rising_edge(clk) then
			if sig_trojan_detect = "0000000000000000" then
				sig_trojan_location <= (others => '0');
			else
				sig_trojan_location <= trojan_location;
			end if;
		end if;
	end process;
	
	-- detection unit
	detect_unit_inst : detection_unit 
    Port map ( clk 		=> clk,
					reset	=> reset,
					trojan_location	=> sig_trojan_location
	);
	
	sig_net_1 <= 	(busy_out(0,2)(3)	or busy_out(0,3)(1)) 	& (busy_out(0,2)(2)	or busy_out(1,2)(4)) 	& (busy_out(0,1)(3) 	or busy_out(0,2)(1)) 	& (busy_out(1,0)(3) 	or busy_out(1,1)(1));
	sig_net_2 <= 	(busy_out(1,1)(3) 	or busy_out(1,2)(1)) 	& (busy_out(1,1)(2) 	or busy_out(2,1)(4)) 	& (busy_out(0,1)(2) 	or busy_out(1,1)(4)) 	& (busy_out(3,0)(3) 	or busy_out(3,1)(1));
	sig_net_3 <= 	(busy_out(3,1)(3) 	or busy_out(3,2)(1))	& (busy_out(2,1)(2) 	or busy_out(3,1)(4)) 	& (busy_out(0,3)(2) 	or busy_out(1,3)(4)) 	& (busy_out(1,0)(2) 	or busy_out(2,0)(4));
	sig_net_4 <= 	(busy_out(0,0)(2) 	or busy_out(1,0)(4)) 	& (busy_out(2,0)(2) 	or busy_out(3,0)(4)) 	& (busy_out(3,2)(3) 	or busy_out(3,3)(1)) 	& (busy_out(2,3)(2) 	or busy_out(3,3)(4));
	sig_net_5 <= 	(busy_out(2,2)(2) 	or busy_out(3,2)(4)) 	& (busy_out(2,2)(3) 	or busy_out(2,3)(1)) 	& (busy_out(1,2)(2) 	or busy_out(2,2)(4)) 	& (busy_out(2,1)(3) 	or busy_out(2,2)(1));
	sig_net_6 <= 	(busy_out(1,3)(2) 	or busy_out(2,3)(4)) 	& (busy_out(1,2)(3) 	or busy_out(1,3)(1)) 	& (busy_out(2,0)(3) 	or busy_out(2,3)(1)) 	& (busy_out(0,0)(3) 	or busy_out(0,1)(1));

	network <= sig_net_1 & sig_net_2 & sig_net_3 & sig_net_4 & sig_net_5 & sig_net_6;
--================================================
	-- generate trojan
	-- trojan in source node
	trojan_location(12) <= '1';
	-- trojan in destination node
--	trojan_location(4) <= '1';
	-- trojan in others nodes that do not in the path
--	trojan_location(1) <= '1';
--	trojan_location(8) <= '1';
--	trojan_location(5) <= '1';
--	trojan_location(14) <= '1';

end Behavioral;

