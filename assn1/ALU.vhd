library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port (
        -- clock
        clk: in std_logic;
        -- input
        op: in std_logic_vector(2 downto 0);
        input1: in std_logic_vector(31 downto 0);
        input2: in std_logic_vector(31 downto 0);
        -- output
        output: out std_logic_vector(31 downto 0)
    );
end entity;

architecture Behavioral of ALU is
    signal ip1 : signed(31 downto 0);
    signal ip2 : signed(31 downto 0);
begin
    ip1 <= signed(input1);
    ip2 <= signed(input2);
    process(clk)     
    begin
        if(rising_edge(clk)) then
            -- input1 + input2
            if(op = "000") then
                output <= std_logic_vector(ip1 + ip2); 
            -- input1 - input2
            elsif(op = "001") then
                output <= std_logic_vector(ip1 - ip2);
            -- input1 * input2
            elsif(op = "010") then
                output <= std_logic_vector(resize(ip1*ip2, 32));  
            -- input1 / input2
            elsif(op = "011" and input2 /= x"00000000") then
                output <= std_logic_vector((ip1/ip2)); 
            -- input and input2
            elsif(op = "100") then
                output <= input1 and input2; 
            -- input or input2
            elsif(op = "101") then
                output <= input1 or input2; 
            -- not input1
            elsif(op = "110") then
                output <= not input1;  
            else 
                output <= input1;
            end if;
        end if;
    end process;
end architecture;
