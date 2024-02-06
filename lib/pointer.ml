open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Pointer.t ptr
include Ptr

module Event_motion = struct
  type t = Types.Event_pointer_motion.t ptr
  let t = ptr Types.Event_pointer_motion.t
  include Ptr
end

module Event_motion_absolute = struct
  type t = Types.Event_pointer_motion_absolute.t ptr
  let t = ptr Types.Event_pointer_motion_absolute.t
  include Ptr
end

module Event_button = struct
  type t = Types.Event_pointer_button.t ptr
  let t = ptr Types.Event_pointer_button.t
  include Ptr
end

module Event_axis = struct
  type t = Types.Event_pointer_axis.t ptr
  let t = ptr Types.Event_pointer_axis.t
  include Ptr
end

let from_input_device = Bindings.wlr_pointer_from_input_device
