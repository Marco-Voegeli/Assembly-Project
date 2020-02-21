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

    signal ITO,CONT,TO,RUN : std_logic;
    signal COUNTER, PERIOD : std_logic_vector(31 downto 0);

begin

writeProcess : process(clk,write) 
begin
if (reset_n = '0') then
????
else
    if(rising_edge(clk)) then
        if(write = '1' AND cs = '1') then
            case address is
                when 16#04# =>  PERIOD <= wrdata;
                when 16#08# =>  ITO <= wrdata(1);
                                CONT <= wrdata(0);
                                RUN <= '1' when wrdata(3) = '1' else '0';
                when 16#12# =>  TO <= wrdata(1);
                                RUN <= wrdata(0);
            end case;
        end if;
    end if;
end if;
end process writeProcess;


statusProcess : process(clk) 
if(rising_edge(clk)) then
    if (COUNTER = '0') then
        if(CONT = '0') then
            STOP <= '1';
        end if;
        TO <= '1';
        COUNTER <= PERIOD;
    else
        COUNTER = std_logic_vector(to_unsigned(COUNTER) - 1));
    end if;
end if;


irq <= ITO AND TO; 

end synth;
