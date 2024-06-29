{lib, config, pkgs, ...} : let
  zshCfg = config.roopkgs.home.zsh;
in{
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

