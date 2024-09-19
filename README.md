# Cmake for Bioconductor

Manages a Cmake installation for use in building Bioconductor packages,
eliminating the need for manual end-user installation of Cmake via `SystemRequirements: cmake`.
This package is a no-op if a suitable version of Cmake is already present on the host machine,
otherwise it pulls down and installs Cmake from the [official website](https://cmake.org/download/).

Usage is as simple as calling:

```r
biocmake::find()
```

... to get the path to the Cmake executable, either on the `PATH` if a suitable version already exists or in a **biocmake**-managed installation.
Developers can additionally call `biocmake::configure()` to propagate R's configuration options (e.g., compiler choice) into the Cmake build.
