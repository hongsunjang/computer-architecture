library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SingleBitAdder is
    port (
        -- clock
        clk: in std_logic;
        -- input
        a: in std_logic;
        b: in std_logic;
        -- output
        c: out std_logic;
        carry: out std_logic
    );
end entity;

architecture Behavioral of SingleBitAdder is
    
begin
    process (clk)
    begin
        if(rising_edge(clk)) then
             c <= a XOR b;
             carry <= a AND b;
        end if;
    end process;
end Behavioral;
