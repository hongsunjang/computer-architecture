library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ForwardingUnit is
    port (
        IDEX_rs1: in std_logic_vector(4 downto 0);
        IDEX_rs2: in std_logic_vector(4 downto 0);
        EXMEM_RegWrite: in std_logic;
        EXMEM_rd: in std_logic_vector(4 downto 0);
        MEMWB_RegWrite: in std_logic;
        MEMWB_rd: in std_logic_vector(4 downto 0);
        ForwardA: out std_logic_vector(1 downto 0); 
        ForwardB: out std_logic_vector(1 downto 0)
    );
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
begin
    process(IDEX_rs1, IDEX_rs2, EXMEM_RegWrite, EXMEM_rd, MEMWB_RegWrite, MEMWB_rd)
    begin
        -- Register write request in both EX stage and MEM stage
        if(((EXMEM_RegWrite = '1') and (EXMEM_rd /= "00000")) and ((MEMWB_RegWrite = '1') and (MEMWB_rd /= "00000"))) then
            -- MEM stage data hazard check
            if(EXMEM_rd = IDEX_rs1) then
                ForwardA <= "10";
            else
                ForwardA <= "00";
            end if;
            if(EXMEM_rd = IDEX_rs2) then
                ForwardB <= "10";
            else
                ForwardB <= "00";
            end if;
            -- EX stage data hazard check
            if(MEMWB_rd /= EXMEM_rd) then
                if(MEMWB_rd = IDEX_rs1) then
                    ForwardA <= "01";
                end if;
                if(MEMWB_rd = IDEX_rs2) then
                    ForwardB <= "01";
                end if;
            end if;
        -- Register Write request in EX stage
        elsif((EXMEM_RegWrite = '1') and (EXMEM_rd /="00000")) then
            if(EXMEM_rd = IDEX_rs1) then
                ForwardA <= "10";
            else
                ForwardA <= "00";
            end if;
            if(EXMEM_rd = IDEX_rs2) then
                ForwardB <= "10";
            else
                ForwardB <="00";
            end if;
        -- Regsiter Write request in Mem stage
        elsif((MEMWB_RegWrite = '1') and (MEMWB_rd /= "00000")) then
                if(MEMWB_rd = IDEX_rs1) then
                    ForwardA <= "01";
                else
                    ForwardA <= "00";
                end if;
                if(MEMWB_rd = IDEX_rs2) then
                    ForwardB <= "01";
                else
                    ForwardB <="00";
                end if;
        -- No register write request on EX/MEM stage
        else
            ForwardA <="00";
            ForwardB <= "00";
        end if;
    end process;
end Behavioral;
