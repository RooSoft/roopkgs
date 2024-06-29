# roopkgs

Removes some configuration repetition across different computers


## Available configurations for

* zsh
* eza
* helix
* atuin
* tmux
* zellij
* starship
* alacritty


## How to use

#### Import this flake

```nix
roopkgs = {
  url = "https://github.com/RooSoft/roopkgs.git";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

#### Enable for a given computer

Example: add `roopkgs.nixosModules.home` to `nixos-computer`'s `home-manager` imports

```nix
"me@nixos-computer" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages."x86_64-linux";
  extraSpecialArgs = {
    inherit inputs pkgs;
  };
  modules = [
    roopkgs.nixosModules.home
    ./machines/nixos-computer/users/me/home.nix];
  ];
};
```

#### Configure applications in the configuration file

Example here with `helix`

```nix
roopkgs.home.helix.enable = true;
```
