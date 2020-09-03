library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplexer2 is
    port (
        selector: in std_logic_vector(1 downto 0);
        input1: in std_logic_vector(63 downto 0);
        input2: in std_logic_vector(63 downto 0);
        input3: in std_logic_vector(63 downto 0);
        output: out std_logic_vector(63 downto 0)
    );
end Multiplexer2;

architecture Behavioral of Multiplexer2 is
begin
    process(selector, input1, input2, input3)
    begin
        if(selector = "00") then
            output<=input1;
        elsif(selector = "01") then
            output<=input2;
        elsif(selector = "10") then
            output<=input3;
        end if;
    end process;
end Behavioral;
