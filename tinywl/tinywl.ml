open Wlroots

type view = {
  surface : Xdg_surface.t;
  listener: Wl.Listener.t;
  mutable mapped: bool;
}

type tinywl_output = {
  output : Output.t;

  frame : Wl.Listener.t;
}

type tinywl_server = {
  display : Wl.Display.t;
  backend : Backend.t;
  renderer : Renderer.t;
  output_layout : Output_layout.t;
  seat : Seat.t;
  cursor : Cursor.t;
  mutable outputs : tinywl_output list;
  mutable views : view list;
  mutable keyboards : Keyboard.t list;

  new_output : Wl.Listener.t;
}

type cursor_mode = Passthrough
                 | Move
                 | Resize of Unsigned.uint32

let output_frame _st _ _ =
  failwith "todo"

let server_new_output st _ output =
  let output_ok =
    match Output.preferred_mode output with
    | Some mode ->
      Output.set_mode output mode;
      Output.enable output true;
      Output.commit output
    | None -> true
  in
  if output_ok then begin
    let o = { output; frame = Wl.Listener.create () } in
    Wl.Signal.add (Output.signal_frame output) o.frame (output_frame st);
    st.outputs <- o :: st.outputs;

    Output_layout.add_auto st.output_layout output;
    Output.create_global output;
  end

let begin_interactive _st (_view: view) (_mode: cursor_mode) =
  print_endline "Begin interactive"

let focus_view st view _listener surf =
  let keyboard_state = Seat.keyboard_state st.seat in
  let prev_surface = Seat.Keyboard_state.focused_surface keyboard_state in
  let to_deactivate =
    Option.bind prev_surface (fun prev ->
        if prev == Xdg_surface.surface surf
        then None
        else Xdg_surface.from_surface prev
      )
  in
  let discard _ = () in
  Option.iter (fun s -> discard (Xdg_surface.toplevel_set_activated s false))
    to_deactivate;
  let keyboard = Seat.Keyboard_state.keyboard keyboard_state in
  st.views <- view :: List.filter ((!=) view) st.views;
  discard (Xdg_surface.toplevel_set_activated surf true);
  Seat.keyboard_notify_enter
    st.seat
    (Xdg_surface.surface surf)
    (Keyboard.keycodes keyboard)
    (Keyboard.num_keycodes keyboard)
    (Keyboard.modifiers keyboard)

let server_new_xdg_surface st _listener (surf : Xdg_surface.t) =
  begin match Xdg_surface.role surf with
    | None -> print_endline "Got None"
    | TopLevel -> print_endline "Got TopLevel"
    | Popup -> print_endline "Got Popup"
  end;

  let view_listener = Wl.Listener.create () in

  let view = {
    surface = surf;
    listener = view_listener;
    mapped = false;
  } in

  st.views <- view :: st.views;

  (* We want to add the signal handlers for the surface events using Wl.Signal.add *)
  Wl.Signal.add (Xdg_surface.Events.destroy surf) view_listener
    (fun _ _ -> st.views <- List.filter (fun item -> not (item == view)) st.views;);

  (* Might need to make mapped true in this guy *)
  Wl.Signal.add (Xdg_surface.Events.map surf) view_listener
    (focus_view st view) ;
  Wl.Signal.add (Xdg_surface.Events.unmap surf) view_listener
    (fun _ _ -> view.mapped <- false;);
    (* Wl.Signal.add (Xdg_shell.signal_new_surface xdg_shell) new_xdg_surface *)
    (* (server_new_xdg_surface st); *)

  (* cotd *)
  let toplevel = Xdg_surface.toplevel surf in

  Wl.Signal.add (Xdg_toplevel.Events.request_move toplevel) view_listener
    (fun _ _ -> begin_interactive st view Move);
  Wl.Signal.add (Xdg_toplevel.Events.request_resize toplevel) view_listener
    (* FIXME: Need to actually get the edges from the event to pass with Resize *)
    (fun _ _ -> begin_interactive st view (Resize (Unsigned.UInt32.of_int 0)));
  ()

let server_cursor_motion _st _ _ =
  failwith "server_cursor_motion"

let server_cursor_motion_absolute _st _ _ =
  failwith "server_cursor_motion_absolute"

let server_cursor_button _st _ _ =
  failwith "server_cursor_button"

let server_cursor_axis _st _ _ =
  failwith "server_cursor_axis"

let server_cursor_frame _st _ _ =
  failwith "server_cursor_frame"

