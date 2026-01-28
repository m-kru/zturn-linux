TARGET := zturn-gpio

# Compiler and Flags
CC ?= gcc
CFLAGS  += -Wall -Wextra -g
LDFLAGS +=

# 2. Directories & Targets
# Add your source directories here (separated by spaces)
SRCDIRS := . afbd
SRCDIRS := $(abspath $(SRCDIRS))

#INCDIRS := ../autogen
#INCDIRS := $(abspath $(INCDIRS))
#INCFLAGS := $(addprefix -I,$(INCDIRS))
#CFLAGS += $(INCFLAGS)

# File Discovery
# Find all .c files in the specified directories
SRCS := $(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c))

# Create a list of .o files by replacing .c with .o
OBJS := $(SRCS:.c=.o)

# Build targets
.PHONY: all
all: $(TARGET)

# Link the executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

# Compile source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Cleanup
.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)
