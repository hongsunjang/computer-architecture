library ieee;
use ieee.std_logic_1164.all;

entity JKFlipFlop is
    port (
        -- clock
        clk: in std_logic;
        -- input
        J: in std_logic;
        K: in std_logic;
        -- output
        Q: out std_logic
    );
end entity;

architecture Behavioral of JKFlipFlop is
    signal qNext : std_logic := '0';
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            qNext <= ((not qNext) and J) or (qNext and (not K));  
        end if;
    end process;
    Q <= qNext;
end architecture;
