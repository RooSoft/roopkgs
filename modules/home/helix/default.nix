{
  lib,
  pkgs,
  unstable,
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
      packages = [unstable.helix pkgs.alejandra];
    };
  };
}
