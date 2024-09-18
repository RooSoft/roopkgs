{pkgs, ...}: let
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
in {
  environment = {
    systemPackages = [
      pkgs.minio-certgen
      pkgs.openssl
      kes
    ];

    variables = let
      configFolder = "/var/lib/kes";
    in {
      SSL_CERT_DIR = configFolder;

      KES_SERVER = "https://127.0.0.1:7373";
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

  systemd.services.kes = {
    description = "KES server";
    wants = ["network-online.target"];
    after = ["network-online.target"];

    environment = let
      configFolder = "/var/lib/kes";
    in {
      SSL_CERT_DIR = configFolder;

      KES_SERVER = "https://127.0.0.1:7373";
      KES_CLIENT_CERT = "${configFolder}/client.crt";
      KES_CLIENT_KEY = "${configFolder}/client.key";
    };

    serviceConfig = {
      User = "kes";
      ExecStart = "${kes}/bin/kes server --config /var/lib/kes/config.yml";

      WorkingDirectory = "/var/lib/kes";
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
}
