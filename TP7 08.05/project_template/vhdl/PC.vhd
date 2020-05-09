library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is
    signal mux01,mux02,big_mux,s_next_addr,add01,add02,add03  : std_logic_vector(15 downto 0);
	 signal sel_conc : std_logic_vector(1 downto 0);
begin


main: process(reset_n, clk)
begin
if (reset_n = '0') then
    s_next_addr <= (15 downto 0 => '0');
elsif(rising_edge(clk)) then
    s_next_addr <= big_mux;
end if;
end process main;

mux03: process(sel_imm, sel_a)
begin
sel_conc <= sel_imm & sel_a;
case  (sel_conc) is
    when ("00")  =>  
        big_mux <= add02;
    when ("01")=>  
        big_mux <= add03;
    when ("10")  => 
        big_mux <= d_imm(13 downto 0) & "00";
    when others => null;
end case;
end process mux03;


add01 <= e_imm + ((15 downto 3 => '0') & "100");
mux01 <= pc_addr WHEN (branch = '1') ELSE s_next_addr; 
mux02 <= add01 WHEN (branch = '1') ELSE X"0004"; 
add02 <= mux01 + mux02;
add03 <= X"4" + a;
next_addr <= s_next_addr;
addr <= big_mux;

end synth;
