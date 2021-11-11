#!/bin/bash

# run_igtree_lmap.sh
# Last modified: tor nov 11, 2021  05:28
# Sign: JN

set -eu -o pipefail

## Defaults
multiplier=50
model='TEST'
version='0.1'
iqtree='iqtree2'
quiet=0
iqtree2threads='AUTO'

## Check if iqtree2
command -v "${iqtree}" > /dev/null 2>&1 || { echo >&2 "Error: iqtree2 not found."; exit 1; }


## Usage function
function usage {
cat <<End_Of_Usage

$(basename "$0") version ${version}

What:
           Do likelihood mapping using iqtree2 and report fraction of
           highly supported quartets.

By:
           Johan Nylander

Usage:
           $(basename "$0") [-a 50][-n 10000][-m TEST][-p][-c 0.70][-d][-x][-v][-h] infile.fasta

Options:
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

Examples:
           $(basename "$0") infile.fasta
           $(basename "$0") -d -x infile.fasta
           $(basename "$0") -a 25 -c 0.80 -m 'GTR+G4' -x -q infile.fasta

Input:
            Fasta formatted sequence files (aligned, that is, all sequence entries
            should be of the same length).

Output:
            The name of the input file and the corresponding fraction of highly supported
            quartets are written to a .lmap.out file.
            The .lmap.quartetlh from iqtree2 will also be kept (other files from iqtree
            can be removed using -x).
            If the -c option is used, the file name of the files not matching the cutoff
            standard will be printed to stdout. This list can then be captured in downstream
            steps.

Notes:
            Program iqtree2 (www.iqtree.org) needs to be installed.
            For the theory behind likelihood mapping, see Strimmer and von
            Haeseler. Proc. Natl. Acad. Sci. USA Vol. 94, pp. 6815–6819, June 1997.


License:    Copyright (C) 2021 nylander <johan.nylander@nrm.se>
            Distributed under terms of the MIT license.

End_Of_Usage

}

## For comparing floating numbers
compare() (IFS=" "
  exec awk "BEGIN{if (!($*)) exit(1)}"
)

## Read arguments
aflag=
nflag=
mflag=
dflag=
cflag=
vflag=
xflag=
qflag=

while getopts 'a:n:m:c:dvhxq' OPTION
do
  case $OPTION in
  a) aflag=1
     aval="$OPTARG"
     ;;
  n) nflag=1
     nval="$OPTARG"
     ;;
  m) mflag=1
     mval="$OPTARG"
     ;;
  c) cflag=1
     cval="$OPTARG"
     ;;
  d) dflag=1
     ;;
  v) vflag=1
     ;;
  x) xflag=1
     ;;
  q) qflag=1
     quiet=1
     ;;
  h) usage
     exit
     ;;
  *) usage
     exit
     ;;
  esac
done
shift $((OPTIND - 1))

## Check if args
if [ $# -eq 0 ] ; then
    usage
    exit
else
  infile="$1"
fi

if [ "${vflag}" ] ; then
  echo "${version}"
  exit
fi

if [ "${aflag}" ] ; then
  multiplier="${aval}"
fi

if [ "${mflag}" ] ; then
  model="${mval}"
fi

if [ "${nflag}" ] ; then
  nquartets="${nval}"
else
  nseq=$(grep -c '>' "${infile}")
  nquartets=$((nseq*multiplier))
fi

## Put remaining args in files
#FILES="$*"
#echo "files to read: $FILES"
#for file in $FILES ; do
#done

if [ "${quiet}" == 0 ] ; then
  echo "" 1>&2
  echo "Run likelihood mapping of $nquartets quartets for file $infile" 1>&2
fi

## Run igtree2
"${iqtree}" \
  -s "${infile}" \
  -lmap "${nquartets}" \
  -wql \
  -n 0 \
  -T "${iqtree2threads}" \
  -m "${model}" > /dev/null 2>&1

## Parse .lmap.quartetlh or not
if [ "${dflag}" ] ; then
  if [ -e "${infile}.lmap.quartetlh" ] ; then
    if [ "${quiet}" == 0 ] ; then
      echo "Likelihood mappings are in file ${infile}.lmap.quartetlh" 1>&2
    fi
  else
    echo "Error: could not find file ${infile}.lmap.quartetlh" 1>&2
    exit 1
  fi
else
  val=$(awk 'BEGIN{i=0}!/SeqIDs/{i=i+1;if($8==1||$8==2||$8==3)a=a+1}END{print a/i}' "${infile}.lmap.quartetlh")
  if [ "${cflag}" ] ; then
    echo -e "${infile}\t${val}" > "${infile}".lmap.out
    if compare "${val} < ${cval}" ; then
      echo -e "${infile}"
    fi
  else
    echo -e "${infile}\t${val}" | tee "${infile}".lmap.out
  fi
fi

if [ -e "${infile}.lmap.out" ] ; then
  if [ "${quiet}"  == 0 ] ; then
    echo "Wrote file ${infile}.lmap.out" 1>&2
  fi
fi

if [ "${xflag}" ] ; then
  for suff in .ckp.gz .lmap.eps .lmap.svg .log .treefile .iqtree .model.gz ; do
    if [ -e "${infile}${suff}" ] ; then
      rm "${infile}${suff}"
    fi
  done
fi

exit

