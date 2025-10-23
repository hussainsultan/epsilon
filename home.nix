{ config, pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # These will be overridden by flake configuration
  home.username = lib.mkDefault "hussainsultan";
  home.homeDirectory = lib.mkDefault (
    if isDarwin then "/Users/hussainsultan" else "/home/hussainsultan"
  );
  home.stateVersion = "23.11";

  # Enable compatibility for non-NixOS Linux systems
  targets.genericLinux.enable = isLinux;

  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_window_left_separator ""
          set -g @catppuccin_window_right_separator " "
          set -g @catppuccin_window_middle_separator " █"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_window_default_fill "number"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_fill "number"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "directory session"
          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_right_separator_inverse "no"
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
          set -g @catppuccin_directory_text "#{pane_current_path}"
        '';
      }
      sensible
    ];
    extraConfig = ''
      # Custom key bindings
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Override default pane creation to ensure environment
      bind-key '"' split-window -v -c "#{pane_current_path}"
      bind-key '%' split-window -h -c "#{pane_current_path}"
      bind-key 'c' new-window -c "#{pane_current_path}"

      set-environment -g PATH "/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

      set-option -g default-command "${if isLinux then pkgs.bash else pkgs.zsh}/bin/${if isLinux then "bash" else "zsh"} -l"
      set-option -g default-shell "${if isLinux then pkgs.bash else pkgs.zsh}/bin/${if isLinux then "bash" else "zsh"}"

      # Update environment variables that should be inherited
      set-option -ga update-environment " NIX_PATH"
      set-option -ga update-environment " NIX_PROFILES"
      set-option -ga update-environment " NIX_SSL_CERT_FILE"
      set-option -ga update-environment " NIX_USER_PROFILE_DIR"
      set-option -ga update-environment " XDG_DATA_DIRS"
      set-option -ga update-environment " XDG_CONFIG_DIRS"
      set-option -ga update-environment " LOCALE_ARCHIVE"
      set-option -ga update-environment " UPTERM_ADMIN_SOCKET"

      # OSC 52 clipboard support for tmux
      set -g set-clipboard on
      set -g allow-passthrough on

      # Specific overrides for Alacritty + tmux
      set -as terminal-overrides ',alacritty:Ms=\E]52;c;%p2%s\007'
      set -as terminal-overrides ',tmux*:Ms=\E]52;c;%p2%s\007'
      set -as terminal-features ',alacritty:clipboard'
      set -as terminal-features ',*:clipboard'

      # Force tmux to pass through OSC sequences to the parent terminal
      set -as terminal-features ',*:Ms=\E]52;c;%p2%s\007'
      set -g set-clipboard on
      set -g allow-passthrough on
      # Fix cursor shape https://github.com/neovim/neovim/issues/5096#issuecomment-469027417
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'

      # Undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

      # Underscore colours - needs tmux-3.0
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Status interval
      set -g status-interval 0
    '';
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];

  # Add session variables for Nix
  home.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
  } // lib.optionalAttrs isLinux {
    NIX_LD = "${pkgs.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2";
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
    ];
  };

  programs.bash = lib.mkIf isLinux {
    enable = true;
    shellAliases = {
      vim= "nvim";
      cd = "z";
      ls = "eza --color=always --group-directories-first";
      ll = "eza -l --color=always --group-directories-first --git";
      la = "eza -la --color=always --group-directories-first --git";
      lt = "eza --tree --color=always --group-directories-first";
      l = "eza -lah --color=always --group-directories-first --git";
      g = "git";
      gc = "git commit";
      gf = "git fetch";
      gs = "git status";
      gd = "git diff";
      gg = "git grep -n";
      gpo = "git push origin";
      gco = "git checkout";
      ga = "git add";
      gai = "git add -i";
      gap = "git add -p";
      gau = "git add -u";
      gcw = "git commit -m wip";
      gcm = "git commit -m";
      gpu = "git push";
      gpl = "git pull";
      gdc = "git diff --cached";
      gds = "git diff --staged";
      gre = "git checkout --";
      gus = "git reset HEAD";
      gla = "git log --graph --oneline --all";
      gll = "git log --graph --oneline";
      glp = "git log -p";
      gls = "git ls-files";
      grl = "git rebase -i HEAD^^";
      gwc = "git whatchanged";
      git-commit-empty-initial-commit = "git commit --allow-empty -m 'initial commit'";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
    };
    historySize = 10000;
    historyFile = "${config.home.homeDirectory}/.bash_history";
  };

  programs.zsh = lib.mkIf isDarwin {
    enable = true;
    shellAliases = {
      vim= "nvim";
      cd = "z";
      ls = "eza --color=always --group-directories-first";
      ll = "eza -l --color=always --group-directories-first --git";
      la = "eza -la --color=always --group-directories-first --git";
      lt = "eza --tree --color=always --group-directories-first";
      l = "eza -lah --color=always --group-directories-first --git";
      g = "git";
      gc = "git commit";
      gf = "git fetch";
      gs = "git status";
      gd = "git diff";
      gg = "git grep -n";
      gpo = "git push origin";
      gco = "git checkout";
      ga = "git add";
      gai = "git add -i";
      gap = "git add -p";
      gau = "git add -u";
      gcw = "git commit -m wip";
      gcm = "git commit -m";
      gpu = "git push";
      gpl = "git pull";
      gdc = "git diff --cached";
      gds = "git diff --staged";
      gre = "git checkout --";
      gus = "git reset HEAD";
      gla = "git log --graph --oneline --all";
      gll = "git log --graph --oneline";
      glp = "git log -p";
      gls = "git ls-files";
      grl = "git rebase -i HEAD^^";
      gwc = "git whatchanged";
      git-commit-empty-initial-commit = "git commit --allow-empty -m 'initial commit'";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./configs/starship/starship.toml);
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = isLinux;
    enableZshIntegration = isDarwin;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = builtins.readFile ./configs/nvim/init.lua;
  };


  # Install packages
  home.packages = with pkgs; [
    tmux
    watch
    uv
    eza
    fd
    ripgrep
    fzf
    git
    gh
    htop
    btop
    curl
    wget
    jq
    yq
    tree
    asciinema
    presenterm
    nodejs_24
    tailwindcss
    yazi
    claude-code
    codex
    # Nerd Fonts - patched fonts with additional glyphs for icons/symbols
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    nerd-fonts.space-mono
  ] ++ lib.optionals isDarwin [
    # macOS-specific packages
    # GUI apps are handled by mac-app-util for Spotlight/Launchpad integration
    alacritty
    google-chrome
    obsidian
    colima
    docker
    aerospace
  ] ++ lib.optionals isLinux [
    # Linux-specific packages
    nix-ld
    alacritty
  ];

  # Enable font configuration
  fonts.fontconfig.enable = true;

  # Alacritty configuration (TOML format)
  xdg.configFile."alacritty/alacritty.toml".source = ./configs/alacritty/alacritty.toml;

  # macOS-specific configuration for AeroSpace
  home.file = lib.mkIf isDarwin {
    "Applications/AeroSpace.app".source = "${pkgs.aerospace}/Applications/AeroSpace.app";

    "Library/LaunchAgents/com.jakehilborn.aerospace.plist".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>com.jakehilborn.aerospace</string>
        <key>ProgramArguments</key>
        <array>
          <!-- Launch the AeroSpace GUI server from the home Applications symlink -->
          <string>${config.home.homeDirectory}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
      </plist>
    '';

    ".aerospace.toml".text = builtins.readFile ./configs/aerospace/aerospace.toml;
  };

  home.activation = lib.mkIf isDarwin {
    setupAerospace = ''
      /bin/launchctl unload "${config.home.homeDirectory}/Library/LaunchAgents/com.jakehilborn.aerospace.plist" 2>/dev/null || true
      /bin/launchctl load   "${config.home.homeDirectory}/Library/LaunchAgents/com.jakehilborn.aerospace.plist"
    '';

    # Link Nix-installed fonts to ~/Library/Fonts so GUI apps can find them
    linkFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "${config.home.homeDirectory}/Library/Fonts/Nix"

      # Clean up old font links
      $DRY_RUN_CMD rm -rf "${config.home.homeDirectory}/Library/Fonts/Nix/"*

      # Link all Nerd Fonts from the Nix profile
      for font_dir in ${pkgs.nerd-fonts.fira-code}/share/fonts/*; do
        if [ -d "$font_dir" ]; then
          for font_file in "$font_dir"/*; do
            if [ -f "$font_file" ]; then
              $DRY_RUN_CMD ln -sf "$font_file" "${config.home.homeDirectory}/Library/Fonts/Nix/$(basename "$font_file")"
            fi
          done
        fi
      done

      # Also link other nerd fonts
      for font_pkg in ${pkgs.nerd-fonts.jetbrains-mono} ${pkgs.nerd-fonts.meslo-lg} ${pkgs.nerd-fonts.space-mono}; do
        for font_dir in "$font_pkg"/share/fonts/*; do
          if [ -d "$font_dir" ]; then
            for font_file in "$font_dir"/*; do
              if [ -f "$font_file" ]; then
                $DRY_RUN_CMD ln -sf "$font_file" "${config.home.homeDirectory}/Library/Fonts/Nix/$(basename "$font_file")"
              fi
            done
          fi
        done
      done
    '';
  };

  programs.direnv = {
   enable= true;
   enableBashIntegration = isLinux;
   enableZshIntegration = isDarwin;
  };

  programs.home-manager.enable = true;
}
