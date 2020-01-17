
checkout_all:
	-cd ../ && git submodule update --init bsg_ac_io_complex_loopback/cad/synth
	cd ../ && git submodule update --init bsg_ac_io_complex_loopback/imports/basejump_stl
	cd ../ && git submodule update --init bsg_ac_io_complex_loopback/imports/board
	cd ../ && git submodule update --init bsg_ac_io_complex_loopback/imports/bsg_designs
	cd ../ && git submodule update --init bsg_ac_io_complex_loopback/imports/bsg_packaging

synth: checkout_all
	cd cad/synth; $(MAKE) synth

