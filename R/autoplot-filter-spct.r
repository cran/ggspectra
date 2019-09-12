#' Create a complete ggplot for a filter spectrum.
#'
#' This function returns a ggplot object with an annotated plot of a filter_spct
#' object showing absorptance.
#'
#' @param spct a filter_spct object.
#' @param w.band list of waveband objects.
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm).
#' @param pc.out logical, if TRUE use percents instead of fraction of one.
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels.
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param ylim numeric y axis limits,
#' @param na.rm logical.
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
Afr_plot <- function(spct,
                     w.band,
                     range,
                     pc.out,
                     label.qty,
                     span,
                     annotations,
                     text.size,
                     idfactor,
                     ylim,
                     na.rm,
                     ...) {
  if (!is.filter_spct(spct)) {
    stop("Afr_plot() can only plot filter_spct objects.")
  }
  if (is.null(ylim) || !is.numeric(ylim)) {
    ylim <- rep(NA_real_, 2L)
  }
  if (!is.null(range)) {
    spct <- trim_wl(spct, range = range)
  }
  A2T(spct, byref = TRUE)
  Tfr.type <- getTfrType(spct)
  if (!is.null(w.band)) {
    w.band <- trim_wl(w.band, range = range(spct))
  }
  setGenericSpct(spct, multiple.wl = getMultipleWl(spct)) # so that we can assign variable Afr
  if (! "Afr" %in% names(spct)) {
    if (Tfr.type == "internal" &&
        "Rfr" %in% names(spct)) {
      spct$Afr <- (1 - spct[["Rfr"]]) * (1 - spct[["Tfr"]])
      Afr.type <- "total"
    } else if (Tfr.type == "internal" &&
      !("Rfr" %in% names(spct))) {
      spct$Afr <- 1 - spct[["Tfr"]]
      Afr.type <- "internal"
    } else if (Tfr.type == "total" &&
               "Rfr" %in% names(spct)) {
      spct$Afr <- 1 - spct[["Tfr"]] - spct[["Rfr"]]
      Afr.type <- "total"
    } else {
      warning("Absorptance data unavailable")
      return(ggplot())
    }
  } else {
    Afr.type <- Tfr.type
  }
  if (!length(Afr.type)) {
    Afr.type <- "unknown"
  }
  if (!pc.out) {
    scale.factor <- 1
    if (Afr.type == "internal") {
      s.Afr.label <- expression(Internal~~spectral~~absorptance~~italic(A)[int](lambda)~~(fraction))
      Afr.label.total  <- "atop(italic(A)[int], (fraction))"
      Afr.label.avg  <- "atop(bar(italic(A)[int](lambda)), (fraction))"
    } else if (Afr.type == "total") {
      s.Afr.label <- expression(Total~~spectral~~absorptance~~italic(A)[tot](lambda)~~(fraction))
      Afr.label.total  <- "atop(italic(A)[tot], (total))"
      Afr.label.avg  <- "atop(bar(italic(A)[tot](lambda)), (fraction))"
    }  else {
      s.Afr.label <- expression(Spectral~~absorptance~~italic(A)(lambda)~~(fraction))
      Afr.label.total  <- "atop(italic(A), (total))"
      Afr.label.avg  <- "atop(bar(italic(A)(lambda)), (fraction))"
    }
  } else if (pc.out) {
    scale.factor <- 100
    if (Afr.type == "internal") {
      s.Afr.label <- expression(Internal~~spectral~~absorptance~~italic(A)[int](lambda)~~(percent))
      Afr.label.total  <- "atop(italic(A)[int], (total %*% 100))"
      Afr.label.avg  <- "atop(bar(italic(A)[int](lambda)), (percent))"
    } else if (Afr.type == "total") {
      s.Afr.label <- expression(Total~~spectral~~absorptance~~italic(A)[tot](lambda)~~(percent))
      Afr.label.total  <- "atop(italic(A)[tot], (total %*% 100))"
      Afr.label.avg  <- "atop(bar(italic(A)[tot](lambda)), (percent))"
    }  else {
      s.Afr.label <- expression(Spectral~~absorptance~~italic(A)(lambda)~~(percent))
      Afr.label.total  <- "atop(italic(A), (total  %*% 100))"
      Afr.label.avg  <- "atop(bar(italic(A)(lambda)), (percent))"
    }
  }
  if (label.qty == "total") {
    Afr.label <- Afr.label.total
  } else if (label.qty %in% c("average", "mean")) {
    Afr.label <- Afr.label.avg
  } else if (label.qty == "contribution") {
    Afr.label <- "atop(Contribution~~to~~total, italic(A)~~(fraction))"
  } else if (label.qty == "contribution.pc") {
    Afr.label <- "atop(Contribution~~to~~total, italic(A)~~(percent))"
  } else if (label.qty == "relative") {
    Afr.label <- "atop(Relative~~to~~sum, italic(A)~~(fraction))"
  } else if (label.qty == "relative.pc") {
    Afr.label <- "atop(Relative~~to~~sum, italic(A)~~(percent))"
  } else {
    Afr.label <- ""
  }

  y.min <- ifelse(!is.na(ylim[1]),
                  ylim[1],
                  min(0, spct[["Afr"]], na.rm = TRUE))
  y.max <- ifelse(!is.na(ylim[2]),
                  ylim[2],
                  max(1, spct[["Afr"]], na.rm = TRUE))

  if (any(!is.na(ylim))) {
    y.breaks <- scales::pretty_breaks(n = 6)
  } else {
    y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
  }

  plot <- ggplot(spct, aes_(x = ~w.length, y = ~Afr))
  temp <- find_idfactor(spct = spct,
                        idfactor = idfactor,
                        annotations = annotations)
  plot <- plot + temp$ggplot_comp
  annotations <- temp$annotations

  # We want data plotted on top of the boundary lines
  if ("boundaries" %in% annotations) {
    if (y.max > 1.005) {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "black")
    }
    if (y.min < -0.005) {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "black")
    }
  }

  plot <- plot + geom_line(na.rm = na.rm)
  plot <- plot + labs(x = "Wavelength (nm)", y = s.Afr.label)

  if (length(annotations) == 1 && annotations == "") {
    return(plot)
  }

  plot <- plot + scale_fill_identity() + scale_color_identity()

  plot <- plot + decoration(w.band = w.band,
                            label.mult = scale.factor,
                            y.max = y.max,
                            y.min = y.min,
                            x.max = max(spct),
                            x.min = min(spct),
                            annotations = annotations,
                            label.qty = label.qty,
                            span = span,
                            summary.label = Afr.label,
                            text.size = text.size,
                            na.rm = TRUE)

  if (!is.null(annotations) &&
      length(intersect(c("labels", "summaries", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, y.max * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA) # NA needed because of rounding errors
  } else {
    y.limits <- c(y.min, y.max)
    x.limits <- range(spct)
  }

  if (pc.out) {
    plot <- plot + scale_y_continuous(labels = scales::percent, breaks = y.breaks,
                                      limits = y.limits)
  } else {
    plot <- plot + scale_y_continuous(breaks = y.breaks,
                                      limits = y.limits)
  }

  plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))

}

