-- =============================================================================
-- ================================= multiplier ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        A, B : in  unsigned(7 downto 0);
        P    : out unsigned(15 downto 0)
    );
end multiplier;

architecture combinatorial of multiplier is
signal s_b_ext : unsigned(15 downto 0);
signal s_add_0, s_add_01, s_add_02, s_add_03, s_add_04, s_add_05, s_add_06, s_add_07 : unsigned(15 downto 0);
signal s_A_0,s_A_1,s_A_2,s_A_3 : unsigned(15 downto 0);
signal s_B_0,s_B_1 : unsigned(15 downto 0);
begin
    s_b_ext <= (15 downto 8 => '0') & B;
    s_add_0 <= (15 downto 0 => A(0)) AND s_b_ext;
    s_add_01 <= (15 downto 0 => A(1)) AND s_b_ext;
    s_add_02 <= (15 downto 0 => A(2)) AND s_b_ext;
    s_add_03 <= (15 downto 0 => A(3)) AND s_b_ext;
    s_add_04 <= (15 downto 0 => A(4)) AND s_b_ext;
    s_add_05 <= (15 downto 0 => A(5)) AND s_b_ext;
    s_add_06 <= (15 downto 0 => A(6)) AND s_b_ext;
    s_add_07 <= (15 downto 0 => A(7)) AND s_b_ext;
    
    s_A_0 <= s_add_0 + (s_add_01(14 downto 0) & '0');
    s_A_1 <= s_add_02 + (s_add_03(14 downto 0) & '0');
    s_A_2 <= s_add_04 + (s_add_05(14 downto 0) & '0');
    s_A_3 <= s_add_06 + (s_add_07(14 downto 0) & '0');

    s_B_0 <= s_A_0 + (s_A_1(13 downto 0) & "00");
    s_B_1 <= s_A_2 + (s_A_3(13 downto 0) & "00");
    
    P <= s_B_0 + (s_B_1(11 downto 0) & "0000");

end combinatorial;


-- =============================================================================
-- =============================== multiplier16 ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16 is
    port(
        A, B : in  unsigned(15 downto 0);
        P    : out unsigned(31 downto 0)
    );
end multiplier16;

architecture combinatorial of multiplier16 is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    signal s_lsb,s_msb,s_lsb8,s_msb8, s_upper:  unsigned(15 downto 0);

    begin
    LSB8_LSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0),
        B => B(7 downto 0),
        P => s_lsb);
    MSB8_MSB_MUL : multiplier
    PORT MAP(
        A => A(15 downto 8),
        B => B(15 downto 8),
        P => s_msb);
    LSB8_MSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0),
        B => B(15 downto 8),
        P => s_lsb8);
    MSB8_LSB_MUL : multiplier
    PORT MAP(
        A => A(15 downto 8),
        B => B(7 downto 0),
        P => s_msb8);
    P <= ((15 downto 0 => '0') & s_lsb)  + (((7 downto 0 => '0') & s_msb8) + ((7 downto 0 => '0') & s_lsb8) & (7 downto 0 => '0')) + (s_msb & (15 downto 0 => '0'));

end combinatorial;



-- =============================================================================
-- =========================== multiplier16_pipeline ===========================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16_pipeline is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        A, B    : in  unsigned(15 downto 0);
        P       : out unsigned(31 downto 0)
    );
end multiplier16_pipeline;

architecture pipeline of multiplier16_pipeline is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    signal s_lsb,s_msb,s_lsb8,s_msb8, s_upper:  unsigned(15 downto 0);
    signal s_lsb_n,s_msb_n,s_lsb8_n,s_msb8_n, s_upper_n : unsigned(15 downto 0);
begin
    LSB8_LSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0),
        B => B(7 downto 0),
        P => s_lsb);

    MSB8_MSB_MUL : multiplier
    PORT MAP(
        A => A(15 downto 8),
        B => B(15 downto 8),
        P => s_msb);

    LSB8_MSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0),
        B => B(15 downto 8),
        P => s_lsb8);

    MSB8_LSB_MUL : multiplier
    PORT MAP(
        A => A(15 downto 8),
        B => B(7 downto 0),
        P => s_msb8);
    
main : process(clk, reset_n)
    begin
        if(reset_n = '0') then
        s_lsb_n <= (15 downto 0 => '0');
        s_msb_n <= (15 downto 0 => '0');
        s_lsb8_n <= (15 downto 0 => '0');
        s_msb8_n <= (15 downto 0 => '0');
        else
            if(rising_edge(clk)) then
                s_lsb_n <= s_lsb;
                s_msb_n <= s_msb;
                s_lsb8_n <= s_lsb8;
                s_msb8_n <= s_msb8;
            end if;
        end if;

end process main;
P <= ((15 downto 0 => '0') & s_lsb_n)  + (((7 downto 0 => '0') & s_msb8_n) + ((7 downto 0 => '0') & s_lsb8_n) & (7 downto 0 => '0')) + (s_msb_n & (15 downto 0 => '0'));

end pipeline;




