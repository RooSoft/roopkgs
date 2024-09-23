# MinIO configuration

There was a missing feature in nixpkgs regarding MinIO... the possibility to run two instances 
on the same machine. It is viable to do so, though, as all an instance need is two network ports
and a folder to write files.

## Encryption

There also is a missing piece in nixpkgs, and that's KES server management.

This configuration depends on a KES instance, which can just be configured with `roopkgs.system.kes`.
Many MinIO instances can refer to the same KES server.
