# blast-galley

_Precooked BLAST-related recipes, scripts and utilities_


## Introduction

In the [blast-galley](https://github.com/zwets/blast-galley),
[I](http://io.zwets.it/) collect a mishmash of scripts and utilities
for easy digestion of the
[NCBI Blast+ suite](http://www.ncbi.nlm.nih.gov/books/NBK1763/).

These tools were developed for my own use, but I've tried to make them
self-contained (all have `--help`) so they may be of use to others.


## zblast

`zblast` is a very thin wrapper around the blast command.  I use it because
I keep forgetting the options that do what I want, while `blastn -help` is
an oxymoron.  For that same reason I maintain a
[Blast+ commmand-line reference](http://io.zwets.it/blast-cmdline-ref)

```bash
$ zblast "ATGAGCAT"         # default blast query against `nt` for given sequence
$ zblast queries.fasta      # same but reading subject(s) from file queries.fasta
$ echo "ATGAGCAT" | zblast  # same but reading subject from stdin
$ zblast -b "-perc_identity 99 -evalue 0.01"  ...  # pass options to blast
```


## blastdb-get

`blastdb-get` retrieves sequences or metadata from a BLAST database, using
sequence identifiers such as accession to identify the entry.

```bash
$ blastdb-get 'X74108.1'
>gi|395160|emb|X74108.1| V.cholerae gene for heat-stable enterotoxin, partial
TTATTATTTTCTTCAATCGCATTTAGCCAAACAGTAGAAAACAATACAAAAACAGTGCAGCAACCACAACAAATTGAAAG
CAAGGTAAATATTAAAAAACTAAGTGAAAATGAAGAATGCCCATTTATAAAACAAGTCGATGAAAATGGAAATCTCATTG
```

It can return either FASTA sequences, or tabular data about the sequences.

```bash
$ blastdb-get --table "aTs" EU545988.1 JF260983.1
EU545988.1      Zika virus      10272   ATGAAAAACCCCAAAGAAGAAATCCGGAGGATCC...
JF260983.1      Dengue virus    10176   ATGAATAACCAACGGAAAAAGGCGAGAAACACGC...
```


## blastdb-find

Whereas `blastdb-get` retrieves sequences by identifier only, `blastdb-find`
can also grep through sequence titles or select by taxonomy ID.  By default
it returns a list, but it can also produce the sequences in FASTA format.

```bash
$ blastdb-find -t 64320 -t 12637 'polyprotein .*complete cds'
gb|EU545988.1|  EU545988.1      64320   10272   Zika virus polyprotein gene, complete cds
gb|DQ859059.1|  DQ859059.1      64320   10254   Zika virus strain MR 766 polyprotein gene, complete cds
gb|JF260983.1|  JF260983.1      12637   10176   Dengue virus strain EEB-17 polyprotein gene, complete cds
```

`blastdb-find` can do a superset of what `blastdb-get` can do, but it needs
to maintain a cache of metadata per BLAST database.  For 'key-based' queries,
`blastdb-get` is generally faster, simpler, and more configurable.


## gene-cutter

`gene-cutter` solves the problem of excising from one or more sequences the
segment(s) which match a given template, such as a known gene sequence.  It
is assumed that the sequences are assembled genomes, ideally consisting of
as few contigs as possible.

@@TODO@@ extend the script so it can detect segments broken across contigs.
This should be doable by lowering the query coverage threshold, and finding
subjects whose start or end is overlapped by the query.

Note: possibly better ways to 'excise' a gene are (a) mapping reads on the
template, and (b) processing the reads/assembly using annotation pipeline.
This script uses only the BLAST command-line utilities (plus the usual
suspects on any GNU system: bash, sed, tr, awk, etc).

The script is self-contained, use `-h|--help` for documentation.


## in-silico-pcr

`in-silico-pcr.sh` is a bash script which tests pairs of PCR primers against a
local BLAST database and returns the fragments selected by the primers.

The online in-silico PCR services at [EHU](http://insilico.ehu.es/PCR/index.php)
and [NCBI](http://www.ncbi.nlm.nih.gov/tools/primer-blast/) do the same thing
and probably do it better and faster.

The script is self-contained; the usual `-h|--help` gives documentation.


## taxo

`taxo` is a command line utility to search or browse a local copy of the
NCBI taxonomy database.  `taxo` has moved to <https://github.com/zwets/taxo>.


## Miscellaneous

### Why the name "blast-galley"?

Because it has a nice piratey ring.  Pirates must be [revered](http://sparrowism.soc.srcf.net/home/pirates.html)
for the [well-established fact](http://www.forbes.com/sites/erikaandersen/2012/03/23/true-fact-the-lack-of-pirates-is-causing-global-warming)
that their presence [attenuates global warming](http://www.venganza.org/about/open-letter/).

### License

blast-galley - pre-cooked BLAST for easier digestion
Copyright (C) 2016  Marco van Zwetselaar

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

