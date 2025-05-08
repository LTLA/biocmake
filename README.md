# Cmake for Bioconductor

|Build|Status|
|-----|----|
| Bioc-release | [![](https://bioconductor.org/shields/build/release/bioc/biocmake.svg)](https://bioconductor.org/checkResults/release/bioc-LATEST/biocmake) |
| Bioc-devel   | [![](https://bioconductor.org/shields/build/devel/bioc/biocmake.svg)](https://bioconductor.org/checkResults/devel/bioc-LATEST/biocmake) | 

Manages a Cmake installation for use in building Bioconductor packages,
eliminating the need for manual end-user installation of Cmake via `SystemRequirements: cmake`.
This package is a no-op if a suitably recent version of Cmake is already present on the host machine,
otherwise it fetches Cmake binaries from the [official website](https://cmake.org/download/).

Usage is as simple as calling:

```r
biocmake::find()
```

... to get the path to the Cmake executable, either on the `PATH` if a suitable version already exists or in a **biocmake**-managed installation.
Developers can additionally call `biocmake::configure()` to propagate R's configuration options (e.g., compiler choice) into the Cmake build.
