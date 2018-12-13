# crixel

Crystal sixel renderer

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  crixel:
    github: fliegermarzipan/crixel
```
2. Run `shards install`

## Usage

```crystal
require "crixel"

# create a canvas
width = 5 # px
height = 5 # px
img = SixelImage.new(width, height)

# change pixel color at x, y coords
img.set(3, 3, 0xFF0000_u32)

# draw
img.render_naive_full
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/fliegermarzipan/crixel/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Robin Broda](https://github.com/coderobe) - creator and maintainer
