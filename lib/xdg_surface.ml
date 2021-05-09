open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Xdg_surface.t ptr
let t = ptr Types.Xdg_surface.t

type role = Types.Xdg_surface_role.role

include Ptr

let role (surface : t) : role =
  surface |->> Types.Xdg_surface.role
let surface (surface : t) : Surface.t =
  surface |-> Types.Xdg_surface.surface
let toplevel (surface : t) : Xdg_toplevel.t =
  surface |-> Types.Xdg_surface.toplevel

let from_surface (surface : Surface.t) : t option =
  (* This is not exactly a verbatim binding but it is safer *)
  (* Worth it? *)
  if Bindings.wlr_surface_is_xdg_surface surface
  then
    (* assert is called so this might blow up *)
    Some (Bindings.wlr_xdg_surface_from_wlr_surface surface)
  else None

let get_geometry (surface : t) =
  let box = make Types.Box.t in
  let () = Bindings.wlr_xdg_surface_get_geometry surface (addr box) in
  Box.of_c (addr box)

let toplevel_set_activated =
  Bindings.wlr_xdg_toplevel_set_activated

let toplevel_set_size =
  Bindings.wlr_xdg_toplevel_set_size

module Events = struct
  let destroy (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_destroy;
    typ = t;
  }

  let ping_timeout (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_ping_timeout;
    typ = t;
  }

  let new_popup (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_new_popup;
    typ = t;
  }

  let map (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_map;
    typ = t;
  }

  let unmap (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_unmap;
    typ = t;
  }

  let configure (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_configure;
    typ = t;
  }

  let ack_configure (surface : t) : t Wl.Signal.t = {
    c = surface |-> Types.Xdg_surface.events_ack_configure;
    typ = t;
  }
end
