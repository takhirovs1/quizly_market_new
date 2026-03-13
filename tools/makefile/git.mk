# ───────────────
# 🛠️ GIT COMMANDS
# ───────────────
.PHONY: help-git
help-git: ## Show all available Git-related commands
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: push
push: ## Git push with message (m) and branch name (u); also merge into test
ifndef m
	$(error ❌ Error: Commit message (m) is required. Usage: make push m="your commit message" u=branch_name)
endif
ifndef u
	$(error ❌ Error: Branch name (u) is required. Usage: make push m="your commit message" u=branch_name)
endif
	@echo "🔧 Formatting Dart files before push..."
	@fvm dart format --fix -l 120 lib/ test/ packages/
	@echo "📦 Adding changes..."
	@git add .
	@echo "📝 Committing with message: $(m)"
	@git commit -m "$(m)"
	@echo "🚀 Pushing to origin/$(u) and merging to origin/test..."
	@git push -u origin $(u)
	@git push -u origin $(u):test

.PHONY: tag-prod
tag-prod: format ## Create and push a Git tag for production
ifndef m
	$(error ❌ Error: Tag message (m) is required. Usage: make tag-prod m="v1.0.0")
endif
	@echo "🏷️ Creating Git tag: $(m)"
	@git tag -a "${m}" -m "${m}"
	@echo "📤 Pushing tags to remote..."
	@git push origin --tags

.PHONY: merge
merge: ## Merge the current branch into the test branch
	@git fetch origin
	@git merge origin/development