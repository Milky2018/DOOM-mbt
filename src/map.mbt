///|
const CANVAS_WIDTH = 640.0

///|
const CANVAS_HEIGHT = 480.0

///|
const TILE_SIZE = 64.0

///|
fn get_map() -> Level {
  levels[current_level.val]
}

///|
fn is_wall(x : Double, y : Double) -> Bool {
  // Convert world coordinates to map coordinates
  let map_x = (x / TILE_SIZE).floor().to_int()
  let map_y = (y / TILE_SIZE).floor().to_int()
  let map = get_map()

  // Check bounds
  if map_x < 0 || map_x >= map[0].length() || map_y < 0 || map_y >= map.length() {
    return true
  }
  // Only walls (1) are solid, empty spaces (0), ghost spawns (2), and player spawn (3) are walkable
  return map[map_y][map_x] == 1
}

///|
// Small level for easier gameplay
// 0 = empty space, 1 = wall, 2 = ghost spawn point, 3 = player spawn point
let level1 = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 3, 0, 0, 1, 0, 0, 0, 1],
  [1, 0, 1, 2, 0, 2, 1, 0, 1],
  [1, 0, 0, 0, 1, 0, 0, 0, 1],
  [1, 1, 0, 0, 0, 0, 0, 1, 1],
  [1, 0, 0, 0, 1, 0, 0, 0, 1],
  [1, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 1, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1],
]

///|
// Original large level
let level2 = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1],
  [1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 0, 1, 2, 1, 0, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 1, 0, 2, 1, 2, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 0, 1, 2, 1, 0, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1],
  [1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1],
  [1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1],
  [1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
]

///|
// Level progression system
let current_level : Ref[Int] = Ref::new(1)

///|
let levels : Array[Level] = [level1, level2]

///|
typealias Array[Array[Int]] as Level

///|
fn next_level() -> Unit {
  current_level.val = current_level.val + 1
  if current_level.val >= levels.length() {
    current_level.val = 0 // Back to level 1 after completing all levels
  }
}

///|
fn reset_level() -> Unit {
  init_dots()
  init_ghosts()
  init_player()
}
