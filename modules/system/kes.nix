{
  lib,
  pkgs,
  config,
  ...
}: let
  pname = "kes";
  version = "2024-09-11T07-22-50Z";

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
    address = cfg.address;

    admin = {
      identity = "disabled"; # cfg.adminIdentity;
    };

    tls = {
      key = cfg.privateKey;
      cert = cfg.publicCrt;
      auth = "off";
    };

    policy = {
      minio = {
        allow = [
          "/v1/key/create/*"
          "/v1/key/generate/*"
          "/v1/key/decrypt/*"
          "/v1/key/bulk/decrypt"
          "/v1/key/list"
          "/v1/status"
          "/v1/metrics"
          "/v1/log/audit"
          "/v1/log/error"
        ];

        identities = cfg.identities;
      };
    };

    keystore = {
      vault = {
        endpoint = cfg.vaultEndpoint;
        engine = "kv/";
        version = "v2";
        approle = {
          id = cfg.vaultAppId;
          secret = cfg.vaultAppSecret;
          retry = "15s";
        };

        status = {
          ping = "10s";
        };
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

      address = mkOption {
        type = types.str;
        default = "0.0.0.0:7373";
      };

      identities = mkOption {
        type = types.listOf types.str;
      };

      vaultEndpoint = mkOption {
        type = types.str;
      };

      vaultAppId = mkOption {
        type = types.str;
      };

      vaultAppSecret = mkOption {
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
