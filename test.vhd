library ieee;
use iee.std_logic_1164.all;


entity test is 
  port(input : in std_logic_vector(7 downto 0);
        clk,clear,sr,sl,s0,s1 : in std_logic;
       output : out std_logic_vector(7 downto 0));
end entity;

architecture arch of test is 
  signal mode : std_logic_vector(1 downto 0);
  
begin   
  mode <= s1&s0;
  process(clk,mode)
  begin
    if(clear='0') then output <="00000000";
    else 
      if(clk'event and clk='1')then
        case mode is 
          when "01" => output <= (sr& input(6 downto 0); 
          when "10" => output <= (input(7 downto 1) & sl);
          when "11" => output <= input;
        end case;
      end if;
    end if;
  end process;

end arch;
