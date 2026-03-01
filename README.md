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

#### `sanzo.color(index)`

Returns a single color by its Wada color number (1–159).

```lua
local c = sanzo.color(72)  -- Citrine
```

#### `sanzo.random_color(swatch)`

Returns a random single color from a swatch group (1–6).

```lua
local c = sanzo.random_color(3)  -- random green
```

| Swatch | Group |
|---|---|
| 1 | Reds, pinks, browns |
| 2 | Yellows, creams |
| 3 | Greens |
| 4 | Blues |
| 5 | Purples, lavenders |
| 6 | Neutrals (white, grays, black) |

#### `sanzo.random_with_color(color_index, size)`

Returns a random palette containing a specific color. Pass `0` for size to get a combination of any size. Returns `nil` if no combination of that size contains the color.

```lua
local palette = sanzo.random_with_color(72, 3)  -- 3-color combo containing Citrine
local palette = sanzo.random_with_color(72, 0)  -- any size combo containing Citrine

if not palette then
    palette = sanzo.random(3)  -- fall back to any random combo
end
```

#### `sanzo.find(query)`

Find colors by name using a case-insensitive substring search. Returns an array of matches, each with the color's index and color object.

```lua
local results = sanzo.find("cit")
-- finds Citrine, Buffy Citrine, Dark Citrine, Orange Citrine...

for _, r in ipairs(results) do
    print(r.index, r.color.name, r.color.hex)
end

-- use the index with other functions
local palette = sanzo.random_with_color(results[1].index, 3)
```

### Return values

Palette functions return an array of color objects. `sanzo.color()` and `sanzo.random_color()` return a single color object.

Each color object has:

| Field | Type | Description |
|---|---|---|
| `name` | string | Color name (e.g. `"Citrine"`) |
| `hex` | string | Hex code (e.g. `"#a3ad00"`) |
| `rgb` | table | Normalized `{r, g, b}` in 0–1 range, for use with `love.graphics.setColor()` |
| `rgb255` | table | Raw `{r, g, b}` in 0–255 range |
| `swatch` | number | Swatch group (1–6) |

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
