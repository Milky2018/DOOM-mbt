///|
const MAX_DEPTH = 800.0

///|
const DOT_RADIUS = 4.0

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

  // Calculate wall hit coordinate for texture mapping
  let wall_hit_x = start_x + perp_wall_dist * ray_dir_x
  let wall_hit_y = start_y + perp_wall_dist * ray_dir_y

  // Use the appropriate coordinate based on wall side for texture mapping
  let wall_x = match side {
    Vertical => wall_hit_y / TILE_SIZE // Use Y coordinate for vertical walls
    Horizontal => wall_hit_x / TILE_SIZE // Use X coordinate for horizontal walls
  }
  // Get fractional part for texture coordinate
  let wall_x = wall_x - wall_x.floor()
  let hit_dots = []

  // Check each dot to see if ray passes close to it
  for _i, dot in dots {
    if !dot.collected {
      // Calculate dot distance from player
      let dot_dx = dot.x - start_x
      let dot_dy = dot.y - start_y
      let dot_distance = (dot_dx * dot_dx + dot_dy * dot_dy).sqrt()

      // Check if dot is roughly in the same direction as the ray
      let dot_angle = @math.atan2(dot_dy, dot_dx)
      let view_angle = @math.atan2(DOT_RADIUS, dot_distance)
      let angle_diff = (dot_angle - angle).abs()
      let angle_diff = @cmp.minimum(angle_diff, @math.PI * 2 - angle_diff)

      // If dot is close to ray direction and closer than wall
      if angle_diff < view_angle && dot_distance < distance {
        hit_dots.push((dot_distance, angle_diff))
      }
    }
  }
  let hit_ghosts = []

  // Check each ghost to see if ray passes close to it
  for i, ghost in ghosts {
    // Calculate ghost distance from player
    let ghost_dx = ghost.x - start_x
    let ghost_dy = ghost.y - start_y
    let ghost_distance = (ghost_dx * ghost_dx + ghost_dy * ghost_dy).sqrt()

    // Check if ghost is roughly in the same direction as the ray
    let ghost_angle = @math.atan2(ghost_dy, ghost_dx)
    let view_angle = @math.atan2(GHOST_RADIUS, ghost_distance)
    let angle_diff = (ghost_angle - angle).abs()
    let angle_diff = @cmp.minimum(angle_diff, @math.PI * 2.0 - angle_diff)

    // If ghost is close to ray direction and closer than wall
    if angle_diff < view_angle && ghost_distance < distance {
      hit_ghosts.push((i, ghost_distance, angle_diff))
    }
  }
  { distance, side, wall_x, hit_dots, hit_ghosts }
}

///|
struct Ray {
  distance : Double
  side : Side
  wall_x : Double // X coordinate where ray hit the wall (for texture mapping)
  hit_dots : Array[(Double, Double)] // Distance to a dot
  hit_ghosts : Array[(Int, Double, Double)] // (ghost_index, distance, angle_diff)
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
    let ray_angle = @smath.normalize_angle(
      player_state.angle - FOV / 2 + i.to_double() * angle_step,
    )

    // Cast the ray
    let ray_info = cast_ray(ray_angle)

    // Fix fisheye effect by multiplying with cos of angle difference
    let angle_diff = ray_angle - player_state.angle
    rays.push({
      distance: ray_info.distance * @math.cos(angle_diff),
      side: ray_info.side,
      wall_x: ray_info.wall_x,
      hit_dots: ray_info.hit_dots,
      hit_ghosts: ray_info.hit_ghosts,
    })
  }
  rays
}
