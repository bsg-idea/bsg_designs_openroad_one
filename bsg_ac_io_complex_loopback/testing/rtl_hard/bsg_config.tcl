# scripts for creating filelist and library
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/bsg_vcs_create_filelist_library.tcl

# chip source (rtl) files and include paths list
source $::env(SYNTH_FLOW_DIR)/bsg_dc_scripts/design.filelist.tcl
source $::env(SYNTH_FLOW_DIR)/bsg_dc_scripts/design.include.tcl
set all_final_source_files [concat $all_final_source_files $::env(GATE_VERILOG_FILES)]

# chip filelist
bsg_create_filelist $::env(BSG_CHIP_FILELIST) \
                    $all_final_source_files

# chip library
bsg_create_library $::env(BSG_CHIP_LIBRARY_NAME) \
                   $::env(BSG_CHIP_LIBRARY)      \
                   $all_final_source_files       \
                   $final_sverilog_include_paths

# testing source (rtl) files and include paths list
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/filelist.tcl
source $::env(BSG_DESIGNS_TARGET_DIR)/testing/tcl/include.tcl

# testing filelist
bsg_create_filelist $::env(BSG_DESIGNS_TESTING_FILELIST) \
                    $TESTING_SOURCE_FILES

# testing library
bsg_create_library $::env(BSG_DESIGNS_TESTING_LIBRARY_NAME) \
                   $::env(BSG_DESIGNS_TESTING_LIBRARY)      \
                   $TESTING_SOURCE_FILES                    \
                   $TESTING_INCLUDE_PATHS
