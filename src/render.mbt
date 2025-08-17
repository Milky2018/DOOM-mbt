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
    let wall_color = if ray.side is Vertical {
      "#8B4513" // Brown for vertical walls
    } else {
      "#654321" // Darker brown for horizontal walls
    }
    let shading_factor = @cmp.maximum(0.3, 1 - ray.distance / 400)
    let r = (try! (@strconv.parse_int(wall_color[1:3].to_string(), base=16).to_double() *
    shading_factor)).to_int()
    let g = (try! (@strconv.parse_int(wall_color[3:5].to_string(), base=16).to_double() *
    shading_factor)).to_int()
    let b = (try! (@strconv.parse_int(wall_color[5:7].to_string(), base=16).to_double() *
    shading_factor)).to_int()
    let rgb = "rgb(\{r}, \{g}, \{b})"
    backend.draw_color_rect(
      x=strip_x,
      y=wall_top,
      width=strip_width + 1,
      height=wall_height,
      color=rgb,
    )
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
