.PHONY: help install dev build preview

help:
	@echo "Voicer MVP - Makefile commands"
	@echo ""
	@echo "  make install   安装依赖"
	@echo "  make dev       开发模式运行（http://localhost:5173）"
	@echo "  make build     构建生产版本到 dist/"
	@echo "  make preview   预览生产构建"
	@echo ""

install:
	cd mvp && npm install

dev:
	cd mvp && npm run dev

build:
	cd mvp && npm run build

preview:
	cd mvp && npm run preview
