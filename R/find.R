#' Find Cmake 
#'
#' Find an existing Cmake installation or, if none can be found, install a \pkg{biocmake}-managed Cmake instance.
#'
#' @param command String containing the command to check for an existing installation.
#' @param minimum.version String specifying the minimum acceptable version of an existing installation.
#' @param can.download Logical scalar indicating whether to download Cmake if no acceptable existing installation can be found.
#' @param forget Logical scalar indicating whether to forget the results of the last call.
#' @param ... Further arguments to pass to \code{\link{download}}.
#'
#' @details
#' If the \code{BIOCMAKE_FIND_OVERRIDE} environment variable is set to a command or path to a Cmake executable, it is returned directly and all other options are ignored.
#'
#' On Windows, it is strongly recommended to download Rtools (see \url{https://cran.r-project.org/bin/windows/Rtools/rtools44/rtools.html}).
#' This provides a pre-configured Cmake that is guaranteed to work.
#'
#' By default, \code{find} will remember the result of its last call in the current R session, to avoid re-checking the versions, cache, etc.
#' This can be disabled by setting \code{forget=TRUE} to force a re-check, e.g., to detect a new version of Cmake that was installed while the R session is active.
#'
#' @return String containing the command to use to run Cmake.
#'
#' @author Aaron Lun
#' @examples
#' cmd <- find()
#' system2(cmd, "--version")
#'
#' @export
find <- function(
    command=defaultCommand(),
    minimum.version=defaultMinimumVersion(),
    can.download=TRUE,
    forget=FALSE,
    ...)
{
    if (!forget && !is.na(cached$previous)) {
        return(cached$previous)
    }

    override <- Sys.getenv("BIOCMAKE_FIND_OVERRIDE", NA)
    if (!is.na(override)) {
        cached$previous <- override
        return(override)
    }

    if (Sys.which(command) != "") {
        version <- get_version(command)
        if (!is.na(version) && version >= minimum.version) {
            cached$previous <- command
            return(command)
        }
    }

    if (!can.download) {
        cached$previous <- NULL
        return(NULL)
    }

    acquired <- download(...)
    cached$previous <- acquired
    acquired 
}

get_version <- function(command) {
    test <- system2(command, "--version", stdout=TRUE)
    vstring <- test[grep("cmake version ", test[1])]
    vstring <- gsub("cmake version ", "", vstring)
    to_version(vstring)
}

to_version <- function(version) {
    # Remove modifiers like -alpha, -beta, rc1, etc.
    if (grepl("^[0-9]+\\.[0-9]+\\.[0-9]+[^0-9]", version)) {
        version <- sub("^([0-9]+\\.[0-9]+\\.[0-9]+)[^0-9].*", "\\1", version)
    }
    package_version(version, strict=FALSE)
}

cached <- new.env()
cached$previous <- NA
