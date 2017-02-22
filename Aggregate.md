###Aggregate framework 合并脚本

```
FMK_NAME="HWFunctional"

INSTALL_DIR=${SRCROOT}/Products/${FMK_NAME}.framework

WRK_DIR=build

DEVICE_DIR=${WRK_DIR}/Release-iphoneos/${FMK_NAME}.framework

SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator/${FMK_NAME}.framework

xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphoneos clean build
xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphonesimulator clean build

if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi
mkdir -p "${INSTALL_DIR}"
cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"

lipo -create "${DEVICE_DIR}/${FMK_NAME}" "${SIMULATOR_DIR}/${FMK_NAME}" -output "${INSTALL_DIR}/${FMK_NAME}"

rm -r "${WRK_DIR}"
open "${INSTALL_DIR}"
```