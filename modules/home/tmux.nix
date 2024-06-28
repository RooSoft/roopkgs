{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roopkgs.home.tmux;
in {
  options = with lib; {
    roopkgs.home.tmux.enable = mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;
      customPaneNavigationAndResize = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        better-mouse-mode
        sensible
        yank
        #gruvbox
        nord
        #onedark-theme
      ];
      extraConfig = ''
        set -g mouse on
        set -g status-position top

        set-option -sg escape-time 10
        set-option -g focus-events on
        set-option -sa terminal-overrides ',xterm-256color:RGB'
      '';
    };
  };
}
