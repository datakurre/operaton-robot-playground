{
  buildMavenRepositoryFromLockFile,
  jdk,
  maven,
  stdenv,
}:
let
  mavenRepository = buildMavenRepositoryFromLockFile {
    file = ./mvn2nix.lock;
  };
in
stdenv.mkDerivation rec {
  pname = "my-fixture";
  version = "1.0.0-SNAPSHOT";
  name = "${pname}-${version}.jar";
  src = ./.;

  buildInputs = [
    jdk
    maven
  ];
  buildPhase = ''
    find . -print0|xargs -0 touch
    echo "mvn package --offline -Dmaven.repo.local=${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository}
  '';

  installPhase = ''
    mv target/${name} $out
    jar i $out
  '';
}
