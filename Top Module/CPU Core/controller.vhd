----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
--
-- Create Date: 10/29/2020 07:18:24 PM
-- Updated Date: 01/11/2021
-- Design Name: CONTROLLER FOR THE CPU
-- Module Name: cpu - behavioral(controller)
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: CPU_LAB 3 - ECE 410 (2021)
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Additional Comments:
--*********************************************************************************
-- The controller implements the states for each instructions and asserts appropriate control signals for the datapath during every state.
-- For detailed information on the opcodes and instructions to be executed, refer the lab manual.
-----------------------------


LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- needed for CONV_INTEGER()

ENTITY controller IS PORT (
            clk_ctrl        : IN std_logic;
            rst_ctrl        : IN std_logic;
            enter           : IN std_logic;
            muxsel_ctrl     : OUT std_logic_vector(1 DOWNTO 0);
            imm_ctrl        : buffer std_logic_vector(7 DOWNTO 0);
            accwr_ctrl      : OUT std_logic;          
            rfaddr_ctrl     : OUT std_logic_vector(2 DOWNTO 0); 
            rfwr_ctrl       : OUT std_logic;
            alusel_ctrl     : OUT std_logic_vector(2 DOWNTO 0);
            outen_ctrl      : OUT std_logic;
            zero_ctrl       : IN std_logic;
            positive_ctrl   : IN std_logic;
            PC_out          : out std_logic_vector(4 downto 0);
            OP_out          : out std_logic_vector(3 downto 0);
            ---------------------------------------------------
            bit_sel_ctrl    : OUT std_logic;
            bits_shift_ctrl : OUT std_logic_vector(1 downto 0); 
            ---------------------------------------------------
            done            : out std_logic);
END controller;

architecture Behavior of controller is

TYPE state_type IS (Fetch,Decode,LDA_execute,STA_execute,LDI_execute, ADD_execute, SUB_execute, SHFL_execute, SHFR_execute,
                    input_A, output_A, Halt_cpu, JZ_execute, flag_state, ADD_SUB_SL_SR_next);

SIGNAL state: state_type;
SIGNAL IR: std_logic_vector(7 downto 0); -- Instruction register
SIGNAL PC: integer RANGE 0 to 31; -- Program counter
SIGNAL temp: std_logic_vector(4 downto 0);


-- Instructions and their opcodes (pre-decided)
    CONSTANT LDA : std_logic_vector(3 DOWNTO 0) := "0001";  
    CONSTANT STA : std_logic_vector(3 DOWNTO 0) := "0010";  
    CONSTANT LDI : std_logic_vector(3 DOWNTO 0) := "0011";  
    
    CONSTANT ADD : std_logic_vector(3 DOWNTO 0) := "0100"; 
    CONSTANT SUB : std_logic_vector(3 DOWNTO 0) := "0101"; 
    
    CONSTANT SHFL : std_logic_vector(3 DOWNTO 0) := "0110";  
    CONSTANT SHFR : std_logic_vector(3 DOWNTO 0) := "0111";  
    
    CONSTANT INA  : std_logic_vector(3 DOWNTO 0) := "1000";   
    CONSTANT OUTA : std_logic_vector(3 DOWNTO 0) := "1001";   
    CONSTANT HALT : std_logic_vector(3 DOWNTO 0) := "1010";   
    
    CONSTANT JZ   : std_logic_vector(3 DOWNTO 0) := "1100";
    
    TYPE PM_BLOCK IS ARRAY(0 TO 31) OF std_logic_vector(7 DOWNTO 0); -- program memory that will store the instructions sequentially from part 1 and part 2 test program
    
BEGIN
    
    --opcode is kept up-to-date
    OP_out <= IR(7 downto 4); -- Connect the OP-code output to the upper nibble of the Instruction Register
    
    PROCESS(clk_ctrl,rst_ctrl) -- complete the sensitivity list ********************************************
    
        -- "PM" is the program memory that holds the instructions to be executed by the CPU 
        VARIABLE PM                      : PM_BLOCK;     

        -- To decode the 4 MSBs from the PC content
        VARIABLE OPCODE                  : std_logic_vector( 3 DOWNTO 0);

        -- Zero flag and positive flag
        VARIABLE zero_flag, positive_flag: std_logic;
        
        BEGIN
            IF (rst_ctrl='1') THEN -- RESET initializes all the control signals to 0.
                PC <= 0;
                PC_out <= std_logic_vector(to_unsigned(PC,5));
                muxsel_ctrl <= "00";
                imm_ctrl <= (OTHERS => '0');
                accwr_ctrl <= '0';
                rfaddr_ctrl <= "000";
                rfwr_ctrl <= '0';
                alusel_ctrl <= "000";
                outen_ctrl <= '0';
                done       <= '0';
                bit_sel_ctrl <= '0';
                bits_shift_ctrl <= "00";
                state <= Fetch;    

-- *************** assembly code for PART1/PART2 goes here
                -- for example this is how the instructions will be stored in the program memory
--                PM(0) := "XXXXXXXX";    
                
                -- Part 1:
