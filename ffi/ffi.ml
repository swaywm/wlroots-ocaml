open Ctypes
open Wlroots_common.Utils

module Types = Wlroots_types_f.Types.Make (Generated_types)

module Make (F : Cstubs.FOREIGN) =
struct
  open F
  open Types

  (* time *)

  let mtime_of_timespec timespec =
    let open Time in
    let ns = Int64.(add timespec.Timespec.sec
                      (of_int timespec.Timespec.nsec)) in
    Mtime.of_uint64_ns ns

  let timespec_of_mtime mtime =
    let ns_in_sec = 1_000_000_000L in
    let ns = Mtime.to_uint64_ns mtime in
    let sec = Int64.div ns ns_in_sec in
    let nsec = Int64.rem ns ns_in_sec |> Int64.to_int in
    Time.Timespec.{ sec; nsec }

  let time : Mtime.t typ =
    view
      ~read:(fun timespec_p -> mtime_of_timespec (!@ timespec_p))
      ~write:(fun mtime ->
        let timespec = timespec_of_mtime mtime in
        allocate Time_unix.Timespec.t timespec)
      (ptr Time_unix.Timespec.t)

  (* wl_list *)

  type wl_list_p = Wl_list.t ptr
  let wl_list_p = ptr Wl_list.t

  let prev (l: wl_list_p) : wl_list_p = Ctypes.(getf (!@ l) Wl_list.prev)
  let next (l: wl_list_p) : wl_list_p = Ctypes.(getf (!@ l) Wl_list.next)

  let wl_list_init = foreign "wl_list_init"
      (wl_list_p @-> returning void)

  let wl_list_remove = foreign "wl_list_remove"
      (wl_list_p @-> returning void)

  let ocaml_of_wl_list
      (extract_elt : wl_list_p -> 'a)
      (l : wl_list_p) :
    'a list
    =
    let rec aux acc elt =
      if ptr_eq elt l then List.rev acc
      else aux ((extract_elt elt)::acc) (next elt)
    in
    if Ctypes.(ptr_eq (coerce wl_list_p (ptr void) l) null) then []
    else aux [] (next l)

  (* wl_listener *)

  let wl_listener_p = ptr Wl_listener.t

  (* wl_signal *)

  let wl_signal_p = ptr Wl_signal.t

  let wl_signal_add = foreign "wl_signal_add"
      (wl_signal_p @-> wl_listener_p @-> returning void)

  (* wl_event_loop *)

  let wl_event_loop_p = ptr void

  (* wl_display *)

  let wl_display_p = ptr void

  let wl_display_create = foreign "wl_display_create"
      (void @-> returning wl_display_p)

  let wl_display_get_event_loop = foreign "wl_display_get_event_loop"
      (wl_display_p @-> returning wl_event_loop_p)

  let wl_display_run = foreign "wl_display_run"
      (wl_display_p @-> returning void)

  let wl_display_destroy = foreign "wl_display_destroy"
      (wl_display_p @-> returning void)

  let wl_display_destroy_clients = foreign "wl_display_destroy_clients"
      (wl_display_p @-> returning void)

  let wl_display_add_socket_auto = foreign "wl_display_add_socket_auto"
      (wl_display_p @-> returning string_opt)

  let wl_display_init_shm = foreign "wl_display_init_shm"
      (wl_display_p @-> returning int)

  let wl_display_terminate = foreign "wl_display_terminate"
      (wl_display_p @-> returning void)

  (* wl_resource *)

  let wl_resource_p = ptr Wl_resource.t

  (* wlr_output_mode *)

  let wlr_output_mode_p = ptr Output_mode.t

  (* wlr_output *)

  let wlr_output_p = ptr Output.t

  let wlr_output_set_mode = foreign "wlr_output_set_mode"
      (wlr_output_p @-> wlr_output_mode_p @-> returning void)

  let wlr_output_create_global = foreign "wlr_output_create_global"
      (wlr_output_p @-> returning void)

  let wlr_output_attach_render = foreign "wlr_output_attach_render"
      (wlr_output_p @-> ptr int @-> returning bool)

  let wlr_output_commit = foreign "wlr_output_commit"
      (wlr_output_p @-> returning bool)

  let wlr_output_preferred_mode = foreign "wlr_output_preferred_mode"
      (wlr_output_p @-> returning wlr_output_mode_p)

  let wlr_output_enable = foreign "wlr_output_enable"
      (wlr_output_p @-> bool @-> returning void)

  (* wlr_output_layout *)

  let wlr_output_layout_p = ptr Output_layout.t

  let wlr_output_layout_create = foreign "wlr_output_layout_create"
      (void @-> returning wlr_output_layout_p)

  let wlr_output_layout_add_auto = foreign "wlr_output_layout_add_auto"
      (wlr_output_layout_p @-> wlr_output_p @-> returning void)

  (* wlr_box *)

  let wlr_box_p = ptr Box.t

  (* wlr_matrix *)

  let wlr_matrix_p = ptr float

  let wlr_matrix_project_box = foreign "wlr_matrix_project_box"
      (wlr_matrix_p @-> wlr_box_p @-> Wl_output_transform.t @-> float @->
       wlr_matrix_p @-> returning void)

  (* wlr_texture *)

  let wlr_texture_p = ptr Texture.t

  (* wlr_surface *)

  let wlr_surface_p = ptr Surface.t

  let wlr_surface_from_resource = foreign "wlr_surface_from_resource"
      (wl_resource_p @-> returning wlr_surface_p)

  let wlr_surface_has_buffer = foreign "wlr_surface_has_buffer"
      (wlr_surface_p @-> returning bool)

  let wlr_surface_send_frame_done = foreign "wlr_surface_send_frame_done"
      (wlr_surface_p @-> time @-> returning void)

  (* wlr_renderer *)

  let wlr_renderer_p = ptr Renderer.t

  let wlr_renderer_begin = foreign "wlr_renderer_begin"
      (wlr_renderer_p @-> int @-> int @-> returning void)

  let wlr_renderer_end = foreign "wlr_renderer_end"
      (wlr_renderer_p @-> returning void)

  let wlr_renderer_clear = foreign "wlr_renderer_clear"
      (wlr_renderer_p @-> ptr float @-> returning void)

  let wlr_renderer_init_wl_display = foreign "wlr_renderer_init_wl_display"
      (wlr_renderer_p @-> wl_display_p @-> returning bool)

  (* wlr_input_device *)

  let wlr_input_device_p = ptr Input_device.t

  (* wlr_keyboard *)

  let wlr_keyboard_p = ptr Keyboard.t

  let wlr_keyboard_set_keymap = foreign "wlr_keyboard_set_keymap"
      (wlr_keyboard_p @-> Xkbcommon.Keymap.t @-> returning bool)

  let wlr_keyboard_from_input_device = foreign "wlr_keyboard_from_input_device"
      (wlr_input_device_p @-> returning wlr_keyboard_p)

  (* wlr_pointer *)

  let wlr_pointer_p = ptr Pointer.t

  let wlr_pointer_from_input_device = foreign "wlr_pointer_from_input_device"
      (wlr_input_device_p @-> returning wlr_pointer_p)

  (* wlr_touch *)

  let wlr_touch_p = ptr Touch.t

  let wlr_touch_from_input_device = foreign "wlr_touch_from_input_device"
      (wlr_input_device_p @-> returning wlr_touch_p)

  (* wlr_tablet *)

  let wlr_tablet_p = ptr Tablet.t

  let wlr_tablet_from_input_device = foreign "wlr_tablet_from_input_device"
      (wlr_input_device_p @-> returning wlr_tablet_p)

  (* wlr_tablet_pad *)

  let wlr_tablet_pad_p = ptr Tablet_pad.t

  let wlr_tablet_pad_from_input_device = foreign "wlr_tablet_pad_from_input_device"
      (wlr_input_device_p @-> returning wlr_tablet_pad_p)

  (* wlr_backend *)

  let wlr_backend_p = ptr Backend.t

  let wlr_renderer_autocreate = foreign "wlr_renderer_autocreate"
      (wlr_backend_p @-> returning wlr_renderer_p)

  let wlr_backend_autocreate = foreign "wlr_backend_autocreate"
      (wl_display_p @-> ptr (ptr Session.t) @-> returning wlr_backend_p)

  let wlr_backend_start = foreign "wlr_backend_start"
      (wlr_backend_p @-> returning bool)

  let wlr_backend_destroy = foreign "wlr_backend_destroy"
      (wlr_backend_p @-> returning void)

  (* wlr_data_device_manager *)

  let wlr_data_device_manager_p = ptr Data_device_manager.t

  let wlr_data_device_manager_create = foreign "wlr_data_device_manager_create"
      (wl_display_p @-> returning wlr_data_device_manager_p)

  (* wlr_compositor *)

  let wlr_compositor_p = ptr Compositor.t

  let wlr_compositor_create = foreign "wlr_compositor_create"
      (wl_display_p @-> int @-> wlr_renderer_p @-> returning wlr_compositor_p)

  (* wlr_xdg_shell *)

  let wlr_xdg_shell_p = ptr Xdg_shell.t

  let wlr_xdg_shell_create = foreign "wlr_xdg_shell_create"
      (wl_display_p @-> int @-> returning wlr_xdg_shell_p)

  (* wlr_cursor *)

  let wlr_cursor_p = ptr Cursor.t

  let wlr_cursor_create = foreign "wlr_cursor_create"
      (void @-> returning wlr_cursor_p)

  let wlr_cursor_attach_output_layout =
    foreign "wlr_cursor_attach_output_layout"
      (wlr_cursor_p @-> wlr_output_layout_p @-> returning void)

  let wlr_cursor_attach_input_device =
    foreign "wlr_cursor_attach_input_device"
      (wlr_cursor_p @-> wlr_input_device_p @-> returning void)

  let wlr_cursor_set_surface =
    foreign "wlr_cursor_set_surface"
      (wlr_cursor_p @-> wlr_surface_p @-> int @-> int @-> returning void)

  (* wlr_xcursor_manager *)

  let wlr_xcursor_manager_p = ptr Xcursor_manager.t

  let wlr_xcursor_manager_create = foreign "wlr_xcursor_manager_create"
      (string_opt @-> int @-> returning wlr_xcursor_manager_p)

  let wlr_xcursor_manager_load = foreign "wlr_xcursor_manager_load"
      (wlr_xcursor_manager_p @-> float @-> returning int)

  (* wlr_seat *)

  let wlr_seat_p = ptr Seat.t

  let wlr_seat_create = foreign "wlr_seat_create"
      (wl_display_p @-> string @-> returning wlr_seat_p)

  let wlr_seat_set_capabilities = foreign "wlr_seat_set_capabilities"
      (wlr_seat_p @-> Wl_seat_capability.t @-> returning void)

  (* wlr_log *)

  (* TODO *)
  let log_callback_t = ptr void
  let log_importance_t = Log.importance

  let wlr_log_init = foreign "wlr_log_init"
      (log_importance_t @-> log_callback_t @-> returning void)
end
