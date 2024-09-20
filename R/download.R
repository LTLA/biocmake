#' Download Cmake
#'
#' Download Cmake binaries for the current architecture.
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
download <- function(download.version=defaultDownloadVersion(), cache.dir=defaultCacheDirectory(), ignore.cache=FALSE) {
    if (.Platform$OS.type == "windows") {
        return(get_cmake_windows(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache))
    }

    sinfo <- Sys.info()
    ssys <- sinfo[["sysname"]]
    if (ssys == "Darwin") {
        return(get_cmake_macos(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache))
    } 

    return(get_cmake_linux(download.version, cache.dir=cache.dir, ignore.cache=ignore.cache))
}

release_url <- function(download.version, format) {
    paste0("https://github.com/Kitware/CMake/releases/download/v", download.version, "/", sprintf(format, download.version))
}

#' @importFrom utils download.file
quick_download <- function(url) {
    tmp <- tempfile()
    if (download.file(url, tmp) != 0) {
        stop("failed to download file from '", url, "'")
    }
    tmp
}

#' @importFrom utils untar
robust_unpack <- function(archive, dest, FUN=untar) {
    parent <- dirname(dest)
    dir.create(parent, recursive=TRUE, showWarnings=FALSE)

    tmp <- tempfile(tmpdir=parent)
    on.exit(unlink(tmp, recursive=TRUE))

    FUN(archive, exdir=tmp)
    listing <- list.files(tmp)
    stopifnot(length(listing) == 1L)
    inner <- file.path(tmp, listing[1]) # reducing some of the nesting.

    if (!file.exists(dest)) { 
        # This should be atomic enough to protect against multiple processes
        # trying to do this at the same time. I suppose we could be more
        # rigorous with a filelock but why bother.
        file.rename(inner, dest)
    }
}

get_cmake_linux <- function(download.version, cache.dir, ignore.cache) {
    output <- file.path(cache.dir, download.version)
    if (ignore.cache) {
        unlink(output, recursive=TRUE)
    }

    if (!file.exists(output)) {
        sinfo <- Sys.info()
        smach  <- sinfo[["machine"]]
        if (smach == "aarch64") {
            format <- "cmake-%s-linux-aarch64.tar.gz"
        } else {
            format <- "cmake-%s-linux-x86_64.tar.gz"
        }
        url <- release_url(download.version, format)
        full.path <- quick_download(url)
        on.exit(unlink(full.path))
        robust_unpack(full.path, output)
    }

    file.path(output, "bin", "cmake")
}

get_cmake_macos <- function(download.version, cache.dir, ignore.cache) {
    output <- file.path(cache.dir, download.version)
    if (ignore.cache) {
        unlink(output, recursive=TRUE)
    }

    if (!file.exists(output)) {
        format <- "cmake-%s-macos-universal.tar.gz"
        url <- release_url(download.version, format)
        full.path <- quick_download(url)
        on.exit(unlink(full.path))
        robust_unpack(full.path, output)
    }

    file.path(output, "CMake.app", "Contents", "bin", "cmake")
}

#' @importFrom utils unzip
get_cmake_windows <- function(download.version, cache.dir, ignore.cache) {
    output <- file.path(cache.dir, download.version)
    if (ignore.cache) {
        unlink(output, recursive=TRUE)
    }

    if (!file.exists(output)) {
        sinfo <- Sys.info()
        smach  <- sinfo[["machine"]]
        if (smach %in% c("x86_64", "x86-64")) {
            format <- "cmake-%s-windows-x86_64.zip"
        } else {
            format <- "cmake-%s-windows-arm64.zip"
        }

        url <- release_url(download.version, format)
        full.path <- quick_download(url)
        on.exit(unlink(full.path))
        robust_unpack(full.path, output, FUN=unzip)
    }

    file.path(output, "bin", "cmake.exe")
}