--                PM(0) := "10000001"; -- IN A
--                PM(1) := "10000000"; -- IN A
--                PM(2) := "11000000"; -- JMPZ 05
--                PM(3) := "00000101"; -- 05
--                PM(4) := "01100010"; -- SHFL A,02
--                PM(5) := "10010000"; -- OUT A
--                PM(6) := "00110000"; -- LDI A,10
--                PM(7) := "00001010"; -- 10
--                PM(8) := "01110001"; -- SHFR A,01
--                PM(9) := "10010000"; -- OUT A
--                PM(10) := "10100000"; -- HALT
                
                -- Part 2:
                PM(0) := "10000001"; -- IN A
                PM(1) := "10000000"; -- IN A
                PM(2) := "00100101"; -- STA R[5],A
                PM(3) := "00110000"; -- LDI A,15
                PM(4) := "00001111"; -- 15
                PM(5) := "01000101"; -- ADD A,R[5]
                PM(6) := "10010000"; -- OUT A
                PM(7) := "10100000"; -- HALT
-- **************

           ELSIF (clk_ctrl'event and clk_ctrl = '1') THEN
                CASE state IS
                    WHEN Fetch => -- fetch instruction, reads next instruction from memory into the Instruction Register
                                if(enter = '1')then -- Program told to start
                                    PC_out <= std_logic_vector(to_unsigned(PC,5)); -- Convert the program counter value to a 5-bit vector and output
	      			                -- ****************************************
                                    -- write one line of code to get the 8-bit instruction into IR                      
	                                IR <= PM(PC);
				                -------------------------------------------
			            
                                    PC <= PC + 1; -- The program counter increments after the instruction has been fetched
                                    muxsel_ctrl <= "00"; -- ALU output selected
                                    imm_ctrl <= (OTHERS => '0'); -- Immediate value input is 0
                                    accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                                    rfaddr_ctrl <= "000"; -- Register 0 selected
                                    rfwr_ctrl <= '0'; -- Reading from Register File
                                    alusel_ctrl <= "000"; -- ALU passes Accumulator value to MUX input 0
                                    outen_ctrl <= '0'; -- Output buffer outputs open cct
                                    done       <= '0'; -- Program not completed
                                    zero_flag := zero_ctrl;
                                    positive_flag := positive_ctrl;                                       
                                    state <= Decode; -- Next state is the decode state
                                elsif(enter = '0')then -- Program waits until its told to start
                                    state <= Fetch;
                                end if;

                    WHEN Decode => -- decode instruction, decodes OPCODE instruction and sets it as the next state
                    
                            OPCODE := IR(7 downto 4); -- Reads the upper nibble of the byte from program memory
                            
                            CASE OPCODE IS
                                WHEN LDA => -- 0001
                                state   <= LDA_execute;
                                
                                WHEN STA => -- 0010
                                state   <= STA_execute;
                                
                                WHEN LDI => -- 0011
                                state   <= LDI_execute;
                                
                                WHEN ADD => -- 0100
                                state   <= ADD_execute;
                                
                                WHEN SUB => -- 0101
                                state   <= SUB_execute;
                                
                                WHEN SHFL => -- 0110
                                state  <= SHFL_execute;
                                
                                WHEN SHFR => -- 0111
                                state  <= SHFR_execute;
                                
                                WHEN INA  => -- 1000
                                state  <= input_A;
                                
                                WHEN OUTA => -- 1001
                                state  <= output_A;
                                
                                WHEN HALT => -- 1010
                                state  <= Halt_cpu;
                                
                                WHEN JZ   => -- 1100
                                state  <= JZ_execute;
                                
                                WHEN OTHERS => 
                                state <= Halt_cpu;
                                
                            END CASE;
                            
                            muxsel_ctrl <= "00";
                            imm_ctrl <= PM(PC); -- Since the PC is incremented here, I am just doing the pre-fetching. Will relax the requirement for PM to be very fast for LDI to work properly.
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= IR(2 downto 0); -- Decode pre-emptively sets up the register file, just to reduce the delay for waiting one more cycle
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            bit_sel_ctrl <= IR(0); -- The input nibble select is set to the LSB of the instruction
                            bits_shift_ctrl <= IR(1 downto 0); -- The bit shift value is set to the 2 LSB of the instruction
                            
                            
                    WHEN flag_state => -- set zero and positive flags and then goto next instruction
                            muxsel_ctrl <= "00";
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= Fetch;
                            zero_flag := zero_ctrl;
                            positive_flag := positive_ctrl;     
                            
                    WHEN ADD_SUB_SL_SR_next => -- next state TO add, sub, shfl, shfr - store ALU output in Accumulator
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '1'; -- Write to Accumulator enabled
                            rfaddr_ctrl <= "000"; -- Reset the Register File to register 0  
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000"; -- Pass Accumulator value to ALU output
                            outen_ctrl <= '0';
                            state <= flag_state; -- Next state is the flag state
                            
                    WHEN LDA_execute => -- LDA (0001 0rrr), load value from register R[rrr] into Accumulator
                            -- *********************************
                            -- write the entire state for LDA_execute
                            muxsel_ctrl <= "01"; -- Register File output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '1'; -- Writing to Accumulator enabled
                            rfaddr_ctrl <= IR(2 DOWNTO 0); -- Register number set to 3 LSBs of instruction
                            rfwr_ctrl <= '0'; -- Reading from Register File
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= Fetch;
      			    ------------------------------------
    
                    WHEN STA_execute => -- STA (0010 0rrr), store value from Accumulator into register R[rrr]
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= IR(2 DOWNTO 0);
                            rfwr_ctrl <= '1'; -- Writing to Register File
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= Fetch;   
                            
                    WHEN LDI_execute => -- LDI (0011 0000), load immediate value to Accumulator
                            -- *********************************
                            -- write the entire state for LDI_execute
                            imm_ctrl <= PM(PC); -- Load the value from Program Memory into the immediate value input
                            PC <= PC + 1; -- Increment the program counter so the next memory value is an instruction
                            muxsel_ctrl <= "11"; -- Immediate value input selected
                            accwr_ctrl <= '1'; -- Writing to Accumulator enabled
                            rfaddr_ctrl <= "000"; 
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= Fetch;
			    ------------------------------------
                            
                    WHEN JZ_execute => -- JZ (1100 0000), if zero flag is high, absolute jump to memory address 000a aaaa
                            -- *********************************
                            -- write the entire state for JZ_execute 
                            muxsel_ctrl <= "00";
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= "000"; 
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            zero_flag := zero_ctrl;
                            if(zero_flag = '1') then
                                temp <= PM(PC)(4 downto 0);
                                PC <= TO_INTEGER(unsigned(temp));
                            
                            else
                                PC <= PC + 1;
                                
                            end if;
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= Fetch;
			    ------------------------------------

                   
                    WHEN ADD_execute => -- ADD (0100 0rrr), add Accumulator value and value in register R[rrr]
                            -- *********************************
                            -- write the entire state for ADD_execute 
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                            rfaddr_ctrl <= IR(2 DOWNTO 0);
                            rfwr_ctrl <= '0'; -- Reading from Register File
                            alusel_ctrl <= "100"; -- ALU set to add A and B
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= ADD_SUB_SL_SR_next;
			    ------------------------------------
 
                    WHEN SUB_execute => -- SUB (0101 0rrr), subtract value in register R[rrr] from Accumulator value
                            -- *********************************
                            -- write the entire state for SUB_execute 
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                            rfaddr_ctrl <= IR(2 DOWNTO 0);
                            rfwr_ctrl <= '0'; -- Reading from Register File
                            alusel_ctrl <= "101"; -- ALU set to subtract B from A
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= ADD_SUB_SL_SR_next;
			    ------------------------------------

                
                    WHEN SHFL_execute => -- SHFL (0110 00xx), shift the Accumulator value left by xx bits
                            -- *********************************
                            -- write the entire state for SHFL_execute 
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "010"; -- ALU set to left shift A
                            bits_shift_ctrl <= IR(1 downto 0); -- The bit shift value is set to the 2 LSBs of the instruction
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= ADD_SUB_SL_SR_next;
			    ------------------------------------
                            
                    
                    WHEN SHFR_execute => -- SHFR (0111 00xx), shift the Accumulator value right by xx bits
                            -- *********************************
                            -- write the entire state for SHFR_execute 
                            muxsel_ctrl <= "00"; -- ALU output selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "011"; -- ALU set to right shift A
                            bits_shift_ctrl <= IR(1 downto 0); -- The bit shift value is set to the 2 LSB of the instruction
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= ADD_SUB_SL_SR_next;
			    ------------------------------------

                    
                    WHEN input_A => -- INA (1000 000x), read user input into upper/lower nibble of Accumulator
                            muxsel_ctrl <= "10"; -- User input selected
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '1'; -- Writing to Accumulator enabled
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '0';
                            done       <= '0';
                            state <= flag_state;
                            bit_sel_ctrl <= IR(0);
                            
                    WHEN output_A => -- OUTA (1001 0000), output Accumulator value
                            -- *********************************
                            -- write the entire state for output_A
                            muxsel_ctrl <= "00";
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0'; -- Writing to Accumulator disabled
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '1'; -- Enable output
                            done       <= '0';
                            state <= Fetch;
			    ------------------------------------

                    WHEN Halt_cpu => -- HALT (1010 0000), stop the program
                            muxsel_ctrl <= "00";
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '1';
                            done       <= '1';
                            state <= Halt_cpu;
    
                    WHEN OTHERS =>
                            muxsel_ctrl <= "00";
                            imm_ctrl <= (OTHERS => '0');
                            accwr_ctrl <= '0';
                            rfaddr_ctrl <= "000";
                            rfwr_ctrl <= '0';
                            alusel_ctrl <= "000";
                            outen_ctrl <= '1';
                            done       <= '1';
                            state <= Halt_cpu;
                END CASE;
        END IF;

    END PROCESS;
end Behavior;    
