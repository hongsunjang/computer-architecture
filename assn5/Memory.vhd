library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity Memory is
    generic (
        addrSize: natural;                  -- the # of memory address bits (e.g., 64/32 for 64/32 bits)
        accessGranularityInBytes: natural;  -- the granularity of memory accesses in bytes
        accessLatencyInCycles: natural      -- the access latency in cycles
    );
    port (
        clk: in std_logic;
        ready: out std_logic;
        reqValid: in std_logic;
        reqAddr: in std_logic_vector((addrSize - 1) downto 0);
        reqRdWr: in std_logic;
        reqWrData: in std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0);
        reqRdData: out std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0)
    );
    constant totalSizeInBytes: natural := natural(2 ** addrSize);
end Memory;

architecture Behavioral of Memory is
    type tByteAddressableMemory is array (0 to (totalSizeInBytes - 1)) of std_logic_vector(7 downto 0);
    signal storage: tByteAddressableMemory := (others => x"FF");
    signal memCtrlState: std_logic := '0';
begin
    process (clk)
        variable currAddr: std_logic_vector((addrSize - 1) downto 0);
        variable currRdWr: std_logic;
        variable currWrData: std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0);
        variable latency: natural;
    begin
        if (rising_edge(clk)) then
            if (memCtrlState = '0') then
                ready <= '1';
                if (reqValid = '1') then
                    currAddr := reqAddr;
                    currRdWr := reqRdWr;
                    currWrData := reqWrData;
                    latency := accessLatencyInCycles - 1;
                
                    ready <= '0';
                    memCtrlState <= '1';
                end if;
            elsif (memCtrlState = '1') then
                if (latency = 0) then
                    for i in 0 to (accessGranularityInBytes - 1) loop
                        if (currRdWr = '0') then
                            reqRdData(((i + 1) * 8 - 1) downto (i * 8)) <= storage(to_integer(unsigned(currAddr)) + i); 
                        elsif (currRdWr = '1') then
                            storage(to_integer(unsigned(currAddr)) + i) <= currWrData(((i + 1) * 8 - 1) downto (i * 8));
                        end if;
                    end loop;
                    
                    ready <= '1';
                    memCtrlState <= '0';
                else
                    latency := latency - 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
