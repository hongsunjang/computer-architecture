library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUControlUnit is
    port (
        ALUOp: in std_logic_vector(1 downto 0);
        input: in std_logic_vector(3 downto 0);
        output: out std_logic_vector(3 downto 0)
    );
end ALUControlUnit;

architecture Behavioral of ALUControlUnit is
    --
begin
    process(ALUOp, input) 
    begin
        -- if ALUOp is ld, sd
        if(ALUOp = "00") then
            output <= "0010";
        
        -- if ALUOp is beq
        elsif(ALUOp = "01") then
            output <= "0110";
        
        -- if ALUOp is Arithmetic operator
        elsif(ALUOp = "10") then
            if(input = "0000") then
                output <= "0010";
            elsif(input  = "1000") then
                output <= "0110";
            elsif(input = "0111") then
                output <= "0000";
            elsif(input = "0110") then
                output <= "0001";
            end if;
        end if;
    end process;
end Behavioral;
