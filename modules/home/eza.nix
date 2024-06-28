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

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        eza
      ];

      shellAliases = {
        e = "eza -lg --git --git-repos";
      };
    };
  };
}
