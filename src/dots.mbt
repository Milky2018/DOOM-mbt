///|
// Dot system for 3D Pacman

///|
struct Dot {
  x : Double
  y : Double
  collected : Bool
}

///|
// Global dot storage
let dots : Array[Dot] = []

///|
// Initialize dots in the maze (place them in empty spaces)
fn init_dots() -> Unit {
  dots.clear()
  let map = get_map()
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      if map[y][x] == 0 { // Only place dots in empty spaces (not walls, ghost spawns, or player spawn)
        // Place dot in center of tile
        let dot_x = (x.to_double() + 0.5) * TILE_SIZE
        let dot_y = (y.to_double() + 0.5) * TILE_SIZE
        dots.push({ x: dot_x, y: dot_y, collected: false })
      }
    }
  }
}

///|
// Check if there's a dot at given position
fn get_dot_at(x : Double, y : Double, radius : Double) -> Int? {
  for i, dot in dots {
    if !dot.collected {
      let dx = dot.x - x
      let dy = dot.y - y
      let distance = (dx * dx + dy * dy).sqrt()
      if distance < radius {
        return Some(i)
      }
    }
  }
  None
}

///|
// Collect a dot
fn collect_dot(index : Int) -> Unit {
  if index < dots.length() {
    dots[index] = { ..dots[index], collected: true }
    @audio.play_audio("assets/coin.wav")
  }
}

///|
// Check if all dots have been collected
fn all_dots_collected() -> Bool {
  for dot in dots {
    if !dot.collected {
      return false
    }
  }
  return true
}

///|
// Check if player is near a dot and collect it
fn check_dot_collection() -> Unit {
  let collection_radius = 20.0 // Distance to collect dot
  match get_dot_at(player_state.x, player_state.y, collection_radius) {
    Some(index) => {
      collect_dot(index)
      // Check if all dots collected and advance level
      if all_dots_collected() {
        next_level()
        reset_level()
      }
    }
    None => ()
  }
}
