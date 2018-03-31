open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = { x : int; y : int; width : int; height : int }
include Poly

let of_c (c_box : Types.Box.t ptr) =
  { x = c_box |->> Types.Box.x;
    y = c_box |->> Types.Box.y;
    width = c_box |->> Types.Box.width;
    height = c_box |->> Types.Box.height; }

let to_c { x; y; width; height } : Types.Box.t ptr =
  let c_box = make Types.Box.t in
  setf c_box Types.Box.x x;
  setf c_box Types.Box.y y;
  setf c_box Types.Box.width width;
  setf c_box Types.Box.height height;
  addr c_box
