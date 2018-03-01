let prologue = "
#define _POSIX_C_SOURCE 200809L
#include <wayland-server.h>
#include <wlr/backend.h>
#include <wlr/render.h>
#include <wlr/render/matrix.h>
#include <wlr/types/wlr_compositor.h>
#include <wlr/types/wlr_gamma_control.h>
#include <wlr/types/wlr_idle.h>
#include <wlr/types/wlr_primary_selection.h>
#include <wlr/types/wlr_screenshooter.h>
#include <wlr/types/wlr_xdg_shell_v6.h>
#include <wlr/util/log.h>
"

let () =
  print_endline prologue;
  Cstubs_structs.write_c Format.std_formatter
    (module Bindings_structs_lib.Bindings_structs.Make)
