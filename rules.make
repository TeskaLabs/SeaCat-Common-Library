# Optional include of site specific configuration
-include $(ROOTDIR)/rules.site

# Optional include of site specific configuration that is propagated from main module
ifdef TOPDIR
-include ${TOPDIR}/rules.site
endif

VERSION=$(shell git describe --abbrev=7 --tags --dirty --always)

ifndef RELEASE
CFLAGS+=-O0 -ggdb
else
CFLAGS+=-O2 -fno-strict-aliasing
endif

CFLAGS+=-Wall -std=c99 -static -pthread
CPPFLAGS+=-I $(ROOTDIR)/include
LDLIBS+=-Wall -lpthread

.PHONY: clean all test subdirs

# OpenSSL

OPENSSLINCPATH?=/usr/local/include
OPENSSLLIBPATH?=/usr/local/lib

CPPFLAGS+=-I${OPENSSLINCPATH}

ifdef OPENSSLDYNAMIC
LDLIBS+=-L${OPENSSLLIBPATH} -lssl -lcrypto
else
LDLIBS+=${OPENSSLLIBPATH}/libssl.a ${OPENSSLLIBPATH}/libcrypto.a
endif


# LibEv

EVINCPATH?=/usr/local/include
EVLIBPATH?=/usr/local/lib

CPPFLAGS+=-I${EVINCPATH}

ifdef EVDYNAMIC
LDLIBS+=-L${EVLIBPATH} -lev
else
LDLIBS+=${EVLIBPATH}/libev.a
endif


LDLIBS+=-lm


# Basic commands

subdirs:
	@$(foreach dir, $(SUBDIRS), $(MAKE) -C $(dir);)

clean:
	@echo " [RM] in" $(CURDIR)
	@$(RM) $(BIN) $(LIB) $(CLEAN) $(EXTRACLEAN) *.o
	@$(foreach dir, $(SUBDIRS) $(CLEANSUBDIRS), $(MAKE) -C $(dir) clean;)


# Compile command

.c.o:
	@echo " [CC]" $@
	@$(COMPILE.c) $(OUTPUT_OPTION) $<


# Link commands

${BIN}: ${OBJS}
	@echo " [LD]" $@
	@$(LINK.o) $^ ${UTOBJS} $(LOADLIBES) -ldl $(LDLIBS) -ldl -o $@
ifdef RELEASE
	@echo " [ST]" $@
	@strip $@
	@bash -c "if [[ `nm $@ | grep _ev_ | wc -l` -gt 0 ]] ; then \
		 echo \"Produced binary contains unwanted symbols!\"; \
		 exit 1; \
	fi"
endif

${LIB}: ${OBJS}
	@echo " [AR]" $@
	@$(AR) -cr $@ $^
