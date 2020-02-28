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

    signal ITO,CONT,s_TO,RUN,s_READ,s_CS : std_logic;
    signal s_addr : std_logic_vector(1 downto 0);
    signal COUNTER, PERIOD : std_logic_vector(31 downto 0);

begin

generalProcess : process(clk,write, reset_n) 
begin
    if (reset_n = '0') then
        ITO <= '0';
        CONT <= '0';
        s_TO <= '0';
        RUN <= '0';
        COUNTER <= "0"; 
        PERIOD <= "0";
        s_READ <= '0';
        s_CS <= '0';
        s_addr <= "0";
else
    if(rising_edge(clk)) then
        if(write = '1' AND cs = '1') then
            case address is --shouldn't we check the address in terms of 0,1,2,3 because it is 2 bits
                when std_logic_vector(to_unsigned(4,2)) =>  PERIOD <= wrdata;
                                COUNTER <= PERIOD;
                when std_logic_vector(to_unsigned(8,2)) =>  ITO <= wrdata(1);
                                CONT <= wrdata(0);
                                if (wrdata(3) = '1') then
                                RUN <= '1'; else 
                                RUN <= '0';
                                end if;
                when std_logic_vector(to_unsigned(12,2)) =>  s_TO <= wrdata(1);
                                RUN <= wrdata(0);
                when others => 
            end case;
        end if;
        if (COUNTER = (others => '0')) then --problem aqui
            if(CONT = '0') then
                RUN <= '0';
            end if;
            s_TO <= '1';
            COUNTER <= PERIOD;
        else
            if(RUN = '1') then
                COUNTER <= std_logic_vector(to_unsigned(COUNTER) - 1),32);
            end if;
        end if;
    end if;
end if;
end process generalProcess;

readProcess : process(clk,s_read) 
begin
    if(rising_edge(clk)) then
        if (s_read = '1' and s_CS = '1') then
            case s_addr is
                when 16#00# => rddata <= COUNTER;
                when 16#04# =>  rddata <= PERIOD;
                when 16#08# => 
                                rddata <= RUN & not(RUN) & ITO & CONT;
                when 16#12# => 
                                rddata <= s_TO & RUN; 
                when others => 
            end case;
        end if;
        s_addr <= address;
        s_CS <= cs;
        s_READ <= read;
    end if;
end process readProcess;

irq <= ITO AND s_TO; 

end synth;
