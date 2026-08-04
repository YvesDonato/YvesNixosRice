{
  pkgs,
  inputs,
  ...
}: let
  # Nix's Playwright 1.59.1 browser bundle (26.05) contains Chromium revision
  # 1217, which matches the Python Playwright 1.59.0 wheel used by
  # openconnect-saml. These must be re-paired on nixpkgs bumps: the wheel
  # looks up browsers by revision inside PLAYWRIGHT_BROWSERS_PATH.
  pythonPlaywrightVersion = "1.59.0";
  anyConnectUserAgent = "AnyConnect Linux_64 4.7.00136";
  defaultSheridanVpnIp = "142.55.3.2";
  sheridanVpnRunner = pkgs.writeText "sheridan-vpn-runner.py" ''
    import json
    import os
    import socket
    import tempfile

    sheridan_storage_dir = os.path.expanduser("~/.config/sheridan-vpn")
    sheridan_storage_path = os.path.join(sheridan_storage_dir, "storage_state.json")

    from openconnect_saml.browser import chrome as chrome_mod

    original_authenticate_at = chrome_mod.ChromeBrowser.authenticate_at


    vpn_ip = os.environ.get("SHERIDAN_VPN_RESOLVE_IP")
    if vpn_ip:
        original_getaddrinfo = socket.getaddrinfo


        def pinned_getaddrinfo(host, port, *args, **kwargs):
            if host == "vpn.sheridancollege.ca":
                return original_getaddrinfo(vpn_ip, port, *args, **kwargs)
            return original_getaddrinfo(host, port, *args, **kwargs)


        socket.getaddrinfo = pinned_getaddrinfo


    async def sheridan_spawn(self):
        try:
            from playwright.async_api import async_playwright
        except ImportError as exc:
            raise ImportError(
                "Playwright is not installed. Install openconnect-saml with the chrome extra."
            ) from exc

        self._playwright = await async_playwright().start()

        launch_args = {
            "headless": self.headless,
            "args": ["--disable-blink-features=AutomationControlled"],
        }
        if vpn_ip:
            launch_args["args"].append(
                f"--host-resolver-rules=MAP vpn.sheridancollege.ca {vpn_ip}"
            )
        if self.proxy:
            launch_args["proxy"] = {"server": self.proxy}
        if self.channel:
            launch_args["channel"] = self.channel

        try:
            self._browser = await self._playwright.chromium.launch(**launch_args)
        except Exception as exc:
            try:
                if self._playwright:
                    await self._playwright.stop()
            except Exception:
                pass
            self._playwright = None

            msg = str(exc).lower()
            if "executable" in msg or "browsertype" in msg or "doesn't exist" in msg:
                raise RuntimeError(
                    "Chromium is not available to Playwright. The Nix wrapper should provide it."
                ) from exc
            raise

        os.makedirs(sheridan_storage_dir, mode=0o700, exist_ok=True)
        context_args = {
            "bypass_csp": True,
            "user_agent": (
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            ),
        }
        # Restore a previously saved Microsoft (Azure AD) session so reconnects
        # complete via silent SSO instead of a fresh browser login.
        if os.path.exists(sheridan_storage_path):
            try:
                with open(sheridan_storage_path) as fh:
                    saved_state = json.load(fh)
                if not isinstance(saved_state, dict):
                    raise ValueError("saved storage state is not a JSON object")
                cookies = saved_state.get("cookies", [])
                origins = saved_state.get("origins", [])
                if not isinstance(cookies, list) or not isinstance(origins, list):
                    raise ValueError("saved storage state has invalid collections")
                if not all(isinstance(cookie, dict) for cookie in cookies):
                    raise ValueError("saved storage state has invalid cookies")
                if not all(isinstance(origin, dict) for origin in origins):
                    raise ValueError("saved storage state has invalid origins")
                if not all(isinstance(cookie.get("domain", ""), str) for cookie in cookies):
                    raise ValueError("saved storage state has invalid cookie domains")

                # Never restore the VPN gateway's single-use SAML token.
                saved_state["cookies"] = [
                    cookie
                    for cookie in cookies
                    if "sheridancollege.ca" not in cookie.get("domain", "")
                ]
                saved_state["origins"] = origins
            except (OSError, json.JSONDecodeError, TypeError, ValueError):
                # A partial/invalid prior write must not prevent a fresh login.
                try:
                    os.unlink(sheridan_storage_path)
                except OSError:
                    pass
            else:
                context_args["storage_state"] = saved_state

        try:
            self._context = await self._browser.new_context(**context_args)
        except Exception:
            if "storage_state" not in context_args:
                raise

            # Let Playwright perform the definitive schema validation. If a
            # saved state is syntactically valid but unusable, discard it and
            # retry exactly once with a fresh browser context.
            context_args.pop("storage_state", None)
            try:
                os.unlink(sheridan_storage_path)
            except OSError:
                pass
            self._context = await self._browser.new_context(**context_args)
        self._page = await self._context.new_page()
        self._page.set_default_timeout(self.timeout)


    async def sheridan_authenticate_at(
        self,
        url,
        credentials=None,
        final_url=None,
        token_cookie_name=None,
    ):
        async def use_anyconnect_user_agent(route, request):
            headers = dict(request.headers)
            headers["user-agent"] = "${anyConnectUserAgent}"
            await route.continue_(headers=headers)

        await self._page.route(
            "https://vpn.sheridancollege.ca/+CSCOE+/saml/sp/login**",
            use_anyconnect_user_agent,
        )
        result = await original_authenticate_at(
            self,
            url,
            credentials=credentials,
            final_url=final_url,
            token_cookie_name=token_cookie_name,
        )
        # Persist the Microsoft session for next time (best-effort; never break
        # the connection if saving fails). Contains sensitive cookies -> 0600.
        # Drop the VPN gateway's cookies before saving: its acSamlv2Token is
        # single-use, so persisting it would be replayed and rejected next time.
        temporary_path = None
        try:
            saved_state = await self._context.storage_state()
            saved_state["cookies"] = [
                c
                for c in saved_state.get("cookies", [])
                if "sheridancollege.ca" not in c.get("domain", "")
            ]
            fd, temporary_path = tempfile.mkstemp(
                prefix=".storage_state.", suffix=".tmp", dir=sheridan_storage_dir
            )
            with os.fdopen(fd, "w") as fh:
                json.dump(saved_state, fh)
                fh.flush()
                os.fsync(fh.fileno())
            os.chmod(temporary_path, 0o600)
            os.replace(temporary_path, sheridan_storage_path)
            temporary_path = None
        except Exception:
            pass
        finally:
            if temporary_path is not None:
                try:
                    os.unlink(temporary_path)
                except OSError:
                    pass
        return result


    chrome_mod.ChromeBrowser.spawn = sheridan_spawn
    chrome_mod.ChromeBrowser.authenticate_at = sheridan_authenticate_at

    from openconnect_saml.cli import main

    raise SystemExit(main())
  '';
  sheridanVpn = pkgs.writeShellApplication {
    name = "sheridan-vpn";
    runtimeInputs = with pkgs; [
      coreutils
      openconnect
      uv
    ];
    text = ''
      export PATH="/run/wrappers/bin:$PATH"
      export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers-chromium}"
      export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS="true"
      export SHERIDAN_VPN_RESOLVE_IP="''${SHERIDAN_VPN_RESOLVE_IP:-${defaultSheridanVpnIp}}"

      run_openconnect_saml() {
        exec uv run \
          --with 'openconnect-saml[chrome]==0.24.5' \
          --with 'playwright==${pythonPlaywrightVersion}' \
          python '${sheridanVpnRunner}' "$@"
      }

      if [[ "''${1:-}" == "disconnect" ]]; then
        run_openconnect_saml "$@"
      fi

      # Switch Microsoft account: the saved SSO session in storage_state.json
      # is what silently signs the last account back in. Drop it so the login
      # window shows a fresh account picker, then continue connecting.
      # Optionally: sheridan-vpn switch-account someone@sheridancollege.ca
      if [[ "''${1:-}" == "switch-account" ]]; then
        shift
        rm -f "$HOME/.config/sheridan-vpn/storage_state.json"
        echo "Cleared saved Microsoft session; sign in with the account you want." >&2
        if [[ $# -gt 0 && "''${1:-}" == *@* ]]; then
          export SHERIDAN_VPN_USER="$1"
          shift
        fi
      fi

      foreground=true
      if [[ "''${1:-}" == "foreground" || "''${1:-}" == "debug" ]]; then
        foreground=true
        shift
      fi
      if [[ "''${1:-}" == "background" || "''${1:-}" == "detach" ]]; then
        foreground=false
        shift
      fi

      /run/wrappers/bin/sudo -v

      args=(
        --server "vpn.sheridancollege.ca"
        --authgroup "SHERIDAN-VPN"
        --browser "chrome"
        --no-totp
        --no-history
        --useragent "${anyConnectUserAgent}"
        --resolve "vpn.sheridancollege.ca:$SHERIDAN_VPN_RESOLVE_IP"
      )

      if [[ "$foreground" == false ]]; then
        args+=(--detach --wait "''${SHERIDAN_VPN_WAIT:-60}")
      fi

      if [[ -n "''${SHERIDAN_VPN_USER:-}" ]]; then
        args+=(--user "$SHERIDAN_VPN_USER")
      fi

      run_openconnect_saml "''${args[@]}" "$@"
    '';
  };
in {
  environment.systemPackages = with pkgs; [
    # Programs
    anki
    rofi
    pavucontrol
    pamixer
    networkmanagerapplet
    sheridanVpn
    blanket
    libreoffice
    freecad # Same 1.1.1 as unstable; stable avoids GDAL 3.13.1's failing Zarr test
    obs-studio
    blueman
    crispy-doom
    sqlitebrowser
    # Qt6/KDE-Gear-6 build; the top-level Qt5 alias was removed in 26.05
    kdePackages.isoimagewriter
    # adb/fastboot; replaces the removed programs.adb module (26.05)
    android-tools

    # Terminal
    arduino-cli
    neovim
    git
    fastfetch # neofetch was removed in 26.05 (unmaintained upstream)
    wget
    killall
    btop
    git-credential-manager
    wlr-randr
    lsof
    yazi
    asusctl
    lshw
    glow
    curl
    openconnect
    acpi
    patchelf
    leetcode-cli
    gitui
    fd
    python313Packages.weasyprint
    unzip
    p7zip
    pandoc
    fzf
    libnotify

    # Languages
    alejandra
    ruff
    clang
    svelte-language-server
    typescript-language-server
    tailwindcss-language-server
    pyright
    glibc
    zlib
    marksman
    ripgrep

    # mongosh
    # mongodb

    # system
    xwayland
    brightnessctl
    gnome-disk-utility
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    swtpm
    dex
    transmission_4
    qemu
    tailscale

    glib
    nss
    nspr
  ];
}
