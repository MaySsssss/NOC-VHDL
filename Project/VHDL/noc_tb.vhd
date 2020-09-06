LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
USE ieee.numeric_std.ALL;

USE STD.textio.all;
use ieee.std_logic_textio.all;
 
ENTITY noc_tb IS
END noc_tb;
 
ARCHITECTURE behavior OF noc_tb IS 
    -- Component Declaration for the Unit Under Test (UUT) 
    COMPONENT NOC
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
		 network				: out std_logic_vector(23 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   
   signal network : std_logic_vector(23 downto 0) := (others => '0');
   
   file file_RESULTS : text;
   constant c_WIDTH : natural := 24;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: NOC PORT MAP (
          clk => clk,
          reset => reset,
		  network => network
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
	  reset <= '1';
	  wait for 10 ns;
	  reset <= '0';
    wait;
   end process;
   
   -- Store the signals
   process
		variable v_OLINE     : line;
   begin
		file_open(file_RESULTS, "output_results.txt", write_mode);
		wait for 1000 ns;
		for k in 0 to c_WIDTH loop
		    write(v_OLINE, network(c_WIDTH - k - 1), right, 1);
			writeline(file_RESULTS, v_OLINE);
	    end loop;
		file_close(file_RESULTS);
		wait;
   end process;

END;
