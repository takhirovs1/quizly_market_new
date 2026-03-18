# ──────────────────────────────────
# 📖 HELPERS
# ──────────────────────────────────
.PHONY: help-pub
help-pub: ## Show all available pub commands with descriptions
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────────────
# 🔎 PROJECT INFORMATION
# ──────────────────────────────────
.PHONY: version
version: ## Check Flutter version
	######## ##       ##     ## ######## ######## ######## ########
	##       ##       ##     ##    ##       ##    ##       ##     ##
	##       ##       ##     ##    ##       ##    ##       ##     ##
	######   ##       ##     ##    ##       ##    ######   ########
	##       ##       ##     ##    ##       ##    ##       ##   ##
	##       ##       ##     ##    ##       ##    ##       ##    ##
	##       ########  #######     ##       ##    ######## ##     ##
	@$(FLUTTER) --version

# ──────────────────────────────────
# 🧹 CLEANING COMMANDS
# ──────────────────────────────────
.PHONY: clean_all
clean_all: ## Clean the project and remove all generated files
	@echo "🗑️ Cleaning the project..."
	@$(FLUTTER) clean
	@rm -f coverage.*
	@rm -rf dist bin out build
	@rm -rf coverage .dart_tool .packages pubspec.lock
	@echo "✅ Project successfully cleaned"

.PHONY: clean_all-win
clean_all-win: ## Clean the project and remove all generated files (Windows-safe)
	@echo "🗑️ Cleaning the project..."
	@$(FLUTTER) clean
	@rm -f coverage.* || true
	@rm -rf dist bin out build || true
	@rm -rf coverage .packages pubspec.lock || true
	@rm -rf .dart_tool || true
	@echo "✅ Project successfully cleaned"


.PHONY: fcg
fcg: ## Flutter clean, get dependencies, and format
	@$(FLUTTER) clean
	@$(FLUTTER) pub get

.PHONY: c_get
c_get: clean_all get ## Clean all and get dependencies

# ──────────────────────────────────
# 📦 DEPENDENCY MANAGEMENT
# ──────────────────────────────────
.PHONY: upgrade
upgrade: ## Upgrade all dependencies
	@$(FLUTTER) pub upgrade

.PHONY: upgrade-major
upgrade-major: get ## Upgrade to major versions
	@$(FLUTTER) pub upgrade --major-versions

.PHONY: outdated
outdated: get ## Check for outdated dependencies
	@$(FLUTTER) pub outdated

.PHONY: dependencies
dependencies: get ## Check all types of outdated dependencies
	@$(FLUTTER) pub outdated --dependency-overrides \
		--dev-dependencies --prereleases --show-all --transitive

.PHONY: get
get: ## Get dependencies
	@$(FLUTTER) pub get

# ──────────────────────────────────
# 🎨 CODE STYLE & FORMATTING
# ──────────────────────────────────
.PHONY: format
format: ## Format Dart code to line length 120
	@$(DART) format -l 120 lib/ test/ packages/ data/

# ──────────────────────────────────
# ⚡ CODE GENERATION
# ──────────────────────────────────
.PHONY: fluttergen
fluttergen: ## Generate assets with flutter_gen
	@$(DART) pub global activate flutter_gen
	@fluttergen -c packages/ui/pubspec.yaml

.PHONY: l10n
l10n: ## Generate localization files
	@dart pub global activate sheety_localization
	@dart pub global run sheety_localization:generate \
		--credentials=packages/localization/credentials.json \
		--sheet=1_tACbV1NUU-7-AmZNYWXkHbZHM9PN2WjjSfNYr0tZhQ \
		--lib=./packages/localization/lib/ \
		--arb=src/l10n \
		--gen=src/generated \
		--prefix=intl \
	  --format

.PHONY: l10n-untranslated
l10n-untranslated: ## Generate untranslated localization files
	@$(DART) pub global activate intl_utils
	@($(DART) pub global run intl_utils:generate --untranslated)
	@($(FLUTTER) gen-l10n --arb-dir lib/src/common/localization --output-dir lib/src/common/localization/generated --template-arb-file intl_en.arb --untranslated-messages-file=untranslated.json)

.PHONY: untranslated
untranslated: l10n-untranslated

.PHONY: build_runner
build_runner: ## Run build_runner to generate code
	@$(DART) run build_runner build --delete-conflicting-outputs --release #// --build-filter=lib/src/common/constant/pubspec.yaml.g.dart

.PHONY: codegen
codegen: ## Run all code generation tasks
	@echo "🔄 Generating code..."
	@$(FLUTTER) pub get
	@make build_runner
	@make fluttergen
	@make l10n
	@make format
	@clear
	@echo "✅ Code generated successfully"

.PHONY: gen
gen: codegen fcg ## Alias for code generation

# ──────────────────────────────────
# 🎨 VECTOR GRAPHICS
# ──────────────────────────────────
.PHONY: build_vec
build_vec: ## Build vector graphics from SVG files
	@$(DART) run tools/dart/vector_generator.dart $(r)

vec: r ?= false
vec: build_vec fluttergen fcg ## Build vectors and regenerate assets

# ──────────────────────────────────
# 📱 APP RESOURCES
# ──────────────────────────────────
.PHONY: generate-icons
generate-icons: ## Generate app icons (flutter_launcher_icons)
	@$(DART) pub global activate flutter_launcher_icons
	@$(DART) pub global run flutter_launcher_icons -f flutter_launcher_icons.yaml

.PHONY: generate-splash
generate-splash: ## Generate splash screen (flutter_native_splash)
	@$(FLUTTER) pub get
	@$(FLUTTER) pub run flutter_native_splash:create --path=flutter_native_splash.yaml

# ──────────────────────────────────
# 🍎 CocoaPods
# ──────────────────────────────────
.PHONY: pod-restart
pod-restart: ## Restart CocoaPods for iOS and macOS projects
	@cd ios && \
	rm -rf Pods && \
	rm -f Podfile.lock && \
	pod deintegrate && \
	pod install
	@if [ -d macos ]; then \
		cd macos && \
		rm -rf Pods && \
		rm -f Podfile.lock && \
		pod deintegrate && \
		pod install; \
	else \
		echo "No macos folder found, skipping macOS pod restart"; \
	fi
	@make fcg
