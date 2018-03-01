open Ctypes
open Utils

module Bindings = Wlroots_bindings.Bindings.Make (Ffi_generated)
module Types = Wlroots_bindings.Bindings.Types

module Wl = struct

  module Event_loop = struct
    type t = unit ptr
    include Ptr
  end

  module Listener = struct
    type 'a listener = {
      c : Types.Wl_listener.t ptr;
      (* Tie the lifetime of the OCaml callback function to the lifetime of the C
         structure, to prevent untimely memory collection *)
      notify : 'a -> unit;
    }

    type 'a t = 'a listener O.t

    let compare x1 x2 = O.compare (fun t1 t2 -> ptr_compare t1.c t2.c) x1 x2
    let equal x y = mk_equal compare x y
    let hash t = O.hash (fun t -> ptr_hash t.c) t

    let create (notify : 'a -> unit) : 'a t =
      let c_struct = make Types.Wl_listener.t in
      (* we do not set the [notify] field of the C structure yet. It will be done
         by [Signal.add], which will provide the coercion function from [void*] to
         ['a], computed from the [typ] field of the signal. *)
      O.create { c = addr c_struct; notify }

    let state (listener : 'a t) : [`attached | `detached] =
      match O.state listener with
      | `owned -> `detached
      | `transfered_to_c -> `attached

    let detach (listener : 'a t) =
      match O.state listener with
      | `owned -> ()
      | `transfered_to_c ->
        let raw_listener = O.reclaim_ownership listener in
        (* Detach the listener from its signal, as advised in the documentation of
           [wl_listener]. *)
        Bindings.wl_list_remove (raw_listener.c |-> Types.Wl_listener.link)
  end

  module Signal = struct
    type 'a t = {
      c : Types.Wl_signal.t ptr;
      typ : 'a typ;
    }

    let compare t1 t2 = ptr_compare t1.c t2.c
    let equal x y = mk_equal compare x y
    let hash t = ptr_hash t.c

    let add (signal : 'a t) (listener : 'a Listener.t) =
      match listener with
      | O.{ box = Owned raw_listener } ->
        setf (!@ (raw_listener.c)) Types.Wl_listener.notify
          (fun _ data -> raw_listener.notify (coerce (ptr void) signal.typ data));
        Bindings.wl_signal_add signal.c raw_listener.c;
        O.transfer_ownership_to_c listener
      | O.{ box = Transfered_to_C _ } ->
        failwith "Signal.add: cannot attach the same listener to multiple signals"
  end

  module Display = struct
    type t = unit ptr
    include Ptr

    let create () =
      let dpy = Bindings.wl_display_create () in
      if is_null dpy then failwith "Display.create";
      dpy

    let get_event_loop dpy =
      let el = Bindings.wl_display_get_event_loop dpy in
      if is_null el then failwith "Display.get_event_loop";
      el

    let run = Bindings.wl_display_run
    let destroy = Bindings.wl_display_destroy
    let add_socket_auto = Bindings.wl_display_add_socket_auto
    let init_shm = Bindings.wl_display_init_shm
  end

  module Resource = struct
    type t = Types.Wl_resource.t ptr
    include Ptr
  end
end

module Output = struct
  type t = Types.Output.t ptr
  let t = ptr Types.Output.t
  include Ptr

  module Mode = struct
    type t = Types.Output_mode.t ptr
    include Ptr

    let flags mode = mode |->> Types.Output_mode.flags
    let width mode = mode |->> Types.Output_mode.width
    let height mode = mode |->> Types.Output_mode.height
    let refresh mode = mode |->> Types.Output_mode.refresh
  end

  let modes (output : t) : Mode.t list =
    (output |-> Types.Output.modes)
    |> Bindings.ocaml_of_wl_list Bindings.wlr_output_mode_of_link

  let set_mode (output : t) (mode : Mode.t) =
    Bindings.wlr_output_set_mode output mode

  let make_current (output : t) : bool =
    (* TODO: handle buffer age *)
    Bindings.wlr_output_make_current output
      (coerce (ptr void) (ptr int) null)

  let swap_buffers (output : t) : bool =
    Bindings.wlr_output_swap_buffers output null null

  let create_global (output : t) =
    Bindings.wlr_output_create_global output

  module Events = struct
    let destroy (output : t) : t Wl.Signal.t = {
      c = output |-> Types.Output.events_destroy;
      typ = t;
    }

    let frame (output : t) : t Wl.Signal.t = {
      c = output |-> Types.Output.events_frame;
      typ = t;
    }
  end
end

module Renderer = struct
  type t = Types.Renderer.t ptr
  include Ptr

  let begin_ (renderer : t) (output : Output.t) =
    Bindings.wlr_renderer_begin renderer output

  let end_ (renderer : t) =
    Bindings.wlr_renderer_end renderer

  let clear (renderer : t) ((c1,c2,c3,c4) : float * float * float * float) =
    let color_arr = CArray.of_list float [c1;c2;c3;c4] in
    Bindings.wlr_renderer_clear renderer (CArray.start color_arr)
end

module Backend = struct
  type t = Types.Backend.t ptr
  include Ptr

  let autocreate dpy =
    let b = Bindings.wlr_backend_autocreate dpy in
    if is_null b then failwith "Backend.autocreate";
    b

  let start = Bindings.wlr_backend_start

  let get_renderer = Bindings.wlr_backend_get_renderer

  module Events = struct
    let new_output (backend : t) : Output.t Wl.Signal.t = {
      c = backend |-> Types.Backend.events_new_output;
      typ = Output.t;
    }
  end
end

module Compositor = struct
  type t = Types.Compositor.t ptr
  include Ptr

  let create = Bindings.wlr_compositor_create
  let destroy = Bindings.wlr_compositor_destroy
  let surfaces comp =
    (comp |-> Types.Compositor.surfaces)
    |> Bindings.ocaml_of_wl_list Bindings.wl_resource_of_link
end

module Xdg_shell_v6 = struct
  type t = Types.Xdg_shell_v6.t ptr
  include Ptr

  let create = Bindings.wlr_xdg_shell_v6_create
  let destroy = Bindings.wlr_xdg_shell_v6_destroy
end

module Gamma_control = struct
  type t = unit ptr
  include Ptr

  module Manager = struct
    type t = unit ptr
    include Ptr

    let create = Bindings.wlr_gamma_control_manager_create
    let destroy = Bindings.wlr_gamma_control_manager_destroy
  end
end

module Screenshooter = struct
  type t = unit ptr
  include Ptr

  let create = Bindings.wlr_screenshooter_create
  let destroy = Bindings.wlr_screenshooter_destroy
end

module Primary_selection = struct
  module Device_manager = struct
    type t = unit ptr
    include Ptr

    let create = Bindings.wlr_primary_selection_device_manager_create
    let destroy = Bindings.wlr_primary_selection_device_manager_destroy
  end
end

module Idle = struct
  type t  = unit ptr
  include Ptr

  let create = Bindings.wlr_idle_create
  let destroy = Bindings.wlr_idle_destroy
end

module Log = struct
  include Types.Log

  (* TODO: callback *)
  let init importance =
    Bindings.wlr_log_init importance null
end
