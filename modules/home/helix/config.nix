{
  lib,
  pkgs,
  config,
  unstable,
  ...
}: let
  cfg = config.roopkgs.home.helix;
  helix = import ../../common/helix {inherit pkgs unstable;};
in {
  imports = [
    ../lazygit.nix
  ];

  config = lib.mkIf cfg.enable {
    roopkgs.home.lazygit.enable = true;

    home.file.".config/helix/config.toml".source = helix.configFile;
  };
}
