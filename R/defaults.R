#' Defaults for \pkg{biocmake}
#'
#' @return
#' For \code{defaultCommand}, a string specifying the expected command-line invocation of an existing Cmake installation.
#' 
#' For \code{defaultDownloadVersion}, a string specifying the version of Cmake to download if no existing installation can be found.
#'
#' For \code{defaultMinimumVersion}, a string specifying the minimum version of an existing Cmake installation.
#'
#' For \code{defaultCacheDirectory}, a string containing the path to the cache directory for \pkg{biocmake}-managed Cmake installations.
#'
#' @details
#' The \code{BIOCMAKE_CMAKE_COMMAND} environment variable will override the default setting of \code{defaultCommand}.
#'
#' The \code{BIOCMAKE_CMAKE_DOWNLOAD_VERSION} environment variable will override the default setting of \code{defaultDownloadVersion}.
#'
#' The \code{BIOCMAKE_CMAKE_MINIMUM_VERSION} environment variable will override the default setting of \code{defaultMinimumVersion}.
#'
#' The \code{BIOCMAKE_CMAKE_CACHE_DIRECTORY} environment variable will override the default setting of \code{defaultCacheDirectory}.
#'
#' @author Aaron Lun
#' @examples
#' defaultCommand()
#' defaultDownloadVersion()
#' defaultMinimumVersion()
#' defaultCacheDirectory()
#' 
#' @name defaults
NULL

#' @export
defaultCommand <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_COMMAND", "cmake")
}


#' @export
#' @rdname defaults
defaultDownloadVersion <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_DOWNLOAD_VERSION", "3.30.3")
}

#' @export
#' @rdname defaults
defaultMinimumVersion <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_MINIMUM_VERSION", "3.24.0")
}

#' @export
#' @importFrom tools R_user_dir
#' @rdname defaults
defaultCacheDirectory <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_CACHE_DIRECTORY", R_user_dir("biocmake", "cache"))
}
