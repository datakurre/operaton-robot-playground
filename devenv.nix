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

  dotenv.disableHint = true;

  enterTest = ''
    wait_for_port 8080 60
  '';

  enterShell = ''
    unset PYTHONPATH
    export UV_LINK_MODE=copy
    export UV_PYTHON_DOWNLOADS=never
    if [ ! -d .venv ]; then
      ${pkgs.uv}/bin/uv venv --python ${pkgs.python3}/bin/python
      source ${pkgs.makeWrapper}/nix-support/setup-hook
      cp ${pkgs.uv}/bin/uv $(pwd)/.venv/bin/uv
      chmod u+w $(pwd)/.venv/bin/uv
      wrapProgram $(pwd)/.venv/bin/uv --prefix PATH : ${pkgs.python3}/bin
    fi
    $(pwd)/.venv/bin/uv pip install -r requirements.txt
    source $(pwd)/.venv/bin/activate
  '';

  cachix.pull = [ "datakurre" ];

  git-hooks.hooks.treefmt = {
    enable = true;
    settings.formatters = [
      pkgs.nixfmt-rfc-style
    ];
  };
}
