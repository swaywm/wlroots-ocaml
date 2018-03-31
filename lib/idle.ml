open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t  = unit ptr
include Ptr

let create = Bindings.wlr_idle_create
let destroy = Bindings.wlr_idle_destroy
