{
  lib, 
  config,
  ...
}: let
  cfg = config.roopkgs.home.zellij;
in {
  imports = [
    ./layouts
  ];

  options = with lib; {
    roopkgs.home.zellij.enable = mkEnableOption "zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        # theme = "tokyo-night-dark";
        theme = "catppuccin-macchiato";

        simplified_ui = false;
        pane_frames = false;

        scroll_buffer_size = 10000;
      };
    };
  };
}
