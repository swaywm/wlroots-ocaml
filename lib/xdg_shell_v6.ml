open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Xdg_shell_v6.t ptr
include Ptr

let create = Bindings.wlr_xdg_shell_v6_create
let destroy = Bindings.wlr_xdg_shell_v6_destroy
