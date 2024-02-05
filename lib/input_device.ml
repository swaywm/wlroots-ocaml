open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Input_device.t ptr
include Ptr

let signal_destroy (input : t) : t Wl.Signal.t = {
  c = input |-> Types.Input_device.events_destroy;
  typ = ptr Types.Input_device.t;
}

type typ =
  | Keyboard of Keyboard.t
  | Pointer of Pointer.t
  | Touch of Touch.t
  | Tablet of Tablet_tool.t (* FIXME? *)
  | Tablet_pad of Tablet_pad.t

let typ (input: t): typ =
  match input |->> Types.Input_device.typ with
  | Types.Input_device.Type.Keyboard ->
    Keyboard (Keyboard.from_input_device input)
  | Types.Input_device.Type.Pointer ->
    Pointer (Pointer.from_input_device input)
  | Types.Input_device.Type.Touch ->
    Touch (Touch.from_input_device input)
  | Types.Input_device.Type.Tablet_tool ->
    Tablet (Tablet_tool.from_input_device input)
  | Types.Input_device.Type.Tablet_pad ->
    Tablet_pad (Tablet_pad.from_input_device input)

let vendor (input: t): int =
  input |->> Types.Input_device.vendor

let product (input: t): int =
  input |->> Types.Input_device.product

let name (input: t): string =
  input |->> Types.Input_device.name
