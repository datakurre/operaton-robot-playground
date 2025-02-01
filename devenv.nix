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
  ];

  package.operaton.path = ./fixture;

  packages = [
    pkgs.entr
    pkgs.git
    pkgs.findutils
    pkgs.gnumake
    pkgs.openssl
    pkgs.uv
  ];

  dotenv.disableHint = true;

  enterTest = ''
    wait_for_port 8080 60
  '';

  enterShell = ''
    unset PYTHONPATH
    export UV_LINK_MODE=copy
    export UV_PYTHON_DOWNLOADS=never
    uv venv
    source .venv/bin/activate
    uv pip install "black>24,<26" "robotframework-tidy>3,<5" "robotframework>6,<8" "purjo>=1.0.0a3"
  '';

  cachix.pull = [ "datakurre" ];

  git-hooks.hooks.treefmt = {
    enable = true;
    settings.formatters = [
      pkgs.nixfmt-rfc-style
    ];
  };
}
