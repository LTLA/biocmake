#' Download Cmake
#'
#' Download Cmake binaries for the current architecture.
#' This uses \pkg{dir.expiry} to remove unused versions of the \pkg{biocmake}-managed Cmake.
#'
#' @param download.version String specifying the Cmake version to download.
#' @param cache.dir String specifying the location of the directory in which to cache Cmake installations.
#' @param ignore.cache Logical scalar specifying whether to ignore any existing cached version of Cmake,
#' in which case the binaries will be downloaded again.
#'
#' @return String containing the path to the Cmake executable.
#' @author Aaron Lun
#'
#' @examples
#' download()
#'
#' @export
#' @importFrom utils untar unzip
download <- function(download.version=defaultDownloadVersion(), cache.dir=defaultCacheDirectory(), ignore.cache=FALSE) {
    if (.Platform$OS.type == "windows") {
        output <- get_cmake(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache, formatter=get_windows_format, unpacker=unzip)
        return(file.path(output, "bin", "cmake.exe"))
    }

    sinfo <- Sys.info()
    ssys <- sinfo[["sysname"]]
    if (ssys == "Darwin") {
        output <- get_cmake(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache, formatter=get_mac_format, unpacker=untar)
        return(file.path(output, "CMake.app", "Contents", "bin", "cmake"))
    }

    output <- get_cmake(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache, formatter=get_linux_format, unpacker=untar)
    file.path(output, "bin", "cmake")
}

get_linux_format <- function() {
    sinfo <- Sys.info()
    smach  <- sinfo[["machine"]]
    if (smach == "aarch64") {
        "cmake-%s-linux-aarch64.tar.gz"
    } else {
        "cmake-%s-linux-x86_64.tar.gz"
    }
}

get_mac_format <- function() "cmake-%s-macos-universal.tar.gz"

get_windows_format <- function() {
    sinfo <- Sys.info()
    smach  <- sinfo[["machine"]]
    if (smach %in% c("x86_64", "x86-64")) {
        "cmake-%s-windows-x86_64.zip"
    } else {
        "cmake-%s-windows-arm64.zip"
    }
}

#' @importFrom utils download.file
#' @import dir.expiry
get_cmake <- function(download.version, cache.dir, ignore.cache, formatter, unpacker) {
    output <- file.path(cache.dir, download.version)
    lck <- lockDirectory(output, exclusive=(!file.exists(output) || ignore.cache))
    on.exit(unlockDirectory(lck), add=TRUE, after=FALSE)

    if (ignore.cache) {
        unlink(output, recursive=TRUE)
    }

    if (!file.exists(output)) {
        format <- formatter()
        url <- paste0("https://github.com/Kitware/CMake/releases/download/v", download.version, "/", sprintf(format, download.version))
        full.path <- tempfile()
        if (download.file(url, full.path) != 0) {
            stop("failed to download file from '", url, "'")
        }
        on.exit(unlink(full.path), add=TRUE, after=FALSE)

        tmp <- tempfile(tmpdir=cache.dir)
        on.exit(unlink(tmp, recursive=TRUE), add=TRUE, after=FALSE)
        unpacker(full.path, exdir=tmp)

        listing <- list.files(tmp)
        stopifnot(length(listing) == 1L)
        inner <- file.path(tmp, listing[1]) # reducing some of the nesting.
        if (!file.rename(inner, output)) {
            stop("failed to move cmake binaries to the cache directory")
        }
    }

    touchDirectory(output)
    output
}
