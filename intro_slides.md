---
title       : Introduction to Data Analysis with R
subtitle    : UCI Data Science Initiative
author      : Sepehr Akhavan, Homer Strong, Christine Lee
job         : Dept. of Statistics
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : mathjax            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
github:
  user: UCIDataScienceInitiative
  repo: intro_data_analysis_R

---

## What is R?
+ a programming language
+ but also, an 'environment'
  + package manager, Comprehensive R Archive Network (CRAN)
  + command-line interface
  + builtin-graphics
+ ~20 years old
+ traditionally academic, increasingly industrial
+ free and open source!

---

## vs. other languages

+ Most similar to python and matlab
  + vs. matlab: R is free
  + vs. python (+numpy, scipy, etc): R is already specialized
+ moved from 30th most popular programming language to 20th in the last year [1]
+ most other languages (java, C, JavaScript, ...) arguably not well suited to interactive data analysis

[1] http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html

---

## R is probably best when...
+ want to use research-grade statistical methods
+ dynamic/generated reports or paper
+ pubication-quality graphics (ggplot2, visualization)
+ create interactive dashboards (shiny)
+ exploratory analysis
  + filtering
  + aggregation

---

## Downsides to R
+ large installation
+ not good for "backend" programming or long-running services
+ difficulties when data does not fit in-memory
+ namespacing makes large programs difficult to organize
+ learning curve
+ not terribly fast
  + largely written by academic statisticians

---
## R vs. Excel

+ reproducing work
+ troubleshooting
+ sharing work
+ organizing project
+ flexability

---
## Summary: why use R?
+ free, open source
+ many high-quality, cutting edge tools
+ covers many data analysis use cases



## Session 5 - Agenda

+ Goal: use ggplot2 to explore data afterwards
+ Emphasize simple examples
+ Emphasize principles
+ Some examples will be developed today
+ ... but there's a lot that won't be covered
+ Base plotting system

---

### Information Visualization

+ Efficiency
+ Interpretability
+ Parsimony
+ ggplot2 lies in "sweet spot" of functionality

---

### Hello, ggplot2

+ ggplot2 is a very popular graphics system written by Hadley Wickham
+ implementation of Leland Wilkinson' Grammar of Graphics
+ I'll use the `diamonds` dataset for most of the examples.


```r
head(diamonds)
```

```
## Error in head(diamonds): object 'diamonds' not found
```

---

### First ggplot2: histogram

Let's make a histogram!


```r
ggplot(diamonds, aes(price)) + geom_histogram()
```

```
## Error in eval(expr, envir, enclos): could not find function "ggplot"
```


---

### Gotchas

Easy to run into unhelpful errors


```r
library(ggplot2)
ggplot(airquality) # :(
```

```
## Error: No layers in plot
```

```r
ggplot(airquality, aes(temp)) # :'''(
```

```
## Error: No layers in plot
```

---

### Now make it fancier

Group diamonds by cut.


```r
m <- ggplot(diamonds, aes(price))
m + geom_histogram(aes(fill=cut))
```

```
## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
```

![plot of chunk unnamed-chunk-4](assets/fig/unnamed-chunk-4-1.png) 

---

### Facets are an alternative

Group diamonds by cut.


```r
m <- ggplot(diamonds, aes(price))
m + geom_histogram(binwidth=100) + facet_grid(cut~color)
```

![plot of chunk unnamed-chunk-5](assets/fig/unnamed-chunk-5-1.png) 


---
### Let's pause for a moment

+ what's up with `aes`?
+ `aes(x, y, ...)`
+ allows functions of columns e.g. `aes(x=price^2)`, `aes(x=price/carat)`
+ what are layers?

```
m <- ggplot(diamonds, aes(price))
m + geom_histogram(aes(fill=cut))
```

+ note that plots can be built up _incrementally_
+ "Geoms, short for geometric objects, describe the type of plot you will produce."
+ geom names always begin with `geom_`

---
### Scatterplots

Note: There's no "scatterplot" function. Use `geom_point`.


