#! gmake
## The OpenGL Extension Wrangler Library
## Copyright (C) 2003, 2002, Milan Ikits <milan.ikits@ieee.org>
## Copyright (C) 2003, 2002, Marcelo E. Magallon <mmagallo@debian.org>
## Copyright (C) 2002, Lev Povalahev <levp@gmx.net>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without 
## modification, are permitted provided that the following conditions are met:
## 
## * Redistributions of source code must retain the above copyright notice, 
##   this list of conditions and the following disclaimer.
## * Redistributions in binary form must reproduce the above copyright notice, 
##   this list of conditions and the following disclaimer in the documentation 
##   and/or other materials provided with the distribution.
## * The name of the author may be used to endorse or promote products 
##   derived from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
## THE POSSIBILITY OF SUCH DAMAGE.

GLEW_DEST ?= /usr

GLEW_MAJOR = 1
GLEW_MINOR = 1
GLEW_MICRO = 3
GLEW_VERSION = $(GLEW_MAJOR).$(GLEW_MINOR).$(GLEW_MICRO)

TARDIR = ../glew-$(GLEW_VERSION)
TARBALL = ../glew_$(GLEW_VERSION).tar.gz

SHELL = /bin/sh
SYSTEM = $(strip $(shell uname -s))

# ----------------------------------------------------------------------------
# Cygwin
# ----------------------------------------------------------------------------
ifeq ($(patsubst CYGWIN%,CYGWIN,$(SYSTEM)), CYGWIN)
NAME = glew32
CC = gcc
LD = ld
CFLAGS.EXTRA = -mno-cygwin -DGLEW_STATIC
LDFLAGS.EXTRA = -shared -soname $(LIB.SONAME)
WARN = -Wall -W
BIN.SUFFIX = .exe

LIB.SONAME = lib$(NAME).so.$(GLEW_MAJOR)
LIB.DEVLNK = lib$(NAME).so
LIB.SHARED = lib$(NAME).so.$(GLEW_VERSION)
LIB.STATIC = lib$(NAME).a

GL_LDFLAGS = -lopengl32
GLU_LDFLAGS = -lglu32
GLUT_LDFLAGS = -lglut32 $(GLU_LDFLAGS) $(GL_LDFLAGS)

else
# ----------------------------------------------------------------------------
# Linux
# ----------------------------------------------------------------------------
ifeq ($(patsubst Linux%,Linux,$(SYSTEM)), Linux)
NAME = GLEW
CC = cc
LD = ld
CFLAGS.EXTRA = 
LDFLAGS.EXTRA = -shared -soname $(LIB.SONAME) -L/usr/X11R6/lib
NAME = GLEW
WARN = -Wall -W
BIN.SUFFIX =
LIB.SONAME = lib$(NAME).so.$(GLEW_MAJOR)
LIB.DEVLNK = lib$(NAME).so
LIB.SHARED = lib$(NAME).so.$(GLEW_VERSION)
LIB.STATIC = lib$(NAME).a

# Support broken systems which don't include proper inter-library
# dependency information (several versions of RedHat and SuSE among
# others).  Stuff needed by both GLUT and GL is included only in GL's
# LDFLAGS.  Same thnig for GLU and GL.  Include the stuff needed only by
# GLUT *before* the GL flags.  This probably breaks down on IRIX. (mem)

GL_LDFLAGS = -lGL -lXext -lX11
GLU_LDFLAGS = -lGLU
GLUT_LDFLAGS = -lglut -lXmu -lXi $(GLU_LDFLAGS) $(GL_LDFLAGS)

else
# ----------------------------------------------------------------------------
# Irix
# ----------------------------------------------------------------------------
ifeq ($(patsubst IRIX%,IRIX,$(SYSTEM)), IRIX)
NAME = GLEW
CC = cc
LD = ld
ABI = -64 # -n32
CFLAGS.EXTRA = -woff 1110,1498 $(ABI)
LDFLAGS.EXTRA = $(ABI) -shared -soname $(LIB.SONAME)
NAME = GLEW
WARN = -fullwarn
BIN.SUFFIX =

GL_LDFLAGS = -lGL -lXext -lX11
GLU_LDFLAGS = -lGLU
GLUT_LDFLAGS = -lglut -lXmu -lXi $(GLU_LDFLAGS) $(GL_LDFLAGS)
else
# ----------------------------------------------------------------------------
# Darwin
# ----------------------------------------------------------------------------
ifeq ($(patsubst Darwin%,Darwin,$(SYSTEM)), Darwin)
NAME = GLEW
CC = cc
LD = cc
CFLAGS.EXTRA = -I/usr/X11R6/include -I/sw/include -dynamic -fno-common
LDFLAGS.EXTRA = -dynamiclib -L/usr/X11R6/lib 
NAME = GLEW
BIN.SUFFIX =
WARN = -Wall -W
LIB.SONAME = lib$(NAME).$(GLEW_MAJOR).dylib
LIB.DEVLNK = lib$(NAME).dylib
LIB.SHARED = lib$(NAME).$(GLEW_VERSION).dylib
LIB.STATIC = lib$(NAME).a

