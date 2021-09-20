----------------------------------------------------------------------------------
-- Company:  Politecnico di Milano
-- 
-- Create Date: 10.04.2021 16:30:10
-- Module Name: 10656643_10660217 - Behavioral
-- Project Name: Prova Finale - Reti Logiche 2020/2021
-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use ieee.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;
architecture Behavioral of project_reti_logiche is
    -- Stati per FSM
    type stateType is(
        IDLE,
        CALC_NUMPIXEL,
        CALC_DELTA,
        CALC_SHIFT,
        CALC_NEWPIXEL,
        READ,
        DONE);
    signal currentState, nextState: stateType;
    signal currentAddress, nextAddress: std_logic_vector(15 downto 0);
    signal maxPixel, maxPixel_next : integer range 0 to 255;
    signal minPixel, minPixel_next : integer range 0 to 255;
    signal colonne, colonne_next, righe, righe_next: integer range 0 to 128;
    signal numPixel, numPixel_next: integer;
    signal deltaValue: integer range 0 to 255;
    signal deltaValue_next: integer range 0 to 255;
    signal shiftLevel,  shiftLevel_next: integer;
begin
    registroStati: process(i_clk, i_rst)
        begin
            if(i_rst = '1') then 
                currentState <= IDLE;
            elsif (rising_edge(i_clk)) then
                colonne <= colonne_next;
                righe <= righe_next;
                numPixel <= numPixel_next;
                deltaValue <= deltaValue_next;
                shiftLevel <= shiftLevel_next;    
                maxPixel <= maxPixel_next;
                minPixel <= minPixel_next;
                currentAddress <= nextAddress;
                currentState <= nextState;
            end if;
        end process;
    operazioni: process(currentState, currentAddress, i_start, i_data, maxPixel, minPixel, righe, colonne, deltaValue, numPixel,shiftLevel)
        
        variable datoSalvato: unsigned (15 downto 0);
        begin
            o_en <= '0';
            o_we <= '0';
            o_done <= '0';
            o_data <= "00000000";
            o_address <= currentAddress;
            colonne_next <= 0;
            righe_next <= 0;
            maxPixel_next <= 0;
            minPixel_next <= 255;
            numPixel_next <= 0;
            deltaValue_next <= 0;
            shiftLevel_next <= 0;
            nextAddress <= (others => '0');
            nextState <= currentState;
            
            case currentState is 
                when IDLE =>
                    if( i_start = '1') then
                        o_en <= '1';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        o_address <= (others => '0');
                        maxPixel_next <= 0;
                        minPixel_next <= 255;
                        colonne_next <= 0;
                        righe_next <= 0;
                        numPixel_next <= 0;
                        deltaValue_next <= 0;
                        shiftLevel_next <= 0;
                        nextAddress <= (others => '0');
                        nextState <= CALC_NUMPIXEL;
                    else
                        o_en <= '0';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        o_address <= (others => '0');
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        deltaValue_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        nextAddress <= currentAddress;
                        nextState <= IDLE;
                    end if;
                when CALC_NUMPIXEL =>
                    if(currentAddress = "0000000000000000") then
                        colonne_next <= conv_integer(i_data);
                        o_en <= '1';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        deltaValue_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        o_address <= "0000000000000001";
                        nextAddress <= "0000000000000001";
                        nextState <= CALC_NUMPIXEL;
                     elsif( currentAddress = "0000000000000001") then
                        righe_next <= TO_INTEGER(unsigned(i_data));
                        o_en <= '1';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        numPixel_next <= numPixel;
                        deltaValue_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        o_address <= "0000000000000010";
                        nextAddress <= "0000000000000010";
                        nextState <= CALC_NUMPIXEL;
                    else
                        numPixel_next <= righe*colonne;
                        o_en<= '1';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        o_address <= currentAddress;
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        righe_next <= righe;
                        deltaValue_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        nextAddress <= currentAddress;
                        nextState <= CALC_DELTA;
                    end if;
                when CALC_DELTA =>
                    if( currentAddress <= std_logic_vector(TO_UNSIGNED(numPixel+1, 16))) then
                        if(minPixel > conv_integer(i_data)) then
                            minPixel_next <= conv_integer(i_data);
                        else
                            minPixel_next <= minPixel;
                        end if;
                        if(maxPixel < conv_integer(i_data)) then
                            maxPixel_next <= conv_integer(i_data);
                        else 
                            maxPixel_next <= maxPixel;
                        end if;
                        o_en <= '1';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        colonne_next <= colonne;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        deltaValue_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        o_address <= currentAddress+"0000000000000001";
                        nextAddress <= currentAddress+"0000000000000001";
                        nextState <= CALC_DELTA;
                     else
                        deltaValue_next <= maxPixel - minPixel;
                        o_en <= '0';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        shiftLevel_next <= shiftLevel;
                        
                        o_address <= "0000000000000010";
                        nextAddress <= "0000000000000010";
                        nextState <= CALC_SHIFT;
                     end if;
                when CALC_SHIFT =>
                    if(deltaValue+ 1 = 1) then
                        shiftLevel_next <= 8;
                    elsif(deltaValue + 1 > 1 and deltaValue + 1 < 4) then
                        shiftLevel_next <= 7; 
                    elsif(deltaValue + 1 > 3 and deltaValue + 1 < 8) then   
                        shiftLevel_next <= 6;
                    elsif(deltaValue + 1 > 7 and deltaValue + 1 < 16) then
                        shiftLevel_next <= 5;
                    elsif(deltaValue + 1 > 15 and deltaValue + 1 < 32) then
                        shiftLevel_next <= 4;
                    elsif(deltaValue + 1 > 31 and deltaValue + 1 < 64) then
                        shiftLevel_next <= 3;
                    elsif(deltaValue + 1 > 63 and deltaValue + 1 < 128) then
                        shiftLevel_next <= 2; 
                    elsif(deltaValue + 1 > 127 and deltaValue + 1 < 256) then
                        shiftLevel_next <= 1;
                    else
                        shiftLevel_next <= 0; 
                    end if;
                    o_en <= '1';
                    o_we <= '0';
                    o_done <= '0';
                    o_data <= "00000000";
                    o_address <= (others => '0');
                    maxPixel_next <= maxPixel;
                    minPixel_next <= minPixel;
                    colonne_next <= colonne;
                    righe_next <= righe;
                    numPixel_next <= numPixel;
                    deltaValue_next <= numPixel;
                    nextAddress <="0000000000000010";
                    nextState <= CALC_NEWPIXEL;
                when CALC_NEWPIXEL =>
                    if(currentAddress - "0000000000000001" <=  std_logic_vector(TO_UNSIGNED(numPixel+1, 16))) then
                        datoSalvato := shift_left(TO_UNSIGNED((TO_INTEGER(unsigned(i_data)) - minPixel),16), shiftLevel);
                        if(TO_INTEGER(datoSalvato) < 255) then
                            o_data <= std_logic_vector(TO_UNSIGNED(TO_INTEGER(datoSalvato), 8));
                        else 
                            o_data <= "11111111";
                        end if;
                        if(currentAddress ="0000000000000010") then
                            o_en <= '1';
                            o_we <= '0';
                            o_address <= currentAddress + std_logic_vector(TO_UNSIGNED(numPixel, 16));
                        else 
                            o_en <= '1';
                            o_we <= '1';
                            o_address <= currentAddress + std_logic_vector(TO_UNSIGNED(numPixel-1, 16));
                        end if;
                        o_done <= '0';
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        deltaValue_next <= deltaValue;
                        shiftLevel_next <= shiftLevel;
                        nextAddress <= currentAddress;
                        nextState <= READ; 
                    else 
                        o_en <= '0';
                        o_we <= '0';
                        o_done <= '0';
                        o_data <= "00000000";
                        o_address <= (others => '0');
                        maxPixel_next <= maxPixel;
                        minPixel_next <= minPixel;
                        colonne_next <= colonne;
                        righe_next <= righe;
                        numPixel_next <= numPixel;
                        deltaValue_next <= deltaValue;
                        shiftLevel_next <= shiftLevel;
                        nextAddress <= currentAddress;
                        nextState <= READ;
                    end if;
              when READ =>
                    if(currentAddress <= std_logic_vector(TO_UNSIGNED(numPixel+1, 16))) then
                        o_en <= '1';
                        o_done <= '0';
                        nextAddress <= currentAddress + "0000000000000001";
                        nextState <= CALC_NEWPIXEL;
                    else 
                        o_en <= '0';
                        o_done <= '1';
                        nextAddress <= currentAddress;
                        nextState <= DONE;
                    end if;
                    o_we <= '0';
                    o_data <= "00000000";
                    o_address <= currentAddress;
                    maxPixel_next <= maxPixel;
                    minPixel_next <= minPixel;
                    colonne_next <= colonne;
                    righe_next <= righe;
                    numPixel_next <= numPixel;
                    deltaValue_next <= deltaValue;
                    shiftLevel_next <= shiftLevel;
                when DONE =>
                    o_done <= '1';
                    if(i_start = '0') then
                        o_done<= '0';
                        nextAddress <= std_logic_vector(TO_UNSIGNED(numPixel-1, 16)) +  currentAddress;   
                        o_address <= std_logic_vector(TO_UNSIGNED(numPixel-1, 16)) +  currentAddress;   
                        nextState <= IDLE;   
                    else 
                        o_address <= currentAddress;
                        nextAddress <= currentAddress;
                        nextState <= DONE;
                    end if;
                    o_en <= '0';
                    o_we <= '0';
                    o_data <= "00000000";
                    maxPixel_next <= 0;
                    minPixel_next <= 255;
                    colonne_next <= 0;
                    righe_next <= 0;
                    numPixel_next <= 0;
                    deltaValue_next <= 0;
                    shiftLevel_next <= 0;
                    datoSalvato := TO_UNSIGNED(0, 16);
        end case;                        
    end process;
end Behavioral;