#' Create a complete ggplot for a filter spectrum.
#'
#' This function returns a ggplot object with an annotated plot of a filter_spct
#' object showing transmittance.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot objects, and can be further manipulated.
#'
#' @param spct a filter_spct object
#' @param w.band list of waveband objects
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm)
#' @param pc.out logical, if TRUE use percents instead of fraction of one
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param na.rm logical.
#' @param ylim numeric y axis limits,
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
T_plot <- function(spct,
                   w.band,
                   range,
                   pc.out,
                   label.qty,
                   span,
                   annotations,
                   text.size,
                   idfactor,
                   na.rm,
                   ylim,
                   ...) {
  if (!is.filter_spct(spct)) {
    stop("T_plot() can only plot filter_spct objects.")
  }
  if (is.null(ylim) || !is.numeric(ylim)) {
    ylim <- rep(NA_real_, 2L)
  }
  if (!is.null(range)) {
    spct <- trim_wl(spct, range = range)
  }
  A2T(spct, byref = TRUE)
  Tfr.type <- getTfrType(spct)
  if (!is.null(w.band)) {
    w.band <- trim_wl(w.band, range = range(spct))
  }
  if (!length(Tfr.type)) {
    Tfr.type <- "unknown"
  }
  if (!pc.out) {
    scale.factor <- 1
    if (Tfr.type == "internal") {
      s.Tfr.label <- expression(Internal~~spectral~~transmittance~~T[int](lambda)~~(fraction))
      Tfr.label.total  <- "atop(T[int], (fraction))"
      Tfr.label.avg  <- "atop(bar(T[int](lambda)), (fraction))"
    } else if (Tfr.type == "total") {
      s.Tfr.label <- expression(Total~~spectral~~transmittance~~T[tot](lambda)~~(fraction))
      Tfr.label.total  <- "atop(T[tot], (total))"
      Tfr.label.avg  <- "atop(bar(T[tot](lambda)), (fraction))"
    }  else {
      s.Tfr.label <- expression(Spectral~~transmittance~~T(lambda)~~(fraction))
      Tfr.label.total  <- "atop(T, (total))"
      Tfr.label.avg  <- "atop(bar(T(lambda)), (fraction))"
    }
  } else if (pc.out) {
    scale.factor <- 100
    if (Tfr.type == "internal") {
      s.Tfr.label <- expression(Internal~~spectral~~transmittance~~T[int](lambda)~~(percent))
      Tfr.label.total  <- "atop(T[int], (total %*% 100))"
      Tfr.label.avg  <- "atop(bar(T[int](lambda)), (percent))"
    } else if (Tfr.type == "total") {
      s.Tfr.label <- expression(Total~~spectral~~transmittance~~T[tot](lambda)~~(percent))
      Tfr.label.total  <- "atop(T[tot], (total %*% 100))"
      Tfr.label.avg  <- "atop(bar(T[tot](lambda)), (percent))"
    }  else {
      s.Tfr.label <- expression(Spectral~~transmittance~~T(lambda)~~(percent))
      Tfr.label.total  <- "atop(T, (total  %*% 100))"
      Tfr.label.avg  <- "atop(bar(T(lambda)), (percent))"
    }
  }
  if (label.qty == "total") {
    Tfr.label <- Tfr.label.total
  } else if (label.qty %in% c("average", "mean")) {
    Tfr.label <- Tfr.label.avg
  } else if (label.qty == "contribution") {
    Tfr.label <- "atop(Contribution~~to~~total, T~~(fraction))"
  } else if (label.qty == "contribution.pc") {
    Tfr.label <- "atop(Contribution~~to~~total, T~~(percent))"
  } else if (label.qty == "relative") {
    Tfr.label <- "atop(Relative~~to~~sum, T~~(fraction))"
  } else if (label.qty == "relative.pc") {
    Tfr.label <- "atop(Relative~~to~~sum, T~~(percent))"
  } else {
    Tfr.label <- ""
  }

  y.min <- ifelse(!is.na(ylim[1]),
                  ylim[1],
                  min(0, spct[["Tfr"]], na.rm = TRUE))
  y.max <- ifelse(!is.na(ylim[2]),
                  ylim[2],
                  max(1, spct[["Tfr"]], na.rm = TRUE))

  if (any(!is.na(ylim))) {
    y.breaks <- scales::pretty_breaks(n = 6)
  } else {
    y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
  }

  plot <- ggplot(spct, aes_(x = ~w.length, y = ~Tfr))
  temp <- find_idfactor(spct = spct,
                        idfactor = idfactor,
                        annotations = annotations)
  plot <- plot + temp$ggplot_comp
  annotations <- temp$annotations

  # We want data plotted on top of the boundary lines
  if ("boundaries" %in% annotations) {
    if (y.max > 1.005) {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "black")
    }
    if (y.min < -0.005) {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "black")
    }
  }

  plot <- plot + geom_line(na.rm = na.rm)
  plot <- plot + labs(x = "Wavelength (nm)", y = s.Tfr.label)

  if (length(annotations) == 1 && annotations == "") {
    return(plot)
  }

  plot <- plot + scale_fill_identity() + scale_color_identity()

  plot <- plot + decoration(w.band = w.band,
                            label.mult = scale.factor,
                            y.max = y.max,
                            y.min = y.min,
                            x.max = max(spct),
                            x.min = min(spct),
                            annotations = annotations,
                            label.qty = label.qty,
                            span = span,
                            summary.label = Tfr.label,
                            text.size = text.size,
                            na.rm = TRUE)

  if (!is.null(annotations) &&
      length(intersect(c("labels", "summaries", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, y.max * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA) # NA needed because of rounding errors
  } else {
    y.limits <- c(y.min, y.max)
    x.limits <- range(spct)
  }
  if (pc.out) {
    plot <- plot + scale_y_continuous(labels = scales::percent, breaks = y.breaks,
                                      limits = y.limits)
  } else {
    plot <- plot + scale_y_continuous(breaks = y.breaks,
                                      limits = y.limits)
  }

  plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))

}

