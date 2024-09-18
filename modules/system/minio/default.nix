{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roopkgs.system.minio;
in {
  imports = [
    ./kes.nix
  ];

  options = with lib; {
    roopkgs.system.minio = {
      enable = mkEnableOption "minio";

      dataPort = mkOption {
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
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [cfg.dataPort cfg.consolePort];
      };
    };

    users.users.minio = {
      extraGroups = ["kes"];
    };

    systemd.services.minio = {
      description = "MinIO server";
      wants = ["network-online.target"];
      after = ["kes.service"];

      environment = let
        kesConfigFolder = "/var/lib/kes";
        caFolder = "/var/lib/minio/config/CAs";
      in {
        SSL_CERT_DIR = kesConfigFolder;

        MINIO_KMS_KES_ENDPOINT = "https://127.0.0.1:7373";

        MINIO_KMS_KES_CERT_FILE = "${caFolder}/kes.crt";
        MINIO_KMS_KES_KEY_FILE = "${caFolder}/kes.key";

        MINIO_KMS_KES_KEY_NAME = "my-key-2";

        MINIO_KMS_KES_CAPATH = "${kesConfigFolder}/public.crt";
      };

      serviceConfig = {
        User = "kes";
        ExecStart = ''${pkgs.minio}/bin/minio server \
          --address ":${toString cfg.dataPort}" \
          --console-address ":${toString cfg.consolePort}"
        '';

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
  };
}
