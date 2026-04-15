.PHONY: help ios-gen ios-build ios-run ios-clean ios-ipa \
         web-install web-dev web-build web-preview \
         mac-install mac-electron-dev mac-electron-build mac-electron-build-dir

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
	@echo "  Web:"
	@echo "    make web-install   Install npm dependencies"
	@echo "    make web-dev       Vite dev server (http://localhost:5173)"
	@echo "    make web-build     Production build to web/dist/"
	@echo "    make web-preview   Preview production build"
	@echo ""
	@echo "  macOS Desktop:"
	@echo "    make mac-install   Install npm dependencies"
	@echo "    make mac-electron-dev     Run Electron in dev mode"
	@echo "    make mac-electron-build    Build macOS dmg + zip"
	@echo "    make mac-electron-build-dir   Build macOS app (no dmg)"
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

# ── Web ──────────────────────────────────────────────────────────────────
web-install:
	cd web && ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ npm install

web-dev:
	cd web && npm run dev

web-build:
	cd web && npm run build

web-preview:
	cd web && npm run preview

# ── macOS Desktop ────────────────────────────────────────────────────────
mac-install:
	cd mac && npm install

mac-electron-dev: mac-install
	cd mac && npm run electron:dev

mac-electron-build: mac-install
	cd mac && npm run electron:build

mac-electron-build-dir: mac-install
	cd mac && npm run electron:build:dir
