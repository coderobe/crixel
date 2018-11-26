# TODO: Write documentation for `Crixel`
module Crixel
  VERSION = "0.2.0"

  class Squot
    property color

    def initialize(@color : UInt32 = 0xFF000000_u32)
    end

    def set(@color : UInt32)
    end

    def transparent? : Bool
      color & 0xFF000000 == 0xFF000000
    end
  end

  class Sixel
    property squots

    def initialize(@squots = Array(Squot).new(6, Squot.new))
      @squots.size.times do |t|
        @squots[t - 1] = Squot.new
      end
    end

    def set(y, color : UInt32)
      @squots[y].set(color)
    end

    def to_char : Char
      c = 0b00000000
      @squots.each.with_index do |sq, i|
        c |= 1 << i unless sq.transparent?
      end
      (c + 63).chr
    end
  end

  class MonochromeSixel < Sixel
    property color

    def initialize(@color : UInt32)
      super()
    end
  end

  class Image
    property sixbuf

    def initialize(@width : UInt32, @height : UInt32)
      @sixbuf = Array(Sixel).new((@width * (@height.to_f / 6).ceil).to_u32, Sixel.new)
      @sixbuf.size.times do |t|
        @sixbuf[t - 1] = Sixel.new
      end
    end

    def set(x, y, color : UInt32)
      sindex = (y.to_f / 6).floor.to_u32 * @width + x
      @sixbuf[sindex].set(y % 6, color)
    end

    def render_full(io = STDOUT)
      io.write "\033Pq".to_slice # sixel
      render(io)
      io.write "\033\\".to_slice # sixel exit
    end

    def split_sixel(sixel : Sixel) : Array(MonochromeSixel)
      colors = [] of UInt32
      sixels = [] of MonochromeSixel
      sixel.squots.each.with_index do |sq, i|
        color = colors.index(sq.color)
        if color.nil?
          color = colors.size
          colors << sq.color
        end
        sixels << MonochromeSixel.new(sq.color) if sixels.size < color + 1
        sixels[color].set(i, sq.color)
      end
      sixels
    end

    def render(io = STDOUT)
      frame = ""
      palette = [] of UInt32

      @sixbuf.each_slice(@width) do |sixline|
        colors = [] of UInt32
        lines = [] of String
        sixline.each do |sixel|
          sixels = split_sixel(sixel)
          sixels.each.with_index do |sx, i|
            color = colors.index(sx.color)
            if color.nil?
              color = colors.size
              colors << sx.color
            end
            lines << "" if lines.size < colors.size
            lines[color] += sx.to_char
          end
        end

        lines.each.with_index do |line, index|
          color = colors[index]
          pindex = palette.index color
          if pindex.nil? # color undefined
            pindex = palette.size
            palette.push color
            frame += "##{pindex};2;#{(color >> 16 & 0xFF).to_u8};#{(color >> 8 & 0xFF).to_u8};#{(color & 0xFF).to_u8}"
          else
            frame += "##{pindex}"
          end
          frame += "#{line}$"
        end

        frame += '-'
      end

      io.write frame.to_slice
    end
  end
end
