{
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (lib) mkDefault ldTernary;
in {
  imports = [
    # imported home-manager modules
    self.homeManagerModules.gtklock
    self.homeManagerModules.swaync

    # important system environment config
    ./system
    # programs that are used, e.g. GUI apps
    ./programs
    # system services, organized by display protocol
    ./services
    # Application themeing
    ./themes
  ];

  config = {
    # reload system units when changing configs
    systemd.user.startServices = mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

    home = {
      username = "isabel";
      homeDirectory = ldTernary pkgs "/home/isabel" "/Users/isabel";
      extraOutputsToInstall = ["doc" "devdoc"];

      stateVersion = mkDefault "23.05";
    };

    manual = {
      # I don't use docs, so just disable them
      html.enable = false;
      json.enable = false;
      manpages.enable = false;
    };

    # let HM manage itself when in standalone mode
    programs.home-manager.enable = true;
  };
}
