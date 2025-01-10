{
  pkgs,
  config,
  lib,
  ...
}:
# users.extraUsers.myusername= {
#   subUidRanges = [{ startUid = 100000; count = 65536; }];
#   subGidRanges = [{ startGid = 100000; count = 65536; }];
# };
let
  cfg = config.package.podman;
  inherit (lib) types mkOption;

  podmanSetupScript =
    let
      policyConf = pkgs.writeText "policy.conf" ''
        {"default":[{"type":"insecureAcceptAnything"}],"transports":{"docker-daemon":{"":[{"type":"insecureAcceptAnything"}]}}}
      '';
      registriesConf = pkgs.writeText "registries.conf" ''
        [registries]
        [registries.block]
        registries = []
        [registries.insecure]
        registries = []
        [registries.search]
        registries = ["docker.io", "quay.io"]
      '';
      storageConf = pkgs.writeText "storage.conf" ''
        [storage]
        driver = "overlay"
      '';
      containersConf = pkgs.writeText "containers.conf" ''
        [engine]
        helper_binaries_dir = ["${pkgs.podman}/libexec/podman","${pkgs.crun}/bin","${pkgs.fuse-overlayfs}/bin"]
        runtime = "crun"
        [containers]
        pids_limit = 0
      '';
    in
    pkgs.writeScript "podman-setup" ''
      #!${pkgs.runtimeShell}
      if ! test -f ~/.config/containers/policy.json; then
        install -Dm755 ${policyConf} ~/.config/containers/policy.json
      fi
      if ! test -f ~/.config/containers/registries.conf; then
        install -Dm755 ${registriesConf} ~/.config/containers/registries.conf
      fi
      if ! test -f ~/.config/containers/storage.conf; then
        install -Dm755 ${storageConf} ~/.config/containers/storage.conf
      fi
      install -Dm755 ${containersConf} ~/.config/containers/containers.conf
      if command -v "systemctl" >/dev/null 2>&1; then
        mkdir -p ~/.config/systemd/user
        ln -sf ${pkgs.podman}/share/systemd/user/podman.socket ~/.config/systemd/user/podman.socket
        ln -sf ${pkgs.podman}/share/systemd/user/podman.service ~/.config/systemd/user/podman.service
        systemctl --user start podman.socket
      fi
    '';
in
{
  options.package.podman = { };
  config = {
    packages = [
      pkgs.podman
      pkgs.crun
      pkgs.conmon
      pkgs.skopeo
      pkgs.slirp4netns
      pkgs.fuse-overlayfs
    ];
    enterShell = ''
      ${podmanSetupScript}
    '';
    devcontainer.settings = {
      runArgs = [
        "--userns=keep-id:uid=1000,gid=1000"
      ];
      containerUser = "vscode";
      updateRemoteUserUID = true;
      containerEnv = {
        HOME = "/home/vscode";
      };
    };
  };
}
