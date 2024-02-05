open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Touch.t ptr
include Ptr

let from_input_device = Bindings.wlr_touch_from_input_device
