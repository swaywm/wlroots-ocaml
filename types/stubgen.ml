let () =
  print_endline Wlroots_config.stubgen_prologue;
  Cstubs_structs.write_c Format.std_formatter
    (module Wlroots_types_f.Types.Make)
