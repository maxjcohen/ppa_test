#!/bin/sh

# Copy tarball for orig
cp /orig/* .
cp "$PACKAGE-$VERSION.tar.gz" "${PACKAGE}_${VERSION}.orig.tar.gz"
# Extract tarball
tar xf "$PACKAGE-$VERSION.tar.gz"
cd "$PACKAGE-$VERSION"
# Build package
debuild
# Copy built package to ppa folder
cp ../*deb /ppa
