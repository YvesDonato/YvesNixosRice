# Single source of truth for the patched compositor build. The system module,
# Quickshell's PATH, and the mmsg client must all use this same package, or the
# closure carries two mango builds and mmsg can drift from the compositor.
# `mango` comes from the pinned upstream flake so 0.15.x gets its matching
# wlroots and scenefx dependencies.
{mango}:
mango.overrideAttrs (oldAttrs: {
  __intentionallyOverridingVersion = true;
  version = "0.15.1";
  patches =
    (oldAttrs.patches or [])
    ++ [
      ../patches/mango-adaptive-scroller.patch
      ../patches/mango-eleven-tags.patch
    ];
})
