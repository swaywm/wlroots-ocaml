open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = {
  raw : Types.Output.t ptr;
  frame : Wl.Listener.t;
  destroy : Wl.Listener.t;
}

let compare o1 o2 = Ptr.compare o1.raw o2.raw
let equal = mk_equal compare
let hash o = Ptr.hash o.raw

type Event.event +=
  | Frame of t
  | Destroy of t

let signal_frame (output_raw : Types.Output.t ptr)
  : Types.Output.t ptr Wl.Signal.t = {
  c = output_raw |-> Types.Output.events_frame;
  typ = ptr Types.Output.t;
}

let signal_destroy (output_raw : Types.Output.t ptr)
  : Types.Output.t ptr Wl.Signal.t = {
  c = output_raw |-> Types.Output.events_destroy;
  typ = ptr Types.Output.t;
}

(* This creates a new [t] structure from a raw pointer. It must be only called
   at most once for each different raw pointer *)
let create (raw: Types.Output.t ptr) (handler: Event.handler): t =
  let frame = Wl.Listener.create () in
  let destroy = Wl.Listener.create () in
  let output = { raw; frame; destroy } in
  Wl.Signal.subscribe (signal_frame raw) frame (fun _ ->
    handler (Frame output)
  );
  Wl.Signal.subscribe (signal_destroy raw) destroy (fun _ ->
    handler (Destroy output);
    Wl.Listener.detach frame;
    Wl.Listener.detach destroy
  );
  output

module Mode = struct
  type t = Types.Output_mode.t ptr
  include Ptr

  let width = getfield Types.Output_mode.width
  let height = getfield Types.Output_mode.height
  let refresh = getfield Types.Output_mode.refresh
  let preferred = getfield Types.Output_mode.preferred
end

let modes (output : t) : Mode.t list =
  (output.raw |-> Types.Output.modes)
  |> Bindings.ocaml_of_wl_list
    (container_of Types.Output_mode.t Types.Output_mode.link)

let transform_matrix (output : t) : Matrix.t =
  CArray.start (output.raw |->> Types.Output.transform_matrix)

let set_mode (output : t) (mode : Mode.t): unit =
  Bindings.wlr_output_set_mode output.raw mode

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
  Bindings.wlr_output_create_global output.raw

let attach_render (output : t): bool =
  (* TODO: handle buffer age *)
  Bindings.wlr_output_attach_render output.raw (coerce (ptr void) (ptr int) null)

let commit (output : t): bool =
  Bindings.wlr_output_commit output.raw
