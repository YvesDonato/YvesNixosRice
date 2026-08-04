{
  buildNpmPackage,
  fetchurl,
  lib,
  nodejs_22,
}: let
  # Upstream's npm-shrinkwrap.json ships these workspace deps without
  # "integrity" fields, which buildNpmPackage rejects; postPatch injects them.
  # On a version bump, update `version`, `hash`, `npmDepsHash`, and these
  # integrities (copy from https://registry.npmjs.org/@earendil-works/<name>/<version>).
  workspaceDepIntegrities = {
    pi-agent-core = "sha512-Lvn89ko42h5ETUb6Z0Ku6ldskEqXaTdQBYvSa0+7bdG9V6rUEpXptv5e0OVZ1HDcvi8s6/2lGCQWsxKX+DFHNw==";
    pi-ai = "sha512-7xfLk8sANBp+bpPEbjoOZTbPxsa+++b1JXAoSJsNa3vbs9AHHEclmvg54XLQcxH+fuwaeti/g2jeIfJ+mVYLpA==";
    pi-tui = "sha512-bSuzS4EVSqEPj/Qr/p9eqCESfKsGuDNbl77EGci8Iaqqt/C/XCBZL1MjXaxSWW1NsT5afjp/Cb0NTPzOLv/aPA==";
  };
in
  buildNpmPackage rec {
    pname = "pi-coding-agent";
    version = "0.80.6";

    src = fetchurl {
      url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
      hash = "sha256-KndjRkCy2G2Q0kCHu2dVns8jZuD7UqQsVe7UFhR9pBE=";
    };

    npmDepsHash = "sha256-93ZdpMsvMSiLTeMbpp89zdbi1J5zeSgoj51o7eZtdyk=";

    nodejs = nodejs_22;
    dontNpmBuild = true;

    postPatch =
      ''
        sed -i '/\t"devDependencies": {/,/\t},/d' package.json

      ''
      + lib.concatStrings (lib.mapAttrsToList (name: integrity: ''
          substituteInPlace npm-shrinkwrap.json \
            --replace-fail $'\t\t\t"resolved": "https://registry.npmjs.org/@earendil-works/${name}/-/${name}-${version}.tgz",\n\t\t\t"license": "MIT",' \
                           $'\t\t\t"resolved": "https://registry.npmjs.org/@earendil-works/${name}/-/${name}-${version}.tgz",\n\t\t\t"integrity": "${integrity}",\n\t\t\t"license": "MIT",'
        '')
        workspaceDepIntegrities);

    meta = {
      description = "Coding agent CLI with read, bash, edit, write tools and session management";
      homepage = "https://github.com/earendil-works/pi";
      license = lib.licenses.mit;
      mainProgram = "pi";
    };
  }
