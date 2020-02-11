
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/llrs/BaseSet.svg?branch=master)](https://travis-ci.org/llrs/BaseSet)
[![Coverage
status](https://codecov.io/gh/llrs/BaseSet/branch/master/graph/badge.svg)](https://codecov.io/github/llrs/BaseSet?branch=master)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://badges.ropensci.org/359_status.svg)](https://github.com/ropensci/software-review/issues/359)
<!-- badges: end -->

# BaseSet

The goal of BaseSet is to facilitate working with sets in an efficient
way. The package implements methods to work on sets, doing intersection,
union, complementary, power sets, cartesian product and other set
operations in a tidy way. Both for classical and fuzzy sets. On fuzzy
sets, elements have a probability to belong to a set.

It also allows to import from several formats used in the life science
world. Like the GMT and the GAF or the [OBO
format](http://www.obofoundry.org/) file for ontologies.

You can save information about the elements, sets and their relationship
on the object itself. For instance origin of the set, categorical or
numeric data associated with sets…

Watch BaseSet working on the [examples](#Examples) below and in the
vignettes. You can also find [related packages](#related) and the
differences with BaseSet. If you have some questions or bugs [open an
issue](https://github.com/llrs/BaseSet/issues) (remember of the [Code of
Conduct](#CoC))

# Installation

Before installation you might need to install some of the suggested
packages from Bioconductor:

``` r
if (!require("BiocManager")) {
  install.packages("BiocManager")
  BiocManager::install(c("Biobase", "GO.db", "GSEABase", "org.HS.eg.db", 
                         "reactome.db", "BiocStyle"), type = "source")
}
```

You can install the latest version of BaseSet from
[Github](https://github.com/llrs/BaseSet) with:

``` r
BiocManager::install("llrs/BaseSet", 
                     dependencies = TRUE, build_vignettes = TRUE, force = TRUE)
```

# Examples

## Sets

We can create a set like this:

``` r
sets <- list(A = letters[1:5], B = c("a", "f"))
sets_analysis <- tidySet(sets)
sets_analysis
#>   elements sets fuzzy
#> 1        a    A     1
#> 2        a    B     1
#> 3        b    A     1
#> 4        c    A     1
#> 5        d    A     1
#> 6        e    A     1
#> 7        f    B     1
```

Perform typical operations like union, intersection. You can name the
resulting set or let the default name:

``` r
union(sets_analysis, sets = c("A", "B")) 
#>   elements sets fuzzy
#> 1        a  A∪B     1
#> 2        b  A∪B     1
#> 3        c  A∪B     1
#> 4        d  A∪B     1
#> 5        e  A∪B     1
#> 6        f  A∪B     1
# Or we can give a name to the new set
union(sets_analysis, sets = c("A", "B"), name = "D")
#>   elements sets fuzzy
#> 1        a    D     1
#> 2        b    D     1
#> 3        c    D     1
#> 4        d    D     1
#> 5        e    D     1
#> 6        f    D     1
# Or the intersection
intersection(sets_analysis, sets = c("A", "B"))
#>   elements sets fuzzy
#> 1        a  A∩B     1
# Keeping the other sets:
intersection(sets_analysis, sets = c("A", "B"), name = "D", keep = TRUE) 
#>   elements sets fuzzy
#> 1        a    A     1
#> 2        a    B     1
#> 3        a    D     1
#> 4        b    A     1
#> 5        c    A     1
#> 6        d    A     1
#> 7        e    A     1
#> 8        f    B     1
```

And compute size of sets among other things:

``` r
set_size(sets_analysis)
#>   sets size probability
#> 1    A    5           1
#> 2    B    2           1
```

The elements in one set not present in other:

``` r
subtract(sets_analysis, set_in = "A", not_in = "B", keep = FALSE)
#>   elements sets fuzzy
#> 1        b  A∖B     1
#> 2        c  A∖B     1
#> 3        d  A∖B     1
#> 4        e  A∖B     1
```

Or any other verb from
[dplyr](https://cran.r-project.org/package=dplyr). We can add columns,
filter, remove them and add information about the sets:

``` r
library("magrittr")
#> 
#> Attaching package: 'magrittr'
#> The following object is masked from 'package:BaseSet':
#> 
#>     subtract
set.seed(4673) # To make it reproducible in your machine
sets_enriched <- sets_analysis %>% 
  mutate(Keep = sample(c(TRUE, FALSE), 7, replace = TRUE)) %>% 
  filter(Keep == TRUE) %>% 
  select(-Keep) %>% 
  activate("sets") %>% 
  mutate(sets_origin = c("Reactome", "KEGG"))
sets_enriched
#>   elements sets fuzzy sets_origin
#> 1        a    A     1    Reactome
#> 2        a    B     1        KEGG
#> 3        b    A     1    Reactome
#> 4        c    A     1    Reactome
#> 5        d    A     1    Reactome
#> 6        f    B     1        KEGG

# Activating sets makes the verb affect only them:
elements(sets_enriched)
#>   elements
#> 1        a
#> 2        b
#> 3        c
#> 4        d
#> 5        f
relations(sets_enriched)
#>   elements sets fuzzy
#> 1        a    A     1
#> 2        a    B     1
#> 3        b    A     1
#> 4        c    A     1
#> 5        d    A     1
#> 6        f    B     1
sets(sets_enriched)
#>   sets sets_origin
#> 1    A    Reactome
#> 2    B        KEGG
```

## Fuzzy sets

In fuzzy sets the elements are related to a set by a probability (the
association is not guaranteed).

``` r
relations <- data.frame(sets = c(rep("A", 5), "B", "B"), 
                        elements = c("a", "b", "c", "d", "e", "a", "f"),
                        fuzzy = runif(7))
fuzzy_set <- tidySet(relations)
fuzzy_set
#>   elements sets     fuzzy
#> 1        a    A 0.1837246
#> 2        a    B 0.9381182
#> 3        b    A 0.4567009
#> 4        c    A 0.8152075
#> 5        d    A 0.5800610
#> 6        e    A 0.5724973
#> 7        f    B 0.9460158
```

The equivalent oprations are possible with the sets

``` r
union(fuzzy_set, sets = c("A", "B")) 
#>   elements sets     fuzzy
#> 1        a  A∪B 0.9381182
#> 2        b  A∪B 0.4567009
#> 3        c  A∪B 0.8152075
#> 4        d  A∪B 0.5800610
#> 5        e  A∪B 0.5724973
#> 6        f  A∪B 0.9460158
# Or we can give a name to the new set
union(fuzzy_set, sets = c("A", "B"), name = "D")
#>   elements sets     fuzzy
#> 1        a    D 0.9381182
#> 2        b    D 0.4567009
#> 3        c    D 0.8152075
#> 4        d    D 0.5800610
#> 5        e    D 0.5724973
#> 6        f    D 0.9460158
# Or the intersection
intersection(fuzzy_set, sets = c("A", "B"))
#>   elements sets     fuzzy
#> 1        a  A∩B 0.1837246
# Keeping the other sets:
intersection(fuzzy_set, sets = c("A", "B"), name = "D", keep = TRUE) 
#>   elements sets     fuzzy
#> 1        a    A 0.1837246
#> 2        a    B 0.9381182
#> 3        a    D 0.1837246
#> 4        b    A 0.4567009
#> 5        c    A 0.8152075
#> 6        d    A 0.5800610
#> 7        e    A 0.5724973
#> 8        f    B 0.9460158
```

With fuzzy sets, the number of elements or cardinality is a probability:

``` r
# A set could be empty
set_size(fuzzy_set)
#>   sets size probability
#> 1    A    0 0.014712455
#> 2    A    1 0.120607154
#> 3    A    2 0.318386944
#> 4    A    3 0.357078627
#> 5    A    4 0.166499731
#> 6    A    5 0.022715089
#> 7    B    0 0.003340637
#> 8    B    1 0.109184679
#> 9    B    2 0.887474684
# The more probable size of the sets:
set_size(fuzzy_set) %>% 
  group_by(sets) %>% 
  filter(probability == max(probability))
#> # A tibble: 2 x 3
#> # Groups:   sets [2]
#>   sets   size probability
#>   <chr> <dbl>       <dbl>
#> 1 A         3       0.357
#> 2 B         2       0.887
# Probability of belonging to several sets:
element_size(fuzzy_set)
#>    elements size probability
#> 1         a    0  0.05051256
#> 2         a    1  0.77713204
#> 3         a    2  0.17235540
#> 4         b    0  0.54329910
#> 5         b    1  0.45670090
#> 6         c    0  0.18479253
#> 7         c    1  0.81520747
#> 8         d    0  0.41993900
#> 9         d    1  0.58006100
#> 10        e    0  0.42750268
#> 11        e    1  0.57249732
#> 12        f    0  0.05398419
#> 13        f    1  0.94601581
```

With fuzzy sets we can filter at certain probability (called alpha cut):

``` r
fuzzy_set %>% 
  mutate(Keep = ifelse(fuzzy > 0.5, TRUE, FALSE)) %>% 
  filter(Keep == TRUE) %>% 
  select(-Keep) %>% 
  activate("sets") %>% 
  mutate(sets_origin = c("Reactome", "KEGG"))
#>   elements sets     fuzzy sets_origin
#> 1        a    B 0.9381182    Reactome
#> 2        f    B 0.9460158    Reactome
#> 3        c    A 0.8152075        KEGG
#> 4        d    A 0.5800610        KEGG
#> 5        e    A 0.5724973        KEGG
```

# Related packages

There are several other packages related to sets, which partially
overlap with BaseSet functionality:

  - [sets](https://CRAN.R-project.org/package=sets)  
    Implements a more generalized approach, that can store functions or
    lists as an element of a set (while BaseSet only allows to store a
    character or factor), but it is harder to operate in a tidy/long
    way. Also the operations of intersection and union need to happen
    between two different objects, while a single TidySet object (the
    class implemented in BaseSet) can store one or thousands of sets.

  - [GSEABase](https://bioconductor.org/packages/GSEABase)  
    Implements a class to store sets and related information, but it
    doesn’t allow to store fuzzy sets and it is also quite slow as it
    creates several classes for annotating each set.

  - [BiocSets](https://bioconductor.org/packages/BiocSets)  
    Implements a tidy class for sets but does not handle fuzzy sets. It
    also has less functionality to operate with sets, like power sets
    and cartesian product. BiocSets was influenced by the development of
    this
    package.

  - [hierarchicalSets](https://CRAN.R-project.org/package=hierarchicalSets)  
    This package is focused on clustering of sets that are inside other
    sets and visualizations. However, BaseSet is focused on storing and
    manipulate sets including hierarchical sets.

  - [set6](https://cran.r-project.org/package=set6) This package
    implements different classes for different type of sets including
    fuzzy sets, conditional sets. However, it doesn’t handle information
    associated to the elements or sets.

# Code of Conduct

Please note that the BaseSet project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
