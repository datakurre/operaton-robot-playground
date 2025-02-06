{ pkgs, ... }:
{
  imports = [
    ./devenv/modules/operaton.nix
  ];

  package.operaton.path = ./fixture;

  enterTest = ''
    wait_for_port 8080 60
    pur --help
  '';

  enterShell = ''
    unset PYTHONPATH
    export UV_LINK_MODE=copy
    export UV_PYTHON_DOWNLOADS=never
    if [ ! -d .venv ]; then
      ${pkgs.uv}/bin/uv venv --python ${pkgs.python3}/bin/python
    fi
    source ${pkgs.makeWrapper}/nix-support/setup-hook
    cp ${pkgs.uv}/bin/uv $(pwd)/.venv/bin/uv; chmod u+w $(pwd)/.venv/bin/uv
    wrapProgram $(pwd)/.venv/bin/uv --prefix PATH : ${pkgs.python3}/bin
    ln -fs ${pkgs.git}/bin/git $(pwd)/.venv/bin
    ln -fs ${pkgs.unzip}/bin/unzip $(pwd)/.venv/bin
    ln -fs ${pkgs.treefmt}/bin/treefmt $(pwd)/.venv/bin
    ln -fs ${pkgs.nixfmt-rfc-style}/bin/nixfmt $(pwd)/.venv/bin
    $(pwd)/.venv/bin/uv pip install -r requirements.txt
    source $(pwd)/.venv/bin/activate
  '';

  cachix.pull = [ "datakurre" ];
}
