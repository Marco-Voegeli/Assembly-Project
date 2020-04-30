library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_unit is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
    );
end arith_unit;

-- =============================================================================
-- =============================== COMBINATORIAL ===============================
-- =============================================================================

architecture combinatorial of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

    signal mux01, mux02 :  unsigned(7 downto 0);
    signal mux03, mux04, mux05, BC_PLUS_A, MUX03_PLUS_B, TWO_A: unsigned(31 downto 0);
    signal mux06, temp_P01, temp_P02, temp_P03:  unsigned(31 downto 0);
  
begin
    mul01 : multiplier
    PORT MAP(
        A => mux01,
        B => mux02,
        P => temp_P01(15 downto 0)); --GIVES A^2 OR BC

    mul02 : multiplier16
    PORT MAP(
        A => mux04(15 downto 0),
        B => temp_P01(15 downto 0),    
        P => temp_P02); --GIVES A^4 OR BC(BC+A+B)

    mul03 : multiplier16
        PORT MAP(
            A => MUX03_PLUS_B(15 downto 0),
            B => MUX03_PLUS_B(15 downto 0),
            P => temp_P03); --GIVES (2A+B)^2

    mux01 <= A WHEN (sel = '1') ELSE B;  -- A OR B
    mux02 <= A WHEN (sel = '1') ELSE C;  -- A OR C
    BC_PLUS_A <= temp_P01 + A; --first addition BC + A
    TWO_A <= (31 downto 10 => '0') & A & "0"; -- 2A Changed to only one 0 instead of two
    mux03 <= TWO_A WHEN (sel = '1') ELSE BC_PLUS_A;  -- BC+A OR 2A
    MUX03_PLUS_B <= mux03 + B ; --second addition BC+A+B OR 2A+B
    mux04 <= temp_P01 WHEN (sel = '1') ELSE MUX03_PLUS_B; --BC+A+B OR A^2
    mux06 <= temp_P03 + temp_P02 WHEN (sel = '1') ELSE temp_P02; -- A^4+(2A+B)^2 OR BC(BC+B+A)
    D <= mux06;
    start <= done;
end combinatorial;

-- =============================================================================
-- ============================= 1 STAGE PIPELINE ==============================
-- =============================================================================

architecture one_stage_pipeline of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

    signal mux06, temp_P01,temp_P01_n, temp_P02, temp_P03:  unsigned(31 downto 0);
    signal mux01, mux02,B_n :  unsigned(7 downto 0);
    signal mux03,mux03_n, mux04, mux05, BC_PLUS_A, MUX03_PLUS_B, TWO_A: unsigned(31 downto 0);
  
    begin
        mul01 : multiplier
        PORT MAP(
            A => mux01,
            B => mux02,
            P => temp_P01(15 downto 0)); --GIVES A^2 OR BC
    
        mul02 : multiplier16
        PORT MAP(
            A => mux04(15 downto 0),
            B => temp_P01_n(15 downto 0),    
            P => temp_P02); --GIVES A^4 OR BC(BC+A+B)
    
        mul03 : multiplier16
            PORT MAP(
                A => MUX03_PLUS_B(15 downto 0),
                B => MUX03_PLUS_B(15 downto 0),
                P => temp_P03); --GIVES (2A+B)^2

        if (reset_n = '0') then
            mux06 <= (31 downto 0 => '0');
            temp_P01 <=(31 downto 0 => '0');
            temp_P01_n <=(31 downto 0 => '0');
            temp_P02 <=(31 downto 0 => '0');
            temp_P03 <=(31 downto 0 => '0');
            mux01 <= (7 downto 0 => '0');
            mux02 <= (7 downto 0 => '0');
            B_n  <= (7 downto 0 => '0');
            mux03  <= (31 downto 0 => '0');
            mux03_n <= (31 downto 0 => '0');
            mux04 <= (31 downto 0 => '0');
            mux05 <= (31 downto 0 => '0');
            BC_PLUS_A <= (31 downto 0 => '0');
            MUX03_PLUS_B <= (31 downto 0 => '0');
            TWO_A <= (31 downto 0 => '0');
        end if;
        if(rising_edge(clk)) then
            B_n <= B;
            mux03_n <= mux03;
            temp_P01_n <= temp_P01;
        end if;

        
            
        mux01 <= A WHEN (sel = '1') ELSE B;  -- A OR B
        mux02 <= A WHEN (sel = '1') ELSE C;  -- A OR C
        BC_PLUS_A <= temp_P01 + A; --first addition BC + A
        TWO_A <= (31 downto 10 => '0') & A & "0"; -- 2A Changed to only one 0 instead of two
        mux03 <= TWO_A WHEN (sel = '1') ELSE BC_PLUS_A;  -- BC+A OR 2A
        MUX03_PLUS_B <= mux03_n + B_n ; --second addition BC+A+B OR 2A+B
        mux04 <= temp_P01_n WHEN (sel = '1') ELSE MUX03_PLUS_B; --BC+A+B OR A^2
        mux06 <= temp_P03 + temp_P02 WHEN (sel = '1') ELSE temp_P02; -- A^4+(2A+B)^2 OR BC(BC+B+A)
        D <= mux06;
        done <= start;

end one_stage_pipeline;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE I =============================
-- =============================================================================

architecture two_stage_pipeline_1 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================

architecture two_stage_pipeline_2 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16_pipeline
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            A, B    : in  unsigned(15 downto 0);
            P       : out unsigned(31 downto 0)
        );
    end component;

begin
end two_stage_pipeline_2;
