{
  lib,
  pkgs,
  config,
  ...
}: {
  options = with lib; {
    roopkgs.system.lightningd= mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "lightningd";

          package = mkPackageOption pkgs "clightning" {};

          network = mkOption {
            type = types.enum ["mainnet" "signet"];
            default = "mainnet";
          };

          alias = mkOption {
            type = types.str;
          };

          rgb = mkOption {
            type = types.str;
          };

          port = mkOption {
            type = types.port;
            default = 9735;
          };

          workingDirectory = mkOption {
            type = types.path;
          };
        };
      });
    };
  };

  config = let
    filteredCfgs = lib.attrsets.filterAttrs (_: cfg: cfg.enable) config.roopkgs.system.lightningd;
  in {
    users = {
      groups =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "lightning-${name}";
          value = {};
        })
        filteredCfgs;

      users =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "lightning-${name}";
          value = {
            isSystemUser = true;
            group = "lightning-${name}";
          };
        })
        filteredCfgs;
    };

    systemd = {
      tmpfiles =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "rules";
          value = [
            "d ${cfg.workingDirectory} 750 lightning-${name} lightning-${name}"
          ];
        })
        filteredCfgs;

      services =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "lightning@${name}";
          value = {
            description = "${name} Core Lightning server";
            wants = ["network-online.target"];

            serviceConfig = {
              User = "lightning-${name}";
              ExecStart = ''${cfg.package}/bin/lightningd --lightning-dir ${cfg.workingDirectory}'';

              WorkingDirectory = cfg.workingDirectory;
              Type = "simple";
              Restart = "always";
              TimeoutSec = 120;
              RestartSec = 30;
              KillMode = "process";

              PrivateTmp = true;
              PrivateDevices = true;
              MemoryDenyWriteExecute = true;
            };

            wantedBy = ["multi-user.target"];
          };
        })
        filteredCfgs;
    };
  };
}
