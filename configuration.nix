{ config, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    pkgs.vim
    # Claude Code CLI from Nix overlay
    pkgs.claude-code
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

  system.configurationRevision = null;
  system.stateVersion = 6;

  users.users.hussainsultan = {
    name = "hussainsultan";
    home = "/Users/hussainsultan";
  };
}
