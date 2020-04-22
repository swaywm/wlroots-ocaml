open Wlroots
open! Tgl3

type state = {
  last_frame : Mtime.t;
  mutable dec : int;
  color : float array; (* of size 3 *)

  new_output : Wl.Listener.t;
  new_input : Wl.Listener.t;
}

type output = {
  frame : Wl.Listener.t;
  destroy : Wl.Listener.t;
}

type keyboard = {
  device : Keyboard.t;
  key : Wl.Listener.t;
  destroy : Wl.Listener.t;
}

let state = ref {
  last_frame = Mtime_clock.now (); dec = 0; color = [|1.; 0.; 0.|];
  new_output = Wl.Listener.create ();
  new_input = Wl.Listener.create ();
}

let fail msg () =
  print_endline msg; exit 1

let output_frame_notify _ output =
  let st = !state in
  let now = Mtime_clock.now () in
  let ms = Mtime.span st.last_frame now |> Mtime.Span.to_ms in
  let inc = (st.dec + 1) mod 3 in
  let dcol = ms /. 2000. in

  st.color.(inc) <- st.color.(inc) +. dcol;
  st.color.(st.dec) <- st.color.(st.dec) -. dcol;
  if st.color.(st.dec) < 0. then (
    st.color.(inc) <- 1.;
    st.color.(st.dec) <- 0.;
    st.dec <- inc
  );

  ignore (Output.attach_render output : bool);
  Gl.clear_color st.color.(0) st.color.(1) st.color.(2) 1.;
  Gl.clear Gl.color_buffer_bit;
  ignore (Output.commit output : bool);
  state := { st with last_frame = Mtime_clock.now () }

let output_remove_notify output_handles _ _output =
  print_endline "Output removed";
  Wl.Listener.detach output_handles.frame;
  Wl.Listener.detach output_handles.destroy

let new_output_notify _ output =
  let o = { frame = Wl.Listener.create ();
            destroy = Wl.Listener.create (); } in
  begin match Output.modes output with
    | mode :: _ -> Output.set_mode output mode
    | [] -> ()
  end;
  Wl.Signal.add (Output.signal_frame output) o.frame output_frame_notify;
  Wl.Signal.add (Output.signal_destroy output) o.destroy
    (output_remove_notify o);
  ignore (Output.commit output : bool);
  ()

let keyboard_destroy_notify keyboard_handles _ _input =
  print_endline "keyboard removed";
  Wl.Listener.detach keyboard_handles.key;
  Wl.Listener.detach keyboard_handles.destroy

let keyboard_key_notify display keyboard _ event =
  let keycode = Keyboard.Event_key.keycode event + 8 in
  let syms = Xkbcommon.State.key_get_syms (Keyboard.xkb_state keyboard)
      keycode in
  if List.mem Xkbcommon.Keysyms._Escape syms then
    Wl.Display.terminate display;
  ()

let new_input_notify display _ (input: Input_device.t) =
  match Input_device.typ input with
  | Input_device.Keyboard keyboard ->
    let k = {
      device = keyboard;
      key = Wl.Listener.create ();
      destroy = Wl.Listener.create ();
    } in
    Wl.Signal.add (Input_device.signal_destroy input) k.destroy
      (keyboard_destroy_notify k);
    Wl.Signal.add (Keyboard.signal_key keyboard) k.key
      (keyboard_key_notify display keyboard);
    let rules = Xkbcommon.Rule_names.{
      rules = Sys.getenv_opt "XKB_DEFAULT_RULES";
      model = Sys.getenv_opt "XKB_DEFAULT_MODEL";
      layout = Sys.getenv_opt "XKB_DEFAULT_LAYOUT";
      variant = Sys.getenv_opt "XKB_DEFAULT_VARIANT";
      options = Sys.getenv_opt "XKB_DEFAULT_OPTIONS";
    } in
    Xkbcommon.Context.with_new (fun context ->
      Xkbcommon.Keymap.with_new_from_names context rules (fun keymap ->
        ignore (Keyboard.set_keymap keyboard keymap : bool)
      ) ~fail:(fail "Failed to create XKB keymap")
    ) ~fail:(fail "Failed to create XKB context")
  | _ ->
    ()

let () =
  Log.(init Debug);
  let display = Wl.Display.create () in
  let backend = Backend.autocreate display in

  Wl.Signal.add (Backend.signal_new_output backend) (!state).new_output
    new_output_notify;
  Wl.Signal.add (Backend.signal_new_input backend) (!state).new_input
    (new_input_notify display);

  if not (Backend.start backend) then (
    Backend.destroy backend;
    failwith "Unable to start backend";
  );

  Wl.Display.run display;
  Wl.Display.destroy display;
  ()
