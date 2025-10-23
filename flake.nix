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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Mac App Util: Proper .app integration with Spotlight and Launchpad
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, claude-code, mac-app-util }:
    let
      # Generic darwin configuration that can be used with any hostname
      darwinConfiguration = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          mac-app-util.darwinModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Enable backup for files managed by Home Manager (e.g., .aerospace.toml)
            home-manager.backupFileExtension = ".bak";
            home-manager.users.hussainsultan = import ./home.nix;
            # Enable mac-app-util for all users
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
            # Allow unfree packages (e.g., claude-code has an unfree license)
            nixpkgs.config.allowUnfree = true;
            # Enable Claude Code via overlay
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
        ];
      };
    in
    {
      # Standalone home-manager configuration for non-NixOS Linux
      homeConfigurations."hussainsultan@lets-pop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ claude-code.overlays.default ];
        };
        modules = [
          ./home.nix
          {
            home.username = "hussainsultan";
            home.homeDirectory = "/home/hussainsultan";
          }
        ];
      };

      nixosConfigurations."lets-pop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = ".bak";
            home-manager.users.hussainsultan = import ./home.nix;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ claude-code.overlays.default ];
          }
        ];
      };

      # Default darwin configuration - works with any Mac hostname
      darwinConfigurations.default = darwinConfiguration;
    };
}
