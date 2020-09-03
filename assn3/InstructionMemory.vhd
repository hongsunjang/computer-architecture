library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    port (
        readAddress: in std_logic_vector(63 downto 0);
        instruction: out std_logic_vector(31 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    subtype tByte is std_logic_vector(7 downto 0);
    type t1KBMemory is array (0 to 1023) of tByte;
    
    -- problem #4
    --signal memory: t1KBMemory := (
    --    x"EF", x"CD", x"AB", x"89",
    --    x"67", x"45", x"23", x"01",
    --    x"67", x"CD", x"23", x"89",
    --    x"EF", x"45", x"AB", x"01",
    --    others => (others => '0')
    --);
    
    --problem #6 example #1
    --signal memory: t1KBMemory := (
    --    x"00", x"00", x"00", x"00",
    --    x"B3", x"05", x"05", x"00",  -- NOTE: little-endian
    --   x"33", x"06", x"B5", x"00",
    --    x"B3", x"86", x"C5", x"00",
    --    x"33", x"07", x"D6", x"00",
    --    x"B3", x"87", x"E6", x"00",
    --    others => (others => '0')
    --);
    
    -- problem #6 example #2
    --signal memory: t1KBMemory := (
    --    x"00",x"00", x"00", x"00",
    --   x"b3", x"85", x"c5", x"00", -- add  x11, x11, x12
    --    x"67", x"0c", x"b5", x"02", -- beq x10, x11, 0x38
    --    x"b3", x"85", x"c5", x"00", -- add  x11, x11, x12
    --    x"67", x"08", x"b5", x"02", -- beq x10, x11, 0x30
    --    x"b3", x"85", x"c5", x"00", -- add  x11, x11, x12
    --   x"67", x"04", x"b5", x"02", -- beq x10, x11, 0x28
    --    x"b3", x"85", x"c5", x"00", -- add  x11, x11, x12
    --   x"67", x"00", x"b5", x"02", -- beq x10, x11, 0x20
    --    x"b3", x"85", x"c5", x"00", -- add  x11, x11, x12
    --    x"67", x"0c", x"b5", x"00", -- beq x10, x11, 0x18 (jump!)
    --    x"b3", x"85", x"c5", x"40", -- sub x11, x11, x12
    --    x"b3", x"85", x"c5", x"40", -- sub x11, x11, x12
    --   x"b3", x"85", x"c5", x"40", -- sub x11, x11, x12
    --    x"b3", x"85", x"c5", x"40", -- sub x11, x11, x12
    --  x"b3", x"85", x"c5", x"40", -- sub x11, x11, x12
    --    x"b3", x"85", x"b5", x"00", -- add  x11, x11, x11
    --   others=> (others=>'0')
    --);
    --problem #6 example #3
    --signal memory: t1KBMemory := (
    --    x"00",x"00", x"00", x"00",
    --    x"23", x"73", x"45", x"00", -- sd x4, 0x6(x10)
    --    x"23", x"77", x"55", x"00", -- sd x5, 0xE(x10)
    --    x"83", x"35", x"65", x"00", -- ld x11, 0x6(x10)
    --   x"03", x"36", x"e5", x"00", -- ld x12, 0xE(x10)
    --    others=> (others=>'0')
    --);
    
    --problem#6 example #4
    signal memory: t1KBMemory := (
        x"00",x"00", x"00", x"00",
       x"03", x"3f", x"00", x"00", -- sd x4, 0x6(x10)
        x"83", x"3f", x"80", x"00", -- sd x5, 0xE(x10)
        x"33", x"05", x"0f", x"00", -- ld x11, 0x6(x10)
        x"b3", x"75", x"ff", x"01", -- ld x12, 0xE(x10)
        x"33",x"76",x"05",x"40",
        x"67",x"04",x"06",x"00",
        x"34",x"41",x"23",x"23", -- not executed 
        x"83",x"36",x"80",x"01",
        x"33",x"67",x"d0",x"00",
        x"23",x"70",x"e0", x"02",
        
        others=> (others=>'0')
    );
begin
    instruction(7 downto 0) <= memory(to_integer(unsigned(readAddress)));
    instruction(15 downto 8) <= memory(to_integer(unsigned(readAddress))+1);
    instruction(23 downto 16) <= memory(to_integer(unsigned(readAddress))+2);
    instruction(31 downto 24) <= memory(to_integer(unsigned(readAddress))+3);
end Behavioral;
