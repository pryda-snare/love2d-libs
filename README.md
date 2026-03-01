# love2d-libs

A collection of reusable Lua libraries for [LÖVE](https://love2d.org/) games.

---

## sanzo.lua

Color palettes from Sanzo Wada's *A Dictionary of Color Combinations*, ready to use in Love2D.

Drop `sanzo.lua` into your project and require it:

```lua
local sanzo = require("sanzo")
```

### Functions

#### `sanzo.combination(id)`

Returns a specific Wada palette by its combination number (1–348).

```lua
local palette = sanzo.combination(121)
```

#### `sanzo.random(size)`

Returns a random palette of `2`, `3`, or `4` colors.

```lua
local palette = sanzo.random(3)
```

### Return value

Both functions return an array of color objects. Each color has:

| Field | Type | Description |
|---|---|---|
| `name` | string | Color name (e.g. `"Citrine"`) |
| `hex` | string | Hex code (e.g. `"#a3ad00"`) |
| `rgb` | table | Normalized `{r, g, b}` in 0–1 range, for use with `love.graphics.setColor()` |
| `rgb255` | table | Raw `{r, g, b}` in 0–255 range |

### Example

```lua
local sanzo = require("sanzo")

function love.load()
    palette = sanzo.random(3)
end

function love.draw()
    for i, c in ipairs(palette) do
        love.graphics.setColor(c.rgb[1], c.rgb[2], c.rgb[3])
        love.graphics.rectangle("fill", (i - 1) * 200, 0, 200, 200)
    end
end
```

### Data sources

Combination structure from [Z4P0/sanzo](https://github.com/Z4P0/sanzo). Hex values from [sanzo-wada.dmbk.io](https://sanzo-wada.dmbk.io).
