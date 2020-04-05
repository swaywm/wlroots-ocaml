open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

module Manager = struct
  type t = Types.Data_device_manager.t ptr
  include Ptr

  let create = Bindings.wlr_data_device_manager_create
end
