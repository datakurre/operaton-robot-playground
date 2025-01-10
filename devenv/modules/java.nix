{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.languages.java;
  inherit (lib) types mkOption;
in
{
  options.languages.java.mvn2nix = {
    package = mkOption {
      type = types.package;
      default = inputs.mvn2nix.defaultPackage.${pkgs.system}.override {
        jdk = cfg.jdk.package;
        maven = cfg.maven.package;
      };
    };
    lib = mkOption {
      type = types.attrs;
      default = import inputs.nixpkgs {
        localSystem = pkgs.system;
        overlays = [ inputs.mvn2nix.overlay ];
      };
    };
  };
  config = {
    languages.java = {
      enable = true;
      maven.enable = true;
      maven.package = pkgs.maven.override {
        jdk_headless = cfg.jdk.package;
      };
    };
    packages = [
      cfg.mvn2nix.package
    ];
  };
}
