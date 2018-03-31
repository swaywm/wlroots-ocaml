open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = float ptr
include Ptr

let project_box box transform ~rotation projection =
  let mat = CArray.make float 16 in
  let mat_p = CArray.start mat in
  Bindings.wlr_matrix_project_box
    mat_p (Box.to_c box) transform rotation
    projection;
  mat_p
