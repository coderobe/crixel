# TODO: Write documentation for `Crixel`
module Crixel
  VERSION = "0.1.0"

  def write_sixel(io, pixels, skew)
    frame = ""
    palette = [] of Array(UInt8)

    frame += "\033[;H" # cursor home
    frame += "\033Pq"  # sixel

    pixels.each.with_index do |pixel, index|
      pindex = palette.index pixel
      if pindex.nil?
        pindex = palette.size
        frame += "##{pindex};2;#{pixel.join ";"}"
        palette.push pixel
      end
      6.times do
        frame += "##{pindex}~"
      end
      frame += "-$" if (index + 1) % skew == 0
    end
    frame += "\033\\" # sixel exit
    io.write frame.to_slice
  end
end
