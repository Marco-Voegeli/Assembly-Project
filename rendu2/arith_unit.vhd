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

    signal mux01, mux02 :  unsigned(7 downto 0);
    signal mux03, mux04, mux06, BC_PLUS_A, MUX03_PLUS_B, MUX03_PLUS_B_n, TWO_A: unsigned(31 downto 0);
    signal temp_P02, temp_P03 :  unsigned(31 downto 0);
    signal temp_P01, temp_P01_n : unsigned(15 downto 0);
    signal s_done, s_sel: std_logic;
begin
    mul01 : multiplier
    PORT MAP(
        A => mux01,
        B => mux02,
        P => temp_P01); --GIVES A^2 OR BC

    mul02 : multiplier16
    PORT MAP(
        A => mux04(15 downto 0),
        B => temp_P01_n,    
        P => temp_P02); --GIVES A^4 OR BC(BC+A+B)

    mul03 : multiplier16
        PORT MAP(
            A => MUX03_PLUS_B_n(15 downto 0),
            B => MUX03_PLUS_B_n(15 downto 0),
            P => temp_P03); --GIVES (2A+B)^2

    main: process(clk, reset_n)
    begin
        if(reset_n = '0') then
            temp_P01_n <= (15 downto 0 => '0');
            MUX03_PLUS_B_n <= (31 downto 0 => '0');
            s_done <= '0';
            s_sel <= '0';
        else if (rising_edge(clk)) then
            temp_P01_n <= temp_P01;
            MUX03_PLUS_B_n <= MUX03_PLUS_B;
            s_done <= start;
            s_sel <= sel;
        end if;
        end if;
    end process main;

    mux01 <= A WHEN (sel = '1') ELSE B;  -- A OR B
    mux02 <= A WHEN (sel = '1') ELSE C;  -- A OR C
    BC_PLUS_A <= ((15 downto 0 => '0') & temp_P01) + A; --first addition BC + A
    TWO_A <= (31 downto 9 => '0') & A & "0"; -- 2A Changed to only one 0 instead of two
    mux03 <= TWO_A WHEN (sel = '1') ELSE BC_PLUS_A;  -- BC+A OR 2A
    MUX03_PLUS_B <= mux03 + B ; --second addition BC+A+B OR 2A+B
    mux04 <= ((15 downto 0 => '0') & temp_P01_n) WHEN (s_sel = '1') ELSE MUX03_PLUS_B_n; --BC+A+B OR A^2
    mux06 <= temp_P03 + temp_P02 WHEN (s_sel= '1') ELSE temp_P02; -- A^4+(2A+B)^2 OR BC(BC+B+A)
    D <= mux06;
    done <= s_done;
    

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
      signal mux01, mux02 :  unsigned(7 downto 0);
    signal mux03, mux04, mux06, BC_PLUS_A, MUX03_PLUS_B, MUX03_PLUS_B_n, TWO_A: unsigned(31 downto 0);
    signal temp_P02, temp_P02_n, temp_P03, temp_P03_n :  unsigned(31 downto 0);
    signal temp_P01, temp_P01_n : unsigned(15 downto 0);
    signal s_done, s_done2, s_sel, s_sel2: std_logic;
