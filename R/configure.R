#' Configure Cmake 
#'
#' Propagate R's configuration variables into the Cmake options, where possible.
#'
#' @param c.compiler Logical scalar indicating whether to propagate R's choice of C compiler.
#' @param cxx.compiler Logical scalar indicating whether to propagate R's choice of C++ compiler.
#' @param fortran.compiler Logical scalar indicating whether to propagate R's choice of Fortran compiler.
#' @param make Logical scalar indicating whether to propagate R's choice of \code{make} command.
#' @param ar Logical scalar indicating whether to propagate R's choice of command to make static libraries.
#' @param ranlib Logical scalar indicating whether to propagate R's choice of command to index static libraries.
#' @param options Character vector of optional arguments from \code{configure}.
#'
#' @return
#' For \code{configure}, a named character vector containing the name and value of each option.
#'
#' For \code{formatArguments}, a character vector with Cmake arguments on the command line.
#' \code{NA} values are ignored, and values with spaces or empty strings are quoted.
#'
#' @author Aaron Lun
#'
#' @examples
#' options <- configure()
#' options
#' formatArguments(options)
#'
#' @export
configure <- function(c.compiler=TRUE, cxx.compiler=TRUE, fortran.compiler=TRUE, make=TRUE, ar=TRUE, ranlib=TRUE) {
    options <- list()

    options[["CMAKE_POSITION_INDEPENDENT_CODE"]] <- "ON"

    if (.Platform$OS.type != "windows") {
        options[["CMAKE_BUILD_TYPE"]] <- "Release" # this doesn't work on windows as the release flag is set elsewhere.
    }

    if (Sys.info()[["sysname"]] == "Darwin") {
         options[["CMAKE_OSX_DEPLOYMENT_TARGET"]] <- "" # avoiding hard-coding of exact OSX version.
    }

    r.self <- file.path(R.home("bin"), "R")

    if (c.compiler) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "CC"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_C_COMPILER"]] <- out
        }
    }

    if (cxx.compiler) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "CXX"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_CXX_COMPILER"]] <- out
        }
    }

    if (fortran.compiler) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "FC"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_FORTRAN_COMPILER"]] <- out
        }
    }
 
    if (make) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "MAKE"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_MAKE_PROGRAM"]] <- out
        }
    }

    if (ar) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "AR"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_AR"]] <- out
        }
    }

    if (ranlib) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "RANLIB"), stdout=TRUE))
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_RANLIB"]] <- out
        }
    }

    unlist(options)
}

#' @export
#' @rdname configure
formatArguments <- function(options) {
    options <- options[!is.na(options)]
    needs.quote <- grepl(" ", options) | options == ""
    options[needs.quote] <- shQuote(options[needs.quote])
    options <- sprintf("-D%s=%s", names(options), options)
}
