{
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
        language-servers = ["nixd"];
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
}
