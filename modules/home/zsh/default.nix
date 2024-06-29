{lib, config, pkgs, ...} : let
  cfg = config.roopkgs.home.zsh;
in {
  imports = [
    ./fzf.nix
    ./zoxide.nix
  ];

  options = with lib; {
    roopkgs.home.zsh.enable = mkEnableOption "zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      shellAliases = {
        ls = "ls --color=auto -F";
      };

      sessionVariables = {
        CLICOLOR = 1;
        EDITOR = "hx";
      };
    };
  };
}
