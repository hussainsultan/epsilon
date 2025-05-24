{ config, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    pkgs.vim
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";

    trusted-users = [ "root" "hussainsultan" ];

    substituters = [
      "https://cache.nixos.org/"
      "https://xorq-labs.cachix.org"
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
