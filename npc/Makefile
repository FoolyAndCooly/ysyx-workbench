TOPNAME = top

WORK_DIR = $(shell pwd)
INC_PATH = $(WORK_DIR)/include
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
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
OSRCS = $(shell find $(abspath ./build/obj_dir) -name "*.o")
CSRCS += $(SRC_AUTO_BIND)

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS +=  $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\""
LDFLAGS = -lreadline

$(BIN): $(VSRCS) $(CSRCS)
	@echo $(CXXFLAGS)
	@rm -rf $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))
all: default

run: $(BIN)
	@$^ $(IMG)
	$(call git_commit, "sim RTL")

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean run
