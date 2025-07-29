with import <nixpkgs> { };
mkShell {
  nativeBuildInputs = [
    jq
    curlMinimal
    zip
  ];
}
