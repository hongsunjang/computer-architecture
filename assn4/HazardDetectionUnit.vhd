library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HazardDetectionUnit is
    port (
        IDEX_MemRead: in std_logic;
        IDEX_RegisterRd: in std_logic_vector(4 downto 0);
        IFID_RegisterRs1: in std_logic_vector(4 downto 0);
        IFID_RegisterRs2: in std_logic_vector(4 downto 0);
        PCWrite: out std_logic;
        IFIDWrite: out std_logic;
        MakeBubble: out std_logic
    );
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is
begin
    process(IDEX_MemRead, IDEX_RegisterRd, IFID_RegisterRs1, IFID_RegisterRs2)
    begin
        -- load-use data hazard detected
        if((IDEX_MemRead = '1') and (IDEX_RegisterRd /= "00000") and ((IDEX_RegisterRd = IFID_RegisterRs1) or (IDEX_RegisterRd = IFID_RegisterRs2))) then
            -- make bubble
            PCWrite <= '1';
            IFIDWrite <= '1';
            MakeBubble<= '1';
        else
            PCWrite <= '0';
            IFIDWrite <= '0';
            MakeBubble <= '0';
        end if;
    end process;
end Behavioral;
