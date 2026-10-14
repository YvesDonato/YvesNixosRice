# ChatGPT desktop app for Linux (preview), which is where the Codex app lives.
# OpenAI only ships .deb/.rpm; this repackages the .deb.
#
# The download URL is an unversioned "latest" alias. When OpenAI publishes a
# new build the hash stops matching; bump both fields together:
#   curl -sL <url> -o /tmp/chatgpt.deb && dpkg-deb -f /tmp/chatgpt.deb Version
#   nix hash file --sri /tmp/chatgpt.deb
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeShellWrapper,
  perl,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  openssl,
  pango,
  systemd,
  tpm2-tss,
  vulkan-loader,
  xdg-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "chatgpt-desktop";
  version = "26.1002.52244";

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    name = "chatgpt-${finalAttrs.version}_amd64.deb";
    hash = "sha256-lJjkFxMaJ4vONb//YnXSUsDTMvF6/AMT4LeCdJ9NNIo=";
  };

  nativeBuildInputs = [dpkg autoPatchelfHook makeShellWrapper wrapGAppsHook3 perl];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libnotify
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    openssl
    pango
    systemd
    tpm2-tss
  ];

  # Qt shims load only for Qt theming; musl node prebuilds are never picked on glibc.
  autoPatchelfIgnoreMissingDeps = ["libQt5*" "libQt6*" "libc.musl-x86_64.so.1"];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r usr/lib/chatgpt $out/lib/chatgpt
    install -Dm644 usr/share/pixmaps/chatgpt.png $out/share/pixmaps/chatgpt.png
    # Drop http/https from MimeType so it can't become the default browser.
    install -Dm644 usr/share/applications/chatgpt.desktop $out/share/applications/chatgpt.desktop
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail "x-scheme-handler/http;x-scheme-handler/https;" ""

    # Opening a project loads @parcel/watcher, whose detect-libc can't read the
    # patchelf-relocated PT_INTERP (it reads only the first 2 KiB) and finds no
    # /usr/bin/ldd on NixOS, so it falls back to process.report.getReport(),
    # which trips a CFI trap in this Chromium build (SIGILL). Short-circuit the
    # report path to glibc. Same-length edit keeps every asar offset valid.
    perl -0777 -pi -e '
      $n = s/const familyFromReport = \(\) => \{\n  const report = getReport\(\);/const familyFromReport = () => {\n  return GLIBC;              /g;
      die "detect-libc patch: expected 1 match, got $n\n" unless $n == 1;
    ' $out/lib/chatgpt/resources/app.asar

    runHook postInstall
  '';

  postFixup = ''
    # Shell wrapper: wrapGAppsHook3 makes plain makeWrapper a binary wrapper,
    # which would pass the NIXOS_OZONE_WL expansion below through literally.
    # OpenAI's Owl shell ignores --ozone-platform-hint, so force wayland.
    makeShellWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libGL vulkan-loader systemd libnotify]} \
      --suffix PATH : ${lib.makeBinPath [xdg-utils]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "ChatGPT desktop app with Codex (Linux preview)";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "chatgpt";
  };
})
