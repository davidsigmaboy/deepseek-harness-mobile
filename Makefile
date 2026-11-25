# DeepSeek Harness Mobile — build orchestration.
#
# `make fetch` works anywhere with git. `make ipa` requires macOS with Xcode,
# brew (meson, ninja, lld, libarchive) and network access; the GitHub Actions
# workflow runs the equivalent steps on a macos-15 runner and is the
# supported way to build.

UPSTREAM_DIR := upstream

.PHONY: fetch ipa clean

fetch:
	bash scripts/fetch-upstream.sh

ipa: fetch
	$(MAKE) -C $(UPSTREAM_DIR) emulator
	$(MAKE) -C $(UPSTREAM_DIR) rootfs
	$(MAKE) -C $(UPSTREAM_DIR) project
	cd $(UPSTREAM_DIR) && xcodebuild \
	  -project DSH.xcodeproj -scheme DSH -configuration Release \
	  -destination 'generic/platform=iOS' \
	  -archivePath "$$PWD/build/DSH.xcarchive" \
	  -derivedDataPath "$$PWD/build/DerivedData" \
	  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
	  CODE_SIGN_ENTITLEMENTS="" DEVELOPMENT_TEAM="" PROVISIONING_PROFILE_SPECIFIER="" \
	  COMPILER_INDEX_STORE_ENABLE=NO archive
	@echo "Unsigned archive: $(UPSTREAM_DIR)/build/DSH.xcarchive"
	@echo "Zip its Payload/ directory into a .ipa to sideload (see README)."

clean:
	rm -rf $(UPSTREAM_DIR)/build
