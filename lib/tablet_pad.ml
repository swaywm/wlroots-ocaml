open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Tablet_pad.t ptr
include Ptr

let from_input_device = Bindings.wlr_tablet_pad_from_input_device
