open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Renderer.t ptr
include Ptr

let begin_ (renderer : t) (output : Output.t) =
  Bindings.wlr_renderer_begin renderer output.raw

let end_ (renderer : t) =
  Bindings.wlr_renderer_end renderer

let clear (renderer : t) ((c1,c2,c3,c4) : float * float * float * float) =
  let color_arr = CArray.of_list float [c1;c2;c3;c4] in
  Bindings.wlr_renderer_clear renderer (CArray.start color_arr)

let render_with_matrix renderer texture mat ~alpha =
  Bindings.wlr_render_with_matrix renderer texture mat alpha
