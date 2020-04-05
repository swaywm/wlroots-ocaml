open Ctypes
open! Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Compositor.t ptr
include Ptr

let create dpy renderer =
  Bindings.wlr_compositor_create dpy renderer
