# Get the current directory and hostname
DOTFILES_DIR := $(shell pwd)
RAW_HOSTNAME := $(shell scutil --get ComputerName)
HOSTNAME := $(shell scutil --get ComputerName | sed "s/'//g" | tr ' ' '-')

.PHONY: help install update clean backup diff

help:
	@echo "Available commands:"
	@echo "Raw hostname: $(RAW_HOSTNAME)"
	@echo "Clean hostname: $(HOSTNAME)"
	@echo "Dotfiles directory: $(DOTFILES_DIR)"

install:
	@echo "Installing dotfiles..."
	COMPUTER_NAME="$(HOSTNAME)" scripts/install.sh

rebuild:
	@echo "Rebuilding nix-darwin configuration..."
	@echo "This requires sudo access for system activation..."
	COMPUTER_NAME="$(HOSTNAME)"  sudo darwin-rebuild switch --flake $(DOTFILES_DIR)

clean:
	@echo "Cleaning up old generations..."
	nix-collect-garbage -d
	sudo darwin-rebuild --delete-older-than 30d switch --flake $(DOTFILES_DIR)
