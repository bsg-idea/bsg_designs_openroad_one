`include "bsg_padmapping.v"
`include "bsg_iopad_macros.v"

//==============================================================================
//
// BSG CHIP
//
// This is the toplevel for the ASIC. This chip uses the UW BGA package found
// inside bsg_packaging/uw_bga. For physical design reasons, the input pins
// have been swizzled (ie. re-arranged) from their original meaning. We use the
// bsg_chip_swizzle_adapter in every ASIC to abstract away detail.
//

module bsg_chip

import bsg_tag_pkg::*;
import bsg_chip_pkg::*;

`include "bsg_pinout.v"
`include "bsg_iopads.v"

  //////////////////////////////////////////////////
  //
  // BSG Tag Master Instance
  //

  // All tag lines from the btm
  bsg_tag_s [tag_num_clients_gp-1:0] tag_lines_lo;

  // Rename the tag lines (determines the client ID!)
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
      (.clk_i      ( bsg_tag_clk_i_int )
      ,.data_i     ( bsg_tag_en_i_int ? bsg_tag_data_i_int : 1'b0 )
      ,.en_i       ( 1'b1 )
      ,.clients_r_o( tag_lines_lo )
      );

  //////////////////////////////////////////////////
  //
  // BSG Clock Generator Power Domain
  //

  // No clock generators ...
  wire router_clk_lo = clk_C_i_int;
  wire io_master_clk_lo = clk_B_i_int;

  //////////////////////////////////////////////////
  //
  // Swizzle Adapter for Comm Link IO Signals
  //

  logic         ci_clk_li;
  logic         ci_v_li;
  logic [8:0]   ci_data_li;
  logic         ci_tkn_lo;

  logic         co_clk_lo;
  logic         co_v_lo;
  logic [8:0]   co_data_lo;
  logic         co_tkn_li;

  logic         ci2_clk_li;
  logic         ci2_v_li;
  logic [8:0]   ci2_data_li;
  logic         ci2_tkn_lo;

  logic         co2_clk_lo;
  logic         co2_v_lo;
  logic [8:0]   co2_data_lo;
  logic         co2_tkn_li;

  bsg_chip_swizzle_adapter
    swizzle
      ( // IO Port Side
       .port_ci_clk_i   (ci_clk_i_int)
      ,.port_ci_v_i     (ci_v_i_int)
      ,.port_ci_data_i  ({ci_8_i_int, ci_7_i_int, ci_6_i_int, ci_5_i_int, ci_4_i_int, ci_3_i_int, ci_2_i_int, ci_1_i_int, ci_0_i_int})
      ,.port_ci_tkn_o   (ci_tkn_o_int)

      ,.port_ci2_clk_o  (ci2_clk_o_int)
      ,.port_ci2_v_o    (ci2_v_o_int)
      ,.port_ci2_data_o ({ci2_8_o_int, ci2_7_o_int, ci2_6_o_int, ci2_5_o_int, ci2_4_o_int, ci2_3_o_int, ci2_2_o_int, ci2_1_o_int, ci2_0_o_int})
      ,.port_ci2_tkn_i  (ci2_tkn_i_int)

      ,.port_co_clk_i   (co_clk_i_int)
      ,.port_co_v_i     (co_v_i_int)
      ,.port_co_data_i  ({co_8_i_int, co_7_i_int, co_6_i_int, co_5_i_int, co_4_i_int, co_3_i_int, co_2_i_int, co_1_i_int, co_0_i_int})
      ,.port_co_tkn_o   (co_tkn_o_int)

      ,.port_co2_clk_o  (co2_clk_o_int)
      ,.port_co2_v_o    (co2_v_o_int)
      ,.port_co2_data_o ({co2_8_o_int, co2_7_o_int, co2_6_o_int, co2_5_o_int, co2_4_o_int, co2_3_o_int, co2_2_o_int, co2_1_o_int, co2_0_o_int})
      ,.port_co2_tkn_i  (co2_tkn_i_int)

      // Chip (Guts) Side
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
      (.core_clk_i ( router_clk_lo )
      ,.io_clk_i   ( io_master_clk_lo )

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
  // Loopback Test Client
  //

  bsg_wormhole_router_test_node_client #(.flit_width_p( ct_width_gp )
                                        ,.dims_p( 1 )
                                        ,.cord_markers_pos_p({ wh_cord_markers_pos_b_gp, wh_cord_markers_pos_a_gp })
                                        ,.len_width_p( wh_len_width_gp )
                                        )
    loopback
      (.clk_i( router_clk_lo )
      ,.reset_i( router_reset_lo )

      ,.dest_cord_i( 4'b0000 )

      ,.link_i( rtr_links_lo )
      ,.link_o( rtr_links_li )
      );

endmodule

