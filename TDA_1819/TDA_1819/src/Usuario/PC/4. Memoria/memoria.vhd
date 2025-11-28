library TDA_1819;
use TDA_1819.const_memoria.all;
use TDA_1819.tipos_memoria.all;
use TDA_1819.const_buses.all;

library IEEE;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_1164.all; 


entity memoria is
	
    port (
        DataDataBusOutMem   : out std_logic_vector(31 downto 0);
        InstDataBusOutMem   : out std_logic_vector(31 downto 0);
        EnableDataMemToCpu  : out std_logic;
        EnableInstMemToCpu  : out std_logic;
        DataAddrBusMem      : in  std_logic_vector(15 downto 0);
        DataDataBusInMem    : in  std_logic_vector(31 downto 0);
        DataSizeBusMem      : in  std_logic_vector(3 downto 0);
        DataCtrlBusMem      : in  std_logic_vector(1 downto 0);
        InstAddrBusMem      : in  std_logic_vector(15 downto 0);
        InstDataBusInMem    : in  std_logic_vector(31 downto 0);
        InstSizeBusMem      : in  std_logic_vector(3 downto 0);
        InstCtrlBusMem      : in  std_logic_vector(1 downto 0);	
        EnableInDataMem     : in  std_logic;
        EnableInInstMem     : in  std_logic
    );

end memoria;


architecture MEMORIA_ARCHITECTURE of memoria is

    SIGNAL Memory       : type_memory(MEMORY_BEGIN to MEMORY_END);
    SIGNAL Data_Memory  : type_memory(DATA_BEGIN   to INST_BEGIN-1);
    SIGNAL Inst_Memory  : type_memory(INST_BEGIN   to SUBR_BEGIN-1);
    SIGNAL Subr_Memory  : type_memory(SUBR_BEGIN   to STACK_BEGIN-1);
    SIGNAL Stack_Memory : type_memory(STACK_BEGIN  to MEMORY_END);

