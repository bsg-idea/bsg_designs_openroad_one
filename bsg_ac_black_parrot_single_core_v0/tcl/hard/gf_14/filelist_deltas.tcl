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

set HARD_SWAP_FILELIST [join "
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_bit.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_1rw_sync_mask_write_byte.v
  $basejump_stl_dir/hard/gf_14/bsg_mem/bsg_mem_2r1w_sync.v
"]

set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

