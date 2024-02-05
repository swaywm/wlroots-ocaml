open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Backend.t ptr
include Ptr

let autocreate dpy =
  (* TODO get returned Session *)
  let b = Bindings.wlr_backend_autocreate dpy Ctypes.(coerce (ptr void) (ptr (ptr Types.Session.t)) null) in
  if is_null b then failwith "Failed to create backend";
  b

let start = Bindings.wlr_backend_start
let destroy = Bindings.wlr_backend_destroy

let renderer_autocreate = Bindings.wlr_renderer_autocreate

let signal_new_output (backend: t) : Types.Output.t ptr Wl.Signal.t = {
  c = backend |-> Types.Backend.events_new_output;
  typ = ptr Types.Output.t;
}

let signal_new_input (backend: t) : Types.Input_device.t ptr Wl.Signal.t = {
  c = backend |-> Types.Backend.events_new_input;
  typ = ptr Types.Input_device.t;
}

let signal_destroy (backend: t) : t Wl.Signal.t = {
  c = backend |-> Types.Backend.events_destroy;
  typ = ptr Types.Backend.t;
}
