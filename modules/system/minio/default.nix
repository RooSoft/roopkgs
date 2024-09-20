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
            default = "/var/lib/minio";
          };

          kesCrtFile = mkOption {
            type = types.path;
          };

          kesKeyFile = mkOption {
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

    users.groups.minio = {};

    users.users.minio = {
      isSystemUser = true;
      extraGroups = ["kes"];
      group = "minio";
    };

    systemd = {
      tmpfiles =
        lib.attrsets.mapAttrs' (name: cfg: {
          name = "rules";
          value = [
            "d ${cfg.workingDirectory} 750 minio minio"
            "d ${cfg.workingDirectory}/config 750 minio minio"
            "d ${cfg.workingDirectory}/data 750 minio minio"
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

              MINIO_KMS_KES_ENDPOINT = "https://127.0.0.1:7373";

              MINIO_KMS_KES_CERT_FILE = cfg.kesCrtFile;
              MINIO_KMS_KES_KEY_FILE = cfg.kesKeyFile;

              MINIO_KMS_KES_KEY_NAME = "minio";

              MINIO_KMS_KES_CAPATH = "${kesConfigFolder}/public.crt";
            };

            serviceConfig = {
              User = "minio";
              ExecStart = ''${pkgs.minio}/bin/minio server data --address ":${toString cfg.listenPort}" --console-address ":${toString cfg.consolePort}"'';

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
