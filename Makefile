.PHONY: help \
	ios-gen ios-build ios-run ios-clean ios-ipa \
	web-install web-dev web-build web-preview \
	web-package-win web-package-mac web-package-linux web-package-all

help:
	@echo "Voicer MVP - Unified Makefile"
	@echo ""
	@echo "  iOS:"
	@echo "    make ios-gen        Generate Xcode project"
	@echo "    make ios-build     Build for iOS Simulator"
	@echo "    make ios-run       Build and launch in Simulator"
	@echo "    make ios-clean     Remove generated project"
	@echo "    make ios-ipa       Build IPA package for device"
	@echo "      Required env: CODE_SIGN_IDENTITY, PROVISIONING_PROFILE"
	@echo "      Example:"
	@echo "        make ios-ipa CODE_SIGN_IDENTITY='Apple Development: Name (TEAMID)' PROVISIONING_PROFILE='Your Profile'"
	@echo ""
	@echo "  Web (packages/web/):"
	@echo "    make web-install       Install npm dependencies"
	@echo "    make web-dev           Vite dev server (http://localhost:5173)"
	@echo "    make web-build         Production build to packages/web/dist/"
	@echo "    make web-preview       Preview production build"
	@echo "    make web-package-win   Build Windows installer (.exe)"
	@echo "    make web-package-mac   Build macOS app (.dmg)"
	@echo "    make web-package-linux Build Linux AppImage"
	@echo "    make web-package-all   Build all platforms"
	@echo ""

# ── iOS ──────────────────────────────────────────────────────────────────
ios-gen:
	cd mvp/ios && $(MAKE) gen

ios-build:
	cd mvp/ios && $(MAKE) build

ios-run:
	cd mvp/ios && $(MAKE) run

ios-clean:
	cd mvp/ios && $(MAKE) clean

ios-ipa:
	@if [ -z "$(CODE_SIGN_IDENTITY)" ] || [ -z "$(PROVISIONING_PROFILE)" ]; then \
		echo "Error: CODE_SIGN_IDENTITY and PROVISIONING_PROFILE are required."; \
		echo "Usage: make ios-ipa CODE_SIGN_IDENTITY='...' PROVISIONING_PROFILE='...'"; \
		exit 1; \
	fi
	cd mvp/ios && xcodegen generate
	cd mvp/ios && xcodebuild -project Voicer.xcodeproj -scheme Voicer \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath build/Voicer.xcarchive \
		CODE_SIGN_STYLE=Manual \
		CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY)" \
		PROVISIONING_PROFILE="$(PROVISIONING_PROFILE)" \
		archive
	@mkdir -p mvp/ios/build
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>method</key>\n\t<string>ad-hoc</string>\n</dict>\n</plist>\n' > /tmp/Voicer_export.plist
	xcodebuild -exportArchive \
		-archivePath mvp/ios/build/Voicer.xcarchive \
		-exportPath mvp/ios/build \
		-exportOptionsPlist /tmp/Voicer_export.plist \
		-sign "$(CODE_SIGN_IDENTITY)"
	@echo ""
	@echo "IPA built: mvp/ios/build/Voicer.ipa"
	@echo "To install: open mvp/ios/build/Voicer.ipa in Xcode, or use:"
	@echo "  xcrun devicectl install <device-udid> mvp/ios/build/Voicer.ipa"

# ── Web (packages/web/) ────────────────────────────────────────────────────
WEB_DIR := packages/web

web-install:
	cd $(WEB_DIR) && npm install

web-dev:
	cd $(WEB_DIR) && npm run dev

web-build:
	cd $(WEB_DIR) && npm run build

web-preview:
	cd $(WEB_DIR) && npm run preview

# Package targets: build web + build electron + electron-builder
web-package-win: web-build
	cd $(WEB_DIR) && npm run build:electron && npx electron-builder --win

web-package-mac: web-build
	cd $(WEB_DIR) && npm run build:electron && npx electron-builder --mac

web-package-linux: web-build
	cd $(WEB_DIR) && npm run build:electron && npx electron-builder --linux

web-package-all: web-build
	cd $(WEB_DIR) && npm run build:electron && npx electron-builder --linux