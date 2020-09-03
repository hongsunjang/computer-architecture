library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Memory is
    port (
        clk: in std_logic;

        ready: out std_logic;   -- 0: busy, 1: ready

        ivalid: in std_logic;   -- 0: invalid, 1: valid
        rdwr: in std_logic;                     -- 0: read, 1: write
        addr: in unsigned(11 downto 0);         -- byte address
        size: in std_logic_vector(1 downto 0);  -- 00/01/10/11: 1/2/4/8 bytes
        idata: in std_logic_vector(63 downto 0);

        ovalid: out std_logic;  -- 0: invalid, 1: valid
        odata: out std_logic_vector(63 downto 0)
    );
end entity;

architecture Behavioral of Memory is
    type memory_type is array (0 to 4096) of std_logic_vector(7 downto 0);
    signal storage : memory_type := (others =>(others => '0'));
    signal wait_cycle : integer := 0;
    
    -- curr_rdwr is 1 when write, 0 when read. cur_work(1 downto 0) is same as size
    signal curr_work : std_logic_vector(1 downto 0); 
    signal curr_rdwr :std_logic;
    signal target_addr : unsigned(11 downto 0);
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
                if(wait_cycle /= 0) then
                    wait_cycle <= wait_cycle - 1;
                    if(wait_cycle = 2) then
                        ready <= '1';
                        if(curr_rdwr = '0') then
                            ovalid<= '1';
                        end if;
                    end if;
                    if(wait_cycle = 1) then
                        ovalid <='0';
                    end if;
                elsif(wait_cycle = 0) then 
                    ready <= '1';
                    ovalid <= '0';
                    if(ivalid = '1') then
  
                            ready <= '0';
                            curr_work <= size;
                            curr_rdwr <= rdwr;
                            target_addr <= addr;  
                            if(size = "00") then
                                ready <= '1';
                                wait_cycle <= 1;
                                if(rdwr = '0') then
                                    ovalid <='1';
                                end if;
                            elsif(size = "01") then
                                wait_cycle <= 2;      
                            elsif(size = "10") then
                                wait_cycle <= 4;  
                            elsif(size = "11") then
                                wait_cycle <= 8;  
                            end if;           
                    end if;  -- ivalid    
               end if; -- wait_cycle /= 0
       end if; -- rising edge of clk
    end process;
    
    process(wait_cycle)
    begin
        if(wait_cycle'event and wait_cycle = 1) then
                
                if(curr_rdwr = '1') then
                    If(curr_work = "00") then
                        storage(to_integer(target_addr)) <= idata(7 downto 0);
                    elsif(curr_work = "01") then
                        storage(to_integer(target_addr)) <= idata(7 downto 0);
                        storage(to_integer(target_addr)+1) <= idata(15 downto 8);
                    elsif(curr_work = "10") then
                        storage(to_integer(target_addr)) <= idata(7 downto 0);
                        storage(to_integer(target_addr)+1) <= idata(15 downto 8);
                        storage(to_integer(target_addr)+2) <= idata(23 downto 16);
                        storage(to_integer(target_addr)+3) <= idata(31 downto 24);
                    elsif(curr_work = "11") then
                        storage(to_integer(target_addr)) <= idata(7 downto 0);
                        storage(to_integer(target_addr)+1) <= idata(15 downto 8);
                        storage(to_integer(target_addr)+2) <= idata(23 downto 16);
                        storage(to_integer(target_addr)+3) <= idata(31 downto 24);
                        storage(to_integer(target_addr)+4) <= idata(39 downto 32);
                        storage(to_integer(target_addr)+5) <= idata(47 downto 40);
                        storage(to_integer(target_addr)+6) <= idata(55 downto 48);
                        storage(to_integer(target_addr)+7) <= idata(63 downto 56);
                    end if;
                elsif(curr_rdwr = '0') then
                    odata <= (others => '0');
                    if(curr_work = "00") then
                        odata(7 downto 0) <= storage(to_integer(target_addr));
                    elsif(curr_work = "01") then
                        odata(7 downto 0) <= storage(to_integer(target_addr));
                        odata(15 downto 8) <= storage(to_integer(target_addr)+1);
                    elsif(curr_work = "10") then
                        odata(7 downto 0) <= storage(to_integer(target_addr));
                        odata(15 downto 8) <= storage(to_integer(target_addr)+1);
                        odata(23 downto 16) <= storage(to_integer(target_addr)+2);
                        odata(31 downto 24) <= storage(to_integer(target_addr)+3);
                    elsif(curr_work = "11") then
                        odata(7 downto 0) <= storage(to_integer(target_addr));
                        odata(15 downto 8) <= storage(to_integer(target_addr)+1);
                        odata(23 downto 16) <= storage(to_integer(target_addr)+2);
                        odata(31 downto 24) <= storage(to_integer(target_addr)+3);
                        odata(39 downto 32) <= storage(to_integer(target_addr)+4);
                        odata(47 downto 40) <= storage(to_integer(target_addr)+5);
                        odata(55 downto 48) <= storage(to_integer(target_addr)+6);
                        odata(63 downto 56) <= storage(to_integer(target_addr)+7);
                    end if;
                end if; -- curr_rdwr
        end if;
    end process;
end Behavioral;