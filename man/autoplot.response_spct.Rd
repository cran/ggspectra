% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/autoplot-response-spct.r
\name{autoplot.response_spct}
\alias{autoplot.response_spct}
\alias{autoplot.response_mspct}
\title{Plot one or more response spectra.}
\usage{
\method{autoplot}{response_spct}(
  object,
  ...,
  w.band = getOption("photobiology.plot.bands", default = list(UVC(), UVB(), UVA(),
    PhR())),
  range = getOption("ggspectra.wlrange", default = NULL),
  norm = getOption("ggspectra.norm", default = "update"),
  unit.out = getOption("photobiology.radiation.unit", default = "energy"),
  pc.out = getOption("ggspectra.pc.out", default = FALSE),
  label.qty = NULL,
  span = NULL,
  wls.target = "HM",
  annotations = NULL,
  geom = "line",
  time.format = "",
  tz = "UTC",
  text.size = 2.5,
  idfactor = NULL,
  facets = FALSE,
  plot.data = "as.is",
  ylim = c(NA, NA),
  object.label = deparse(substitute(object)),
  na.rm = TRUE
)

\method{autoplot}{response_mspct}(
  object,
  ...,
  range = getOption("ggspectra.wlrange", default = NULL),
  norm = getOption("ggspectra.norm", default = "update"),
  unit.out = getOption("photobiology.radiation.unit", default = "energy"),
  pc.out = getOption("ggspectra.pc.out", default = FALSE),
  plot.data = "as.is",
  facets = FALSE,
  idfactor = TRUE,
  object.label = deparse(substitute(object)),
  na.rm = TRUE
)
}
\arguments{
\item{object}{a \code{response_spct} object or a \code{response_mspct} object.}

\item{...}{in the case of collections of spectra, additional arguments passed
to the plot methods for individual spectra, otherwise currently ignored.}

\item{w.band}{a single waveband object or a list of waveband objects.}

\item{range}{an R object on which \code{range()} returns a vector of length
2, with minimum and maximum wavelengths (nm).}

\item{norm}{numeric Normalization wavelength (nm) or character string
\code{"max"}, or \code{"min"} for normalization at the corresponding
wavelength, \code{"update"} to update the normalization after modifying
units of expression, quantity or range but respecting the previously used
criterion, or \code{"skip"} to force return of \code{object} unchanged.}

\item{unit.out}{character string indicating type of radiation units to use
for plotting: \code{"photon"} or its synonym \code{"quantum"}, or
\code{"energy"}.}

\item{pc.out}{logical, if \code{TRUE} use percent instead of fraction of one
for normalized spectral data.}

\item{label.qty}{character string giving the type of summary quantity to use
for labels, one of \code{"mean"}, \code{"total"}, \code{"contribution"},
and \code{"relative"}.}

\item{span}{a peak is defined as an element in a sequence which is greater
than all other elements within a window of width span centred at that
element.}

\item{wls.target}{numeric vector indicating the spectral quantity values for
which wavelengths are to be searched and interpolated if need. The
\code{character} strings \code{"half.maximum"} and \code{"half.range"} are
also accepted as arguments. A list with \code{numeric} and/or
\code{character} values is also accepted.}

\item{annotations}{a character vector. For details please see sections Plot
\strong{Annotations} and \strong{Title Annotations}.}

\item{geom}{character The name of a ggplot geometry, currently only
\code{"area"}, \code{"spct"} and \code{"line"}. The default \code{NULL}
selects between them based on \code{stacked}.}

\item{time.format}{character Format as accepted by
\code{\link[base]{strptime}}.}

\item{tz}{character Time zone to use for title and/or subtitle.}

\item{text.size}{numeric size of text in the plot decorations.}

\item{idfactor}{character Name of an index column in data holding a
\code{factor} with each spectrum in a long-form multispectrum object
corresponding to a distinct level of the factor.}

\item{facets}{logical or integer Indicating if facets are to be created for
the levels of \code{idfactor} when \code{spct} contain multiple spectra in
long form.}

\item{plot.data}{character Data to plot. Default is \code{"as.is"} plotting
one line per spectrum. When passing \code{"mean"}, \code{"median"},
\code{"sum"}, \code{"prod"}, \code{"var"}, \code{"sd"}, \code{"se"} as
argument all the spectra must contain data at the same wavelength values.}

\item{ylim}{numeric y axis limits,}

\item{object.label}{character The name of the object being plotted.}

\item{na.rm}{logical.}
}
\value{
A \code{ggplot} object with a number of layers that depends on the
  data and annotations.
}
\description{
These methods return a ggplot object with an annotated plot of the spectral
data contained in a \code{response_spct} or a \code{response_mspct} object.
Spectral responsitivity can be expressed either on an energy basis or a photon
or quantum basis.
}
\details{
The plot object returned is a ggplot (an object of class
  \code{"gg"}) and it can be added to or modified as any other ggplot. The
  axis labels are encoded as \emph{plotmath} expressions as they contain
  superscripts and special characters. In 'ggplot2', plotmath expressions do
  not obey theme settings related to text fonts, except for \code{size}.

  Scale limits are expanded so as to make space for the annotations. If
  annotations are disabled, limits are not expanded unless
  \code{reserve.space} is passed to parameter \code{annotations}.

  The generic of the \code{\link[ggplot2]{autoplot}} method is defined in
  package 'ggplot2'. Package 'ggspectra' defines specializations for the
  different classes for storage of spectral data defined in package
  \code{\link[photobiology]{photobiology}}.
}
\note{
If \code{idfactor = NULL}, the default for single spectra, the name of
  the factor is retrieved from metadata or if no metadata found, the default
  \code{"spct.idx"} is tried. The default for multiple spectra is to create a
  factor named \code{"spct.idx"}, but if a different name is passed, it will
  be used instead, possibly renaming a pre-existing one.
}
\section{Plot Annotations}{
 The recognized annotation names are: \code{"summaries"}, \code{"peaks"},
  \code{"peak.labels"}, \code{"valleys"}, \code{"valley.labels"},
  \code{"wls"}, \code{"wls.labels"}, \code{"colour.guide"},
  \code{"color.guide"}, \code{"boxes"}, \code{"segments"}, \code{"labels"}.
  In addition, \code{"+"} is interpreted as a request to add to the already
  present default annotations, \code{"-"} as request to remove annotations
  and \code{"="} or missing\code{"+"} and \code{"-"} as a request to reset
  annotations to those requested. If used, \code{"+"}, \code{"-"} or
  \code{"="} must be the first member of a character vector, and followed by
  one or more of the names given above. To simultaneously add and remove
  annotations one can pass a \code{list} containing \code{character} vectors
  each assembled as described. The vectors are applied in the order they
  appear in the list. To disable all annotations pass \code{""} or
  \code{c("=", "")} as argument. Adding a variation of an annotation already
  present, replaces the existing one automatically: e.g., adding
  \code{"peak.labels"} replaces\code{"peaks"} if present.
}

