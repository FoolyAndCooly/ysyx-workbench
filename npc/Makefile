TOPNAME = ysyxSoCFull

WORK_DIR = $(shell pwd)
INC_PATH = $(WORK_DIR)/include
INV_PATH += $(abspath $(WORK_DIR)/../ysyxSoC/perip/uart16550/rtl)
INV_PATH += $(abspath $(WORK_DIR)/../ysyxSoC/perip/spi/rtl)
LIB_SO = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = $(WORK_DIR)/build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# project source

VSRCS += $(shell find $(abspath ./vsrc) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/perip) -name "*.v")
VSRCS += $(shell find $(abspath ../ysyxSoC/build) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
OSRCS = $(shell find $(abspath ./build/obj_dir) -name "*.o")
CSRCS += $(SRC_AUTO_BIND)

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
INVFLAGS = $(addprefix -I, $(INV_PATH))
CXXFLAGS +=  $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS = -lreadline

$(BIN): $(VSRCS) $(CSRCS)
	@rm -rf $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		$(INVFLAGS) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN)) \
		--timescale "1ns/1ns" --no-timing
all: default

run: $(BIN)
	@$^ -b $(LIB_SO) $(IMG)
	$(call git_commit, "sim RTL")

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean run
