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
    type reg_type is array (0 to 31) of std_logic_vector(63 downto 0);
    signal regs : reg_type := (
        -- problem #6 example #1
        --10 => std_logic_vector(to_signed(2, 64)),
        
        --problem #6 example #2
        --10 => std_logic_vector(to_signed(5, 64)),
        --11 => std_logic_vector(to_signed(0, 64)),
        --12 => std_logic_vector(to_signed(1, 64)),
       
        others =>(others =>'0')
    );
begin
    readData1 <= regs(to_integer(unsigned(readRegister1)));
    readData2 <= regs(to_integer(unsigned(readRegister2)));
    
    process(regWrite, writeRegister, writeData)
    begin
        if((regWrite = '1') and (writeRegister /= "00000")) then
            regs(to_integer(unsigned(writeRegister)))<= writeData;
        end if;
    end process;
    
    regs(0)<= (others=>'0');
    
end Behavioral;
