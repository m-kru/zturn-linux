library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library afbd;

library lapb;
  use lapb.apb;
  use lapb.serial_bridge.all;

library ltinyuart;
    use ltinyuart.tinyuart;


entity Top is
  port (
    ext_clk_10_i : in std_logic; -- External 10 MHz asynchronous clock

    uart_tx_o : out std_logic;
    uart_rx_i : in  std_logic;

    led_red_o   : buffer std_logic := '1';
    led_green_o : buffer std_logic := '1';
    led_blue_o  : buffer std_logic := '1';

    switches_i : in std_logic_vector(0 to 3);

    -- DDR interface
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

    -- Fixed PS IO pins
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
  constant EXT_CLK_10_FREQ : natural := 10_000_000;

  signal fclk0 : std_logic;
  signal fclk_reset0_n : std_logic;
  signal irq_f2p : std_logic_vector(15 downto 0);

  -- Master GP0 AXI
  signal m_gp0_axi_araddr  : std_logic_vector(31 downto 0);
  signal m_gp0_axi_arburst : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_arcache : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_arid    : std_logic_vector(11 downto 0);
  signal m_gp0_axi_arlen   : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_arlock  : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_arprot  : std_logic_vector( 2 downto 0);
  signal m_gp0_axi_arqos   : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_arready : std_logic;
  signal m_gp0_axi_arsize  : std_logic_vector( 2 downto 0);
  signal m_gp0_axi_arvalid : std_logic;
  signal m_gp0_axi_awaddr  : std_logic_vector(31 downto 0);
  signal m_gp0_axi_awburst : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_awcache : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_awid    : std_logic_vector(11 downto 0);
  signal m_gp0_axi_awlen   : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_awlock  : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_awprot  : std_logic_vector( 2 downto 0);
  signal m_gp0_axi_awqos   : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_awready : std_logic;
  signal m_gp0_axi_awsize  : std_logic_vector( 2 downto 0);
  signal m_gp0_axi_awvalid : std_logic;
  signal m_gp0_axi_bid     : std_logic_vector(11 downto 0);
  signal m_gp0_axi_bready  : std_logic;
  signal m_gp0_axi_bresp   : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_bvalid  : std_logic;
  signal m_gp0_axi_rdata   : std_logic_vector(31 downto 0);
  signal m_gp0_axi_rid     : std_logic_vector(11 downto 0);
  signal m_gp0_axi_rlast   : std_logic;
  signal m_gp0_axi_rready  : std_logic;
  signal m_gp0_axi_rresp   : std_logic_vector( 1 downto 0);
  signal m_gp0_axi_rvalid  : std_logic;
  signal m_gp0_axi_wdata   : std_logic_vector(31 downto 0);
  signal m_gp0_axi_wid     : std_logic_vector(11 downto 0);
  signal m_gp0_axi_wlast   : std_logic;
  signal m_gp0_axi_wready  : std_logic;
  signal m_gp0_axi_wstrb   : std_logic_vector( 3 downto 0);
  signal m_gp0_axi_wvalid  : std_logic;

  -- Master GP0 AXI Lite
  signal m_gp0_axil_awaddr  : std_logic_vector(31 downto 0);
  signal m_gp0_axil_awprot  : std_logic_vector( 2 downto 0);
  signal m_gp0_axil_awvalid : std_logic;
  signal m_gp0_axil_awready : std_logic;
  signal m_gp0_axil_wdata   : std_logic_vector(31 downto 0);
  signal m_gp0_axil_wstrb   : std_logic_vector( 3 downto 0);
  signal m_gp0_axil_wvalid  : std_logic;
  signal m_gp0_axil_wready  : std_logic;
  signal m_gp0_axil_bresp   : std_logic_vector(1 downto 0);
  signal m_gp0_axil_bvalid  : std_logic;
  signal m_gp0_axil_bready  : std_logic;
  signal m_gp0_axil_araddr  : std_logic_vector(31 downto 0);
  signal m_gp0_axil_arprot  : std_logic_vector( 2 downto 0);
  signal m_gp0_axil_arvalid : std_logic;
  signal m_gp0_axil_arready : std_logic;
  signal m_gp0_axil_rdata   : std_logic_vector(31 downto 0);
  signal m_gp0_axil_rresp   : std_logic_vector( 1 downto 0);
  signal m_gp0_axil_rvalid  : std_logic;
  signal m_gp0_axil_rready  : std_logic;

  --
  -- Master GP0 APB
  --

  signal m_gp0_apb_req : apb.requester_out_t;
  signal m_gp0_apb_com : apb.completer_out_t;

  signal gpio_apb_req : apb.requester_out_t;
  signal gpio_apb_com : apb.completer_out_t;

  signal timer_apb_req : apb.requester_out_t;
  signal timer_apb_com : apb.completer_out_t;

  signal apb_test_apb_req : apb.requester_out_t;
  signal apb_test_apb_com : apb.completer_out_t;

  --
  -- Timer
  --

  type timer_state_t is (DISABLED, ENABLED);
  signal timer_state : timer_state_t := DISABLED;

  signal timer_counter : unsigned(31 downto 0);
  signal timer_period  : unsigned(31 downto 0);
  signal timer_irq : std_logic;

  signal afbd_timer_start : afbd.timer_pkg.start_out_t;
  signal afbd_timer_stop  : afbd.timer_pkg.stop_out_t;

  --
  -- UART
  --

  constant UART_BAUDRATE : positive := 115_200;
  constant UART_CYCLES_PER_BAUD : positive := EXT_CLK_10_FREQ / UART_BAUDRATE;

  signal uart_tx : tinyuart.transmitter_t := tinyuart.init(UART_CYCLES_PER_BAUD);
  signal uart_rx : tinyuart.receiver_t    := tinyuart.init(UART_CYCLES_PER_BAUD);


  -- APB Serial Bridge
  signal serial_bridge : serial_bridge_t := init(ADDR_BYTE_COUNT => 1);
  signal serial_bridge_apb_com : apb.completer_out_t;

  -- APB CDC Bridge
  signal apb_cdc_bridge_apb_req : apb.requester_out_t;
  signal apb_cdc_bridge_apb_com : apb.completer_out_t;

begin

  -- Interrupts mapping
  irq_f2p(15) <= timer_irq;


  heartbeat_fclk0 : process (fclk0)
    constant CNT_MAX : natural := FCLK0_FREQ / 2;
    variable cnt : natural range 0 to CNT_MAX;
  begin
    if rising_edge(fclk0) then
      if cnt = 0 then
        led_green_o <= not led_green_o;
        cnt := CNT_MAX;
      else
        cnt := cnt - 1;
      end if;
    end if;
  end process;


  timer : process (fclk0)
  begin
    if rising_edge(fclk0) then
      timer_irq <= '0';

      case timer_state is
      when DISABLED =>
        if afbd_timer_start.call = '1' then
          timer_counter <= unsigned(afbd_timer_start.period);
          timer_period  <= unsigned(afbd_timer_start.period);
          timer_state   <= ENABLED;
        end if;
      when ENABLED =>
        if timer_counter = 0 then
          timer_counter <= timer_period;
          timer_irq <= '1';
        else
          timer_counter <= timer_counter - 1;
        end if;

        if afbd_timer_stop.call = '1' then
          timer_state <= DISABLED;
        end if;
      end case;
    end if;
  end process timer;


  uart : process (ext_clk_10_i) is
  begin
    if rising_edge(ext_clk_10_i) then
      uart_tx <= tinyuart.clock(uart_tx, serial_bridge.obyte, serial_bridge.obyte_valid);
      uart_rx <= tinyuart.clock(uart_rx, uart_rx_i, serial_bridge.ibyte_ready);
    end if;
  end process;
  uart_tx_o <= uart_tx.tx;


  apb_serial_bridge : process (ext_clk_10_i) is
  begin
    if rising_edge(ext_clk_10_i) then
      serial_bridge <= clock(
        serial_bridge,
        uart_rx.obyte, uart_rx.obyte_valid,
        uart_tx.ibyte_ready,
        serial_bridge_apb_com
      );
    end if;
  end process;


  apb_cdc_bridge : entity lapb.APB_CDC_Bridge
  port map (
    com_arstn_i => '1',
    com_clk_i   => ext_clk_10_i,
    com_i       => serial_bridge.apb_req,
    com_o       => serial_bridge_apb_com,

    req_arstn_i => '1',
    req_clk_i   => fclk0,
    req_i       => apb_cdc_bridge_apb_com,
    req_o       => apb_cdc_bridge_apb_req
  );


  afbd_main : entity afbd.main
  port map (
    clk_i => fclk0,
    rst_i => '0',

    apb_coms_i(0) => m_gp0_apb_req,
    apb_coms_o(0) => m_gp0_apb_com,
    gpio_apb_reqs_o(0) => gpio_apb_req,
    gpio_apb_reqs_i(0) => gpio_apb_com,
    timer_apb_reqs_o(0) => timer_apb_req,
    timer_apb_reqs_i(0) => timer_apb_com,
    apb_test_apb_reqs_o(0) => apb_test_apb_req,
    apb_test_apb_reqs_i(0) => apb_test_apb_com,

    write_read_test_o => open,
    led_red_o(0)      => led_red_o
  );


  afbd_gpio : entity afbd.gpio
  port map (
    clk_i => fclk0,
    rst_i => '0',

    apb_coms_i(0) => gpio_apb_req,
    apb_coms_o(0) => gpio_apb_com,

    leds_o(0)  => led_blue_o,
    switches_i => switches_i
  );


  afbd_timer : entity afbd.timer
  port map (
    clk_i => fclk0,
    rst_i => '0',

    apb_coms_i(0) => timer_apb_req,
    apb_coms_o(0) => timer_apb_com,

    start_o   => afbd_timer_start,
    stop_o    => afbd_timer_stop,
    counter_i => std_logic_vector(timer_counter)
  );


  afbd_test : entity afbd.apb_test
  port map (
    clk_i => fclk0,
    rst_i => '0',

    apb_coms_i(0) => apb_test_apb_req,
    apb_coms_i(1) => apb_cdc_bridge_apb_req,

    apb_coms_o(0) => apb_test_apb_com,
    apb_coms_o(1) => apb_cdc_bridge_apb_com
  );


  m_gp0_axilite_apb3_bridge : entity work.m_gp0_axilite_apb3_bridge
  port map (
    -- AXI port
    s_axi_aclk    => fclk0,
    s_axi_aresetn => fclk_reset0_n,
    s_axi_awaddr  => m_gp0_axil_awaddr,
    s_axi_awvalid => m_gp0_axil_awvalid,
    s_axi_awready => m_gp0_axil_awready,
    s_axi_wdata   => m_gp0_axil_wdata,
    s_axi_wvalid  => m_gp0_axil_wvalid,
    s_axi_wready  => m_gp0_axil_wready,
    s_axi_bresp   => m_gp0_axil_bresp,
    s_axi_bvalid  => m_gp0_axil_bvalid,
    s_axi_bready  => m_gp0_axil_bready,
    s_axi_araddr  => m_gp0_axil_araddr,
    s_axi_arvalid => m_gp0_axil_arvalid,
    s_axi_arready => m_gp0_axil_arready,
    s_axi_rdata   => m_gp0_axil_rdata,
    s_axi_rresp   => m_gp0_axil_rresp,
    s_axi_rvalid  => m_gp0_axil_rvalid,
    s_axi_rready  => m_gp0_axil_rready,
    -- APB port
    unsigned(m_apb_paddr) => m_gp0_apb_req.addr,
    m_apb_psel(0)         => m_gp0_apb_req.selx,
    m_apb_penable         => m_gp0_apb_req.enable,
    m_apb_pwrite          => m_gp0_apb_req.write,
    m_apb_pwdata          => m_gp0_apb_req.wdata,
    m_apb_pready(0)       => m_gp0_apb_com.ready,
    m_apb_prdata          => m_gp0_apb_com.rdata,
    m_apb_pslverr(0)      => m_gp0_apb_com.slverr
  );


  m_gp0_axi_axilite_bridge : entity work.m_gp0_axi_axilite_bridge
  port map (
    aclk    => fclk0,
    aresetn => fclk_reset0_n,
    -- AXI port
    s_axi_awid     => m_gp0_axi_awid,
    s_axi_awaddr   => m_gp0_axi_awaddr,
    s_axi_awlen    => m_gp0_axi_awlen,
    s_axi_awsize   => m_gp0_axi_awsize,
    s_axi_awburst  => m_gp0_axi_awburst,
    s_axi_awlock   => m_gp0_axi_awlock,
    s_axi_awcache  => m_gp0_axi_awcache,
    s_axi_awprot   => m_gp0_axi_awprot,
    s_axi_awqos    => m_gp0_axi_awqos,
    s_axi_awvalid  => m_gp0_axi_awvalid,
    s_axi_awready  => m_gp0_axi_awready,
    s_axi_wid      => m_gp0_axi_wid,
    s_axi_wdata    => m_gp0_axi_wdata,
    s_axi_wstrb    => m_gp0_axi_wstrb,
    s_axi_wlast    => m_gp0_axi_wlast,
    s_axi_wvalid   => m_gp0_axi_wvalid,
    s_axi_wready   => m_gp0_axi_wready,
    s_axi_bid      => m_gp0_axi_bid,
    s_axi_bresp    => m_gp0_axi_bresp,
    s_axi_bvalid   => m_gp0_axi_bvalid,
    s_axi_bready   => m_gp0_axi_bready,
    s_axi_arid     => m_gp0_axi_arid,
    s_axi_araddr   => m_gp0_axi_araddr,
    s_axi_arlen    => m_gp0_axi_arlen,
    s_axi_arsize   => m_gp0_axi_arsize,
    s_axi_arburst  => m_gp0_axi_arburst,
    s_axi_arlock   => m_gp0_axi_arlock,
    s_axi_arcache  => m_gp0_axi_arcache,
    s_axi_arprot   => m_gp0_axi_arprot,
    s_axi_arqos    => m_gp0_axi_arqos,
    s_axi_arvalid  => m_gp0_axi_arvalid,
    s_axi_arready  => m_gp0_axi_arready,
    s_axi_rid      => m_gp0_axi_rid,
    s_axi_rdata    => m_gp0_axi_rdata,
    s_axi_rresp    => m_gp0_axi_rresp,
    s_axi_rlast    => m_gp0_axi_rlast,
    s_axi_rvalid   => m_gp0_axi_rvalid,
    s_axi_rready   => m_gp0_axi_rready,
    -- AXI Lite port
    m_axi_awaddr  => m_gp0_axil_awaddr,
    m_axi_awprot  => m_gp0_axil_awprot,
    m_axi_awvalid => m_gp0_axil_awvalid,
    m_axi_awready => m_gp0_axil_awready,
    m_axi_wdata   => m_gp0_axil_wdata,
    m_axi_wstrb   => m_gp0_axil_wstrb,
    m_axi_wvalid  => m_gp0_axil_wvalid,
    m_axi_wready  => m_gp0_axil_wready,
    m_axi_bresp   => m_gp0_axil_bresp,
    m_axi_bvalid  => m_gp0_axil_bvalid,
    m_axi_bready  => m_gp0_axil_bready,
    m_axi_araddr  => m_gp0_axil_araddr,
    m_axi_arprot  => m_gp0_axil_arprot,
    m_axi_arvalid => m_gp0_axil_arvalid,
    m_axi_arready => m_gp0_axil_arready,
    m_axi_rdata   => m_gp0_axil_rdata,
    m_axi_rresp   => m_gp0_axil_rresp,
    m_axi_rvalid  => m_gp0_axil_rvalid,
    m_axi_rready  => m_gp0_axil_rready
  );


  processing_system : entity work.processing_system_wrapper
  port map (
    FCLK_CLK0 => fclk0,
    FCLK_RESET0_N => fclk_reset0_n,
    IRQ_F2P => irq_f2p,

    DDR_addr    => DDR_addr,
    DDR_ba      => DDR_ba,
    DDR_cas_n   => DDR_cas_n,
    DDR_ck_n    => DDR_ck_n,
    DDR_ck_p    => DDR_ck_p,
    DDR_cke     => DDR_cke,
    DDR_cs_n    => DDR_cs_n,
    DDR_dm      => DDR_dm,
    DDR_dq      => DDR_dq,
    DDR_dqs_n   => DDR_dqs_n,
    DDR_dqs_p   => DDR_dqs_p,
    DDR_odt     => DDR_odt,
    DDR_ras_n   => DDR_ras_n,
    DDR_reset_n => DDR_reset_n,
    DDR_we_n    => DDR_we_n,

    FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
    FIXED_IO_mio      => FIXED_IO_mio,
    FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,

    M_AXI_GP0_ACLK    => fclk0,
    M_AXI_GP0_araddr  => m_gp0_axi_araddr,
    M_AXI_GP0_arburst => m_gp0_axi_arburst,
    M_AXI_GP0_arcache => m_gp0_axi_arcache,
    M_AXI_GP0_arid    => m_gp0_axi_arid,
    M_AXI_GP0_arlen   => m_gp0_axi_arlen,
    M_AXI_GP0_arlock  => m_gp0_axi_arlock,
    M_AXI_GP0_arprot  => m_gp0_axi_arprot,
    M_AXI_GP0_arqos   => m_gp0_axi_arqos,
    M_AXI_GP0_arready => m_gp0_axi_arready,
    M_AXI_GP0_arsize  => m_gp0_axi_arsize,
    M_AXI_GP0_arvalid => m_gp0_axi_arvalid,
    M_AXI_GP0_awaddr  => m_gp0_axi_awaddr,
    M_AXI_GP0_awburst => m_gp0_axi_awburst,
    M_AXI_GP0_awcache => m_gp0_axi_awcache,
    M_AXI_GP0_awid    => m_gp0_axi_awid,
    M_AXI_GP0_awlen   => m_gp0_axi_awlen,
    M_AXI_GP0_awlock  => m_gp0_axi_awlock,
    M_AXI_GP0_awprot  => m_gp0_axi_awprot,
    M_AXI_GP0_awqos   => m_gp0_axi_awqos,
    M_AXI_GP0_awready => m_gp0_axi_awready,
    M_AXI_GP0_awsize  => m_gp0_axi_awsize,
    M_AXI_GP0_awvalid => m_gp0_axi_awvalid,
    M_AXI_GP0_bid     => m_gp0_axi_bid,
    M_AXI_GP0_bready  => m_gp0_axi_bready,
    M_AXI_GP0_bresp   => m_gp0_axi_bresp,
    M_AXI_GP0_bvalid  => m_gp0_axi_bvalid,
    M_AXI_GP0_rdata   => m_gp0_axi_rdata,
    M_AXI_GP0_rid     => m_gp0_axi_rid,
    M_AXI_GP0_rlast   => m_gp0_axi_rlast,
    M_AXI_GP0_rready  => m_gp0_axi_rready,
    M_AXI_GP0_rresp   => m_gp0_axi_rresp,
    M_AXI_GP0_rvalid  => m_gp0_axi_rvalid,
    M_AXI_GP0_wdata   => m_gp0_axi_wdata,
    M_AXI_GP0_wid     => m_gp0_axi_wid,
    M_AXI_GP0_wlast   => m_gp0_axi_wlast,
    M_AXI_GP0_wready  => m_gp0_axi_wready,
    M_AXI_GP0_wstrb   => m_gp0_axi_wstrb,
    M_AXI_GP0_wvalid  => m_gp0_axi_wvalid
  );

end architecture;