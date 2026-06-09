# Single source of truth for the patched compositor build. The system module,
# Quickshell's PATH, and the mmsg client must all use this same package, or the
# closure carries two mangowc builds and mmsg can drift from the compositor.
{mangowc}:
mangowc.overrideAttrs (oldAttrs: {
  patches =
    (oldAttrs.patches or [])
    ++ [
      ../patches/mangowc-repaint-focus-borders.patch
      ../patches/mangowc-adaptive-scroller.patch
    ];
})
