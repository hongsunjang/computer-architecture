library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Elevator is
    Port (
        clk : in std_logic;
        button_pressed : in std_logic;
        button_floor : in std_logic_vector(3 downto 0);
        curr_floor : out std_logic_vector(3 downto 0);
        curr_moving : out std_logic
    );
end Elevator;

architecture Behavioral of Elevator is
    type qarray_type is array (0 to 15) of std_logic_vector(3 downto 0);
    signal todo_list : qarray_type := (others =>(others => '0'));    -- queue array for store the pressed-buttons
    signal push_ptr, pop_ptr: integer := 0;                         -- pointer for queue array 
    signal where_at, target_floor : integer := 0;                   -- current floor and target of elevator
    signal curr_state: std_logic := '0';                            -- current state of elevator
begin 
    -- update output
    curr_floor <= std_logic_vector(to_unsigned(where_at, 4));
    curr_moving <= curr_state;
     
    -- process when the rising edge of clk value
    process(clk) 
        variable pop_ptr_temp: integer; -- temperate variable for pop pointer of queue
        variable where_at_tmp: integer; -- tmeperate variable for current floor of elevator
    begin
        if(rising_edge(clk)) then
            if(curr_state = '1') then                                                     -- &&&if current state is moving&&&
                if(where_at = target_floor) then                                          -- ###arrive at target floor###
                    if(push_ptr /= pop_ptr) then 
                        -- %%%pop the target floor from todo_list%%%
                        pop_ptr_temp := pop_ptr;
                        target_floor <= to_integer(unsigned(todo_list(pop_ptr_temp)));
                        if(pop_ptr_temp = 15) then
                            pop_ptr <= 0;
                        else
                            pop_Ptr <= pop_ptr_temp +1;
                        end if;
                        --@@ move the elevator @@
                        if(where_at > to_integer(unsigned(todo_list(pop_ptr_temp)))) then     
                            where_at <= where_at - 1;
                        elsif(where_at < to_integer(unsigned(todo_list(pop_ptr_temp)))) then
                            where_at <= where_at + 1;
                        end if;   
                    end if;
                --@@ move the elevator @@  
                elsif(where_at > target_floor) then     
                    where_at_tmp := where_at -1;
                            if((where_at_tmp = target_floor) and (push_ptr = pop_ptr)) then
                                curr_state <= '0';
                            end if;
                    where_at <= where_at_tmp;
                elsif(where_at < target_floor) then
                    where_at_tmp := where_at +1;
                            if(where_at_tmp = target_floor) then
                                curr_state <= '0';
                            end if;
                    where_at <= where_at +1;
                end if;
            elsif(curr_state = '0') then                                                  --&&&if current state is stop&&&
                if(push_ptr /= pop_ptr) then  
                    -- %%%pop the target floor from todo_list%%%   
                    pop_ptr_temp := pop_ptr;
                    target_floor <= to_integer(unsigned(todo_list(pop_ptr_temp)));
                    if(pop_ptr_temp = 15) then
                        pop_ptr <= 0;
                    else
                        pop_ptr <= pop_ptr_temp +1;
                    end if;
                    
                    -- start to move the elevator to the target floor
                    curr_state <= '1';
                    --@@ move the elevator @@
                    if(where_at > to_integer(unsigned(todo_list(pop_ptr_temp)))) then     
                        where_at_tmp := where_at -1;
                        if((where_at_tmp = to_integer(unsigned(todo_list(pop_ptr_temp))))and (push_ptr = pop_ptr)) then
                            curr_state <= '0';
                        end if;
                        where_at <= where_at_tmp;
                    else
                        where_at_tmp := where_at +1;
                        if((where_at_tmp = to_integer(unsigned(todo_list(pop_ptr_temp))))and (push_ptr = pop_ptr)) then
                            curr_state <= '0';
                        end if;
                        where_at <= where_at_tmp;
                    end if;
                end if;
            end if;
        end if;   
    end process;
    
    
    -- process when the button pressed
    process(button_floor, button_pressed)
        variable push_ptr_temp: integer;   -- temperate variable for push pointer
        variable ignore: std_logic := '0'; -- value'1' means already exist in todo_list
    begin
        -- restore the value when the pressed-button is not current target floor 
        if((button_floor /= std_logic_vector(to_unsigned(target_floor, 4)) ) and (button_pressed = '1')) then
            if( not((curr_state = '0') and (button_floor = std_logic_vector(to_unsigned(where_at, 4))))) then -- check if the pressed floor is currend floor  
                -- check if the pressed floor is already in todo_list
                for i in pop_ptr to push_ptr loop
                    if(button_floor = std_logic_vector(todo_list(i))) then
                        ignore :='1';
                    end if;
                end loop;
       
                -- push the floor when ignore value is '0' 
                if( ignore = '0') then
                    push_ptr_temp := push_ptr;
                    todo_list(push_ptr_temp) <= button_floor;
                    if(push_ptr_temp = 15) then
                        push_ptr <= 0;
                    else
                        push_ptr <= push_ptr_temp + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
