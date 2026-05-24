{
  pkgs,
  unstable,
}: let
  data = import ./data.nix;
  toml = pkgs.formats.toml {};
in {
  configFile = toml.generate "helix-config.toml" data.helixConfig;
  languagesFile = toml.generate "helix-languages.toml" data.languageConfig;

  # Packages every consumer wants when helix is enabled.
  # Lazygit is intentionally not here — each consumer decides.
  packages = [
    unstable.helix
    pkgs.alejandra

    # LSPs / formatters referenced by helixConfig + languageConfig
    pkgs.marksman
    unstable.markdown-oxide
    unstable.dprint
    pkgs.nil
    pkgs.nixd
    pkgs.beamMinimal28Packages.elixir-ls
  ];
}
