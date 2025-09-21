///|
fn main {
  init_dots() // Initialize dots in the maze
  @system.App::new(@canvas.CanvasBackend::new())
  .with_canvas_height(CANVAS_HEIGHT)
  .with_canvas_width(CANVAS_WIDTH)
  .add_plugin(@plugins.debug_plugin)
  .add_system(player_input_system)
  .add_system(@system.lock_mouse, schedule=Startup)
  .add_system(@system.advanced_mouse_system)
  .add_system(render_3d_system, schedule=Render(0))
  .add_system(render_map_system, schedule=Render(-1))
  .run()
}