#' Create a complete ggplot for a filter spectrum.
#'
#' This function returns a ggplot object with an annotated plot of a filter_spct
#' object showing spectral absorbance.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot objects, and can be further manipulated.
#'
#' @param spct a filter_spct object
#' @param w.band list of waveband objects
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm)
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param na.rm logical.
#' @param ylim numeric y axis limits,
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
A_plot <- function(spct,
                   w.band,
                   range,
                   label.qty,
                   span,
                   annotations,
                   text.size,
                   idfactor,
                   na.rm,
                   ylim,
                   ...) {
  if (!is.filter_spct(spct)) {
    stop("A_plot() can only plot filter_spct objects.")
  }
  if (is.null(ylim) || !is.numeric(ylim)) {
    ylim <- rep(NA_real_, 2L)
  }
  if (!is.null(range)) {
    spct <- trim_wl(spct, range = range)
  }
  T2A(spct, action = "replace", byref = TRUE)
  if (!is.null(w.band)) {
    w.band <- trim_wl(w.band, range = range(spct))
  }
  Tfr.type <- getTfrType(spct)
  if (!length(Tfr.type)) {
    Tfr.type <- "unknown"
  }
  if (Tfr.type == "internal") {
    s.A.label <- expression(Internal~~spectral~~absorbance~~A[int](lambda)~~(AU))
    A.label.total  <- "atop(A[int], (AU %*% nm))"
    A.label.avg  <- "atop(bar(A[int](lambda)), (AU))"
  } else if (Tfr.type == "total") {
    s.A.label <- expression(Total~~spectral~~absorbance~~A[tot](lambda)~~(AU))
    A.label.total  <- "atop(A[tot], (AU %*% nm))"
    A.label.avg  <- "atop(bar(A[tot](lambda)), (AU))"
  }  else {
    s.A.label <- expression(Spectral~~absorbance~~A(lambda)~~(AU))
    A.label.total  <- "atop(A, (AU %*% nm))"
    A.label.avg  <- "atop(bar(A(lambda)), (AU))"
  }
  if (label.qty == "total") {
    A.label <- A.label.total
  } else if (label.qty %in% c("average", "mean")) {
    A.label <- A.label.avg
  } else if (label.qty == "contribution") {
    A.label <- "atop(Contribution~~to~~total, A~~(fraction))"
  } else if (label.qty == "contribution.pc") {
    A.label <- "atop(Contribution~~to~~total, A~~(percent))"
  } else if (label.qty == "relative") {
    A.label <- "atop(Relative~~to~~sum, A~~(fraction))"
  } else if (label.qty == "relative.pc") {
    A.label <- "atop(Relative~~to~~sum, A~~(percent))"
  } else {
    A.label <- ""
  }

  y.min <- ifelse(!is.na(ylim[1]),
                  ylim[1],
                  min(0, spct[["A"]], na.rm = TRUE))
  y.max <- ifelse(!is.na(ylim[2]),
                  ylim[2],
                  max(spct[["A"]], na.rm = TRUE))

  if (any(!is.na(ylim))) {
    y.breaks <- scales::pretty_breaks(n = 6)
  } else {
    y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
  }

  plot <- ggplot(spct, aes_(x = ~w.length, y = ~A))
  temp <- find_idfactor(spct = spct,
                        idfactor = idfactor,
                        annotations = annotations)
  plot <- plot + temp$ggplot_comp
  annotations <- temp$annotations

  # We want data plotted on top of the boundary lines
  if ("boundaries" %in% annotations) {
    if (y.max > 6) {
      plot <- plot + geom_hline(yintercept = 6, linetype = "dashed", colour = "red")
    }
    if (y.min < -0.01) {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "black")
    }
  }

  plot <- plot + geom_line(na.rm = na.rm)
  plot <- plot + labs(x = "Wavelength (nm)", y = s.A.label)

  if (length(annotations) == 1 && annotations == "") {
    return(plot)
  }

  plot <- plot + scale_fill_identity() + scale_color_identity()

  plot <- plot + decoration(w.band = w.band,
                            y.max = min(y.max, 6),
                            y.min = y.min,
                            x.max = max(spct),
                            x.min = min(spct),
                            annotations = annotations,
                            label.qty = label.qty,
                            span = span,
                            summary.label = A.label,
                            text.size = text.size,
                            na.rm = TRUE)

  if (!is.null(annotations) &&
      length(intersect(c("boxes", "segments", "labels", "summaries", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, min(y.max, 6) * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA) # NA needed because of rounding errors
  } else {
    y.limits <- c(y.min, min(y.max, 6))
    x.limits <- range(spct)
  }
  plot <- plot + scale_y_continuous(limits = y.limits)
  plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))

}

