open Wlroots_common.Sigs

module Wl : sig
  module Event_loop : sig
    type t
    include Comparable0 with type t := t
  end

  module Listener : sig
    type t
    include Comparable0 with type t := t

    val create : unit -> t
    val state : t -> [`attached | `detached]
    val detach : t -> unit
  end

  module Signal : sig
    type 'a t
    include Comparable1 with type 'a t := 'a t

    val add : 'a t -> Listener.t -> (Listener.t -> 'a -> unit) -> unit
  end

  module Display : sig
    type t
    include Comparable0 with type t := t

    val create : unit -> t
    val get_event_loop : t -> Event_loop.t
    val run : t -> unit
    val destroy : t -> unit
    val destroy_clients : t -> unit
    val add_socket_auto : t -> string option
    val init_shm : t -> int
    val terminate : t -> unit
  end

  module Resource : sig
    type t
    include Comparable0 with type t := t
  end

  module Output_transform : sig
    type t
    include Comparable0 with type t := t
  end
end

module Texture : sig
  type t
  include Comparable0 with type t := t
end

module Surface : sig
  type t
  include Comparable0 with type t := t

  val from_resource : Wl.Resource.t -> t
  val has_buffer : t -> bool

  module State : sig
    type t
    include Comparable0 with type t := t
    val width : t -> int
    val height : t -> int
    val transform : t -> Wl.Output_transform.t
  end

  val current : t -> State.t
  val pending : t -> State.t
  val send_frame_done : t -> Mtime.t -> unit
end

module Box : sig
  type t = { x : int; y : int; width : int; height : int }
  include Comparable0 with type t := t
end

module Matrix : sig
  type t
  include Comparable0 with type t := t
  val project_box : Box.t -> Wl.Output_transform.t -> rotation:float -> t -> t
end

module Output : sig
  type t
  include Comparable0 with type t := t

  module Mode : sig
    type t
    include Comparable0 with type t := t

    val width : t -> int32
    val height : t -> int32
    val refresh : t -> int32 (* mHz *)
    val preferred : t -> bool
  end

  (* Setting an output mode *)
  val modes : t -> Mode.t list
  val set_mode : t -> Mode.t -> unit
  val preferred_mode : t -> Mode.t option

  val transform_matrix : t -> Matrix.t
  val create_global : t -> unit
  val attach_render : t -> bool
  val commit : t -> bool
  val enable : t -> bool -> unit

  val signal_frame : t -> t Wl.Signal.t
  val signal_destroy : t -> t Wl.Signal.t
end

module Output_layout : sig
  type t
  include Comparable0 with type t := t

  val create : unit -> t
  val add_auto : t -> Output.t -> unit
end

module Keyboard : sig
  type t
  include Comparable0 with type t := t

  type key_state = Released | Pressed

  module Event_key : sig
    type t
    include Comparable0 with type t := t

    val time_msec : t -> Unsigned.uint32
    val keycode : t -> int
    val update_state : t -> bool
    val state : t -> key_state
  end

  val xkb_state : t -> Xkbcommon.State.t
  val signal_key : t -> Event_key.t Wl.Signal.t
  val set_keymap : t -> Xkbcommon.Keymap.t -> bool
end

module Pointer : sig
  type t
  include Comparable0 with type t := t

  module Event_motion : sig
    type t
    include Comparable0 with type t := t
  end

  module Event_motion_absolute : sig
    type t
    include Comparable0 with type t := t
  end

  module Event_button : sig
    type t
    include Comparable0 with type t := t 
  end

  module Event_axis : sig
    type t
    include Comparable0 with type t := t
  end
end

module Touch : sig
  type t
  include Comparable0 with type t := t
end

module Tablet_tool : sig
  type t
  include Comparable0 with type t := t
end

module Tablet_pad : sig
  type t
  include Comparable0 with type t := t
end

module Input_device : sig
  type t
  include Comparable0 with type t := t

  type typ =
    | Keyboard of Keyboard.t
    | Pointer of Pointer.t
    | Touch of Touch.t
    | Tablet of Tablet_tool.t
    | Tablet_pad of Tablet_pad.t

  val typ : t -> typ
  val vendor : t -> int
  val product : t -> int
  val name : t -> string

  val signal_destroy : t -> t Wl.Signal.t
end

module Renderer : sig
  type t
  include Comparable0 with type t := t

  val begin_ : t -> width:int -> height:int -> unit
  val end_ : t -> unit
  val clear : t -> float * float * float * float -> unit
  val init_wl_display : t -> Wl.Display.t -> bool
end

module Backend : sig
  type t
  include Comparable0 with type t := t

  val autocreate : Wl.Display.t -> t
  val start : t -> bool
  val destroy : t -> unit

  val get_renderer : t -> Renderer.t

  val signal_new_output : t -> Output.t Wl.Signal.t
  val signal_new_input : t -> Input_device.t Wl.Signal.t
  val signal_destroy : t -> t Wl.Signal.t
end

module Data_device : sig
  module Manager : sig
    type t
    include Comparable0 with type t := t

    val create : Wl.Display.t -> t
  end
end

module Compositor : sig
  type t
  include Comparable0 with type t := t

  val create : Wl.Display.t -> Renderer.t -> t
end

module Xdg_shell : sig
  type t
  include Comparable0 with type t := t

  module Surface : sig
    type t
    include Comparable0 with type t := t
  end

  val create : Wl.Display.t -> t
  val signal_new_surface : t -> Surface.t Wl.Signal.t
end

module Cursor : sig
  type t
  include Comparable0 with type t := t

  val create : unit -> t
  val attach_output_layout : t -> Output_layout.t -> unit

  val signal_motion : t -> Pointer.Event_motion.t Wl.Signal.t
  val signal_motion_absolute : t -> Pointer.Event_motion_absolute.t Wl.Signal.t
  val signal_button : t -> Pointer.Event_button.t Wl.Signal.t
  val signal_axis : t -> Pointer.Event_axis.t Wl.Signal.t
  val signal_frame : t -> unit (* ? *) Wl.Signal.t
end

module Xcursor_manager : sig
  type t
  include Comparable0 with type t := t

  val create : string option -> int -> t
  val load : t -> float -> int
end

module Seat : sig
  type t
  include Comparable0 with type t := t

  module Pointer_request_set_cursor_event : sig
    type t
    include Comparable0 with type t := t
  end

  val create : Wl.Display.t -> string -> t
  val signal_request_set_cursor :
    t -> Pointer_request_set_cursor_event.t Wl.Signal.t
end

module Log : sig
  type importance =
    | Silent
    | Error
    | Info
    | Debug

  val init : importance -> unit
end
