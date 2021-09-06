let pkgs = import ./pin.nix { }; in { resolve = pkgs.opam2nix-resolve; }
