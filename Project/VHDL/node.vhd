library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity node is
	generic (node_ID : std_logic_vector(3 downto 0);
				node_type : integer
	);
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
end node;

architecture Behavioral of node is
	component proc is
    Generic (
				node_ID : STD_LOGIC_VECTOR(3 DOWNTO 0));
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  wr : out STD_LOGIC;
			  wr_data : out STD_LOGIC_VECTOR(7 DOWNTO 0);
			  
			  rd_request : out STD_LOGIC;
			  
			  dest_addr : out STD_LOGIC_VECTOR(31 DOWNTO 0);
			  
			  rd_return : in STD_LOGIC;
			  rd_data : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			  
			  not_ready : in STD_LOGIC);
	end component;
	
	component master is
    Generic (
				node_ID : STD_LOGIC_VECTOR(3 DOWNTO 0));
	 Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  
			  busy : in std_logic;
			  not_ready : out std_logic;
			  
			  packet_in : in std_logic_vector(48 downto 0);
			  packet_out : out std_logic_vector(48 downto 0);
			  
			  addr : in std_logic_vector(31 downto 0);
			  
			  rd_return : out std_logic;
			  rd_data : out std_logic_vector(7 downto 0);
			  
			  wr : in std_logic;
			  wr_data : in std_logic_vector(7 downto 0);
			  
			  rd_request : in std_logic);
	end component;
	
	component slave is
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
	end component;
	
	component mem is
	 generic ( node_ID : std_logic_vector(3 downto 0));
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;

           addr : in  STD_LOGIC_VECTOR (31 downto 0);

           wr_data : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;

           rd_request : in  STD_LOGIC;

           rd_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rd_return : out  STD_LOGIC);
	end component;
	
	component router is
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
		   pkt_drop : out STD_LOGIC;
           local_tag : in  STD_LOGIC_VECTOR(7 DOWNTO 0);
           tag_seg : in  STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	end component;

	signal read_request	: std_logic;
	signal read_return	: std_logic;
	signal write_en		: std_logic;
	signal address			: std_logic_vector(31 downto 0);
	signal read_data		: std_logic_vector(7 downto 0);
	signal write_data		: std_logic_vector(7 downto 0);
	
	signal local_pkt_in : std_logic_vector(48 downto 0);
	signal local_pkt_out : std_logic_vector(48 downto 0);
	
	signal sig_north_pkt_out : std_logic_vector(48 downto 0);
	signal sig_east_pkt_out : std_logic_vector(48 downto 0);
	signal sig_south_pkt_out : std_logic_vector(48 downto 0);
	signal sig_west_pkt_out : std_logic_vector(48 downto 0);
	
	-- router
	signal sig_local_busy_in : std_logic;
	signal sig_local_busy_out : std_logic;
	

	-- tag segment 
	signal sig_local_flag : std_logic_vector(2 downto 0);	
	signal sig_local_data : std_logic_vector(7 downto 0);	
	signal sig_local_target : std_logic_vector(3 downto 0);
	signal sig_we : std_logic;
	signal sig_tag : std_logic_vector(7 downto 0);
	
	
begin
--================================================
	-- instantiate rounter
	router_inst : router
	generic map(
		node_ID 		=> node_ID 
	)
   Port map( clk 		=> clk,
				reset 	=> reset,

				trojan		=> trojan,

				busy_in(4 downto 1)			=> busy_in,
				busy_in(0)							=> sig_local_busy_in,
				
				busy_out(4 downto 1)		=> busy_out,
				busy_out(0)						=> sig_local_busy_out,

				local_pkt_in 		=> local_pkt_in,
				local_pkt_out 	=> local_pkt_out,

				north_pkt_in 	=> sig_north_pkt_out,
				north_pkt_out 	=> north_pkt_out,

				east_pkt_in 		=> sig_east_pkt_out,
				east_pkt_out 	=> east_pkt_out,

				south_pkt_in 	=> sig_south_pkt_out,
				south_pkt_out 	=> south_pkt_out,

				west_pkt_in 		=> sig_west_pkt_out,
				west_pkt_out 	=> west_pkt_out
	);
--================================================

