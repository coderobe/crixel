#!/usr/bin/env crystal

require "benchmark"
require "./src/crixel"
include Crixel

width = 64_u32
height = 64_u32

img = SixelImage.new(width, height)

def shade(x, y, time)
  bg = 0x00FA9A_u32
  fg = 0x61001E_u32
  color = bg

  vx = x + Math.sin(time * 3) * 10
  vy = y + Math.cos(time * 3) * 10

  if (vy % 32) < 16
    if (vx % 32) > 16
      color = fg
    end
  else
    if (vx % 32) < 16
      color = fg
    end
  end

  color & 0xFFFFFF
end

t_start = Time.now
1.times do # replace with higher num for moar rendering
  delta = Benchmark.realtime do
    height.times do |y|
      width.times do |x|
        img.set(x, y, shade(x, y, (Time.now - t_start).total_seconds))
      end
    end
    puts "normal implementation:"
    d_norm = Benchmark.realtime do
      img.render_full
    end
    puts "took #{d_norm}\n"
    puts "naive implementation:"
    d_naive = Benchmark.realtime do
      img.render_naive_full
    end
    puts "took #{d_naive}\n"
  end
  max = 33.33.milliseconds
  sleep max - delta
end
