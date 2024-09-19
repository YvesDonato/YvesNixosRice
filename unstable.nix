 { config, pkgs-unstable, ...}:{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs-unstable; [
    electron
    obsidian
    hypridle
    firefox
    moonlight-qt 
  ];
  
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs {
    #version = "550.40.07";
    # the new driver
    #src = builtins.fetchurl
      #{
        #url = "https://download.nvidia.com/XFree86/Linux-x86_64/550.40.07/NVIDIA-Linux-x86_64-550.40.07.run";
        #sha256 = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
      #};
  #};

}
