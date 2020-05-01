library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity arith_unit_tb is
end;

architecture bench of arith_unit_tb is
    signal A, B, C : unsigned(7 downto 0);
    signal clk       : std_logic                     := '0';
    signal start, sel, done, reset_n: std_logic;
    signal D    : unsigned(31 downto 0);
    signal finished : boolean := false;
    component arith_unit is
        port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
        );
    end component;
  constant CLK_PERIOD : time := 5 ns;
begin
    arith_com : arith_unit port map(
            clk => clk,
            reset_n => reset_n,
            start => start,
            sel => sel, 
            A => A,
            B => B,
            C => C,
            D => D, 
            done => done
        );

   check: process
        variable err         : boolean := false;
        variable line_output : line;
     begin
        reset_n <= '0';
        wait for 5 ns;
        reset_n <= '1';
       
        for i in 0 to 10 loop
            for j in 0 to 10 loop
                for k in 0 to 10 loop
                start <= '1';
                sel <= '1';
                A <= to_unsigned(i, 8);
                B <= to_unsigned(j, 8);
                C <= to_unsigned(k, 8);
                wait for 5 ns;
                start <= '0';
                if (D /= (i*i*i*i + (2*i + j) * (2*i + j)) and not err) then
                    err := true;
                    report "not matching!" severity ERROR;
                end if;
                 wait for 5 ns;
                sel <= '0';
                if (D /= (j*k*(j*k + j + i)) and not err) then
                    err := true;
                    report "not matching!" severity ERROR;
                end if;
            end loop;
            end loop;
        end loop;

        line_output := new string'("===================================================================");
        writeline(output, line_output);
        if (err) then
            line_output := new string'("Errors encountered during simulation.");
        else
            finished <= true;
            line_output := new string'("Simulation is successful");
        end if;
        writeline(output, line_output);
        line_output := new string'("===================================================================");
        writeline(output, line_output);
    end process;

 process
    begin
        if (finished) then
            wait;
        else
            clk <= not clk;
            wait for CLK_PERIOD / 2;
        end if;
    end process;
end bench;
