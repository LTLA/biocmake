#' Configure Cmake 
#'
#' Propagate R's configuration variables into the Cmake options, where possible.
#'
#' @param compact Logical scalar indicating whether to format the options as Cmake command-line arguments.
#'
#' @return
#' If \code{compact}, a character vector containing CMake command-line arguments.
#'
#' Otherwise, a named character vector containing the name and value of each option.
#'
#' @author Aaron Lun
#'
#' @examples
#' configure()
#'
#' @export
configure <- function(compact=TRUE) {
    options <- list()

    options[["CMAKE_POSITION_INDEPENDENT_CODE"]] <- "ON"

    if (.Platform$OS.type != "windows") {
        options[["CMAKE_BUILD_TYPE"]] <- "Release" # this doesn't work on windows as the release flag is set elsewhere.
    }

    if (Sys.info()[["sysname"]] == "Darwin") {
         options[["CMAKE_OSX_DEPLOYMENT_TARGET"]] <- "\"\"" # avoiding hard-coding of exact OSX version.
    }

    r.self <- file.path(R.home("bin"), "R")

    c_compiler <- sub(" .*", "", system2(r.self, c("CMD", "config", "CC"), stdout=TRUE))
    if (Sys.which(c_compiler) != "" || file.exists(c_compiler)) {
        options[["CMAKE_C_COMPILER"]] <- c_compiler
    }

    cxx_compiler <- sub(" .*", "", system2(r.self, c("CMD", "config", "CXX"), stdout=TRUE))
    if (Sys.which(cxx_compiler) != "" || file.exists(cxx_compiler)) {
        options[["CMAKE_CXX_COMPILER"]] <- cxx_compiler
    }

    f_compiler <- sub(" .*", "", system2(r.self, c("CMD", "config", "FC"), stdout=TRUE))
    if (Sys.which(f_compiler) != "" || file.exists(f_compiler)) {
        options[["CMAKE_FORTRAN_COMPILER"]] <- f_compiler
    }

    make <- sub(" .*", "", system2(r.self, c("CMD", "config", "MAKE"), stdout=TRUE))
    if (Sys.which(make) != "" || file.exists(make)) {
        options[["CMAKE_MAKE_PROGRAM"]] <- make
    }

    ar <- sub(" .*", "", system2(r.self, c("CMD", "config", "AR"), stdout=TRUE))
    if (Sys.which(make) != "" || file.exists(make)) {
        options[["CMAKE_AR"]] <- ar
    }

    ranlib <- sub(" .*", "", system2(r.self, c("CMD", "config", "RANLIB"), stdout=TRUE))
    if (Sys.which(ranlib) != "" || file.exists(ranlib)) {
        options[["CMAKE_RANLIB"]] <- ranlib
    }

    options <- unlist(options)
    if (compact) {
        needs.quote <- grep(" ", options)
        options[needs.quote] <- shQuote(options[needs.quote])
        options <- sprintf("-D%s=%s", names(options), options)
    }

    options
}