GL_LDFLAGS = -lGL -lXext -lX11
GLU_LDFLAGS = -lGLU
GLUT_LDFLAGS = -L/sw/lib -lglut -lXmu -lXi $(GLU_LDFLAGS) $(GL_LDFLAGS)
else
# ----------------------------------------------------------------------------
$(error "Platform '$(SYSTEM)' not supported")
endif
endif
endif
endif

AR = ar
INSTALL = install
RM = rm -f
LN = ln -sf
ifeq ($(MAKECMDGOALS), debug)
OPT = -g
STRIP =
else
OPT = -O2
STRIP = -s
endif
INCLUDE = -Iinclude
CFLAGS = $(OPT) $(WARN) $(INCLUDE) $(CFLAGS.EXTRA)

LIB.SRCS = src/glew.c
LIB.OBJS = $(LIB.SRCS:.c=.o)
LIB.LDFLAGS = $(LDFLAGS.EXTRA)
LIB.LIBS = $(GL_LDFLAGS)

BIN = glewinfo$(BIN.SUFFIX)
BIN.SRCS = src/glewinfo.c
BIN.OBJS = $(BIN.SRCS:.c=.o)
BIN.LIBS = -Llib -l$(NAME) $(LDFLAGS.EXTRA) $(GLUT_LDFLAGS)

all: lib/$(LIB.SHARED) lib/$(LIB.STATIC) bin/$(BIN)

lib:
	mkdir lib

lib/$(LIB.STATIC): $(LIB.OBJS)
	$(AR) cr $@ $^

lib/$(LIB.SHARED): $(LIB.OBJS)
	$(LD) -o $@ $^ $(LIB.LDFLAGS) $(LIB.LIBS)
	$(LN) $(LIB.SHARED) lib/$(LIB.SONAME)
	$(LN) $(LIB.SHARED) lib/$(LIB.DEVLNK)

bin/$(BIN): $(BIN.SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(BIN.LIBS)

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

src/glew.o: src/glew.c include/GL/glew.h include/GL/wglew.h include/GL/glxew.h
	$(CC) $(CFLAGS) -o $@ -c $<

install: all
# directories
	$(INSTALL) -d -m 0755 $(GLEW_DEST)/bin
	$(INSTALL) -d -m 0755 $(GLEW_DEST)/include/GL
	$(INSTALL) -d -m 0755 $(GLEW_DEST)/lib
# runtime
	$(INSTALL) $(STRIP) -m 0644 lib/$(LIB.SHARED) $(GLEW_DEST)/lib/
	$(LN) $(LIB.SHARED) $(GLEW_DEST)/lib/$(LIB.SONAME)
# development files
	$(INSTALL) -m 0644 include/GL/wglew.h $(GLEW_DEST)/include/GL
	$(INSTALL) -m 0644 include/GL/glew.h $(GLEW_DEST)/include/GL
	$(INSTALL) -m 0644 include/GL/glxew.h $(GLEW_DEST)/include/GL
	$(INSTALL) $(STRIP) -m 0644 lib/$(LIB.STATIC) $(GLEW_DEST)/lib/
	$(LN) $(LIB.SHARED) $(GLEW_DEST)/lib/$(LIB.DEVLNK)
# utilities
	$(INSTALL) -s -m 0755 bin/$(BIN) $(GLEW_DEST)/bin/

uninstall:
	$(RM) $(GLEW_DEST)/include/GL/wglew.h
	$(RM) $(GLEW_DEST)/include/GL/glew.h
	$(RM) $(GLEW_DEST)/include/GL/glxew.h
	$(RM) $(GLEW_DEST)/lib/$(LIB.DEVLNK)
	$(RM) $(GLEW_DEST)/lib/$(LIB.SONAME)
	$(RM) $(GLEW_DEST)/lib/$(LIB.SHARED)
	$(RM) $(GLEW_DEST)/lib/$(LIB.STATIC)
	$(RM) $(GLEW_DEST)/bin/$(BIN)

clean:
	$(RM) $(LIB.OBJS)
	$(RM) lib/$(LIB.STATIC) lib/$(LIB.SHARED) lib/$(LIB.DEVLNK) lib/$(LIB.SONAME) $(LIB.STATIC)
	$(RM) $(BIN.OBJS) bin/$(BIN)
# Compiler droppings
	$(RM) so_locations

distclean: clean
	find -name \*~ | xargs $(RM)
	find -name .\*.sw\? | xargs $(RM)

tardist:
	$(RM) -r $(TARDIR)
	mkdir $(TARDIR)
	cp -a . $(TARDIR)
	find $(TARDIR) -name CVS -o -name .cvsignore | xargs $(RM) -r
	$(MAKE) -C $(TARDIR) distclean
	$(MAKE) -C $(TARDIR)
	$(MAKE) -C $(TARDIR) distclean
	$(RM) -r $(TARDIR)/auto/registry
	env GZIP=-9 tar -C `dirname $(TARDIR)` -cvzf $(TARBALL) `basename $(TARDIR)`

.PHONY: clean distclean tardist
