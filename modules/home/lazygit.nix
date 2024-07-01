{
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.lazygit;
in {
  options = with lib; {
    roopkgs.home.lazygit.enable = mkEnableOption "lazygit";
  };

  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;

      # See: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
      settings = {
        gui = {
          showIcons = true;
        };
      };
    };
  };
}
