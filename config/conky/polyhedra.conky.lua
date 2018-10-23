require 'cairo'

scale = 2
Width = 1920*2
Height = 1080*2

function init_cairo()
  if conky_window == nil then
    return false
  end

  cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height)

  cr = cairo_create(cs)
  cairo_set_source_rgba(cr, 0.933,0.905,0.894,1)
  return true
end

function conky_main()
  if (not init_cairo()) then
    return
  end

  updatesPrSecond = 1/conky_info["update_interval"];
  t = conky_info["update_interval"]*(tonumber(conky_parse('${updates}')));
  period = 1;
  t = t;
  t=t/10;

  local volume = tonumber(conky_parse('${exec amixer sget Master | grep -oPm 1 [0-9]+% | grep -oP [0-9]+}'));
  local battery = tonumber(conky_parse('${exec acpi | grep -oPm 1 [0-9]+% | grep -oP [0-9]+}'));
  local brightness = tonumber(conky_parse('${exec light | grep -oP ^[0-9]+}'));
  
  local cy,radius = Height/2, Height/8;
  
  draw_tetrahedron(Width/4*1,cy,radius*.1+radius*.9*battery/100);
  draw_dodecahedron(Width/4*2,cy,radius*.1+radius*.9*brightness/100);
  draw_icosahedron(Width/4*3,cy,radius*.1+radius*.9*volume/100);
  
  cairo_destroy(cr);
  cairo_surface_destroy(cs);
  cr = nil;
end

function drawLine(x1,y1, x2,y2, size)
  cairo_set_line_width(cr, size);
  cairo_move_to(cr, x1,y1);
  cairo_line_to(cr, x2,y2);
  cairo_stroke(cr);
end
function drawPoint(x,y,size)
  cairo_arc(cr, x,y, size, 0, 2*math.pi);
  cairo_fill(cr);
end

function rotate_x(p, angle)
  local c = math.cos(angle);
  local s = math.sin(angle);
  matrix = {
    {1,0,0},
    {0,c,-s},
    {0,s, c}
  };

  return matrix_vector_product(matrix, p);
end
function rotate_y(p, angle)
  local c = math.cos(angle);
  local s = math.sin(angle);
  matrix = {
    { c, 0, s},
    { 0, 1, 0},
    {-s, 0, c}
  };

  return matrix_vector_product(matrix, p);
end
function rotate_z(p, angle)
  local c = math.cos(angle);
  local s = math.sin(angle);
  matrix = {
    {c,-s,0},
    {s,c,0},
    {0,0, 1}
  };
  return matrix_vector_product(matrix, p);
end

function matrix_vector_product(matrix, vector)
  local result = {}
  for i,row in pairs(matrix) do
    result[i] = 0;
    for j, v in pairs(vector) do
      result[i] = result[i] + row[j]*v;
    end
  end

  return result;
end

function draw_dodecahedron(cx, cy, radius)
  local pointSize = 10;
  local lineSize = 4;
  local q = 0.577350269;
  local t = 0.934172359;
  local y = 0.35682209;
  
-- (±1,  ±1,  ±1)
-- ( 0,  ±ϕ,  ±1/ϕ)
-- (±1/ϕ, 0,  ±ϕ)
-- (±ϕ,  ±1/ϕ, 0)

  local vertices = {
    { q, q, q},
    { q, q,-q},
    { q,-q, q},
    { q,-q,-q},
    {-q, q, q},
    {-q, q,-q},
    {-q,-q, q},
    {-q,-q,-q},

    { 0, t, y},
    { 0, t,-y},
    { 0,-t, y},
    { 0,-t,-y},

    { y, 0, t},
    { y, 0,-t},
    {-y, 0, t},
    {-y, 0,-t},

    { t, y, 0},
    { t,-y, 0},
    {-t, y, 0},
    {-t,-y, 0},

  };
  local edges = {
    {1,9},  {1,13}, {1,17},
    {2,10}, {2,14}, {2,17},
    {3,11}, {3,13}, {3,18},
    {4,12}, {4,14}, {4,18},
    {5,9},  {5,15}, {5,19},
    {6,10}, {6,16}, {6,19},
    {7,11}, {7,15}, {7,20},
    {8,12}, {8,16}, {8,20},
    
    {9,10},
    {11,12},
    
    {17,18},
    {19,20},
    
    {13,15},
    {14,16},
  };

  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6, 100);
end
function draw_tetrahedron(cx, cy, radius)
  local pointSize = 10;
  local lineSize = 4;
  local q = 0.57735026919; -- bound coordinates to the unit circle
  
  local vertices = {
    { q, q, q},
    { q,-q,-q},
    {-q, q,-q},
    {-q,-q, q}
  };
  local edges = {
    {1,2},
    {1,3},
    {1,4},
    {2,3},
    {3,4},
    {4,2}
  };

  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6, 200);
end
function draw_icosahedron(cx, cy, radius)
  local q = 0.5663; -- bound coordinates to the unit circle
  local w = 0.916320109; -- bound coordinates to the unit circle
  local vertices = {
    { 0, q, w},
    { q, w, 0},
    { w, 0, q},
    { 0,-q, w},
    {-q, w, 0},
    { w, 0,-q},
    { 0, q,-w},
    { q,-w, 0},
    {-w, 0, q},
    { 0,-q,-w},
    {-q,-w, 0},
    {-w, 0,-q}
  };
  local edges = {
    {1,2}, {2,3}, 
    {1,3}, {3,4}, 
    {1,4}, {4,9},
    {1,9}, {9,5},
    {1,5}, {5,2}, 

    {6,2},  {2, 3},
    {6,3},  {3, 8},
    {6,8},  {8, 10},
    {6,10}, {10, 7},
    {6,7},  {7, 2},

    {11,4},  {4,  8},
    {11,8},  {8,  10},
    {11,10}, {10, 12},
    {11,12}, {12, 9},
    {11,9},  {9,  4},

    {12,5},
    {12,7},
    {5,7},
  };
  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6,300);
end

function draw_mesh(x,y,vertices, edges, scale,r,g,b,timeOffset)
  local pointSize = 10*scale/(Height/8);  
  local lineSize = 4;

  for index,point in pairs(vertices) do
    point = rotate_x(point,(t+timeOffset)/2);
    point = rotate_y(point,(t+timeOffset)/3);
    point = rotate_z(point,(t+timeOffset)/5);
    vertices[index] = point;

    local shadeAmount = (point[3]>0 and 0 or -point[3]*.5);
    cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1-shadeAmount);
    -- cairo_set_source_rgba(cr, r/0xff, g/0xff, b/0xff, 1);

    drawPoint(x+point[1]*scale, y+point[2]*scale, pointSize);
  end

  for index,line in pairs(edges) do
    z = vertices[line[1]][3]+vertices[line[2]][3]/2;
    local shadeAmount = (z>0 and 0 or -z*.5);
    cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1-shadeAmount);
    -- cairo_set_source_rgba(cr, r/0xff, g/0xff, b/0xff, 1);

    drawLine(
      x+vertices[line[1]][1]*scale, y+vertices[line[1]][2]*scale,
      x+vertices[line[2]][1]*scale, y+vertices[line[2]][2]*scale,
      lineSize);
  end
end