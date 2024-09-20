# library(testthat); library(biocmake); source("setup.R"); source("test-find.R")

test_that("find() returns a valid path", {
    out <- find()
    expect_true(Sys.which(out) != "" || file.exists(out))

    ver <- biocmake:::get_version(out)
    expect_match(as.character(ver), "^[0-9]+\\.[0-9]+\\.[0-9]+$")
})

test_that("find() respects the minimum required version", {
    out <- find(minimum.version=package_version("1000.1000.1000"), can.download=FALSE)
    expect_null(out)
})

test_that("find() respects the override", {
    old <- Sys.getenv("BIOCMAKE_FIND_OVERRIDE", NA)
    Sys.setenv(BIOCMAKE_FIND_OVERRIDE="foobar")
    if (is.na(old)) {
        on.exit(Sys.unsetenv("BIOCMAKE_FIND_OVERRIDE"))
    } else {
        Sys.setenv(BIOCMAKE_FIND_OVERRIDE=old)
    }

    out <- find()
    expect_identical(out, "foobar")
})

test_that("find() works in a mock project", {
    project <- mock()
    build <- compile(find(), project)
    expect_true(file.exists(file.path(build, "libsuperfoo.a")))
})
