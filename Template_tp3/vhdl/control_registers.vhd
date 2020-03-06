library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is

signal s_rddata, s_ctl0, s_ctl1, s_ctl3, s_ctl4, s_ctl5: std_logic_vector(31 downto 0); --Please put their actual names

begin

main: process(clk, reset_n)
begin
    if (reset_n = '0') then 
            s_rddata <= (31 downto 0 => '0');
            s_ctl0 <= (31 downto 0 => '0'); 
            s_ctl1 <= (31 downto 0 => '0');
            s_ctl3 <= (31 downto 0 => '0');
            s_ctl4 <= (31 downto 0 => '0');
            s_ctl5 <= (31 downto 0 => '0');
            ipending <= '0';
    else
        if(rising_edge(clk)) then
            if(write_n = '0') then 
                case address is
                    when "000" => s_ctl0 <= wrdata;
                    when "001" => s_ctl1 <= wrdata;
                    when "011" => s_ctl3 <= wrdata;
                    when "100" => s_ctl4 <= wrdata;
                    when "101" => s_ctl5 <= wrdata;
                    when others =>
                end case;
            end if;
            if(backup_n = '0') then
                s_ctl1(0) <= s_ctl0(0);
                s_ctl0(0) <= '0';
            end if;
            if(restore_n = '0') then
                s_ctl0(0) <= s_ctl1(0);
            end if;
        end if;
        case address is
            when "000" => s_rddata <= s_ctl0;
            when "001" => s_rddata <= s_ctl1;
            when "011" => s_rddata <= s_ctl3;
            when "100" => s_rddata <= s_ctl4;
            when "101" => s_rddata <= s_ctl5;
            when others =>
        end case;
    end if;   
end process main; 

ipending <= '1' when s_ctl0(0) = '1' and (s_ctl4 /= (31 downto 0 => '0')) else '0';
end synth;
