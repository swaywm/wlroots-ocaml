open Wlroots

type view
  
type tinywl_output = {
  output : Output.t;

  frame : Wl.Listener.t;
}

type tinywl_server = {
  display : Wl.Display.t;
  backend : Backend.t;
  renderer : Renderer.t;
  output_layout : Output_layout.t;
  mutable outputs : tinywl_output list;
  mutable views : view list;
  mutable keyboards : Keyboard.t list;

  new_output : Wl.Listener.t;
}

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

let server_new_xdg_surface _st _ _ =
  failwith "todo"

let server_cursor_motion _st _ _ =
  failwith "todo"

let server_cursor_motion_absolute _st _ _ =
  failwith "todo"

let server_cursor_button _st _ _ =
  failwith "todo"

let server_cursor_axis _st _ _ =
  failwith "todo"

let server_cursor_frame _st _ _ =
  failwith "todo"

let server_new_input _st _ _ =
  failwith "todo"

let server_request_cursor _st _ _ =
  failwith "todo"

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
  let st = { display; backend; renderer; output_layout; new_output;
             outputs = []; views = []; keyboards = [] } in

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
