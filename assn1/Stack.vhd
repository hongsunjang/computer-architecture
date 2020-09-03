library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stack is
    port (
        -- clock
        clk: in std_logic;
        -- input
        push: in std_logic;
        push_data: in std_logic_vector(31 downto 0);
        pop: in std_logic;
        -- output
        pop_data: out std_logic_vector(31 downto 0);
        num_values: out unsigned(31 downto 0)
    );
end entity;

architecture Behavioral of Stack is
    type sarray_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal sarray : sarray_type := (others =>(others => '0'));
    signal topPtr : integer := 0;
    signal num : unsigned(31 downto 0) := (others => '0');
begin
    process(clk)
        variable toptemp : integer;
    begin
        if(rising_edge(clk)) then
            if(push = '1') then
                pop_data <= (others => '0');
                toptemp := topPtr;
                sarray(toptemp) <= push_data;
                topPtr <= toptemp + 1;
                num <= num +1;
            elsif(pop = '1') then
                if(num = 0) then
                    pop_data <= (others => '0');
                else
                    toptemp := topPtr -1;
                    pop_data <= sarray(toptemp);
                    topPtr <= toptemp;
                    num <= num - 1;    
                end if;
            else 
                pop_data <= (others => '0');
            end if;
        end if;
    end process;
    num_values <= num;
end architecture;
