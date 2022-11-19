#!/bin/sh

flutter clean

rm -rf build
cd ios
rm -rf Podspec Podfile Podfile.lock Pods/

cd ..

rm -rf .packages .flutter-plugins
flutter packages get

cd ios

pod cache clean --all
# pod repo remove trunk
# pod repo update
pod setup
pod install

cd ..
