{
  lib,
  config,
  inputs',
  ...
}:
{
  programs.nh = {
    enable = true;
    package = inputs'.nh.packages.nh;

    clean = {
      enable = !config.nix.gc.automatic;
      dates = "weekly";
    };
  };

  # WARNING: this leaves you without commands like `nixos-rebuild` which you don't
  # really need, you may consider enabling nh and using `nh os switch` instead
  # which is actually a really good alternative to using this
  system =
    {
      disableInstallerTools = config.programs.nh.enable;
    }
    // lib.attrsets.optionalAttrs (config.system ? tools) {
      tools.nixos-version.enable = true;
    };
}
