# library(testthat); library(biocmake); source("test-download.R")

test_that("download() works as expected", {
    path <- download()
    expect_identical(download(), path) # just re-uses the cached path.

    # Checking that we can actually run the binary.
    ver <- biocmake:::get_version(path)
    expect_match(as.character(ver), "^[0-9]+\\.[0-9]+\\.[0-9]+$")
})

test_that("download() works in a mock project", {
    skip_on_os("windows") # Downloaded version doesn't work; use Rtools's version.
    project <- mock()
    build <- compile(download(), project)
    expect_true(file.exists(file.path(build, "libsuperfoo.a")))
})
