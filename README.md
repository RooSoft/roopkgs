# roopkgs

a list of modules that can be reused in any flake configuration

so far, it's a proof of concept only containing `eza`

once working, the target computer will contain an `e` alias that will call `eza` with a specific set of parameters

## instructions

import this flake

```nix
roopkgs = {
  url = "https://github.com/RooSoft/roopkgs.git";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

add `roopkgs.nixosModules.home` to any computer configuration's `home-manager` imports

then, roopkg's specific `eza` configuration could be added to that computer like so

```nix
roopkgs.home = {
  eza.enable = true;
};

```
