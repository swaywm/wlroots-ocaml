open Ctypes
open Wlroots_common.Utils

module Bindings = Wlroots_ffi_f.Ffi.Make (Generated_ffi)
module Types = Wlroots_ffi_f.Ffi.Types

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
      mutable full_notify : Types.Wl_listener.t ptr -> unit ptr -> unit;
    }

    let full_notify_dummy _ _ = assert false

    type 'a t = 'a listener O.t

    let compare x1 x2 = O.compare (fun t1 t2 -> ptr_compare t1.c t2.c) x1 x2
    let equal x y = mk_equal compare x y
    let hash t = O.hash (fun t -> ptr_hash t.c) t

    let create (notify : 'a -> unit) : 'a t =
      let c_struct = make Types.Wl_listener.t in
      (* we do not set the [notify] field of the C structure yet. It will be done
         by [Signal.add], which will provide the coercion function from [void*] to
         ['a], computed from the [typ] field of the signal, and compose it with [notify]
         to obtain [full_notify]. *)
      O.create { c = addr c_struct; notify; full_notify = full_notify_dummy }

    let state (listener : 'a t) : [`attached | `detached] =
      match O.state listener with
      | `owned -> `detached
      | `transfered_to_c -> `attached

    let detach (listener : 'a t) =
      match O.state listener with
      | `owned -> ()
      | `transfered_to_c ->
        let raw_listener = O.reclaim_ownership listener in
        (* Throw away [full_notify] which was [notify] (which we keep) + a closure
           specific to the signal, which can now be garbage collected. *)
        raw_listener.full_notify <- full_notify_dummy;
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
        let full_notify _ data =
          raw_listener.notify (coerce (ptr void) signal.typ data)
        in
        raw_listener.full_notify <- full_notify;
        setf (!@ (raw_listener.c)) Types.Wl_listener.notify full_notify;
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

  module Output_transform = struct
    type t = Types.Wl_output_transform.t
    include Poly
  end
end

module Log = struct
  include Types.Log

  (* TODO: callback *)
  let init importance =
    Bindings.wlr_log_init importance null

  (* TODO logging functions *)
end

module Texture = struct
  type t = Types.Texture.t ptr
  include Ptr
end

module Surface = struct
  type t = Types.Surface.t ptr
  include Ptr

  let from_resource = Bindings.wlr_surface_from_resource
  let has_buffer = Bindings.wlr_surface_has_buffer

  module State = struct
    type t = Types.Surface_state.t ptr
    include Ptr

    let width = getfield Types.Surface_state.width
    let height = getfield Types.Surface_state.height
    let transform = getfield Types.Surface_state.transform
  end

  let current = getfield Types.Surface.current
  let pending = getfield Types.Surface.pending
  let texture = getfield Types.Surface.texture

  let send_frame_done = Bindings.wlr_surface_send_frame_done
end

module Box = struct
  type t = { x : int; y : int; width : int; height : int }
  include Poly

  let of_c (c_box : Types.Box.t ptr) =
    { x = c_box |->> Types.Box.x;
      y = c_box |->> Types.Box.y;
      width = c_box |->> Types.Box.width;
      height = c_box |->> Types.Box.height; }

  let to_c { x; y; width; height } : Types.Box.t ptr =
    let c_box = make Types.Box.t in
    setf c_box Types.Box.x x;
    setf c_box Types.Box.y y;
    setf c_box Types.Box.width width;
    setf c_box Types.Box.height height;
    addr c_box
end

module Matrix = struct
  type t = float ptr
  include Ptr

  let project_box box transform ~rotation projection =
    let mat = CArray.make float 16 in
    let mat_p = CArray.start mat in
    Bindings.wlr_matrix_project_box
      mat_p (Box.to_c box) transform rotation
      projection;
    mat_p
end

module Output = struct
  type t = Types.Output.t ptr
  let t = ptr Types.Output.t
  include Ptr

  module Mode = struct
    type t = Types.Output_mode.t ptr
    include Ptr

    let flags = getfield Types.Output_mode.flags
    let width = getfield Types.Output_mode.width
    let height = getfield Types.Output_mode.height
    let refresh = getfield Types.Output_mode.refresh
  end

  let modes (output : t) : Mode.t list =
    (output |-> Types.Output.modes)
    |> Bindings.ocaml_of_wl_list
      (container_of Types.Output_mode.t Types.Output_mode.link)

  let transform_matrix (output : t) : Matrix.t =
    CArray.start (output |->> Types.Output.transform_matrix)

  let set_mode (output : t) (mode : Mode.t): bool =
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

  let render_with_matrix renderer texture mat ~alpha =
    Bindings.wlr_render_with_matrix renderer texture mat alpha
end

module Backend = struct
  type t = Types.Backend.t ptr
  include Ptr

  let autocreate dpy =
    let b = Bindings.wlr_backend_autocreate dpy in
    if is_null b then failwith "Failed to create backend";
    b

  let start = Bindings.wlr_backend_start
  let destroy = Bindings.wlr_backend_destroy

  let get_renderer = Bindings.wlr_backend_get_renderer

  module Events = struct
    let new_output (backend : t) : Output.t Wl.Signal.t = {
      c = backend |-> Types.Backend.events_new_output;
      typ = Output.t;
    }
  end
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

module Compositor = struct
  type t = {
    compositor : Types.Compositor.t ptr;
    backend : Backend.t;
    display : Wl.Display.t;
    event_loop : Wl.Event_loop.t;
    renderer : Renderer.t;
    socket : string;
    shm_fd : int;
    mutable screenshooter : Screenshooter.t option;
    mutable idle : Idle.t option;
    mutable xdg_shell_v6 : Xdg_shell_v6.t option;
    mutable primary_selection : Primary_selection.Device_manager.t option;
    mutable gamma_control : Gamma_control.Manager.t option;
  }

  let create
      ?(screenshooter = true)
      ?(idle = true)
      ?(xdg_shell_v6 = true)
      ?(primary_selection = true)
      ?(gamma_control = true)
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
    let screenshooter = flag screenshooter Screenshooter.create display in
    let idle = flag idle Idle.create display in
    let xdg_shell_v6 = flag xdg_shell_v6 Xdg_shell_v6.create display in
    let primary_selection =
      flag primary_selection Primary_selection.Device_manager.create display in
    let gamma_control =
      flag gamma_control Gamma_control.Manager.create display in

    { compositor; backend; display; event_loop; renderer; socket; shm_fd;
      screenshooter; idle; xdg_shell_v6; primary_selection; gamma_control; }

  let run c =
    if not (Backend.start c.backend) then (
      Backend.destroy c.backend;
      failwith "Failed to start backend"
    );
    Unix.putenv "WAYLAND_DISPLAY" c.socket;
    Wl.Display.run c.display

  let terminate c =
    Bindings.wlr_compositor_destroy c.compositor; (* ? *)
    Wl.Display.destroy c.display

  let display c = c.display
  let event_loop c = c.event_loop
  let renderer c = c.renderer

  module Events = struct
    let new_output c = Backend.Events.new_output c.backend
  end

  let surfaces comp =
    (comp.compositor |-> Types.Compositor.surfaces)
    |> Bindings.ocaml_of_wl_list
      (container_of Types.Wl_resource.t Types.Wl_resource.link)
end
