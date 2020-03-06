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
    signal s_addr : std_logic_vector(1 downto 0);
    signal COUNTER, PERIOD, s_rddata : std_logic_vector(31 downto 0);

begin

generalProcess : process(clk,write, reset_n) 
begin
    if (reset_n = '0') then
        ITO <= '0';
        CONT <= '0';
        s_TO <= '0';
        RUN <= '0';
        COUNTER <= (31 downto 0 => '0'); 
        PERIOD <= (31 downto 0 => '0');
        s_rddata <= (31 downto 0 => '0');
        s_read <= '0';
        s_CS <= '0';
        s_addr <= (1 downto 0 => '0');
        
else
    if(rising_edge(clk)) then
        if(write = '1' AND cs = '1') then
            case s_addr is --shouldn't we check the address in terms of 0,1,2,3 because it is 2 bits
                when "01" => 
                        PERIOD <= wrdata;
                        COUNTER <= PERIOD; --Counter is reloaded when a write to PERIOD occurs
                when "10" =>  
                        ITO <= wrdata(1);
                        CONT <= wrdata(0);
                        if (wrdata(3) = '1' and RUN = '0') then
                            RUN <= '1';
                        end if;
                        if (wrdata(2) = '1' and RUN = '1') then
                            RUN <= '0';
                        end if;                           
                when "11" =>  
                        s_TO <= wrdata(1);
                        RUN <= wrdata(0);
                when others => 
            end case;
        end if;
        if (unsigned(COUNTER) = 0) then 
            if(CONT = '0') then
                RUN <= '0'; --should we modify this?
            end if;
            s_TO <= '1';
            COUNTER <= PERIOD;
        end if;
            if(RUN = '1') then
                COUNTER <= std_logic_vector(unsigned(COUNTER) - 1);
            end if;
    end if;
end if;
end process generalProcess;

s_addr <= address;
s_read <= read;
s_CS <= cs;
readProcess : process(clk,s_read) 
begin
    if(rising_edge(clk)) then
        if (s_read = '1' and s_CS = '1') then
            case s_addr is
                when "00" => s_rddata <= COUNTER;
                when "01" => s_rddata <= PERIOD;
                when "10" => s_rddata(3 downto 0) <= RUN & not(RUN) & ITO & CONT;
                when "11" => s_rddata(1 downto 0) <= s_TO & RUN; 
                when others => 
            end case;
        end if;
      --  s_addr <= address;
       -- s_CS <= cs;
        --s_READ <= read;
    end if;
end process readProcess;
rddata <= (31 downto 0 => 'Z') when read = '0' else s_rddata;
irq <= ITO AND s_TO; 

end synth;
