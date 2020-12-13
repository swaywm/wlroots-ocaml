open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

module Surface = struct
  type t = Types.Xdg_surface.t ptr
  let t = ptr Types.Xdg_surface.t

  type role_t = Types.Xdg_surface_role.role ptr
  let role_t = ptr Types.Xdg_surface_role.t

  include Ptr

  let role (surface : t) = surface |-> Types.Xdg_surface.role
end

type t = Types.Xdg_shell.t ptr
let t = ptr Types.Xdg_shell.t
include Ptr

let create = Bindings.wlr_xdg_shell_create

let signal_new_surface (shell : t) : Surface.t Wl.Signal.t = {
  c = shell |-> Types.Xdg_shell.events_new_surface;
  typ = Surface.t;
}

