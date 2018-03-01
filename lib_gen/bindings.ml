open Ctypes

module Types = Bindings_structs_lib.Bindings_structs.Make (Generated_types)

(* TODO: move *)
module Utils = struct
  let ptr_eq p q = Ctypes.ptr_compare p q = 0

  let ( |->> ) s f = !@ (s |-> f)
end

module Make (F : Cstubs.FOREIGN) =
struct
  open Ctypes
  open F
  open Types
  open Utils

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

  let wl_display_add_socket_auto = foreign "wl_display_add_socket_auto"
      (wl_display_p @-> returning string)

  let wl_display_init_shm = foreign "wl_display_init_shm"
      (wl_display_p @-> returning int)

  (* wl_resource *)

  let wl_resource_p = ptr Wl_resource.t

  let wl_resource_of_link = foreign "wl_resource_of_link"
      (wl_list_p @-> returning wl_resource_p)

  (* wlr_output_mode *)

  let wlr_output_mode_p = ptr Output_mode.t

  let wlr_output_mode_of_link = foreign "wlr_output_mode_of_link"
      (wl_list_p @-> returning wlr_output_mode_p)

  (* wlr_output *)

  let wlr_output_p = ptr Output.t

  let wlr_output_set_mode = foreign "wlr_output_set_mode"
      (wlr_output_p @-> wlr_output_mode_p @-> returning bool)

  let wlr_output_make_current = foreign "wlr_output_make_current"
      (wlr_output_p @-> ptr int @-> returning bool)

  (* TODO: handle "when" and "damage" *)
  let wlr_output_swap_buffers = foreign "wlr_output_swap_buffers"
      (wlr_output_p @-> ptr void @-> ptr void @-> returning bool)

  let wlr_output_create_global = foreign "wlr_output_create_global"
      (wlr_output_p @-> returning void)

  (* wlr_renderer *)

  let wlr_renderer_p = ptr Renderer.t

  let wlr_renderer_begin = foreign "wlr_renderer_begin"
      (wlr_renderer_p @-> wlr_output_p @-> returning void)

  let wlr_renderer_end = foreign "wlr_renderer_end"
      (wlr_renderer_p @-> returning void)

  let wlr_renderer_clear = foreign "wlr_renderer_clear"
      (wlr_renderer_p @-> ptr float @-> returning void)

  (* wlr_backend *)

  let wlr_backend_p = ptr Backend.t

  let wlr_backend_get_renderer = foreign "wlr_backend_get_renderer"
      (wlr_backend_p @-> returning wlr_renderer_p)

  let wlr_backend_autocreate = foreign "wlr_backend_autocreate"
      (wl_display_p @-> returning wlr_backend_p)

  let wlr_backend_start = foreign "wlr_backend_start"
      (wlr_backend_p @-> returning bool)

  (* wlr_compositor *)

  let wlr_compositor_p = ptr Compositor.t

  let wlr_compositor_create = foreign "wlr_compositor_create"
      (wl_display_p @-> wlr_renderer_p @-> returning wlr_compositor_p)

  let wlr_compositor_destroy = foreign "wlr_compositor_destroy"
      (wlr_compositor_p @-> returning void)

  (* wlr_xdg_shell_v6 *)

  let wlr_xdg_shell_v6_p = ptr Xdg_shell_v6.t

  let wlr_xdg_shell_v6_create = foreign "wlr_xdg_shell_v6_create"
      (wl_display_p @-> returning wlr_xdg_shell_v6_p)

  let wlr_xdg_shell_v6_destroy = foreign "wlr_xdg_shell_v6_destroy"
      (wlr_xdg_shell_v6_p @-> returning void)

  (* wlr_gamma_control *)

  (* TODO *)
  let wlr_gamma_control_manager = ptr void

  let wlr_gamma_control_manager_create = foreign "wlr_gamma_control_manager_create"
      (wl_display_p @-> returning wlr_gamma_control_manager)

  let wlr_gamma_control_manager_destroy = foreign "wlr_gamma_control_manager_destroy"
      (wlr_gamma_control_manager @-> returning void)

  (* wlr_screenshoter *)

  (* TODO *)
  let wlr_screenshooter_p = ptr void

  let wlr_screenshooter_create = foreign "wlr_screenshooter_create"
      (wl_display_p @-> returning wlr_screenshooter_p)

  let wlr_screenshooter_destroy = foreign "wlr_screenshooter_destroy"
      (wlr_screenshooter_p @-> returning void)

  (* wlr_primary_selection *)

  (* TODO *)
  let wlr_primary_selection_device_manager_p = ptr void

  let wlr_primary_selection_device_manager_create =
    foreign "wlr_primary_selection_device_manager_create"
      (wl_display_p @-> returning wlr_primary_selection_device_manager_p)

  let wlr_primary_selection_device_manager_destroy =
    foreign "wlr_primary_selection_device_manager_destroy"
      (wlr_primary_selection_device_manager_p @-> returning void)

  (* wlr_idle *)

  (* TODO *)
  let wlr_idle_p = ptr void

  let wlr_idle_create = foreign "wlr_idle_create"
      (wl_display_p @-> returning wlr_idle_p)

  let wlr_idle_destroy = foreign "wlr_idle_destroy"
      (wlr_idle_p @-> returning void)

  (* wlr_log *)

  (* TODO *)
  let log_callback_t = ptr void
  let log_importance_t = Log.importance

  let wlr_log_init = foreign "wlr_log_init"
      (log_importance_t @-> log_callback_t @-> returning void)
end
