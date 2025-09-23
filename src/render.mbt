///|
fn render_3d_system(_delta : Double) -> Unit {
  let rays = cast_all_rays()
  let wall_height = 64.0
  let distance_scale = 1000.0
  @backend.draw_gradient_rect(
    x=0,
    y=0,
    width=CANVAS_WIDTH,
    height=CANVAS_HEIGHT / 2,
    color_start="#2A2A2A",
    color_end="#1E1E1E",
  )
  @backend.draw_gradient_rect(
    x=0,
    y=CANVAS_HEIGHT / 2,
    width=CANVAS_WIDTH,
    height=CANVAS_HEIGHT / 2,
    color_start="#2F4F2F",
    color_end="#1A3A1A",
  )
  let strip_width = CANVAS_WIDTH / rays.length().to_double()
  for i, ray in rays {
    let wall_height = wall_height * distance_scale / ray.distance
    let wall_top = (CANVAS_HEIGHT - wall_height) / 2
    let strip_x = i.to_double() * strip_width

    // Get texture for this wall (assuming all walls are type 1 for now)
    let texture = get_wall_texture(1)

    // Calculate texture X coordinate - use a fixed value to remove horizontal variation
    let texture_x = 32 // Fixed X coordinate - no horizontal texture movement

    // Sample just a few points and draw larger blocks for performance
    let num_segments = 16 // Only 16 texture samples per wall strip
    let segment_height = wall_height / num_segments.to_double()

    // Calculate world Y position for texture mapping
    let wall_world_height = 64.0 // Standard wall height in world units
    let texture_y_scale = texture.height.to_double() / wall_world_height
    for segment in 0..<num_segments {
      let segment_y = wall_top + segment.to_double() * segment_height

      // Calculate texture Y based on world position, not screen position
      let world_y_offset = segment.to_double() *
        wall_world_height /
        num_segments.to_double()
      let texture_y = (world_y_offset * texture_y_scale).to_int() %
        texture.height
      let texture_color = get_texture_pixel(texture, texture_x, texture_y)

      // Apply distance-based shading
      let shading_factor = @cmp.maximum(0.3, 1.0 - ray.distance / 400.0)

      // Apply side-based shading (vertical walls slightly darker)
      let side_factor = if ray.side is Vertical { 1.0 } else { 0.8 }
      let final_shading = shading_factor * side_factor

      // Parse and apply shading to texture color
      let r = (try! (@strconv.parse_int(texture_color[1:3].to_string(), base=16).to_double() *
      final_shading)).to_int()
      let g = (try! (@strconv.parse_int(texture_color[3:5].to_string(), base=16).to_double() *
      final_shading)).to_int()
      let b = (try! (@strconv.parse_int(texture_color[5:7].to_string(), base=16).to_double() *
      final_shading)).to_int()
      let shaded_color = "rgb(\{r}, \{g}, \{b})"
      @backend.draw_color_rect(
        x=strip_x,
        y=segment_y,
        width=strip_width + 1,
        height=segment_height + 1, // Add 1 to avoid gaps
        color=shaded_color,
      )
    }
  }

  // Render dots that were hit by rays
  for i, ray in rays {
    for dot in ray.hit_dots {
      let (distance, angle_diff) = dot
      let strip_x = i.to_double() * strip_width
      let center_x = strip_x + (strip_width + 1) / 2.0
      let x = distance * @math.tan(angle_diff)
      let h = (DOT_RADIUS * DOT_RADIUS - x * x).sqrt()
      let dot_height = h * 1.3 * distance_scale / distance
      let y_offset = 24.0 * distance_scale / distance
      let dot_top = (CANVAS_HEIGHT - dot_height + y_offset) / 2
      @backend.draw_color_rect(
        x=center_x,
        y=dot_top,
        width=strip_width + 1,
        height=dot_height,
        color="#FFFF00",
      )
    }
  }

  // Render ghosts that were hit by rays
  for i, ray in rays {
    for ghost_hit in ray.hit_ghosts {
      let (ghost_index, distance, angle_diff) = ghost_hit
      let strip_x = i.to_double() * strip_width
      let center_x = strip_x + (strip_width + 1) / 2.0
      let x = distance * @math.tan(angle_diff)
      let h = (GHOST_RADIUS * GHOST_RADIUS - x * x).sqrt()
      let ghost_height = h * 1.3 * distance_scale / distance
      let ghost_top = (CANVAS_HEIGHT - ghost_height) / 2

      // Get ghost color
      let ghost_color = ghosts[ghost_index].color

      // Draw ghost as colored rectangle
      @backend.draw_color_rect(
        x=center_x - (strip_width + 1) / 2.0,
        y=ghost_top,
        width=strip_width + 1,
        height=ghost_height,
        color=ghost_color,
      )
    }
  }
}

///|
fn render_map_system(_delta : Double) -> Unit {
  let scale = 4.0
  let offset_x = 10.0
  let offset_y = 10.0
  let map = get_map()

  // Draw map tiles
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      let cell_x = offset_x + x.to_double() * scale
      let cell_y = offset_y + y.to_double() * scale
      if map[y][x] == 1 {
        // Wall
        @backend.draw_color_rect(
          x=cell_x,
          y=cell_y,
          width=scale,
          height=scale,
          color="#8B4513",
        )
      } else {
        // Empty space
        @backend.draw_color_rect(
          x=cell_x,
          y=cell_y,
          width=scale,
          height=scale,
          color="#333333",
        )
      }
    }
  }

  // Draw dots on the map
  for dot in dots {
    if !dot.collected {
      let dot_map_x = offset_x + dot.x / TILE_SIZE * scale
      let dot_map_y = offset_y + dot.y / TILE_SIZE * scale
      @backend.draw_color_rect(
        x=dot_map_x - 1.0,
        y=dot_map_y - 1.0,
        width=2.0,
        height=2.0,
        color="#FFFF00", // Yellow dots
      )
    }
  }

  // Draw player position as red dot
  let player_map_x = offset_x + player_state.x / TILE_SIZE * scale
  let player_map_y = offset_y + player_state.y / TILE_SIZE * scale
  @backend.draw_color_rect(
    x=player_map_x - 2.0,
    y=player_map_y - 2.0,
    width=4.0,
    height=4.0,
    color="#00FF00", // Red dot for player
  )

  // Draw ghosts on minimap
  for ghost in ghosts {
    let ghost_map_x = offset_x + ghost.x / TILE_SIZE * scale
    let ghost_map_y = offset_y + ghost.y / TILE_SIZE * scale
    @backend.draw_color_rect(
      x=ghost_map_x - 1.5,
      y=ghost_map_y - 1.5,
      width=3.0,
      height=3.0,
      color=ghost.color, // Use ghost's color
    )
  }
}
