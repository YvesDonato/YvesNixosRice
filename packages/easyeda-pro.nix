# EasyEDA Pro desktop client (Electron), repackaged from the vendor zip.
# Versioned URL: bump `version` and `hash` together (hash also listed in the
# AUR easyeda-pro-bin PKGBUILD).
{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeShellWrapper,
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
  pango,
  systemd,
  vulkan-loader,
  xdg-utils,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "easyeda-pro";
  version = "3.2.149";

  src = fetchurl {
    url = "https://image.easyeda.com/files/easyeda-pro-linux-x64-${finalAttrs.version}.zip";
    hash = "sha256-Qv/qOjNVgeOB6dDJSXB6HVif2iW83ggid1nbO1Q7mHU=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [unzip autoPatchelfHook makeShellWrapper wrapGAppsHook3];

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
    pango
    systemd
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r easyeda-pro $out/lib/easyeda-pro
    rm $out/lib/easyeda-pro/chrome-sandbox # needs setuid; user-namespace sandbox is used instead

    for f in $out/lib/easyeda-pro/icon/icon_*x*.png; do
      size=''${f##*icon_}; size=''${size%.png}
      install -Dm644 $f $out/share/icons/hicolor/$size/apps/easyeda-pro.png
    done
    install -Dm644 easyeda-pro/easyeda-pro.dkt $out/share/applications/easyeda-pro.desktop
    substituteInPlace $out/share/applications/easyeda-pro.desktop \
      --replace-fail "Exec=/opt/apps/easyeda-pro/easyeda-pro %f --no-sandbox --gtk-version=3" "Exec=easyeda-pro %f" \
      --replace-fail "Icon=/usr/share/icons/hicolor/128x128/apps/easyeda-pro.png" "Icon=easyeda-pro"

    runHook postInstall
  '';

  postFixup = ''
    # Shell wrapper so the NIXOS_OZONE_WL expansion runs at launch (see chatgpt-desktop.nix).
    makeShellWrapper $out/lib/easyeda-pro/easyeda-pro $out/bin/easyeda-pro \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libGL vulkan-loader systemd]} \
      --suffix PATH : ${lib.makeBinPath [xdg-utils]} \
      --add-flags "--gtk-version=3" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "EasyEDA Pro electronic circuit and PCB design tool";
    homepage = "https://pro.easyeda.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "easyeda-pro";
  };
})
