open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

module Device_manager = struct
  type t = unit ptr
  include Ptr

  let create = Bindings.wlr_primary_selection_device_manager_create
  let destroy = Bindings.wlr_primary_selection_device_manager_destroy
end
