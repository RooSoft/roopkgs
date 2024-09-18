{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.dust;

  # See: https://github.com/bootandy/dust?tab=readme-ov-file#usage
  dustConfig = {
    # ignore-directory = ".git";
    ignore-hidden = true;
  };

  tomlFormat = (pkgs.formats.toml {}).generate "something" dustConfig;
in {
  options = with lib; {
    roopkgs.home.dust.enable = mkEnableOption "dust";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        dust
      ];

      file.".config/dust/config.toml".source = tomlFormat;
    };
  };
}
