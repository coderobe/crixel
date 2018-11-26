#!/usr/bin/env crystal

require "./src/crixel"
include Crixel

width = 256_u32
height = 256_u32

img = Image.new(width, height)

color = 0_u32
height.times do |y|
  width.times do |x|
    color = 0xFF0000_u32 + y
    img.set(x, y, color)
  end
end

img.render_full STDERR
