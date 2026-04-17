.PHONY: help gen build run clean

help:
	@echo "iOS Build commands (run from ios/):"
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
	open -a Simulator

clean:
	rm -rf Voicer.xcodeproj build
