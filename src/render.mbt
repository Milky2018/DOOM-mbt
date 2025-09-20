///|
fn render_3d_system(backend : &@system.Backend) -> Unit {
  let rays = cast_all_rays()
  let wall_height = 64.0
  let distance_scale = 1000.0
  backend.draw_gradient_rect(
    x=0,
    y=0,
    width=CANVAS_WIDTH,
    height=CANVAS_HEIGHT / 2,
    color_start="#2A2A2A",
    color_end="#1E1E1E",
  )
  backend.draw_gradient_rect(
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
      let world_y_offset = (segment.to_double() * wall_world_height / num_segments.to_double())
      let texture_y = (world_y_offset * texture_y_scale).to_int() % texture.height

      let texture_color = get_texture_pixel(texture, texture_x, texture_y)

      // Apply distance-based shading
      let shading_factor = @cmp.maximum(0.3, 1.0 - ray.distance / 400.0)

      // Apply side-based shading (vertical walls slightly darker)
      let side_factor = if ray.side is Vertical { 1.0 } else { 0.8 }
      let final_shading = shading_factor * side_factor

      // Parse and apply shading to texture color
      let r = (try! (@strconv.parse_int(texture_color[1:3].to_string(), base=16).to_double() * final_shading)).to_int()
      let g = (try! (@strconv.parse_int(texture_color[3:5].to_string(), base=16).to_double() * final_shading)).to_int()
      let b = (try! (@strconv.parse_int(texture_color[5:7].to_string(), base=16).to_double() * final_shading)).to_int()
      let shaded_color = "rgb(\{r}, \{g}, \{b})"

      backend.draw_color_rect(
        x=strip_x,
        y=segment_y,
        width=strip_width + 1,
        height=segment_height + 1, // Add 1 to avoid gaps
        color=shaded_color,
      )
    }
  }
}

///|
fn render_map_system(backend : &@system.Backend) -> Unit {
  let scale = 4.0
  let offset_x = 10.0
  let offset_y = 10.0
  for y in 0..<map.length() {
    for x in 0..<map[y].length() {
      let cell_x = offset_x + x.to_double() * scale
      let cell_y = offset_y + y.to_double() * scale
      if map[y][x] == 1 {
        backend.draw_color_rect(
          x=cell_x,
          y=cell_y,
          width=scale,
          height=scale,
          color="#8B4513",
        )
      } else {
        backend.draw_color_rect(
          x=cell_x,
          y=cell_y,
          width=scale,
          height=scale,
          color="#333333",
        )
      }
    }
  }
}
