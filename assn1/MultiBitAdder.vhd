library ieee;
use ieee.std_logic_1164.all;

entity MultiBitAdder is
    port (
        -- clock
        clk: in std_logic;
        -- input
        a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        -- output
        c: out std_logic_vector(7 downto 0);
        carry: out std_logic
    );
end entity;

architecture Behavioral of MultiBitAdder is
    
    begin
        process(clk)
            variable temp: std_logic := '0';
        begin
            if(rising_edge(clk)) then
                temp := '0';
                for i in 0 to 7 loop
                    c(i) <= a(i) XOR b(i) XOR temp;
                    if(a(i)='1' AND b(i)='1') then
                        temp := '1';
                    elsif((a(i) ='1' OR b(i) = '1') and temp = '1') then
                        temp := '1';
                    else
                        temp := '0';
                    end if; 
                end loop;
                carry <= temp;
            end if;
        end process;
end architecture;
