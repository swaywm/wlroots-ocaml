open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Keyboard_modifiers.t ptr
include Ptr

let has_alt modifiers =
  Ctypes.coerce int64_t bool
    (Signed.Int64.logand
       (Ctypes.coerce uint32_t int64_t modifiers)
       Types.Keyboard_modifier._WLR_MODIFIER_ALT)
