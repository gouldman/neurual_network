library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- ST_SPHDL_160x32_mem2011 (words = 160, bits = 32)
entity sram_wrapper is
    port(
        clk: in std_logic;
        cs_n: in std_logic;  -- Active Low
        we_n: in std_logic;  --Active Low
        address: in std_logic_vector(7 downto 0);
        ry: out std_logic;
        write_data: in std_logic_vector(31 downto 0);
        read_data: out std_logic_vector(31 downto 0)
    );
end sram_wrapper;


architecture rtl of sram_wrapper is

    component ST_SPHDL_160x32m8_L
        port (
            Q: out std_logic_vector(31 downto 0);
            RY: out std_logic;
            CK: in std_logic;
            CSN: in std_logic;
            TBYPASS: in std_logic;
            WEN: in std_logic;
            A: in std_logic_vector(7 downto 0);
            D: in std_logic_vector(31 downto 0)
    );
    end component;

    constant LOW: std_logic := '0';

begin

    DUT_ST_SPHDL_160x32_mem2011: ST_SPHDL_160x32m8_L port map(
        Q => read_data,
        RY => ry,
        CK => clk,
        CSN => cs_n,
        TBYPASS => LOW,
        WEN => we_n,
        A => address,
        D => write_data
    );

end rtl;

