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

In the `flake.nix` file make sure `agenix` is part of the inputs

```nix
  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
```

Add agenix into the machine's `special args`

```nix
specialArgs = {inherit self agenix;};
```

Add this section to the machine's modules array:

```nix
  ({...}: {
    kesPublicCrtFile = ./secrets/kes.public.crt.age;
    kesPrivateKeyFile = ./secrets/kes.private.key.age;

    minioKesCrtFile = ./secrets/minio.kes.crt.age;
    minioKesKeyFile = ./secrets/minio.kes.key.age;
  })
```

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
