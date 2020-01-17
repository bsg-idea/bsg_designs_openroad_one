#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set basejump_stl_dir       $::env(BASEJUMP_STL_DIR)
set bsg_designs_dir        $::env(BSG_DESIGNS_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)
set bsg_package            $::env(BSG_PACKAGE)
set bsg_pinout             $::env(BSG_PINOUT)
set bsg_padmapping         $::env(BSG_PADMAPPING)

set SVERILOG_INCLUDE_PATHS [join "
  $basejump_stl_dir/bsg_cache
  $basejump_stl_dir/bsg_misc
  $basejump_stl_dir/bsg_noc
  $basejump_stl_dir/bsg_tag
  $bsg_designs_target_dir/v
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/common/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog
  $bsg_packaging_dir/$bsg_package/pinouts/$bsg_pinout/portable/verilog/padmappings/$bsg_padmapping
  $bsg_packaging_dir/common/foundry/portable/verilog
  $bsg_packaging_dir/common/verilog
"]

