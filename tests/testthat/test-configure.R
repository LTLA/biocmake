# library(testthat); library(biocmake); source("test-configure.R")

test_that("configure() works with all options on", {
    opt <- configure()
    expect_true(all(startsWith(names(opt), "CMAKE_")))
})

test_that("argument formatting works correctly", {
    out <- formatArguments(c(CMAKE_A="g++", CMAKE_B="foo bar", CMAKE_C=""))
    expect_identical(out[1], "-DCMAKE_A=g++")
    expect_identical(out[2], "-DCMAKE_B='foo bar'")
    expect_identical(out[3], "-DCMAKE_C=''")
})
