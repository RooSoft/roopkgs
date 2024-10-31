{
  lib,
  pkgs,
  config,
  ...
}: {
  options = with lib; {
    roopkgs.system.minio = mkOption {
      default = {};
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "minio";

          package = mkPackageOption pkgs "minio" {};

          listenPort = mkOption {
            type = types.port;
            default = 9000;
          };

          consolePort = mkOption {
            type = types.port;
            default = 9001;
          };

          workingDirectory = mkOption {
            type = types.path;
          };

          kes = mkOption {
            default = {};
            type = types.submodule {
              options = {
                host = mkOption {
                  type = types.str;
                };

                port = mkOption {
                  type = types.port;
                  default = 7373;
                };

                keyName = mkOption {
                  type = types.str;
                };
              };
            };
          };

          clientCrtFile = mkOption {
            type = types.path;
          };

          clientKeyFile = mkOption {
            type = types.path;
          };
        };
      });
    };
  };

  config = let
    filteredCfgs = lib.attrsets.filterAttrs (_: cfg: cfg.enable) config.roopkgs.system.minio;
  in {
    networking =
      lib.attrsets.mapAttrs' (name: cfg: {
        name = "firewall";
        value = {
          allowedTCPPorts = [cfg.listenPort cfg.consolePort];
        };
      })
      filteredCfgs;

    users = {
      groups =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "minio-${name}";
          value = {};
        })
        filteredCfgs;

      users =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "minio-${name}";
          value = {
            isSystemUser = true;
            extraGroups = ["kes"];
            group = "minio-${name}";
          };
        })
        filteredCfgs;
    };

    systemd = {
      tmpfiles =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "rules";
          value = [
            "d ${cfg.workingDirectory} 750 minio-${name} minio-${name}"
            "d ${cfg.workingDirectory}/config 750 minio-${name} minio-${name}"
            "d ${cfg.workingDirectory}/data 750 minio-${name} minio-${name}"
          ];
        })
        filteredCfgs;

      services =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "minio@${name}";
          value = {
            description = "MinIO server";
            wants = ["network-online.target"];
            after = ["kes.service"];

            environment = let
              kesConfigFolder = "/var/lib/kes";
            in {
              SSL_CERT_DIR = kesConfigFolder;

              MINIO_KMS_KES_ENDPOINT = "https://${cfg.kes.host}:${toString cfg.kes.port}";

              MINIO_KMS_KES_CERT_FILE = cfg.clientCrtFile;
              MINIO_KMS_KES_KEY_FILE = cfg.clientKeyFile;
              
              MINIO_KMS_KES_KEY_NAME = cfg.kes.keyName;

              MINIO_KMS_KES_CAPATH = "${kesConfigFolder}/public.crt";
            };

            serviceConfig = {
              User = "minio-${name}";
              ExecStart = ''${cfg.package}/bin/minio server data --address ":${toString cfg.listenPort}" --console-address ":${toString cfg.consolePort}"'';

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
