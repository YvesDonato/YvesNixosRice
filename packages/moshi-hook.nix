# moshi-hook: host daemon/CLI for the Moshi iOS terminal (https://getmoshi.app).
# Static Go binary from Moshi's CDN; bump `version` and `hash` together (the hash
# is in https://cdn.getmoshi.app/hook/v<version>/checksums.txt). `moshi update`
# can't replace a store path, so updates go through this file.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "moshi-hook";
  version = "0.4.28";

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${finalAttrs.version}/moshi-hook_Linux_x86_64.tar.gz";
    hash = "sha256-iii27u9v5qZlIbbrxLNO72rThKuoAohrulmSMbfOxPI=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 moshi-hook $out/bin/moshi-hook
    ln -s moshi-hook $out/bin/moshi
    runHook postInstall
  '';

  meta = {
    description = "Moshi host daemon: agent hooks, SSH/Mosh pairing and the gateway for the Moshi app";
    homepage = "https://getmoshi.app";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    mainProgram = "moshi-hook";
  };
})
