VERSION = 1.0
PRODUCT = diskspace

BINARY = diskspace
SWIFT_OUT = .build/apple/Products/Release/${PRODUCT}

PKG_ROOT = .build/packages/${PRODUCT}-${VERSION}
PKG_DIR =  ${PKG_ROOT}/usr/local/bin
PKG_DMG = ./Packages/${PRODUCT}-${VERSION}.dmg
PKG_DMG_ROOT = ./Packages
PKG = ${PKG_DMG_ROOT}/${PRODUCT}-${VERSION}.pkg

CODESIGN_IDENTITY = "Developer ID Application: University of Michigan (D9GZK3CLYY)"
PKG_CODESIGN_IDENTITY = "Developer ID Installer: University of Michigan (D9GZK3CLYY)"
BUNDLE_ID = edu.umich.its.${PRODUCT}
USERNAME = jamesez@umich.edu
PASSWORD_ID = jamesez-altool
ASC_PROVIDER = D9GZK3CLYY


${BINARY}:
	swift build -c release --product ${PRODUCT}  --arch arm64 --arch x86_64
	xcrun codesign -s ${CODESIGN_IDENTITY} \
               --options=runtime \
               --timestamp \
               ${SWIFT_OUT}
	rm -rf out || true
	mkdir -p Binaries
	cp ${SWIFT_OUT} Binaries/${BINARY}

${PKG}: Binaries/${BINARY}
	rm -rf "${PKG_ROOT}" || true
	rm -rf "${PKG_DMG_ROOT}" || true
	mkdir -p ${PKG_DIR}
	mkdir -p ${PKG_DMG_ROOT}
	cp Binaries/${BINARY} ${PKG_DIR}
	xcrun pkgbuild --root ${PKG_ROOT} \
           --identifier "${BUNDLE_ID}" \
           --version "${VERSION}" \
           --install-location "/" \
           --sign ${PKG_CODESIGN_IDENTITY} \
           ${PKG}

${PKG_DMG}: ${PKG} staple
	hdiutil create -volname "${PRODUCT}" -srcfolder "${PKG_DMG_ROOT}" -ov -format UDZO "${PKG_DMG}"

.PHONY: build
build: ${BINARY}

.PHONY: package
package: ${PKG}

.PHONY: notarize
notarize: ${PKG}
	xcrun altool --notarize-app \
               --primary-bundle-id ${BUNDLE_ID} \
               --username "${USERNAME}" \
               --password "@keychain:${PASSWORD_ID}" \
               --asc-provider ${ASC_PROVIDER} \
               --file "${PKG}"

.PHONY: staple
staple:
	xcrun stapler staple "${PKG}"

.PHONY: image
image: ${PKG_DMG}

.PHONY: clean
clean:
	rm -rf Packages Binaries .build
