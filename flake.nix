{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Code: AI coding assistant
    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, claude-code }:
    {
      darwinConfigurations."lets-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backup for files managed by Home Manager (e.g., .aerospace.toml)
            home-manager.backupFileExtension = ".bak";
            home-manager.users.hussainsultan = import ./home.nix;
            # Allow unfree packages (e.g., claude-code has an unfree license)
            nixpkgs.config.allowUnfree = true;
            # Enable Claude Code via overlay
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
        ];
      };
      darwinConfigurations."HUSSAINs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backup for files managed by Home Manager (e.g., .aerospace.toml)
            home-manager.backupFileExtension = ".bak";
            home-manager.users.hussainsultan = import ./home.nix;
            # Allow unfree packages (e.g., claude-code has an unfree license)
            nixpkgs.config.allowUnfree = true;
            # Enable Claude Code via overlay
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
        ];
      };
    };
}
