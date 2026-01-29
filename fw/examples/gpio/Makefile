TARGET := ex-gpio
BUILD_DIR := build

# Compiler and Flags
CC ?= gcc
CFLAGS  += -Wall -Wextra -g -DLOG_COLOR
LDFLAGS +=

# 1. Use relative paths for source directories
SRCDIRS := . afbd common

# 2. Find all .c files (relative paths)
SRCS := $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))

# 3. Strip the "./" from paths if it exists so build/./main.o becomes build/main.o
SRCS := $(patsubst ./%,%,$(SRCS))

# 4. Create the object list inside the build directory
OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS:.c=.o))

.PHONY: all
all: $(TARGET)

# Link
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(BUILD_DIR)/$(TARGET) $(LDFLAGS)

# Compile
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
