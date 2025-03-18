{
  description = "Ryan Elliott nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.mkalias
        ];

      homebrew = {
        enable = true;
        brews = [
          "ansible"
          "awscli"
          "ca-certificates"
          "docker-compose"
          "eza"
          "git"
          "gh"
          "iperf"
          "jq"
          "lazygit"
          "mas"
          "nmap"
          "oh-my-posh"
          "pyenv"
          "stow"
          "tmux"
          #"python@3.13"
          #"python-setuptools"
          "vsh"
          "zoxide"
        ];
        casks = [
          "1password"
          "1password-cli"
          "alacritty"
          "chatgpt"
          "docker"
          "firefox"
          "microsoft-teams"
          "slack"
          "visual-studio-code"
          "warp"
          "zoom"
        ];
        masApps = {
          "Microsoft365" = 1450038993;
        };
        #onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = 
      [
        pkgs.nerd-fonts.lekton
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      system.defaults = {
        #dock.autohide = false;
        dock.persistent-apps = [
          "${pkgs.alacritty}/Applications/Alacritty.app"
          "/Applications/Firefox.app"
          "/Applications/Slack.app"
          "/Applications/1Password.app"
          "/Applications/Visual Studio Code.app"
          "/System/Applications/System Settings.app"
          "/System/Applications/Notes.app"
          "/System/Applications/Reminders.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Mail.app"
          "/Applications/Microsoft Teams.app"
        ];
        dock.persistent-others = [
          "/Users/Ryan/Downloads"
          "/Applications"
        ];
        finder.FXPreferredViewStyle = "Nlsv";
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.FXDefaultSearchScope = "SCcf";
        finder.NewWindowTarget = "Home";
        finder.ShowHardDrivesOnDesktop = true;
        finder.ShowPathbar = true;
        finder.ShowStatusBar = true;
        finder._FXSortFoldersFirst = true;
        menuExtraClock.ShowAMPM = true;
        menuExtraClock.ShowDate = 1;
        menuExtraClock.ShowDayOfMonth = true;
        menuExtraClock.ShowDayOfWeek = true;
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;
        NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
        NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
        NSGlobalDomain."com.apple.trackpad.forceClick" = true;
        NSGlobalDomain."com.apple.swipescrolldirection" = null;
        controlcenter.BatteryShowPercentage = true;
        controlcenter.Sound = true;
        dock.mineffect = "scale";
        dock.minimize-to-application = true;
        dock.show-recents = false;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbookair" = nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "ryan";

            autoMigrate = true;
          };
        }
        configuration ];
    };

    darwinConfigurations."macbookpro" = nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew 
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "ryan";

            autoMigrate = true;
          };
        }
        configuration ];
    };
  };
}
