open Ctypes

module Make (S : Cstubs_structs.TYPE) = struct
  open S

  module Wl_list = struct
    type t = [`wl_list] structure
    let t : t typ = structure "wl_list"
    let prev = field t "prev" (ptr t)
    let next = field t "next" (ptr t)
    let () = seal t
  end

  module Wl_signal = struct
    type t = [`wl_signal] Ctypes.structure
    let t : t typ = structure "wl_signal"
    let listener_list = field t "listener_list" Wl_list.t
    let () = seal t
  end

  module Wl_listener = struct
    type t = [`wl_listener] Ctypes.structure
    let t : t typ = structure "wl_listener"

    type wl_notify_func_t = t ptr -> unit ptr -> unit
    let wl_notify_func_t : wl_notify_func_t typ =
      lift_typ (Foreign.funptr (ptr t @-> ptr void @-> returning void))

    let link = field t "link" Wl_list.t
    let notify = field t "notify" wl_notify_func_t
    let () = seal t
  end

  module Wl_resource = struct
    type t = [`wl_resource] Ctypes.structure
    let t : t typ = structure "wl_resource"
    let link = field t "link" Wl_list.t
    (* TODO *)
    let () = seal t
  end

  module Wl_output_transform = struct
    (* FIXME *)
    type t = int64
    let t : t typ = int64_t
  end

  module Renderer = struct
    type t = [`renderer] Ctypes.structure
    let t : t typ = structure "wlr_renderer"
  end

  module Surface_state = struct
    type t = [`surface_state] Ctypes.structure
    let t : t typ = structure "wlr_surface_state"
    let width = field t "width" int
    let height = field t "height" int
    let transform = field t "transform" Wl_output_transform.t
    (* TODO *)
    let () = seal t
  end

  module Texture = struct
    type t = [`texture] Ctypes.structure
    let t : t typ = structure "wlr_texture"
  end

  module Surface = struct
    type t = [`surface] Ctypes.structure
    let t : t typ = structure "wlr_surface"
    let current = field t "current" (ptr Surface_state.t)
    let pending = field t "pending" (ptr Surface_state.t)
    (* TODO *)
    let () = seal t
  end

  module Box = struct
    type t = [`box] Ctypes.structure
    let t : t typ = structure "wlr_box"
    let x = field t "x" int
    let y = field t "y" int
    let width = field t "width" int
    let height = field t "height" int
    let () = seal t
  end

  module Output_mode = struct
    type t = [`output_mode] Ctypes.structure
    let t : t typ = structure "wlr_output_mode"
    let width = field t "width" int32_t
    let height = field t "height" int32_t
    let refresh = field t "refresh" int32_t
    let preferred = field t "preferred" bool
    let link = field t "link" Wl_list.t
    let () = seal t
  end

  module Output = struct
    type t = [`output] Ctypes.structure
    let t : t typ = structure "wlr_output"

    let modes = field t "modes" Wl_list.t
    let current_mode = field t "current_mode" (ptr Output_mode.t)
    let events_destroy = field t "events.destroy" Wl_signal.t
    let events_frame = field t "events.frame" Wl_signal.t
    let transform_matrix = field t "transform_matrix" (array 16 float)

    (* TODO *)
    let () = seal t
  end

  module Keyboard = struct
    type t = [`keyboard] Ctypes.structure
    let t : t typ = structure "wlr_keyboard"

    let () = seal t
  end

  module Pointer = struct
    type t = [`pointer] Ctypes.structure
    let t : t typ = structure "wlr_pointer"

    let () = seal t
  end

  module Touch = struct
    type t = [`touch] Ctypes.structure
    let t : t typ = structure "wlr_touch"

    let () = seal t
  end

  module Tablet = struct
    type t = [`tablet_tool] Ctypes.structure
    let t : t typ = structure "wlr_tablet"

    let () = seal t
  end

  module Tablet_pad = struct
    type t = [`tablet_pad] Ctypes.structure
    let t : t typ = structure "wlr_tablet_pad"

    let () = seal t
  end

  module Input_device = struct
    type t = [`output_device] Ctypes.structure
    let t : t typ = structure "wlr_input_device"

    module Type = struct
      type t =
        | Keyboard
        | Pointer
        | Touch
        | Tablet_tool
        | Tablet_pad

      let _KEYBOARD = constant "WLR_INPUT_DEVICE_KEYBOARD" int64_t
      let _POINTER = constant "WLR_INPUT_DEVICE_POINTER" int64_t
      let _TOUCH = constant "WLR_INPUT_DEVICE_TOUCH" int64_t
      let _TABLET_TOOL = constant "WLR_INPUT_DEVICE_TABLET_TOOL" int64_t
      let _TABLET_PAD = constant "WLR_INPUT_DEVICE_TABLET_PAD" int64_t

      let t : t typ = enum "wlr_input_device_type" [
        Keyboard, _KEYBOARD;
        Pointer, _POINTER;
        Touch, _TOUCH;
        Tablet_tool, _TABLET_TOOL;
        Tablet_pad, _TABLET_PAD;
      ]
    end

    let typ = field t "type" Type.t
    let vendor = field t "vendor" int
    let product = field t "product" int
    let name = field t "name" string
    let keyboard = field t "keyboard" (ptr Keyboard.t)
    let pointer = field t "pointer" (ptr Pointer.t)
    let touch = field t "touch" (ptr Touch.t)
    let tablet = field t "tablet" (ptr Tablet.t)
    let tablet_pad = field t "tablet_pad" (ptr Tablet_pad.t)

    let events_destroy = field t "events.destroy" Wl_signal.t

    (* TODO *)
    let () = seal t
  end

  module Backend = struct
    type t = [`backend] Ctypes.structure
    let t : t typ = structure "wlr_backend"
    let impl = field t "impl" (ptr void)
    let events_destroy = field t "events.destroy" Wl_signal.t
    let events_new_input = field t "events.new_input" Wl_signal.t
    let events_new_output = field t "events.new_output" Wl_signal.t
    let () = seal t
  end

  module Compositor = struct
    type t = [`compositor] Ctypes.structure
    let t : t typ = structure "wlr_compositor"

    (* TODO *)
    let () = seal t
  end

  module Log = struct
    type importance =
      | Silent
      | Error
      | Info
      | Debug

    let _WLR_SILENT = constant "WLR_SILENT" int64_t
    let _WLR_ERROR = constant "WLR_ERROR" int64_t
    let _WLR_INFO = constant "WLR_INFO" int64_t
    let _WLR_DEBUG = constant "WLR_DEBUG" int64_t
    let _WLR_LOG_IMPORTANCE_LAST = constant "WLR_LOG_IMPORTANCE_LAST" int64_t

    let importance : importance typ =
      enum "wlr_log_importance" [
        Silent, _WLR_SILENT;
        Error, _WLR_ERROR;
        Info, _WLR_INFO;
        Debug, _WLR_DEBUG;
      ]
  end
end
