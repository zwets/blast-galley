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


## taxo

`taxo` is a command-line utility to search trough a local copy of the NCBI
*taxdump* database.  Its main function is to translate between taxonomy IDs (**taxid**)
and scientific names, either in batch or interactively.

In interactive mode, `taxo` is a command-line browser for the taxonomy hierarchy.
Using simple commands it allows you to navigate between nodes and examine their
ancestors, siblings, children and descendants.

Taxo is not fast, but it does the job.  It is a `bash` script which uses `grep`,
`sed` and `awk` against the plain `names.dmp` and `nodes.dmp` files from the
[NCBI taxdump archive](ftp://ftp.ncbi.nih.gov/pub/taxonomy).  i

@@TODO@@ A much optimised version first loads the dmp-files in a lightweight
in-memory database (sqlite?), then performs the queries against that.

In case you wonder why I don't just use the
[Taxonomy browser](http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Root)
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

Interactive `taxo` has the same functionality, with the added convenience
of being able to navigate a pointer up and down the tree, and examine
ancestors, siblings or descendants in each context.

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

