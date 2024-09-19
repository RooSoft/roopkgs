{
  lib,
  pkgs,
  config,
  ...
}: let
  pname = "kes";
  version = "2024-06-17T15-47-05Z";

  uid = 900;
  gid = 900;

  kes = pkgs.buildGoModule {
    pname = pname;
    version = version;

    src = pkgs.fetchFromGitHub {
      owner = "minio";
      repo = "${pname}";
      rev = "${version}";
      hash = "sha256-vKEmwwUVIDAXftDe5uyMUNbxHxm17/SWfRx9kL4SbNI=";
    };

    vendorHash = "sha256-FonlBiCXhCeIATS99q39jnsFtH+91yYqZUJ86MInxzI=";

    meta = {
      description = "Key Managament Server for Object Storage and more";
      homepage = "https://github.com/minio/kes";
    };
  };

  cfg = config.roopkgs.system.kes;

  yamlFormat = pkgs.formats.yaml {};

  kesConfig = {
    address = "0.0.0.0:7373";
    admin = {
      identity = cfg.adminIdentity;
    };

    tls = {
      key = cfg.privateKey;
      cert = cfg.publicCrt;
      auth = "off";
    };

    keystore = {
      fs = {
        path = "./keys";
      };
    };
  };

  kesCfgFile = yamlFormat.generate "config.yml" kesConfig;
in {
  options = with lib; {
    roopkgs.system.kes = {
      enable = mkEnableOption "kes";

      listenPort = mkOption {
        type = types.port;
        default = 7373;
      };

      publicCrt = mkOption {
        type = types.path;
      };

      privateKey = mkOption {
        type = types.path;
      };

      configFolder = mkOption {
        type = types.path;
        default = "/var/lib/kes";
      };

      adminIdentity = mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [
        pkgs.minio-certgen
        pkgs.openssl
        kes
      ];

      variables = {
        SSL_CERT_DIR = cfg.configFolder;

        KES_SERVER = "https://127.0.0.1:${toString cfg.listenPort}";
      };
    };

    users.groups.kes = {
      inherit gid;
    };

    users.users.kes = {
      inherit uid;

      group = "kes";
      extraGroups = [];
      packages = [];
      shell = pkgs.bash;
    };

    systemd = {
      tmpfiles = {
        rules = [
          "d ${cfg.configFolder} 750 kes kes"
        ];
      };

      services.kes = {
        description = "KES server";
        wants = ["network-online.target"];
        after = ["network-online.target"];

        environment = {
          SSL_CERT_DIR = cfg.configFolder;

          KES_SERVER = "https://127.0.0.1:7373";
          KES_CLIENT_CERT = "${cfg.configFolder}/client.crt";
          KES_CLIENT_KEY = "${cfg.configFolder}/client.key";
        };

        serviceConfig = {
          User = "kes";
          ExecStart = "${kes}/bin/kes server --config ${kesCfgFile}";

          WorkingDirectory = cfg.configFolder;
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
  };
}
