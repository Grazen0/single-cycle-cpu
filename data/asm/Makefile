PROJECT_NAME := firmware
TARGET_EXEC := $(PROJECT_NAME).elf
TARGET_BIN := $(PROJECT_NAME).bin
TARGET_HEX := $(PROJECT_NAME).hex

BUILD_DIR := ./build
SRC_DIRS := ./src

SRCS := $(shell find $(SRC_DIRS) -name '*.c' -or -name '*.s')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
LINKER := ./linker.ld

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CFLAGS := $(INC_FLAGS) -nostdlib -no-pie -march=rv32i -mabi=ilp32 -std=c23 -g

CC := riscv32-unknown-none-elf-gcc
OBJCOPY := riscv32-unknown-none-elf-objcopy
XXD := xxd

all: $(BUILD_DIR)/$(TARGET_HEX)

$(BUILD_DIR)/$(TARGET_HEX): $(BUILD_DIR)/$(TARGET_BIN)
	$(XXD) -p -c 1 $< > $@

$(BUILD_DIR)/$(TARGET_BIN): $(BUILD_DIR)/$(TARGET_EXEC)
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS) $(LINKER)
	$(CC) $(CFLAGS) -T $(LINKER) -o $@ $(OBJS) $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.s.o: %.s
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -r $(BUILD_DIR)

.PHONY: all clean
