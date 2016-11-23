# blast-galley

_Precooked BLAST-related recipes, scripts and utilities_


## Introduction

In the [blast-galley](https://github.com/zwets/blast-galley), 
[I](http://io.zwets.it/) collect a mishmash of scripts and utilities
for easy digestion of the [NCBI Blast+ suite](http://www.ncbi.nlm.nih.gov/books/NBK1763/).

These tools were developed for my own use, but I've tried to make
them self-contained and well-documented (all have `--help`) so they can
be of use to others.


## zblast

`zblast` is a very thin wrapper around the blast command.  I use it because I keep
forgetting the options that do what I want, while `blastn -help` is an oxymoron.
For that same reason I maintain a [Blast+ commmand-line reference](http://io.zwets.it/blast-cmdline-ref)

```bash
$ zblast "ATGAGCAT"         # default blast query against `nt` for given sequence
$ zblast queries.fasta      # same but reading subject(s) from file queries.fasta
$ echo "ATGAGCAT" | zblast  # same but reading subject from stdin           
$ zblast -b "-perc_identity 99 -evalue 0.01"  ...  # pass options to blast
```

## zblast-retrieve

`zblast-retrieve` is my convenience wrapper to retrieve entries from a BLAST database
in various output formats.

Entries can be selected (`--entry`) on their accession number, the 'primary key' of
sequences since NCBI abolished 'gi' in Aug 2016, or on any other part of the sequence
identifier.  [Here](http://io.zwets.it/blast-cmdline-ref#database-management) are
the details.

Output by default are zero or more FASTA formatted sequences.  Option `--output`
selects tabular output of a number of selectable columns.

```bash
Usage: zblast-retrieve [OPTIONS] QUERY

  Retrieve sequences and/or their metadata from a BLAST database.

  This script wraps blastdbcmd with convenient default options and
  and easier way to specify the output format.  The default output
  are sequences in FASTA format.  Use the --output option to obtain
  selected columns of meta-data in tabular format.

  Options
   -d|--db DB        database (default: nt)
   -o|--output COLS  output columns (default: no columns, FASTA)
   -s|--sep CHAR     separator character (default: tab)
   -t|--header       prepend header (default: no)
   -v|--verbose      verbose output
   -h|--help         this help

  QUERY is a comma-separated search string of sequence identifiers.
  Use 'all' to retrieve all entries from the database. The QUERY is
  passed verbatim to blastdbcmd -entry.  See the reference at
  http://io.zwets.it/blast-cmdline-ref/#about-sequence-identifiers
  for a description of valid sequence identifiers.

  COLS defines the columns to output when instead of the default FASTA,
  tabular output is requested.  COLS must be a string composed of:
   a Accession | s bare sequence | l length  | t title
   o OID       | g GI            | P PIG     | m Masks (all)
   T TaxID     | L TaxName       | S SciName
```


## taxo

`taxo` is a command-line utility to search trough a local copy of the NCBI
*taxdump* database.  Its main function is to translate between taxonomy IDs (**taxid**)
and scientific names, either in batch or interactively.

In interactive mode, `taxo` is a command-line browser for the taxonomy hierarchy.
Using simple commands it allows you to navigate between nodes and examine their
ancestors, siblings, children and descendants.

Taxo is not fast, but it does the job.  It is a `bash` script which uses `grep`,
`sed` and `awk` against the plain `names.dmp` and `nodes.dmp` files from the
[NCBI taxdump archive](ftp://ftp.ncbi.nih.gov/pub/taxonomy).  @@TODO@@ A much optimised
version would first load the dmp-files in a lightweight in-memory database, then
perform the queries against that.

In case you wonder why I don't just use the [Taxonomy browser](http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Root)
or [Taxonomy Common Tree](http://www.ncbi.nlm.nih.gov/Taxonomy/CommonTree/wwwcmt.cgi)
at [NCBI Taxonomy](http://www.ncbi.nlm.nih.gov/guide/taxonomy/): [this](http://io.zwets.it/about)
may explain.  In my corner of the world, we have the Intermittentnet :-) 


#### Taxo non-interactive

Searching on taxonomic name or regular expression:

```bash
$ taxo Zika
64320   Zika virus
395648  Zikanapis
395833  Zikanapis clypeata
```

```bash
$ taxo '.*monas$'
85      Hyphomonas
226     Alteromonas
283     Comamonas
...	...
1677989 Palustrimonas
1701761 Thiobacimonas
1709445 Candidatus Heliomonas
```

Looking up on taxid:

```bash
$ taxo 286 666 
    286 genus        Pseudomonas
    666 species      Vibrio cholerae
```

Querying hierarchy for a species:

```bash
$ taxo -a 1280
 131567              cellular organisms
      2 superkingdom Bacteria
   1239 phylum       Firmicutes
  91061 class        Bacilli
   1385 order        Bacillales
  90964 family       Staphylococcaceae
   1279 genus        Staphylococcus
   1280 species      Staphylococcus aureus
```

#### Taxo interactive

```
$ ./taxo -i 644
Loading names ... OK.
Loading nodes ... OK.
    644 species      Aeromonas hydrophila

Command? help

Commands:
-                ENTER key displays current node ID, rank and name
- NUMBER         jump to node with taxid NUMBER
- /REGEX         search for nodes whose name matches left-anchored REGEX
- u(p)           move current node pointer to parent node
- p(arent)       show parent but do not move current node pointer there
- a(ncestors)    show lineage of current node all the way up to root
- s(iblings)     show all siblings of the current node
- c(hildren)     show all children of the current node
- D(escendants)  show all descendants of the current node
- q(uit) or ^D   leave

Command? u
    642 genus        Aeromonas

Command? u
  84642 family       Aeromonadaceae

Command? 1279
   1279 genus        Staphylococcus

Command? s
  45669 genus        Salinicoccus
 370802              environmental samples
 227979 genus        Jeotgalicoccus
1647178 genus        Aliicoccus
 489909 genus        Nosocomiicoccus
  69965 genus        Macrococcus
 111016              unclassified Staphylococcaceae
   1279 genus        Staphylococcus

Command? c
   1280 species      Staphylococcus aureus
   1281 species      Staphylococcus carnosus
   1282 species      Staphylococcus epidermidis
   ...    ...
```

## in-silico-pcr

`in-silico-pcr.sh` is a bash script which tests pairs of PCR primers against a
local BLAST database and returns the fragments selected by the primers.

The online in-silico PCR services at [EHU](http://insilico.ehu.es/PCR/index.php)
and [NCBI](http://www.ncbi.nlm.nih.gov/tools/primer-blast/) do the same thing 
and probably do it better and faster.

The script is self-contained; the usual `-h|--help` gives documentation.


## Miscellaneous

### Why the name "blast-galley"?

Because it has a nice piratey ring to it.  Pirates must be [revered](http://sparrowism.soc.srcf.net/home/pirates.html)
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

