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
