# OpenROAD One Tapeout Designs

This repository contains designs working up to the OpenROAD One tapeout. Inside each
design is a Makefile. Running `$make` will checkout all of the submodules for the
given design. Below is a list of all the designs with a short desciption:

| Name                       | Description                                            |
|:---------------------------|:-------------------------------------------------------|
| bsg_ac_padring             | Padring only                                           |
| bsg_ac_io_complex_loopback | Padring with IO complex and a loopback testing client. |

### Using CAD Infrastructure

In the root of this repository is a file called `Makefile.setup`. Inside this file are
some empty environment variables that should be set by the user in order to run any CAD
infrastructure that has been included with the designs. Above each variable is a description
that should guide the user as to what these variables represent. CAD infrastructure 
submodules for a given design can be found inside the `cad/` directory which contains
submodules with cad infrastructures. Some of these are closed-source but should not be
required to build the design with your own infrastructure.
