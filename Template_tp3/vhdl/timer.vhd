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

    signal ITO,CONT,s_TO,RUN,s_read,s_CS : std_logic;
    signal COUNTER, PERIOD, s_rddata : std_logic_vector(31 downto 0);

begin

generalProcess : process(reset_n, clk, read, cs, RUN, COUNTER, CONT, PERIOD, wrdata) 
begin
    if (reset_n = '0') then
        ITO <= '0';
        CONT <= '0';
        s_TO <= '0';
        RUN <= '0';
        COUNTER <= (31 downto 0 => '0'); 
        PERIOD <= (31 downto 0 => '0');
        s_read <= '0';
        s_CS <= '0';
else
    if(rising_edge(clk)) then
        s_read <= read;
        s_CS <= cs;
        if(RUN = '1') then
        if (unsigned(COUNTER) = 0) then 
            RUN <= CONT;
            s_TO <= '1';
            COUNTER <= PERIOD;
        else
            COUNTER <= std_logic_vector(unsigned(COUNTER) - 1);
        end if;
        end if;
        if(write = '1' AND cs = '1') then
            case address is --shouldn't we check the address in terms of 0,1,2,3 because it is 2 bits
                when "01" => 
                    PERIOD <= wrdata;
                    COUNTER <= wrdata; --Counter is reloaded when a write to PERIOD occurs
                when "10" =>  
                    ITO <= wrdata(1);
                    CONT <= wrdata(0);
                    if (wrdata(3) = '1') then
                        RUN <= '1';
                    end if;
                    if (wrdata(2) = '1') then
                        RUN <= '0';
                    end if;                           
                when "11" =>  
                        s_TO <= wrdata(1);
                when others => 
            end case;
        end if;

    end if;
end if;
end process generalProcess;

readProcess : process(clk,s_read, s_CS, COUNTER, PERIOD, RUN, ITO, CONT, s_TO, address) 
begin
        if (s_read = '1' and s_CS = '1') then
            s_rddata <= (others => '0');
            case address is
                when "00" => s_rddata <= COUNTER;
                when "01" => s_rddata <= PERIOD;
                when "10" => s_rddata(3 downto 0) <= "00" & ITO & CONT;
                when "11" => s_rddata(1 downto 0) <= s_TO & RUN; 
                when others => 
            end case;
        end if;
end process readProcess;
rddata <= (31 downto 0 => 'Z') when read = '0' else s_rddata;
irq <= ITO AND s_TO; 

end synth;
