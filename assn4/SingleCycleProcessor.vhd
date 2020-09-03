library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SingleCycleProcessor is
    port (
        clk: in std_logic
    );
end SingleCycleProcessor;

architecture Behavioral of SingleCycleProcessor is
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
    component Multiplexer
    port (
        selector: in std_logic;
        input1: in std_logic_vector(63 downto 0);
        input2: in std_logic_vector(63 downto 0);
        output: out std_logic_vector(63 downto 0)
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
    
    -- PC
    signal PC: std_logic_vector(63 downto 0); 
    signal firstRisingEdge: boolean := true;
    signal instruction:std_logic_vector(31 downto 0);
    
    -- control signals
    signal CtrlBranch:std_logic; -- MCU --> BRANCH_MUX
    signal CtrlMemToReg: std_logic; -- MCU --> WRITEBACK_MUX
    signal CtrlMemRead: std_logic; -- MCU --> DATA_MEM
    signal CtrlALUOp: std_logic_vector(1 downto 0); -- MCU --> ALUCU
    signal CtrlMemWrite: std_logic; -- MCU --> DATA_MEM
    signal CtrlALUSrc: std_logic; -- MCU --> ALU_MUX
    signal CtrlRegwrite:std_logic; -- MCU --> RF
    
    --  wire depend on falling edge of clk
    signal memWrite: std_logic; -- clk and MCU's ctrlmemWrite --> MEM's memWrite 
    signal regWrite:std_logic; -- clk and CtrlRegwrite --> RF
    
    -- wires
    signal regReadData1: std_logic_vector(63 downto 0); -- RF --> ALU
    signal regReadData2: std_logic_vector(63 downto 0); -- RF --> ALU_MUX and DATA_MEM
    signal RegWriteData: std_logic_vector(63 downto 0); -- WRITE_BACK_MUX output --> RF
      
    signal ImmediateOutput:std_logic_vector(63 downto 0); -- IMMGEN --> ALU_MUX and ADD_PC
    
    signal ALUinput2:std_logic_vector(63 downto 0); -- ALU_MUX --> ALU
    signal op: std_logic_vector(3 downto 0); -- ALU_CU --> ALU
    signal ALUresult:std_logic_vector(63 downto 0); --ALU --> DATA_MEM and WRITEBACK_MUX
    signal zero: std_logic; -- ALU --> ADDPC
    
    signal MemReadData: std_logic_vector(63 downto 0); -- DATA_MEM -> WRITEBACK_MUX
    
    
begin
    -- Register File(RF)
    RF: RegisterFile port map(readRegister1=>instruction(19 downto 15), readData1 => regReadData1, 
                              readRegister2 => instruction(24 downto 20), readData2 => regReadData2, 
                              regWrite => regWrite, writeRegister => instruction(11 downto 7), writeData => RegWriteData);
    -- Data Memory
    DataMem: DataMemory port map(address=>ALUresult, memRead => CtrlmemRead, readData => memReadData , memWrite => memWrite ,writeData => regReadData2);
    -- ALU
    ALU: ArithmeticLogicUnit port map(op => op, input1 => regReadData1, input2 => ALUinput2, result=> ALUresult, zero => zero);
     -- instruction memory(INST_MEM)
    INST_MEM: InstructionMemory port map(readAddress => PC, instruction=> instruction);
    ALU_MUX: Multiplexer port map(selector => CtrlALUSrc, input1 => regReadData2, input2 => immediateOutput, output => ALUinput2);
    WRITEBACK_MUX: Multiplexer port map(selector => CtrlMemtoReg, input1 => ALUResult, input2 => memReadData, output => regwriteData);
    IMM_GEN: ImmediateGenerator port map(instruction => instruction, output => ImmediateOutput);
    MCU: MainControlUnit port map(input => instruction(6 downto 0), Branch => CtrlBranch, MemToReg => CtrlMemToReg, MemRead => CtrlMemRead,
                                  ALUOp => CtrlALUOp, MemWrite => CtrlMemWrite, ALUSrc => CtrlALUSrc, Regwrite => CtrlRegwrite);
    ALU_CU: ALUControlUnit port map(ALUOp => CtrlALUOp, input(3)=> instruction(30), input(2 downto 0)=>instruction(14 downto 12), output => op);
 
   --PC process
   process(clk)
   begin
        if(rising_edge(clk)) then
            regWrite <= '0';
            memWrite <= '0';
            if(firstRisingEdge) then
                PC <= std_logic_vector(to_unsigned(4, 64));
                firstRisingEdge <= false;
            else
                if(CtrlBranch = '1' and zero ='1') then
                    PC <= std_logic_vector(unsigned(PC) + (unsigned(immediateOutput) sll 1 ));
                else
                    PC <= std_logic_vector(unsigned(PC) +4);
                end if;
            end if;
        elsif(falling_edge(clk)) then
            if(CtrlRegWrite = '1') then
                regWrite <= '1';
            end if;
            if(CtrlMemWrite = '1') then
                memWrite <= '1';
            end if;
        end if;  
    end process; 
end Behavioral;
