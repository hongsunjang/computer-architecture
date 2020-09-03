library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ArithmeticLogicUnit is
    port (
        op: in std_logic_vector(3 downto 0);
        input1: in std_logic_vector(63 downto 0);
        input2: in std_logic_vector(63 downto 0);
        result: out std_logic_vector(63 downto 0);
        zero: out std_logic
    );
end ArithmeticLogicUnit;

architecture Behavioral of ArithmeticLogicUnit is
begin
    process(op, input1, input2)
    begin
        if(op = "0000") then
         
            result <= input1 AND input2;
            if((input1 AND input2) = std_logic_vector(to_signed(0,64))) then
                zero<='1';
            else
                zero<= '0';
            end if;
        elsif(op= "0001") then
            
            result <= input1 OR input2;
            if((input1 OR input2) = std_logic_vector(to_signed(0,64))) then
                zero<='1';
            else
                zero<= '0';
            end if;
        elsif(op= "0010") then
            
            result<= std_logic_vector(signed(input1) + signed(input2));
            if((std_logic_vector(signed(input1) +  signed(input2))) = std_logic_vector(to_signed(0,64))) then
                zero<='1';
            else
                zero<= '0';
            end if;
        elsif(op = "0110") then
           
            result<= std_logic_vector(signed(input1) - signed(input2));
            if((std_logic_vector(signed(input1) -  signed(input2))) = std_logic_vector(to_signed(0,64))) then
                
                zero<='1';
            else
                zero<= '0';
            end if;
        else 
            zero<='0';
        end if; 
    end process;
end Behavioral;
