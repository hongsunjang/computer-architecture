library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PipelinedProcessor is
    port (
        clk: in std_logic
    );
end PipelinedProcessor;

architecture Behavioral of PipelinedProcessor is
    component InstructionMemory
    port(
        readAddress: in std_logic_vector(63 downto 0);
        instruction: out std_logic_vector(31 downto 0)
        );
    end component;
    component RegisterFile
    port(
        readRegister1: in std_logic_vector(4 downto 0);
        readData1: out std_logic_vector(63 downto 0);
        readRegister2: in std_logic_vector(4 downto 0);
        readData2: out std_logic_vector(63 downto 0);
        regWrite: in std_logic;
        writeRegister: in std_logic_vector(4 downto 0);
        writeData: in std_logic_vector(63 downto 0)
        );
    end component;
    component ArithmeticLogicUnit
    port (
        op: in std_logic_vector(3 downto 0);
        input1: in std_logic_vector(63 downto 0);
        input2: in std_logic_vector(63 downto 0);
        result: out std_logic_vector(63 downto 0);
        zero: out std_logic
        );
    end component;
    component DataMemory
    port(
        address: in std_logic_vector(63 downto 0);
        memRead: in std_logic;
        readData: out std_logic_vector(63 downto 0);
        memWrite: in std_logic;
        writeData: in std_logic_vector(63 downto 0)
        );
    end component;
    component ImmediateGenerator
    port (
        instruction: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(63 downto 0)
        );
    end component;
    component MainControlUnit
    port(
        input: in std_logic_vector(6 downto 0);
        Branch: out std_logic;
        MemToReg: out std_logic;
        MemRead: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        MemWrite: out std_logic;
        ALUSrc: out std_logic;
        RegWrite: out std_logic
        );
    end component;
    component ALUControlUnit
        port(
            ALUOp: in std_logic_vector(1 downto 0);
            input: in std_logic_vector(3 downto 0);
            output: out std_logic_vector(3 downto 0)
        );
    end component;
    component Multiplexer
         port (
            selector: in std_logic;
            input1: in std_logic_vector(63 downto 0);
            input2: in std_logic_vector(63 downto 0);
            output: out std_logic_vector(63 downto 0)
         );
    end component;
    component Multiplexer2 -- 3-to-1 multiplexer
        port (
            selector: in std_logic_vector(1 downto 0);
            input1: in std_logic_vector(63 downto 0);
            input2: in std_logic_vector(63 downto 0);
            input3: in std_logic_vector(63 downto 0);
            output: out std_logic_vector(63 downto 0)
        );
    end component;
    component ForwardingUnit
        port (
            IDEX_rs1: in std_logic_vector(4 downto 0);
            IDEX_rs2: in std_logic_vector(4 downto 0);
            EXMEM_RegWrite: in std_logic;
            EXMEM_rd: in std_logic_vector(4 downto 0);
            MEMWB_RegWrite: in std_logic;
            MEMWB_rd: in std_logic_vector(4 downto 0);
            ForwardA: out std_logic_vector(1 downto 0);
            ForwardB: out std_logic_vector(1 downto 0)
        );
    end component;
    component HazardDetectionUnit
        port (
            IDEX_MemRead: in std_logic;
            IDEX_RegisterRd: in std_logic_vector(4 downto 0);
            IFID_RegisterRs1: in std_logic_vector(4 downto 0);
            IFID_RegisterRs2: in std_logic_vector(4 downto 0);
            PCWrite: out std_logic;
            IFIDWrite: out std_logic;
            MakeBubble: out std_logic
        );
    end component;
    component BranchUnit
        port (
            controlBranch : in std_logic;
            ALUZero: in std_logic;
            doBranch: out std_logic
        );
   end component;
   
   -- PC
   signal PC: std_logic_vector(63 downto 0); 
   
    -- control signals for EX, M, and WB stages
    type tControlEX is
        record
            ALUOp: std_logic_vector(1 downto 0);
            ALUSrc: std_logic;
        end record;
    type tControlMEM is
        record
            Branch: std_logic;
            MemRead: std_logic;
            MemWrite: std_logic;
        end record;
    type tControlWB is
        record
            RegWrite: std_logic;
            MemToReg: std_logic;
        end record;
    
    -- latches
    type tLatchIFID is
        record
            PC: std_logic_vector(63 downto 0);
            instruction: std_logic_vector(31 downto 0);
        end record;
    type tLatchIDEX is
        record
            -- data
            PC: std_logic_vector(63 downto 0);
            readData1: std_logic_vector(63 downto 0);
            readData2: std_logic_vector(63 downto 0);
            immediate: std_logic_vector(63 downto 0);
            instruction_30_14downto12: std_logic_vector(3 downto 0);
            RegisterRs1: std_logic_vector(4 downto 0);
            RegisterRs2: std_logic_vector(4 downto 0);
            RegisterRd: std_logic_vector(4 downto 0);
            -- control signals
            controlEX: tControlEX;
            controlMEM: tControlMEM;
            controlWB: tControlWB;  
        end record;
    type tLatchEXMEM is
        record
            -- data
            branchTarget: std_logic_vector(63 downto 0);
            ALUZero: std_logic;
            ALUResult: std_logic_vector(63 downto 0);
            readData2: std_logic_vector(63 downto 0);
            RegisterRd: std_logic_vector(4 downto 0);
            -- control signals
            controlMEM: tControlMEM;
            controlWB: tControlWB;
        end record;
    type tLatchMEMWB is
        record
            -- data
            readData: std_logic_vector(63 downto 0);
            ALUResult: std_logic_vector(63 downto 0);
            RegisterRd: std_logic_vector(4 downto 0);
            -- control signals for WB stage
            controlWB: tControlWB;
        end record;
        
    signal latchIFID: tLatchIFID := (
        PC => (others => '0'),
        instruction => (others => '0')
    );
    signal latchIDEX: tLatchIDEX := (
        PC => (others => '0'),
        readData1 => (others => '0'),
        readData2 => (others => '0'),
        immediate => (others => '0'),
        instruction_30_14downto12 => (others => '0'),
        RegisterRs1 => (others => '0'),
        RegisterRs2 => (others => '0'),
        RegisterRd => (others => '0'),
        controlEX => (
            ALUOp => (others => '0'),
            ALUSrc => '0'
        ),
        controlMEM => (
            Branch => '0',
            MemRead => '0',
            MemWrite => '0'
        ),
        controlWB => (
            RegWrite => '0',
            MemToReg => '0'
        )
    );
    signal latchEXMEM: tLatchEXMEM := (
        branchTarget => (others => '0'),
        ALUZero => '0',
        ALUResult => (others => '0'),
        readData2 => (others => '0'),
        RegisterRd => (others => '0'),
        controlMEM => (
            Branch => '0',
            MemRead => '0',
            MemWrite => '0'
        ),
        controlWB => (
            RegWrite => '0',
            MemToReg => '0'
        )
    );
    signal latchMEMWB: tLatchMEMWB := (
        readData => (others => '0'),
        ALUResult => (others => '0'),
        RegisterRd => (others => '0'),
        controlWB => (
            RegWrite => '0',
            MemToReg => '0'
        )
    );
    
    --Regsiter
    signal firstRisingEdge: boolean := true;
    signal extendedInstruction:std_logic_vector(63 downto 0);
    
    -- wire
    -- IF stage
        -- rising edge of clk
    
        --falling edge of clk
    signal InstMemReadAddress:std_logic_vector(63 downto 0); -- PC regsiter to InstMem and IFID latch
    -- ID stage
        -- rising edge of clk
    signal Ctrl_MUX_output:std_logic_vector(63 downto 0) := (others=>'0'); -- Ctrl_MUX Output to opcde
    signal opcode:std_logic_vector(6 downto 0):= (others=>'0'); -- opcode for MCU 
    signal PCWrite : std_logic := '0'; -- hazardDetectionUnit to PC register
    signal IFIDWrite : std_logic := '0'; -- hazardDetectionUnit to IF/ID latch
    signal MakeBubble: std_logic:= '0'; -- hazard Detection Unit to Control Multiplexer
    signal IMM_GEN_output: std_logic_vector(63 downto 0);
  
        --falling edge of clk
    signal RFReadRegister1:std_logic_vector(4 downto 0);
    signal RFReadRegister2:std_logic_vector(4 downto 0);
    
    --EX stage
        -- (rising edge of clk)
        --hazard detection unit input
    signal IDEX_MemRead :std_logic;
    signal IDEX_RegisterRd :std_logic_vector(4 downto 0);
    signal IFID_RegisterRs1 :std_logic_vector(4 downto 0);
    signal IFID_RegisterRs2:std_logic_vector(4 downto 0);
        --IMMMultiplexer input
    signal immadiateValue : std_logic_vector(63 downto 0);
        -- ALU Control Unit input
    signal ALU_CU_ALUOp: std_logic_vector(1 downto 0);
    signal ALU_CU_input:std_logic_vector(3 downto 0);
        -- ALU Control Unit and immMultiplexer Output to ALUMUXOUTPUT
    signal ALU_CU_output:std_logic_vector(3 downto 0);
    signal immMultiplexerOutput: std_logic_vector(63 downto 0); -- IMM MULTIPLEXER to ALU INPUT1 MULTIPLEXER2a
    signal ALUMuxOutput1:std_logic_vector(63 downto 0);
    signal ALUMuxOutput2:std_logic_vector(63 downto 0);
        --forwarding unit input
    signal forwardingSelector1: std_logic_vector(1 downto 0);-- forwardingUnit to ALUInput1Selector
    signal forwardingSelector2: std_logic_vector(1 downto 0);-- forwardingUnit to ALUInput2Selector
        --(falling edge of clk)
        --ALU input 
    signal ALUInput1:std_logic_vector(63 downto 0):=(others=>'0'); -- ALU INPUT1 multiplexer2 to ALU
    signal ALUInput2:std_logic_vector(63 downto 0):=(others=>'0'); -- ALU INPUT2 multiplexer2 to ALU and latchEXMEM.readData2
    signal op:std_logic_vector(3 downto 0); -- ALU Control Unit to ALU
    signal F_UNIT_output1: std_logic_vector(1 downto 0);
    signal F_UNIT_output2: std_logic_vector(1 downto 0);
    
    --MEM stage
    -- rising edge of clk
    signal doBranch:std_logic; -- output of branch unit
    signal controlHazard: std_logic:= '0'; -- branch unit to PC regsiter, IF/ID 
    signal branchTarget:std_logic_vector(63 downto 0);
    signal memWrite: std_logic;
    
    -- falling edge of clk
    signal DataMem_readData:std_logic_vector(63 downto 0);
    
    -- WB stage
        --falling edge of clk
    signal writeRegister: std_logic_vector(4 downto 0):= (others=>'0');
    signal WRITEBACK_MUX_output: std_logic_vector(63 downto 0); -- WB Multiplexer ouput
        -- rising edge of clk
    signal regWrite:std_logic;
    signal RFWriteData:std_logic_vector(63 downto 0);
    
