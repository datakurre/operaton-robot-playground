{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.package.editor;
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
  inherit (lib) types mkOption;
in
{
  packages = [
    (pkgs.vscode-with-extensions.override {
      vscodeExtensions = [
        pkgs.vscode-extensions.bbenoist.nix
        pkgs.vscode-extensions.ms-vscode-remote.remote-containers
        pkgs.vscode-extensions.vscodevim.vim
      ];
    })
  ];
}
