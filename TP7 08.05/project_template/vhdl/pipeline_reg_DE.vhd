library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pipeline_reg_DE is
    port(
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        a_in          : in  std_logic_vector(31 downto 0);
        b_in          : in  std_logic_vector(31 downto 0);
        d_imm_in      : in  std_logic_vector(31 downto 0);
        sel_b_in      : in  std_logic;
        op_alu_in     : in  std_logic_vector(5 downto 0);
        read_in       : in  std_logic;
        write_in      : in  std_logic;
        sel_pc_in     : in  std_logic;
        branch_op_in  : in  std_logic;
        sel_mem_in    : in  std_logic;
        rf_wren_in    : in  std_logic;
        mux_in        : in  std_logic_vector(4 downto 0);
        next_addr_in  : in  std_logic_vector(15 downto 0);
        a_out         : out std_logic_vector(31 downto 0);
        b_out         : out std_logic_vector(31 downto 0);
        d_imm_out     : out std_logic_vector(31 downto 0);
        sel_b_out     : out std_logic;
        op_alu_out    : out std_logic_vector(5 downto 0);
        read_out      : out std_logic;
        write_out     : out std_logic;
        sel_pc_out    : out std_logic;
        branch_op_out : out std_logic;
        sel_mem_out   : out std_logic;
        rf_wren_out   : out std_logic;
        mux_out       : out std_logic_vector(4 downto 0);
        next_addr_out : out std_logic_vector(15 downto 0)
    );
end pipeline_reg_DE;
architecture synth of pipeline_reg_DE is
signal s_sel_b, s_read, s_write, s_sel_pc, s_branch_op, s_sel_mem, s_rf_wren : std_logic;
signal s_a, s_b, s_d_imm : std_logic_vector(31 downto 0);
signal s_op_alu : std_logic_vector(5 downto 0);
signal s_mux_out : std_logic_vector(4 downto 0);
signal s_next_addr : std_logic_vector(15 downto 0);
begin
main: process(reset_n, clk)
begin
if(reset_n = 0) then
    s_sel_b <= '0';
    s_read <= '0';
    s_write <= '0';
    s_sel_pc <= '0';
    s_branch_op <= '0';
    s_sel_mem <= '0';
    s_rf_wren <= '0';
    s_a <= (31 downto 0 => '0');
    s_b <= (31 downto 0 => '0');
    s_d_imm <= (31 downto 0 => '0');
    s_op_alu <= (5 downto 0 => '0');
    s_mux <= (4 downto 0 => '0');
    s_next_addr  <= (15 downto 0 => '0');
elsif(rising_edge(clk)) then
    s_sel_b <= sel_b_in;
    s_read <= read_in;
    s_write <= write_in;
    s_sel_pc <= sel_pc_in;
    s_branch_op <= branch_op_in;
    s_sel_mem <= sel_mem_in;
    s_rf_wren <= rf_wren_in;
    s_a <= a_in;
    s_b <= b_in;
    s_d_imm <= d_imm_in;
    s_op_alu <= op_alu_in;
    s_mux <= mux_in;
    s_next_addr <= next_addr_in;
end if;
end process main;
sel_b_out <= s_sel_b;
read_out <= s_read;
write_out <= s_write;
sel_pc_out <= s_sel_pc;
branch_op_out <= s_branch_op;
sel_mem_out <= s_sel_mem;
rf_wren_out <= s_rf_wren;
a_out <= s_a;
b_out <= s_b;
d_imm_out <= s_d_imm;
op_alu_out <= s_op_alu;
mux_out <= s_mux;
next_addr_out <= s_next_addr;
end synth;
