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
    signal add_01,add_02,add_03,add_04,add_05,add_06,add_07 : unsigned(7 downto 0);

begin

    add_01 = (A(0) AND B) + ((A(1) AND B) & "0");
    add_02 = (A(2) AND B) + ((A(3) AND B) & "0");
    add_03 = (A(4) AND B) + ((A(5) AND B) & "0");
    add_04 = (A(6) AND B) + ((A(7) AND B) & "0");
    add_05 = add_01 + (add_02 & "00");
    add_06 = add_03 + (add_04 & "00");
    add_07 = add_05 + (add_06 & "0000");
    P <= add_07

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

    signal temp_P01,temp_P02,temp_P03,temp_P04:  unsigned(15 downto 0);

begin
    8LSB_LSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0)
        B => B(7 downto 0);
        P => temp_P01);

    8MSB_MSB_MUL : multiplier
    PORT MAP(
        A => A(15 downto 8)
        B => B(15 downto 8);
        P => temp_P02);

    8LSB_MSB_MUL : multiplier
    PORT MAP(
        A => A(7 downto 0)
        B => B(15 downto 8);
        P => temp_P03);

    8MSB__LSB_ MUL : multiplier
    PORT MAP(
        A => A(15 downto 8)
        B => B(7 downto 0);
        P => temp_P04);
    
    P <= temp_P01 + ((temp_P02 + temp_P03) & "00000000") + (temp_P04 & "0000000000000000");

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

begin
end pipeline;
