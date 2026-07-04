# Single source of truth for the patched compositor build. The system module,
# Quickshell's PATH, and the mmsg client must all use this same package, or the
# closure carries two mango builds and mmsg can drift from the compositor.
# `mango` comes from pkgs-unstable (call with pkgs-unstable.callPackage);
# stable's mangowc lags and broke the local patch on version bumps.
{mango}:
mango.overrideAttrs (oldAttrs: {
  patches =
    (oldAttrs.patches or [])
    ++ [
      ../patches/mango-adaptive-scroller.patch
    ];
})
