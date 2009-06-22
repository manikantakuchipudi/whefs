########################################################################
# This file should be included by all other Makefiles in the project.
default: all
all:

########################################################################
# Don't touch these:
CONFIG.MAKEFILE := $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
$(CONFIG.MAKEFILE):
TOP_SRCDIR_REL := $(dir $(CONFIG.MAKEFILE))
TOP_SRCDIR_REL := $(patsubst %/,%,$(TOP_SRCDIR_REL))# horrible kludge
#TOP_SRCDIR := $(shell cd -P $(TOP_SRCDIR_REL) && pwd)
TOP_SRCDIR := $(realpath $(TOP_SRCDIR_REL))
#$(error TOP_SRCDIR_REL=$(TOP_SRCDIR_REL)   TOP_SRCDIR=$(TOP_SRCDIR))
TOP_INCDIR := $(TOP_SRCDIR_REL)/include
INCLUDES += -I. -I$(TOP_INCDIR)
CPPFLAGS += $(INCLUDES)

########################################################################
# You can touch these:
########################################################################
CLEAN_FILES += $(wildcard *.o *~)

########################################################################
# Set ENABLE_DEBUG to 1 to enable whefs debugging.
DEBUG ?= 1
ENABLE_DEBUG ?= $(DEBUG)

########################################################################
# The code is C99. How that's enabled/forced is compiler-dependent.
# gcc needs -std=c99. Other compilers need other args. SunStudio:
# -xc99=all, tcc: none
ifeq (cc,$(CC))# assume this is gcc (or compatible)
  CFLAGS += -std=c99 -pedantic -Wall
endif
ifeq (gcc,$(CC))
  CFLAGS += -std=c99
endif
CFLAGS += -Wimplicit-function-declaration


########################################################################
# If ENABLE_MMAP is 1 then whefs will try to mmap() file-based storage
# for faster access. If ENABLE_MMAP_ASYNC is 1 then asynchronous mode
# is used for mmap() flushing by default (*much* faster but also more
# dangerous). If ENABLE_MMAP is false then ENABLE_MMAP_ASYNC is
# ignored.
ENABLE_MMAP ?= 1
ENABLE_MMAP_ASYNC ?= 0


########################################################################
# Set ENABLE_STATIC_MALLOC to 1 to enable (0 to disable) custom
# malloc()/free() implementations for certain types which avoid
# malloc() until a certain number of objects have been created. This
# is not thread-safe, but neither is whefs, so go ahead and turn it on
# unless you need to create whio_dev and/or whefs_fs-related objects
# in multiple threads or you need to use multiple VFSs in separate
# threads.
ENABLE_STATIC_MALLOC ?= 0

WHIO_ENABLE_STATIC_MALLOC ?= $(ENABLE_STATIC_MALLOC)
WHEFS_ENABLE_STATIC_MALLOC ?= $(ENABLE_STATIC_MALLOC)

########################################################################
# If WHIO_ENABLE_ZLIB is 1 then certain features requiring libz will
# be enabled in the whio API. Without this the functions are still
# there but will only return error codes.
WHIO_ENABLE_ZLIB := 1

########################################################################
# common.make should come last. Contains config-independent make code.
include $(TOP_SRCDIR_REL)/common.make
ALL_MAKEFILES := $(PACKAGE.MAKEFILE) $(ShakeNMake.MAKEFILE) $(CONFIG.MAKEFILE)

########################################################################
ifeq (1,$(ENABLE_DEBUG))
  CPPFLAGS += -UNDEBUG -DDEBUG=1
  CFLAGS += -g
  CXXFLAGS += -g
else
  CPPFLAGS += -UDEBUG -DNDEBUG=1
endif


########################################################################
LIBWHEFS.LIBDIR := $(TOP_SRCDIR)/src
LIBWHEFS.A := $(LIBWHEFS.LIBDIR)/libwhefs.a
$(LIBWHEFS.A):
LIBWHEFS.DLL := $(LIBWHEFS.LIBDIR)/libwhefs.so
$(LIBWHEFS.DLL):

AMALGAMATION_H := $(TOP_SRCDIR_REL)/whefs_amalgamation.h
AMALGAMATION_C := $(TOP_SRCDIR_REL)/whefs_amalgamation.c

DISTCLEAN_FILES += $(AMALGAMATION_C) $(AMALGAMATION_H)
