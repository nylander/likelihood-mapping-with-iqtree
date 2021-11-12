# Makefile
# Last modified: fre nov 12, 2021  02:00
# Sign: nylander

all:
	@echo "Use this Makefile for test, install, clean, or run"

run:
	@find ./data -name '*.fas' | parallel './run_iqtree_lmap.sh -x -q {}'

install:
	@cp -v run_iqtree_lmap.sh $$HOME/bin

test: test1 test2 test3 test4

test1:
	./run_iqtree_lmap.sh data/infile.fasta
	cat data/infile.fasta.lmap.out
	@make clean

test2:
	./run_iqtree_lmap.sh -a 25 -c 0.80 -m 'GTR+G4' -x data/infile.fasta
	cat data/infile.fasta.lmap.out
	@make clean

test3:
	./run_iqtree_lmap.sh -a 25 -c 0.60 -m 'GTR+G4' -x  data/infile.fasta
	cat data/infile.fasta.lmap.out
	@make clean

test4:
	./run_iqtree_lmap.sh -a 25 -c 0.80 -m 'GTR+G4' -x -q data/infile.fasta
	cat data/infile.fasta.lmap.out
	@make clean

test5:
	./run_iqtree_lmap.sh -a 25 -c 0.50 -m 'TEST' -x data/*.fas
	cat data/*.lmap.out
	@make clean

clean:
	@rm -fv data/*.iqtree
	@rm -fv data/*.lmap.eps
	@rm -fv data/*.lmap.out
	@rm -fv data/*.lmap.quartetlh
	@rm -fv data/*.lmap.svg
	@rm -fv data/*.log
	@rm -fv data/*.model.gz
	@rm -fv data/*.treefile
	@rm -fv data/*.ckp.gz

# vim:ft=make
#
