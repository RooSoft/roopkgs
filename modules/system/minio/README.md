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
