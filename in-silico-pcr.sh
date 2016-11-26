#!/bin/sh
#
#  in-silico-pcr.sh - Simple in silico PCR using Bash and BLAST
#  Copyright (C) 2016  Marco van Zwetselaar <io@zwets.it>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  Part of https://github.com/zwets/blast-galley

# Defaults

BLAST_DB=nt
MAX_LEN=3000
MAX_MIS=2

# Function to emit information to standard error if VERBOSE is set
emit() {
    [ -z "$VERBOSE" ] || echo "$(basename "$0"): $*" >&2
}

# Function to exit this script with an error message on stderr
err_exit() {
    echo "$(basename "$0"): $*" >&2
    exit 1
}

# Function to clean up files if keep is set
clean_up() {
    if [ -z "$KEEP" ]; then
        emit "cleaning up, removing: $@"
        rm -f "$@"
    else
        emit "keeping intermediate file(s): $@"
    fi
}

# Function to show usage information and exit
usage_exit() {
    echo "
Usage: $(basename $0) [OPTIONS] FILE

  Perform an in silico PCR for the primer pair in FILE.
  
  FILE must be FASTA format with one line for the forward primer in 5' to 3'
  direction, and one line for the reverse primer in 5' to 3' direction.  Both
  lines must be preceded by a comment line starting with '>'.

  Options
   -m|--mismatches N  Mismatch count allowed per primer (default: $MAX_MIS)
   -l|--length L      Maximum allowed segment length (default: $MAX_LEN)
   -d|--database DB   Blast against database DB (default: $BLAST_DB)
   -k|--keep          Keep and reuse intermediate files
   -v|--verbose       Emit progress messages to standard error
"
    exit ${1:-1}
}

# Parse options

unset VERBOSE KEEP

while [ $# -ne 0 -a "$(expr "$1" : '\(.[0-9]*\).*')" = "-" ]; do
    case $1 in
    -m|--mismatches)
        shift
        MAX_MIS=$1
        ;;
    --mismatches=*)
        MAX_MIS="${1#--mismatches=}"
        ;;
    -l|--length)
        shift
        MAX_LEN=$1
        ;;
    --length=*)
        MAX_LEN="${1#--length=}"
        ;;
    -d|-db|--db)
        shift
        BLAST_DB=$1
        ;;
    -k|--keep)
        KEEP=1
        ;;
    -v|--verbose)
        VERBOSE=1
        ;;
    -h|--help)
        usage_exit 0
        ;;
    *) usage_exit
        ;;
    esac
    shift
done

# Check the argument

[ $# -eq 1 ] || usage_exit

PRIMERS_FILE="$1"
[ -r "$PRIMERS_FILE" ] || err_exit "cannot read file: $PRIMERS_FILE"
[ $(grep -v '^>' "$PRIMERS_FILE" | grep -v '^$' | wc -l) -eq 2 ] || err_exit "file must have two primers: $PRIMERS_FILE"

# Set up variables

FWD_PRIMER="${PRIMERS_FILE}.fwd.fna"
REV_PRIMER="${PRIMERS_FILE}.rev.fna"
FWD_BLAST="${PRIMERS_FILE}.fwd.blast.csv"
FWD_GILIST="${PRIMERS_FILE}.fwd.gilist"
REV_BLAST="${PRIMERS_FILE}.rev.blast.csv"
BLAST_OUTFMT="7 sgi sstrand sstart send qlen length nident mismatch sseqid staxids sscinames slen stitle"

# Do the work

emit "Extract the forward primer: $FWD_PRIMER"
[ -n "$KEEP" -a -r "$FWD_PRIMER" ] || grep -v '^>' "$PRIMERS_FILE" | grep -v '^$' | head -n 1 > "$FWD_PRIMER"

emit "Extract the reverse primer: $REV_PRIMER"
[ -n "$KEEP" -a -r "$REV_PRIMER" ] || grep -v '^>' "$PRIMERS_FILE" | grep -v '^$' | tail -n 1 > "$REV_PRIMER"

emit "BLAST the forward primer against database '$BLAST_DB': $FWD_BLAST"
[ -n "$KEEP" -a -r "$FWD_BLAST" ] || if ! blastn -task blastn-short -db "$BLAST_DB" -query "$FWD_PRIMER" -ungapped -outfmt "$BLAST_OUTFMT" | grep -v '^#' > "$FWD_BLAST"; then
    clean_up "$FWD_PRIMER" "$REV_PRIMER" "$FWD_BLAST"
    err_exit "BLAST of forward primer against database $BLAST_DB failed"
fi

clean_up "$FWD_PRIMER"

emit "Extract the GI list: $FWD_GILIST"
[ -n "$KEEP" -a -r "$FWD_GILIST" ] || awk -F '\t' '{print $1}' "$FWD_BLAST" > "$FWD_GILIST"

emit "BLAST the reverse primer against the sequences from the forward primer blast"
[ -n "$KEEP" -a -r "$REV_BLAST" ] || if ! blastn -task blastn-short -db "$BLAST_DB" -query "$REV_PRIMER" -gilist "$FWD_GILIST" -ungapped -outfmt "$BLAST_OUTFMT" | grep -v '^#' > "$REV_BLAST"; then
    clean_up "$FWD_PRIMER" "$REV_PRIMER" "$FWD_GILIST" "$FWD_BLAST" "$REV_BLAST"
    err_exit "BLAST of reverse primer against database $BLAST_DB failed"
fi

clean_up "$FWD_GILIST" "$REV_PRIMER"

emit "Join the two BLAST results"
awk -b -O -F '\t' -v FWD_BLAST_CSV="$FWD_BLAST" -v MAX_LEN=$MAX_LEN -v MAX_MIS=$MAX_MIS '
BEGIN {
    OFS=FS                              # Tab-separated output
    while (getline <FWD_BLAST_CSV == 1) {
        if ($7 + MAX_MIS >= $5) {	# Filter on mismatch limit ($7 is identical count, $5 is query length)
            fwd[$1][1] = ""		# Tell awk this is a subarray, see awk(1)
            split($0,fwd[$1])
        }
    }
    close(FWD_BLAST_CSV)
    print "gi", "seq_id", "length", "strand", "start", "end", "mm_fwd", "mm_rev", "tax_id", "sci_name", "seq_len", "seq_title"
}
# For every line with at most MAX_MIS mismatches
$7 + MAX_MIS >= $5 {
    if (fwd[$1][1] == $1 && $2 != fwd[$1][2]) { 	# check that primers found on opposite strands
        # Length always difference of starting positions; start is lowest on plus, highest on minus (else do not meet)
        spos = $2 == "minus" ? fwd[$1][3] : $3		# start position is the start on the plus strand
        epos = $2 == "minus" ? $3 : fwd[$1][3]		# end position is the start on the minus strand
        len = 1 + epos - spos
        # Select if length not negative (PCR will not meet), and within length limit
        if (len > 0 && len <= MAX_LEN) {
            print $1, $9, len, fwd[$1][2], spos, epos, fwd[$1][5] - fwd[$1][7], $5 - $7, $10, $11, $12, $13
        }
    }
}
' "$REV_BLAST"

clean_up "$FWD_BLAST" "$REV_BLAST"

# vim: sts=4:sw=4:ai:si:et:
