mock <- function() {
    project <- tempfile()
    dir.create(project)

    write(file=file.path(project, "CMakeLists.txt"), '
cmake_minimum_required(VERSION 3.25)

project(bctest VERSION 2.0.1 LANGUAGES CXX)

add_library(superfoo src/superfoo.cpp)
target_include_directories(superfoo PUBLIC include)
')

    dir.create(file.path(project, "src"))
    write(file=file.path(project, "src", "superfoo.cpp"), '
int superfoo(int a, int b) {
    return a + b;
}
')

    dir.create(file.path(project, "include"))
    write(file=file.path(project, "include", "superfoo.h"), '
#ifndef SUPERFOO_H
#define SUPERFOO_H

int superfoo(int, int);

#endif
')

    project
}

compile <- function(command, project) {
    # Removing some of the configuration parameters that we don't need.
    config <- biocmake::configure(c.compiler=FALSE, fortran.compiler=FALSE)
    config.args <- biocmake::formatArguments(config)

    if (.Platform$OS.type == "windows") {
        # No idea why, but it fails for every other name and location. 
        build <- file.path(project, "build")
    } else {
        build <- tempfile()
    }

    status <- system2(command, c(config.args, "-S", project, "-B", build))
    stopifnot(status == 0L)

    status <- system2(command, c("--build", build))
    stopifnot(status == 0L)

    build
}
