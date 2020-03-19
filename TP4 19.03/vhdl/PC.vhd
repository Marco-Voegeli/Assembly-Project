library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
signal s_imm : std_logic_vector(15 downto 0);
signal cur_addr : std_logic_vector(15 downto 0);
signal s_added: std_logic_vector(15 downto 0);
begin
s_imm <= imm(13 downto 0) & "00";
s_added <= std_logic_vector(signed(cur_addr) + signed(imm));
 
PC_process : process(clk,reset_n)

begin
    if(reset_n = '0') then
        cur_addr <= X"0000";
    else 
        if(rising_edge(clk)) then
            if(en = '1') then
                if(add_imm ='1') then
                    cur_addr <= s_added(15 downto 2) & "00"; 
                elsif(sel_imm = '1') then
                    cur_addr <= s_imm;
                elsif(sel_a = '1') then
                    cur_addr <= a(15 downto 2) & "00";
                elsif(sel_ihandler = '1') then
                    cur_addr <= X"0004";
                else
                    cur_addr <= std_logic_vector(signed(cur_addr) + 4);
            end if;
            end if;
        end if;
    end if;
end process PC_process;
addr <= (31 downto 16 => '0') & cur_addr; 
    
end synth;
