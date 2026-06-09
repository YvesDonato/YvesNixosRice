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
    pi-agent-core = "sha512-LHygOgsW2pgXKb3IkXkOAeZPovHr9VF+EixgXVsDNuB4jmhEOXgshy/zksZ7slkUAx10OQ9W1Ed/2jsnhd1NqA==";
    pi-ai = "sha512-zf1F5kXk1pqZeFShXOqq9ibUk8QdtRoLCDPAjO+hj44e3EUs9/GFO2qnhTC5+JA2uwVCx+WCNe1PiCjlBYWm5w==";
    pi-tui = "sha512-LkXUM1/49pvzzeI39Y5wjBMlgafcCf67HCLhB9Z7yuXHy4XgT+VqxWcZVW5hBdhQsHZd0znjJotfGH1BzxMfiA==";
  };
in
  buildNpmPackage rec {
    pname = "pi-coding-agent";
    version = "0.75.5";

    src = fetchurl {
      url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
      hash = "sha256-iP/3TR/MkzQ+g5qoherLNeiM2quX2sJjaxG+zDskmfw=";
    };

    npmDepsHash = "sha256-GZtl7v1xfBgFgXST/aJem5RI4+sffdSnJJX7OMBe4tY=";

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
