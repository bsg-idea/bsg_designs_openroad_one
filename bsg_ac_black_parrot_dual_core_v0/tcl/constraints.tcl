source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_tag.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_chip_cdc.constraints.tcl
source -echo -verbose $::env(BSG_DESIGNS_DIR)/toplevels/common/bsg_comm_link.constraints.tcl

########################################
##
## Clock Setup
##

set router_clk_name               "router_clk"
set router_clk_period_ps          1666.0 ;# 600 MHz
set router_clk_uncertainty_ps     20

set io_master_clk_name            "io_master_clk"
set io_master_clk_period_ps       1666.0 ;# 600MHz
set io_master_clk_uncertainty_ps  20

set bp_clk_name                   "bp_clk"
set bp_clk_period_ps              1250 ;# 800MHz
set bp_clk_uncertainty_ps         20

set coh_clk_name                  "coh_clk"
set coh_clk_period_ps             1000 ;# 1GHz
set coh_clk_uncertainty_ps        20

set tag_clk_name                  "tag_clk"
set tag_clk_period_ps             6666.0 ;# 150 MHz
set tag_clk_uncertainty_ps        20

########################################
##
## Top-level Constraints
##

if { ${DESIGN_NAME} == "bsg_chip" } {

  set_app_var timing_enable_multiple_clocks_per_reg true

  bsg_tag_clock_create ${tag_clk_name} bsg_tag_clk_i/Y bsg_tag_data_i/Y bsg_tag_en_i/Y ${tag_clk_period_ps} ${tag_clk_uncertainty_ps}

  create_clock -period ${bp_clk_period_ps} -name ${bp_clk_name} [get_ports p_clk_A_i]
  set_clock_uncertainty $bp_clk_uncertainty_ps [get_clocks ${bp_clk_name}]

  create_clock -period ${io_master_clk_period_ps} -name ${io_master_clk_name} [get_ports p_clk_B_i]
  set_clock_uncertainty $io_master_clk_uncertainty_ps [get_clocks ${io_master_clk_name}]

  create_clock -period ${router_clk_period_ps} -name ${router_clk_name} [get_ports p_clk_C_i]
  set_clock_uncertainty $router_clk_uncertainty_ps [get_clocks ${router_clk_name}]

  # Comm Link CH0
  #=================
  set ch0_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_clk_i]] -filter "name==Y"]
  set ch0_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_*_i]] -filter "name==Y"] $ch0_in_clk_port]
  set ch0_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_ci_tkn_o]] -filter "name==DATA"]
  set ch0_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_clk_o]] -filter "name==DATA"]
  set ch0_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_*_o]] -filter "name==DATA"] $ch0_out_clk_port]
  set ch0_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_ci2_tkn_i]] -filter "name==Y"]
  
  bsg_comm_link_timing_constraints \
    ${io_master_clk_name}          \
    "a"                            \
    $ch0_in_clk_port               \
    $ch0_in_dv_port                \
    $ch0_in_tkn_port               \
    $ch0_out_clk_port              \
    $ch0_out_dv_port               \
    $ch0_out_tkn_port              \
    100                            \
    100                            \
    $io_master_clk_uncertainty_ps

  # Comm Link CH1
  #=================
  set ch1_in_clk_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_clk_i]] -filter "name==Y"]
  set ch1_in_dv_port   [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co_*_i]] -filter "name==Y"] $ch1_in_clk_port]
  set ch1_in_tkn_port                          [get_pins -of_objects [get_cells -of_objects [get_ports p_co_tkn_o]] -filter "name==DATA"]
  set ch1_out_clk_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_clk_o]] -filter "name==DATA"]
  set ch1_out_dv_port  [remove_from_collection [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_*_o]] -filter "name==DATA"] $ch1_out_clk_port]
  set ch1_out_tkn_port                         [get_pins -of_objects [get_cells -of_objects [get_ports p_co2_tkn_i]] -filter "name==Y"]
  
  bsg_comm_link_timing_constraints \
    ${io_master_clk_name}          \
    "b"                            \
    $ch1_in_clk_port               \
    $ch1_in_dv_port                \
    $ch1_in_tkn_port               \
    $ch1_out_clk_port              \
    $ch1_out_dv_port               \
    $ch1_out_tkn_port              \
    100                            \
    100                           \
    $io_master_clk_uncertainty_ps

  # CDC Paths
  #=================
  update_timing
  set clocks [all_clocks]
  foreach_in_collection launch_clk $clocks {
    if { [get_attribute $launch_clk is_generated] } {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk master_clock_name]"]
      append_to_collection launch_group [get_attribute $launch_clk master_clock]
    } else {
      set launch_group [get_generated_clocks -filter "master_clock_name==[get_attribute $launch_clk name]"]
      append_to_collection launch_group $launch_clk
    }
    foreach_in_collection latch_clk [remove_from_collection $clocks $launch_group] {
      set launch_period [get_attribute $launch_clk period]
      set latch_period [get_attribute $latch_clk period]
      set max_delay_ps [expr min($launch_period,$latch_period)/2]
      set_max_delay $max_delay_ps -from $launch_clk -to $latch_clk -ignore_clock_latency
      set_min_delay 0             -from $launch_clk -to $latch_clk -ignore_clock_latency
    }
  }

  # Dual Port SRAMs
  #=================
  foreach_in_collection cell [filter_collection [all_macro_cells] "ref_name=~*_1r1w_*"] {
    set_disable_timing $cell -from CLKA -to CLKB
    set_disable_timing $cell -from CLKB -to CLKA
  }

  # False Paths
  #=================
  set_false_path -from [get_pins -hier *did*]
  set_false_path -from [get_pins -hier *cord*]

  # Ungrouping
  #=================
  set_ungroup [get_cells swizzle]

  # Derate
  #=================
  set cells_to_derate [list]
  append_to_collection cells_to_derate [get_cells -quiet -hier -filter "ref_name=~gf14_*"]
  if { [sizeof $cells_to_derate] > 0 } {
    foreach_in_collection cell $cells_to_derate {
      set_timing_derate -cell_delay -early 0.97 $cell
      set_timing_derate -cell_delay -late  1.03 $cell
      set_timing_derate -cell_check -early 0.97 $cell
      set_timing_derate -cell_check -late  1.03 $cell
    }
  }

  # Dont-touch
  #=================
  set_dont_touch [get_nets pwrok_lo*]
  set_dont_touch [get_nets iopwrok_lo*]
  set_dont_touch [get_nets retc_lo*]

########################################
##
## Unknown design...
##
} else {

  puts "BSG-error: No constraints found for design (${DESIGN_NAME})!"

}

