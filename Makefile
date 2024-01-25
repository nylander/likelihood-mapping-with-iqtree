# Makefile for run_iqtree_lmap.sh
# Last modified: tor jan 25, 2024  10:31
# Sign: nylander

PROG := run_iqtree_lmap.sh
PARALLEL := parallel
DATADIR := ./data
DATAFILE := infile.fasta

ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif

.PHONY: all help run install uninstall clean distclean test test1

all: help

help:
	@echo ""
	@echo "Makefile for run_iqtree_lmap.sh"
	@echo "Use this Makefile for install, test, clean, or run."
	@echo "Examples:"
	@echo ""
	@echo "  Install in /usr/local/bin:"
	@echo "    make install"
	@echo ""
	@echo "  Install in your \$$HOME/bin:"
	@echo "    make PREFIX=\$$HOME install"
	@echo ""
	@echo "  Uninstall:"
	@echo "    make uninstall"
	@echo ""
	@echo "  Put your *.fas file in the data folder and run:"
	@echo "    make run"
	@echo ""
	@echo "  Clean up extra run files from the data folder:"
	@echo "    make clean"
	@echo ""
	@echo "  Clean up all run files from the data folder:"
	@echo "    make distclean"
	@echo ""

run:
	@find $(DATADIR) -name '*.fas' | $(PARALLEL) '$(PROG) -x -q {}'

install: $(PROG)
	install $(PROG) $(DESTDIR)$(PREFIX)/bin

uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/$(PROG)

test: test1 clean

test1:
	@$(PROG) $(DATADIR)/$(DATAFILE)

clean:
	@rm -f $(DATADIR)/*.iqtree
	@rm -f $(DATADIR)/*.lmap.eps
	@rm -f $(DATADIR)/*.lmap.svg
	@rm -f $(DATADIR)/*.log
	@rm -f $(DATADIR)/*.model.gz
	@rm -f $(DATADIR)/*.treefile
	@rm -f $(DATADIR)/*.ckp.gz

distclean: clean
	@rm -f $(DATADIR)/*.lmap.out
	@rm -f $(DATADIR)/*.lmap.quartetlh

# vim:ft=make
#