#' Create a complete ggplot for a reflector spectrum.
#'
#' This function returns a ggplot object with an annotated plot of a reflector_spct
#' reflectance.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot objects, and can be further manipulated.
#'
#' @param spct a filter_spct object
#' @param w.band list of waveband objects
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm)
#' @param pc.out logical, if TRUE use percents instead of fraction of one
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param na.rm logical.
#' @param ylim numeric y axis limits,
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
R_plot <- function(spct,
                   w.band,
                   range,
                   pc.out,
                   label.qty,
                   span,
                   annotations,
                   text.size,
                   idfactor,
                   ylim,
                   na.rm,
                   ...) {
  if (!is.reflector_spct(spct)) {
    stop("R_plot() can only plot reflector_spct objects.")
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
  Rfr.type <- getRfrType(spct)
  if (length(Rfr.type) == 0) {
    Rfr.type <- "unknown"
  }
  if (!pc.out) {
    scale.factor <- 1
    if (Rfr.type == "specular") {
      s.Rfr.label <- expression(Specular~~spectral~~reflectance~~R[spc](lambda)~~(fraction))
      Rfr.label.total  <- "atop(R[spc], (fraction))"
      Rfr.label.avg  <- "atop(bar(R[spc](lambda)), (fraction))"
    } else if (Rfr.type == "total") {
      s.Rfr.label <- expression(Total~~spectral~~reflectance~~R[tot](lambda)~~(fraction))
      Rfr.label.total  <- "atop(R[tot], (total))"
      Rfr.label.avg  <- "atop(bar(R[tot](lambda)), (fraction))"
    }  else {
      s.Rfr.label <- expression(Total~~spectral~~reflectance~~R(lambda)~~(fraction))
      Rfr.label.total  <- "atop(R, (total))"
      Rfr.label.avg  <- "atop(bar(R(lambda)), (fraction))"
    }
  } else if (pc.out) {
    scale.factor <- 100
    if (Rfr.type == "specular") {
      s.Rfr.label <- expression(Specular~~spectral~~reflectance~~R[spc](lambda)~~(percent))
      Rfr.label.total  <- "atop(R[spc], (total %*% 100))"
      Rfr.label.avg  <- "atop(bar(R[spc](lambda)), (percent))"
    } else if (Rfr.type == "total") {
      s.Rfr.label <- expression(Total~~spectral~~reflectance~~R[tot](lambda)~~(percent))
      Rfr.label.total  <- "atop(R[tot], (total %*% 100))"
      Rfr.label.avg  <- "atop(bar(R[tot](lambda)), (percent))"
    }  else {
      s.Rfr.label <- expression(Total~~spectral~~reflectance~~R(lambda)~~(percent))
      Rfr.label.total  <- "atop(R, (total  %*% 100))"
      Rfr.label.avg  <- "atop(bar(R(lambda)), (percent))"
    }
  }
  if (label.qty == "total") {
    Rfr.label <- Rfr.label.total
  } else if (label.qty %in% c("average", "mean")) {
    Rfr.label <- Rfr.label.avg
  } else if (label.qty == "contribution") {
    Rfr.label <- "atop(Contribution~~to~~total, R~~(fraction))"
  } else if (label.qty == "contribution.pc") {
    Rfr.label <- "atop(Contribution~~to~~total, R~~(percent))"
  } else if (label.qty == "relative") {
    Rfr.label <- "atop(Relative~~to~~sum, R~~(fraction))"
  } else if (label.qty == "relative.pc") {
    Rfr.label <- "atop(Relative~~to~~sum, R~~(percent))"
  } else {
    Rfr.label <- ""
  }

  y.min <- ifelse(!is.na(ylim[1]),
                  ylim[1],
                  min(0, spct[["Rfr"]], na.rm = TRUE))
  y.max <- ifelse(!is.na(ylim[2]),
                  ylim[2],
                  max(1, spct[["Rfr"]], na.rm = TRUE))

  if (any(!is.na(ylim))) {
    y.breaks <- scales::pretty_breaks(n = 6)
  } else {
    y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
  }

  plot <- ggplot(spct, aes_(x = ~w.length, y = ~Rfr))
  temp <- find_idfactor(spct = spct,
                        idfactor = idfactor,
                        annotations = annotations)
  plot <- plot + temp$ggplot_comp
  annotations <- temp$annotations

  # We want data plotted on top of the boundary lines
  if ("boundaries" %in% annotations) {
    if (y.max > 1.005) {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 1, linetype = "dashed", colour = "black")
    }
    if (y.min < -0.005) {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "red")
    } else {
      plot <- plot + geom_hline(yintercept = 0, linetype = "dashed", colour = "black")
    }
  }

  plot <- plot + geom_line(na.rm = na.rm)
  plot <- plot + labs(x = "Wavelength (nm)", y = s.Rfr.label)

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
                            summary.label = Rfr.label,
                            text.size = text.size,
                            na.rm = TRUE)

  if (!is.null(annotations) &&
      length(intersect(c("labels", "summaries", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, y.max * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA) # NA needed because of rounding errors
  } else {
    y.limits <- c(y.min, y.max)
    x.limits <- range(spct)
  }
  if (pc.out) {
    plot <- plot + scale_y_continuous(labels = scales::percent, breaks = y.breaks,
                                      limits = y.limits)
  } else {
    plot <- plot + scale_y_continuous(breaks = y.breaks,
                                      limits = y.limits)
  }

  plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))
}

