library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Refer to Figure 4.17 in the textbook (page 257)
entity MainControlUnit is
    port (
        input: in std_logic_vector(6 downto 0);
        Branch: out std_logic;
        MemToReg: out std_logic;
        MemRead: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        MemWrite: out std_logic;
        ALUSrc: out std_logic;
        RegWrite: out std_logic
    );
end MainControlUnit;

architecture Behavioral of MainControlUnit is
    --
begin
    process(input)
    begin
        if(input ="0110011") then
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '1';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '0';
            ALUOp <= "10";
        elsif(input ="0000011") then
            ALUSrc <= '1';
            MemtoReg <= '1';
            RegWrite <= '1';
            MemRead <= '1';
            MemWrite <= '0';
            Branch <= '0';
            ALUOp <= "00";
        elsif(input ="0100011") then
            ALUSrc <= '1';
            MemtoReg <= '0';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '1';
            Branch <= '0';
            ALUOp <= "00";
        elsif(input ="1100111") then
            ALUSrc <= '0';
            MemtoReg <= '0';
            RegWrite <= '0';
            MemRead <= '0';
            MemWrite <= '0';
            Branch <= '1';
            ALUOp <= "01";
        --else 
        end if;
    end process;
end Behavioral;
