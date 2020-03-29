open Ctypes
open! Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

type t = {
  compositor : Types.Compositor.t ptr;
  backend : Backend.t;
  display : Wl.Display.t;
  event_loop : Wl.Event_loop.t;
  renderer : Renderer.t;
  socket : string;
  shm_fd : int;
  new_output : Wl.Listener.t option;
  new_input : Wl.Listener.t option;
  mutable handler : Event.handler;
}

type Event.event +=
  | New_output of Output.t
  | New_input of Input_device.t

let destroy (c: t) =
  (* It seems that it is not needed to manually detach [c.new_output], as they
     get automatically cleaned up by the code below. *)
  Backend.destroy c.backend;
  Wl.Display.destroy c.display

let create
    ?(manage_outputs = true)
    ?(manage_inputs = true)
    ()
  =
  (* simple helper for the boolean flags *)
  let flag b f x = if b then Some (f x) else None in
  let display = Wl.Display.create () in
  let event_loop = Wl.Display.get_event_loop display in
  let backend = Backend.autocreate display in
  let shm_fd = Wl.Display.init_shm display in
  let renderer = Backend.get_renderer backend in (* ? *)
  let socket = Wl.Display.add_socket_auto display in
  let compositor = Bindings.wlr_compositor_create display renderer in
  let new_output = flag manage_outputs Wl.Listener.create () in
  let new_input = flag manage_inputs Wl.Listener.create () in

  let c =
    { compositor; backend; display; event_loop; renderer; socket; shm_fd;
      new_output; new_input; handler = Event.handler_dummy; }
  in
  begin match new_output with
    | Some listener ->
      Wl.Signal.subscribe (Backend.signal_new_output backend) listener
        (fun output_raw ->
           let output = Output.create output_raw c.handler in
           c.handler (New_output output))
    | None -> ()
  end;
  begin match new_input with
    | Some listener ->
      Wl.Signal.subscribe (Backend.signal_new_input backend) listener
        (fun input_raw ->
           let input_device = Input_device.create input_raw c.handler in
           c.handler (New_input input_device))
    | None -> ()
  end;
  c

let display c = c.display
let event_loop c = c.event_loop
let renderer c = c.renderer
