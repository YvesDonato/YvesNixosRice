{
  pkgs,
  inputs,
  ...
}: let
  # Nix's Playwright 1.56.1 browser bundle contains Chromium revision 1194,
  # which matches the Python Playwright 1.56.0 wheel used by openconnect-saml.
  pythonPlaywrightVersion = "1.56.0";
  anyConnectUserAgent = "AnyConnect Linux_64 4.7.00136";
  defaultSheridanVpnIp = "142.55.3.2";
  sheridanVpnRunner = pkgs.writeText "sheridan-vpn-runner.py" ''
    import os
    import socket

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

        self._context = await self._browser.new_context(
            bypass_csp=True,
            user_agent=(
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            ),
        )
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
        return await original_authenticate_at(
            self,
            url,
            credentials=credentials,
            final_url=final_url,
            token_cookie_name=token_cookie_name,
        )


    chrome_mod.ChromeBrowser.spawn = sheridan_spawn
    chrome_mod.ChromeBrowser.authenticate_at = sheridan_authenticate_at

    from openconnect_saml.cli import main

    raise SystemExit(main())
  '';
  sheridanVpn = pkgs.writeShellApplication {
    name = "sheridan-vpn";
    runtimeInputs = with pkgs; [
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
          --with 'openconnect-saml[chrome]' \
          --with 'playwright==${pythonPlaywrightVersion}' \
          python '${sheridanVpnRunner}' "$@"
      }

      if [[ "''${1:-}" == "disconnect" ]]; then
        run_openconnect_saml "$@"
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
    inputs.zen-browser.packages."${stdenv.hostPlatform.system}".default
    chromium
    anki
    rofi
    pavucontrol
    pamixer
    networkmanagerapplet
    sheridanVpn
    blanket
    libreoffice
    obs-studio
    blueman
    crispy-doom
    sqlitebrowser
    isoimagewriter

    # Terminal
    neovim
    git
    neofetch
    wget
    killall
    btop
    tlp
    git-credential-manager
    wlr-randr
    lsof
    yazi
    asusctl
    supergfxctl
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

    glib
    nss
    nspr
  ];
}
