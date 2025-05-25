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
    echo "TODO"
fi

echo "✅ Dotfiles setup complete!"
