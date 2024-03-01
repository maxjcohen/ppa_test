#!/bin/sh

# Copy tarball for orig
cp /orig/* .
cp "$PACKAGE-$VERSION.tar.gz" "${PACKAGE}_${VERSION}.orig.tar.gz"
# Extract tarball
tar xf "$PACKAGE-$VERSION.tar.gz"
cd "$PACKAGE-$VERSION"
# Build package
debuild
# Create the Package and Package.gz files
cd ..
dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages
apt-ftparchive release . > Release
# Copy built package to ppa folder
cp *deb /ppa
cp Packages /ppa
cp Packages.gz /ppa
cp Release /ppa
