///|
struct PlayerState {
  mut x : Double
  mut y : Double
  mut angle : Double
}

///|
let player_state : PlayerState = {
  x: 1.5 * TILE_SIZE,
  y: 1.5 * TILE_SIZE,
  angle: 0.0,
}

///|
const SPEED = 2.0

///|
const PLAYER_RADIUS = 16.0

///|
fn player_input_system(_backend : &@system.Backend) -> Unit {
  let mut move_x = 0.0
  let mut move_y = 0.0
  if @system.is_pressed(KeyW) {
    move_x += @math.cos(player_state.angle) * SPEED
    move_y += @math.sin(player_state.angle) * SPEED
  }
  if @system.is_pressed(KeyS) {
    move_x -= @math.cos(player_state.angle) * SPEED
    move_y -= @math.sin(player_state.angle) * SPEED
  }
  if @system.is_pressed(KeyA) {
    move_x += @math.cos(player_state.angle - @math.PI / 2) * SPEED
    move_y += @math.sin(player_state.angle - @math.PI / 2) * SPEED
  }
  if @system.is_pressed(KeyD) {
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
  if @system.is_mouse_locked() {
    let sensitivity = 0.002
    let angle = player_state.angle + @system.mouse_movement.movement[X] * sensitivity
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
