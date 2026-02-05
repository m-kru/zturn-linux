APP := ex-uio
BUILD_DIR := build

# Compiler and Flags
CC ?= gcc
CFLAGS  += -Wall -Wextra -g -DLOG_COLOR
LDFLAGS +=

# relative paths for source directories.
SRC_DIRS := . afbd common

# Find all .c files (relative paths).
SRCS := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))

# Strip the "./" from paths if it exists so build/./main.o becomes build/main.o
SRCS := $(patsubst ./%,%,$(SRCS))

# Create the object list inside the build directory
OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS:.c=.o))

.PHONY: all
all: $(APP)

# Link application
$(APP): $(OBJS)
	$(CC) $(OBJS) -o $(BUILD_DIR)/$(APP) $(LDFLAGS)

# Compile source files
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
