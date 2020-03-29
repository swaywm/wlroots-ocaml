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

let state = ref {
  last_frame = Mtime_clock.now (); dec = 0; color = [|1.; 0.; 0.|];
  new_output = Wl.Listener.create ();
  new_input = Wl.Listener.create ();
}

module OutputH = Hashtbl.Make (Output)
let outputs : output OutputH.t = OutputH.create 25

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

let output_remove_notify _ output =
  let o = OutputH.find outputs output in
  print_endline "Output removed";
  Wl.Listener.detach o.frame;
  Wl.Listener.detach o.destroy;
  OutputH.remove outputs output

let new_output_notify _ output =
  let o = { frame = Wl.Listener.create ();
            destroy = Wl.Listener.create (); } in
  Output.set_best_mode output;
  Wl.Signal.add (Output.signal_frame output) o.frame output_frame_notify;
  Wl.Signal.add (Output.signal_destroy output) o.destroy output_remove_notify;
  OutputH.replace outputs output o;
  ignore (Output.commit output : bool);
  ()

let new_input_notify _ _input =
  ()

let () =
  Log.(init Debug);
  let display = Wl.Display.create () in
  let backend = Backend.autocreate display in

  Wl.Signal.add (Backend.signal_new_output backend) (!state).new_output
    new_output_notify;
  Wl.Signal.add (Backend.signal_new_input backend) (!state).new_input
    new_input_notify;

  if not (Backend.start backend) then (
    Backend.destroy backend;
    failwith "Unable to start backend";
  );

  Wl.Display.run display;
  Wl.Display.destroy display;
  ()
