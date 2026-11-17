# FPGA Mini-Games Console
# Supratim Das CS25B057
# Utkarsh Pandey CS25B051

A digital logic design project: six mini-games on one FPGA board, written in Verilog and built with Vivado. Games are selected with three slide switches.

- **Board:** EDGE Artix-7 FPGA Development Board
- **FPGA:** AMD Xilinx XC7A35T-1FTG256C (Vivado part: `xc7a35tftg256-1`)
- **Language / tool:** Verilog, Vivado

## Games

Select a game with **SW[11:9]** (binary). **BTN4** is a global reset.

| SW[11:9] | Game | How to play |
|---|---|---|
| 001 | Reaction timer | BTN0 to start. When all LEDs light, press BTN0 as fast as you can. The display shows your time in ms. Pressing early is a foul (`EEEE`). |
| 010 | Whack-a-mole | BTN0 starts. LED0-3 are holes; press the matching BTN0-3. Moles speed up as you score. Three misses end the game (LED11:9 show lives). |
| 011 | Simon Says | BTN0 starts. Watch the LED0-3 sequence (with tones) and repeat it with BTN0-3. Display shows the level. 15 levels wins; 5 s of inactivity loses. |
| 100 | Guess the number | BTN0 starts. Set a guess on SW[7:0] and press BTN0. LED11:8 = go higher, LED3:0 = go lower. 9 tries. Display shows tries used and your current guess. |
| 101 | LED ping-pong | Two players: P1 = BTN0 (LED0 end), P2 = BTN3 (LED11 end). Press when the ball is in the last two LEDs on your side to return it. Early press or a miss gives the opponent a point. First to 9 wins. |
| 110 | Sum game | BTN0 starts. Digits 1-9 flash one at a time; add them up. Enter your answer with BTN1 (+1), BTN2 (-1), BTN3 (+10), then BTN0 to confirm. `C` = correct, `E` = wrong (shows the right sum). SW[1:0] sets speed (1000/700/500/300 ms), SW[3:2] sets length (4-7 digits). |

SW[11:9] = 000 or 111 selects no game; the display shows the switch value.

## Files

| File | Purpose |
|---|---|
| `top.v` | Top level: game select, output mux, wiring |
| `sync_debounce.v` | 2-flop synchronizer, debouncer, press pulse |
| `tick_gen.v` | 1 ms tick generator |
| `lfsr16.v` | Free-running 16-bit LFSR (random numbers) |
| `bin2bcd.v` | Binary to 4-digit BCD |
| `seg7_driver.v` | Multiplexed 4-digit 7-segment driver |
| `tone_gen.v` | Square-wave tone generator for the buzzer |
| `game1_reaction.v` ... `game6_sum.v` | The six games |
| `board.xdc` | Pin constraints template (pins must be filled in) |

## Architecture

- Every game has the same style of interface: clock, reset, 1 ms tick, random value, button pulses in; display data, LEDs and a sound code out.
- A game is held in reset whenever it is not selected, so it always starts fresh.
- Only one game's outputs reach the board at a time, through a mux in `top.v`.
- Display nibbles: `0-9` digits, `A`, `b`, `C`, `d`, `E`, and `F` = blank.
- Sound codes: `0` silent, `1` success beep, `2` failure buzz, `3-6` Simon tones.

## Setup

### 1. Configure for your board
Edit the parameters at the top of `top.v`:

| Parameter | Meaning |
|---|---|
| `CLK_HZ` | Onboard oscillator frequency (default 50 MHz, verify on your board) |
| `BTN_ACTIVE_HIGH` | Set to 0 if buttons read 0 when pressed |
| `SEG_ACTIVE_LOW` | Set to 1 if a segment lights with logic 0 |
| `AN_ACTIVE_LOW` | Set to 1 if a digit enable is active-low |

### 2. Fill in `board.xdc`
Replace every `<PIN>` with the pin number from the board manual or schematic, and repeat the commented lines for each bit of `sw`, `btn`, `led`, `seg` and `an`. Update the `create_clock` period if the oscillator is not 50 MHz. If the board vendor supplies an XDC, use it and rename ports to match `top.v`.

### 3. Build in Vivado
1. Create an RTL project with part `xc7a35tftg256-1`.
2. Add all `.v` files as design sources and `board.xdc` as constraints.
3. Set `top` as the top module.
4. Run Synthesis, Run Implementation, then Generate Bitstream.
5. Open Hardware Manager, Auto Connect, Program Device with `top.bit`.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Nothing happens | Wrong clock pin or `CLK_HZ` |
| Garbled or reversed display | `SEG_ACTIVE_LOW`, `AN_ACTIVE_LOW`, or digit order |
| Buttons inverted or constantly firing | `BTN_ACTIVE_HIGH` |
| Some LEDs or switches dead | Missing or wrong pin line in the XDC |
| "Unplaced ports" / "unspecified I/O standard" | Ports missing from the XDC |
| No sound | Buzzer jumper or buzzer type (passive vs active) |

## Notes

- Programming via Hardware Manager is volatile; the design is lost at power-off unless written to the board's configuration flash.
- The code has not been simulated or synthesized by the author tools; expect to fix minor issues on first build.

## Concepts demonstrated

Finite state machines, counters and clock dividers, LFSR random generation, button synchronization and debouncing, multiplexed 7-segment display, modular hierarchical design, and tone generation.
