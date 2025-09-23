///|
struct PlayerState {
  mut x : Double
  mut y : Double
  mut angle : Double
}

///|
// Initialize player at spawn point (will be set by init_player)
let player_state : PlayerState = {
  x: 0.0,
  y: 0.0,
  angle: 0.0,
}

///|
// Initialize player at spawn point from map
fn init_player() -> Unit {
  let map = get_map()
  // Find player spawn point (value 3) in the map
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      if map[y][x] == 3 { // Player spawn point
        player_state.x = (x.to_double() + 0.5) * TILE_SIZE
        player_state.y = (y.to_double() + 0.5) * TILE_SIZE
        player_state.angle = 0.0
        return // Found spawn point, exit
      }
    }
  }
  // Fallback if no spawn point found
  player_state.x = 1.5 * TILE_SIZE
  player_state.y = 1.5 * TILE_SIZE
  player_state.angle = 0.0
}

///|
const SPEED = 2.0

///|
const PLAYER_RADIUS = 16.0

///|
fn player_input_system(_delta : Double) -> Unit {
  let mut move_x = 0.0
  let mut move_y = 0.0
  if @inputs.is_pressed(KeyW) {
    move_x += @math.cos(player_state.angle) * SPEED
    move_y += @math.sin(player_state.angle) * SPEED
  }
  if @inputs.is_pressed(KeyS) {
    move_x -= @math.cos(player_state.angle) * SPEED
    move_y -= @math.sin(player_state.angle) * SPEED
  }
  if @inputs.is_pressed(KeyA) {
    move_x += @math.cos(player_state.angle - @math.PI / 2) * SPEED
    move_y += @math.sin(player_state.angle - @math.PI / 2) * SPEED
  }
  if @inputs.is_pressed(KeyD) {
    move_x += @math.cos(player_state.angle + @math.PI / 2) * SPEED
    move_y += @math.sin(player_state.angle + @math.PI / 2) * SPEED
  }
  let new_x = player_state.x + move_x
  let new_y = player_state.y + move_y
  if can_move_to(new_x, player_state.y) {
    player_state.x = new_x
  }
  if can_move_to(player_state.x, new_y) {
    player_state.y = new_y
  }

  // Check for dot collection after movement
  check_dot_collection()

  // Check for ghost collision - reset entire level if collision detected
  if check_ghost_collision() {
    @audio.play_audio("assets/game_over.wav")
    // Reset the entire level (dots, ghosts, and player)
    reset_level()
  }

  if @system.is_mouse_locked() {
    let sensitivity = 0.002
    let angle = player_state.angle + @inputs.mouse_movement.movement[X] * sensitivity
    player_state.angle = @smath.normalize_angle(angle)
  }
}

///|
fn can_move_to(x : Double, y : Double) -> Bool {
  let radius = PLAYER_RADIUS
  let corners = [
    (x - radius, y - radius), // top-left
    (x + radius, y - radius), // top-right
    (x - radius, y + radius), // bottom-left
    (x + radius, y + radius), // bottom-right
  ]
  for corner_x_y in corners {
    if is_wall(corner_x_y.0, corner_x_y.1) {
      return false
    }
  }
  return true
}
