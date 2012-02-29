#!/bin/bash

DEPLOY_DIR="cloudmine-framework-release"
ARCHIVE_NAME="$DEPLOY_DIR.tgz"

echo "Removing old build directory..."
rm -rf "./ios/build"

echo "Re-building release framework..."
env --unset=CC xcodebuild -scheme "CloudMine Universal Framework" -configuration Release -workspace cm-ios.xcworkspace

echo "Beginning documentation generation..."
cd ./ios
doxygen ios/Doxyfile
cd ../

echo "Copying files to deploy..."
mkdir $DEPLOY_DIR
cp -R "ios/build/Release-iphoneuniversal/CloudMine.framework" $DEPLOY_DIR
cp -R "ios/docs" $DEPLOY_DIR

echo "Tarballing deploy directory..."
if [ -e $ARCHIVE_NAME ]; then
  rm $ARCHIVE_NAME
fi
tar -cvf cloudmine-framework-release.tgz $DEPLOY_DIR
rm -rf $DEPLOY_DIR
