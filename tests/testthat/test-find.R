# library(testthat); library(biocmake); source("setup.R"); source("test-find.R")

test_that("find() returns a valid path", {
    out <- find()
    expect_true(Sys.which(out) != "" || file.exists(out))

    ver <- biocmake:::get_version(out)
    expect_match(as.character(ver), "^[0-9]+\\.[0-9]+\\.[0-9]+$")
})

test_that("find() respects the minimum required version", {
    out <- find(minimum.version=package_version("1000.1000.1000"), can.download=FALSE, forget=TRUE)
    on.exit(find(forget=TRUE)) # avoid caching a weird path.
    expect_null(out)
})

reset_override <- function(old) {
    if (is.na(old)) {
        Sys.unsetenv("BIOCMAKE_FIND_OVERRIDE")
    } else {
        Sys.setenv(BIOCMAKE_FIND_OVERRIDE=old)
    }
}

test_that("find() respects the override", {
    old <- Sys.getenv("BIOCMAKE_FIND_OVERRIDE", NA)
    Sys.setenv(BIOCMAKE_FIND_OVERRIDE="foobar")
    on.exit(reset_override(old))

    out <- find(forget=TRUE)
    on.exit(find(forget=TRUE), after=TRUE, add=TRUE) # avoid caching a weird path.
    expect_identical(out, "foobar")
})

test_that("find() remembers previous calls", {
    out <- find()

    old <- Sys.getenv("BIOCMAKE_FIND_OVERRIDE", NA)
    Sys.setenv(BIOCMAKE_FIND_OVERRIDE="harvester")
    on.exit(reset_override(old))

    out2 <- find()
    expect_identical(out2, out) 

    out3 <- find(forget=TRUE)
    on.exit(find(forget=TRUE), after=TRUE, add=TRUE) # avoid caching a weird path.
    expect_identical(out3, "harvester") 

    Sys.unsetenv("BIOCMAKE_FIND_OVERRIDE")
    out4 <- find()
    expect_identical(out4, "harvester") 

    out5 <- find(forget=TRUE)
    expect_identical(out5, out) 
})

test_that("find() works in a mock project", {
    project <- mock()
    build <- compile(find(), project)
    expect_true(file.exists(file.path(build, "libsuperfoo.a")))
})

test_that("to_version() works for weird versions", {
    expect_identical(biocmake:::to_version("1.1.1-alpha"), package_version("1.1.1"))
    expect_identical(biocmake:::to_version("3.23.39a"), package_version("3.23.39"))
    expect_identical(biocmake:::to_version("4.0.2-dirty"), package_version("4.0.2"))
    expect_true(is.na(biocmake:::to_version("1.1-foo")))
})
