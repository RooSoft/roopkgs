{lib, pkgs, ...}: let
  cfg = config.eza;
in {
  options = with lib; {
    eza.enable = mkEnableOption "eza";
  };

  config = {
    lib.mkIf cfg.eza.enable {
      home.shellAliases = {
        l = "eza -l --git";
      };

      home = {
        packages = with pkgs; [
          eza
        ];
      };
    };
  };
}

