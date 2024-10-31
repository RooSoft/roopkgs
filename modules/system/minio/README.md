# MinIO configuration

There was a missing feature in nixpkgs regarding MinIO... the possibility to run two instances 
on the same machine. It is viable to do so, though, as all an instance need is two network ports
and a folder to write files.

## Encryption

There also is a missing piece in nixpkgs, and that's KES server management.

This configuration depends on a KES instance, which can just be configured with `roopkgs.system.kes`.
Many MinIO instances can refer to the same KES server.

## How to install

KES has to be configured before any MinIO instance

### KES configuration

#### Server key generation

Make sure `certgen` is installed. On NixOS:

```bash
nix-shell -p certgen
```

Then, if you want to create a local host certificate:

```bash
certgen -host "127.0.0.1,localhost"
```

#### Server configuration

In the `flake.nix` file make sure `agenix` and `roopkgs` are part of the inputs

```nix
  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  roopkgs = {
    url = "github:RooSoft/roopkgs";
  };
```

Add agenix into the machine's `special args`

```nix
specialArgs = {inherit self agenix;};
```

Add this section to the machine's modules array:

```nix
  ({...}: {
    publicCrtFile = ./secrets/kes.public.crt.age;
    privateKeyFile = ./secrets/kes.private.key.age;
  })
```

Also, make sure `agenix.packages.x86_64-linux.agenix` is installed on the host machine
through the `configuration.nix` file. The agenix variable should be available from there
since it's included in the `specialArgs`.


#### Create `public.crt` and `private.key` secrets

We'll explain how to add the `private.key` file. The same has to be done for `public.crt`.

In the flake's `secrets` folder, add this bash script named `edit-kes.private.key.sh`

```bash
sudo EDITOR=hx agenix -e kes.private.key.age -i /etc/ssh/ssh_host_ed25519_key
```

Create a `secrets.nix` file if it does not already exist

```nix
let
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNqpcHLS2Ip1Cdz53LuMF/znGtsLWeA4vr3WLETb9sZ";
in {
  "kes.public.crt.age".publicKeys = [system];
  "kes.private.key.age".publicKeys = [system];
}
```

The system key comes from `/etc/ssh/ssh_host_ed25519_key.pub`. Tells agenix that the related
ed25519 key can be used to encrypt and decrypt the underlying secrets.

Now run `./edit-kes.private.key.sh` and paste the `private.key` file contents created earlier.

#### Configure KES on the host

In a module under the host's configuration file, add `agenix.nixosModules.default` to the imports
array.

Then, create an agenix section refering to the variables created above

```nix
  age = {
    secrets = {
      publicCrt = {
        file = config.publicCrtFile;
        path = "/var/lib/kes/public.crt";
        mode = "440";
        owner = "kes";
        group = "kes";
      };

      privateKey = {
        file = config.privateKeyFile;
        owner = "kes";
        group = "kes";
      };
    };
  };
```

Here, the public certificate will end up being written in the `/var/lib/kes/public.crt` file, while
the private key doesn't really need to be accessed outside this configuration file. It thus doesn't
have to get a recognizable path.

All that's left is to configure a `KES` instande from roopkgs

```nix
  roopkgs.system = {
    kes = {
      enable = true;

      publicCrt = config.age.secrets.publicCrt.path;
      privateKey = config.age.secrets.privateKey.path;

      identities = [
        "901b125bf3c2e7b16423cfee6825c3c5efacbb642bb04a95ee39bfa61480c112"
      ];
    };
  };
```

Now let's talk about the `identities` value here. Next to the `private.key` and `public.crt` files,
create client crential files:

```bash
certgen -client -host "localhost"
```

The `client.crt` and `client.key` files will be useful to connect MinIO to the KES certificate autorithy

Extract this new identity and put it in the above nix config under `roopkgs.system.kes.identities`

```bash
kes identity of client.crt
```

From that point on, the system should be able to be updated with `nixos-rebuild switch` and have KES installed.

```bash
journalctl -u kes
````

To check if everything is ok


### MinIO configuration

Now that we've got the `client.crt` and `client.key` files, let's create secrets for them in the same way
that's been done for KES.

We won't discuss how to do it, as it's the same as for KES keys. Here is what the new `secrets.nix` file 
might end up looking like...

```nix
let
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNqpcHLS2Ip1Cdz53LuMF/znGtsLWeA4vr3WLETb9sZ";
in {
  "kes.public.crt.age".publicKeys = [system];
  "kes.private.key.age".publicKeys = [system];

  "minio.client.crt.age".publicKeys = [system];
  "minio.client.key.age".publicKeys = [system];
}
```

In the `minio` section of the `flake.nix`, make sur to refer to those keys

```nix
  ({...}: {
    kes = {
      publicCrtFile = ./secrets/kes.public.crt.age;
    }; 

    clientCrtFile = ./secrets/minio.client.crt.age;
    clientKeyFile = ./secrets/minio.client.key.age;
  })
```

Make sure these options are added to the host configuration file, so they match the configuration above:

```nix
    clientCrtFile = mkOption {
      type = types.path;
    };
    clientKeyFile = mkOption {
      type = types.path;
    };
```

Now, we need a MinIO configuration file that will contain

```nix
  age = {
    secrets = {
      clientCrt = {
        file = config.clientCrtFile;
        path = "/var/lib/kes/client.crt";
        mode = "440";
        owner = "kes";
        group = "kes";
      };

      clientKey = {
        file = config.clientKeyFile;
        path = "/var/lib/kes/client.key";
        mode = "440";
        owner = "kes";
        group = "kes";
      };
    };
  };
```

And here is a special case of a system containing two MinIO instances named `minio@one` and `minio@two`

```nix
  roopkgs.system = {
    minio = {
      one = {
        enable = true;

        package = pkgs_unstable.minio;

        listenPort = oneListenPort;
        consolePort = oneConsolePort;

        workingDirectory = "/var/lib/minio-one";

        # same as two
        clientCrtFile = config.age.secrets.clientCrt.path;
        clientKeyFile = config.age.secrets.clientKey.path;
      };

      two = {
        enable = true;

        package = pkgs_unstable.minio;

        listenPort = twoListenPort;
        consolePort = twoConsolePort;

        workingDirectory = "/var/lib/minio-two";

        # same as one
        clientCrtFile = config.age.secrets.clientCrt.path;
        clientKeyFile = config.age.secrets.clientKey.path;
      };
    };
  };
```
