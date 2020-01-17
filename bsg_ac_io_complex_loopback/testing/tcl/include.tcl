#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_designs_target_dir $::env(TESTING_BSG_DESIGNS_TARGET_DIR)
set basejump_stl_dir       $::env(TESTING_BASEJUMP_STL_DIR)
set bsg_designs_dir        $::env(TESTING_BSG_DESIGNS_DIR)
set bsg_packaging_dir      $::env(TESTING_BSG_PACKAGING_DIR)
set board_dir              $::env(TESTING_BOARD_DIR)
set bsg_package            $::env(BSG_PACKAGE)
set bsg_pinout             $::env(BSG_PINOUT)
set bsg_padmapping         $::env(BSG_PADMAPPING)

set TESTING_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $basejump_stl_dir/testing/bsg_dmc/lpddr_verilog_model
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
"]
