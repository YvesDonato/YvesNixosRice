{
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:{

  imports = [
  ];
  
  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
    settings = {
      theme = "tokyonight_moon";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
        };
        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };
      };
    };
  };
}
