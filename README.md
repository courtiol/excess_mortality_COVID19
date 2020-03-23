
# COVID19

<!-- badges: start -->
<!-- badges: end -->

The goal of this small R project is to plot the COVID19 attributed deaths adjusted for baseline mortality and population size.

### Why?

Because most people don't know if 100 deaths caused by something is a lot or not.

### How?

Here I express the number of _reported_ COVID19 deaths compared to 100 "normal" deaths.

So for example, a value of 50 would imply that if 100 normal deaths used to occur in a city, then we would observe 150 deaths in total (100 normal + 50 COVID19 ones) assuming that normal deaths have not changed.

### Caveats

Some countries (including Italy) seem to underreport death by COVID19 because for many deaths occurying outside hospitals the exact cause of death is not known. (We will be able to look at that when overall death rates will be known.)

### Open questions

- Does it make sense to correct for the baseline mortality in each countries (current approach) versus to a common baseline?

To some degree _Yes_, as it reflect the overall health situation in a country... but only to some degrees.



