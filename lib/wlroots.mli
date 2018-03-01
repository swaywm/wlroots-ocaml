open Sigs

module Wl : sig
  module Listener : sig
    (* Resources associated to a ['a Listener.t] (subscription to events
       broadcasted by a ['a Signal.t]) are manually managed.

       Attaching a listener to a signal using [Signal.add] registers the listener
       and gives its ownership to the C code. After attaching it, dropping the
       handle on a listener will not free the listener and its associated
       resources: one needs to explicitly call [detach] first (which un-registers
       it from the signal).

       NB: Detaching a listener then re-attaching it to the same or a different
       signal is possible -- detaching a listener does not necessarily means
       destroying it *)
    type 'a t
    include Comparable1 with type 'a t := 'a t

    val create : ('a -> unit) -> 'a t
    val state : 'a t -> [`attached | `detached]
    val detach : 'a t -> unit
  end

  module Signal : sig
    type 'a t
    include Comparable1 with type 'a t := 'a t

    val add : 'a t -> 'a Listener.t -> unit
  end

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
end

module Output : sig
  type t
  include Comparable0 with type t := t

  module Mode : sig
    type t
    include Comparable0 with type t := t

    val flags : t -> Unsigned.uint32
    val width : t -> int32
    val height : t -> int32
    val refresh : t -> int32 (* mHz *)
  end

  val modes : t -> Mode.t list
  val set_mode : t -> Mode.t -> bool
  val make_current : t -> bool
  val swap_buffers : t -> bool
  val create_global : t -> unit

  module Events : sig
    val destroy : t -> t Wl.Signal.t
    val frame : t -> t Wl.Signal.t
  end
end

module Renderer : sig
  type t
  include Comparable0 with type t := t

  val begin_ : t -> Output.t -> unit
  val end_ : t -> unit
  val clear : t -> float * float * float * float -> unit
end

module Backend : sig
  type t
  include Comparable0 with type t := t

  val autocreate : Wl.Display.t -> t
  val start : t -> bool
  val get_renderer : t -> Renderer.t

  module Events : sig
    val new_output : t -> Output.t Wl.Signal.t
  end
end

module Compositor : sig
  type t
  include Comparable0 with type t := t

  val create : Wl.Display.t -> Renderer.t -> t
  val destroy : t -> unit
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