#' Create a complete ggplot for a object spectrum.
#'
#' This function returns a ggplot object with an annotated plot of an object_spct
#' displaying spectral transmittance, absorptance and reflectance.
#'
#' @note Note that scales are expanded so as to make space for the annotations.
#'   The object returned is a ggplot object, and can be further manipulated.
#'
#' @param spct an object_spct object.
#' @param w.band list of waveband objects.
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm).
#' @param pc.out logical, if TRUE use percents instead of fraction of one.
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels.
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param stacked logical.
#' @param text.size numeric size of text in the plot decorations.
#' @param na.rm logical.
#' @param ylim numeric y axis limits,
#' @param ... currently ignored.
#'
#' @return a \code{ggplot} object.
#'
#' @keywords internal
#'
O_plot <- function(spct,
                   w.band,
                   range,
                   pc.out,
                   label.qty,
                   span,
                   annotations,
                   stacked,
                   text.size,
                   na.rm,
                   ylim,
                   ...) {
  if (getMultipleWl(spct) > 1L) {
    stop("Only one object spectrum per plot supported")
  }
  if (!is.object_spct(spct)) {
    stop("O_plot() can only plot object_spct objects.")
  }
  if (stacked) {
    # we need to ensure that none of Tfr, Rfr and Afr are negative
    spct <- photobiology::clean(spct)
  }
  if (is.null(ylim) || !is.numeric(ylim)) {
    ylim <- rep(NA_real_, 2L)
  }
  if (stacked && !all(is.na(ylim))) {
    warning("'ylim' not supported for stacked plots!")
  }
  if (!is.null(range)) {
    spct <- trim_wl(spct, range = range)
  }
  if (!is.null(w.band)) {
    w.band <- trim_wl(w.band, range = range(spct))
  }
  Rfr.type <- getRfrType(spct)
  if (length(Rfr.type) == 0) {
    Rfr.type <- "unknown"
  }
  Tfr.type <- getTfrType(spct)
  if (length(Tfr.type) == 0) {
    Tfr.type <- "unknown"
  }
  if (Rfr.type != "total") {
    warning("Only 'total' reflectance can be meaningfully plotted in a combined plot")
  }
  if (Tfr.type != "total") {
    warning("Only 'total' transmittance can be meaningfully plotted in a combined plot")
  }
  s.Rfr.label <- expression(atop(Spectral~~reflectance~R(lambda)~~spectral~~absorptance~~A(lambda), and~~spectral~~transmittance~T(lambda)))
  spct[["Afr"]] <- 1.0 - spct[["Tfr"]] - spct[["Rfr"]]
  if (any((spct[["Afr"]]) < -0.01)) {
    message("Bad data or fluorescence.")
    if (stacked) {
      warning("Changing mode to not stacked")
      stacked <- FALSE
    }
  }

  if (stacked) {
    y.max <- 1.01 # take care of rounding off
    y.min <- -0.01 # take care of rounding off
    y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
  } else {
    y.min <- ifelse(!is.na(ylim[1]),
                    ylim[1],
                    min(0, spct[["Rfr"]], spct[["Tfr"]], spct[["Afr"]], na.rm = TRUE))
    y.max <- ifelse(!is.na(ylim[2]),
                    ylim[2],
                    max(1, spct[["Rfr"]], spct[["Tfr"]], spct[["Afr"]], na.rm = TRUE))

    if (any(!is.na(ylim))) {
      y.breaks <- scales::pretty_breaks(n = 6)
    } else {
      y.breaks <- c(0, 0.25, 0.5, 0.75, 1)
    }

  }

  molten.spct <-
    tidyr::gather_(data = dplyr::select(spct, c("w.length", "Tfr", "Afr", "Rfr")),
                   key_col = "variable", value_col = "value", gather_cols = c("Tfr", "Afr", "Rfr"))
  stack.levels <- c("Tfr", "Afr", "Rfr")
  if (utils::compareVersion(
    asNamespace("ggplot2")$`.__NAMESPACE__.`$spec[["version"]],
    "2.1.0") > 0) {
    stack.levels <- rev(stack.levels)
  }
  molten.spct[["variable"]] <-
    factor(molten.spct[["variable"]], levels = stack.levels)
  setGenericSpct(molten.spct, multiple.wl = 3L * getMultipleWl(spct))
  plot <- ggplot(molten.spct, aes_(~w.length, ~value), na.rm = na.rm)
  if (stacked) {
    plot <- plot + geom_area(aes_(alpha = ~variable), fill = "black", colour = NA)
    plot <- plot + scale_alpha_manual(values = c(Tfr = 0.4,
                                                 Rfr = 0.25,
                                                 Afr = 0.55),
                                      breaks = c("Rfr", "Afr", "Tfr"),
                                      labels = c(Tfr = expression(T(lambda)),
                                                 Afr = expression(A(lambda)),
                                                 Rfr = expression(R(lambda))),
                                      guide = guide_legend(title = NULL))
  } else {
    plot <- plot + geom_line(aes_(linetype = ~variable))
    plot <- plot + scale_linetype(labels = c(Tfr = expression(T(lambda)),
                                               Afr = expression(A(lambda)),
                                               Rfr = expression(R(lambda))),
                                    guide = guide_legend(title = NULL))
  }
  plot <- plot + labs(x = "Wavelength (nm)", y = s.Rfr.label)

  if (length(annotations) == 1 && annotations == "") {
    return(plot)
  }

  plot <- plot + scale_fill_identity() + scale_color_identity()

  valid.annotations <- c("labels", "boxes", "segments", "colour.guide", "reserve.space")
  if (!stacked) {
    valid.annotations <- c(valid.annotations, "peaks", "valleys", "peak.labels", "valley.labels")
  }
  annotations <- intersect(annotations, valid.annotations)

  plot <- plot + decoration(w.band = w.band,
                            y.max = y.max,
                            y.min = y.min,
                            x.max = max(spct),
                            x.min = min(spct),
                            annotations = annotations,
                            label.qty = label.qty,
                            span = span,
                            summary.label = "",
                            text.size = text.size,
                            na.rm = TRUE)
  if (!is.null(annotations) &&
      length(intersect(c("boxes", "segments", "labels", "colour.guide", "reserve.space"), annotations)) > 0L) {
    y.limits <- c(y.min, y.max * 1.25)
    x.limits <- c(min(spct) - wl_expanse(spct) * 0.025, NA)
  } else {
    y.limits <- c(y.min, y.max)
    x.limits <- range(spct)
  }
  if (pc.out) {
    plot <- plot + scale_y_continuous(labels = scales::percent, breaks = y.breaks, limits = y.limits)
  } else {
    plot <- plot + scale_y_continuous(breaks = y.breaks, limits = y.limits)
  }

 plot + scale_x_continuous(limits = x.limits, breaks = scales::pretty_breaks(n = 7))

}

