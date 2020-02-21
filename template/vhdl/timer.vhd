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

    signal ITO,CONT,TO,RUN,s_READ,s_CS : std_logic;
    signal s_addr : std_logic_vector(1 downto 0);
    signal COUNTER, PERIOD : std_logic_vector(31 downto 0);

begin

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
                                rddata <= TO & RUN; 
                when others => 
            end case;
        end if;
    end if;
end process readProcess;

FP : process(clk) 
begin 
    if(rising_edge(clk)) then
        s_addr <= address;
        s_CS <= cs;
        s_READ <= read;
    end if;
end process FP;
       


writeProcess : process(clk,write, reset_n) 
begin
    if (reset_n = '0') then
        ITO <= '0';
        CONT <= '0';
        TO <= '0';
        RUN <= '0';
        COUNTER <= '0'; 
        PERIOD <= '0';
        s_READ <= '0';
        s_CS <= '0';
        s_addr <= '0':
else
    if(rising_edge(clk)) then
        if(write = '1' AND cs = '1') then
            case address is
                when 16#04# =>  PERIOD <= wrdata;
                                COUNTER <= PERIOD;
                when 16#08# =>  ITO <= wrdata(1);
                                CONT <= wrdata(0);
                                RUN <= '1' when wrdata(3) = '1' else '0';
                when 16#12# =>  TO <= wrdata(1);
                                RUN <= wrdata(0);
                when others => 
            end case;
        end if;
        if (COUNTER = '0') then
            if(CONT = '0') then
                RUN <= '0';
            end if;
            TO <= '1';
            COUNTER <= PERIOD;
        else
            if(RUN = '1') then
                COUNTER = std_logic_vector(to_unsigned(COUNTER) - 1));
            end if;
        end if;
    end if;
end if;

end process writeProcess;

irq <= ITO AND TO; 

end synth;
