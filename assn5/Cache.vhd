library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity Cache is
    generic (
        addrSize: natural;                  -- the # of memory address bits (e.g., 64/32 for 64/32 bits)
        accessGranularityInBytes: natural;  -- the granularity of cache accesses in bytes
        totalSizeInBytes: natural;          -- the total size of the cache in bytes (only the data part)
        numWays: natural;                   -- the # of cache ways (i.e., associativity)
        blockSizeInBytes: natural           -- the size of a cache block in bytes (only the data part)
    );
    port (
        clk: in std_logic;
        ready: out std_logic;
        reqValid: in std_logic;
        reqAddr: in std_logic_vector((addrSize - 1) downto 0);
        reqRdWr: in std_logic;
        reqWrData: in std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0);
        reqRdData: out std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0);
        memReady: in std_logic;
        memReqValid: out std_logic;
        memReqRdWr: out std_logic;
        memReqAddr: out std_logic_vector((addrSize - 1) downto 0);
        memReqWrData: out std_logic_vector((blockSizeInBytes * 8 - 1) downto 0);
        memReqRdData: in std_logic_vector((blockSizeInBytes * 8 - 1) downto 0)
    );
    constant numBlocks: natural := totalSizeInBytes / (blockSizeInBytes);       -- FIXME
    constant numSets: natural := totalSizeInBytes / (numWays * blockSizeInBytes);         -- FIXME
    constant numBlocksPerSet: natural := numWays; -- FIXME
    constant numIndexBits: natural := natural(CEIL(log2(real(numSets))));    -- FIXME
    constant numOffsetBits: natural :=natural(CEIL(log2(real(blockSizeInBytes / accessGranularityInBytes))));   -- FIXME
    constant numTagBits: natural := addrSize - numIndexBits - numOffsetBits;      -- FIXME
    
    constant zeroOffsetBits: std_logic_vector((numOffsetBits - 1) downto 0) := (others=>'0'); 
end Cache;

architecture Behavioral of Cache is
    type tBlock is record
        valid: std_logic;
        dirty: std_logic;
        tag: std_logic_vector((numTagBits - 1) downto 0);
        data: std_logic_vector((blockSizeInBytes * 8 - 1) downto 0);
        LRUCounter: natural;
    end record;
    type tSet is array (0 to (numBlocksPerSet - 1)) of tBlock;
    type tCache is array (0 to (numSets - 1)) of tSet;
    signal cache: tCache := (others => (others => (
        dirty => '0',
        valid => '0',
        tag => (others => '0'),
        data => (others => '0'),
        LRUCounter => 0
    )));
    
    signal ctrlState: std_logic_vector(1 downto 0) := "00";
    -- 00: Idle, 01: Compare Tag, 10: Write-Back, 11: Allocate
    
    
    
    signal address: std_logic_vector((addrSize - 1) downto 0);
    signal target_offset_value: integer:= 0;
    signal target_index_value: integer:= 0;
    signal target_tag_value: std_logic_vector((numTagBits-1) downto 0);
    signal target_reqRdWr: std_logic;
    signal target_reqWrData: std_logic_vector((accessGranularityInBytes * 8 - 1) downto 0);
    
    signal writeBack_next_address: std_logic_vector((addrSize - 1) downto 0);
    signal memRequested:std_logic := '0';
    
    signal firstRisingOfclk: std_logic := '1';
    --