```r
ggplot(diamonds, aes(price, carat)) + geom_point()
```

![plot of chunk unnamed-chunk-6](assets/fig/unnamed-chunk-6-1.png) 

---
### Log scales



```r
ggplot(diamonds, aes(price, carat)) + geom_point() + scale_x_log10()
```

![plot of chunk unnamed-chunk-7](assets/fig/unnamed-chunk-7-1.png) 

Scales begin with `scale_`, and are not only for continuous variables: also `datetime`, `shape`, `colour`, etc

---
### Adding factors

Similar to histogram


```r
ggplot(diamonds, aes(price, carat)) + geom_point(aes(colour=color, shape=cut))
```

![plot of chunk unnamed-chunk-8](assets/fig/unnamed-chunk-8-1.png) 

Note the legend for each mapping!

---
### Overview of components

+ `geom_*` : Geoms, short for geometric objects, describe the type of plot you will produce.
+ `stat_*`: Statistical transformations transform your data before plotting
+ `scale_*`: Scales control the mapping between data and aesthetics.
+ `facet_*`: Facets display subsets of the dataset in different panels.
+ `coord_*`: Coordinate systems adjust the mapping from coordinates to the 2d plane of the computer screen.

And a few others...

---
### Problem: overplotting, approach 1a
Try lowering opacity


```r
ggplot(diamonds, aes(price, carat)) + geom_point(alpha=0.1)
```

![plot of chunk unnamed-chunk-9](assets/fig/unnamed-chunk-9-1.png) 


---
### Problem: overplotting, approach 1b

Try mapping the inverse of a variable to opacity.


```r
ggplot(diamonds, aes(price, carat)) + geom_point(aes(alpha=1/carat))
```

![plot of chunk unnamed-chunk-10](assets/fig/unnamed-chunk-10-1.png) 


---
### Problem: overplotting, approach 2

Shake the points around a little bit.


```r
ggplot(diamonds, aes(price, carat)) + geom_jitter()
```

![plot of chunk unnamed-chunk-11](assets/fig/unnamed-chunk-11-1.png) 


---
### Problem: overplotting, approach 3

Bin into hexagons!


```r
library(hexbin)
ggplot(diamonds, aes(price, carat)) + geom_hex()
```

![plot of chunk unnamed-chunk-12](assets/fig/unnamed-chunk-12-1.png) 


---
### Problem: overplotting, approach 4

Smooth with a 2d density


```r
ggplot(diamonds, aes(price, carat)) + stat_density2d()
```

![plot of chunk unnamed-chunk-13](assets/fig/unnamed-chunk-13-1.png) 


---
### Something completely different: map!



```r
library(maps)
states <- map_data("state")
ggplot(states) + geom_polygon(aes(x=long, y=lat, group = group), colour="white")
```

![plot of chunk unnamed-chunk-14](assets/fig/unnamed-chunk-14-1.png) 

---
### The world is your oyster



```r
ggplot(map_data("world")) + geom_polygon(aes(x=long, y=lat, group = group), colour="white")
```

![plot of chunk unnamed-chunk-15](assets/fig/unnamed-chunk-15-1.png) 

---
### What's the point?



```r
ucs <- data.frame(lat=c(37.870007, 33.64945), long=c(-122.270501, -117.845707))
m <- ggplot(map_data("state"), aes(x=long, y=lat)) + geom_polygon(aes(group=group))
m + geom_point(data=ucs, colour="red", size=5)
```

![plot of chunk unnamed-chunk-16](assets/fig/unnamed-chunk-16-1.png) 


---
### FYI

+ easy to add legend titles, axis labels, etc
+ `ggsave` function will save the plot to an image (or can just save via Rstudio)
+ `+ theme_bw()` will create a plot more suitable for printing
+ pie charts are possible but please do not make them
+ the `qplot` function is available as a more concise option
+ there are many packages that extend ggplot2's functionality!
+ e.g. `bdscale`, `GGally`, `xkcd`, `ggmap`
