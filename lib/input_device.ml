open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = {
  raw : Types.Input_device.t ptr;
  destroy : Wl.Listener.t;
}

let compare x1 x2 = Ptr.compare x1.raw x2.raw
let equal = mk_equal compare
let hash x = Ptr.hash x.raw

type Event.event +=
  | Destroy of t

let signal_destroy (input_raw : Types.Input_device.t ptr)
  : Types.Input_device.t ptr Wl.Signal.t = {
  c = input_raw |-> Types.Input_device.events_destroy;
  typ = ptr Types.Input_device.t;
}

(* This creates a new [t] structure from a raw pointer. It must be only called
   at most once for each different raw pointer *)
let create (raw: Types.Input_device.t ptr) (handler: Event.handler): t =
  let destroy = Wl.Listener.create () in
  let input = { raw; destroy } in
  Wl.Signal.subscribe (signal_destroy raw) destroy (fun _ ->
    handler (Destroy input)
  );
  input

type typ =
  | Keyboard of Keyboard.t
  | Pointer of Pointer.t
  | Touch of Touch.t
  | Tablet of Tablet_tool.t (* FIXME? *)
  | Tablet_pad of Tablet_pad.t

let typ (input: t): typ =
  match input.raw |->> Types.Input_device.typ with
  | Types.Input_device.Type.Keyboard ->
    Keyboard (input.raw |->> Types.Input_device.keyboard)
  | Types.Input_device.Type.Pointer ->
    Pointer (input.raw |->> Types.Input_device.pointer)
  | Types.Input_device.Type.Touch ->
    Touch (input.raw |->> Types.Input_device.touch)
  | Types.Input_device.Type.Tablet_tool ->
    Tablet (input.raw |->> Types.Input_device.tablet)
  | Types.Input_device.Type.Tablet_pad ->
    Tablet_pad (input.raw |->> Types.Input_device.tablet_pad)

let vendor (input: t): int =
  input.raw |->> Types.Input_device.vendor

let product (input: t): int =
  input.raw |->> Types.Input_device.product

let name (input: t): string =
  input.raw |->> Types.Input_device.name
