VERSION=$(cat ./VERSION)
tar cfz "aciah_$VERSION.tar.gz" \
    src/* \
    Makefile \
    VERSION \
    README.md
