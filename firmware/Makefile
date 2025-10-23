PROJECT_NAME := firmware
TARGET_EXEC := $(PROJECT_NAME).elf

TARGET_BIN := $(PROJECT_NAME).bin
TARGET_INSTR_BIN := $(PROJECT_NAME)_instr.bin
TARGET_DATA_BIN := $(PROJECT_NAME)_data.bin

TARGET_HEX := $(PROJECT_NAME).hex
TARGET_INSTR_HEX := $(PROJECT_NAME)_instr.hex
TARGET_DATA_HEX := $(PROJECT_NAME)_data.hex

BUILD_DIR := ./build
SRC_DIRS := ./src

SRCS := $(shell find $(SRC_DIRS) -name '*.c' -or -name '*.s')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
LINKER := ./linker.ld

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CFLAGS := $(INC_FLAGS) -no-pie -march=rv32i -mabi=ilp32 -O2 -g \
		  -ffunction-sections -fdata-sections -Wl,-gc-sections \
		  -nostartfiles

CC := riscv32-none-elf-gcc
OBJCOPY := riscv32-none-elf-objcopy
XXD := xxd

BEAR := bear
CDB := compile_commands.json

.PHONY: all clean

all: $(BUILD_DIR)/$(TARGET_HEX) $(BUILD_DIR)/$(TARGET_INSTR_HEX) $(BUILD_DIR)/$(TARGET_DATA_HEX)

clean:
	rm -rf $(BUILD_DIR)

compdb:
	mkdir -p $(BUILD_DIR)
	$(BEAR) --output $(BUILD_DIR)/$(CDB) -- make -B

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.bin
	$(XXD) -p -c4 -e $< | awk '{print $$2}' > $@

$(BUILD_DIR)/$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_EXEC)
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/$(TARGET_INSTR_BIN): $(BUILD_DIR)/$(TARGET_EXEC)
	$(OBJCOPY) -O binary --only-section=.text $< $@

$(BUILD_DIR)/$(TARGET_DATA_BIN): $(BUILD_DIR)/$(TARGET_EXEC)
	$(OBJCOPY) -O binary --only-section=.rodata --only-section=.data --only-section=.bss $< $@

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS) $(LINKER)
	$(CC) $(CFLAGS) -T $(LINKER) -o $@ $(OBJS) $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.s.o: %.s
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@
