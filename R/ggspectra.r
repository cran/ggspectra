#' @details Package `ggspectra` provides a set of stats, geoms and methods
#' extending packages `ggplot2` and `photobiology`. They easy the task of
#' plotting radiation-related spectra and of annotating the resulting plots with
#' labels and summary quantities derived from the spectral data.
#'
#' Plot methods automate in many respects the plotting of spectral data.
#' 'ggplot2' compatible statistics make the addition of labels or plotting of
#' subject-area specific summaries possible as well as the addition of labels
#' and wvaelength-based colour to plots easy. Available summaries are most of
#' those relevant to photobiology. However, many of the functions in the package
#' are more generaly useful for plotting UV, VIS and NIR spectra of light
#' emission, transmittance, reflectance, absorptance, and responses.
#'
#' The available summary quantities are both simple statistical summaries and
#' response-weighted summaries. Simple derived quantities represent summaries of a
#' given range of wavelengths, and can be expressed either in energy or photon
#' based units. Derived biologically effective quantities are used to quantify
#' the effect of radiation on different organisms or processes within organisms.
#' These effects can range from damage to perception of informational light
#' signals. Additional features of spectra may be important and worthwhile
#' annotating in plots. Of these, local maxima (peaks) and minima (valleys)
#' present in spectral data can also be annotated with statistics made available
#' by the 'ggspectra' package.
#'
#' Package 'ggspectra' is useful solely for plotting spectral data as most
#' functions depend on the x aesthetic being mapped to a variable containing
#' wavelength values expressed in nanometres. It works well together with
#' some other extensions to package 'ggplot2' such as packages 'ggrepel' and
#' 'cowplot'.
#'
#' This package is part of a suite of R packages for photobiological
#' calculations described at the
#' [r4photobiology](https://www.r4photobiology.info) web site.
#'
#'
#' @references
#' Aphalo, Pedro J. (2015) The r4photobiology suite. UV4Plants Bulletin, 2015:1,
#' 21-29. \doi{10.19232/uv4pb.2015.1.14}.
#'
#' \code{ggplot2} web site at \url{https://ggplot2.tidyverse.org/}\cr
#' \code{ggplot2} source code at \url{https://github.com/tidyverse/ggplot2}\cr
#' Function \code{multiplot} from \url{http://www.cookbook-r.com/}
#'
#'
#' @import photobiology photobiologyWavebands ggplot2 ggrepel
#' @importFrom graphics plot
#' @importFrom ggplot2 ggplot autoplot
#' @importFrom rlang .data
#'
#' @note
#' This package makes use of the new features of 'ggplot2' >= 2.0.0 that make
#' writing this kind of extensions easy and is consequently not
#' compatible with earlier versions of 'ggplot2'.
#'
#' @examples
#'
#' library(photobiologyWavebands)
#'
#' ggplot(sun.spct) + geom_line() + stat_peaks(span = NULL)
#'
#' ggplot(sun.spct, aes(w.length, s.e.irrad)) + geom_line() +
#'   stat_peaks(span = 21, geom = "point", colour = "red") +
#'   stat_peaks(span = 51, geom = "text", colour = "red", vjust = -0.3,
#'              label.fmt = "%3.0f nm")
#'
#' ggplot(polyester.spct, range = UV()) + geom_line()
#'
#' plot(sun.spct)
#'
#' plot(polyester.spct, UV_bands(), range = UV(),
#'      annotations = c("=", "segments", "labels"))
#'
"_PACKAGE"
