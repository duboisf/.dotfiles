-- Use OSC 52 so kitty writes the system clipboard directly. Avoids wl-copy,
-- which on GNOME spawns a transient toplevel to satisfy wl_data_device_manager
-- and steals focus, causing tiling-extension reflows.
vim.g.clipboard = 'osc52'
