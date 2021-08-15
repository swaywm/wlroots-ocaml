{ wlroots-version ? "0.12" }:
let pkgs = import ./pin.nix;
in pkgs.mkShell {
  name = "wlroots-ocaml-shell";
  inputsFrom = [ pkgs.ocamlPackages.wlroots ];
  nativeBuildInputs = [ pkgs.nixfmt ];
  shellHook = ''
    export NIX_PATH=nixpkgs=${pkgs.path}
  '';
}
