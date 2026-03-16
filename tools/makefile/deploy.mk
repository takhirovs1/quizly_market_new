# ──────────────────────
# 🚀 DEPLOYMENT COMMANDS
# ──────────────────────

# Build Name and Number from pubspec.yaml
BUILD_NAME=$(shell grep '^version: ' pubspec.yaml | cut -d+ -f1 | sed 's/version: //')
BUILD_NUMBER=$(shell grep '^version: ' pubspec.yaml | cut -d+ -f2)

.PHONY: help-deploy
help-deploy: ## Show all available deployment-related commands
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: pre-build
pre-build: increment-build clean_all gen ## Run before build tasks

.PHONY: pre-build-win
pre-build-win: ## Run before build tasks (Windows-safe)
	@make increment-build-win
	@make clean_all-win
	@make gen

# ─────────── VERSION MANAGEMENT ───────────

.PHONY: increment-build
increment-build: ## Increment build number in pubspec.yaml
	@sed -i '' 's/\(^version: *[0-9.]*\)+\([0-9]*\)/\1+'"$$(($$(grep '^version:' pubspec.yaml | cut -d+ -f2) + 1))"'/' pubspec.yaml
	@echo "\nBuild number incremented to $$(($(BUILD_NUMBER) + 1))\n"

.PHONY: increment-build-win
increment-build-win: ## Increment build number in pubspec.yaml (Windows-safe)
	@CURRENT=$$(grep '^version:' pubspec.yaml | head -n1); \
	NAME=$${CURRENT%%+*}; \
	NUM=$${CURRENT##*+}; \
	NEW_NUM=$$((NUM + 1)); \
	sed -i.bak "s/^version: .*/$${NAME}+$$NEW_NUM/" pubspec.yaml; \
	echo "\nBuild number incremented to $$NEW_NUM\n"


# ─────────── BUILD COMMANDS FOR ANDROID ───────────

.PHONY: apk
apk: pre-build ## Build Android APK (development config)
	@$(FLUTTER) build apk --release --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/development.json --dart-define=config.platform=android
	@open build/app/outputs/apk/release/

.PHONY: apk-stage
apk-stage: pre-build ## Build Android APK (staging config)
	@$(FLUTTER) build apk --release --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/staging.json --dart-define=config.platform=android
	@open build/app/outputs/apk/release/

.PHONY: apk-prod
apk-prod: pre-build ## Build Android APK (production config)
	@$(FLUTTER) build apk --release --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/production.json --dart-define=config.platform=android
	@open build/app/outputs/apk/release/

# ─────────── BUILD COMMANDS FOR ANDROID aab ───────────

.PHONY: aab
aab: pre-build ## Build Android AAB
	@$(FLUTTER) build appbundle --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/production.json --dart-define=config.platform=android
	@open build/app/outputs/bundle/release/

# ─────────── BUILD COMMANDS FOR iOS ───────────

.PHONY: ipa
ipa: pre-build ## Build iOS IPA (development config)
	@$(FLUTTER) build ipa --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/development.json --dart-define=config.platform=ios
	@open build/ios/archive/Runner.xcarchive

.PHONY: ipa-stage
ipa-stage: pre-build ## Build iOS IPA (staging config)
	@$(FLUTTER) build ipa --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/staging.json --dart-define=config.platform=ios
	@open build/ios/archive/Runner.xcarchive

.PHONY: ipa-prod
ipa-prod: pre-build ## Build iOS IPA (production config)
	@$(FLUTTER) build ipa --build-name=$(BUILD_NAME) --build-number=$(BUILD_NUMBER) --dart-define-from-file=config/production.json --dart-define=config.platform=ios
	@open build/ios/archive/Runner.xcarchive

.PHONY: web
web: pre-build ## Build Flutter web release and deploy to Firebase hosting
	@$(FLUTTER) build web --release --source-maps --dart-define-from-file=config/production.json --dart-define=config.platform=web
	@sed -i '' '/sourceMappingURL=flutter\.js\.map/d' build/web/flutter.js || true
	@firebase deploy --only hosting

.PHONY: web-win
web-win: pre-build-win ## Build Flutter web release and deploy to Firebase hosting (Windows-safe)
	@$(FLUTTER) build web --release --source-maps --dart-define-from-file=config/production.json --dart-define=config.platform=web
	@firebase deploy --only hosting
