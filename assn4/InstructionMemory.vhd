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
        
    signal memory: t1KBMemory := ( 
        x"00", x"00", x"00", x"00",
        --x"b3",x"05",x"05",x"00", --add x11, x10,x0
        --x"33", x"06", x"b5", x"00",-- add x12, x11, x10
        --x"b3", x"86", x"c5", x"00",-- add x13, x12, x11
        --x"33", x"07", x"d6", x"00",-- add x14, x13, x12
        --x"33", x"85", x"e6", x"00", --add x10,x 14, x13
        --x"b3", x"86", x"c5", x"00",-- add x13, x12, x11
        x"63",x"84",x"00",x"02",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"33",x"01",x"21",x"00",
        x"03",x"B1",x"40",x"01",
               
        
        
        --x"63",x"0c",x"b5",x"00", -- branch if(x10=x11) x18
        --x"b3",x"05",x"05",x"00", --add x11, x10,x0
        --x"63",x"0c",x"b5",x"00", -- branch if(x10=x11) x18
        --x"23",x"73",x"45",x"00", --sd x4, 06(x10) -x
        --x"23",x"73",x"55",x"00", --sd x5, 0x6(x10)- x
        --x"23",x"73",x"65",x"00", --sd x6, 0x6(x10)-x 
        --x"23",x"73",x"75",x"00", --sd x7, 0x6(x10)-x
        --x"23",x"73",x"85",x"00", --sd x8, 0x6(x10)-x
        --x"23",x"73",x"95",x"00", --sd x9, 0x6(x10)
        --x"23",x"73",x"A5",x"00", --sd x10, 0xE(x10)
        
        
        
        
        others => (others => '0')
    );
    
begin
    instruction(7 downto 0) <= memory(to_integer(unsigned(readAddress)));
    instruction(15 downto 8) <= memory(to_integer(unsigned(readAddress))+1);
    instruction(23 downto 16) <= memory(to_integer(unsigned(readAddress))+2);
    instruction(31 downto 24) <= memory(to_integer(unsigned(readAddress))+3);
end Behavioral;
