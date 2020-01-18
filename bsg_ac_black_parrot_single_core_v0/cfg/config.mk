#===============================================================================
# Configuration File (sourced by cad infrastructures)
#===============================================================================

include $(BSG_DESIGNS_TARGET_DIR)/../Makefile.setup

# Toplevel module name
export DESIGN_NAME := bsg_chip

# Design type ("block" or "chip"). Chip implies a toplevel design with GPIOs.
export DESIGN_TYPE := chip 

# Pointer to import repos
export BASEJUMP_STL_DIR  := $(BSG_DESIGNS_TARGET_DIR)/imports/basejump_stl
export BSG_PACKAGING_DIR := $(BSG_DESIGNS_TARGET_DIR)/imports/bsg_packaging
export BSG_DESIGNS_DIR   := $(BSG_DESIGNS_TARGET_DIR)/imports/bsg_designs
export BOARD_DIR         := $(BSG_DESIGNS_TARGET_DIR)/imports/board
export BLACKPARROT_DIR  := $(BSG_DESIGNS_TARGET_DIR)/imports/pre-alpha-release

# Packaging Parameters
export BSG_PACKAGE           := uw_bga
export BSG_PINOUT            := bsg_asic_cloud
export BSG_PACKAGING_FOUNDRY := gf_14_invecas_1p8v
export BSG_PADMAPPING        := default

# Black-parrot subdirectories
export BLACKPARROT_COMMON_DIR ?= $(BLACKPARROT_DIR)/bp_common
export BLACKPARROT_TOP_DIR    ?= $(BLACKPARROT_DIR)/bp_top
export BLACKPARROT_FE_DIR     ?= $(BLACKPARROT_DIR)/bp_fe
export BLACKPARROT_BE_DIR     ?= $(BLACKPARROT_DIR)/bp_be
export BLACKPARROT_ME_DIR     ?= $(BLACKPARROT_DIR)/bp_me

