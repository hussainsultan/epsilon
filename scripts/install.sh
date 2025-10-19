#!/usr/bin/env bash
set -e

echo "Setting up dotfiles..."

# Get the current directory (should be ~/workspace/bigdots)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "📁 Dotfiles directory: $DOTFILES_DIR"

# Check if we're on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 Detected macOS"

    # Check if Nix is installed
    if ! command -v nix &> /dev/null; then
        echo "❌ Nix is not installed. Please install Nix first:"
        echo "Use determinate https://dtr.mn/determinate-nix"
        exit 1
    fi

    # Check if nix-darwin is already installed
    if ! command -v darwin-rebuild &> /dev/null; then
        echo "Installing nix-darwin..."
        echo "This will require sudo access for system activation..."
        sudo nix run nix-darwin --extra-experimental-features nix-command  --extra-experimental-features flakes -- switch --flake "$DOTFILES_DIR"
    else
        echo "Rebuilding darwin configuration..."
        echo "This will require sudo access for system activation..."
        sudo darwin-rebuild switch --flake "$DOTFILES_DIR"
    fi

    echo "✅ Darwin configuration applied!"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux"

    # Check if Nix is installed
    if ! command -v nix &> /dev/null; then
        echo "❌ Nix is not installed. Please install Nix first:"
        echo "sh <(curl -L https://nixos.org/nix/install) --daemon"
        exit 1
    fi

    # Check if we're on NixOS
    if [ -f /etc/NIXOS ]; then
        echo "Rebuilding NixOS configuration..."
        echo "This will require sudo access for system activation..."
        sudo nixos-rebuild switch --flake "$DOTFILES_DIR"
        echo "✅ NixOS configuration applied!"
    else
        echo "Using home-manager standalone for non-NixOS Linux..."

        # Get the username and hostname
        USERNAME="${USER:-$(whoami)}"
        HOSTNAME="${COMPUTER_NAME:-$(hostname)}"

        # Check if home-manager is already installed
        if ! command -v home-manager &> /dev/null; then
            echo "Installing home-manager standalone..."
            nix run home-manager/master -- switch --flake "$DOTFILES_DIR#$USERNAME@$HOSTNAME"
        else
            echo "Rebuilding home-manager configuration..."
            home-manager switch --flake "$DOTFILES_DIR#$USERNAME@$HOSTNAME"
        fi

        echo "✅ Home-manager configuration applied!"
    fi
fi

echo "✅ Dotfiles setup complete!"
