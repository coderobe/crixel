# TODO: Write documentation for `Crixel`
module Crixel
  VERSION = "0.2.0"

  class SixelImage
    property width : UInt32
    property height : UInt32
    property pixels : Array(UInt32)
    property target : IO

    def initialize(@width, @height)
      @pixels = Array(UInt32).new((@width)*(@height), 0)
      @target = STDOUT
    end

    def set(x, y, color : UInt32)
      @pixels[y*@width + x] = color
    end

    def set_target(io)
      @target = io
    end

    def write(msg : String)
      @target.write(msg.to_slice)
    end

    def render
      colormap = Hash(UInt32, Tuple(Int32, String)).new
      outlines = Array(Array(Hash(UInt32, String))).new

      @pixels.each_slice(@width*6).with_index do |sixrow, sindex|
        # in sixel row
        line_collector = Array(Hash(UInt32, String)).new
        this_line_collector = Hash(UInt32, String).new
        @width.times do |x|
          # in sixel col of row
          sixel_collector = Hash(UInt32, Array(UInt8)).new
          6.times do |ct|
            # in sixel y of col
            begin
              color = sixrow[@width*ct + x]
              sixel_collector.fetch(color) do |color|
                sixel_collector[color] = Array(UInt8).new
                sixel_collector.max_by { |_, a| a.size }.size.times do |t|
                  sixel_collector[color] << 0
                end
              end
              sixel_collector[color] = sixel_collector.fetch(color, Array(UInt8).new) << (1 << ct).to_u8
              sixel_collector.each do |collector_color, sixelpack|
                if collector_color != color
                  sixel_collector[collector_color] = sixelpack << 0
                end
              end
              colstr = colormap.fetch(color, nil)
              if colstr.nil? # color undefined
                colstr = "##{colormap.size};2;"
                colstr += "#{((color >> 16 & 0xFF) / 2.56).round.to_u8}"
                colstr += ';'
                colstr += "#{((color >> 8 & 0xFF) / 2.56).round.to_u8}"
                colstr += ';'
                colstr += "#{((color & 0xFF) / 2.56).round.to_u8}"
                colormap[color] = {colormap.size, colstr}
              end
            rescue e : IndexError
              break # last row of image doesn't fill entire sixel
            end
          end
          sixel_collector.each do |color, sixelpack|
            this_line_collector[color] = this_line_collector.fetch(color, "") + (63 + sixelpack.reduce { |s1, s2| s1 | s2 }).chr
          end
          line_collector << this_line_collector
        end
        outlines << line_collector
      end

      colormap.each { |ck, cs| puts cs.last }
      outlines.each do |line_collect|
        lastcolor = nil
        line_collect.each do |sixel_collect|
          sixel_collect.each do |color, linepart|
            if lastcolor != color
              write "##{colormap[color].first}"
            end
            write linepart
            lastcolor = color
          end
          write "$"
        end
        write "-"
      end
    end

    def render_naive
      colors = Array(UInt32).new

      @pixels.each_slice(@width*6).with_index do |sixrow, sindex|
        # in sixel row
        lastcolor = nil
        lastchar = nil
        lastchar_count = 0
        @width.times do |x|
          # in sixel col of row
          6.times do |ct|
            # in sixel y of col
            begin
              write "$"

              color = sixrow[@width*ct + x]
              colid = colors.index(color)
              if colid.nil? # color undefined
                write "##{colors.size};2;"
                write "#{((color >> 16 & 0xFF) / 2.56).round.to_u8}"
                write ";"
                write "#{((color >> 8 & 0xFF) / 2.56).round.to_u8}"
                write ";"
                write "#{((color & 0xFF) / 2.56).round.to_u8}"
                colors << color
              elsif lastcolor != color
                write "##{colid}"
              end

              if x > 1
                write "!#{x}?"
              else
                write "?"
              end

              write (63 + (1 << ct)).chr.to_s

              lastcolor = color
            rescue e : IndexError
              break # last row of image doesn't fill entire sixel
            end
          end
        end
        write "-"
      end
    end

    def render_full
      write "\033Pq" # sixel
      render
      write "\033\\" # sixel exit
    end

    def render_naive_full
      write "\033Pq" # sixel
      render_naive
      write "\033\\" # sixel exit
    end
  end
end
