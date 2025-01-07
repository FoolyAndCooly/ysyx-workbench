ifeq ($(PLATFORM),SOC)
TOPNAME = ysyxSoCTop
else
TOPNAME = npc
endif

DIFF_TEST ?= true
NXDC_FILES = constr/$(TOPNAME).nxdc
WORK_DIR = $(shell pwd)
INC_PATH += $(WORK_DIR)/include
ifeq ($(PLATFORM),SOC)
INV_PATH += $(abspath $(WORK_DIR)/../ysyxSoC/perip/uart16550/rtl)
INV_PATH += $(abspath $(WORK_DIR)/../ysyxSoC/perip/spi/rtl)
endif
LIB_SO = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = $(WORK_DIR)/build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

ifeq ($(PLATFORM),SOC)
# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)

$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

CSRCS += $(SRC_AUTO_BIND)
endif

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# project source

VSRCS += $(shell find $(abspath ./vsrc) -name "*.v")
ifeq ($(PLATFORM),SOC)
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/build) -name "*.v")
endif
CSRCS += $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
OSRCS += $(shell find $(abspath ./build/obj_dir) -name "*.o")

# rules for verilator
INCFLAGS += $(addprefix -I, $(INC_PATH))
INCFLAGS += -D$(PLATFORM)
INVFLAGS += $(addprefix -I, $(INV_PATH))
INVFLAGS += -D$(PLATFORM)
ifeq ($(DIFF_TEST),true)
INCFLAGS += -DDIFFTEST
INVFLAGS += -DDIFFTEST
endif
CXXFLAGS +=  $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS += -lreadline

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_CFLAGS)\
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		$(INVFLAGS) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) \
		--timescale "1ns/1ns" --no-timing --trace

all: default

run: $(BIN)
ifeq ($(DIFF_TEST),true)
	@$^ $(ARGS) -d $(LIB_SO) $(IMG)
else
	@$^ $(ARGS) $(IMG)
	$(call git_commit, "sim RTL")
endif

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean run
