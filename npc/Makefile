all:
	@echo "Write this Makefile by your self."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator -cc vsrc/top.v
	verilator -Wall --trace -cc vsrc/top.v --exe csrc/tb_top.cpp
	make -C obj_dir -f Vtop.mk Vtop

include ../Makefile
