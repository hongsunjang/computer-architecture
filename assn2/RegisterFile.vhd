library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    port (
        -- clock
        clk: in std_logic;
        -- read port 1
        read1: in std_logic;
        read1_reg: in unsigned(4 downto 0);
        read1_data: out std_logic_vector(63 downto 0);
        -- read port 2
        read2: in std_logic;
        read2_reg: in unsigned(4 downto 0);
        read2_data: out std_logic_vector(63 downto 0);
        -- write port
        write: in std_logic;
        write_reg: in unsigned(4 downto 0);
        write_data: in std_logic_vector(63 downto 0)
    );
end RegisterFile;

architecture Behavioral of RegisterFile is
    type reg_type is array (0 to 31) of std_logic_vector(63 downto 0);
    signal regs : reg_type := (others =>(others => '0'));
begin
    regs(0) <= (others => '0');
    process(clk)
    begin
        if(rising_edge(clk)) then
            if((write = '1') and (write_reg /= "00000")) then
                report("write complete");
                regs(to_integer(write_reg)) <= write_data;
            end if;
            if(read1 = '1') then
                read1_data <= regs(to_integer(read1_reg));
                report("read1 complete");
            end if;
            if(read2 = '1') then
                read2_data <= regs(to_integer(read2_reg));
                report("read2 complete");
            end if;
        end if;
    end process;
end Behavioral;
