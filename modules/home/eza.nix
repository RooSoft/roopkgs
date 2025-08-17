{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roopkgs.home.eza;
in {
  options = with lib; {
    roopkgs.home.eza.enable = mkEnableOption "eza";
  };

  # See https://github.com/eza-community/eza/blob/main/README.md#display-options

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        eza
      ];

      shellAliases = {
        e = "eza";
        ee = "eza -lg --git --git-repos";
      };
    };
  };
}
