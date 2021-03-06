#' Add title, subtitle and caption to a spectral plot
#'
#' Add a title, subtitle and caption to a spectral plot based on automatically
#' extracted metadata stored from an spectral object.
#'
#' @param object generic_spct The spectral object plotted.
#' @param object.label character The name of the object being plotted.
#' @param annotations character vector Annotations as described for
#'   \code{plot()} methods, values unrelated to title are ignored.
#' @param time.format character Format as accepted by
#'   \code{\link[base]{strptime}}.
#' @param tz character time zone used in labels.
#' @param default.title character vector The default used for \code{annotations
#'   = "title"}.
#'
#' @details \code{autotitle()} retrieves from object \code{object} metadata and
#'   passes it to \code{ggplot2::ggtitle()} as arguments for \code{title},
#'   \code{subtitle} and \code{caption}. The specification for the tittle is
#'   passed as argument to \code{annotations}, and consists in the keyword
#'   \code{title} with optional modifiers selecting the kind of metatdata to
#'   use, separated by colons. Up to three keywords separated by colons are
#'   accepted, and correspond to title, subtitle and caption. The recognized
#'   keywords are: "objt", "class", "what", "when", "where", "how", "inst.name",
#'   "inst.sn", "comment" and "none" are recognized as modifiers to "title";
#'   "none" is a placeholder.
#'
#' @return The return value of \code{ggplot2::labs()}.
#'
#' @examples
#'
#' p <- ggplot(sun.spct) +
#'   geom_line()
#'
#' p + autotitle(sun.spct)
#' p + autotitle(sun.spct, annotations = "title:what")
#' p + autotitle(sun.spct, annotations = "title:where:when")
#' p + autotitle(sun.spct, annotations = "title:none:none:comment")
#'
#' @export
#'
autotitle <- function(object,
                      object.label = deparse(substitute(object)),
                      annotations = "title",
                      time.format = "",
                      tz = lubridate::tz(getWhenMeasured(object)),
                      default.title  = "title:objt") {

  get_title_text <- function(key) {
    switch(key,
           objt = object.label,
           class = class(object)[1],
           what = getWhatMeasured(object)[[1]],
           how = getHowMeasured(object)[[1]],
           when = strftime(x = getWhenMeasured(object),
                           format = time.format,
                           tz = tz,
                           usetz = TRUE),
           where =
             {
               where <- getWhereMeasured(object)
               if (!(anyNA(where[["lon"]]) | anyNA(where[["lat"]]))) {
                 where[["lon"]] <- ifelse(where[["lon"]] < 0,
                                          paste(abs(where[["lon"]]), " W"),
                                          paste(where[["lon"]], " E"))
                 where[["lat"]] <- ifelse(where[["lat"]] < 0,
                                          paste(abs(where[["lat"]]), " S"),
                                          paste(where[["lat"]], " N"))
                 where[["address"]] <- ifelse(is.na(where[["address"]]),
                                              character(),
                                              as.character(where[["address"]]))
                 # the order of columns in the data frame can vary
                 paste(where[["lat"]], where[["lon"]], where[["address"]], sep = ", ")
               } else {
                 character()
               }
             },
             inst.name = getInstrDesc(object)[["spectrometer.name"]],
             inst.sn = getInstrDesc(object)[["spectrometer.sn"]],
             comment = comment(object),
             none = NULL,
             {warning("Title key '", key, "' not recognized"); NULL}
    )
  }

  title.ann <- grep("^title", annotations, value = TRUE)
  if (length(title.ann) == 0) {
    return(NULL)
  } else if(title.ann[1] == "title") {
    # default title
    title.ann <- default.title
  }
  title.ann <- c(strsplit(title.ann[1], ":")[[1]][-1], "none", "none", "none")
  title <- get_title_text(title.ann[1])
  subtitle <- get_title_text(title.ann[2])
  caption <- get_title_text(title.ann[3])
  # this is equivalent to ggtitle(tittle, subtitle)
  ggplot2::labs(title = title, subtitle = subtitle, caption = caption)
}

#' @rdname autotitle
#'
#' @note Method renamed as \code{autotitle()} to better reflect its function;
#' \code{ggtitle_spct()} is deprecated but will remain available for backwards
#' compatibility.
#'
#' @export
#'
ggtitle_spct <- autotitle
