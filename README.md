## RB: R package to search for records and download images from the RB (Jardim Botânico do Rio de Janeiro) herbarium

### Installation:

RB is not on CRAN, so please install it from github:

```r
# Install devtools
install.packages("devtools")

# Install finch (YOU MUST INSTALL THE VERSION FROM GITHUB IF USING R ON WINDOWS!)
devtools::install_github("ropensci/finch")

# Install RB:
devtools::install_github("gustavobio/RB")
```

### Usage:

RB tools have three main usage scenarios:

  1. Searching for records in the RB database.
  2. Navigating images.
  3. Downloading images.
  
#### 1. Searching for records

The main function here is `search_rb`. When you call it for the first time 
the package will try to download the DWCA dataset provided by the Jardim Botânico
do Rio de Janeiro. This dataset is a little over 100M, so it may take a while. Memory usage 
is also high and will likely impact performance in computers with lower specs:

```r
> library(RB)
> miconias <- search_rb("Miconia albicans")
trying URL 'http://ipt.jbrj.gov.br/jbrj/archive.do?r=jbrj_rb&v=84.108'
downloaded 102.9 MB

Read 691354 rows and 45 (of 45) columns from 0.352 GB file in 00:00:13
Read 625625 rows and 7 (of 7) columns from 0.153 GB file in 00:00:08
153 GB file in 00:00:08
```

This call to `search_rb` returns a data frame with 477 rows and 45 columns, including scientific name, family,
collector, collector notes, dates, determiner, county, state, and so on:

```r
> str(miconias)
'data.frame':	477 obs. of  45 variables:
 $ id                      : chr  "urn:catalog:JBRJ:RB:741399" "urn:catalog:JBRJ:RB:1045255" "urn:catalog:JBRJ:RB:1045306" "urn:catalog:JBRJ:RB:1045294" ...
 $ type                    : chr  "Collection" "Collection" "Collection" "Collection" ...
 $ modified                : chr  "2014-07-08 00:45:06.721283" "2015-11-30 17:52:29.673752" "2015-11-30 17:52:57.868959" "2015-11-30 19:04:47.934176" ...
 $ rightsHolder            : chr  "" "RB" "RB" "RB" ...
 $ institutionCode         : chr  "RB" "RB" "RB" "RB" ...
 $ collectionCode          : chr  "" "RB" "RB" "RB" ...
 $ basisOfRecord           : chr  "PreservedSpecimen" "PreservedSpecimen" "PreservedSpecimen" "PreservedSpecimen" ...
 $ occurrenceID            : chr  "urn:catalog:JBRJ:RB:741399" "urn:catalog:JBRJ:RB:1045255" "urn:catalog:JBRJ:RB:1045306" "urn:catalog:JBRJ:RB:1045294" ...
 $ catalogNumber           : chr  "RB00741399" "RB01045255" "RB01045306" "RB01045294" ...
 $ recordNumber            : chr  "431" "488" "551" "538" ...
 $ recordedBy              : chr  "N.L. Britton; H.H. Rusby" "P. Rosa; T.S.Pereira; A. Pintor & JF.A. Baumgratz" "P. Rosa; T.S.Pereira; A. Pintor & JF.A. Baumgratz" "P. Rosa; T.S.Pereira; A. Pintor & JF.A. Baumgratz" ...
...
```

The first argument in `search_rb` is a scientific name. Please see the helpfile (`?search_rb`) for a list of all possible arguments. You can combine them to refine your search:

```r
# By scientific name and year
> miconias_2015 <- search_rb("Miconia albicans", year = 2015)
> dim(miconias_2015)
[1] 13 45
```

```r
# By genus and county
> miconias_itirapina <- search_rb(genus = "Miconia", county = "Itirapina")
> dim(miconias_itirapina)
[1] 24 45
```

```r
# By scientific name and collector
> myrcias_van <- search_rb("Myrcia guianensis", collector = "Staggemeier")
> dim(myrcias_van)
[1]  3 45
```

There are several combinations possible. Please consult the help files for all arguments.

#### 2. Navigating images

You can also open images in the default browser using `open_rb_images` and passing the results from `search_rb`:

```r
> open_rb_images(myrcias_van)
```
<img width="400" alt="screen shot 2017-06-30 at 17 24 22" src="https://user-images.githubusercontent.com/30267/27752751-06fd4da4-5db9-11e7-897b-1b3cc933cf4d.png">


This will open all images in your browser in new tabs. The maximum number of images is given by the argument `max`, which defaults to 5.

```r
> open_rb_images(myrcias_van, max = 15)
```

You can also tweak image resolution using the argument `width` (the default width in pixels is 600):

```r
> open_rb_images(myrcias_van, width = 3000)
```

If you are just browsing images (for instance, to check plant characteristics) you can do the search directly in `open_rb_images`:

```r
> open_rb_images(scientific_name = "Miconia albicans")
``` 

This will open the first 5 images in the database. If you want random 5, use the argument `random`:

```r
> open_rb_images(scientific_name = "Miconia albicans", random = TRUE, width = 3000) # files here will be large
```

#### 3. Downloading images

Images can also be downloaded and stored locally, in folders in your current path. See `getwd()` if you don't know where this is. You can change this with `setwd()`.

```r
> getwd()
[1] "/Users/gustavo"
```

The function `download_rb_images` is the workhorse here. For instance, you can download images from a previous search:

```r
> download_rb_images(myrcias_van)
3 images found. Continue? (y/n): y
  |===================================================================| 100%
> 
``` 

This call downloads images in the default resolution (in this case, width = 3000) to a local dir:

<img width="400" alt="screen shot 2017-06-30 at 17 11 16" src="https://user-images.githubusercontent.com/30267/27752423-4b3a4d20-5db7-11e7-97f1-1b542016de55.png">

Please beware that if your search yields several results, downloading all images can impact RB servers. Use discretion here. You could, for instance,
download all images for a given family:

```r
> download_rb_images(family = "Melastomataceae")
26890 images found. Continue? (y/n): y

Downloading 26890 images to /Users/gustavo/RB_images__30_Jun_17_22_37/:
  |                                                                   |   0%
```