begin
    -- Instruction Memory
    InstMem: InstructionMemory port map(readAddress => InstMemReadAddress, instruction=>latchIFID.instruction );
    
    -- Register File (RF)
    RF: RegisterFile port map(readRegister1=> RFReadRegister1, readData1 => latchIDEX.ReadData1, 
                              readRegister2 => RFReadRegister2 , readData2 => latchIDEX.ReadData2, 
                              regWrite => regWrite, writeRegister => writeRegister, writeData => RFwriteData);
    
    -- Data Memory
    DataMem: DataMemory port map(address=>latchEXMEM.ALUResult, memRead =>latchEXMEM.controlMEM.memRead , 
                                 readData => DataMem_readData, memWrite => memWrite, writeData => latchEXMEM.readData2);
                               
    -- ID stage
        --rising edge of clk
    HDU: HazardDetectionUnit port map ( IDEX_MemRead => IDEX_MemRead , IDEX_RegisterRd => IDEX_RegisterRd, 
                                        IFID_RegisterRs1 => IFID_RegisterRs1 ,IFID_RegisterRs2=> IFID_RegisterRs2 ,
                                         PCWrite => PCWrite, IFIDWrite => IFIDWrite, MakeBubble => MakeBubble);
    MCU: MainControlUnit port map(input => opcode,  
                                   ALUOp => latchIDEX.controlEX.ALUOp,       ALUSrc => latchIDEX.controlEX.ALUSrc,
                                   MemRead => latchIDEX.controlMEM.MemRead,  MemWrite => latchIDEX.controlMEM.MemWrite, Branch => latchIDEX.controlMEM.Branch, 
                                   Regwrite => latchIDEX.controlWB.Regwrite, MemToReg => latchIDEX.controlWB.MemToReg );
    Ctrl_MUX: Multiplexer port map(selector => MakeBubble, input1 => extendedInstruction , input2 => (others=>'0'), output => Ctrl_MUX_output);  
    IMM_GEN: ImmediateGenerator port map(instruction => latchIFID.Instruction, output => IMM_GEN_output);
        --falling edge of clk
    
                              
    -- EX stage
        
        --rising edge of clk 
    ALU_CU: ALUControlUnit port map(ALUOp =>  ALU_CU_ALUOp, input=>  ALU_CU_input, output => ALU_CU_output);
    IMM_MUX: Multiplexer port map(selector => latchIDEX.controlEX.ALUSrc, input1 => latchIDEX.readData2, input2 =>immadiateValue, output =>immMultiplexerOutput );
    
    
    ALU_INPUT1_MUX2: Multiplexer2 port map(selector=>forwardingSelector1,input1=>latchIDEX.readData1,  input2=>RFWriteData, input3=>latchEXMEM.ALUResult, output =>ALUMuxOutput1);
    ALU_INPUT2_MUX2: Multiplexer2 port map(selector=>forwardingSelector2,input1=> immMultiplexerOutput, input2=>RFWriteData, input3=>latchEXMEM.ALUResult, output =>ALUMuxOutput2);
    
        --falling edge of clk
    ALU: ArithmeticLogicUnit port map(op =>op, input1 => ALUInput1  , input2 => ALUInput2 , result=> latchEXMEM.ALUResult , zero => latchEXMEM.ALUZero );
    F_UNIT: ForwardingUnit port map(IDEX_rs1=>latchIDEX.RegisterRs1,IDEX_rs2=>latchIDEX.RegisterRs2, EXMEM_RegWrite=>latchEXMEM.controlWB.RegWrite,
                                    EXMEM_rd=> latchEXMEM.RegisterRd,  MEMWB_RegWrite=>latchMEMWB.controlWB.RegWrite, MEMWB_rd=>latchMEMWB.RegisterRd,
                                    ForwardA=> F_UNIT_output1, ForwardB=> F_UNIT_output2);
    -- MEM stage
    BRANCH_UNIT: BranchUnit port map (controlBranch=>latchEXMEM.controlMEM.Branch, ALUZero=>latchEXMEM.ALUZero, doBranch=> doBranch);
    
    
    -- WB stage
    WRITEBACK_MUX: Multiplexer port map(selector => latchMEMWB.controlWB.MemToReg, input1 => latchMEMWB.ALUResult, input2 => latchMEMWB.ReadData, output => WRITEBACK_MUX_output);
    
   -- 64bit zero-extension of instruction
   extendedInstruction <= std_logic_vector(resize(unsigned(latchIFID.instruction),64));
   
   --PC process
   process(clk)
   begin
        if(rising_edge(clk)) then
            -- first Rising edge of clk
            if(FirstRisingedge) then
                PC <= std_logic_vector(to_unsigned(4, 64));
                firstRisingEdge<= false;
            else
                --IF               
                if(controlHazard = '1') then
                    -- Branch executed
                    PC <= branchTarget;
                else
                    if(PCWrite = '1') then
                        PC<=PC;
                    else
                        PC<=std_logic_vector(unsigned(PC) + 4);
                    end if;
                end if;
                
                --wire to IF/ID latch to ID/EX
                latchIDEX.PC<= latchIFID.PC;
                latchIDEX.instruction_30_14downto12 <= latchIFID.instruction(30)&latchIFID.instruction(14 downto 12);
                latchIDEX.RegisterRs1 <= latchIFID.instruction(19 downto 15);
                latchIDEX.RegisterRs2 <= latchIFID.instruction(24 downto 20);
                latchIDEX.RegisterRd <= latchIFID.instruction(11 downto 7);
                latchIDEX.Immediate <= IMM_GEN_output;
                
                
                --hazard detection
                IDEX_MemRead <= latchIDEX.controlMem.MemRead;
                IDEX_RegisterRd <= latchIDEX.RegisterRd;
                IFID_RegisterRs1 <= latchIFID.instruction(19 downto 15);
                IFID_RegisterRs2 <=latchIFID.instruction(24 downto 20);
                
                -- EX stage
                immadiateValue <= latchIDEX.immediate;
                ALU_CU_input<=latchIDEX.instruction_30_14downto12;
                ALU_CU_ALUOp<=latchIDEX.controlEX.ALUOp;
                forwardingSelector1<=F_UNIT_output1;
                forwardingSelector2<=F_UNIT_output2;
                
                latchEXMEM.branchTarget<= std_logic_vector(unsigned(latchIDEX.PC) + (unsigned(latchIDEX.immediate) sll 1)); -- get branch target address
                
                latchEXMEM.RegisterRd<= latchIDEX.RegisterRd;
                if((latchEXMEM.controlMEM.Branch = '1') and (latchEXMEM.ALUZero = '1')) then
                    latchEXMEM.controlMEM <= (others=>'0'); 
                    latchEXMEM.controlWB <= (others=>'0');
                else    
                    latchEXMEM.controlMEM<= latchIDEX.controlMEM;
                    latchEXMEM.controlWB<= latchIDEX.controlWB;
                end if;
                
                
                
                -- MEM stage 
                controlHazard <= doBranch;
                branchTarget <= latchEXMEM.branchTarget;
                    -- memory write
                memWrite <= latchEXMEM.controlMEM.memWrite;
                
                latchMEMWB.ALUResult<=latchEXMEM.ALUResult;
                latchMEMWB.RegisterRd<=latchEXMEM.RegisterRd;
                latchMEMWB.controlWB<=latchEXMEM.controlWB;
                   
                 -- WB stage
                regWrite <= latchMEMWB.controlWB.regWrite;
                RFWriteData<=WRITEBACK_MUX_output;
                
            end if;
        elsif(falling_edge(clk)) then
  
            --Branch handling
            if(controlHazard ='1') then
                InstMemReadAddress <= (others=>'0');
                opcode <= (others=>'0');
                latchEXMEM.controlMEM <= (others=>'0');
            else
                -- IF stage (Read instruction by PC and write to IF/ID latch)
                if(IFIDWrite = '1') then
                     latchIFID.PC<= std_logic_vector(unsigned(PC) - 4);
                    InstMemReadAddress <= std_logic_vector(unsigned(PC) - 4);
                else
                     latchIFID.PC<=PC;
                    InstMemReadAddress <=PC;
                end if;
                --ID stage (Register read)           
                opcode <=Ctrl_MUX_output(6 downto 0);
                RFReadRegister1 <= latchIFID.instruction(19 downto 15);
                RFReadRegister2 <=latchIFID.instruction(24 downto 20);
            end if;
            -- EX stage(ALU Unit)
            op <= ALU_CU_output;
            ALUInput1 <= ALUMuxOutput1;
            ALUInput2 <= ALUMuxOutput2;
            
            -- MEM stage
                --(Read Memory)
            latchMEMWB.readData<=DataMem_readData;
                --(Memory write)
            latchEXMEM.readData2<= latchIDEX.readData2;
            memWrite <= '0';
            
            -- WB stage
            regWrite <= '0';
            writeRegister <= latchMEMWB.RegisterRd;
        end if;  
    end process; 
end Behavioral;
