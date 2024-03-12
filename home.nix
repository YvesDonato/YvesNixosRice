{ config, pkgs, ... }:

{
  home.username = "yvesd";
  home.homeDirectory = "/home/yvesd";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
  
  ];

  home.file = {
  
  };
  
  home.sessionVariables = {
  
  };
  
  # Program Settings
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };
  programs.starship = {
    enable = true;
    settings = {
      
    };
  };

  programs.home-manager.enable = true;
}
