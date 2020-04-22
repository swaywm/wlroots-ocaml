# wlroots-ocaml - OCaml bindings to [wlroots](https://github.com/swaywm/wlroots)

**NOTE**: This is an early, very work in progress set of bindings. There are
guaranteed to be bugs and rough edges along with lots of missing documentation.
These bindings are an occasional nights and weekends project done for fun.

The goal of the library is to provide "thin bindings" that follow the C API as
closely as possible (while being type-safe). Only a fraction of the C API is
currently covered, but adding new functions and structures to the bindings
should be mostly a mechanical process.

## Building

To compile wlroots-ocaml, you need the following (assuming you have
[opam](https://opam.ocaml.org)):

- wlroots (the C library), from the git master branch. wlroots-ocaml uses
  pkg-config to know where the library and headers are.
- OCaml bindings to xkbcommon: `opam pin add xkbcommon https://github.com/Armael/ocaml-xkbcommon.git`

Then, to directly install wlroots-ocaml with opam, use:

```
  opam pin add wlroots https://github.com/swaywm/wlroots-ocaml.git
```

If you want to hack on the library instead, clone the repository, and install
its dependencies with:

```
opam install -t --deps-only .
```

Then, you can use `make` to build the library, and `make examples` to build the
example programs.
