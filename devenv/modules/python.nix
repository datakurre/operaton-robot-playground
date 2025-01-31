{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.languages.python;
  inherit (lib) types mkOption;
  python = cfg.interpreter;
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = config.languages.python.workspaceRoot;
  };
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        pkgs.lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          overlay
          cfg.pyprojectOverrides
        ]
      );
  editableOverlay = workspace.mkEditablePyprojectOverlay {
    root = "$REPO_ROOT";
  };
  editablePythonSet = pythonSet.overrideScope editableOverlay;
in
{
  options.languages.python = {
    interpreter = mkOption {
      type = types.package;
    };
    workspaceRoot = mkOption {
      type = types.path;
      default = ../../.;
    };
    pyprojectOverrides = mkOption {
      default = final: prev: {
      };
    };
  };
  config = {
    languages.python = {
      uv.package = pkgs.buildFHSEnv {
        name = "uv";
        targetPkgs = pkgs: [
          pkgs.uv
          python
        ];
        runScript = "uv";
      };
    };
    packages = [
      # cfg.uv.package  # bwrap issue in codespaces
      pkgs.uv
      config.outputs.python.virtualenv
    ];
    enterShell = ''
      unset PYTHONPATH
      export UV_LINK_MODE=copy
      export UV_PYTHON_DOWNLOADS=never
      export REPO_ROOT=$(git rev-parse --show-toplevel)
    '';
    outputs.python =
      let
        pyprojectName =
          (builtins.fromTOML (builtins.readFile (cfg.workspaceRoot + "/pyproject.toml"))).project.name;
      in
      {
        virtualenv = editablePythonSet.mkVirtualEnv "${pyprojectName}-dev-env" workspace.deps.all;
        app = pythonSet.mkVirtualEnv "${pyprojectName}-env" workspace.deps.default;
      };
  };
}
