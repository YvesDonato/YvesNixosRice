# Single source of truth for the patched compositor build. The system module,
# Quickshell's PATH, and the mmsg client must all use this same package, or the
# closure carries two mango builds and mmsg can drift from the compositor.
# `mango` comes from the pinned upstream flake so it gets its matching wlroots
# and scenefx dependencies. The patches target 0.18.0's split sources; the
# extra-tags patch is gone because 0.18's `tag_num` does it.
{mango}:
mango.overrideAttrs (oldAttrs: {
  __intentionallyOverridingVersion = true;
  version = "0.18.0";
  # Runs the native-stream unit tests (tests/native_*.c).
  doCheck = true;
  patches =
    (oldAttrs.patches or [])
    ++ [
      ../patches/mango-adaptive-scroller.patch
      ../patches/mango-native-stream.patch
    ];
})
