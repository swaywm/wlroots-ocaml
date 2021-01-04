open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

module Xdg_surface = struct
  type t = Types.Xdg_surface.t ptr
  let t = ptr Types.Xdg_surface.t

  type role = Types.Xdg_surface_role.role

  include Ptr

  let role (surface : t) : role =
    surface |->> Types.Xdg_surface.role
  let surface (surface : t) : Surface.t =
    surface |-> Types.Xdg_surface.surface

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
end

type t = Types.Xdg_shell.t ptr
let t = ptr Types.Xdg_shell.t
include Ptr

let create = Bindings.wlr_xdg_shell_create

let signal_new_surface (shell : t) : Xdg_surface.t Wl.Signal.t = {
  c = shell |-> Types.Xdg_shell.events_new_surface;
  typ = Xdg_surface.t;
}