#' Create a complete ggplot for a filter spectrum.
#'
#' These methods return a ggplot object with an annotated plot of a
#' filter_spct object or of the spectra contained in a filter_mspct
#' object.
#'
#' @note The ggplot object returned can be further manipulated and added to.
#'   Except when no annotations are added, limits are set for the x-axis and
#'   y-axis scales. The y scale limits are expanded to include all data, or at
#'   least to the range of expected values. The plotting of absorbance is an
#'   exception as the y-axis is not extended past 6 a.u. In the case of
#'   absorbance, values larger than 6 a.u. are rarely meaningful due to stray
#'   light during measurement. However, when transmittance values below the
#'   detection limit are rounded to zero, and later converted into absorbance,
#'   values Inf a.u. result, disrupting the plot. Scales are further expanded so
#'   as to make space for the annotations.
#'
#' @param object a filter_spct object or a filter_mspct object.
#' @param ... in the case of collections of spectra, additional arguments passed
#'   to the plot methods for individual spectra, otherwise currently ignored.
#' @param w.band a single waveband object or a list of waveband objects.
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm).
#' @param plot.qty character string one of "transmittance" or "absorbance".
#' @param pc.out logical, if TRUE use percents instead of fraction of one.
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels, one of "mean", "total", "contribution", and "relative".
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param time.format character Format as accepted by \code{\link[base]{strptime}}.
#' @param tz character Time zone to use for title and/or subtitle.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param ylim numeric y axis limits,
#' @param object.label character The name of the object being plotted.
#' @param na.rm logical.
#'
#' @return a \code{ggplot} object.
#'
#' @export
#'
#' @keywords hplot
#'
#' @examples
#'
#' autoplot(yellow_gel.spct)
#' autoplot(yellow_gel.spct, pc.out = TRUE)
#'
#' @family autoplot methods
#'
autoplot.filter_spct <-
  function(object, ...,
           w.band = getOption("photobiology.plot.bands",
                            default = list(UVC(), UVB(), UVA(), PAR())),
           range = NULL,
           plot.qty = getOption("photobiology.filter.qty", default = "transmittance"),
           pc.out = FALSE,
           label.qty = NULL,
           span = NULL,
           annotations = NULL,
           time.format = "",
           tz = "UTC",
           text.size = 2.5,
           idfactor = NULL,
           ylim = c(NA, NA),
           object.label = deparse(substitute(object)),
           na.rm = TRUE) {
    annotations.default <-
      getOption("photobiology.plot.annotations",
                default = c("boxes", "labels", "summaries", "colour.guide", "peaks"))
    annotations <- decode_annotations(annotations,
                                      annotations.default)
    if (is.null(label.qty)) {
      if (is_normalized(object) || is_scaled(object)) {
        label.qty = "contribution"
      } else {
        label.qty = "average"
      }
    }
    if (length(w.band) == 0) {
      if (is.null(range)) {
        w.band <- waveband(object)
      } else if (is.waveband(range)) {
        w.band <- range
      } else {
        w.band <-  waveband(range, wb.name = "Total")
      }
    }

    if (plot.qty == "transmittance") {
      out.ggplot <- T_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           pc.out = pc.out,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else if (plot.qty == "absorbance") {
      out.ggplot <- A_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else if (plot.qty == "absorptance") {
      out.ggplot <- Afr_plot(spct = object,
                             w.band = w.band,
                             range = range,
                             pc.out = pc.out,
                             label.qty = label.qty,
                             span = span,
                             annotations = annotations,
                             text.size = text.size,
                             idfactor = idfactor,
                             ylim = ylim,
                             na.rm = na.rm,
                             ...)
    } else {
      stop("Invalid 'plot.qty' argument value: '", plot.qty, "'")
    }
    out.ggplot +
      autotitle(object = object,
                   time.format = time.format,
                   tz = tz,
                   object.label = object.label,
                   annotations = annotations)
  }

#' @rdname autoplot.filter_spct
#'
#' @param plot.data character Data to plot. Default is "as.is" plotting
#'   one line per spectrum. When passing "mean" or "median" as
#'   argument all the spectra must contain data at the same wavelength values.
#'
#' @export
#'
autoplot.filter_mspct <-
  function(object, ..., range = NULL, plot.data = "as.is") {
    # We trim the spectra to avoid unnecesary computaions later
    if (!is.null(range)) {
      object <- trim_wl(object, range = range, use.hinges = TRUE, fill = NULL)
    }
    # we convert the collection of spectra into a single spectrum object
    # containing a summary spectrum or multiple spectra in long form.
    z <- switch(plot.data,
                mean = photobiology::s_mean(object),
                median = photobiology::s_median(object),
                as.is = photobiology::rbindspct(object)
    )
    autoplot(object = z, range = NULL, ...)
  }

#' Create a complete ggplot for a reflector spectrum.
#'
#' These methods return a ggplot object with an annotated plot of a
#' reflector_spct object or of the spectra contained in a reflector_mspct
#' object.
#'
#' @note The ggplot object returned can be further manipulated and added to.
#'   Except when no annotations are added, limits are set for the x-axis and
#'   y-axis scales. The y scale limits are expanded to include all data, or at
#'   least to the range of expected values. Scales are further expanded so as to
#'   make space for the annotations.
#'
#' @param object a reflector_spct object or a reflector_mspct object.
#' @param ... in the case of collections of spectra, additional arguments passed
#'   to the plot methods for individual spectra, otherwise currently ignored.
#' @param w.band a single waveband object or a list of waveband objects.
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm).
#' @param plot.qty character string (currently ignored).
#' @param pc.out logical, if TRUE use percents instead of fraction of one.
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels, one of "mean", "total", "contribution", and "relative".
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector.
#' @param time.format character Format as accepted by
#'   \code{\link[base]{strptime}}.
#' @param tz character Time zone to use for title and/or subtitle.
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param ylim numeric y axis limits,
#' @param object.label character The name of the object being plotted.
#' @param na.rm logical.
#'
#' @return a \code{ggplot} object.
#'
#' @export
#'
#' @keywords hplot
#'
#' @examples
#'
#' autoplot(Ler_leaf_rflt.spct)
#'
#' @family autoplot methods
#'
autoplot.reflector_spct <-
  function(object, ...,
           w.band=getOption("photobiology.plot.bands",
                            default = list(UVC(), UVB(), UVA(), PAR())),
           range = NULL,
           plot.qty = getOption("photobiology.reflector.qty", default = "reflectance"),
           pc.out = FALSE,
           label.qty = NULL,
           span = NULL,
           annotations = NULL,
           time.format = "",
           tz = "UTC",
           text.size = 2.5,
           idfactor = NULL,
           ylim = c(NA, NA),
           object.label = deparse(substitute(object)),
           na.rm = TRUE) {
    annotations.default <-
      getOption("photobiology.plot.annotations",
                default = c("boxes", "labels", "summaries", "colour.guide", "peaks"))
    annotations <- decode_annotations(annotations,
                                      annotations.default)
    if (is.null(label.qty)) {
      if (is_normalized(object) || is_scaled(object)) {
        label.qty = "contribution"
      } else {
        label.qty = "average"
      }
    }
    if (length(w.band) == 0) {
      if (is.null(range)) {
        w.band <- waveband(object)
      } else if (is.waveband(range)) {
        w.band <- range
      } else {
        w.band <-  waveband(range, wb.name = "Total")
      }
    }
    if (plot.qty == "reflectance") {
      out.ggplot <- R_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           pc.out = pc.out,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else {
      stop("Invalid 'plot.qty' argument value: '", plot.qty, "'")
    }
    out.ggplot +
      autotitle(object = object,
                   time.format = time.format,
                   tz = tz,
                   object.label = object.label,
                   annotations = annotations)
  }

#' @rdname autoplot.reflector_spct
#'
#' @param plot.data character Data to plot. Default is "as.is" plotting
#'   one line per spectrum. When passing "mean" or "median" as
#'   argument all the spectra must contain data at the same wavelength values.
#'
#' @export
#'
autoplot.reflector_mspct <-
  function(object, ..., range = NULL, plot.data = "as.is") {
    # We trim the spectra to avoid unnecesary computaions later
    if (!is.null(range)) {
      object <- trim_wl(object, range = range, use.hinges = TRUE, fill = NULL)
    }
    # we convert the collection of spectra into a single spectrum object
    # containing a summary spectrum or multiple spectra in long form.
    z <- switch(plot.data,
                mean = photobiology::s_mean(object),
                median = photobiology::s_median(object),
                as.is = photobiology::rbindspct(object)
    )
    autoplot(object = z, range = NULL, ...)
  }

#' Create a complete ggplot for a object spectrum.
#'
#' This function returns a ggplot object with an annotated plot of an
#' object_spct object.
#'
#' @note The ggplot object returned can be further manipulated and added to.
#'   Except when no annotations are added, limits are set for the x-axis and
#'   y-axis scales. The y scale limits are expanded to include all data, or at
#'   least to the range of expected values. Scales are further expanded so
#'   as to make space for the annotations. When all \code{"all"} quantities are
#'   plotted, a single set of spectra is accepted as input.
#'
#' @param object an object_spct object
#' @param ... in the case of collections of spectra, additional arguments passed
#'   to the plot methods for individual spectra, otherwise currently ignored.
#' @param w.band a single waveband object or a list of waveband objects
#' @param range an R object on which range() returns a vector of length 2, with
#'   min annd max wavelengths (nm)
#' @param plot.qty character string, one of "all", "transmittance",
#'   "absorbance", "absorptance", or "reflectance".
#' @param pc.out logical, if TRUE use percents instead of fraction of one
#' @param label.qty character string giving the type of summary quantity to use
#'   for labels, one of "mean", "total", "contribution", and "relative".
#' @param span a peak is defined as an element in a sequence which is greater
#'   than all other elements within a window of width span centered at that
#'   element.
#' @param annotations a character vector
#' @param time.format character Format as accepted by \code{\link[base]{strptime}}.
#' @param tz character Time zone to use for title and/or subtitle.
#' @param stacked logical
#' @param text.size numeric size of text in the plot decorations.
#' @param idfactor character Name of an index column in data holding a
#'   \code{factor} with each spectrum in a long-form multispectrum object
#'   corresponding to a distinct spectrum. If \code{idfactor=NULL} the name of
#'   the factor is retrieved from metadata or if no metadata found, the
#'   default "spct.idx" is tried. If \code{idfactor=NA} no aesthetic is mapped
#'   to the spectra and the user needs to use 'ggplot2' functions to manually
#'   map an aesthetic or use facets for the spectra.
#' @param ylim numeric y axis limits,
#' @param object.label character The name of the object being plotted.
#' @param na.rm logical.
#'
#' @return a \code{ggplot} object.
#'
#' @export
#'
#' @keywords hplot
#'
#' @examples
#'
#' autoplot(Ler_leaf.spct)
#'
#' @family autoplot methods
#'
autoplot.object_spct <-
  function(object, ...,
           w.band = getOption("photobiology.plot.bands",
                              default = list(UVC(), UVB(), UVA(), PAR())),
           range = NULL,
           plot.qty = "all",
           pc.out = FALSE,
           label.qty = NULL,
           span = 61,
           annotations = NULL,
           time.format = "",
           tz = "UTC",
           stacked = TRUE,
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
    if (is.null(label.qty)) {
      if (is_normalized(object) || is_scaled(object)) {
        label.qty = "contribution"
      } else {
        label.qty = "average"
      }
    }
    if (length(w.band) == 0) {
      if (is.null(range)) {
        w.band <- waveband(object)
      } else if (is.waveband(range)) {
        w.band <- range
      } else {
        w.band <-  waveband(range, wb.name = "Total")
      }
    }
    if (is.null(plot.qty) || plot.qty == "all") {
    out.ggplot <- O_plot(spct = object,
                         w.band = w.band,
                         range = range,
                         pc.out = pc.out,
                         label.qty = label.qty,
                         span = span,
                         annotations = annotations,
                         stacked = stacked,
                         text.size = text.size,
                         ylim = ylim,
                         na.rm = na.rm,
                         ...)
    } else if (plot.qty == "transmittance") {
      object <- as.filter_spct(object)
      out.ggplot <- T_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           pc.out = pc.out,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else if (plot.qty == "absorbance") {
      object <- as.filter_spct(object)
      out.ggplot <- A_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else if (plot.qty == "absorptance") {
      object <- as.filter_spct(object)
      out.ggplot <- Afr_plot(spct = object,
                             w.band = w.band,
                             range = range,
                             pc.out = pc.out,
                             label.qty = label.qty,
                             span = span,
                             annotations = annotations,
                             text.size = text.size,
                             idfactor = idfactor,
                             ylim = ylim,
                             na.rm = na.rm,
                             ...)
    } else if (plot.qty == "reflectance") {
      object <- as.reflector_spct(object)
      out.ggplot <- R_plot(spct = object,
                           w.band = w.band,
                           range = range,
                           pc.out = pc.out,
                           label.qty = label.qty,
                           span = span,
                           annotations = annotations,
                           text.size = text.size,
                           idfactor = idfactor,
                           ylim = ylim,
                           na.rm = na.rm,
                           ...)
    } else {
      stop("Invalid 'plot.qty' argument value: '", plot.qty, "'")
    }
    out.ggplot +
      autotitle(object = object,
                   time.format = time.format,
                   tz = tz,
                   object.label = object.label,
                   annotations = annotations)
  }

#' @rdname autoplot.object_spct
#'
#' @export
#'
autoplot.object_mspct <-
  function(object, ..., range = NULL) {
    stop("plot() not implemented for 'object_mspct'")
    # z <- rbindspct(x)
    # plot(x = z, ...)
  }

