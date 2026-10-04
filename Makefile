.PHONY: help setup plan check

help:
	@printf '%s\n' 'make setup  Install missing tools, sync VS Code extensions, and link dotfiles' 'make plan   Preview the setup without changes' 'make check  Check syntax and run mocked installer tests'

setup:
	bash install.sh

plan:
	@bash install.sh --plan

check:
	bash -n install.sh
	bash -n scripts/packages.sh
	bash -n scripts/vscode.sh
	bash -n tests/packages.sh
	zsh -n dotfiles/.zshrc
	ruby -c Brewfile
	bash tests/packages.sh