begin
    DataMemory: PROCESS
	
        VARIABLE First      : BOOLEAN := true;
        VARIABLE intAddress : INTEGER; 
        VARIABLE accessSize : INTEGER;
        VARIABLE iDataBus   : INTEGER;
	
    BEGIN
        WAIT UNTIL rising_edge(EnableInDataMem);

        if (First) then
            First := false;
            EnableDataMemToCpu <= '0';
            WAIT FOR 1 ps;
        end if;

        intAddress := to_integer(unsigned(DataAddrBusMem)); 
        accessSize := to_integer(unsigned(DataSizeBusMem));
        iDataBus   := 0;

        -- ahora acepto accesos tanto a la memoria de datos [DATA_BEGIN .. INST_BEGIN-1]
        -- como al segmento de pila [STACK_BEGIN .. MEMORY_END].
        if not (
            (intAddress >= DATA_BEGIN  and intAddress <= INST_BEGIN-1) or
            (intAddress >= STACK_BEGIN and intAddress <= MEMORY_END)
        ) then
            report "Error: la dirección seleccionada no pertenece a la memoria de datos/pila"
            severity FAILURE;
        end if;

        if (DataCtrlBusMem = READ_MEMORY) then

            for i in 0 to accessSize-1 loop

                -- leo de Data_Memory o Stack_Memory según el rango.
                if (intAddress >= DATA_BEGIN and intAddress <= INST_BEGIN-1) then
                    for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
                        DataDataBusOutMem(iDataBus) <= Data_Memory(intAddress)(j);
                        iDataBus := iDataBus + 1;
                    end loop;
                elsif (intAddress >= STACK_BEGIN and intAddress <= MEMORY_END) then
                    for j in 0 to Stack_Memory(intAddress)'LENGTH-1 loop
                        DataDataBusOutMem(iDataBus) <= Stack_Memory(intAddress)(j);
                        iDataBus := iDataBus + 1;
                    end loop;
                end if;

                intAddress := intAddress + 1;
            end loop;

            EnableDataMemToCpu <= '1';
            WAIT FOR 1 ps;
            EnableDataMemToCpu <= '0';

        elsif (DataCtrlBusMem = WRITE_MEMORY) then 

            for i in 0 to accessSize-1 loop

                -- escribo en Data_Memory o Stack_Memory según el rango.
                if (intAddress >= DATA_BEGIN and intAddress <= INST_BEGIN-1) then
                    for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
                        Data_Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
                        iDataBus := iDataBus + 1;
                    end loop;
                elsif (intAddress >= STACK_BEGIN and intAddress <= MEMORY_END) then
                    for j in 0 to Stack_Memory(intAddress)'LENGTH-1 loop
                        Stack_Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
                        iDataBus := iDataBus + 1;
                    end loop;
                end if;

                intAddress := intAddress + 1;
            end loop;

        else
            report "Error: el bus de control de la memoria de datos no posee un valor válido"
            severity FAILURE;
        end if;
    END PROCESS DataMemory;
	
	
 	InstMemory: PROCESS
	
	VARIABLE First: BOOLEAN := true;
	VARIABLE intAddress: INTEGER; 
	VARIABLE accessSize: INTEGER;
	VARIABLE iDataBus: INTEGER;
	
	BEGIN
		WAIT UNTIL rising_edge(EnableInInstMem);
		if (First) then
			First := false;
			EnableInstMemToCpu <= '0';
			WAIT FOR 1 ps;
		end if;
		intAddress := to_integer(unsigned(InstAddrBusMem)); 
		accessSize := to_integer(unsigned(InstSizeBusMem));
		iDataBus := 0;
		if ((intAddress < INST_BEGIN) or (intAddress > SUBR_BEGIN-1)) then
			report "Error: la dirección seleccionada no pertenece a la memoria de instrucciones"
			severity FAILURE;
		end if;
		if (InstCtrlBusMem = READ_MEMORY) then
			for i in 0 to accessSize-1 loop
				for j in 0 to Inst_Memory(intAddress)'LENGTH-1 loop
					InstDataBusOutMem(iDataBus) <= Inst_Memory(intAddress)(j);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
			EnableInstMemToCpu <= '1';
			WAIT FOR 1 ps;
			EnableInstMemToCpu <= '0'; 
		elsif (InstCtrlBusMem = WRITE_MEMORY) then
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					Inst_Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					--Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		else
			report "Error: el bus de control de la memoria de instrucciones no posee un valor válido"
			severity FAILURE;
		end if;
	END PROCESS InstMemory;	 
	
	
	FullMemory: PROCESS	  
	
	VARIABLE intAddress: INTEGER; 
	VARIABLE accessSize: INTEGER;
	VARIABLE iDataBus: INTEGER;
	
	BEGIN
		WAIT UNTIL (rising_edge(EnableInDataMem) OR rising_edge(EnableInInstMem)); 
		if ((EnableInDataMem = '1') and (DataCtrlBusMem = WRITE_MEMORY)) then
			intAddress := to_integer(unsigned(DataAddrBusMem)); 
			accessSize := to_integer(unsigned(DataSizeBusMem));
			iDataBus := 0;
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop
					Memory(intAddress)(j) <= DataDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		elsif ((EnableInInstMem = '1') and (InstCtrlBusMem = WRITE_MEMORY)) then 
			intAddress := to_integer(unsigned(InstAddrBusMem)); 
			accessSize := to_integer(unsigned(InstSizeBusMem));
			iDataBus := 0;
			for i in 0 to accessSize-1 loop
				for j in 0 to Data_Memory(intAddress)'LENGTH-1 loop	   
					Memory(intAddress)(j) <= InstDataBusInMem(iDataBus);
					iDataBus := iDataBus + 1;
				end loop;
				intAddress := intAddress + 1;
			end loop;
		end if;
	END PROCESS FullMemory;
				
end MEMORIA_ARCHITECTURE;
