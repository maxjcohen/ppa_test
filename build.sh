# Define package full name and version
VERSION=$(cat ./VERSION)
PACKAGE_NAME="aciah_$VERSION"
# Create temporary directory
mkdir -p /tmp/$PACKAGE_NAME
cp -r ./* /tmp/$PACKAGE_NAME
mv /tmp/$PACKAGE_NAME .
# Create tarball
tar cfz "aciah_$VERSION.tar.gz" $PACKAGE_NAME
# Remove temporary directory
rm -r $PACKAGE_NAME
