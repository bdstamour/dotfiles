# Makefile — convenience entrypoint for the dotfiles.
#
# scripts/install.sh and scripts/bootstrap.sh do the real work; these targets
# are memorable shortcuts. `link`/`unlink`/`dry-run` call Stow directly for
# quick symlink management without the plugin-install steps.

STOW_PACKAGES := nvim tmux zsh
STOW_FLAGS := --target=$(HOME) --no-folding

.DEFAULT_GOAL := help
.PHONY: help install bootstrap link unlink relink dry-run

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "} {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install: ## Install tools + deps, then bootstrap (meant for a fresh system)
	./scripts/install.sh

bootstrap: ## Symlink configs with Stow + install tmux/nvim plugins
	./scripts/bootstrap.sh

link: ## Symlink configs only (stow --restow)
	stow $(STOW_FLAGS) --restow $(STOW_PACKAGES)

unlink: ## Remove the config symlinks (stow -D)
	stow $(STOW_FLAGS) -D $(STOW_PACKAGES)

relink: unlink link ## Unlink then relink everything

dry-run: ## Preview what stow would do, changing nothing
	stow $(STOW_FLAGS) -n -v --restow $(STOW_PACKAGES)
