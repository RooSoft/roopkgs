{
  lib,
  config,
  ...
}: let
  cfg = config.roopkgs.home.atuin;
in {
  imports = [
    ./kes.nix
  ];

  options = with lib; {
    roopkgs.system.minio.enable = mkEnableOption "minio";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedTCPPorts = [9000 9001];
      };
    };

    users.users.minio = {
      extraGroups = ["kes"];
    };

    systemd.services.minio = {
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
    };
  };
}
