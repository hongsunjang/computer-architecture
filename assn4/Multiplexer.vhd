library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplexer is
    port (
        selector: in std_logic;
        input1: in std_logic_vector(63 downto 0);
        input2: in std_logic_vector(63 downto 0);
        output: out std_logic_vector(63 downto 0)
    );
end Multiplexer;

architecture Behavioral of Multiplexer is
    --
begin
    process(selector, input1, input2)
    begin
        if(selector = '0') then
            output<=input1;
        elsif(selector = '1') then
            output<=input2;
        end if;
    end process;
end Behavioral;
