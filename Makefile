# Get the current directory and hostname
DOTFILES_DIR := $(shell pwd)

# Detect OS and get hostname accordingly
ifeq ($(shell uname),Darwin)
	RAW_HOSTNAME := $(shell scutil --get ComputerName)
	HOSTNAME := $(shell scutil --get ComputerName | tr -cd '[:alnum:] -' | tr ' ' '-')
else
	RAW_HOSTNAME := $(shell hostname)
	HOSTNAME := $(shell hostname)
endif

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
ifeq ($(shell uname),Darwin)
	@echo "Rebuilding nix-darwin configuration..."
	@echo "Using hostname: $(HOSTNAME)"
	@echo "This requires sudo access for system activation..."
	sudo darwin-rebuild switch --flake $(DOTFILES_DIR)#$(HOSTNAME)
else ifeq ($(shell test -f /etc/NIXOS && echo nixos),nixos)
	@echo "Rebuilding NixOS configuration..."
	@echo "This requires sudo access for system activation..."
	sudo nixos-rebuild switch --flake $(DOTFILES_DIR)
else
	@echo "Rebuilding home-manager configuration..."
	@if command -v home-manager >/dev/null 2>&1; then \
		home-manager switch --flake $(DOTFILES_DIR)#$(USER)@$(HOSTNAME); \
	else \
		nix run home-manager/master -- switch --flake $(DOTFILES_DIR)#$(USER)@$(HOSTNAME); \
	fi
endif

clean:
	@echo "Cleaning up old generations..."
	nix-collect-garbage -d
ifeq ($(shell uname),Darwin)
	sudo darwin-rebuild --delete-older-than 30d switch --flake $(DOTFILES_DIR)
else
	sudo nix-collect-garbage --delete-older-than 30d
endif
