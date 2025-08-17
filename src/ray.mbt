///|
const MAX_DEPTH = 800.0

///|
enum Side {
  Vertical
  Horizontal
}

///|
fn cast_ray(angle : Double) -> Ray {
  let start_x = player_state.x
  let start_y = player_state.y

  // Ray direction
  let ray_dir_x = @math.cos(angle)
  let ray_dir_y = @math.sin(angle)

  // Step size for DDA algorithm
  let delta_dist_x = if ray_dir_x != 0.0 {
    (1.0 / ray_dir_x).abs()
  } else {
    @double.infinity
  }
  let delta_dist_y = if ray_dir_y != 0.0 {
    (1.0 / ray_dir_y).abs()
  } else {
    @double.infinity
  }

  // Current position in map coordinates
  let mut map_x = (start_x / TILE_SIZE).floor()
  let mut map_y = (start_y / TILE_SIZE).floor()
  let step_x = if ray_dir_x < 0.0 { -1.0 } else { 1.0 }
  let step_y = if ray_dir_y < 0.0 { -1.0 } else { 1.0 }
  let mut side_dist_x = if ray_dir_x < 0.0 {
    (start_x / TILE_SIZE - map_x) * delta_dist_x
  } else {
    (map_x + 1.0 - start_x / TILE_SIZE) * delta_dist_x
  }
  let mut side_dist_y = if ray_dir_y < 0.0 {
    (start_y / TILE_SIZE - map_y) * delta_dist_y
  } else {
    (map_y + 1.0 - start_y / TILE_SIZE) * delta_dist_y
  }

  // Perform DDA
  let mut hit = false
  let mut side = Vertical
  while !hit {
    // Jump to next map square, either in x-direction or in y-direction
    if side_dist_x < side_dist_y {
      side_dist_x += delta_dist_x
      map_x += step_x
      side = Vertical
    } else {
      side_dist_y += delta_dist_y
      map_y += step_y
      side = Horizontal
    }

    // Check if ray has hit a wall
    if is_wall(map_x * TILE_SIZE, map_y * TILE_SIZE) {
      hit = true
    }

    // Safety check to prevent infinite loops
    if (map_x - start_x / TILE_SIZE).abs() > MAX_DEPTH / TILE_SIZE ||
      (map_y - start_y / TILE_SIZE).abs() > MAX_DEPTH / TILE_SIZE {
      break
    }
  }

  // Calculate distance
  let perp_wall_dist = match side {
    Vertical => (map_x - start_x / TILE_SIZE + (1 - step_x) / 2) / ray_dir_x
    Horizontal => (map_y - start_y / TILE_SIZE + (1 - step_y) / 2) / ray_dir_y
  }

  // Convert back to pixel distance
  let distance = perp_wall_dist * TILE_SIZE
  { distance, side }
}

///|
struct Ray {
  distance : Double
  side : Side
}

///|
const FOV : Double = @math.PI / 3.0 // 60 degrees

///|
fn cast_all_rays() -> Array[Ray] {
  let rays = []
  let num_rays = (CANVAS_WIDTH / 2).to_int() // Assuming each ray takes 2 pixels
  let angle_step = FOV / num_rays.to_double()
  for i in 0..<num_rays {
    // Calculate ray angle
    let ray_angle = player_state.angle - FOV / 2 + i.to_double() * angle_step

    // Cast the ray
    let ray_info = cast_ray(ray_angle)

    // Fix fisheye effect by multiplying with cos of angle difference
    let angle_diff = ray_angle - player_state.angle
    rays.push({
      distance: ray_info.distance * @math.cos(angle_diff),
      side: ray_info.side,
    })
  }
  rays
}
