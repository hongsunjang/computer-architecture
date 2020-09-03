library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BranchUnit is
    port (
        controlBranch : in std_logic;
        ALUZero: in std_logic;
        doBranch: out std_logic
     );
end BranchUnit;

architecture Behavioral of BranchUnit is

begin
    process (controlBranch, ALUZero)
    begin
        if((controlBranch = '1') and (ALUZero = '1')) then
            doBranch <= '1';
        else
            doBranch <= '0';
        end if;
    end process;

end Behavioral;
