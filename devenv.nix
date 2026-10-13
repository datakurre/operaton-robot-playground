{ pkgs, config, ... }:
{
  services.operaton.enable = true;
  services.operaton.port = 8080;
  services.operaton.postgres.enable = true;
  services.operaton.deployment = ./bpmn;
  services.operaton.adminUser.id = "demo";
  services.operaton.adminUser.password = "demo";

  dotenv.enable = true;

  languages.java.enable = true;
  languages.java.jdk.package = pkgs.jdk25;

  languages.javascript.enable = true;
  languages.javascript.npm.enable = true;

  profiles.devcontainer.module = {
    devcontainer.enable = true;
    devcontainer.settings.image = "ghcr.io/cachix/devenv/devcontainer:v2.4.0";
    devcontainer.settings.customizations.vscode.extensions = [
      "bbenoist.Nix"
      "be5invis.toml"
      "GitHub.copilot"
      "GitHub.copilot-chat"
      "mkhl.direnv"
      "d-biehl.robotcode"
      "datakurre.vscode-operaton-bpmn-js-modeler"
      "datakurre.vscode-operaton-dmn-js-modeler"
      "datakurre.vscode-operaton-form-js-modeler"
      "datakurre.devenv"
      "DavidAnson.vscode-markdownlint"
    ];
    devcontainer.settings.customizations.vscode.settings = {
      "bpmnModeler.engineRestUrl" = "http://localhost:8080/engine-rest";
    };
  };

  services.vault = {
    enable = true;
    disableMlock = true;
    ui = true;
  };

  processes.vault-configure-kv.exec =
    let
      configureScript = pkgs.writeShellScriptBin "configure-vault-kv" ''
        set -euo pipefail

        # Wait for the vault server to start up
        response=""
        while [ -z "$response" ]; do
          response=$(${pkgs.curl}/bin/curl -s --max-time 5 "${config.env.VAULT_API_ADDR}/v1/sys/init" | ${pkgs.jq}/bin/jq '.initialized' || true)
          if [ -z "$response" ]; then
            echo "Waiting for vault server to respond..."
            sleep 1
          fi
        done
        while [ ! -f "${config.env.DEVENV_STATE}/env_file" ]; do
            sleep 1s
        done

        # Export VAULT_TOKEN
        source ${config.env.DEVENV_STATE}/env_file

        # Ensure /kv/secret
        if ! ${pkgs.vault-bin}/bin/vault secrets list | grep -q '^secret/'; then
          ${pkgs.vault-bin}/bin/vault secrets enable -path=secret kv-v2
        fi
      '';
    in
    "${configureScript}/bin/configure-vault-kv";
  
  packages = [
    pkgs.vim
  ];  

  enterTest = ''
    wait_for_port 8080 180
    wait_for_port 8200 60
  '';

  enterShell = ''
    unset PYTHONPATH
    export UV_LINK_MODE=copy
    export UV_PYTHON_DOWNLOADS=never
    export UV_PYTHON_PREFERENCE=system
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
    if [ -f ${config.env.DEVENV_STATE}/env_file ]; then
      source ${config.env.DEVENV_STATE}/env_file
    fi
  '';

  cachix.pull = [
    "datakurre"
    "vasara-bpm"
  ];
}
