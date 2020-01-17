#------------------------------------------------------------
# Do NOT arbitrarily change the order of files. Some module
# and macro definitions may be needed by the subsequent files
#------------------------------------------------------------

set bsg_designs_target_dir $::env(BSG_DESIGNS_TARGET_DIR)
set bsg_packaging_dir      $::env(BSG_PACKAGING_DIR)
set bsg_package            $::env(BSG_PACKAGE)
set bsg_pinout             $::env(BSG_PINOUT)
set bsg_padmapping         $::env(BSG_PADMAPPING)

set HARD_SWAP_FILELIST [join "
"]

set NETLIST_SOURCE_FILES [join "
"]

set NEW_SVERILOG_SOURCE_FILES [join "
"]

