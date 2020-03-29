open Ctypes
open! Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

include Types.Log

(* TODO: callback *)
let init importance =
  Bindings.wlr_log_init importance null

(* TODO logging functions *)
