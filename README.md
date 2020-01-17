# OpenROAD One Tapeout Designs

This repository contains designs working up to the OpenROAD One tapeout. Inside each
design is a Makefile. Running `$make` will checkout all of the submodules for the
given design. Below is a list of all the designs with a short desciption:

| Name                       | Description                                            |
|:---------------------------|:-------------------------------------------------------|
| bsg_ac_padring             | Padring only                                           |
| bsg_ac_io_complex_loopback | Padring with IO complex and a loopback testing client. |

## Using CAD Infrastructure

In the root of this repository is a file called `Makefile.setup`. Inside this file are
some empty environment variables that should be set by the user in order to run any CAD
infrastructure that has been included with the designs. Above each variable is a description
that should guide the user as to what these variables represent. CAD infrastructure 
submodules for a given design can be found inside the `cad/` directory which contains
submodules with cad infrastructures. Some of these are closed-source but should not be
required to build the design with your own infrastructure.

## Design Directory Structure

Each design has a structure that is well defined to make it easy for CAD tool infrastructure
to find and link the required files. Below is a description of the main files you will find
in each design.

### v/ Directory
The `v/` directory is where your toplevel and any additional RTL verilog files live. There
are no rules about the name of the files in this directory as they will be linked in the
filelist.tcl file (described later). For the most part, we try to limit the code in this
repository to the top most RTL in the chip. Generalized components are typically refactored
to live somewhere they can be better maintained.


### tcl/ Directory
The `tcl/` directory contains a collection of TCL scripts that will be sourced by the various
tools. These scripts are the main way that the designer can express design intent and
constraints to the chip building flow, so this directory is quite important! Below is a
description about each of the tcl scripts that we expect to find in this directory.

The first file is `filelist.tcl`. This file is used to find all of the RTL files for your
design. Inside this script should be the creation of a list called `SVERILOG_SOURCE_FILES`
where each element in the list is the absolute path to a required RTL file that will be
synthesized. It is best practice to make the path’s absolute as the relative path is not with
respect to this file’s directory. It is also common to use the available environment variables
to reference other repositories that might contain RTL required for you design. Using the
environment variables allows for the flow to move about and still correctly link the design.

The next file is `include.tcl`. This file is very similar to the `filelist.tcl` file described
above but instead contains a list of directories that should be searched to resolve include
statements. The name of the list must be `SVERILOG_INCLUDE_PATHS` and each element is the absolute
path to the search directory.

The next file is `constraints.tcl`. This file contains all constraints for your design. It is read
in during synthesis (before compilation) and is passed down the line to the cad tools that follow.
This primarily constrains timing constraints but any constraints or DRVs you want to add to your
design can be specified here.

The `hard/` folder is a special folder that holds information that is more process specific. The
term hard or hardened shows up throughout the cad flow and some of our other repositories and
refers to the inflexibility that occurs when you start to design in a process specific manner.

The final file is `hard/<process>/filelist_deltas.tcl`. This file modifies the previously discussed
`filelist.tcl`. There are 3 lists that must be defined in the filelist_deltas.tcl: `HARD_SWAP_FILELIST`,
`NETLIST_SOURCE_FILES`, and `NEW_SVERILOG_SOURCE_FILES`. The first is `HARD_SWAP_FILELIST` which is a list
of files that will replace modules with the same name in the `SVERILOG_SOURCE_FILES` list defined in
`filelist.tcl`. This replacing step (often referred to as “hardened swapping”) is useful for replacing
RTL modules with generated IP blocks or other finely tuned pre-synthesized blocks. The second list is
`NETLIST_SOURCE_FILES` which contains a list of new files to link during synthesis however these files
are already in a netlist form (no synthesis required). The final list is `NEW_SVERILOG_SOURCE_FILES`
which is a list of new files to link during synthesis however these files are still RTL and need to
be synthesized.

### testing/ Directory
The `testing/` directory contains anything testing related.

First is the `testing/v/` directory. Here are any verilog files needed for the simulation such as
testbench drivers, reset and clock generations, bootloaders, and more!

Next is the `testing/tcl/` directory with the `filelist.tcl` and `include.tcl` files. These files
are very similar to the main tcl/filelist.tcl and tcl/include.tcl files in the design except they are
only used for testing (thus do not need to be synthesizable).

Finally there are the `testing/rtl`, `testing/rtl_hard`, and `testing/post_synth_ff`. These are
referred to as “testing corners” and are used to perform simulations at different points throughout
the flow. Each corner has a makefile that can be used to build and run the simulation as well
as setup any prerequisites. Below is a description of each corner in order of least accurate/fastest
to most accurate/slowest:

#### RTL Testing
The design for this testing corner is created by simply reading the files found in your
design’s `tcl/filelist.tcl`. This corner has no timing information annotated (propagation delay is 0ns).

#### RTL-HARD Testing
This corner is very similar to the RTL testing corner, except that it will add/swap
hardened modules into the design. The design for this testing corner is created by reading the files found
in your design’s `tcl/filelist.tcl` and `tcl/hard/<process>/filelist_deltas.tcl`. This allows you to make sure
that the semantics of the hardened modules match that of the RTL modules used in the previous corner. This
corner is also using the exact same filelist that will be used during synthesis thus can be used to make
sure that the hardening process occurs (i.e. hardened modules are actually getting pulled into the design).
This corner has no timing information annotated (propagation delay is 0ns).

#### Post-Synth-FF Testing (Fast Functional)
This corner uses the output netlist from synthesis as the design
and combines it with the gate-level verilog modules from the PDK to create the simulation design model. This
corner has no timing information annotated (propagation delay is 0ns). In our experience, adding timing
information to this simulation is futile however the fast functional model works just fine and is important
to catch synthesizability and X-pessimism problems early.

### cfg/ Directory
Inside this directory are configuration files. Right now there is only the `config.mk` which can be sourced
by CAD tool infrastructure to setup a few design specific values.

### cad/ Directory
Inside this directory are submodules to CAD tool infrastructures.

### imports/ Directory
Inside this directory are submodules to other projects to grab RTL from.
