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


 s_imm <= imm & "00";
PC_process : process(clk,reset_n)
begin
    if(reset_n = '0') then
        cur_addr <= 0 ;
    else 
        if(rising_edge(clk)) then
            if(en = '1') then
                if(add_imm ='1') then
                    cur_addr <= cur_addr + to_integer(signed(imm)); 
                elsif(sel_imm = '1') then
                    cur_addr <= to_integer(unsigned(s_imm));
                elsif(sel_a = '1') then
                    cur_addr <= to_integer(unsigned(a));
                elsif(sel_ihandler = '1') then
                    cur_addr <= to_integer(unsigned(sel_ihandler))
                else
                    cur_addr <= cur_addr + 4;
            end if;
            end if;
        end if;
    end if;
end process PC_process;
s_addr <= std_logic_vector(to_unsigned(cur_addr,32));
--addr <= s_addr(31 downto 2) & "00";
addr <= (31 downto 16 => '0') & s_addr(15 downto 2)  & "00"; 
    
    
begin
    
end synth;
