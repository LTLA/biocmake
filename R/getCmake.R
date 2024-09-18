#' @export
getCmake <- function(download=TRUE) {
    override <- Sys.getenv("BIOCMAKE_CMAKE_PATH", NA)
    if (!is.na(override)) {
        return(override)
    }

    test <- system2("cmake", "--version", stdout=TRUE)
    vstring <- test[grep("cmake version ", test[1])]
    vstring <- gsub("cmake version ", "", vstring)
    version <- package_version(vstring)

    required_version <- Sys.getenv("BIOCMAKE_CMAKE_MINIMUM_VERSION", "3.24.0")
    if (version >= required_version) {
        return("cmake")
    }

    if (!download) {
        return(NULL)
    }

    sinfo <- Sys.info()
    ssys <- sinfo[["sysname"]]
    download_version <- Sys.getenv("BIOCMAKE_CMAKE_DOWNLOAD_VERSION", "3.30.3")

    if (ssys == "Linux") {
        return(get_cmake_linux(download_version))
    } else if (ssys == "Darwin") {
        return(get_cmake_macos(download_version))
    } else {
        # TODO
        stop("unsupported operating system")
    }
}

#' @importFrom tools R_user_dir
create_cache <- function(download_version) {
    dir <- R_user_dir("biocmake", "cache")
}

release_url <- function(download_version, format) {
    paste0("https://github.com/Kitware/CMake/releases/download/v", download_version, "/", sprintf(format, download_version))
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
robust_unpack <- function(tarfile, dest) {
    parent <- dirname(dest)
    dir.create(parent, recursive=TRUE, showWarnings=FALSE)
    tmp <- tempfile(tmpdir=parent)
    on.exit(unlink(tmp, recursive=TRUE))

    untar(tarfile, exdir=tmp)
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

get_cmake_linux <- function(download_version) {
    smach  <- sinfo[["machine"]]
    if (smach == "aarch64") {
        format <- "cmake-%s-linux-aarch64.tar.gz"
    } else {
        format <- "cmake-%s-linux-x86_64.tar.gz"
    }
    url <- release_url(download_version, format)

    cache <- create_cache(download_version)
    output <- file.path(cache, download_version)
    if (!file.exists(output)) {
        full.path <- quick_download(url)
        on.exit(unlink(full.path))
        robust_unpack(full.path, output)
    }

    file.path(output, "bin", "cmake")
}

get_cmake_macos <- function(download_version) {
    format <- "cmake-%s-macos-universal.tar.gz"
    url <- release_url(download_version, format)

    cache <- create_cache(download_version)
    output <- file.path(cache, download_version)
    if (!file.exists(output)) {
        full.path <- quick_download(url)
        on.exit(unlink(full.path))
        robust_unpack(full.path, output)
    }

    file.path(output, "CMake.app", "Contents", "bin", "cmake")
}
