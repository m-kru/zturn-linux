library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library lapb;
  use lapb.apb;


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

  -- General purpose AXI Master 0
  signal M_AXI_GP0_araddr  :  STD_LOGIC_VECTOR ( 31 downto 0 );
  signal M_AXI_GP0_arburst :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_arcache :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_arid    :  STD_LOGIC_VECTOR ( 11 downto 0 );
  signal M_AXI_GP0_arlen   :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_arlock  :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_arprot  :  STD_LOGIC_VECTOR ( 2 downto 0 );
  signal M_AXI_GP0_arqos   :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_arready :  STD_LOGIC;
  signal M_AXI_GP0_arsize  :  STD_LOGIC_VECTOR ( 2 downto 0 );
  signal M_AXI_GP0_arvalid :  STD_LOGIC;
  signal M_AXI_GP0_awaddr  :  STD_LOGIC_VECTOR ( 31 downto 0 );
  signal M_AXI_GP0_awburst :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_awcache :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_awid    :  STD_LOGIC_VECTOR ( 11 downto 0 );
  signal M_AXI_GP0_awlen   :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_awlock  :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_awprot  :  STD_LOGIC_VECTOR ( 2 downto 0 );
  signal M_AXI_GP0_awqos   :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_awready :  STD_LOGIC;
  signal M_AXI_GP0_awsize  :  STD_LOGIC_VECTOR ( 2 downto 0 );
  signal M_AXI_GP0_awvalid :  STD_LOGIC;
  signal M_AXI_GP0_bid     :  STD_LOGIC_VECTOR ( 11 downto 0 );
  signal M_AXI_GP0_bready  :  STD_LOGIC;
  signal M_AXI_GP0_bresp   :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_bvalid  :  STD_LOGIC;
  signal M_AXI_GP0_rdata   :  STD_LOGIC_VECTOR ( 31 downto 0 );
  signal M_AXI_GP0_rid     :  STD_LOGIC_VECTOR ( 11 downto 0 );
  signal M_AXI_GP0_rlast   :  STD_LOGIC;
  signal M_AXI_GP0_rready  :  STD_LOGIC;
  signal M_AXI_GP0_rresp   :  STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M_AXI_GP0_rvalid  :  STD_LOGIC;
  signal M_AXI_GP0_wdata   :  STD_LOGIC_VECTOR ( 31 downto 0 );
  signal M_AXI_GP0_wid     :  STD_LOGIC_VECTOR ( 11 downto 0 );
  signal M_AXI_GP0_wlast   :  STD_LOGIC;
  signal M_AXI_GP0_wready  :  STD_LOGIC;
  signal M_AXI_GP0_wstrb   :  STD_LOGIC_VECTOR ( 3 downto 0 );
  signal M_AXI_GP0_wvalid  :  STD_LOGIC;

  -- AXI Lite GP0
  signal m_axilite_gp0_awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m_axilite_gp0_awprot : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m_axilite_gp0_awvalid : STD_LOGIC;
  signal m_axilite_gp0_awready : STD_LOGIC;
  signal m_axilite_gp0_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m_axilite_gp0_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m_axilite_gp0_wvalid : STD_LOGIC;
  signal m_axilite_gp0_wready : STD_LOGIC;
  signal m_axilite_gp0_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal m_axilite_gp0_bvalid : STD_LOGIC;
  signal m_axilite_gp0_bready : STD_LOGIC;
  signal m_axilite_gp0_araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m_axilite_gp0_arprot : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m_axilite_gp0_arvalid : STD_LOGIC;
  signal m_axilite_gp0_arready : STD_LOGIC;
  signal m_axilite_gp0_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m_axilite_gp0_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal m_axilite_gp0_rvalid : STD_LOGIC;
  signal m_axilite_gp0_rready : STD_LOGIC;

  -- APB GP0
  signal m_apb_paddr : std_logic_vector(31 downto 0);
  signal apb_gp0_req : apb.requester_out_t;
  signal apb_gp0_com : apb.completer_out_t;

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


  axi_gp0_apb_bridge : entity work.axi_gp0_apb_bridge
  port map (
    -- AXI port
    s_axi_aclk    => fclk0,
    s_axi_aresetn => '1',
    s_axi_awaddr  => m_axilite_gp0_awaddr,
    s_axi_awvalid => m_axilite_gp0_awvalid,
    s_axi_awready => m_axilite_gp0_awready,
    s_axi_wdata   => m_axilite_gp0_wdata,
    s_axi_wvalid  => m_axilite_gp0_wvalid,
    s_axi_wready  => m_axilite_gp0_wready,
    s_axi_bresp   => m_axilite_gp0_bresp,
    s_axi_bvalid  => m_axilite_gp0_bvalid,
    s_axi_bready  => m_axilite_gp0_bready,
    s_axi_araddr  => m_axilite_gp0_araddr,
    s_axi_arvalid => m_axilite_gp0_arvalid,
    s_axi_arready => m_axilite_gp0_arready,
    s_axi_rdata   => m_axilite_gp0_rdata,
    s_axi_rresp   => m_axilite_gp0_rresp,
    s_axi_rvalid  => m_axilite_gp0_rvalid,
    s_axi_rready  => m_axilite_gp0_rready,
    -- APB port
    m_apb_paddr      => m_apb_paddr,
    m_apb_psel(0)    => apb_gp0_req.selx,
    m_apb_penable    => apb_gp0_req.enable,
    m_apb_pwrite     => apb_gp0_req.write,
    m_apb_pwdata     => apb_gp0_req.wdata,
    m_apb_pready(0)  => apb_gp0_com.ready,
    m_apb_prdata     => apb_gp0_com.rdata,
    m_apb_pslverr(0) => apb_gp0_com.slverr
  );
  apb_gp0_req.addr <= unsigned(m_apb_paddr);


  axi_axilite_bridge : entity work.axi_protocol_converter_0
  port map (
    aclk    => fclk0,
    aresetn => '1',
    -- AXI port
    s_axi_awaddr   => M_AXI_GP0_awaddr,
    s_axi_awlen    => M_AXI_GP0_awlen,
    s_axi_awsize   => M_AXI_GP0_awsize,
    s_axi_awburst  => M_AXI_GP0_awburst,
    s_axi_awlock   => M_AXI_GP0_awlock,
    s_axi_awcache  => M_AXI_GP0_awcache,
    s_axi_awprot   => M_AXI_GP0_awprot,
    s_axi_awqos    => M_AXI_GP0_awqos,
    s_axi_awvalid  => M_AXI_GP0_awvalid,
    s_axi_awready  => M_AXI_GP0_awready,
    s_axi_wdata    => M_AXI_GP0_wdata,
    s_axi_wstrb    => M_AXI_GP0_wstrb,
    s_axi_wlast    => M_AXI_GP0_wlast,
    s_axi_wvalid   => M_AXI_GP0_wvalid,
    s_axi_wready   => M_AXI_GP0_wready,
    s_axi_bresp    => M_AXI_GP0_bresp,
    s_axi_bvalid   => M_AXI_GP0_bvalid,
    s_axi_bready   => M_AXI_GP0_bready,
    s_axi_araddr   => M_AXI_GP0_araddr,
    s_axi_arlen    => M_AXI_GP0_arlen,
    s_axi_arsize   => M_AXI_GP0_arsize,
    s_axi_arburst  => M_AXI_GP0_arburst,
    s_axi_arlock   => M_AXI_GP0_arlock,
    s_axi_arcache  => M_AXI_GP0_arcache,
    s_axi_arprot   => M_AXI_GP0_arprot,
    s_axi_arqos    => M_AXI_GP0_arqos,
    s_axi_arvalid  => M_AXI_GP0_arvalid,
    s_axi_arready  => M_AXI_GP0_arready,
    s_axi_rdata    => M_AXI_GP0_rdata,
    s_axi_rresp    => M_AXI_GP0_rresp,
    s_axi_rlast    => M_AXI_GP0_rlast,
    s_axi_rvalid   => M_AXI_GP0_rvalid,
    s_axi_rready   => M_AXI_GP0_rready,
    -- AXI Lite port
    m_axi_awaddr  => m_axilite_gp0_awaddr,
    m_axi_awprot  => m_axilite_gp0_awprot,
    m_axi_awvalid => m_axilite_gp0_awvalid,
    m_axi_awready => m_axilite_gp0_awready,
    m_axi_wdata   => m_axilite_gp0_wdata,
    m_axi_wstrb   => m_axilite_gp0_wstrb,
    m_axi_wvalid  => m_axilite_gp0_wvalid,
    m_axi_wready  => m_axilite_gp0_wready,
    m_axi_bresp   => m_axilite_gp0_bresp,
    m_axi_bvalid  => m_axilite_gp0_bvalid,
    m_axi_bready  => m_axilite_gp0_bready,
    m_axi_araddr  => m_axilite_gp0_araddr,
    m_axi_arprot  => m_axilite_gp0_arprot,
    m_axi_arvalid => m_axilite_gp0_arvalid,
    m_axi_arready => m_axilite_gp0_arready,
    m_axi_rdata   => m_axilite_gp0_rdata,
    m_axi_rresp   => m_axilite_gp0_rresp,
    m_axi_rvalid  => m_axilite_gp0_rvalid,
    m_axi_rready  => m_axilite_gp0_rready
  );


  processing_system : entity work.processing_system_wrapper
  port map (
    FCLK_CLK0 => fclk0,
    FCLK_RESET0_N => open,

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
    M_AXI_GP0_araddr  => M_AXI_GP0_araddr,
    M_AXI_GP0_arburst => M_AXI_GP0_arburst,
    M_AXI_GP0_arcache => M_AXI_GP0_arcache,
    M_AXI_GP0_arid    => M_AXI_GP0_arid,
    M_AXI_GP0_arlen   => M_AXI_GP0_arlen,
    M_AXI_GP0_arlock  => M_AXI_GP0_arlock,
    M_AXI_GP0_arprot  => M_AXI_GP0_arprot,
    M_AXI_GP0_arqos   => M_AXI_GP0_arqos,
    M_AXI_GP0_arready => M_AXI_GP0_arready,
    M_AXI_GP0_arsize  => M_AXI_GP0_arsize,
    M_AXI_GP0_arvalid => M_AXI_GP0_arvalid,
    M_AXI_GP0_awaddr  => M_AXI_GP0_awaddr,
    M_AXI_GP0_awburst => M_AXI_GP0_awburst,
    M_AXI_GP0_awcache => M_AXI_GP0_awcache,
    M_AXI_GP0_awid    => M_AXI_GP0_awid,
    M_AXI_GP0_awlen   => M_AXI_GP0_awlen,
    M_AXI_GP0_awlock  => M_AXI_GP0_awlock,
    M_AXI_GP0_awprot  => M_AXI_GP0_awprot,
    M_AXI_GP0_awqos   => M_AXI_GP0_awqos,
    M_AXI_GP0_awready => M_AXI_GP0_awready,
    M_AXI_GP0_awsize  => M_AXI_GP0_awsize,
    M_AXI_GP0_awvalid => M_AXI_GP0_awvalid,
    M_AXI_GP0_bid     => M_AXI_GP0_bid,
    M_AXI_GP0_bready  => M_AXI_GP0_bready,
    M_AXI_GP0_bresp   => M_AXI_GP0_bresp,
    M_AXI_GP0_bvalid  => M_AXI_GP0_bvalid,
    M_AXI_GP0_rdata   => M_AXI_GP0_rdata,
    M_AXI_GP0_rid     => M_AXI_GP0_rid,
    M_AXI_GP0_rlast   => M_AXI_GP0_rlast,
    M_AXI_GP0_rready  => M_AXI_GP0_rready,
    M_AXI_GP0_rresp   => M_AXI_GP0_rresp,
    M_AXI_GP0_rvalid  => M_AXI_GP0_rvalid,
    M_AXI_GP0_wdata   => M_AXI_GP0_wdata,
    M_AXI_GP0_wid     => M_AXI_GP0_wid,
    M_AXI_GP0_wlast   => M_AXI_GP0_wlast,
    M_AXI_GP0_wready  => M_AXI_GP0_wready,
    M_AXI_GP0_wstrb   => M_AXI_GP0_wstrb,
    M_AXI_GP0_wvalid  => M_AXI_GP0_wvalid
  );

end architecture;