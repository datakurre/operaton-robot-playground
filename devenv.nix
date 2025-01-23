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
  languages.python.pyprojectOverrides = final: prev: {
    "operaton-robot-runner" = prev."operaton-robot-runner".overrideAttrs (old: {
      nativeBuildInputs =
        old.nativeBuildInputs
        ++ final.resolveBuildSystem ({
          "hatchling" = [ ];
        });
    });
    "operaton-tasks" = prev."operaton-tasks".overrideAttrs (old: {
      nativeBuildInputs =
        old.nativeBuildInputs
        ++ final.resolveBuildSystem ({
          "hatchling" = [ ];
        });
    });
  };

  processes.gateway.exec = "operaton-robot-runner --log-level=DEBUG";

  packages = [
    pkgs.entr
    pkgs.git
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
