#' Find Cmake 
#'
#' Find an existing Cmake installation or, if none can be found, install a \pkg{biocmake}-managed Cmake instance.
#'
#' @param command String containing the command to check for an existing installation.
#' @param minimum.version String specifying the minimum acceptable version of an existing installation.
#' @param can.download Logical scalar indicating whether to download Cmake if no acceptable existing installation can be found.
#' @param ... Further arguments to pass to \code{\link{download}}.
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
    ...)
{
    override <- Sys.getenv("BIOCMAKE_CMAKE_PATH", NA)
    if (!is.na(override)) {
        return(override)
    }

    test <- system2(command, "--version", stdout=TRUE)
    vstring <- test[grep("cmake version ", test[1])]
    vstring <- gsub("cmake version ", "", vstring)
    version <- package_version(vstring)

    if (version >= minimum.version) {
        return(command)
    }

    if (!can.download) {
        return(NULL)
    }

    download(...)
}