let server_new_keyboard _st (_keyboard: Keyboard.t) =
  failwith "server_new_keyboard"

let server_new_pointer st (pointer: Input_device.t) =
  Cursor.attach_input_device st.cursor pointer

let server_new_input st _ (device: Input_device.t) =
  begin match Input_device.typ device with
  | Input_device.Keyboard keyboard ->
    server_new_keyboard st keyboard
  | Input_device.Pointer _ ->
    server_new_pointer st device
  | _ ->
    ()
  end;

  let caps =
    Wl.Seat_capability.Pointer ::
    (match st.keyboards with
     | [] -> []
     | _ -> [Wl.Seat_capability.Keyboard])
  in
  Seat.set_capabilities st.seat caps

let server_request_cursor st _ (ev: Seat.Pointer_request_set_cursor_event.t) =
  let module E = Seat.Pointer_request_set_cursor_event in
  let focused_client =
    st.seat |> Seat.pointer_state |> Seat.Pointer_state.focused_client in

  if Seat.Client.equal focused_client (E.seat_client ev) then (
    Cursor.set_surface st.cursor (E.surface ev) (E.hotspot_x ev) (E.hotspot_y ev)
  )

let () =
  Log.(init Debug);
  let startup_cmd =
    match Array.to_list Sys.argv |> List.tl with
    | ["-s"; cmd] -> Some cmd
    | [] -> None
    | _ ->
      Printf.printf "Usage: %s [-s startup command]\n" Sys.argv.(0);
      exit 0
  in

  let display = Wl.Display.create () in
  let backend = Backend.autocreate display in
  let renderer = Backend.get_renderer backend in
  assert (Renderer.init_wl_display renderer display);

  let _compositor = Compositor.create display renderer in
  let _data_manager = Data_device.Manager.create display in

  let output_layout = Output_layout.create () in

  let xdg_shell = Xdg_shell.create display in

  let cursor = Cursor.create () in
  Cursor.attach_output_layout cursor output_layout;

  let cursor_mgr = Xcursor_manager.create None 24 in
  ignore (Xcursor_manager.load cursor_mgr 1. : int);

  let seat = Seat.create display "seat0" in

  let new_output = Wl.Listener.create () in
  let new_xdg_surface = Wl.Listener.create () in
  let cursor_motion = Wl.Listener.create () in
  let cursor_motion_absolute = Wl.Listener.create () in
  let cursor_button = Wl.Listener.create () in
  let cursor_axis = Wl.Listener.create () in
  let cursor_frame = Wl.Listener.create () in
  let new_input = Wl.Listener.create () in
  let request_cursor = Wl.Listener.create () in
  let st = { display; backend; renderer; output_layout; new_output; seat;
             cursor; outputs = []; views = []; keyboards = [] } in

  Wl.Signal.add (Backend.signal_new_output backend) new_output
    (server_new_output st);
  Wl.Signal.add (Xdg_shell.signal_new_surface xdg_shell) new_xdg_surface
    (server_new_xdg_surface st);

  Wl.Signal.add (Cursor.signal_motion cursor) cursor_motion
    (server_cursor_motion st);
  Wl.Signal.add (Cursor.signal_motion_absolute cursor) cursor_motion_absolute
    (server_cursor_motion_absolute st);
  Wl.Signal.add (Cursor.signal_button cursor) cursor_button
    (server_cursor_button st);
  Wl.Signal.add (Cursor.signal_axis cursor) cursor_axis
    (server_cursor_axis st);
  Wl.Signal.add (Cursor.signal_frame cursor) cursor_frame
    (server_cursor_frame st);

  Wl.Signal.add (Backend.signal_new_input backend) new_input
    (server_new_input st);
  Wl.Signal.add (Seat.signal_request_set_cursor seat) request_cursor
    (server_request_cursor st);

  let socket = match Wl.Display.add_socket_auto display with
    | None -> Backend.destroy backend; exit 1
    | Some socket -> socket
  in

  if not (Backend.start backend) then (
    Backend.destroy backend;
    Wl.Display.destroy display;
    exit 1
  );

  Unix.putenv "WAYLAND_DISPLAY" socket;
  begin match startup_cmd with
    | Some cmd ->
      if Unix.fork () = 0 then Unix.execv "/bin/sh" [|"/bin/sh"; "-c"; cmd|]
    | None -> ()
  end;

  Printf.printf "Running wayland compositor on WAYLAND_DISPLAY=%s" socket;
  Wl.Display.run display;

  Wl.Display.destroy_clients display;
  Wl.Display.destroy display;

  ()
