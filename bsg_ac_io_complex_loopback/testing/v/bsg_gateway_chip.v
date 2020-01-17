`timescale 1ps/1ps

`ifndef IO_MASTER_CLK_PERIOD
  `define IO_MASTER_CLK_PERIOD 10000.0
`endif

`ifndef ROUTER_CLK_PERIOD
  `define ROUTER_CLK_PERIOD 10000.0
`endif

`ifndef TAG_CLK_PERIOD
  `define TAG_CLK_PERIOD 10000.0
`endif

module bsg_gateway_chip

import bsg_tag_pkg::*;
import bsg_chip_pkg::*;

`include "bsg_pinout_inverted.v"

  //////////////////////////////////////////////////
  //
  // Waveform Dump
  //

  initial
    begin
      $vcdpluson;
      $vcdplusmemon;
      $vcdplusautoflushon;
    end

  //////////////////////////////////////////////////
  //
  // Nonsynth Clock Generator(s)
  //

  logic io_master_clk;
  assign p_clk_B_o = io_master_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`IO_MASTER_CLK_PERIOD)) io_master_clk_gen (.o(io_master_clk));

  logic router_clk;
  assign p_clk_C_o = router_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`ROUTER_CLK_PERIOD)) router_clk_gen (.o(router_clk));

  logic tag_clk;
  assign p_bsg_tag_clk_o = tag_clk;
  bsg_nonsynth_clock_gen #(.cycle_time_p(`TAG_CLK_PERIOD)) tag_clk_gen (.o(tag_clk));

  //////////////////////////////////////////////////
  //
  // Nonsynth Reset Generator(s)
  //

  logic tag_reset;
  bsg_nonsynth_reset_gen #(.num_clocks_p(1),.reset_cycles_lo_p(10),.reset_cycles_hi_p(5))
    tag_reset_gen
      (.clk_i(tag_clk)
      ,.async_reset_o(tag_reset)
      );

  //////////////////////////////////////////////////
  //
  // BSG Tag Track Replay
  //

  localparam tag_trace_rom_addr_width_lp = 32;
  localparam tag_trace_rom_data_width_lp = 18;

  logic [tag_trace_rom_addr_width_lp-1:0] rom_addr_li;
  logic [tag_trace_rom_data_width_lp-1:0] rom_data_lo;

  logic [1:0] tag_trace_en_r_lo;
  logic       tag_trace_done_lo;

  // TAG TRACE ROM
  bsg_tag_boot_rom #(.width_p( tag_trace_rom_data_width_lp )
                    ,.addr_width_p( tag_trace_rom_addr_width_lp )
                    )
    tag_trace_rom
      (.addr_i( rom_addr_li )
      ,.data_o( rom_data_lo )
      );

  // TAG TRACE REPLAY
  bsg_tag_trace_replay #(.rom_addr_width_p( tag_trace_rom_addr_width_lp )
                        ,.rom_data_width_p( tag_trace_rom_data_width_lp )
                        ,.num_masters_p( 2 )
                        ,.num_clients_p( tag_num_clients_gp )
                        ,.max_payload_width_p( tag_max_payload_width_gp )
                        )
    tag_trace_replay
      (.clk_i   ( p_bsg_tag_clk_o )
      ,.reset_i ( tag_reset    )
      ,.en_i    ( 1'b1            )

      ,.rom_addr_o( rom_addr_li )
      ,.rom_data_i( rom_data_lo )

      ,.valid_i ( 1'b0 )
      ,.data_i  ( '0 )
      ,.ready_o ()

      ,.valid_o    ()
      ,.en_r_o     ( tag_trace_en_r_lo )
      ,.tag_data_o ( p_bsg_tag_data_o )
      ,.yumi_i     ( 1'b1 )

      ,.done_o  ( tag_trace_done_lo )
      ,.error_o ()
      ) ;

  assign p_bsg_tag_en_o = tag_trace_en_r_lo[0];

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // Rename the tag lines (copy from bsg_chip.v)
  wire bsg_tag_s prev_link_io_tag_lines_lo   = tag_lines_lo[0];
  wire bsg_tag_s prev_link_core_tag_lines_lo = tag_lines_lo[1];
  wire bsg_tag_s prev_ct_core_tag_lines_lo   = tag_lines_lo[2];
  wire bsg_tag_s next_link_io_tag_lines_lo   = tag_lines_lo[3];
  wire bsg_tag_s next_link_core_tag_lines_lo = tag_lines_lo[4];
  wire bsg_tag_s next_ct_core_tag_lines_lo   = tag_lines_lo[5];
  wire bsg_tag_s router_core_tag_lines_lo    = tag_lines_lo[6];

  // BSG tag master instance
  bsg_tag_master #(.els_p( tag_num_clients_gp )
                  ,.lg_width_p( tag_lg_max_payload_width_gp )
                  )
    btm
      (.clk_i      ( p_bsg_tag_clk_o )
      ,.data_i     ( tag_trace_en_r_lo[1] ? p_bsg_tag_data_o : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // Commlink Swizzle
  //

  logic       ci_clk_li;
  logic       ci_v_li;
  logic [8:0] ci_data_li;
  logic       ci_tkn_lo;

  logic       co_clk_lo;
  logic       co_v_lo;
  logic [8:0] co_data_lo;
  logic       co_tkn_li;

  logic       ci2_clk_li;
  logic       ci2_v_li;
  logic [8:0] ci2_data_li;
  logic       ci2_tkn_lo;

  logic       co2_clk_lo;
  logic       co2_v_lo;
  logic [8:0] co2_data_lo;
  logic       co2_tkn_li;

  bsg_chip_swizzle_adapter
    swizzle
      (.port_ci_clk_i   (p_ci_clk_i)
      ,.port_ci_v_i     (p_ci_v_i)
      ,.port_ci_data_i  ({p_ci_8_i, p_ci_7_i, p_ci_6_i, p_ci_5_i, p_ci_4_i, p_ci_3_i, p_ci_2_i, p_ci_1_i, p_ci_0_i})
      ,.port_ci_tkn_o   (p_ci_tkn_o)

      ,.port_ci2_clk_o  (p_ci2_clk_o)
      ,.port_ci2_v_o    (p_ci2_v_o)
      ,.port_ci2_data_o ({p_ci2_8_o, p_ci2_7_o, p_ci2_6_o, p_ci2_5_o, p_ci2_4_o, p_ci2_3_o, p_ci2_2_o, p_ci2_1_o, p_ci2_0_o})
      ,.port_ci2_tkn_i  (p_ci2_tkn_i)

      ,.port_co_clk_i   (p_co_clk_i)
      ,.port_co_v_i     (p_co_v_i)
      ,.port_co_data_i  ({p_co_8_i, p_co_7_i, p_co_6_i, p_co_5_i, p_co_4_i, p_co_3_i, p_co_2_i, p_co_1_i, p_co_0_i})
      ,.port_co_tkn_o   (p_co_tkn_o)

      ,.port_co2_clk_o  (p_co2_clk_o)
      ,.port_co2_v_o    (p_co2_v_o)
      ,.port_co2_data_o ({p_co2_8_o, p_co2_7_o, p_co2_6_o, p_co2_5_o, p_co2_4_o, p_co2_3_o, p_co2_2_o, p_co2_1_o, p_co2_0_o})
      ,.port_co2_tkn_i  (p_co2_tkn_i)

      ,.guts_ci_clk_o  (ci_clk_li)
      ,.guts_ci_v_o    (ci_v_li)
      ,.guts_ci_data_o (ci_data_li)
      ,.guts_ci_tkn_i  (ci_tkn_lo)

      ,.guts_co_clk_i  (co_clk_lo)
      ,.guts_co_v_i    (co_v_lo)
      ,.guts_co_data_i (co_data_lo)
      ,.guts_co_tkn_o  (co_tkn_li)

      ,.guts_ci2_clk_o (ci2_clk_li)
      ,.guts_ci2_v_o   (ci2_v_li)
      ,.guts_ci2_data_o(ci2_data_li)
      ,.guts_ci2_tkn_i (ci2_tkn_lo)

      ,.guts_co2_clk_i (co2_clk_lo)
      ,.guts_co2_v_i   (co2_v_lo)
      ,.guts_co2_data_i(co2_data_lo)
      ,.guts_co2_tkn_o (co2_tkn_li)
      );

  //////////////////////////////////////////////////
  //
  // BSG Chip IO Complex
  //

  logic router_reset_lo;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_li;
  bsg_ready_and_link_sif_s [ct_num_in_gp-1:0] rtr_links_lo;

  bsg_chip_io_complex #(.num_router_groups_p( 1 )

                       ,.link_width_p( link_width_gp )
                       ,.link_channel_width_p( link_channel_width_gp )
                       ,.link_num_channels_p( link_num_channels_gp )
                       ,.link_lg_fifo_depth_p( link_lg_fifo_depth_gp )
                       ,.link_lg_credit_to_token_decimation_p( link_lg_credit_to_token_decimation_gp )

                       ,.ct_width_p( ct_width_gp )
                       ,.ct_num_in_p( ct_num_in_gp )
                       ,.ct_remote_credits_p( ct_remote_credits_gp )
                       ,.ct_use_pseudo_large_fifo_p( ct_use_pseudo_large_fifo_gp )
                       ,.ct_lg_credit_decimation_p( ct_lg_credit_decimation_gp )

                       ,.wh_cord_markers_pos_p({wh_cord_markers_pos_b_gp, wh_cord_markers_pos_a_gp})
                       ,.wh_len_width_p( wh_len_width_gp )
                       )
    io_complex
      (.core_clk_i ( router_clk )
      ,.io_clk_i   ( io_master_clk )

      ,.prev_link_io_tag_lines_i( prev_link_io_tag_lines_lo )
      ,.prev_link_core_tag_lines_i( prev_link_core_tag_lines_lo )
      ,.prev_ct_core_tag_lines_i( prev_ct_core_tag_lines_lo )
      
      ,.next_link_io_tag_lines_i( next_link_io_tag_lines_lo )
      ,.next_link_core_tag_lines_i( next_link_core_tag_lines_lo )
      ,.next_ct_core_tag_lines_i( next_ct_core_tag_lines_lo )

      ,.rtr_core_tag_lines_i( router_core_tag_lines_lo )
      
      ,.ci_clk_i  ( ci_clk_li )
      ,.ci_v_i    ( ci_v_li )
      ,.ci_data_i ( ci_data_li[link_channel_width_gp-1:0] )
      ,.ci_tkn_o  ( ci_tkn_lo )

      ,.co_clk_o  ( co_clk_lo )
      ,.co_v_o    ( co_v_lo )
      ,.co_data_o ( co_data_lo[link_channel_width_gp-1:0] )
      ,.co_tkn_i  ( co_tkn_li )

      ,.ci2_clk_i  ( ci2_clk_li )
      ,.ci2_v_i    ( ci2_v_li )
      ,.ci2_data_i ( ci2_data_li[link_channel_width_gp-1:0] )
      ,.ci2_tkn_o  ( ci2_tkn_lo )

      ,.co2_clk_o  ( co2_clk_lo )
      ,.co2_v_o    ( co2_v_lo )
      ,.co2_data_o ( co2_data_lo[link_channel_width_gp-1:0] )
      ,.co2_tkn_i  ( co2_tkn_li )
      
      ,.rtr_links_i ( rtr_links_li )
      ,.rtr_links_o ( rtr_links_lo )

      ,.rtr_reset_o ( router_reset_lo )
      ,.rtr_cord_o  ()
      );

  //////////////////////////////////////////////////
  //
  // Loopback Test Master
  //

  logic [1:0]       error_lo;
  logic [1:0][31:0] sent_lo;
  logic [1:0][31:0] recv_lo;

  logic loopback_en;
  
  bsg_wormhole_router_test_node_master #(.flit_width_p( ct_width_gp )
                                        ,.dims_p( 1 )
                                        ,.cord_markers_pos_p({ wh_cord_markers_pos_b_gp, wh_cord_markers_pos_a_gp })
                                        ,.len_width_p( wh_len_width_gp )
                                        ,.num_channels_p( 3 )
                                        ,.channel_width_p( link_channel_width_gp )
                                        )
    loopback
      (.clk_i( router_clk )
      ,.reset_i( router_reset_lo )
      ,.en_i( {2{tag_trace_done_lo & loopback_en}} )

      ,.error_o( error_lo )
      ,.sent_o( sent_lo )
      ,.received_o(recv_lo )

      ,.dest_cord_i( 4'b0001 )

      ,.link_i( rtr_links_lo )
      ,.link_o( rtr_links_li )
      );

  //////////////////////////////////////////////////
  //
  // Testing driver and checker
  //
  initial begin

    // Enable loopback test master
    loopback_en = 1'b1;
    @(negedge tag_trace_done_lo);

    // Test for 10K cycles
    for(int i = 0; i < 10000; i++)
      @(negedge router_clk);

    // Disable loopback test master and wait for pending responses
    loopback_en = 1'b0;
    for(int i = 0; i < 10000; i++)
      @(negedge router_clk);

    // Check no errors from node 0
    assert(error_lo[0] == 0) else 
      begin
        $error("\nFAIL... Error in loopback node 0\n");
        $finish;
      end

    // Check node 0 sent and recv are the same
    assert(sent_lo[0] == recv_lo[0]) else 
      begin
        $error("\nFAIL... Loopback node 0 sent %d packets but received only %d\n", sent_lo[0], recv_lo[0]);
        $finish;
      end
    
    // Check no errors from node 1
    assert(error_lo[1] == 0) else 
      begin
        $error("\nFAIL... Error in loopback node 1\n");
        $finish;
      end
    
    // Check node 1 sent and recv are the same
    assert(sent_lo[1] == recv_lo[1]) else 
      begin
        $error("\nFAIL... Loopback node 1 sent %d packets but received only %d\n", sent_lo[1], recv_lo[1]);
        $finish;
      end
    
    // Pass and finish
    $display("\nPASS!\n");
    $display("Loopback node 0 sent and received %d packets\n", sent_lo[0]);
    $display("Loopback node 1 sent and received %d packets\n", sent_lo[1]);
    $finish;

  end

endmodule

