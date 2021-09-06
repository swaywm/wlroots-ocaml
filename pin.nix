{ wlroots-version ? "0.12" }:
let
  nix-rev = "3ab8ce12c2db31268f579c11727d9c63cfee2eee"; # 2021-08-15
  nix-src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${nix-rev}.tar.gz";
    sha256 = "13fx0yb95gxyk0jyvgrxv2yp4fj54g7nzrlvjfc8slx9ccqd2v86";
  };
in import nix-src {
  overlays = [
    (_: super: { ocamlPackages = super.ocaml-ng.ocamlPackages_4_08; })
    (_: super: {
      wlroots_0_13 = super.callPackage (import ./wlroots-13.nix) { };
    })
    (self: super:
      let
        opam2nix = import (super.fetchFromGitHub {
          owner = "timbertson";
          repo = "opam2nix";
          rev = "c9192288543be9ea17ba8a568e41258082016768";
          sha256 = "1ii2v08r7xkqf35ra0niqkzyqwx45vi7bzm7c0kcq83sl46qirlp";
        }) { pkgs = self; };
        xkbcommon = self.fetchFromGitHub {
          owner = "Armael";
          repo = "ocaml-xkbcommon";
          rev = "af0cd8c938938db3e67b65ac13b6444102756ba0";
          sha256 = "0zh80aczdn821xkwjn8m74mjcqb6f1hj0qfh1kxrz2z9h5as2r8k";
        };
        opam2nix-args = {
          inherit (super.ocamlPackages) ocaml;
          selection = ./opam-selection.nix;
          src = {
            inherit xkbcommon;
            wlroots = ./.;
          };
          override = { pkgs }: {
            xkbcommon = super:
              super.overrideAttrs (attrs: {
                nativeBuildInputs = [ pkgs.pkg-config ];
                buildInputs = [ self.libxkbcommon ];
              });
            tgls = super:
              super.overrideAttrs (attrs: {
                nativeBuildInputs = [ self.pkg-config ];
                buildInputs = [ self.libGL ];
              });
            wlroots = super:
              super.overrideAttrs (attrs: {
                nativeBuildInputs =
                  [ pkgs.pkg-config pkgs.ocamlPackages.dune-configurator ];
                buildInputs = [
                  pkgs.libGL
                  pkgs.libudev # Should libudev be upstreamed as an input for wlroots?
                  pkgs.libxkbcommon
                  pkgs.mesa
                  pkgs.pixman
                  pkgs.wayland-protocols
                  pkgs.wayland
                  (if wlroots-version == "0.12" then
                    pkgs.wlroots_0_12
                  else if wlroots-version == "0.13" then
                    pkgs.wlroots_0_13
                  else if wlroots-version == "0.14" then
                    pkgs.wlroots
                  else
                    throw ''
                      wlroots-version must be one of 0.12, 0.13 or 0.14.  Got ${wlroots-version}
                    '')
                ];
              });
          };
        };
        opam-selection = opam2nix.build opam2nix-args;
      in {
        inherit opam2nix opam-selection;
        opam2nix-resolve = opam2nix.resolve opam2nix-args [
          "${xkbcommon}/xkbcommon.opam"
          "wlroots.opam"
        ];
        ocamlPackages = super.ocamlPackages // {
          inherit (opam-selection) tgls xkbcommon wlroots;
        };
      })
  ];
}
