# ──────────────────────
# 🚀 DEPLOYMENT COMMANDS
# ──────────────────────

BUILD_NAME=$(shell grep '^version: ' pubspec.yaml | cut -d+ -f1 | sed 's/version: //')
BUILD_NUMBER=$(shell grep '^version: ' pubspec.yaml | cut -d+ -f2)

.PHONY: help-deploy
help-deploy:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ─────────── VERSION ───────────

.PHONY: increment-build
increment-build:
	@sed -i '' 's/\(^version: *[0-9.]*\)+\([0-9]*\)/\1+'"$$(($$(grep '^version:' pubspec.yaml | cut -d+ -f2) + 1))"'/' pubspec.yaml
	@echo "\nBuild number incremented to $$(($(BUILD_NUMBER) + 1))\n"

.PHONY: pre-build
pre-build: increment-build clean_all gen

# ─────────── WEB: Telegram Mini App → Firebase Hosting ───────────

.PHONY: tma
tma: pre-build ## Build & deploy Telegram Mini App to Firebase Hosting
	@if [ -d "packages/quizlymarket_landing" ]; then \
		cd packages/quizlymarket_landing && npm install && npm run build && \
		mkdir -p ../../web/landing && \
		cp -R dist/* ../../web/landing/ ; \
	fi
	@echo '{"version":"$(shell date +%s)"}' > web/version.json
	@$(FLUTTER) build web --release --source-maps \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=web
	@sed -i '' '/sourceMappingURL=flutter\.js\.map/d' build/web/flutter.js || true
	@firebase deploy --only hosting

# ─────────── WEB: Own Server Deploy ───────────

DEPLOY_HOST := corelabs-server
DEPLOY_PATH := /opt/quizly/web/

.PHONY: web-deploy
web-deploy: pre-build ## Build & deploy web to quizlymarket.corelabs.uz (own server)
	@if [ -d "packages/quizlymarket_landing" ]; then \
		cd packages/quizlymarket_landing && npm install && npm run build && \
		mkdir -p ../../web/landing && \
		cp -R dist/* ../../web/landing/ ; \
	fi
	@echo '{"version":"$(shell date +%s)"}' > web/version.json
	@$(FLUTTER) build web --release --source-maps \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=web
	@sed -i '' '/sourceMappingURL=flutter\.js\.map/d' build/web/flutter.js || true
	@rsync -avz --delete build/web/ $(DEPLOY_HOST):$(DEPLOY_PATH)

# ─────────── iOS ───────────

.PHONY: ipa
ipa: pre-build ## Build iOS IPA (development)
	@$(FLUTTER) build ipa \
		--build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) \
		--dart-define-from-file=config/development.json \
		--dart-define=config.platform=ios
	@open build/ios/archive/Runner.xcarchive

.PHONY: ipa-prod
ipa-prod: pre-build ## Build iOS IPA (production) and open Xcode to upload
	@$(FLUTTER) build ipa \
		--build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=ios
	@open build/ios/archive/Runner.xcarchive

# ─────────── Android ───────────

.PHONY: apk
apk: pre-build ## Build Android APK (development)
	@$(FLUTTER) build apk --release \
		--build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) \
		--dart-define-from-file=config/development.json \
		--dart-define=config.platform=android
	@open build/app/outputs/apk/release/

.PHONY: aab
aab: pre-build ## Build Android AAB (production) for Play Store
	@$(FLUTTER) build appbundle --release \
		--build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=android
	@open build/app/outputs/bundle/release/

# ─────────── macOS ───────────

.PHONY: macos
macos: pre-build ## Build macOS for App Store (archive via Xcode)
	@$(FLUTTER) build macos --release \
		--build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=macos
	@open macos/Runner.xcworkspace

.PHONY: macos-dmg
macos-dmg: pre-build ## Build macOS DMG (direct distribution)
	@brew install create-dmg || true
	@$(FLUTTER) build macos --release \
		--dart-define-from-file=config/production.json \
		--dart-define=config.platform=macos
	@rm -f QuizlyMarket.dmg
	@create-dmg \
		--volname "QuizlyMarket" \
		--window-size 600 400 \
		--icon-size 100 \
		--app-drop-link 450 200 \
		"QuizlyMarket.dmg" \
		"build/macos/Build/Products/Release/QuizlyMarket.app"