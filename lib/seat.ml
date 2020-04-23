open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Seat.t ptr
include Ptr

module Pointer_request_set_cursor_event = struct
  type t = Types.Seat_pointer_request_set_cursor_event.t ptr
  let t = ptr Types.Seat_pointer_request_set_cursor_event.t
  include Ptr
end


let create = Bindings.wlr_seat_create

let signal_request_set_cursor (seat: t) : _ Wl.Signal.t = {
  c = seat |-> Types.Seat.events_request_set_cursor;
  typ = Pointer_request_set_cursor_event.t
}

let set_capabilities seat caps =
  Bindings.wlr_seat_set_capabilities
    seat (coerce Wl.Seat_capability.t uint64_t caps)
