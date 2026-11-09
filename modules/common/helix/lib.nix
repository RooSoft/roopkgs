{
  pkgs,
  unstable,
  # marksman's build needs .NET, which is not always in the binary cache
  # (e.g. aarch64-darwin), so consumers can opt out.
  withMarksman ? true,
}: let
  data = import ./data.nix;
  toml = pkgs.formats.toml {};
in {
  configFile = toml.generate "helix-config.toml" data.helixConfig;
  languagesFile = toml.generate "helix-languages.toml" data.languageConfig;

  # Packages every consumer wants when helix is enabled.
  # Lazygit is intentionally not here — each consumer decides.
  packages =
    [
      unstable.helix
      pkgs.alejandra

      # LSPs / formatters referenced by helixConfig + languageConfig
      unstable.markdown-oxide
      unstable.dprint
      pkgs.nil
      pkgs.nixd
      pkgs.beamMinimal28Packages.elixir-ls
    ]
    ++ pkgs.lib.optional withMarksman pkgs.marksman;
}
