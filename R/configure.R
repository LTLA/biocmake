#' Configure Cmake 
#'
#' Propagate R's configuration variables into the Cmake options, where possible.
#'
#' @param c.compiler Logical scalar indicating whether to propagate R's choice of C compiler.
#' @param c.flags Logical scalar indicating whether to propagate R's choice of C flags.
#' @param cxx.compiler Logical scalar indicating whether to propagate R's choice of C++ compiler.
#' @param cxx.flags Logical scalar indicating whether to propagate R's choice of C++ flags.
#' @param fortran.compiler Logical scalar indicating whether to propagate R's choice of Fortran compiler.
#' @param fortran.flags Logical scalar indicating whether to propagate R's choice of Fortran flags.
#' @param cpp.flags Logical scalar indicating whether to propagate R's choice of C/C++ preprocessing flags.
#' @param pic.flags Logical scalar indicating whether to propagate R's choice of each language's position-independent flags.
#' This also sets the \code{CMAKE_POSITION_INDEPENDENT_CODE} variable.
#' @param ld.flags Logical scalar indicating whether to add R's choice of linker flags to the CMake variables for each target type.
#' @param make Logical scalar indicating whether to propagate R's choice of \code{make} command.
#' @param ar Logical scalar indicating whether to propagate R's choice of command to make static libraries.
#' @param ranlib Logical scalar indicating whether to propagate R's choice of command to index static libraries.
#' @param release.build Logical scalar indicating whether to configure Cmake for a release build.
#' Note that this has no effect on Windows, where the release flags must be set during the build itself.
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
configure <- function(
    c.compiler=TRUE,
    c.flags=c.compiler,
    cxx.compiler=TRUE,
    cxx.flags=cxx.compiler,
    fortran.compiler=TRUE,
    fortran.flags=fortran.compiler,
    cpp.flags=c.compiler || cxx.compiler,
    pic.flags=TRUE,
    ld.flags=c("exe", "module", "shared"),
    make=TRUE,
    ar=TRUE,
    ranlib=TRUE,
    release.build=TRUE)
{
    options <- list()

    if (pic.flags) {
        options[["CMAKE_POSITION_INDEPENDENT_CODE"]] <- "ON"
    }

    if (release.build && .Platform$OS.type != "windows") {
        options[["CMAKE_BUILD_TYPE"]] <- "Release" # this doesn't work on windows as the release flag is set elsewhere.
    }

    if (Sys.info()[["sysname"]] == "Darwin") {
         options[["CMAKE_OSX_DEPLOYMENT_TARGET"]] <- "" # avoiding hard-coding of exact OSX version.
    }

    if (.Platform$OS.type == "windows") {
        r.bin <- "R.exe"
    } else {
        r.bin <- "R"
    }
    r.self <- file.path(R.home("bin"), r.bin)

    precursor <- character()
    if (cpp.flags) {
        precursor <- system2(r.self, c("CMD", "config", "CPPFLAGS"), stdout=TRUE)
    }

    if (c.compiler) {
        out <- system2(r.self, c("CMD", "config", "CC"), stdout=TRUE)
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_C_COMPILER"]] <- out
        }
    }

    if (c.flags) {
        out <- c(precursor, system2(r.self, c("CMD", "config", "CFLAGS"), stdout=TRUE))
        if (pic.flags) {
            out <- c(out, system2(r.self, c("CMD", "config", "CPICFLAGS"), stdout=TRUE))
        }
        out <- compact(out)
        if (out != "") {
            options[["CMAKE_C_FLAGS"]] <- out
        }
    }

    if (cxx.compiler) {
        out <- system2(r.self, c("CMD", "config", "CXX"), stdout=TRUE)
        out <- sub(" -std=[^ ]*", "", out) # stripping standard specification.
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_CXX_COMPILER"]] <- out
        }
    }

    if (cxx.flags) {
        out <- c(precursor, system2(r.self, c("CMD", "config", "CXXFLAGS"), stdout=TRUE))
        if (pic.flags) {
            out <- c(out, system2(r.self, c("CMD", "config", "CXXPICFLAGS"), stdout=TRUE))
        }
        out <- compact(out)
        if (out != "") {
            options[["CMAKE_CXX_FLAGS"]] <- out
        }
    }

    if (fortran.compiler) {
        out <- system2(r.self, c("CMD", "config", "FC"), stdout=TRUE)
        if (Sys.which(out) != "" || file.exists(out)) {
            options[["CMAKE_FORTRAN_COMPILER"]] <- out
        }
    }

    if (fortran.flags) {
        out <- system2(r.self, c("CMD", "config", "FFLAGS"), stdout=TRUE)
        if (pic.flags) {
            out <- c(out, system2(r.self, c("CMD", "config", "FPICFLAGS"), stdout=TRUE))
        }
        out <- compact(out)
        if (out != "") {
            options[["CMAKE_FORTRAN_FLAGS"]] <- out
        }
    }

    if (make) {
        out <- system2(r.self, c("CMD", "config", "MAKE"), stdout=TRUE)
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

    ld.flags <- match.arg(ld.flags, several.ok=TRUE)
    if (length(ld.flags)) {
        out <- sub(" .*", "", system2(r.self, c("CMD", "config", "LDFLAGS"), stdout=TRUE))
        if (out != "") {
            for (type in ld.flags) {
                options[[sprintf("CMAKE_%s_LINKER_FLAGS", toupper(type))]] <- out
            }
        }
    }

    unlist(options)
}

compact <- function(x) {
    x <- x[x != ""]
    paste(x, collapse=" ")
}

#' @export
#' @rdname configure
formatArguments <- function(options) {
    options <- options[!is.na(options)]
    needs.quote <- grepl(" ", options) | options == ""
    options[needs.quote] <- shQuote(options[needs.quote])
    options <- sprintf("-D%s=%s", names(options), options)
}
