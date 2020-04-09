library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is

    signal s_ITO,s_CONT,s_TO,s_RUN,s_read, s_write: std_logic;
    signal s_addr : std_logic_vector (1 downto 0);
    signal s_COUNTER, s_PERIOD, s_rddata : std_logic_vector(31 downto 0);

begin

s_write <= cs and write; 

generalProcess : process(reset_n, clk, read, cs, address, s_RUN, s_PERIOD, s_CONT, s_write, wrdata) 
begin
    if (reset_n = '0') then
        s_COUNTER <= (31 downto 0 => '0'); 
        s_PERIOD <= (31 downto 0 => '0');
        s_ITO <= '0';
        s_CONT <= '0';
        s_TO <= '0';
        s_RUN <= '0';
        s_read <= '0';   
else
    if(rising_edge(clk)) then
        s_read <= read and cs;
        s_addr <= address;

        if(s_RUN = '1') then
            if (s_COUNTER = (31 downto 0 => '0')) then 
                s_COUNTER <= s_PERIOD;
                s_RUN <= s_CONT;
                s_TO <= '1';
            else
                s_COUNTER <= std_logic_vector(unsigned(s_COUNTER) - 1);
            end if;
        end if;
        if(s_write = '1') then
            case address is --shouldn't we check the address in terms of 0,1,2,3 because it is 2 bits
                when "01" => 
                    s_PERIOD <= wrdata;
                    s_COUNTER <= wrdata;
                    s_RUN <= '0'; --Counter is reloaded when a write to s_PERIOD occurs
                when "10" =>  
                    if (wrdata(3) = '1' and  s_RUN = '0') then
                        s_RUN <= '1';
                    elsif (wrdata(2) = '1' and  s_RUN = '1') then
                        s_RUN <= '0';
                    end if;
                    s_ITO <= wrdata(1);
                    s_CONT <= wrdata(0);
                when "11" =>  
                    if (wrdata(1) = '0') then
                        s_TO <= '0';
                    end if;
                when others => 
            end case;
        end if;
    end if;
end if;
end process generalProcess;

readProcess : process(clk,s_read, s_COUNTER, s_PERIOD, s_RUN, s_ITO, s_CONT, s_TO, s_addr) 
begin
        case s_addr is
            when "00" => s_rddata <= s_COUNTER;
            when "01" => s_rddata <= s_PERIOD;
            when "10" => s_rddata <= (31 downto 2 => '0') & s_ITO & s_CONT;
            when "11" => s_rddata <= (31 downto 2 => '0') & s_TO & s_RUN; --Changed this such that we set the complete rddata to 0 except for the last two bits
            when others => 
        end case;
end process readProcess;
rddata <= s_rddata when s_read = '1' else (31 downto 0 => 'Z');

irq <= s_ITO AND s_TO; 

end synth;
