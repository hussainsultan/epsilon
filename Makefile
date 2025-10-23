# Get the current directory
DOTFILES_DIR := $(shell pwd)

# Use "default" as the configuration name for darwin systems
# This allows the same flake to work on any Mac without hardcoding hostnames
ifeq ($(shell uname),Darwin)
	RAW_HOSTNAME := $(shell scutil --get ComputerName)
	FLAKE_CONFIG := default
else
	RAW_HOSTNAME := $(shell hostname)
	FLAKE_CONFIG := $(shell hostname)
endif

.PHONY: help install update clean backup diff

help:
	@echo "Available commands:"
	@echo "Hostname: $(RAW_HOSTNAME)"
	@echo "Flake config: $(FLAKE_CONFIG)"
	@echo "Dotfiles directory: $(DOTFILES_DIR)"

install:
	@echo "Installing dotfiles..."
	FLAKE_CONFIG="$(FLAKE_CONFIG)" scripts/install.sh

rebuild:
ifeq ($(shell uname),Darwin)
	@echo "Rebuilding nix-darwin configuration..."
	@echo "Using config: $(FLAKE_CONFIG)"
	@echo "This requires sudo access for system activation..."
	sudo darwin-rebuild switch --flake $(DOTFILES_DIR)#$(FLAKE_CONFIG)
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
