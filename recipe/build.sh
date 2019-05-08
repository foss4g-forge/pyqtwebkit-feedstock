#!/bin/bash

set -e # Abort on error.

declare -a _extra_modules
# Avoid Xcode
if [[ ${HOST} =~ .*darwin.* ]]; then
  PATH=${PREFIX}/bin/xc-avoidance:${PATH}
    _extra_modules+=(--enable)
    _extra_modules+=(QtMacExtras)
else
    _extra_modules+=(--enable)
    _extra_modules+=(QtX11Extras)
fi

# Dumb .. is this Qt or PyQt's fault? (or mine, more likely).
# The spec file could be bad, or PyQt could be missing the
# ability to set QMAKE_CXX
mkdir bin || true
pushd bin
  ln -s ${GXX} g++ || true
  ln -s ${GCC} gcc || true
popd
export PATH=${PWD}/bin:${PATH}

## START BUILD
$PYTHON configure.py \
        --verbose \
        --confirm-license \
        --assume-shared \
        --enable=QtWebKit \
        --enable=QtWebKitWidgets \
        --no-designer-plugin \
        --no-python-dbus \
        --no-qml-plugin \
        --no-qsci-api \
        --no-sip-files \
        --no-tools \
        "${_extra_modules[@]}" \
        -q ${PREFIX}/bin/qmake
make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

# clean out non-WebKit artifacts (already installed by pyqt)
# rm -R ${PREFIX}/"share"
# cd "#{lib}/python#{version}/site-packages/PyQt5" do
#   rm "__init__.py"
#   rm "Qt.so"
#   rm_r "uic"
# end
