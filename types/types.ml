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

  module Wl_seat_capability = struct
    type t = Unsigned.uint64
    let t : t typ = uint64_t
    let _WL_SEAT_CAPABILITY_POINTER = constant "WL_SEAT_CAPABILITY_POINTER" uint64_t
    let _WL_SEAT_CAPABILITY_KEYBOARD = constant "WL_SEAT_CAPABILITY_KEYBOARD" uint64_t
    let _WL_SEAT_CAPABILITY_TOUCH = constant "WL_SEAT_CAPABILITY_TOUCH" uint64_t
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

  module Output_layout = struct
    type t = [`output_layout] Ctypes.structure
    let t : t typ = structure "wlr_output_layout"
    let () = seal t
  end

  module Key_state = struct
    type t = Released | Pressed

    let _RELEASED = constant "WLR_KEY_RELEASED" int64_t
    let _PRESSED = constant "WLR_KEY_PRESSED" int64_t

    let t : t typ = enum "wlr_key_state" [
      Released, _RELEASED;
      Pressed, _PRESSED;
    ]
  end

  (* This is an array of unit32_t keycodes: uint32_t keycodes[] *)
  module Keycodes = struct
    type t = unit ptr
    let t : t typ = ptr void
  end

  module Event_keyboard_key = struct
    type t = [`event_keyboard_key] Ctypes.structure
    let t : t typ = structure "wlr_event_keyboard_key"
    let time_msec = field t "time_msec" uint32_t
    let keycode = field t "keycode" int
    let update_state = field t "update_state" bool
    let state = field t "state" Key_state.t
  end

  module Keyboard_modifier = struct
    type modifier =
      Shift | Caps | Ctrl | Alt | Mod2 | Mod3 | Logo | Mod5

    let _WLR_MODIFIER_SHIFT = constant "WLR_MODIFIER_SHIFT" int64_t
    let _WLR_MODIFIER_CAPS = constant "WLR_MODIFIER_CAPS" int64_t
    let _WLR_MODIFIER_CTRL = constant "WLR_MODIFIER_CTRL" int64_t
    let _WLR_MODIFIER_ALT = constant "WLR_MODIFIER_ALT" int64_t
    let _WLR_MODIFIER_MOD2 = constant "WLR_MODIFIER_MOD2" int64_t
    let _WLR_MODIFIER_MOD3 = constant "WLR_MODIFIER_MOD3" int64_t
    let _WLR_MODIFIER_LOGO = constant "WLR_MODIFIER_LOGO" int64_t
    let _WLR_MODIFIER_MOD5 = constant "WLR_MODIFIER_MOD5" int64_t

    let modifier : modifier typ =
      enum "wlr_keyboard_modifier" [
        Shift, _WLR_MODIFIER_SHIFT;
        Ctrl, _WLR_MODIFIER_CTRL;
        Alt, _WLR_MODIFIER_ALT;
        Mod2, _WLR_MODIFIER_MOD2;
        Mod3, _WLR_MODIFIER_MOD3;
        Logo, _WLR_MODIFIER_LOGO;
        Mod5, _WLR_MODIFIER_MOD5;
      ]
  end

  module Keyboard_modifiers = struct
    type t = [`keyboard_modifier] Ctypes.structure
    let t : t typ = structure "wlr_keyboard_modifiers"
    let () = seal t
  end

  module Keyboard = struct
    type t = [`keyboard] Ctypes.structure
    let t : t typ = structure "wlr_keyboard"

    let xkb_state = field t "xkb_state" (lift_typ Xkbcommon.State.t)
    let modifiers = field t "modifiers" (ptr Keyboard_modifiers.t)
    let events_key = field t "events.key" Wl_signal.t
    let events_modifiers = field t "events.modifiers" Wl_signal.t
    let keycodes = field t "keycodes" Keycodes.t
    let num_keycodes = field t "num_keycodes" size_t
    let () = seal t
  end

  module Pointer = struct
    type t = [`pointer] Ctypes.structure
    let t : t typ = structure "wlr_pointer"

    let () = seal t
  end

  module Event_pointer_button = struct
    type t = [`event_pointer_button] Ctypes.structure
    let t : t typ = structure "wlr_event_pointer_button"

    let () = seal t
  end

  module Event_pointer_axis = struct
    type t = [`event_pointer_axis] Ctypes.structure
    let t : t typ = structure "wlr_event_pointer_axis"

    let () = seal t
  end

  module Edges = struct
    type t = None | Top | Bottom | Left | Right

    let _WLR_EDGE_NONE = constant "WLR_EDGE_NONE" int64_t
    let _WLR_EDGE_TOP = constant "WLR_EDGE_TOP" int64_t
    let _WLR_EDGE_BOTTOM = constant "WLR_EDGE_BOTTOM" int64_t
    let _WLR_EDGE_LEFT = constant "WLR_EDGE_LEFT" int64_t
    let _WLR_EDGE_RIGHT = constant "WLR_EDGE_RIGHT" int64_t

    let t : t typ =
      enum "wlr_edges" [
        None, _WLR_EDGE_NONE;
        Top, _WLR_EDGE_TOP;
        Bottom, _WLR_EDGE_BOTTOM;
        Left, _WLR_EDGE_LEFT;
        Right, _WLR_EDGE_RIGHT;
      ]
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

  module Event_pointer_motion_absolute = struct
    type t = [`event_pointer_motion_absolute] Ctypes.structure
    let t : t typ = structure "wlr_event_pointer_motion_absolute"

    let device = field t "device" (ptr Input_device.t)
    let x = field t "x" double
    let y = field t "y" double
    let () = seal t
  end

  module Event_pointer_motion = struct
    type t = [`event_pointer_motion] Ctypes.structure
    let t : t typ = structure "wlr_event_pointer_motion"

    let device = field t "device" (ptr Input_device.t)
    let time_msec = field t "time_msec" uint32_t
    let delta_x = field t "delta_x" double
    let delta_y = field t "delta_y" double

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

    type renderer_create_func_t =
      unit ptr -> int -> unit ptr -> unit ptr -> int -> Renderer.t ptr
    let renderer_create_func_t : renderer_create_func_t option typ =
      lift_typ
        (Foreign.funptr_opt
           (ptr void @-> int @-> ptr void @-> ptr void @-> int @->
            returning (ptr Renderer.t)))
  end

  module Data_device_manager = struct
    type t = [`data_device] Ctypes.structure
    let t : t typ = structure "wlr_data_device_manager"

    let () = seal t
  end

  module Compositor = struct
    type t = [`compositor] Ctypes.structure
    let t : t typ = structure "wlr_compositor"

    (* TODO *)
    let () = seal t
  end

  module Xdg_surface_role = struct
    (* The type of these may be compiler dependent *)
    let none = constant "WLR_XDG_SURFACE_ROLE_NONE" int64_t
    let top_level = constant "WLR_XDG_SURFACE_ROLE_TOPLEVEL" int64_t
    let popup = constant "WLR_XDG_SURFACE_ROLE_POPUP" int64_t

    type role = None | TopLevel | Popup

    type t = [`xdg_surface_role] Ctypes.structure
    let t : role typ = enum "wlr_xdg_surface_role" [
        None, none;
        TopLevel, top_level;
        Popup, popup;
      ]
  end

  module Xdg_toplevel = struct
    type t = [`xdg_toplevel] Ctypes.structure
    let t : t typ = structure "wlr_xdg_toplevel"

    let events_request_move = field t "events.request_move" Wl_signal.t
    let events_request_resize = field t "events.request_resize" Wl_signal.t

    let () = seal t
  end

  module Xdg_surface = struct
    type t = [`xdg_surface] Ctypes.structure
    let t : t typ = structure "wlr_xdg_surface"

    let role = field t "role" Xdg_surface_role.t
    let surface = field t "surface" Surface.t
    let toplevel = field t "toplevel" Xdg_toplevel.t

    let events_destroy = field t "events.destroy" Wl_signal.t
    let events_ping_timeout = field t "events.ping_timeout" Wl_signal.t
    let events_new_popup = field t "events.new_popup" Wl_signal.t
    let events_map = field t "events.map" Wl_signal.t
    let events_unmap = field t "events.unmap" Wl_signal.t
    let events_configure = field t "events.configure" Wl_signal.t
    let events_ack_configure = field t "events.ack_configure" Wl_signal.t
    let () = seal t
  end

  module Xdg_shell = struct
    type t = [`xdg_shell] Ctypes.structure
    let t : t typ = structure "wlr_xdg_shell"

    let events_new_surface = field t "events.new_surface" Wl_signal.t
    let events_destroy = field t "events.destroy" Wl_signal.t
    let () = seal t
  end

  module Cursor = struct
    type t = [`cursor] Ctypes.structure
    let t : t typ = structure "wlr_cursor"

    let x = field t "x" double
    let y = field t "y" double

    let events_motion = field t "events.motion" Wl_signal.t
    let events_motion_absolute = field t "events.motion_absolute" Wl_signal.t
    let events_button = field t "events.button" Wl_signal.t
    let events_axis = field t "events.axis" Wl_signal.t
    let events_frame = field t "events.frame" Wl_signal.t
    let () = seal t
  end

  module Xcursor_manager = struct
    type t = [`xcursor_manager] Ctypes.structure
    let t : t typ = structure "wlr_xcursor_manager"
    let () = seal t
  end

  module Seat_client = struct
    type t = [`seat_client] Ctypes.structure
    let t : t typ = structure "wlr_seat_client"
    let () = seal t
  end

  module Seat_pointer_state = struct
    type t = [`seat_pointer_state] Ctypes.structure
    let t : t typ = structure "wlr_seat_pointer_state"
    let focused_client = field t "focused_client"
        (ptr Seat_client.t)
    let focused_surface = field t "focused_surface"
        (ptr Surface.t)
    let () = seal t
  end

  module Seat_keyboard_state = struct
    type t = [`seat_keyboard_state] Ctypes.structure
    let t : t typ = structure "wlr_seat_keyboard_state"
    let focused_surface = field t "focused_surface"
        (ptr Surface.t)
    let keyboard = field t "keyboard" (ptr Keyboard.t)
    let () = seal t
  end

  module Seat = struct
    type t = [`seat] Ctypes.structure
    let t : t typ = structure "wlr_seat"

    let events_request_set_cursor =
      field t "events.request_set_cursor" Wl_signal.t
    let pointer_state =
      field t "pointer_state" Seat_pointer_state.t
    let keyboard_state =
      field t "keyboard_state" Seat_keyboard_state.t
    let () = seal t
  end

  module Seat_pointer_request_set_cursor_event = struct
    type t = [`seat_pointer_request_set_cursor_event] Ctypes.structure
    let t : t typ = structure "wlr_seat_pointer_request_set_cursor_event"
    let seat_client = field t "seat_client" (ptr Seat_client.t)
    let surface = field t "surface" (ptr Surface.t)
    let hotspot_x = field t "hotspot_x" int
    let hotspot_y = field t "hotspot_y" int
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
