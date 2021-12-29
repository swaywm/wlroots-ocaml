open Ctypes
module Types = Wlroots_ffi_f.Ffi.Types

type t = None | Top | Bottom | Left | Right
module Size = Unsigned.UInt32
let size = uint32_t
open Types.Edges
let desc = [
    None, _WLR_EDGE_NONE;
    Top, _WLR_EDGE_TOP;
    Bottom, _WLR_EDGE_BOTTOM;
    Right, _WLR_EDGE_RIGHT;
    Left, _WLR_EDGE_LEFT;
]
