{
  lib,
  pkgs,
  unstable,
  ...
}: let
  helix = import ../../common/helix {inherit pkgs unstable;};
in {
  options = with lib; {
    roopkgs.home.helix.enable = mkEnableOption "helix";
  };

  imports = [
    ./config.nix
    ./languages.nix
  ];

  config = {
    home = {
      packages = helix.packages;
    };
  };
}
