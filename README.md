# blast-galley

_Precooked BLAST-related recipes, scripts and utilities_

[Io](http://io.zwets.it/)'s personal collection of small scripts and utilities
to make the [NCBI Blast+ suite](http://www.ncbi.nlm.nih.gov/books/NBK1763/) more
digestible for daily use.  Put here because they may be of use others.

## Cooked up in the blast-galley

### Taxo: search and browse the NCBI taxonomy

`taxo` is a small command-line utility to search trough a local copy of the NCBI
*taxdump* database.  Its main function is to translate between taxonomy IDs (**taxid**)
and scientific names, in batch or interactively.

In interactive mode, `taxo` is a command-line browser for the taxonomy hierarchy.
Using simple commands it allows you to navigate between nodes, and examine their
ancestors, siblings, children and descendants.

#### Non-interactive use

Searching on name or regular expression:

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

#### Interactive use

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

## Miscellaneous

### Useful links

* [Blast+ commmand-line reference](http://io.zwets.it/blast-cmdline-ref)

### Why the name "blast-galley"?

The galley is the kitchen on a ship.  Kitchens are for turning raw ingredients into digestible food.  
The juxtaposition of "blast" and "galley" has a nice piratey ring to it.  Pirates must be
[revered](http://sparrowism.soc.srcf.net/home/pirates.html) for the
[well-established fact](http://www.forbes.com/sites/erikaandersen/2012/03/23/true-fact-the-lack-of-pirates-is-causing-global-warming)
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

