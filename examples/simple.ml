open Wlroots

type state = {
  last_frame : Mtime.t;
  mutable dec : int;
  color : float array; (* of size 3 *)
}

let output_frame comp output st =
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

  ignore (Output.make_current output : bool);
  let renderer = Compositor.renderer comp in
  Renderer.begin_ renderer output;
  Renderer.clear renderer (st.color.(0), st.color.(1), st.color.(2), 1.);
  ignore (Output.swap_buffers output : bool);
  Renderer.end_ renderer;
  { st with last_frame = Mtime_clock.now () }

let () =
  Log.(init Debug);
  let comp = Compositor.create () in
  Main.run
    ~state:{ last_frame = Mtime_clock.now (); dec = 0; color = [|1.; 0.; 0.|] }
    ~handler:(function
    | Output.Frame output -> output_frame comp output
    | _ -> fun st -> st)
    comp;
  Main.terminate comp
