#' Defaults for \pkg{biocmake}
#'
#' @return
#' For \code{defaultCmakeCommand}, a string specifying the expected command-line invocation of an existing Cmake installation.
#' 
#' For \code{defaultCmakeDownloadVersion}, a string specifying the version of Cmake to download if no existing installation can be found.
#'
#' For \code{defaultCmakeMinimumVersion}, a string specifying the minimum version of an existing Cmake installation.
#'
#' For \code{defaultCmakeCacheDirectory}, a string containing the path to the cache directory for \pkg{biocmake}-managed Cmake installations.
#'
#' @details
#' The \code{BIOCMAKE_CMAKE_COMMAND} environment variable will override the default setting of \code{defaultCmakeCommand}.
#'
#' The \code{BIOCMAKE_CMAKE_DOWNLOAD_VERSION} environment variable will override the default setting of \code{defaultCmakeDownloadVersion}.
#'
#' The \code{BIOCMAKE_CMAKE_MINIMUM_VERSION} environment variable will override the default setting of \code{defaultCmakeMinimumVersion}.
#'
#' The \code{BIOCMAKE_CMAKE_CACHE_DIRECTORY} environment variable will override the default setting of \code{defaultCmakeCacheDirectory}.
#'
#' @author Aaron Lun
#' @examples
#' defaultCmakeCommand()
#' defaultCmakeDownloadVersion()
#' defaultCmakeMinimumVersion()
#' defaultCmakeCacheDirectory()
#' 
#' @name defaults
NULL

#' @export
defaultCmakeCommand <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_COMMAND", "cmake")
}


#' @export
#' @rdname defaults
defaultCmakeDownloadVersion <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_DOWNLOAD_VERSION", "3.30.3")
}

#' @export
#' @rdname defaults
defaultCmakeMinimumVersion <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_MINIMUM_VERSION", "3.24.0")
}

#' @export
#' @importFrom tools R_user_dir
#' @rdname defaults
defaultCmakeCacheDirectory <- function() {
    Sys.getenv("BIOCMAKE_CMAKE_CACHE_DIRECTORY", R_user_dir("biocmake", "cache"))
}
