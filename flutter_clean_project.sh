flutter clean
flutter pub get

rm -rf ~/Library/Developer/Xcode/DerivedData

cd ios                                      
rm -rf Pods
rm -rf Podfile.lock
pod install
cd ..
