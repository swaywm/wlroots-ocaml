let prefix = "wlroots_stub"

let prologue = "
#define _POSIX_C_SOURCE 200809L
#include <wayland-server.h>
#include <wlr/render/wlr_renderer.h>
#include <wlr/types/wlr_cursor.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_data_device.h>
#include <wlr/types/wlr_input_device.h>
#include <wlr/types/wlr_keyboard.h>
#include <wlr/types/wlr_matrix.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_output_layout.h>
#include <wlr/types/wlr_pointer.h>
#include <wlr/types/wlr_seat.h>
#include <wlr/types/wlr_xcursor_manager.h>
// #include <wlr/types/wlr_xdg_shell.h>
#include <wlr/util/log.h>
"

let () =
  let generate_ml, generate_c = ref false, ref false in
  let () =
    Arg.(parse [ ("-ml", Set generate_ml, "Generate ML");
                 ("-c", Set generate_c, "Generate C") ])
      (fun _ -> failwith "unexpected anonymous argument")
      "stubgen [-ml|-c]"
  in
  match !generate_ml, !generate_c with
  | false, false
  | true, true ->
    failwith "Exactly one of -ml and -c must be specified"
  | true, false ->
    Cstubs.write_ml Format.std_formatter ~prefix (module Wlroots_ffi_f.Ffi.Make)
  | false, true ->
    print_endline prologue;
    Cstubs.write_c Format.std_formatter ~prefix (module Wlroots_ffi_f.Ffi.Make)
