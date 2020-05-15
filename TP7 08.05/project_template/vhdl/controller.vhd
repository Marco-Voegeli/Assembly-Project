library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        rf_retaddr  : out std_logic_vector(4 downto 0);

        -- multiplexers selections
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
begin

    OP_ALU_Process : process (op,opx)
    begin
        case to_integer(unsigned(op)) is
            when 16#3A# =>                         
                case to_integer(unsigned(opx)) is 
                    when 16#1B#  =>  -- srl // R_OP
                        op_alu <= "110011"; 
                    when 16#0E# =>  -- and // R_OP
                        op_alu <= "100001"; 
                    when 16#31# => -- add // R_OP
                        op_alu <= "000000"; 
                    when 16#39# => -- sub // R_OP
                        op_alu <= "001000"; 
                    when 16#08# => -- cmple // R_OP
                        op_alu <= "011001";
                    when 16#10# => -- cmpgt // R_OP
                        op_alu <= "011010";
                    when 16#06# => -- nor // R_OP
                        op_alu <= "100000";                
                    when 16#16# => -- or // R_OP
                        op_alu <= "100010";
                    when 16#1E# => -- xnor // R_OP
                        op_alu <= "100011";
                    when 16#13# => -- sll // R_OP   
                        op_alu <= "110010";
                    when 16#3B# => -- sra // R_OP   
                        op_alu <= "110111";
                    when 16#12# => -- slli // I_R_OP
                        op_alu <= "110010";
                    when 16#1A# =>  -- srli // I_R_OP
                        op_alu <= "110011";     
                    when 16#3A# => -- srai // I_R_OP 
                        op_alu <= "110111";   
                    when 16#02# => -- roli // I_R_OP
                        op_alu <= "110000";
                    when 16#03# => -- rol // R_OP
                        op_alu <= "110000";
                    when 16#0B# => -- ror // R_OP
                        op_alu <= "110001";
                    when 16#18# =>  -- cmpne // R_OP
                        op_alu <= "011011";
                    when 16#20# =>  -- cmpeq // R_OP
                        op_alu <= "011100";
                    when 16#28# => -- cmpleu // R_IOP
                        op_alu <= "011101";
                    when 16#30# => -- cmpgtu // R_IOP
                        op_alu <= "011110";            
                    when others => null;    
                end case;
            when 16#04# => -- addi // I_OP
                op_alu <= "000000";
            when 16#17# => -- ldw // LOAD
                 -- For Load 1
                op_alu <= "000000";
            when 16#15# => -- stw // STORE
                op_alu <= "000000";
            when 16#06# => -- Special case for BRANCH
                 op_alu <= "011100";
            when 16#0E# => --ble // BRANCH
                op_alu <= "011001"; 
            when 16#16# => -- bgt // BRANCH
                op_alu <= "011010";    
            when 16#1E# => -- bne // BRANCH
                op_alu <= "011011";
            when 16#26# => -- beq // BRANCH
                op_alu <= "011100";
            when 16#2E# => -- bleu // BRANCH
                op_alu <= "011101";
            when 16#36# => -- bgtu // BRANCH
                op_alu <= "011110";
            when 16#0C# => --andi // I_IOP
                op_alu <= "100001";
            when 16#14# => -- ori // I_IOP
                op_alu <= "100010";
            when 16#1C# =>  --xnori // I_IOP
                op_alu <= "100011";
            when 16#08# =>  -- cmplei // I_OP
                op_alu <= "011001";   
            when 16#10# =>  -- cmpgti // I_OP
                op_alu <= "011010";
            when 16#18# =>  -- cmpnei // I_OP
                op_alu <= "011011";
            when 16#20# =>  -- cmpeqi // I_OP
                op_alu <= "011100";
            when 16#28# => -- cmpleui // I_IOP
                op_alu <= "011101";
            when 16#30# => -- cmpgtui // I_IOP
                op_alu <= "011110";     
            when others => null;
            end case;
    end process OP_ALU_Process;
 

    StateSwitch : process(op,opx)
    begin
        --Setting all outputs to 0
        imm_signed <= '0';
        branch_op  <= '0'; 
        ir_en      <= '0';
        pc_sel_a   <= '0';
        pc_sel_imm <= '0';
        rf_wren    <= '0';
        sel_b      <= '0';
        sel_mem    <= '0';
        sel_pc     <= '0';
        sel_ra     <= '0';
        sel_rC     <= '0';
        read       <= '0'; 
        write      <= '0';

            case to_integer(unsigned(op)) is
                when 16#3A# => 
                    case to_integer(unsigned(opx)) is 
                    --when 16#34# => 
                        --state_next <= BREAK; 
                    when 16#05# | 16#0D#  => 
                         pc_sel_a <= '1'; --JMP
                    when 16#02# | 16#3A# | 16#1A# | 16#12# =>
                        rf_wren <= '1'; --I_R_OP
                        sel_rC <= '1';  --I_R_OP
                    when 16#1D# =>
                        rf_wren <= '1';  --CALL_R
                        sel_pc  <= '1';  --CALL_R
                        sel_ra  <= '1';  --CALL_R
                        pc_sel_a <= '1'; --CALL_R
                    when others =>
                        sel_b <= '1';   --R_OP
                        sel_rC <= '1';  --R_OP
                        rf_wren <= '1'; --R_OP
                    end case;
                when 16#04# =>
                    rf_wren    <= '1'; --IOP
                    imm_signed <= '1'; --IOP
                when 16#17# =>
                    read <= '1';       --LOAD1
                    imm_signed <= '1'; --LOAD1
                    sel_rC <= '1';     --LOAD1
                    sel_mem <= '1';    --LOAD2
                    rf_wren <= '1';    --LOAD2
                when 16#15# =>
                    write <= '1';      --STORE
                    imm_signed <= '1'; --STORE
                when 16#06# | 16#0E# | 16#16# | 16#1E# | 16#26# | 16#2E# | 16#36# =>
                    --branch <= '1'; --BRANCH 
                    branch_op <= '1';  --BRANCH TODO IS THIS THE REPLACEMENT FOR PC_ADD_IMM?
                    sel_b <= '1';      --BRANCH 
                when 16#00# =>
                    rf_wren <= '1'; --CALL
                    sel_pc  <= '1'; --CALL
                    sel_ra  <= '1'; --CALL
                    pc_sel_imm <= '1'; --CALL                
                when 16#01# =>
                    pc_sel_imm <= '1';--JMPI
                when 16#0C# | 16#14# | 16#1C# | 16#08# | 16#10# | 16#18# | 16#20# | 16#28# | 16#30# => 
                    rf_wren    <= '1'; --I_IOP
                when others => null; 
    end case;
end process  StateSwitch;

rf_retaddr <= (4 downto 0 => '1'); 

end synth;

