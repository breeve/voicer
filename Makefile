.PHONY: help \
	ios-gen ios-build ios-run ios-clean ios-ipa \
	webapp-install webapp-dev webapp-build webapp-preview

help:
	@echo "Voicer - Build commands"
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
	@echo "  Webapp (packages/webapp/):"
	@echo "    make webapp-install       Install npm dependencies"
	@echo "    make webapp-dev           Vite dev server (http://localhost:5173)"
	@echo "    make webapp-build         Production build to packages/webapp/dist/"
	@echo "    make webapp-preview       Preview production build"

# ── iOS ──────────────────────────────────────────────────────────────────
ios-gen:
	cd ios && $(MAKE) gen

ios-build:
	cd ios && $(MAKE) build

ios-run:
	cd ios && $(MAKE) run

ios-clean:
	cd ios && $(MAKE) clean

ios-ipa:
	@if [ -z "$(CODE_SIGN_IDENTITY)" ] || [ -z "$(PROVISIONING_PROFILE)" ]; then \
		echo "Error: CODE_SIGN_IDENTITY and PROVISIONING_PROFILE are required."; \
		echo "Usage: make ios-ipa CODE_SIGN_IDENTITY='...' PROVISIONING_PROFILE='...'"; \
		exit 1; \
	fi
	cd ios && xcodegen generate
	cd ios && xcodebuild -project Voicer.xcodeproj -scheme Voicer \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath build/Voicer.xcarchive \
		CODE_SIGN_STYLE=Manual \
		CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY)" \
		PROVISIONING_PROFILE="$(PROVISIONING_PROFILE)" \
		archive
	@mkdir -p ios/build
	@printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0">\n<dict>\n\t<key>method</key>\n<string>ad-hoc</string>\n</dict>\n</plist>\n' > /tmp/Voicer_export.plist
	xcodebuild -exportArchive \
		-archivePath ios/build/Voicer.xcarchive \
		-exportPath ios/build \
		-exportOptionsPlist /tmp/Voicer_export.plist \
		-sign "$(CODE_SIGN_IDENTITY)"
	@echo ""
	@echo "IPA built: ios/build/Voicer.ipa"
	@echo "To install: open ios/build/Voicer.ipa in Xcode, or use:"
	@echo "  xcrun devicectl install <device-udid> ios/build/Voicer.ipa"

# ── Webapp (packages/webapp/) ─────────────────────────────────────────────
WEBAPP_DIR := packages/webapp

webapp-install:
	cd $(WEBAPP_DIR) && npm install

webapp-dev:
	cd $(WEBAPP_DIR) && npm run dev

webapp-build:
	cd $(WEBAPP_DIR) && npm run build

webapp-preview:
	cd $(WEBAPP_DIR) && npm run preview