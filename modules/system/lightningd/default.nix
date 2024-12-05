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
        lib.attrsets.mapAttrs' (name: cfg: let

          configFile = pkgs.writeText "config.json" 
          ''
            alias=${name}
            rgb=${cfg.rgb}

            network=${cfg.network}
            # log-file=${cfg.workingDirectory}/lightning.log
            log-level=debug

            fee-base=1000
            fee-per-satoshi=10
            min-capacity-sat=1000000

            large-channels
            funding-confirms=2
            # autocleaninvoice-cycle=86400
            # autocleaninvoice-expired-by=86400

            bind-addr=0.0.0.0:${toString cfg.port}

            bitcoin-cli=/run/current-system/sw/bin/bitcoin-cli
            bitcoin-rpcconnect=bitcoin-signet
            bitcoin-rpcport=38332
            bitcoin-rpcuser=lightning
            bitcoin-rpcpassword=7fM3AEwFw-5iP7LQ917q-__4AKK9DWTwh3hpNIQjTAw
          '';
  
        in {
          name = "lightning@${name}";
          value = {
            description = "${name} Core Lightning server";
            wants = ["network-online.target"];

            serviceConfig = {
              User = "lightning-${name}";
              ExecStart = ''${cfg.package}/bin/lightningd --conf ${configFile} --lightning-dir ${cfg.workingDirectory}'';

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
