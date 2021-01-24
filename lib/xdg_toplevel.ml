open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Xdg_toplevel.t ptr
let t = ptr Types.Xdg_toplevel.t

include Ptr

module Events = struct
  let request_move (toplevel : t) : t Wl.Signal.t = {
    c = toplevel |-> Types.Xdg_toplevel.events_request_move;
    typ = t;
  }

  let request_resize (toplevel : t) : t Wl.Signal.t = {
    c = toplevel |-> Types.Xdg_toplevel.events_request_resize;
    typ = t;
  }
end
