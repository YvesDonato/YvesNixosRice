{
  lib,
  pkgs,
  pkgs-unstable,
  inputs,
  desktopWindowManager,
  ...
}: let
  mangowcPatched = pkgs.callPackage ../packages/mangowc-patched.nix {};
  quickshellRuntimePath =
    (lib.makeBinPath ((with pkgs; [
        acpi
        bash
        brightnessctl
        coreutils
        gnugrep
        gnused
      ])
      ++ [mangowcPatched]))
    + ":/run/current-system/sw/bin:/etc/profiles/per-user/yvesd/bin";
in {
  assertions = [
    {
      assertion = builtins.elem desktopWindowManager ["hyprland" "mango"];
      message = "desktopWindowManager must be either \"hyprland\" or \"mango\".";
    }
  ];

  imports = [
    ./modules/hyprland.nix
    ./modules/mango.nix
    ./modules/nixvim.nix
    # ./modules/helix.nix
    # ./modules/zed-editor.nix
  ];

  home = {
    username = "yvesd";
    homeDirectory = "/home/yvesd";
    stateVersion = "25.11";

    packages = [
    ];

    file = {
      ".config/opencode/opencode.json" = {
        force = true;
        text =
          builtins.toJSON {
            "$schema" = "https://opencode.ai/config.json";
            plugin = ["superpowers@git+https://github.com/obra/superpowers.git"];
            permission = {
              bash = {
                "*" = "ask";
                "git status*" = "allow";
                "git diff*" = "allow";
                "rg *" = "allow";
                "ls *" = "allow";
              };
              edit = "ask";
              task = "ask";
              "agentbrowser_*" = "ask";
            };
            mcp = {
              agentbrowser = {
                type = "local";
                command = [
                  (lib.getExe' pkgs.nodejs "npx")
                  "-y"
                  "@playwright/mcp@0.0.71"
                  "--executable-path"
                  (lib.getExe pkgs.chromium)
                  "--no-sandbox"
                  "--output-dir"
                  "/tmp/opencode-agentbrowser"
                ];
                environment = {
                  PATH = "${lib.makeBinPath [pkgs.nodejs]}:{env:PATH}";
                };
                enabled = true;
              };
            };
          }
          + "\n";
      };

      ".config/opencode/plugins/notifications.js" = {
        force = true;
        text = ''
          const notifySend = "${lib.getExe' pkgs.libnotify "notify-send"}";
          const quickshellBridge = "http://127.0.0.1:9999";
          const permissionNotificationDelayMs = 15000;
          const pendingPermissionNotifications = new Map();
          const notifiedPermissions = new Set();

          const asText = (value) => {
            if (!value) return "";
            if (typeof value === "string") return value;
            if (typeof value.message === "string") return value.message;
            if (typeof value.name === "string") return value.name;

            try {
              return JSON.stringify(value);
            } catch {
              return String(value);
            }
          };

          const trim = (value, limit = 240) => {
            const text = asText(value).replace(/\s+/g, " ").trim();
            return text.length > limit ? text.slice(0, limit - 1) + "…" : text;
          };

          export const OpenCodeNotifications = async ({ $ }) => {
            const notify = async (summary, body = "", urgency = "normal") => {
              const safeSummary = trim(summary, 80) || "OpenCode";
              const safeBody = trim(body, 240);
              const message = safeBody ? safeSummary + ": " + safeBody : safeSummary;

              try {
                await $`''${notifySend} -a OpenCode -u ''${urgency} ''${safeSummary} ''${safeBody}`;
                return;
              } catch {
                // Fall back to the local Quickshell bridge when the notification daemon is unavailable.
              }

              try {
                await fetch(quickshellBridge, {
                  method: "POST",
                  headers: { "Content-Type": "application/json" },
                  body: JSON.stringify({ message }),
                });
              } catch {
                // Notification delivery is best-effort; never break OpenCode work.
              }
            };

            const permissionID = (permission) => permission?.id || permission?.requestID;

            const clearPermissionNotification = (permission) => {
              const id = permissionID(permission);
              if (!id) return;

              const timer = pendingPermissionNotifications.get(id);
              if (timer) clearTimeout(timer);
              pendingPermissionNotifications.delete(id);
            };

            const sendPermissionNotification = async (permission) => {
              const id = permissionID(permission);
              if (id) {
                pendingPermissionNotifications.delete(id);
                notifiedPermissions.add(id);
              }

              await notify(
                "OpenCode needs approval",
                permission?.title || permission?.type || "A permission prompt is waiting.",
                "normal",
              );
            };

            const schedulePermissionNotification = (permission) => {
              const id = permissionID(permission);
              if (id && (pendingPermissionNotifications.has(id) || notifiedPermissions.has(id))) return;

              const timer = setTimeout(() => {
                void sendPermissionNotification(permission);
              }, permissionNotificationDelayMs);

              if (id) pendingPermissionNotifications.set(id, timer);
            };

            return {
              event: async ({ event }) => {
                if (event.type === "session.idle") {
                  const sessionID = event.properties?.sessionID;
                  const session = sessionID ? "Session " + sessionID.slice(0, 8) : "Session";
                  await notify("OpenCode finished", session + " is idle.");
                }

                if (event.type === "session.error") {
                  await notify("OpenCode error", event.properties.error || "Session failed.", "critical");
                }

                if (event.type === "permission.replied") {
                  clearPermissionNotification(event.properties);
                }

                if (event.type === "permission.updated" || event.type === "permission.asked") {
                  schedulePermissionNotification(event.properties);
                }
              },

              "permission.ask": async (input) => {
                schedulePermissionNotification(input);
              },
            };
          };
        '';
      };
    };

    sessionVariables = {
    };
  };

  xdg.configFile."quickshell/generated/desktop-wm".text = desktopWindowManager + "\n";

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "Adwaita-dark";
    style = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  systemd.user.services = {
    quickshell = {
      Unit = {
        Description = "Quickshell desktop shell";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/quickshell";
        Environment =
          [
            "PATH=${quickshellRuntimePath}"
            "QT_QPA_PLATFORM=wayland"
            "XDG_CURRENT_DESKTOP=${
              if desktopWindowManager == "mango"
              then "mango"
              else "Hyprland"
            }"
            "XDG_SESSION_DESKTOP=${desktopWindowManager}"
            "XDG_SESSION_TYPE=wayland"
          ]
          ++ lib.optionals (desktopWindowManager == "mango") [
            "WAYLAND_DISPLAY=wayland-0"
          ];
        Restart = "on-failure";
        RestartSec = 2;
        MemoryHigh = "512M";
        MemoryMax = "1G";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };

    quickshell-notification-server = {
      Unit = {
        Description = "Quickshell notification HTTP bridge";
        After = ["graphical-session.target" "quickshell.service"];
        PartOf = ["graphical-session.target"];
        # The script lives in unmanaged quickshell config; without this guard a
        # missing file puts the unit in a 2s crash-restart loop.
        ConditionPathExists = "%h/.config/quickshell/scripts/notification-server.py";
      };

      Service = {
        ExecStart = "${pkgs.python3}/bin/python3 -u /home/yvesd/.config/quickshell/scripts/notification-server.py";
        Restart = "on-failure";
        RestartSec = 2;
        MemoryHigh = "64M";
        MemoryMax = "128M";
        TasksMax = 32;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };

  services = {
    hypridle = {
      enable = true;
      settings =
        if desktopWindowManager == "hyprland"
        then {
          general = {
            before_sleep_cmd = "qs ipc call lock locked true";
            after_sleep_cmd = "sleep 0.5; hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            ignore_systemd_inhibit = false;
            lock_cmd = "qs ipc call lock locked true";
          };

          listener = [
            {
              timeout = 1800;
              on-timeout = "qs ipc call lock locked true";
            }
            {
              timeout = 1810;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        }
        else {
          general = {
            before_sleep_cmd = "qs ipc call lock locked true";
            ignore_dbus_inhibit = false;
            ignore_systemd_inhibit = false;
            lock_cmd = "qs ipc call lock locked true";
          };

          listener = [
            {
              timeout = 1800;
              on-timeout = "qs ipc call lock locked true";
            }
          ];
        };
    };
  };

  programs = {
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      options = [
        "--cmd cd"
      ];
    };

    nushell = {
      enable = true;
      extraConfig = ''
        $env.config = {
          show_banner: false,
        }
      '';
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        clean = "sudo nix-collect-garbage -d";
        z = "zeditor";
        c = "cd";
        h = "nvim";
      };
    };

    ghostty = {
      enable = true;
      package = pkgs-unstable.ghostty;
      settings = {
        theme = "TokyoNight Moon";
        background-opacity = 0.80;
        background-blur = false;
        copy-on-select = true;
        keybind = [
          "ctrl+v=paste_from_clipboard"
          "ctrl+y=copy_to_clipboard"
          "ctrl+1=decrease_font_size:1"
          "ctrl+2=increase_font_size:1"
          "ctrl+r=reset_font_size"
        ];
      };
    };

    zellij = {
      enable = true;
      package = pkgs-unstable.zellij;
      settings = {
        theme = "tokyo-night-dark";
        default_layout = "compact";
        simplified_ui = true;
        pane_frames = false;
        show_startup_tips = false;
        copy_on_select = true;
      };
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        aws.disabled = true;
      };
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };
  };
  programs.home-manager.enable = true;
}
