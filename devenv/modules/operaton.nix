{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.package.operaton;
  inherit (lib) types mkOption;
in
{
  imports = [ ./java.nix ];
  options.package.operaton = {
    path = mkOption {
      type = types.path;
    };
  };
  config = {
    languages.java.jdk.package = pkgs.jdk17;
    outputs.operaton.jar = pkgs.callPackage cfg.path {
      jdk = config.languages.java.jdk.package;
      maven = config.languages.java.maven.package;
      inherit (config.languages.java.mvn2nix.lib)
        buildMavenRepositoryFromLockFile
        ;
    };
    processes.operaton.exec = "java -jar ${config.outputs.operaton.jar}";
  };
}
