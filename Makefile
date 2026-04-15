.PHONY: help ios-gen ios-build ios-run ios-clean \
         web-install web-dev web-build web-preview \
         mac-install mac-electron-dev mac-electron-build mac-electron-build:dir

help:
	@echo "Voicer MVP - Unified Makefile"
	@echo ""
	@echo "  iOS:"
	@echo "    make ios-gen        Generate Xcode project"
	@echo "    make ios-build     Build for iOS Simulator"
	@echo "    make ios-run       Build and launch in Simulator"
	@echo "    make ios-clean     Remove generated project"
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
	@echo "    make mac-electron-build:dir Build macOS app (no dmg)"
	@echo ""

# ── iOS ──────────────────────────────────────────────────────────────────
ios-gen:
	cd ios && $(MAKE) gen

ios-build:
	cd ios && $(MAKE) build

ios-run:
	cd ios && $(MAKE) run

ios-clean:
	cd ios && $(MAKE) clean

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

mac-electron-build:dir: mac-install
	cd mac && npm run electron:build:dir
