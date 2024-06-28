{
  lib,
  pkgs,
  ...
}: {
  options = with lib; {
    roopkgs.home.helix.enable = mkEnableOption "helix";
  };

  imports = [
    ./config.nix
    ./languages.nix
  ];

  config = {
    home = {
      packages = with pkgs; [helix alejandra];
    };
  };
}
