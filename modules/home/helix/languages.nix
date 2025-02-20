{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.roopkgs.home.helix;

  # See https://docs.helix-editor.com/configuration.html

  languageConfig = {
    language = [
      {
        name = "elixir";
        scope = "source.elixir";
        injection-regex = "elixir";
        file-types = ["ex" "exs"];
        roots = ["mix.exs"];
        auto-format = true;
        diagnostic-severity = "hint";
        comment-token = "#";
        indent = {
          tab-width = 2;
          unit = " ";
        };
        language-servers = ["elixir-ls"];
      }

      {
        name = "nix";
        formatter = {
          command = "alejandra";
        };
      }

      {
        name = "markdown";
        formatter = {
          command = "dprint";
          args = ["fmt" "--stdin" "md"];
        };
      }
    ];
  };

  tomlFormat = (pkgs.formats.toml {}).generate "something" languageConfig;
in
  lib.mkIf cfg.enable {
    home.file.".config/helix/languages.toml".source = tomlFormat;
  }
