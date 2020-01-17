
checkout_all:
	cd ../ && git submodule update --init bsg_ac_padring/cad/synth
	cd ../ && git submodule update --init bsg_ac_padring/imports/basejump_stl
	cd ../ && git submodule update --init bsg_ac_padring/imports/bsg_packaging

synth: checkout_all
	cd cad/synth; $(MAKE) synth

