{
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.ghostty;

  # see https://ghostty.org/docs/config
  ghosttyConfig = ''
    font-family = "MesloLGM Nerd Font Mono Regular"
    font-size = 13
    font-thicken = true
    adjust-cell-height = -10%

    background-opacity = 0.8

    keybind = alt+left=unbind
    keybind = alt+right=unbind
    macos-option-as-alt = true

    keybind = cmd+opt+left=unbind
    keybind = cmd+opt+right=unbind

    keybind = cmd+left=previous_tab
    keybind = cmd+right=next_tab
  '';
in {
  options = with lib; {
    roopkgs.home.ghostty.enable = mkEnableOption "ghostty";
  };

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/ghostty/config".text = ghosttyConfig;
    };
  };
}
