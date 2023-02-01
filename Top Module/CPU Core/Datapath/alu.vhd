----------------------------------------------------------------------------------
-- Company: Department of Electrical and Computer Engineering, University of Alberta
-- Engineer: Shyama Gandhi and Bruce Cockburn
--
-- Create Date: 10/29/2020 07:18:24 PM
-- Design Name:
-- Module Name: cpu - structural(datapath)
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: CPU LAB 3 - ECE 410 (2021)
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 1.01 - File Modified by Raju Machupalli (October 31, 2021)
-- Revision 2.01 - File Modified by Shyama Gandhi (November 2, 2021)
-- Additional Comments:
--*********************************************************************************
-- Total eights operations can be performed using 3 select lines of this ALU.
-- The select line codes have been given to you in the lab manual.
-- In future, this alu is scalable to say, 16 operations using 4 select lines.
-----------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- The following package is needed so that the STD_LOGIC_VECTOR signals
-- A and B can be used in unsigned arithmetic operations.
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is PORT (
            clk_alu     : IN std_logic;
            sel_alu     : IN std_logic_vector(2 DOWNTO 0);
            inA_alu     : IN std_logic_vector(7 DOWNTO 0);
            inB_alu     : IN std_logic_vector(7 DOWNTO 0);
            bits_shift  : IN std_logic_vector(1 downto 0);       -- decides how much to shift during shift left and shift right operation (decide from last 2 bits in the SHFL/SHFR operation)
            OUT_alu     : OUT std_logic_vector (7 DOWNTO 0) := "00000000");
end alu;

ARCHITECTURE Behavior OF alu IS

    BEGIN
        PROCESS(clk_alu,sel_alu)
        
        BEGIN
        IF clk_alu'event and clk_alu = '1' THEN
            CASE sel_alu IS
                WHEN "000" =>   -- Pass A to output
                                OUT_alu <= inA_alu;
                                
                WHEN "001" =>   -- AND operation
                                OUT_alu <= inA_alu AND inB_alu;
                                
                WHEN "010" =>   -- Shift left based on "bits_shift"
                                OUT_alu <= std_logic_vector(shift_left(unsigned(inA_alu),to_integer(unsigned(bits_shift))));

                WHEN "011" =>   -- Shift right based on "bits_shift"
                                OUT_alu <= std_logic_vector(shift_right(unsigned(inA_alu),to_integer(unsigned(bits_shift))));
				
                WHEN "100" =>   -- Add A and B
                                OUT_alu <= inA_alu + inB_alu;
                                
                WHEN "101" =>   -- Subtract B from A
                                OUT_alu <= inA_alu - inB_alu;
                                
                WHEN "110" =>   -- Increment A by 1
                                OUT_alu <= inA_alu + 1;
                                
                WHEN OTHERS =>  -- Decrement A by 1
                                OUT_alu <= inA_alu - 1;               
            END CASE;
        END IF;
        END PROCESS;
END Behavior;