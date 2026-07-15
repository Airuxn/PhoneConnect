# Example keyboard coordinates (1440×2960 layout)

Optional reference for PocketMCP `tap` automation. **Coordinates are device-specific** — measure your own screen or copy this file and adjust for your phone model and keyboard app.

Example layout: compact terminal app with on-screen keyboard (extra keys row ends around y=1618).

## Rows (y)

- Number row: ~1910
- QWERTY row (mid/right): ~2170
- QWERTY row (left keys): ~2050
- ASDF row: ~2300
- ZXCV row: ~2430
- Enter: 1280, 2720

## Example key positions

- w: 230, 2050 | e: 366, 2170 | t: 626, 2050 | p: 1374, 2170
- o: 1175, 2170 | i: 1045, 2170 | u: 956, 2170
- a: 154, 2300 | s: 310, 2270 | d: 470, 2300 | h: 850, 2300 | l: 1334, 2300
- m: 1190, 2430 | n: 1050, 2430
- Enter: 1280, 2720

## Clear line (example)

- Focus input: 720, 1200
- Ctrl+U: CTRL key then u key (device-specific positions)

## Numbers vs letters keyboard

If letters become digits, switch back to ABC before continuing — detect via a probe tap and `screen_state`.
