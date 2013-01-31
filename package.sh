#!/bin/bash

SHOULD_GENERATE_DOCS=${1-true}

DEPLOY_DIR="cloudmine-ios"
ARCHIVE_NAME="$DEPLOY_DIR.tgz"

echo "Removing old build directory..."
rm -rf "./ios/build"

echo "Re-building release framework..."
env CC='' xcodebuild -scheme "CloudMine Universal Framework" -configuration Release -workspace cm-ios.xcworkspace

# Generate File Documentation
if $SHOULD_GENERATE_DOCS ; then
  echo "Beginning documentation generation..."
  cd ./ios
  doxygen ios/Doxyfile
  cd ../
else
  echo "Skipping documentation generation..."
fi

echo "Copying files to deploy..."
mkdir $DEPLOY_DIR
cp -R "ios/build/Release-iphoneuniversal/CloudMine.framework" $DEPLOY_DIR
cp -R "ios/docs" $DEPLOY_DIR
cp *.md $DEPLOY_DIR
cp LICENSE $DEPLOY_DIR

echo "Tarballing deploy directory..."
if [ -e $ARCHIVE_NAME ]; then
  rm $ARCHIVE_NAME
fi
tar -cvf $ARCHIVE_NAME $DEPLOY_DIR
rm -rf $DEPLOY_DIR
