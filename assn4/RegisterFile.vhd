library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    port (
        readRegister1: in std_logic_vector(4 downto 0);
        readData1: out std_logic_vector(63 downto 0);
        readRegister2: in std_logic_vector(4 downto 0);
        readData2: out std_logic_vector(63 downto 0);
        regWrite: in std_logic;
        writeRegister: in std_logic_vector(4 downto 0);
        writeData: in std_logic_vector(63 downto 0)
    );
end RegisterFile;

architecture Behavioral of RegisterFile is
    type tRegister is array (0 to 31) of std_logic_vector(63 downto 0);
    signal registers : tRegister := (
        1=>x"0000000000000000",
        2=>x"0000000000000002",
        
        
        others =>(others =>'0')
    );
    signal reg_update:std_logic:='0';
begin
    process(readRegister1, readRegister2, reg_update) 
    begin
        if( readRegister1 = "00000") then
                readData1 <=(others=>'0');  
        else 
                readData1 <= registers(to_integer(unsigned(readRegister1)));
        end if;
        if(readRegister2 = "00000") then
                readData2 <=(others=>'0');
        else
                readData2<= registers(to_integer(unsigned(readRegister2)));
        end if;
    end process;
    
    process(regWrite, writeRegister, writeData)
    begin
       if(rising_edge(regWrite)) then
           if(writeRegister /= "00000") then
                registers(to_integer(unsigned(writeRegister)))<= writeData;
           end if;
        elsif(falling_edge(regWrite)) then
            reg_update <= '1';
        else
            reg_update <= '0';
        end if; 
    end process;
end Behavioral;