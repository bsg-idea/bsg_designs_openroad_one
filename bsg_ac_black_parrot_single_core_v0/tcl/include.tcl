#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set blackparrot_dir        $::env(BLACKPARROT_DIR)

set bsg_packaging_dir $::env(BSG_PACKAGING_DIR)
set bsg_package       $::env(BSG_PACKAGE)
set bsg_pinout        $::env(BSG_PINOUT)
set bsg_padmapping    $::env(BSG_PADMAPPING)

set bp_common_dir ${blackparrot_dir}/bp_common
set bp_top_dir    ${blackparrot_dir}/bp_top
set bp_fe_dir     ${blackparrot_dir}/bp_fe
set bp_be_dir     ${blackparrot_dir}/bp_be
set bp_me_dir     ${blackparrot_dir}/bp_me

set SVERILOG_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_clk_gen
  $basejump_stl_dir/bsg_dataflow
  $basejump_stl_dir/bsg_mem
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $basejump_stl_dir/bsg_test
  $bp_common_dir/src/include
  $bp_be_dir/src/include
  $bp_be_dir/src/include/bp_be_dcache
  $bp_fe_dir/src/include
  $bp_me_dir/src/include/v
  $bp_top_dir/src/include
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog/padmappings/$bsg_padmapping
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/common/verilog
"]

