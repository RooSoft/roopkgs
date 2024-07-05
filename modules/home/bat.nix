{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.bat;
in {
  options = with lib; {
    roopkgs.home.bat.enable = mkEnableOption "bat";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      shellAliases = {
        # See: https://github.com/sharkdp/bat#man
        # See: bat --list-themes
        bat = "bat --theme='1337' --italic-text=always";
      };
    };
    
    home = {
      packages = with pkgs; [
        bat
      ];
    };
  };
}

