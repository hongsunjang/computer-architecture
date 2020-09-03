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
    with(selector) select
    output <= input1 when '0',
              input2 when '1',
              (others=> '0') when others;

end Behavioral;
