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
enum GhostType {
  Fast // Red ghost - faster than normal
  Normal // Orange ghost - normal speed
  Slow // Blue ghost - slower but more unpredictable
}

///|
struct Ghost {
  mut x : Double
  mut y : Double
  mut direction : Direction
  ghost_type : GhostType
  color : String
}

///|
// Global ghost storage
let ghosts : Array[Ghost] = []

///|
const BASE_GHOST_SPEED = 1.6

///|
const GHOST_RADIUS = 20.0

///|
// Get ghost speed based on type and level
fn get_ghost_speed(ghost_type : GhostType) -> Double {
  let base_speed = BASE_GHOST_SPEED + current_level.val.to_double() * 0.3
  match ghost_type {
    Fast => base_speed * 1.5 // 50% faster
    Normal => base_speed // Normal speed
    Slow => base_speed * 0.7 // 30% slower
  }
}

///|
// Get ghost type and color based on map value
fn get_ghost_type_from_map(map_value : Int) -> (GhostType, String) {
  match map_value {
    3 => (Fast, "#FF0000") // Red fast ghost
    4 => (Normal, "#FFA500") // Orange normal ghost
    5 => (Slow, "#0000FF") // Blue slow ghost
    _ => (Normal, "#FFA500") // Default to normal
  }
}

///|
// Initialize ghosts in the maze based on map data
fn init_ghosts() -> Unit {
  ghosts.clear()
  let map = get_map()

  // Find ghost spawn points (values 3, 4, 5) in the map
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      if map[y][x] == 3 || map[y][x] == 4 || map[y][x] == 5 { // Ghost spawn points
        let spawn_x = (x.to_double() + 0.5) * TILE_SIZE
        let spawn_y = (y.to_double() + 0.5) * TILE_SIZE
        let (ghost_type, color) = get_ghost_type_from_map(map[y][x])
        ghosts.push({
          x: spawn_x,
          y: spawn_y,
          direction: get_random_direction(),
          ghost_type,
          color,
        })
      }
    }
  }
}

///|
let rand : @random.Rand = @random.Rand::new()

///|
// Get random direction using a simple pseudo-random generator
fn get_random_direction() -> Direction {
  // Use player position for randomness
  let random = rand.int() % 4
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
  let radius = GHOST_RADIUS

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
    // Calculate movement based on direction and ghost type
    let ghost_speed = get_ghost_speed(ghost.ghost_type)
    let mut dx = 0.0
    let mut dy = 0.0
    match ghost.direction {
      Up => dy = -ghost_speed
      Down => dy = ghost_speed
      Left => dx = -ghost_speed
      Right => dx = ghost_speed
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
    }
  }
}

///|
// Check collision between player and ghosts
fn check_ghost_collision() -> Bool {
  let player_x = player_state.x
  let player_y = player_state.y
  let collision_distance = PLAYER_RADIUS + GHOST_RADIUS
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
