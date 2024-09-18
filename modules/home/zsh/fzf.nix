{
  lib,
  config,
  pkgs,
  ...
}: let
  zshCfg = config.roopkgs.home.zsh;
in {
  # See https://junegunn.github.io/fzf/getting-started/

  config = lib.mkIf zshCfg.enable {
    programs.zsh = {
      initExtra = ''
        source <(fzf --zsh)
      '';
    };

    home.packages = with pkgs; [
      fzf
    ];
  };
}
