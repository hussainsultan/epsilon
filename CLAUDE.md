# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository that manages system configuration across macOS (via nix-darwin) and Linux (via NixOS/home-manager). The configuration is defined using Nix flakes and provides a declarative, reproducible environment setup.

## Architecture

The repository uses a multi-target flake structure:

- **flake.nix**: Main entry point defining all system configurations
  - `darwinConfigurations.default`: Generic macOS configuration (works with any hostname)
  - `homeConfigurations."hussainsultan@lets-pop"`: Standalone home-manager for non-NixOS Linux
  - `nixosConfigurations."lets-pop"`: Full NixOS system configuration

- **configuration.nix**: System-level configuration (nix-darwin/NixOS)
  - System packages (vim, claude-code)
  - Nix settings (experimental features, trusted users, caches)
  - User account definitions

- **home.nix**: User-level configuration (home-manager)
  - Cross-platform with `isDarwin` and `isLinux` conditionals
  - Program configurations (tmux, neovim, zsh/bash, starship, zoxide, direnv)
  - Shell aliases and environment variables
  - Package installations with platform-specific overrides
  - macOS-specific: AeroSpace window manager + Alacritty setup via LaunchAgents

- **configs/**: Application configuration files
  - `aerospace/aerospace.toml`: AeroSpace window manager config (macOS)
  - `nvim/init.lua`: Neovim configuration
  - `starship/starship.toml`: Starship prompt configuration
  - `alacritty/alacritty.yml`: Alacritty terminal emulator config

## Key Design Patterns

### Hostname Independence (macOS)
The macOS configuration uses `darwinConfigurations.default` instead of hardcoded hostnames, allowing the same flake to work on any Mac. The Makefile detects the platform and sets `FLAKE_CONFIG=default` on Darwin systems.

### Platform-Specific Logic
home.nix uses conditional configuration based on `pkgs.stdenv.isDarwin` and `pkgs.stdenv.isLinux`:
- Darwin uses zsh, Linux uses bash
- Darwin gets AeroSpace, colima, docker; Linux gets nix-ld
- Different session paths and environment variables per platform

### Configuration Symlinks
Application configs in `configs/` are read directly using `builtins.readFile` and applied via:
- `xdg.configFile` for cross-platform configs (Alacritty)
- `home.file` for macOS-specific configs (AeroSpace)
- Inline `settings = builtins.fromTOML (builtins.readFile ...)` for declarative configs (Starship)

### Tmux Environment Preservation
The tmux config in home.nix sets explicit PATH and shell options to ensure Nix-managed tools are available in tmux panes. It also configures OSC 52 clipboard support for remote/terminal clipboard integration.

## Common Commands

### Initial Installation
```bash
make install
```
Runs `scripts/install.sh` which:
- Detects platform (macOS/Linux/NixOS)
- Installs nix-darwin or home-manager if not present
- Activates the appropriate configuration

### Rebuild System
```bash
make rebuild
```
- **macOS**: Runs `darwin-rebuild switch --flake .#default` (requires sudo)
- **NixOS**: Runs `nixos-rebuild switch --flake .` (requires sudo)
- **Linux**: Runs `home-manager switch --flake .#user@hostname`

### Cleanup Old Generations
```bash
make clean
```
Removes old Nix generations and garbage collects (deletes generations older than 30 days).

## Development Workflow

When modifying this repository:

1. **Edit Nix files** (flake.nix, configuration.nix, home.nix) or config files in `configs/`
2. **Test changes** with `make rebuild`
3. **Verify** the system behaves as expected
4. **Commit** changes to git

### Testing Configuration Changes
After editing Nix files, always rebuild to test:
```bash
make rebuild
```

For debugging flake issues:
```bash
nix flake check
nix flake show
```

### Adding New Packages
Add to `home.packages` in home.nix:
```nix
home.packages = with pkgs; [
  # existing packages...
  new-package
];
```

For platform-specific packages, use:
```nix
] ++ lib.optionals isDarwin [
  macos-only-package
] ++ lib.optionals isLinux [
  linux-only-package
];
```

### Adding New Config Files
1. Place config file in `configs/app-name/`
2. Reference in home.nix using one of these patterns:
   - XDG config: `xdg.configFile."app/config.yml".source = ./configs/app/config.yml;`
   - Home file: `home.file.".config/app/config.yml".source = ./configs/app/config.yml;`
   - Inline parsing: `settings = builtins.fromTOML (builtins.readFile ./configs/app/config.toml);`

## Important Notes

- **Unfree packages**: The flake enables `nixpkgs.config.allowUnfree = true` to allow packages like claude-code
- **Claude Code**: Installed via a custom overlay from `github:sadjow/claude-code-nix`
- **Home Manager backups**: Set to `.bak` extension to avoid conflicts during activation
- **Shell initialization**: The default shell is zsh on macOS and bash on Linux
- **NIX_LD on Linux**: Set to support non-Nix binaries on non-NixOS systems
