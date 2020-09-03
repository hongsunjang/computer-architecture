library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALUWithRF is
    port (
        -- clock
        clk: in std_logic;
        -- ready?
        ready: out std_logic;
        -- inputs
        op: in std_logic_vector(2 downto 0);
        rd: in unsigned(4 downto 0);
        rs1: in unsigned(4 downto 0);
        rs2: in unsigned(4 downto 0);
        idata: in std_logic_vector(63 downto 0);
        -- register read/write
        odata: out std_logic_vector(63 downto 0)
    );
end entity;

architecture Behavioral of ALUWithRF is
    component RegisterFile
        port (
            clk: in std_logic;
            read1: in std_logic; read1_reg: in unsigned(4 downto 0); read1_data: out std_logic_vector(63 downto 0);
            read2: in std_logic; read2_reg: in unsigned(4 downto 0); read2_data: out std_logic_vector(63 downto 0);
            write: in std_logic; write_reg: in unsigned(4 downto 0); write_data: in std_logic_vector(63 downto 0)
        );
    end component;
    
    signal read1, read2, write: std_logic;
    signal read1_reg, read2_reg, write_reg: unsigned(4 downto 0);
    signal read1_data, read2_data, write_data: std_logic_vector(63 downto 0);
    
    signal wait_cycle : integer := 0;
    signal curr_op : std_logic_vector(2 downto 0);
    signal curr_rd, curr_rs1, curr_rs2: unsigned(4 downto 0);
    signal r1_tempData, r2_tempData: signed(63 downto 0);
    signal w_tempData: std_logic_vector(63 downto 0);
begin
    RF: RegisterFile port map (
        clk => clk,
        read1 => read1, read1_reg => read1_reg, read1_data => read1_data,
        read2 => read2, read2_reg => read2_reg, read2_data => read2_data,
        write => write, write_reg => write_reg, write_data => write_data
    );
    
    -- process that rising edge of clk
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(wait_cycle /= 0) then
                wait_cycle <= wait_cycle - 1;
                if(wait_cycle = 1) then
                    ready <= '1';
                end if;
            elsif(wait_cycle = 0) then
                
                ready <= '1'; -- initialization
                
                if((op = "001") or (op = "010") or (op = "011") or (op = "100")) then
                    ready <= '0';
                    curr_op <= op;
                    curr_rd <= rd;
                    curr_rs1 <= rs1;
                    curr_rs2 <= rs2;
                    wait_cycle <= 3;
                elsif(op = "101") then
                    ready <= '0';
                    curr_op<= op;
                    curr_rd <= rd;
                    wait_cycle <= 1;
                elsif(op = "110") then
                    ready <= '0';
                    curr_op<= op;
                    curr_rs1 <= rs1;
                    wait_cycle <= 2;
                end if;    
            end if;-- wait_cycle /= 0
        end if;-- rising edge of clk
    end process;
    
    -- process that between rising edge of clk( when wait_cycle decrease)
    process(wait_cycle)
    begin
        if((wait_cycle' event) and (wait_cycle = 3)) then
            -- set the RF's input signal
            read1 <= '1';
            read2 <= '1';
            read1_reg <= curr_rs1;
            read2_reg <= curr_rs2;
        elsif((wait_cycle' event) and (wait_cycle = 2)) then
            if(curr_op = "110") then
                read1 <= '1';
                read1_reg <= curr_rs1;
            else
                -- get output of RF data and fetch
                r1_tempData <= signed(read1_data);
                r2_tempData <= signed(read2_data);
                read1 <= '0';
                read2 <= '0';
                
            end if;
        elsif((wait_cycle' event) and (wait_cycle = 1)) then
            if(curr_op = "110") then
               read1 <= '0';
               w_tempData <= read1_data;
            elsif(curr_op = "101") then
                write <= '1';
                write_data <= idata;
                write_reg <= curr_rd;
                
            else
                --calculation 
                write <= '1';
                write_reg <= curr_rd;
                if(curr_op = "001") then
                    write_data <= std_logic_vector(r1_tempData + r2_tempData); 
                elsif(curr_op = "010") then
                    write_data <= std_logic_vector(r1_tempData - r2_tempData);
                elsif(curr_op = "011") then
                    write_data <= std_logic_vector(resize(r1_tempData * r2_tempData, 64));
                elsif(curr_op = "100" and r2_tempData /= 0) then
                    write_data <= std_logic_vector(r1_tempData / r2_tempData);
                end if;
                  
            end if; -- curr_op "110" or "101"
        elsif((wait_cycle' event) and (wait_cycle = 0)) then
            if((curr_op = "001") or (curr_op = "010") or (curr_op = "011") or (curr_op = "100") or (curr_op = "101")) then
                write <= '0';
            elsif((curr_op = "110")) then
                odata <= w_tempData;
            end if;
        end if;-- wait_cycle 
    end process;
    
end architecture;
