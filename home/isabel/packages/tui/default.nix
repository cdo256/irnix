{
  lib,
  pkgs,
  inputs',
  config,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optionals;

  cfg = config.garden.programs;
in
{
  imports = [
    ./btop.nix
    ./izrss.nix
    # ./newsboat.nix
    # ./ranger.nix
    # ./yazi.nix
    # ./zellij.nix
  ];

  config = mkIf cfg.tui.enable {
    home.packages =
      builtins.attrValues {
        inherit (pkgs)
          # wishlist # fancy ssh
          glow # fancy markdown
          # fx # fancy jq
          # gum # a nicer scripting
          ;

        inherit (inputs'.beapkgs.packages) zzz; # code snippets in the cli
      }
      ++ optionals cfg.gui.enable (
        builtins.attrValues {
          inherit (pkgs) manga-tui; # tui manga finder + reader
        }
      );
  };
}