\section{Title Annotations}{
 metadata retrieved from object \code{object} is
  paased to \code{ggplot2::ggtitle()} as arguments for \code{title},
  \code{subtitle} and \code{caption}. The specification for the title is
  passed as argument to \code{annotations}, and consists in the keyword
  \code{title} with optional modifiers selecting the kind of metatdata to
  use, separated by colons. Up to three keywords separated by colons are
  accepted, and correspond to title, subtitle and caption. The recognized
  keywords are: \code{"objt"}, \code{"class"}, \code{"what"}, \code{"when"},
  \code{"where"}, \code{"how"}, \code{"inst.name"}, \code{"inst.sn"},
  \code{"comment"} and \code{"none"} are recognized as modifiers to
  \code{"title"}; \code{"none"} is a placeholder. Default is
  \code{"title:objt"} or no title depending on the context.
}

\examples{

autoplot(photodiode.spct)
autoplot(photodiode.spct, geom = "spct")
autoplot(photodiode.spct, unit.out = "photon")
autoplot(photodiode.spct, annotations = "")
autoplot(photodiode.spct, norm = "skip")
autoplot(photodiode.spct, norm = 400)

two_sensors.mspct <-
 response_mspct(list("Photodiode" = photodiode.spct,
                     "Coupled charge device" = ccd.spct))
autoplot(two_sensors.mspct, normalize = TRUE, unit.out = "photon")
autoplot(two_sensors.mspct, normalize = TRUE, idfactor = "Spectra")
autoplot(two_sensors.mspct, normalize = TRUE, facets = 2)
autoplot(two_sensors.mspct, normalize = TRUE, geom = "spct")

}
\seealso{
\code{\link[photobiology]{normalize}},
  \code{\link[photobiology]{response_spct}},
  \code{\link[photobiology]{waveband}},
  \code{\link[photobiologyWavebands]{photobiologyWavebands-package}} and
  \code{\link[ggplot2]{autoplot}}

Other autoplot methods: 
\code{\link{autoplot.calibration_spct}()},
\code{\link{autoplot.cps_spct}()},
\code{\link{autoplot.filter_spct}()},
\code{\link{autoplot.object_spct}()},
\code{\link{autoplot.raw_spct}()},
\code{\link{autoplot.reflector_spct}()},
\code{\link{autoplot.source_spct}()},
\code{\link{autoplot.waveband}()},
\code{\link{set_annotations_default}()}
}
\concept{autoplot methods}
