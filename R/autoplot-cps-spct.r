#' Create a complete ggplot for detector-counts per second spectra.
#'
#' This function returns a ggplot object with an annotated plot of a
#' cps_spct object.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot object, and can be further manipulated.
#'   When spct has more than one column with spectral data, each of these
#'   columns is normalized individually.
#'
#' @param spct a cps_spct object
#' @param w.band list of waveband objects
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm)
#' @param pc.out logical, if TRUE use percents instead of fraction of one
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels, one of "mean", "total", "contribution", and "relative".
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param wls.target numeric vector indicating the spectral quantity values for
#'   which wavelengths are to be searched and interpolated if need. The
#'   \code{character} strings "half.maximum" and "half.range" are also accepted
#'   as arguments. A list with \code{numeric} and/or \code{character} values is
#'   also accepted.
#' @param annotations a character vector
#' @param norm numeric normalization wavelength (nm) or character string "max"
#'   for normalization at the wavelength of highest peak.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried.
#' @param ylim numeric y axis limits,
#' @param na.rm logical.
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
cps_plot <- function(spct,
                     w.band,
                     range,
                     pc.out,
                     label.qty,
                     span,
                     wls.target,
                     annotations,
                     norm,
                     text.size,
                     idfactor,
                     ylim,
                     na.rm,
                     ...) {
  if (!is.cps_spct(spct)) {
    stop("cps_plot() can only plot response_spct objects.")
  }
  if (is.null(ylim) || !is.numeric(ylim)) {
    ylim <- rep(NA_real_, 2L)
  }
  if (!is.null(range)) {
    spct <- trim_wl(spct, range = range)
  }
  if (!is.null(w.band)) {
    w.band <- trim_wl(w.band, range = range(spct))
  }
  cps.cols <- names(spct)[grep("^cps", names(spct))]
  num.cps.cols <- length(cps.cols)
  stopifnot(num.cps.cols == 1L || getMultipleWl(spct) <= 1L)
  #  other.cols <- setdiff(names(x), cps.cols)
  if (is.null(norm)) {
    # we will use the original data
    scale.factor <- 1
  } else {
    for (col in cps.cols) {
      if (is.character(norm)) {
        if (norm %in% c("max", "maximum")) {
          idx <- which.max(spct[[col]])
        } else {
          warning("Invalid character '", norm, "'value in 'norm'")
          return(ggplot())
        }
        scale.factor <- 1 / as.numeric(spct[idx, col])
        norm <- as.numeric(spct[idx, "w.length"])
      } else if (is.numeric(norm) && norm >= min(spct) && norm <= max(spct)) {
        scale.factor <- 1 / interpolate_spct(spct, norm)[[col]]
      } else if (is.numeric(norm)) {
        warning("'norm = ", norm, "' value outside spectral data range of ",
                round(min(spct)), " to ", round(max(spct)), " (nm)")
        return(ggplot())
      } else {
        stop("'norm' should be numeric or character")
      }
      spct[[col]] <-  spct[[col]] * scale.factor
    }
  }

  if (scale.factor != 1) {
    if (!pc.out) {
      multiplier.label <- "rel."
      #      scale.factor <- 1 * scale.factor
    } else {
      multiplier.label <- "%"
      scale.factor <- 100 * scale.factor
    }
    if (is.numeric(norm)) {
      norm <- signif(norm, digits = 4)
    }
    s.cps.label <-
      bquote(Pixel~~response~~rate~~N( italic(lambda) )/N( .(norm))~~(.(multiplier.label)))
    cps.label <- ""
  } else {
    s.cps.label <-
      expression(Pixel~~response~~rate~~N(lambda)~~(counts~~s^{-1}))
    cps.label <- ""
  }

  if (num.cps.cols > 1L) {
    # remove raw_spct class before melting as it invalidates expectations
    rmDerivedSpct(spct)
    spct <- tidyr::gather_(data = spct,
                           key_col = "scan",
                           value_col = "cps",
                           gather_cols = cps.cols)
    setCpsSpct(spct, multiple.wl = length(cps.cols))
    plot <- ggplot(spct, aes_(x = ~w.length, y = ~cps, linetype = ~scan))
  } else {
    plot <- ggplot(spct, aes_(x = ~w.length, y = ~cps))
    temp <- find_idfactor(spct = spct,
                          idfactor = idfactor,
                          annotations = annotations)
    plot <- plot + temp$ggplot_comp
    annotations <- temp$annotations
  }

  y.min <- ifelse(!is.na(ylim[1]),
                  ylim[1],
                  min(c(spct[["cps"]], 0), na.rm = TRUE))
  y.max <- ifelse(!is.na(ylim[2]),
                  ylim[2],
                  max(c(spct[["cps"]], 0), na.rm = TRUE))

  # We want data plotted on top of the boundary lines
  if ("boundaries" %in% annotations) {
    if (y.min < (-0.01 * y.max)) {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "black")
    }
  }

  plot <- plot + geom_line(na.rm = na.rm)
  plot <- plot + labs(x = "Wavelength (nm)", y = s.cps.label)

  if (length(annotations) == 1 && annotations == "") {
    return(plot)
  }

  plot <- plot + scale_fill_identity() + scale_color_identity()

  plot <- plot + decoration(w.band = w.band,
                            y.max = y.max,
                            y.min = y.min,
                            x.max = max(spct),
                            x.min = min(spct),
                            annotations = annotations,
                            label.qty = label.qty,
                            span = span,
                            wls.target = wls.target,
                            summary.label = cps.label,
                            text.size = text.size,
                            na.rm = TRUE)

  if (!is.null(annotations) &&
      length(intersect(c("boxes", "segments", "labels", "summaries", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, y.max * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA) # NA needed because of rounding errors
  } else {
    y.limits <- c(y.min, y.max)
    x.limits <- range(spct)
  }

  plot <- plot + scale_y_continuous(limits = y.limits)
  plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))

}

