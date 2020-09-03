library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ImmediateGenerator is
    port (
        instruction: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(63 downto 0)
    );
end ImmediateGenerator;

architecture Behavioral of ImmediateGenerator is
    
begin
    process(instruction)
    begin
        if(instruction(6 downto 0) = "0000011") then
            output(11 downto 0) <= instruction(31 downto 20);
        elsif(instruction(6 downto 0) = "0100011") then
            output(4 downto 0) <= instruction(11 downto 7);
            output(11 downto 5) <= instruction(31 downto 25);
        elsif(instruction(6 downto 0) = "1100111") then
            output(3 downto 0) <= instruction(11 downto 8);
            output(9 downto 4) <= instruction(30 downto 25);
            output(10) <=  instruction(7);
            output(11) <= instruction(31);
        else 
            output(11 downto 0) <= (others=>'0'); 
        end if; 
        
        if(instruction(31) = '1') then
                output(63 downto 12) <= (others => '1');
        elsif (instruction(31) = '0') then
               output(63 downto 12) <= (others => '0');
        end if;
    end process;
end Behavioral;
