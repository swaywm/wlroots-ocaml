#include <wayland-util.h>
#include <wlr/backend.h>
#include <wlr/types/wlr_compositor.h>

#define wlr_output_mode_of_link(link_ptr) \
  (wl_container_of(link_ptr, ((struct wlr_output_mode*) NULL), link))

#define wl_resource_of_link(link_ptr) \
  (wl_container_of(link_ptr, ((struct wl_resource*) NULL), link))
