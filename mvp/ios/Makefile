.PHONY: help gen build run clean

help:
	@echo "iOS Build commands (run from mvp/ios/):"
	@echo "  make gen     Generate Xcode project with XcodeGen"
	@echo "  make build   Build for iOS Simulator"
	@echo "  make run     Open in iOS Simulator"
	@echo "  make clean   Remove generated project"
	@echo ""
	@echo "Prerequisites: xcodegen must be installed (brew install xcodegen)"

gen:
	xcodegen generate

build: gen
	xcodebuild -project Voicer.xcodeproj -scheme Voicer -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16' build

run: build
	xcrun simctl boot $(xcrun simctl list devices available | grep "iPhone 16" | head -1 | awk '{print $$1}')
	open -a Simulator
	xcodebuild -project Voicer.xcodeproj -scheme Voicer -destination 'platform=iOS Simulator,name=iPhone 16' build

clean:
	rm -rf Voicer.xcodeproj build
