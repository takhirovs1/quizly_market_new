.PHONY: help
help: # Script description and usage through `make` or `make help` commands
	$(MAKE) -C ./tools/makefile/ -f deploy.mk help-deploy
	$(MAKE) -C ./tools/makefile/ -f fire.mk help-fire
	$(MAKE) -C ./tools/makefile/ -f git.mk help-git
	$(MAKE) -C ./tools/makefile/ -f pub.mk help-pub

# Tooling fallback:
# Prefer FVM when available, otherwise use globally installed flutter/dart.
FVM_EXISTS := $(shell command -v fvm >/dev/null 2>&1 && echo 1 || echo 0)
ifeq ($(FVM_EXISTS),1)
FLUTTER := fvm flutter
DART := fvm dart
else
FLUTTER := flutter
DART := dart
endif

-include tools/makefile/deploy.mk tools/makefile/fire.mk tools/makefile/git.mk tools/makefile/pub.mk 
