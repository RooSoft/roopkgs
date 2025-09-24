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

      # See https://zellij.dev/documentation/options

      settings = {
        # theme = "tokyo-night-dark";
        theme = "catppuccin-macchiato";

        simplified_ui = false;
        pane_frames = false;

        show_startup_tips = false;

        scroll_buffer_size = 10000;

        keybinds = {
          normal = {
            unbind = [
              "Alt up"    # helix - Expand selection to parent syntax node            
              "Alt down"  # helix - Shrink syntax tree object selection
              "Alt left"  # helix - Select previous sibling node in syntax tree
              "Alt right" # heilx - Select next sibling node in syntax tree
            ];
          };
        };
      };
    };
  };
}
