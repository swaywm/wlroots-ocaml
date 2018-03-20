open Wlroots_common.Sigs

module Wl : sig
  module Event_loop : sig
    type t
    include Comparable0 with type t := t
  end

  module Display : sig
    type t
    include Comparable0 with type t := t

    val create : unit -> t
    val get_event_loop : t -> Event_loop.t
    val run : t -> unit
    val destroy : t -> unit
    val add_socket_auto : t -> string
    val init_shm : t -> int
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
  val texture : t -> Texture.t
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

  type handler =
      Handler :
        < frame : t -> unit;
          .. >
      -> handler

  val handler_default : handler

  module Mode : sig
    type t
    include Comparable0 with type t := t

    val flags : t -> Unsigned.uint32
    val width : t -> int32
    val height : t -> int32
    val refresh : t -> int32 (* mHz *)
  end

  (* Setting an output mode *)
  val modes : t -> Mode.t list
  val set_mode : t -> Mode.t -> bool
  val best_mode : t -> Mode.t option
  val set_best_mode : t -> unit

  val transform_matrix : t -> Matrix.t
  val make_current : t -> bool
  val swap_buffers : t -> bool
  val create_global : t -> unit
end

module Renderer : sig
  type t
  include Comparable0 with type t := t

  val begin_ : t -> Output.t -> unit
  val end_ : t -> unit
  val clear : t -> float * float * float * float -> unit

  val render_with_matrix : t -> Texture.t -> Matrix.t -> alpha:float -> bool
end

module Compositor : sig
  type t

  type outputs_handler =
      Outputs_handler :
        < output_added : t -> Output.t -> Output.handler;
          output_destroyed : t -> Output.t -> unit;
          .. >
      -> outputs_handler

  val outputs_handler_default : outputs_handler

  val create :
    ?outputs_handler:outputs_handler ->
    ?screenshooter:bool ->
    ?idle:bool ->
    ?xdg_shell_v6:bool ->
    ?primary_selection:bool ->
    ?gamma_control:bool ->
    unit ->
    t
  val run : t -> unit
  val terminate : t -> unit

  val display : t -> Wl.Display.t
  val event_loop : t -> Wl.Event_loop.t
  val renderer : t -> Renderer.t
  val surfaces : t -> Wl.Resource.t list
end

module Xdg_shell_v6 : sig
  type t
  include Comparable0 with type t := t

  val create : Wl.Display.t -> t
  val destroy : t -> unit
end

module Gamma_control : sig
  type t
  include Comparable0 with type t := t

  module Manager : sig
    type t
    include Comparable0 with type t := t

    val create : Wl.Display.t -> t
    val destroy : t -> unit
  end
end

module Screenshooter : sig
  type t
  include Comparable0 with type t := t

  val create : Wl.Display.t -> t
  val destroy : t -> unit
end

module Primary_selection : sig
  module Device_manager : sig
    type t
    include Comparable0 with type t := t

    val create : Wl.Display.t -> t
    val destroy : t -> unit
  end
end

module Idle : sig
  type t
  include Comparable0 with type t := t

  val create : Wl.Display.t -> t
  val destroy : t -> unit
end

module Log : sig
  type importance =
    | Silent
    | Error
    | Info
    | Debug

  val init : importance -> unit
end