begin
    process(clk, reqValid)
        variable cache_hit:std_logic;
        variable set_full: std_logic;
        variable highest_lru: natural;
    begin
        if(rising_edge(clk)) then
            report "numIndexbits = " & natural'image (numIndexBits)&"numOffsetBits = " & natural'image(numOffsetBits);
            if(ctrlState = "00") then
                if(reqValid = '1') then
                    ctrlState <= "01";
                    ready <= '0';
                    address<=reqAddr;
                    target_offset_value <= accessGranularityInBytes * 8 * to_integer(unsigned( reqAddr((numOffsetBits-1) downto 0)));
                    target_index_value <= to_integer(unsigned(reqAddr((numIndexBits + numOffsetBits-1) downto numOffsetBits)));
                    target_tag_value <= reqAddr((addrSize-1) downto (addrSize- numTagBits));
                    target_reqRdWr <= reqRdWr;
                    if(reqRdWr = '1') then
                        target_reqWrData <= reqWrdata;
                    end if;
                else
                    ready <= '1';
                end if;
                
                -- lru count
                for i in 0 to (numSets-1) loop
                    for j in 0 to (numBlocksPerSet - 1) loop
                        if(cache(i)(j).valid = '1') then
                            cache(i)(j).LRUcounter <= cache(i)(j).LRUcounter + 1;
                        end if;
                    end loop;
                end loop;
            elsif(ctrlState = "01") then
                cache_hit:= '0';
                set_full:= '1';
                highest_lru:= 0;
                -- Cache Hit check loop (State = "01")
                for i in 0 to (numBlocksPerSet -1) loop
                    -- Cache HIT
                    if((cache_hit = '0') and (cache(target_index_value)(i).valid = '1') and (cache(target_index_value)(i).tag = target_tag_value)) then
                        cache_hit := '1';
                        if(target_reqRdWr = '0') then
                            reqRdData <= cache(target_index_value)(i).data((target_offset_value + 8*accessGranularityInBytes - 1) downto (target_offset_value));
                            cache(target_index_value)(i).LRUcounter <= 0;
                        elsif(target_reqRdWr = '1') then
                            cache(target_index_value)(i).dirty <= '1';
                            cache(target_index_value)(i).data((target_offset_value + 8*accessGranularityInBytes - 1) downto (target_offset_value)) <= target_reqWrData;
                            cache(target_index_value)(i).LRUcounter <= 0;
                        end if;
                        ctrlState <= "00";
                        ready <= '1';
                    end if;
                end loop;
                
                -- Cache Miss (State = "01")
                if(cache_hit = '0') then
                    -- Check whether ther is empty set
                    for i in 0 to (numBlocksPerSet -1) loop
                        if((set_full = '1') and (cache(target_index_value)(i).valid = '0')) then
                            set_full := '0';
                            -- Read/Write memory Requested data or do memory Request;
                            if(memRequested = '1') then
                                if(target_reqRdWr = '0') then
                                    reqRdData <= memReqRdData((target_offset_value + 8*accessGranularityInBytes - 1) downto (target_offset_value));
                                    cache(target_index_value)(i).valid <= '1';
                                    cache(target_index_value)(i).dirty <= '0';
                                    cache(target_index_value)(i).tag <= target_tag_value;
                                    cache(target_index_value)(i).data <= memReqRdData;
                                    cache(target_index_value)(i).LRUcounter <= 0;
                                elsif(target_reqRdWr = '1') then
                                    cache(target_index_value)(i).valid <= '1';
                                    cache(target_index_value)(i).dirty <= '1';
                                    cache(target_index_value)(i).tag <= target_tag_value;
                                    cache(target_index_value)(i).data <= memReqRdData((blockSizeInBytes * 8 - 1) downto (target_offset_value +8*accessGranularityInBytes))
                                                                         &target_reqWrData
                                                                         &memReqRdData((target_offset_value - 1) downto 0);
                                    cache(target_index_value)(i).LRUcounter <= 0;
                                end if;
                                memRequested <= '0';
                                ctrlState <= "00";        
                                ready <= '1';
                            elsif(memRequested = '0') then    
                                -- Memory requested signal on
                                memReqValid<= '1';
                                memReqRdWr <=  '0';
                                memReqAddr <= address;
                                memReqWrData<= (others=>'0');
                                
                                -- Memory requested signal on
                                memRequested <= '1';
                                
                                ctrlState <= "11";
                            end if;
                        end if;
                    end loop;
                    
                    -- if set is full, evict block 
                    if(set_full = '1') then
                        for i in 0 to (numBlocksPerSet - 1) loop
                            if(highest_lru < cache(target_index_value)(i).LRUcounter) then
                                highest_lru := cache(target_index_value)(i).LRUcounter;
                            end if;
                        end loop;
                        for i in 0 to (numBlocksPerSet - 1) loop
                            if(cache(target_index_value)(i).LRUcounter = highest_lru) then
                                -- Cache block is clean 
                                if(cache(target_index_value)(i).dirty = '0') then
                                   -- Set the cache block to empty block
                                   cache(target_index_value)(i).valid <= '0';
                                        
                                   memReqValid<= '1';
                                   memReqRdWr <=  '0';
                                   memReqAddr <= address;
                                   memReqWrData<= (others=>'0');
                                   ctrlState <= "11";
                                        
                                    -- Memory requested signal on
                                    memRequested <= '1';
                                -- Cache block is dirty
                                elsif(cache(target_index_value)(i).dirty = '1') then
                                    -- Set the cache block to empty block
                                    cache(target_index_value)(i).valid <= '0';
                                        
                                    writeBack_next_address <= address;
                                    memReqValid<= '1';
                                    memReqRdWr <=  '1';
                                    memReqAddr <= (cache(target_index_value)(i).tag) & std_logic_vector(to_unsigned(target_index_value, numIndexBits)) & (zeroOffsetBits);
                                    memReqWrData<= cache(target_index_value)(i).data;
                                    ctrlState <= "10";
                                    
                                    -- Memory requested signal on
                                    memRequested <= '1';
                                end if;
                            end if;
                        end loop;
                    end if;
                end if;
            elsif(ctrlState = "10") then
                if((memReady = '1') and (firstRisingOfclk = '1')) then
                    firstRisingOfClk <= '0';
                    memReqValid<='0'; 
                elsif((memReady = '1') and (firstRisingOfclk = '0')) then
                    firstRisingOfClk <= '1';
                    memReqValid <= '1';
                    memReqRdWr <= '0';
                    memReqAddr <= writeBack_next_address;
                    memReqWrData <= (others=>'0');
                    ctrlState <= "11";
                end if;
            elsif(ctrlState = "11") then
                if((memReady = '1') and (firstRisingOfclk = '1')) then
                    firstRisingOfClk <= '0';
                    memReqValid<='0';      
                elsif((memReady = '1') and (firstRisingOfClk = '0')) then
                    firstRisingOfClk <= '1';
                    ctrlState <= "01";
                end if; 
            end if; -- ctrlState
        end if; -- rising edge of clk
    end process;
end Behavioral;
