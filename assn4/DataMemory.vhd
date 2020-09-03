library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    port (
        address: in std_logic_vector(63 downto 0);
        memRead: in std_logic;
        readData: out std_logic_vector(63 downto 0);
        memWrite: in std_logic;
        writeData: in std_logic_vector(63 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is
    subtype tByte is std_logic_vector(7 downto 0);
    type t1KBMemory is array (0 to 1023) of tByte;
    -- default memory
    signal memory: t1KBMemory := (
        x"02", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"0F", x"00", x"00", x"00", x"00", x"00", x"00", x"00",
        x"02", x"00", x"00", x"00", x"AA", x"AA", x"AA", x"AA",
        x"AA", x"AA", x"AA", x"2A", x"FF", x"FF", x"FF", x"FF",
        x"00", x"00", x"00", x"00", x"CC", x"CC", x"CC", x"CC",
        others => (others => '0')
    );
    
    
begin
    process(memRead, address)
    begin
        if(memRead = '1') then
             readData(7 downto 0) <= memory(to_integer(unsigned(address)));
             readData(15 downto 8) <= memory(to_integer(unsigned(address))+1);
             readData(23 downto 16) <= memory(to_integer(unsigned(address))+2);
             readData(31 downto 24) <= memory(to_integer(unsigned(address))+3);
             readData(39 downto 32) <= memory(to_integer(unsigned(address))+4);
             readData(47 downto 40) <= memory(to_integer(unsigned(address))+5);
             readData(55 downto 48) <= memory(to_integer(unsigned(address))+6);
             readData(63 downto 56) <= memory(to_integer(unsigned(address))+7);
             
        end if;
    end process;
    
    process(memWrite, address, writeData) 
    begin
        if(rising_edge(memwrite)) then
            memory(to_integer(unsigned(address))) <= writeData(7 downto 0);
            memory(to_integer(unsigned(address))+1) <= writeData(15 downto 8);
            memory(to_integer(unsigned(address))+2) <= writeData(23 downto 16);
            memory(to_integer(unsigned(address))+3) <= writeData(31 downto 24);
            memory(to_integer(unsigned(address))+4) <= writeData(39 downto 32);
            memory(to_integer(unsigned(address))+5) <= writeData(47 downto 40);
            memory(to_integer(unsigned(address))+6) <= writeData(55 downto 48);
            memory(to_integer(unsigned(address))+7) <= writeData(63 downto 56);
            
        end if;
    end process;
end Behavioral;
