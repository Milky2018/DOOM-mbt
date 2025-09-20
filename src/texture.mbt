///|
// Simple texture system for wall textures

///|
struct TextureData {
  width : Int
  height : Int
  pixels : Array[String] // Array of hex color strings
}

///|
// Create a simple brick texture pattern
fn create_brick_texture() -> TextureData {
  let width = 64
  let height = 64
  let pixels = []
  for y in 0..<height {
    for x in 0..<width {
      // Create a brick pattern
      // let brick_y = y % 8
      // let is_mortar_y = brick_y == 0 || brick_y == 7

      // Offset every other row of bricks
      // let offset = if y / 8 % 2 == 1 { 8 } else { 0 }
      // let adjusted_x = (x + offset) % 16
      // let is_mortar_x_offset = adjusted_x == 0 || adjusted_x == 15

      // let color = if is_mortar_y || is_mortar_x_offset {
      //   "#666666" // Mortar color
      // } else {
      //   // Vary brick color slightly
      //   let variation = (x + y) % 3
      //   match variation {
      //     0 => "#8B4513" // Standard brown
      //     1 => "#A0522D" // Sienna
      //     _ => "#CD853F" // Sandy brown
      //   }
      // }
      let variation = (x + y) % 3
      let color = match variation {
        0 => "#8B4513" // Standard brown
        1 => "#A0522D" // Sienna
        _ => "#CD853F" // Sandy brown
      }
      pixels.push(color)
    }
  }
  { width, height, pixels }
}

///|
// Create a stone texture pattern
fn create_stone_texture() -> TextureData {
  let width = 64
  let height = 64
  let pixels = []
  for y in 0..<height {
    for x in 0..<width {
      // Create a stone pattern with random-like variation
      let seed = x * 31 + y * 17
      let noise = seed % 100
      let base_color = if noise < 20 {
        "#708090" // Slate gray
      } else if noise < 40 {
        "#778899" // Light slate gray
      } else if noise < 60 {
        "#696969" // Dim gray
      } else if noise < 80 {
        "#808080" // Gray
      } else {
        "#A9A9A9" // Dark gray
      }
      pixels.push(base_color)
    }
  }
  { width, height, pixels }
}

///|
// Global texture storage
let brick_texture : TextureData = create_brick_texture()

///|
let stone_texture : TextureData = create_stone_texture()

///|
// Get texture pixel color at specific coordinates
fn get_texture_pixel(texture : TextureData, x : Int, y : Int) -> String {
  let wrapped_x = x % texture.width
  let wrapped_y = y % texture.height
  let index = wrapped_y * texture.width + wrapped_x
  texture.pixels[index]
}

///|
// Get texture based on wall type (can be extended for different wall types)
fn get_wall_texture(wall_type : Int) -> TextureData {
  match wall_type {
    1 => brick_texture
    _ => stone_texture
  }
}
