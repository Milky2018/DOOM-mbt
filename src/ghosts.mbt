///|
// Ghost system for 3D Pacman

///|
enum Direction {
  Up
  Down
  Left
  Right
}

///|
struct Ghost {
  mut x : Double
  mut y : Double
  mut direction : Direction
  mut move_timer : Double
  color : String
}

///|
// Global ghost storage
let ghosts : Array[Ghost] = []

///|
const GHOST_SPEED = 1.5

///|
const GHOST_SIZE = 20.0

///|
const DIRECTION_CHANGE_TIME = 60.0 // Change direction every 60 frames

///|
// Initialize ghosts in the maze based on map data
fn init_ghosts() -> Unit {
  ghosts.clear()
  let map = get_map()

  // Find ghost spawn points (value 2) in the map
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      if map[y][x] == 2 { // Ghost spawn point
        let spawn_x = (x.to_double() + 0.5) * TILE_SIZE
        let spawn_y = (y.to_double() + 0.5) * TILE_SIZE
        ghosts.push({
          x: spawn_x,
          y: spawn_y,
          direction: get_random_direction(),
          move_timer: 0.0,
          color: "#FF0000",
        })
      }
    }
  }
}

///|
// Get random direction using a simple pseudo-random generator
fn get_random_direction() -> Direction {
  // Use player position for randomness
  let seed = (player_state.x + player_state.y).to_int()
  let random = (seed * 1103515245 + 12345) % 4
  match random {
    0 => Up
    1 => Down
    2 => Left
    _ => Right
  }
}

///|
// Check if ghost can move to position
fn ghost_can_move_to(x : Double, y : Double) -> Bool {
  let radius = GHOST_SIZE / 2.0

  // Check four corners around the ghost
  if is_wall(x - radius, y - radius) {
    return false
  }
  if is_wall(x + radius, y - radius) {
    return false
  }
  if is_wall(x - radius, y + radius) {
    return false
  }
  if is_wall(x + radius, y + radius) {
    return false
  }
  true
}

///|
// Update ghost AI and movement
fn update_ghosts() -> Unit {
  for ghost in ghosts {
    ghost.move_timer += 1.0

    // Change direction randomly or when hitting wall
    if ghost.move_timer > DIRECTION_CHANGE_TIME {
      ghost.direction = get_random_direction()
      ghost.move_timer = 0.0
    }

    // Calculate movement based on direction
    let mut dx = 0.0
    let mut dy = 0.0
    match ghost.direction {
      Up => dy = -GHOST_SPEED
      Down => dy = GHOST_SPEED
      Left => dx = -GHOST_SPEED
      Right => dx = GHOST_SPEED
    }
    let new_x = ghost.x + dx
    let new_y = ghost.y + dy

    // Check if ghost can move in current direction
    if ghost_can_move_to(new_x, new_y) {
      ghost.x = new_x
      ghost.y = new_y
    } else {
      // Hit a wall, change direction immediately
      ghost.direction = get_random_direction()
      ghost.move_timer = 0.0
    }
  }
}

///|
// Check collision between player and ghosts
fn check_ghost_collision() -> Bool {
  let player_x = player_state.x
  let player_y = player_state.y
  let collision_distance = PLAYER_RADIUS + GHOST_SIZE / 2.0
  for ghost in ghosts {
    let dx = ghost.x - player_x
    let dy = ghost.y - player_y
    let distance = (dx * dx + dy * dy).sqrt()
    if distance < collision_distance {
      return true // Collision detected!
    }
  }
  false
}

///|
// Ghost update system for the main game loop
fn ghost_update_system(_delta : Double) -> Unit {
  update_ghosts()
}