--================================================
	-- generate process and master node
	gen_process : if node_type = 0 generate
	begin
		sig_we <= '1';
	
		proc_inst : proc 
		Generic map(
				node_ID 		=> node_ID
		)
		Port map( clk 	=> clk,
           reset 			=> reset,
			  
			  wr 				=> write_en,
			  wr_data 		=> write_data,
			  
			  rd_request	=> read_request,
			  
			  dest_addr 	=> address,
			  
			  rd_return 	=> read_return,
			  rd_data 		=> read_data,
			  
			  not_ready	=> '0'
		);
		
		master_inst: master
		Generic map(
				node_ID 		=> node_ID
		)
		Port map( clk 	=> clk,
           reset 			=> reset,
			  
			  busy 			=> sig_local_busy_out,
			  not_ready 	=> sig_local_busy_in,
			  
			  packet_in 	=> local_pkt_out,
			  packet_out 	=> local_pkt_in,
			  
			  addr 			=> address,
			  
			  rd_return	=> read_return,
			  rd_data 		=> read_data,
			  
			  wr 				=> write_en,
			  wr_data 		=> write_data,
			  
			  rd_request 	=> read_request
		);
	end generate;
	
	
--================================================
	-- generate process and master node
	gen_memory : if node_type = 1 generate
	begin
		mem_inst : mem 
		generic map( node_ID 	=> node_ID 
		)
		Port map( clk 			=> clk,
					reset 			=> reset,

					addr 			=> address,

					wr_data 		=> write_data,
					wr 				=> write_en,

					rd_request 	=> read_request,

					rd_data 		=> read_data,
					rd_return		=> read_return
		);
		
		gen_slave_inst : slave 
		generic map ( node_ID 	=> node_ID
		)
		Port map ( clk		=> clk,
				  reset 			=> reset, 
				  
				  packet_in 	=> local_pkt_out, 
				  packet_out	=> local_pkt_in,
				  
				  addr 			=> address, 
				  
				  rounter_not_rdy => sig_local_busy_out,
				  na_not_rdy 		=> sig_local_busy_in, 
				  slave_not_rdy 	=> '0',
				  
				  rd_return 		=> read_return,
				  rd_data 			=> read_data,
				  
				  wr 				=> write_en,
				  wr_data 		=> write_data,
				  
				  rd_request 	=> read_request
		);
		
		sig_we <= '0';
	end generate;
	

--================================================
	-- router only
	gen_router_only : if node_type = 3 generate
	begin
		--router declared seperately up the top (used by all node types)
		local_pkt_in <= (others => '0');
		sig_local_busy_in <= '0';
		sig_we <= '0';
	end generate;
	
	
--================================================
	local_busy_in 	<= sig_local_busy_in;
	local_busy_out 	<= sig_local_busy_out;
	
	
--================================================
	-- AU: authentication unit 
	flag_data <= std_logic_vector(TO_UNSIGNED((to_integer(unsigned(local_pkt_in(42 downto 40))) + to_integer(unsigned(local_pkt_in(39 downto 36))) + to_integer(unsigned(local_pkt_in(7 downto 0)))), 8));
	
	we <= sig_we;
	
	sig_local_flag <= north_pkt_in(42 downto 40) OR south_pkt_in(42 downto 40) OR east_pkt_in(42 downto 40) OR west_pkt_in(42 downto 40);
	sig_local_data <= north_pkt_in(7 downto 0) OR south_pkt_in(7 downto 0) OR east_pkt_in(7 downto 0) OR west_pkt_in(7 downto 0);
	sig_local_target <= north_pkt_in(39 downto 36) OR south_pkt_in(39 downto 36)OR east_pkt_in(39 downto 36) OR west_pkt_in(39 downto 36);

	sig_tag <= std_logic_vector(1 + to_unsigned((to_integer(unsigned(sig_local_flag)) + to_integer(unsigned(sig_local_target))  + to_integer(unsigned(sig_local_data)) + to_integer(unsigned(key_in)) + to_integer(unsigned(node_ID))), 8));

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
				   pkt_drop 	=> pkt_drop,
				   local_tag 	=> sig_tag,
				   tag_seg 		=> tag_seg
		);


--================================================


end Behavioral;

