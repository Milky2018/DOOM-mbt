///|
fn main {
  @system.App::new()
  .with_canvas_height(CANVAS_HEIGHT)
  .with_canvas_width(CANVAS_WIDTH)
  .add_system(player_input_system)
  .add_system(ghost_update_system) // Add ghost AI system
  .add_system(game_startup, schedule=Startup)
  .add_system(@inputs.advanced_mouse_system)
  .add_system(render_3d_system, schedule=Render(0))
  .add_system(render_map_system, schedule=Render(-1))
  .add_system(render_ui_system, schedule=Render(-2))
  .run()
}

///|
fn game_startup(_delta : Double) -> Unit {
  reset_level()
  @system.lock_mouse()
}
