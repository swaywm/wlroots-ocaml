open! Wlroots_common.Utils

let run ~state ~handler (c: Compositor.t) =
  c.handler <- Event.handler_pack state handler;
  if not (Backend.start c.backend) then (
    Compositor.destroy c;
    failwith "Failed to start backend"
  );
  Unix.putenv "WAYLAND_DISPLAY" c.socket;
  Wl.Display.run c.display

let terminate = Compositor.destroy
