library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity controller is
    port(
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        imm_signed : out std_logic;
        sel_b      : out std_logic;
        op_alu     : out std_logic_vector(5 downto 0);
        read       : out std_logic;
        write      : out std_logic;
        sel_pc     : out std_logic;
        branch_op  : out std_logic;
        sel_mem    : out std_logic;
        rf_wren    : out std_logic;
        pc_sel_imm : out std_logic;
        pc_sel_a   : out std_logic;
        sel_ra     : out std_logic;
        rf_retaddr : out std_logic_vector(4 downto 0);
        sel_rC     : out std_logic
    );
end controller;

architecture synth of controller is
type state_type is (F1, F2, DEC, R_OP,STORE,LOAD1,LOAD2,IOP,BRANCH,CALL,JMP,JMP_I,I_IOP,CALL_R, I_R_OP);
 signal state_curr : state_type;
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
 

    StateSwitch : process(state_curr,op,opx)
    begin
        --Setting all outputs to 0
        imm_signed <= '0';
        branch_op  <= '0';
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

        case state_curr is
            when F1 => 
                read <= '1';
                state_curr <= F2;
            when F2 =>
                state_curr <= DEC;
            when IOP =>
                rf_wren    <= '1';
                imm_signed <= '1';
                state_curr <= F1;
            when I_IOP =>
                rf_wren    <= '1';
                state_curr <= F1;
            when R_OP =>
                sel_b <= '1';
                sel_rC <= '1'; 
                rf_wren <= '1';
                state_curr <= F1;
            when I_R_OP =>
                rf_wren <= '1';
                sel_rC <= '1'; 
                state_curr <= F1;
            when STORE =>
                write <= '1';
                imm_signed <= '1';
                state_curr <= F1;
            when BRANCH =>
                branch_op <= '1';
                sel_b <= '1';
                state_curr <= F1;
            when JMP =>
                pc_sel_a <= '1';
                state_curr <= F1;
            when JMP_I =>
                pc_sel_imm <= '1';
                state_curr <= F1;
            when CALL =>  
                rf_wren <= '1';
                sel_pc  <= '1';
                sel_ra  <= '1';
                pc_sel_imm <= '1';
                state_curr <= F1;
            when CALL_R => 
                rf_wren <= '1';
                sel_pc  <= '1';
                sel_ra  <= '1';
                pc_sel_a <= '1';
                state_curr <= F1;
            when LOAD1 =>
                read <= '1';
                imm_signed <= '1';
                state_curr <= LOAD2;
            when LOAD2 =>
                sel_mem <= '1';
                rf_wren <= '1';
                state_curr <= F1;

            when DEC =>
                case to_integer(unsigned(op)) is
                    when 16#3A# => 
                        case to_integer(unsigned(opx)) is 
                        when 16#05# | 16#0D#  => 
                            state_curr <= JMP; 
                        when 16#02# | 16#3A# | 16#1A# | 16#12# =>
                            state_curr <= I_R_OP;
                        when 16#1D# =>
                            state_curr <= CALL_R;    
                        when others => 
                            state_curr <= R_OP;
                        end case;
                    when 16#04# =>
                         state_curr <= IOP;
                    when 16#17# =>
                        state_curr <= LOAD1;
                    when 16#15# =>
                        state_curr <= STORE;
                    when 16#06# | 16#0E# | 16#16# | 16#1E# | 16#26# | 16#2E# | 16#36# =>
                        state_curr <= BRANCH;
                    when 16#00# =>
                            state_curr <= CALL;                    
                    when 16#01# =>
                        state_curr <= JMP_I;
                    when 16#0C# | 16#14# | 16#1C# | 16#08# | 16#10# | 16#18# | 16#20# | 16#28# | 16#30# => 
                        state_curr <= I_IOP;
                when others => null; 
            end case;
            when others => null;
        end case;
    end process  StateSwitch;
    rf_retaddr <= (4 downto 0 => '1');
end synth;