#' Create a complete ggplot for detector-counts per second spectra.
#'
#' This function returns a ggplot object with an annotated plot of a
#' response_spct object.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot objects, and can be further manipulated.
#'
#' @param object a cps_spct object.
#' @param ... in the case of collections of spectra, additional arguments passed
#'   to the plot methods for individual spectra, otherwise currently ignored.
#' @param w.band a single waveband object or a list of waveband objects.
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm).
#' @param unit.out character IGNORED.
#' @param pc.out logical, if TRUE use percents instead of fraction of one
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels, one of "mean", "total", "contribution", and "relative".
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param wls.target numeric vector indicating the spectral quantity values for
#'   which wavelengths are to be searched and interpolated if need. The
#'   \code{character} strings "half.maximum" and "half.range" are also accepted
#'   as arguments. A list with \code{numeric} and/or \code{character} values is
#'   also accepted.
#' @param annotations a character vector ("summaries" is ignored).
#' @param time.format character Format as accepted by \code{\link[base]{strptime}}.
#' @param tz character Time zone to use for title and/or subtitle.
#' @param norm numeric normalization wavelength (nm) or character string "max"
#'   for normalization at the wavelength of highest peak.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried.
#' @param ylim numeric y axis limits,
#' @param object.label character The name of the object being plotted.
#' @param na.rm logical.
#'
#' @return a \code{ggplot} object.
#'
#' @export
#'
#' @family autoplot methods
#'
autoplot.cps_spct <-
  function(object, ...,
           w.band = getOption("photobiology.plot.bands",
                              default = list(UVC(), UVB(), UVA(), PAR())),
           range = NULL,
           unit.out = "cps",
           pc.out = FALSE,
           label.qty = "mean",
           span = NULL,
           wls.target = "HM",
           annotations = NULL,
           time.format = "",
           tz = "UTC",
           norm = NULL,
           text.size = 2.5,
           idfactor = NULL,
           ylim = c(NA, NA),
           object.label = deparse(substitute(object)),
           na.rm = TRUE) {
    annotations.default <-
      getOption("photobiology.plot.annotations",
                default = c("boxes", "labels", "colour.guide", "peaks"))
    annotations <- decode_annotations(annotations,
                                      annotations.default)
    if (length(w.band) == 0) {
      if (is.null(range)) {
        w.band <- waveband(object)
      } else if (is.waveband(range)) {
        w.band <- range
      } else {
        w.band <-  waveband(range, wb.name = "Total")
      }
    }

    cps_plot(spct = object, w.band = w.band, range = range,
             label.qty = label.qty,
             span = span,
             wls.target = wls.target,
             pc.out = pc.out,
             annotations = annotations, norm = norm,
             text.size = text.size,
             idfactor = idfactor,
             ylim = ylim,
             na.rm = na.rm,
             ...) +
      autotitle(object = object,
                   time.format = time.format,
                   tz = tz,
                   object.label = object.label,
                   annotations = annotations)
  }


