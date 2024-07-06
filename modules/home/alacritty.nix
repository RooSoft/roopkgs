{
  lib,
  pkgs,
  unstable,
  config,
  ...
}: let
  cfg = config.roopkgs.home.alacritty;
  
  # see https://alacritty.org/config-alacritty.html
  alacrittyConfig = {
    font = {
      normal = {
        family = "MesloLGM Nerd Font Mono";
      };
      size = 13;
      offset = {
        y = -4;
      };
    };

    keyboard = {
      bindings = [
        {
          key = "ArrowRight";
          mods = "Command";
          action = "SelectNextTab";
        }
        {
          key = "ArrowLeft";
          mods = "Command";
          action = "SelectPreviousTab";
        }
        {
          key = "F12";
          action = "ToggleFullscreen";
        }
        {
          key = "Return";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }
      ];
    };

    colors = {
      primary = {
        foreground = "#c0cbf2";
        background = "#24283a";
      };
      selection = {
        foreground = "#111111";
        background = "#90ccfa";
      };
    };

    window = {
      padding = {
        x = 2;
        y = 4;
      };
      opacity = 0.8;
      blur = true;
      # decorations = "Buttonless";
    };
  };

  tomlFormat = (pkgs.formats.toml {}).generate "something" alacrittyConfig;
in {
  options = with lib; {
    roopkgs.home.alacritty.enable = mkEnableOption "alacritty";
  };

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/alacritty/alacritty.toml".source = tomlFormat;
    };
  };
}
