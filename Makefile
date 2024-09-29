# Makefile both for mingw on windows
# 2024-09-29
# Copyright(c) 2024, mapaware.top
########################################################################
# Linux, CYGWIN_NT, MSYS_NT, ...
shuname="$(shell uname)"
OSARCH=$(shell echo $(shuname)|awk -F '-' '{ print $$1 }')

CC=gcc

# default build is release
# make BUILD=DEBUG
BUILD ?= RELEASE

# project source dirs
PREFIX := .
SRC_DIR := $(PREFIX)/src
COMMON_DIR := $(SRC_DIR)/common

# include dirs for header files (*.h)
INCDIRS += -I$(SRC_DIR) -I$(COMMON_DIR)



# compile directives
CFLAGS += -std=gnu99 -D_GNU_SOURCE -fPIC -Wall -Wno-unused-function -Wno-unused-variable

# load libs: -lpthread = libpthread.so
LDFLAGS += -lm -lpthread

# no mingw default
MINGW_CSRCS := 


# cygwin
ifeq ($(OSARCH), CYGWIN_NT)
	ifeq ($(BITS), 64)
		CFLAGS += -D__CYGWIN64__ -D__CYGWIN__
	else
		CFLAGS += -D__CYGWIN32__ -D__CYGWIN__
	endif
endif

# mingw
# $$MSYS2_HOME: windows 系统环境变量
ifeq ($(OSARCH), MSYS_NT)
	MINGW_CSRCS := $(COMMON_DIR)/win32/syslog-client.c

	CFLAGS += -D__MINGW64__ -m64
	LDFLAGS := -L$$MSYS2_HOME/mingw64/lib -lws2_32
else ifeq ($(OSARCH), MINGW64_NT)
	MINGW_CSRCS := $(COMMON_DIR)/win32/syslog-client.c

	CFLAGS += -D__MINGW64__ -m64
	LDFLAGS := -L$$MSYS2_HOME/mingw64/lib -lws2_32
else ifeq ($(OSARCH), MINGW32_NT)
	MINGW_CSRCS := $(COMMON_DIR)/win32/syslog-client.c

	CFLAGS += -D__MINGW32__ -m32
	LDFLAGS := -L$$MSYS2_HOME/mingw32/lib -lws2_32
else
    LDFLAGS += -lrt
endif


ifeq ($(BUILD), DEBUG)
    # make BUILD=DEBUG
	CFLAGS += -D_DEBUG -g
else
    # default is release
	CFLAGS += -DNDEBUG -O3
endif


############################### make target ############################
.PHONY: all clean help


all: helloworld

helloworld: $(SRC_DIR)/helloworld.c
	@echo "Build $(BUILD) app..."
	$(CC) $(CFLAGS) $(SRC_DIR)/helloworld.c -o helloworld $(INCDIRS) $(LDFLAGS)
	@echo "Done."


clean:
	-rm -f *.stackdump helloworld.o helloworld helloworld.exe

help:
	@echo
	@echo "Build project on $(OSARCH) with the following commands:"
	@echo "  make BUILD=DEBUG  # build app for debug"
	@echo "  make clean        # clean all temp files"
	@echo "  make              # build app for release (default)"
	@echo