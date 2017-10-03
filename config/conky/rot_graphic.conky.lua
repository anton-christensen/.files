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

  font = "Inconsolata"

  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
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
-- TIME
  -- cairo_set_font_size(cr, 130)
  -- cairo_move_to(cr, 644, 230)
  -- cairo_show_text(cr, conky_parse("${time %H:%M}"))
  -- cairo_stroke(cr)
  
  -- DATE
  -- cairo_set_font_size(cr, 27)
  -- cairo_move_to(cr, 664, 280)
  -- local time_str = string.format('%-12s', conky_parse("${time %A,}"))..conky_parse("${time %d.%m.%Y}")
  -- cairo_show_text(cr, time_str)
  -- cairo_stroke(cr)

  local volume = tonumber(conky_parse('${exec amixer sget Master | grep -oPm 1 [0-9]+% | grep -oP [0-9]+}'));
  local battery = tonumber(conky_parse('${exec acpi | grep -oPm 1 [0-9]+% | grep -oP [0-9]+}'));
  
  local cx,cy,radius = Width/4*3, Height/2, Height/8;
  -- draw_sphere(Width/4*1,cy,radius);
  draw_tetrahedron(Width/4*1,cy,radius*.1+radius*.9*battery/100);
  draw_dodecahedron(Width/4*2,cy,radius);
  draw_icosahedron(Width/4*3,cy,radius*.1+radius*.9*volume/100);

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr = nil
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

  -- draw_mesh(cx,cy,vertices, edges,radius,0xBF, 0x9C, 0x86);
  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6);
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

  -- draw_mesh(cx,cy,vertices, edges,radius,0xbf, 0xb7, 0xa1);
  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6);
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
  -- draw_mesh(cx,cy,vertices, edges,radius,0x99,0x73,0x6e);
  draw_mesh(cx,cy,vertices, edges,radius,0x7c, 0x9f, 0xa6);
end

function draw_ellipse(x, y, size, rx, ry, rz)
  cairo_save(cr);
  
  cairo_translate(cr, x, y);
  cairo_scale(cr, math.cos(ry), math.cos(rx));
  cairo_translate(cr, -x, -y);
  cairo_arc(cr, x, y, size*1.25, 0, math.pi*2);
  
  cairo_restore(cr);

  cairo_stroke(cr);
end

function draw_mesh(x,y,vertices, edges, scale,r,g,b)
  local pointSize = 10;  
  local lineSize = 4;

  for index,point in pairs(vertices) do
    point = rotate_x(point,t/2);
    point = rotate_y(point,t/3);
    point = rotate_z(point,t/5);
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
  -- draw_ellipse(x,y,scale*1.3, 0,  t,0);
  -- draw_ellipse(x,y,scale*1.2, t/1.2,0,0);
end

-- function draw_icosahedron(cx, cy, radius)
--   local pointSize = 10;
--   local lineSize = 4;
--   cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1);
--   radius = radius + math.cos(t+math.pi)*radius/10;
--   drawPoint(cx,cy-radius,pointSize);
--   drawPoint(cx,cy+radius,pointSize);


--   for i=0,5,1 do
--     local y = (radius*2/3)-radius;
--     local sub_radi = radius*math.cos(y/(radius*2)*math.pi);
--     local x = sub_radi*math.cos(t+(math.pi*2)/5*i);
--     local z = math.sin(t+(math.pi*2)/5*i);
   
--     local shadeAmount = (z<0 and 0 or z*.75);
--     cairo_set_source_rgba(cr, (0x7c/0xff), (0x9f/0xff), (0xa6/0xff), 1-shadeAmount);
    
--     drawLine(cx,cy-radius,cx+x,cy+y-z*20,lineSize);
   
--     local xn1 = sub_radi*math.cos(t+(math.pi*2)/5*i+math.pi*2/10);
--     local xn2 = sub_radi*math.cos(t+(math.pi*2)/5*i-math.pi*2/10);
--     local zn1 = math.sin(t+(math.pi*2)/5*i+math.pi*2/10);
--     local zn2 = math.sin(t+(math.pi*2)/5*i-math.pi*2/10);
--     drawLine(cx+x,cy+y-z*20,cx+xn1,cy-y-zn1*20, lineSize);
--     drawLine(cx+x,cy+y-z*20,cx+xn2,cy-y-zn2*20, lineSize);

--     drawPoint(cx+x,cy+y-z*20,pointSize);
--   end

--   for i=0,5,1 do
--     local y = (radius*2/3)-radius;
--     local sub_radi = radius*math.cos(y/(radius*2)*math.pi);
--     local x = sub_radi*math.cos(t+(math.pi*2)/5*i+math.pi*2/10);
--     local z = math.sin(t+(math.pi*2)/5*i+math.pi*2/10);
   
--     local shadeAmount = (z<0 and 0 or z*.75);
--     -- local shadeAmount = 2*(math.cos((t+(math.pi*2)/5*i+math.pi*2/10)+math.pi/2));
--     cairo_set_source_rgba(cr, (0x7c/0xff), (0x9f/0xff), (0xa6/0xff), 1-shadeAmount);
    
--     drawLine(cx,cy+radius,cx+x,cy-y-z*20,lineSize);
--     drawPoint(cx+x,cy-y-z*20,pointSize);
--   end
    

-- end

function draw_sphere(cx, cy, radius)
  
  local y_divisions = 10
  
  radius = radius + math.cos(t)*radius/20;

  cairo_save (cr);
  cairo_translate (cr, cx, cy);
  
  cairo_set_line_width(cr, radius/10);
  cairo_set_source_rgba(cr, 0x7c/0xff, 0x9f/0xff, 0xa6/0xff, 1);
 
  for i=0,y_divisions,1
  do

    local sub_radi = radius*math.cos(-math.pi/2 + ((math.pi/y_divisions)*i));
    local y = radius*math.sin(-math.pi/2 + (math.pi/y_divisions)*i);
    local NumberOfDots = math.floor(sub_radi/radius*y_divisions)*2;
    if(NumberOfDots == 0) then NumberOfDots = 1; end
    for j=0, NumberOfDots, 1
    do
      local angle = ((math.pi*2)/NumberOfDots);
      angle = angle*(j+0.5*0*(i % 2)) + (math.pi*2)*(t/period)*.1;
      -- local angle = ((math.pi*2)/NumberOfDots)*j+(math.pi*2)/NumberOfDots*t/period;

      angle = angle % (2*math.pi);
      local x_x = sub_radi*math.cos(angle);
      -- if(x_x > math.pi) x_x -= math.pi;

      local z = math.sin(angle);
      local shadeAmount = (z<0 and 0 or z*.75);
      -- local shadeAmount = 2*(math.cos(angle+math.pi/2));
      if(NumberOfDots == 1) then shadeAmount = 0; end
      cairo_set_source_rgba(cr, (0x7c/0xff), (0x9f/0xff), (0xa6/0xff), 1-shadeAmount);
      if(NumberOfDots == 1) then
        drawPoint(x_x, y, 10);
      else
        drawPoint(x_x, y-math.sin(angle)*10, 10);
      end
    end
  end

  -- icairo_arc (cr, 0., 0., radius, 0., 2 * math.pi);
  -- cairo_stroke(cr);
  
  cairo_restore (cr);
end
