{
  config,
  lib,
  ...
}: let
  cfg = config.roopkgs.home.starship;
in {
  options = with lib; {
    roopkgs.home.starship.enable = mkEnableOption "starship";
  };

  config = lib.mkIf cfg.enable {
    # See https://starship.rs/config/

    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        scan_timeout = 250;

        palette = "foo";

        palettes.foo = {
          mustard = "#af8700";
          time = "#778485";
          directory = "#A7A5AB";
          identity = "#778485";
          git_branch = "#778485";
          deleted = "#a05050";
          added = "#208020";
        };

        fill.symbol = " ";

        username = {
          show_always = true;
          style_user = "identity bold";
          style_root = "bright-red bold";
          format = "[$user]($style)";
        };

        hostname = {
          ssh_only = false;
          ssh_symbol = " 📞";
          style = "identity bold";
          format = "@[$hostname]($style)$ssh_symbol ";
        };

        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
          format = "[$read_only]($read_only_style)[$path]($style) ";
          read_only = "🔒 ";
          style = "directory bold";
        };

        git_branch = {
          style = "git_branch bold";
          format = "[$symbol$branch(:$remote_branch)]($style) ";
        };

        git_metrics = {
          disabled = false;
          added_style = "added bold";
          deleted_style = "deleted bold";
        };

        git_status.style = "";

        time = {
          disabled = false;
          format = "[$time]($style)";
          style = "time bold";
        };

        cmd_duration = {
          style = "mustard bold";
          format = "[$duration]($style) ";
        };

        jobs = {
          format = "[$number$symbol]($style)";
          symbol = "⚙ ";
          style = "mustard bold";
        };

        format = let
          who = [
            "$username"
            "$hostname"
            "$directory"
          ];

          git = [
            "$git_branch"
            "$git_state"
            "$git_status"
            "$git_metrics"
          ];

          fill = ["$fill"];

          duration = [
            "$cmd_duration"
          ];

          time = [
            "$jobs"
            "$time"
          ];

          languages = [
            "$nix_shell"
            "$nodejs"
            "$elixir"
            "$lua"
          ];

          prompt = [
            "$line_break"
            "❯ "
          ];
        in
          lib.concatStrings (who ++ git ++ fill ++ duration ++ languages ++ time ++ prompt);
      };
    };
  };
}
