library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Queue is
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

architecture Behavioral of Queue is
    type qarray_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal qarray : qarray_type := (others =>(others => '0'));
    signal pushPtr, popPtr : integer := 0;
    signal num : unsigned(31 downto 0) := (others => '0');
begin
    process(clk)
        variable pushPtrTemp, popPtrTemp: integer;
        variable popDataTemp: std_logic_vector(31 downto 0);
    begin
        if(rising_edge(clk)) then
            if(push = '1') then
                pop_data <= (others => '0');
                pushPtrTemp := pushPtr;
                qarray(pushPtrTemp) <= push_data;
                if(pushPtrTemp = 31) then
                    pushPtr <= 0;
                else
                    pushPtr <= pushPtrTemp + 1;
                end if;
                num <= num +1;
            elsif(pop = '1') then
                if(num = 0) then
                    pop_data <= (others => '0');
                else
                    popPtrTemp := popPtr;
                    pop_data <= qarray(popPtrTemp);
                    if(popPtrTemp = 31) then
                        popPtr <= 0;
                    else
                        popPtr <= popPtrTemp +1;
                    end if; 
                    num <= num-1;    
                end if;
            else 
                pop_data <= (others => '0');
            end if;
        end if;
    end process;
    num_values <= num;
end architecture;
