{
  lib,
  pkgs,
  config,
  unstable,
  ...
}: {
  imports = [
    ../lazygit.nix
  ];

  config = let
    cfg = config.roopkgs.home.helix;

    # See https://docs.helix-editor.com/configuration.html

    helixConfig = {
      # theme = "jellybeans";
      theme = "catppuccin_macchiato";

      editor = {
        true-color = true;
        line-number = "relative";
        mouse = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        lsp = {
          display-messages = true;
        };

        statusline = {
          center = ["version-control"];
          right = ["diagnostics" "position" "position-percentage" "file-encoding" "file-type"];
        };

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
      };

      keys = {
        normal = {
          C-e = [
            ":sh rm -f /tmp/unique-file"
            ":insert-output yazi %{buffer_name} --chooser-file=/tmp/unique-file"
            ":insert-output echo \"\x1b[?1049h\x1b[?2004h\" > /dev/tty"
            ":open %sh{cat /tmp/unique-file}"
            ":redraw"
          ];
          C-k = ["extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" ":format"];
          C-j = ["extend_to_line_bounds" "delete_selection" "paste_after" ":format"];
          C-l = [":new" ":insert-output lazygit" ":buffer-close" ":redraw"];

          # macro for nix files, splitting chains into attribute sets
          C-m = "@i = {<ret><down><backspace>;<ret><esc>mae<C-k>:format<ret>";
        };
        insert = {
          j = {k = "normal_mode";};
        };
      };
    };

    tomlFormat = (pkgs.formats.toml {}).generate "something" helixConfig;
  in
    lib.mkIf cfg.enable {
      roopkgs.home.lazygit.enable = true;

      home = {
        file.".config/helix/config.toml".source = tomlFormat;

        packages = with pkgs; [
          # Why marksman: https://www.youtube.com/watch?v=8GQKOLh_V5E
          marksman

          unstable.markdown-oxide
          unstable.dprint

          # nix language server
          nil
        ];
      };
    };
}
