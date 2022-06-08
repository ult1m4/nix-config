{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{

  imports = [
    (import "${home-manager}/nixos")
    (import ./hardware-configuration.nix)
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-6e09827a-28c0-4067-9832-c4086d59e0bf".device = "/dev/disk/by-uuid/6e09827a-28c0-4067-9832-c4086d59e0bf";
  boot.initrd.luks.devices."luks-6e09827a-28c0-4067-9832-c4086d59e0bf".keyFile = "/crypto_keyfile.bin";

  # Kernel package
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixaroni"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure screens/resolution/hz
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xrandr}/bin/xrandr --output DVI-I-0 --mode 1920x1080 --pos 0x0 --rotate left --output DVI-I-1 --off --output HDMI-0 --mode 1920x1080 --pos 3000x726 --rotate normal --output DP-0 --off --output DP-1 --off --output DP-2 --primary --mode 1920x1080 --rate 143.98 --pos 1080x726 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off
  '';

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable entropy daemon which refills /dev/random when low
  services.haveged.enable = true;

  # Simple stateful dual-stack firewall
  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    logRefusedConnections = true;
    checkReversePath = false; # for libvirtd
  };

  # Disable sudo password for the wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.goomba = {
    isNormalUser = true;
    description = "goomba";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  /*
    # Set up home manager for dotfiles
    home-manager.users.goom = { pkgs, ... }: {
    #home.packages = [ pkgs.atool pkgs.httpie ];
    };
  */

  # Give library for Steam build and enable NUR
  nixpkgs.config.packageOverrides = pkgs: {

    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };

    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
      ];
    };
  };

  
  # Updates NIXOS
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-unstable;

  # Allow unfree packages and enable Nvidia
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Xbox Controller (also installed xow)
  hardware.xpadneo.enable = true;
  services.hardware.xow.enable = true;

  # Install Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Allow broken packages (testing for TES3MP build...)
  # nixpkgs.config.allowBroken = true;

  # Import EMACS overlay...
  nixpkgs.overlays = [
    (import (builtins.fetchTarball https://github.com/nix-community/emacs-overlay/archive/master.tar.gz))
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #dmenu
    obs-studio
    openssl
    wget
    git
    librewolf
    vim
    emacs
    ripgrep
    coreutils
    fd
    clang
    #pkgs.emacsGcc
    emacsNativeComp
    htop
    discord
    steam
    geany
    easyeffects
    gimp
    firefox
    blender
    bash
    boost
    openal
    openscenegraph
    mygui
    qt6.qt5compat
    bullet
    ffmpeg
    SDL2
    ncurses
    luajit
    boost
    rustup
    gnome.gnome-screenshot
    # nur.repos.crazazy.js.tldr
    tdesktop
    usbutils
    pciutils
    lshw
    dmidecode
    unzip
    libxml2
    jq
    yq
    exfat
    zip
    open-vm-tools
    xow
    element-desktop
    redshift
    ntfs3g #for bad windows alt drive, fix this later
    libreoffice-fresh
    nixpkgs-fmt
    betterdiscordctl
    godot
    lutris
    standardnotes
    qbittorrent
    dxvk
    wine
    bottles
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with pkgs.vimPlugins; {
          start = [ vim-lastplace vim-nix ];
          opt = [ ];
        };
        customRC = ''
          set nocompatible
          set backspace=indent,eol,start
          set number
        '';
      };
    })
    

    # Extra Dev
    lsb-release
    cmake
    bundix
    python27Full
    python37Full
    shellcheck
    gtk3
    pkgconfig
    gcc
    gpp
    gdb
    automake
    gnumake
    pkg-config
    clang-tools
    indent
    splint
    binutils

    #Random for OpenMW
    recastnavigation
    lz4
    qt6.wrapQtAppsHook
    libGL
    libGLU
    glm
    freeglut
    unshield
    libxkbcommon
  ];
  # Enable QEMU VM
  virtualisation.libvirtd.enable = true;

  # Install and configure Docker
  /*
    virtualisation.docker = {
    enable = true;
    # Run docker system prune -f periodically
    autoPrune.enable = true;
    autoPrune.dates = "weekly";
    # Don't start the service at boot, use systemd socket activation
    enableOnBoot = false;
    };
  */
  # Periodically update the database of files used by the locate command
  services.locate.enable = true;

  #Setup Alias(s)
  environment.interactiveShellInit = ''
    alias nconfig='sudo vim /etc/nixos/configuration.nix'
  '';

  #Set default editor Vim
  environment.variables.EDITOR = "vim";

  /*
  #Redshift config
    location.latitude = 35.96;
    location.longitude = -83.92;
  
    services.redshift = {
    enable = true;
    temperature.day = 3500;
    temperature.night = 3500;
    }; 
  */

  #Nix jobs
  nix = {
    # Automatically run the garbage collector
    gc.automatic = true;
    gc.dates = "12:45";
    # Automatically run the nix store optimiser
    optimise.automatic = false;
    optimise.dates = [ "12:55" ];
    # Nix automatically detects files in the store that have identical contents, and replaces them with hard links to a single copy.
    autoOptimiseStore = true;
    # maximum number of concurrent tasks during one build
    buildCores = 6;
    # maximum number of jobs that Nix will try to build in parallel
    # "auto" is broken: https://github.com/NixOS/nixpkgs/issues/50623
    maxJobs = 4;
    # perform builds in a sandboxed environment
    useSandbox = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
