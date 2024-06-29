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


## instructions

* Import this flake

```nix
roopkgs = {
  url = "https://github.com/RooSoft/roopkgs.git";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

* Add `roopkgs.nixosModules.home` to any computer configuration's `home-manager` imports

* Enable fully configured applications on said computers, example here with `helix`

```nix
roopkgs.home.helix.enable = true;

```
