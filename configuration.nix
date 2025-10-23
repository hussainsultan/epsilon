{ config, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    pkgs.vim
    # Claude Code CLI from Nix overlay
    pkgs.claude-code
    # Alacritty is automatically installed to /Applications/Nix Apps/ by nix-darwin
    pkgs.alacritty
  ];
  # Determinate nix needs to be told to use nix-darwin
  nix.enable = false;

  nix.settings = {
    experimental-features = "nix-command flakes";

    trusted-users = [ "root" "hussainsultan" ];

    substituters = [
      "https://cache.nixos.org/"
      "https://xorq-labs.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "xorq-labs.cachix.org-1:yw5TptZAA4ry8WZ8VEAy4e4T8bdIhoeiLC5YlR5cOo4="
    ];

  };

  programs.zsh.enable = true;

  # Set primary user for user-specific system defaults
  system.primaryUser = "hussainsultan";

  # macOS Dock customization
  system.defaults.dock = {
    # Auto-hide the dock
    autohide = true;
    # Delay before showing the dock (in seconds)
    autohide-delay = 0.0;
    # Animation duration when showing/hiding the dock
    autohide-time-modifier = 0.2;
    # Position on screen: "left", "bottom", "right"
    orientation = "bottom";
    # Icon size in pixels
    tilesize = 48;
    # Minimize windows using the "Scale" effect
    mineffect = "scale";
    # Show recent applications in the dock
    show-recents = false;
    # Show indicator lights for open applications
    show-process-indicators = true;
    # Disable rearranging spaces based on most recent use
    mru-spaces = false;
    # Make Dock icons of hidden applications translucent
    showhidden = true;
  };

  # Additional macOS system defaults
  system.defaults.NSGlobalDomain = {
    # Enable natural scrolling (default on macOS)
    "com.apple.swipescrolldirection" = true;
  };

  system.configurationRevision = null;
  system.stateVersion = 6;

  users.users.hussainsultan = {
    name = "hussainsultan";
    home = "/Users/hussainsultan";
  };
}
