# wlroots-ocaml

Work in progress OCaml bindings to [wlroots](https://github.com/swaywm/wlroots).

## Plans

- Extend the bindings coverage, following
  [SirCmpwn's series of blog-posts](https://drewdevault.com/2018/02/17/Writing-a-Wayland-compositor-1.html)
  and adding what is needed for implementing them in OCaml
  (see [ocaml-mcwayface](https://github.com/Armael/ocaml-mcwayface))
- Move the partial wayland bindings into their own repository (currently sitting
  in `Wlroots.Wl`), write the code generation part, and complete the wayland
  bindings (at least for the server part)
- Be able to implement a clone
  of [rootston](https://github.com/swaywm/wlroots/tree/master/rootston) in
  OCaml, as well as the other [wlroots examples](https://github.com/swaywm/wlroots/tree/master/examples)
