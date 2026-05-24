{
  lib,
  pkgs,
  config,
  unstable,
  ...
}: let
  cfg = config.roopkgs.home.helix;
  helix = import ../../common/helix {inherit pkgs unstable;};
in
  lib.mkIf cfg.enable {
    home.file.".config/helix/languages.toml".source = helix.languagesFile;
  }
