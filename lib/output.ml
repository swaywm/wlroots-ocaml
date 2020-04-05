open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = Types.Output.t ptr
include Ptr

let signal_frame (output : t) : t Wl.Signal.t = {
  c = output |-> Types.Output.events_frame;
  typ = ptr Types.Output.t;
}

let signal_destroy (output : t) : t Wl.Signal.t = {
  c = output |-> Types.Output.events_destroy;
  typ = ptr Types.Output.t;
}

module Mode = struct
  type t = Types.Output_mode.t ptr
  include Ptr

  let width = getfield Types.Output_mode.width
  let height = getfield Types.Output_mode.height
  let refresh = getfield Types.Output_mode.refresh
  let preferred = getfield Types.Output_mode.preferred
end

let modes (output : t) : Mode.t list =
  (output |-> Types.Output.modes)
  |> Bindings.ocaml_of_wl_list
    (container_of Types.Output_mode.t Types.Output_mode.link)

let transform_matrix (output : t) : Matrix.t =
  CArray.start (output |->> Types.Output.transform_matrix)

let set_mode (output : t) (mode : Mode.t): unit =
  Bindings.wlr_output_set_mode output mode

let best_mode (output : t): Mode.t option =
  match modes output with
  | [] -> None
  | mode :: _ -> Some mode

let set_best_mode (output : t) =
  match best_mode output with
  | None -> ()
  | Some mode ->
    (* TODO log the mode set *)
    set_mode output mode |> ignore

let create_global (output : t) =
  Bindings.wlr_output_create_global output

let attach_render (output : t): bool =
  (* TODO: handle buffer age *)
  Bindings.wlr_output_attach_render output (coerce (ptr void) (ptr int) null)

let commit (output : t): bool =
  Bindings.wlr_output_commit output

module Layout = struct
  type t = Types.Output_layout.t ptr
  include Ptr

  let create = Bindings.wlr_output_layout_create
end
