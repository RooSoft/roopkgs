{
  lib,
  pkgs,
  config,
  unstable,
  ...
}: let
  cfg = config.roopkgs.system.helix;
  helix = import ../../common/helix {inherit pkgs unstable;};
in {
  options.roopkgs.system.helix.enable =
    lib.mkEnableOption "system-wide helix (XDG config in /etc/xdg/helix)";

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "xdg/helix/config.toml".source = helix.configFile;
      "xdg/helix/languages.toml".source = helix.languagesFile;
    };

    environment.systemPackages = helix.packages ++ [pkgs.lazygit];
  };
}
