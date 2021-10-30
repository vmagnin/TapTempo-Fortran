#!/bin/bash

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ FC='gfortran-8' ./build.sh
# Default:
: ${FC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

"${FC}" src/taptempo.f90 app/main.f90 -o build/taptempo

rm -f *.mod
