{lib, config, ...} : let
  cfg = config.roopkgs.home.zsh;
in {
  options = with lib; {
    roopkgs.home.zsh.enable = mkEnableOption "zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ls = "ls --color=auto -F";
      };

      sessionVariables = {
        CLICOLOR = 1;
        EDITOR = "hx";
      };

      autosuggestion = {
        enable = true;
      };
    };
  };
}
