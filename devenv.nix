{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./devenv/modules/operaton.nix
    ./devenv/modules/python.nix
  ];

  package.operaton.path = ./fixture;
  languages.python.interpreter = pkgs.python312;

  packages = [
    pkgs.entr
    pkgs.findutils
    pkgs.gnumake
    pkgs.openssl
  ];

  dotenv.disableHint = true;

  enterTest = ''
    wait_for_port 8080 60
  '';

  cachix.pull = [ "datakurre" ];

  devcontainer.enable = true;

  git-hooks.hooks.treefmt = {
    enable = true;
    settings.formatters = [
      pkgs.nixfmt-rfc-style
    ];
  };
}
