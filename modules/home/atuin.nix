{
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.atuin;
in {
  options = with lib; {
    roopkgs.home.atuin.enable = mkEnableOption "atuin";
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;

      # see https://docs.atuin.sh/configuration/config/
      settings = {
        auto_sync = false;
        update_check = false;
        filter_mode = "directory";
        ctrl_n_shortcuts = true;
        enter_accept = true;

        stats = {
          common_subcommands = [
            "cargo"
            "docker"
            "git"
            "ip"
            "nix"
            "npm"
            "systemctl"
          ];

          common_prefix = ["sudo"];
        };
      };
    };
  };
}
