# Likelihood mapping with iqtree2

- Last modified: fre nov 12, 2021  03:25
- Sign: Johan Nylander


## Description

Script for running likelihood mapping (Strimmer & von Haeseler, 1997) with
iqtree2 (Minh et al., 2020), and summarize the run as the fraction of highly
supported quartets for the data.

Reads a fasta-formatted input file (multiple sequence alignment) as input,
prints the fraction of "highly supportive" quartets as output (to file or
stout, or both).

## Installation

The script is written in bash, and requires `iqtree2` to be installed.
The full path to `iqtree2` can changed directly in the script (line 14) if needed.

In order to utilize all functionality of the provided `Makefile`, GNU make and
GNU parallel needs to be installed.

If `make` is installed, the script can be installed (in `/usr/local/bin`) by using

    $ make install

To install in another location, e.g., `$HOME/bin`, use

    $ make PREFIX=$HOME install


## Usage

    $ run_iqtree_lmap.sh [-a 50][-n 10000][-m TEST][-p][-c 0.70][-d][-x][-v][-h] infile.fasta


### Example

Run likelihood mapping while automatically setting number of quartets, use
automatic model selection, and report the fraction of "supported" quartets for
the input file (fasta formatted multiple-sequence alignment):

    $ ./run_iqtree_lmap.sh data/infile.fasta

In this case, the result is printed to file `data/infile.fasta.lmap.out` with
the following (tab-delimited) content:

    data/infile.fasta	0.66

Note that the script also keeps the other files that iqtree2 creates, unless
the `-x` option is used (see **Options**).


### Options

    -n number -- Specify the number of quartets to be sampled. Default
                 is using a multiplier on the number of sequences in the
                 infile.
    -a number -- Specify the multiplier to use for automatically set the
                 number of quartets sampled. The total number of quartets
                 are number of sequences times the multiplier.
                 Default multiplier is 50.
    -m model  -- Specify the model to use. Default is TEST.
    -c cutoff -- Specify a cutoff-level (0-1) for files to be reported.
                 If the fraction of supported quartets are below this value,
                 the file name is printed. Default is to print output for all
                 files.
    -d        -- Do not parse the output (the .lmap.quartetlh file).
    -x        -- Remove all iqtree2 output except the .lmap.quartetlh file.
                 Default is to keep all files.
    -q        -- Be quiet (noverbose)
    -v        -- Print version.
    -h        -- Print help message.


## Likelihood mapping run manually


### 1. Run iqtree2

    $ iqtree2 -s data/infile.fasta -lmap ALL -wql -n 0 -m TEST

The `data/infile.fasta.lmap.quartetlh` file -- an example (first two lines):

    SeqIDs  lh1     lh2     lh3     weight1 weight2 weight3 area    corner
    (8,3,17,16)     -7456.47        -7532   -7522.94        1       0       0       1       1

- lh1 is the log-likelihood of the quartet tree {8,3} | {17,16}
- lh2 is the log-likelihood of the quartet tree {8,17} | {3,16}
- lh3 is the log-likelihood of the quartet tree {8,16} | {3,17}
- weight1 = exp(lh1) / (exp(lh1)+exp(lh2)+exp(lh3))
- weight2 = exp(lh2) / (exp(lh1)+exp(lh2)+exp(lh3))
- weight3 = exp(lh3) / (exp(lh1)+exp(lh2)+exp(lh3))
- (That means, they are the likelihood weights of the 3 quartets).


### 2. Parse the `.lmap.quartetlh` file to give proportion of well-supported quartets

That is, count the number of times a quartet ends up in any of the "corner"
areas 1, 2, or 3, over the total number of sampled quartets.

    $ awk 'BEGIN{i=0}!/SeqIDs/{i=i+1; if($8==1||$8==2||$8==3) a=a+1}END{print a/i}' data/infile.fasta.lmap.quartetlh


## Try also

If you have several fasta files and a multi-core computer, you may also try to
run the likelihood mapping in parallel (by utilizing the provided
[`Makefile`](Makefile) and `data` folder).

1. Make sure you have `iqtree2`, `make`, and `parallel` (GNU parallel)
   installed
2. Put your fasta-formatted alignments (files ending in `.fas`) in the `data`
   folder
4. Run

       $ make run > lmap.out &


## Links and further reading

- [Minh et al. 2020](https://academic.oup.com/mbe/article/37/5/1530/5721363)
- [Strimmer and von Haeseler 1997](doc/Strimmer_von_Haeseler_1997.pdf)
- [igtree2, www.iqtree.org](http://www.iqtree.org)
- [Likelihood-mapping in iqtree2, www.iqtree.org/doc/Command-Reference#likelihood-mapping-analysis](http://www.iqtree.org/doc/Command-Reference#likelihood-mapping-analysis)
- [Post on google groups, groups.google.com/g/iqtree/c/OcfgC0RF110](https://groups.google.com/g/iqtree/c/OcfgC0RF110)
- [GNU parallel, www.gnu.org/software/parallel](https://www.gnu.org/software/parallel/)
- [GNU make, www.gnu.org/software/make](https://www.gnu.org/software/make/)