begin
    mul01 : multiplier
    PORT MAP(
        A => mux01,
        B => mux02,
        P => temp_P01); --GIVES A^2 OR BC

    mul02 : multiplier16
    PORT MAP(
        A => mux04(15 downto 0),
        B => temp_P01_n,    
        P => temp_P02); --GIVES A^4 OR BC(BC+A+B)

    mul03 : multiplier16
        PORT MAP(
            A => MUX03_PLUS_B_n(15 downto 0),
            B => MUX03_PLUS_B_n(15 downto 0),
            P => temp_P03); --GIVES (2A+B)^2

    first: process(clk, reset_n)
    begin
        if(reset_n = '0') then
            temp_P01_n <= (15 downto 0 => '0');
            MUX03_PLUS_B_n <= (31 downto 0 => '0');
            s_done <= '0';
            s_sel <= '0';
        else if (rising_edge(clk)) then
            temp_P01_n <= temp_P01;
            MUX03_PLUS_B_n <= MUX03_PLUS_B;
            s_done <= start;
            s_sel <= sel;
        end if;
        end if;
    end process;

    second: process(clk, reset_n)
    begin
        if(reset_n = '0') then
            temp_P03_n <= (31 downto 0 => '0');
            temp_P02_n <= (31 downto 0 => '0');
            s_done2 <= '0';
            s_sel2 <= '0';
        else if (rising_edge(clk)) then
            temp_P03_n <= temp_P03;
            temp_P02_n <= temp_P02;
            s_done2 <= s_done;
            s_sel2 <= s_sel;
        end if;
        end if;
    end process;

    mux01 <= A WHEN (sel = '1') ELSE B;  -- A OR B
    mux02 <= A WHEN (sel = '1') ELSE C;  -- A OR C
    BC_PLUS_A <= ((15 downto 0 => '0') & temp_P01) + A; --first addition BC + A
    TWO_A <= (31 downto 9 => '0') & A & "0"; -- 2A Changed to only one 0 instead of two
    mux03 <= TWO_A WHEN (sel = '1') ELSE BC_PLUS_A;  -- BC+A OR 2A
    MUX03_PLUS_B <= mux03 + B ; --second addition BC+A+B OR 2A+B
    mux04 <= ((15 downto 0 => '0') & temp_P01_n) WHEN (s_sel = '1') ELSE MUX03_PLUS_B_n; --BC+A+B OR A^2
    mux06 <= temp_P03_n + temp_P02_n WHEN (s_sel2= '1') ELSE temp_P02_n; -- A^4+(2A+B)^2 OR BC(BC+B+A)
    D <= mux06;
    done <= s_done2;
    

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
    signal mux01, mux02 :  unsigned(7 downto 0);
    signal mux03, mux04, mux06, BC_PLUS_A, MUX03_PLUS_B, MUX03_PLUS_B_n, TWO_A: unsigned(31 downto 0);
    signal temp_P02, temp_P03 :  unsigned(31 downto 0);
    signal temp_P01, temp_P01_n : unsigned(15 downto 0);
    signal s_done, s_sel, s_done2, s_sel2: std_logic;
  begin
    mul01 : multiplier
    PORT MAP(
        A => mux01,
        B => mux02,
        P => temp_P01); --GIVES A^2 OR BC

    mul02 : multiplier16_pipeline
    PORT MAP(
        clk => clk,
        reset_n => reset_n,
        A => mux04(15 downto 0),
        B => temp_P01_n,    
        P => temp_P02); --GIVES A^4 OR BC(BC+A+B)

    mul03 : multiplier16_pipeline
        PORT MAP(
            clk => clk,
            reset_n => reset_n,
            A => MUX03_PLUS_B_n(15 downto 0),
            B => MUX03_PLUS_B_n(15 downto 0),
            P => temp_P03); --GIVES (2A+B)^2

    main: process(clk, reset_n)
    begin
        if(reset_n = '0') then
            temp_P01_n <= (15 downto 0 => '0');
            MUX03_PLUS_B_n <= (31 downto 0 => '0');
            s_done <= '0';
            s_sel <= '0';
            s_sel2 <= '0';
            s_done <= '0';
        else if (rising_edge(clk)) then
            temp_P01_n <= temp_P01;
            MUX03_PLUS_B_n <= MUX03_PLUS_B;
            s_sel2 <= s_sel;
            s_done2 <= s_done;
            s_done <= start;
            s_sel <= sel;
        end if;
        end if;
    end process main;

    mux01 <= A WHEN (sel = '1') ELSE B;  -- A OR B
    mux02 <= A WHEN (sel = '1') ELSE C;  -- A OR C
    BC_PLUS_A <= ((15 downto 0 => '0') & temp_P01) + A; --first addition BC + A
    TWO_A <= (31 downto 9 => '0') & A & "0"; -- 2A Changed to only one 0 instead of two
    mux03 <= TWO_A WHEN (sel = '1') ELSE BC_PLUS_A;  -- BC+A OR 2A
    MUX03_PLUS_B <= mux03 + B ; --second addition BC+A+B OR 2A+B
    mux04 <= ((15 downto 0 => '0') & temp_P01_n) WHEN (s_sel = '1') ELSE MUX03_PLUS_B_n; --BC+A+B OR A^2
    mux06 <= temp_P03 + temp_P02 WHEN (s_sel2= '1') ELSE temp_P02; -- A^4+(2A+B)^2 OR BC(BC+B+A)
    D <= mux06;
    done <= s_done2;

end two_stage_pipeline_2;