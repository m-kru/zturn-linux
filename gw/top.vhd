library ieee;
  use ieee.std_logic_1164.all;


entity Top is
  port (
    led_red_o   : buffer std_logic := '1';
    led_green_o : buffer std_logic := '1';
    led_blue_o  : buffer std_logic := '1';

    -- Fixed PS IO pins
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC
  );
end entity;


architecture Main of Top is

  constant FCLK0_FREQ : natural := 50_000_000;

  signal fclk0 : std_logic;

begin

  Heartbeat_FCLK0 : process (fclk0)
    constant CNT_MAX : natural := FCLK0_FREQ / 2;
    variable cnt : natural range 0 to CNT_MAX;
  begin
    if rising_edge(fclk0) then
      if cnt = 0 then
        led_red_o <= not led_red_o;
        cnt := CNT_MAX;
      else
        cnt := cnt - 1;
      end if;
    end if;
  end process;


  processing_system : entity work.processing_system_wrapper
  port map (
    FCLK_CLK0 => fclk0,
    FCLK_RESET0_N => open,
    DDR_addr => DDR_addr,
    DDR_ba => DDR_ba,
    DDR_cas_n => DDR_cas_n,
    DDR_ck_n => DDR_ck_n,
    DDR_ck_p => DDR_ck_p,
    DDR_cke => DDR_cke,
    DDR_cs_n => DDR_cs_n,
    DDR_dm => DDR_dm,
    DDR_dq => DDR_dq,
    DDR_dqs_n => DDR_dqs_n,
    DDR_dqs_p => DDR_dqs_p,
    DDR_odt => DDR_odt,
    DDR_ras_n => DDR_ras_n,
    DDR_reset_n => DDR_reset_n,
    DDR_we_n => DDR_we_n,
    FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
    FIXED_IO_mio => FIXED_IO_mio,
    FIXED_IO_ps_clk => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb
  );

end architecture;