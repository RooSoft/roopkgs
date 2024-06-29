{lib, config, pkgs, ...} : let
  zshCfg = config.roopkgs.home.zsh;
in{
  # See https://github.com/ajeetdsouza/zoxide?tab=readme-ov-file#configuration

  config = lib.mkIf zshCfg.enable {
    programs.zsh = {
      initExtra = ''
        eval "$(zoxide init zsh)"
      '';
    };

    home.packages = with pkgs; [
      zoxide
    ];
  };
}

