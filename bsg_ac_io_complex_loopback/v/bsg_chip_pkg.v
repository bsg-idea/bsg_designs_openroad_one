`ifndef BSG_CHIP_PKG_V
`define BSG_CHIP_PKG_V

package bsg_chip_pkg;

  `include "bsg_defines.v"
  `include "bsg_noc_links.vh"

  //////////////////////////////////////////////////
  //
  // BSG CHIP IO COMPLEX PARAMETERS
  //

  localparam link_channel_width_gp = 8;
  localparam link_num_channels_gp = 1;
  localparam link_width_gp = 32;
  localparam link_lg_fifo_depth_gp = 6;
  localparam link_lg_credit_to_token_decimation_gp = 3;

  localparam ct_num_in_gp = 2;
  localparam ct_tag_width_gp = `BSG_SAFE_CLOG2(ct_num_in_gp + 1);
  localparam ct_width_gp = link_width_gp - ct_tag_width_gp;

  localparam ct_remote_credits_gp = 64;
  localparam ct_credit_decimation_gp = ct_remote_credits_gp/4;
  localparam ct_lg_credit_decimation_gp = `BSG_SAFE_CLOG2(ct_credit_decimation_gp/2+1);
  localparam ct_use_pseudo_large_fifo_gp = 1;

  localparam wh_len_width_gp = 2;
  localparam wh_cord_markers_pos_a_gp = 0;
  localparam wh_cord_markers_pos_b_gp = 4;
  localparam wh_cord_width_gp = wh_cord_markers_pos_b_gp - wh_cord_markers_pos_a_gp;

  //////////////////////////////////////////////////
  //
  // BSG CHIP TAG PARAMETERS AND STRUCTS
  //

  // Total number of clients the master will be driving.
  localparam tag_num_clients_gp = 7;

  localparam tag_max_payload_width_in_io_complex_gp = (wh_cord_width_gp + 1);

  localparam tag_max_payload_width_gp = `BSG_MAX(tag_max_payload_width_in_io_complex_gp, 0);

  // The number of bits required to represent the max payload width
  localparam tag_lg_max_payload_width_gp = `BSG_SAFE_CLOG2(tag_max_payload_width_gp + 1);

  //////////////////////////////////////////////////
  //
  // Interface Struct Declarations
  //

  `declare_bsg_ready_and_link_sif_s(ct_width_gp, bsg_ready_and_link_sif_s);

endpackage // bsg_chip_pkg

`endif // BSG_CHIP_PKG_V

