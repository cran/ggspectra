% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggplot-methods.R
\name{ggplot}
\alias{ggplot}
\alias{ggplot.source_spct}
\alias{ggplot.response_spct}
\alias{ggplot.filter_spct}
\alias{ggplot.reflector_spct}
\alias{ggplot.cps_spct}
\alias{ggplot.calibration_spct}
\alias{ggplot.raw_spct}
\alias{ggplot.object_spct}
\alias{ggplot.generic_spct}
\alias{ggplot.generic_mspct}
\alias{ggplot.filter_mspct}
\alias{ggplot.source_mspct}
\alias{ggplot.object_mspct}
\title{Create a new ggplot plot from spectral data.}
\usage{
\method{ggplot}{source_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  unit.out = getOption("photobiology.radiation.unit", default = "energy"),
  environment = parent.frame()
)

\method{ggplot}{response_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  unit.out = getOption("photobiology.radiation.unit", default = "energy"),
  environment = parent.frame()
)

\method{ggplot}{filter_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  plot.qty = getOption("photobiology.filter.qty", default = "transmittance"),
  environment = parent.frame()
)

\method{ggplot}{reflector_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  plot.qty = NULL,
  environment = parent.frame()
)

\method{ggplot}{cps_spct}(data, mapping = NULL, ..., range = NULL, environment = parent.frame())

\method{ggplot}{calibration_spct}(data, mapping = NULL, ..., range = NULL, environment = parent.frame())

\method{ggplot}{raw_spct}(data, mapping = NULL, ..., range = NULL, environment = parent.frame())

\method{ggplot}{object_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  plot.qty = getOption("photobiology.object.qty", default = "all"),
  environment = parent.frame()
)

\method{ggplot}{generic_spct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  spct_class,
  environment = parent.frame()
)

\method{ggplot}{generic_mspct}(data, mapping = NULL, ..., range = NULL, environment = parent.frame())

\method{ggplot}{filter_mspct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  plot.qty = getOption("photobiology.filter.qty", default = "transmittance"),
  environment = parent.frame()
)

\method{ggplot}{source_mspct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  unit.out = getOption("photobiology.radiation.unit", default = "energy"),
  environment = parent.frame()
)

\method{ggplot}{object_mspct}(
  data,
  mapping = NULL,
  ...,
  range = NULL,
  plot.qty = getOption("photobiology.object.qty", default = ifelse(length(data) > 1L,
    "as.is", "all")),
  environment = parent.frame()
)
}
\arguments{
\item{data}{Default spectrum dataset to use for plot. If not a spectrum, the
methods used will be those defined in package \code{ggplot2}. See
\code{\link[ggplot2]{ggplot}}. If not specified, must be supplied in each
layer added to the plot.}

\item{mapping}{Default list of aesthetic mappings to use for plot. If not
specified, in the case of spectral objects, a default mapping will be used.}

\item{...}{Other arguments passed on to methods.}

\item{range}{an R object on which range() returns a vector of length 2, with
min and max wavelengths (nm).}

\item{unit.out}{character string indicating type of units to use for
plotting spectral irradiance or spectral response, \code{"photon"} or
\code{"energy"}.}

\item{environment}{If a variable defined in the aesthetic mapping is not
found in the data, ggplot will look for it in this environment. It defaults
to using the environment in which \code{ggplot()} is called.}

\item{plot.qty}{character string One of \code{"transmittance"},
\code{"absorptance"} or \code{"absorbance"} for \code{filter_spct} objects,
and in addition to these \code{"reflectance"}, \code{"all"} or
\code{"as.is"} for \code{object_spct} objects.}

\item{spct_class}{character Class into which a \code{generic_spct} object
will be converted before plotting. The column names in data should
match those expected by the class constructor (see
\code{\link[photobiology]{setGenericSpct}}); other arguments should be
passed by name).}
}
\description{
\code{ggplot()} initializes a ggplot object. It can be used to declare the
input spectral object for a graphic and to optionally specify the set of plot
aesthetics intended to be common throughout all subsequent layers unless
specifically overridden.
}
\details{
\code{ggplot()} is typically used to construct a plot incrementally, using
the \code{+} operator to add layers to the existing ggplot object. This is
advantageous in that the code is explicit about which layers are added and
the order in which they are added. For complex graphics with multiple layers,
initialization with \code{ggplot} is recommended.

We show seven common ways to invoke \code{ggplot} for spectra and
collections of spectra:
\itemize{
   \item \code{ggplot(spct)}
   \item \code{ggplot(spct, unit.out = <unit.to.use>)}
   \item \code{ggplot(spct, plot.qty = <quantity.to.plot>)}
   \item \code{ggplot(spct, range = <wavelength.range>)}
   \item \code{ggplot(spct) + aes(<other aesthetics>)}
   \item \code{ggplot(spct, aes(x, y, <other aesthetics>))}
   \item \code{ggplot(spct, aes())}
  }
The first method is recommended if all layers use the same data and the same
set of automatic default x and y aesthetics. The second, third and fourth use
automatic default x and y aesthetics but first transform or trim the spectral
data to be plotted. The fifth uses automatic default x and y aesthetics and
adds mappings for other aesthetics. These patterns can be combined as needed.
The sixth disables the use of a default automatic mapping, while the seventh
delays the mapping of aesthetics and can be convenient when using different
mappings for different geoms.
}
\note{
Current implementation does not merge the default mapping with user
  supplied mapping. If user supplies a mapping, it is used as is, and
  variables should be present in the spectral object. In contrast, when using
  the default mapping, unit or quantity conversions are done on the fly when
  needed. To add to the default mapping, \code{aes()} can be used by itself
  to compose the ggplot. In all cases, except when an \code{object_spct} is
  converted into long form, the data member of the returned plot object
  retains its class and attributes.

plot.qty is ignored for reflectors.
}
\section{Object spectra}{
 In the case of class object_spct, the arguments
  \code{"all"} and \code{"as.is"} if passed to \code{plot.qty}, indicate in
  the first case that the data are to be converted into long form, to allow
  stacking, while in the second case \code{data} is copied unchanged to the
  plot object. \code{"reflectance"} passed to \code{plot.qty} converts
  \code{data} into a \code{replector_spct} object and \code{"absorbance"},
  \code{"absorptance"} and \code{"reflectance"}, convert \code{data} into a
  \code{filter_spct}.
}

\section{Collections of spectra}{
 The method for collections of spectra
  accepts arguments for the same parameters as the corresponding methods for
  single spectra. Heterogeneous generic collections of spectra are not
  supported. When plotting collections of spectra the factor \code{spct.idx}
  contains as levels the names of the individual members of the collection,
  and can be mapped to aesthetics or used for faceting.
}

\examples{

ggplot(sun.spct) + geom_line()
ggplot(sun.spct, unit.out = "photon") + geom_line()

ggplot(yellow_gel.spct) + geom_line()
ggplot(yellow_gel.spct, plot.qty = "absorbance") + geom_line()

ggplot(Ler_leaf.spct) + facet_grid(~variable) + geom_line()
ggplot(Ler_leaf.spct) + aes(linetype = variable) + geom_line()

}
