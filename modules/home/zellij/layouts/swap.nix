{...}: {
  home.file.".config/zellij/layouts/default.kdl" = {
    text = ''
      layout {
        tab {
          pane
        }

        swap_tiled_layout name="vertical" {
              tab max_panes=5 {
              pane split_direction="vertical" {
                  pane
                  pane { children; }
              }
          }
          tab max_panes=8 {
              pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
              }
          }
          tab max_panes=12 {
              pane split_direction="vertical" {
                  pane { children; }
                  pane { pane; pane; pane; pane; }
                  pane { pane; pane; pane; pane; }
              }
          }
        }

        swap_tiled_layout name="horizontal" {
              tab max_panes=5 {
              pane
              pane
          }
          tab max_panes=8 {
              pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
              }
          }
          tab max_panes=12 {
              pane {
                  pane split_direction="vertical" { children; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
                  pane split_direction="vertical" { pane; pane; pane; pane; }
              }
          }
        }

        default_tab_template {
          children
          pane size=1 borderless=true {
            plugin location="file:~/.config/zjstatus/bin/zjstatus.wasm" {
              format_left "{mode}{tabs}"
              format_right "#[fg=#83a598,bold]{session} #[fg=#b8bb26,bold]{swap_layout}"

              mode_normal        "#[fg=#b8bb26,bold]{name}"
              mode_locked        "#[fg=#fb4934,bold]{name}"
              mode_resize        "#[fg=#fabd2f,bold]{name}"
              mode_pane          "#[fg=#d3869b,bold]{name}"
              mode_tab           "#[fg=#83a598,bold]{name}"
              mode_scroll        "#[fg=#8ec07c,bold]{name}"
              mode_session       "#[fg=#fe8019,bold]{name}"
              mode_move          "#[fg=#a89984,bold]{name}"

              tab_normal   "#[fg=#a89984,bold] {name}"
              tab_active   "#[fg=#83a598,bold] {name}"
            }
          }
        }
      }
    '';
  };
}
