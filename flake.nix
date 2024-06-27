{
  description = "RooSoft's sane defaults for some applications";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    home = ./modules/home;
  };
}
