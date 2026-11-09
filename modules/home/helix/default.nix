{
  lib,
  pkgs,
  config,
  unstable,
  ...
}: let
  cfg = config.roopkgs.home.helix;
  helix = import ../../common/helix {
    inherit pkgs unstable;
    withMarksman = cfg.marksman.enable;
  };
in {
  options = with lib; {
    roopkgs.home.helix.enable = mkEnableOption "helix";
    roopkgs.home.helix.marksman.enable =
      mkEnableOption "the marksman markdown LSP (needs .NET to build)"
      // {default = true;};
  };

  imports = [
    ./config.nix
    ./languages.nix
  ];

  # Only install helix and its LSPs when enabled. Unconditional install
  # pulled marksman (and a from-source .NET build) onto every machine.
  config = lib.mkIf cfg.enable {
    home.packages = helix.packages;
  };
}
