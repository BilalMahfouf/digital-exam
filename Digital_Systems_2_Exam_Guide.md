# Digital Systems 2 — Complete Exam Guide
### 100% Exam-Focused | Theory + Problem Solving + VHDL + Systems
### ✅ IMPROVED & COMPLETED VERSION

---

# PART 1 — THEORY SECTION

---

## 1.1 LATCHES

### What is a Latch?
A latch is a **level-sensitive** bistable storage element. It stores 1 bit. Its output can change **any time** its Enable (En) signal is asserted.

**Why it exists:** Simplest way to store a bit. Acts as the building block for flip-flops.

### The D-Latch
| En | D | Q (next) |
|----|---|----------|
| 0  | x | Q (unchanged — opaque) |
| 1  | 0 | 0 (transparent — follows D) |
| 1  | 1 | 1 (transparent — follows D) |

- **Transparent** when En=1: Q = D continuously
- **Opaque** when En=0: Q holds last value

### SR-Latch Key Points
| S | R | Q | Mode |
|---|---|---|------|
| 0 | 0 | Q | Hold |
| 0 | 1 | 0 | Reset |
| 1 | 0 | 1 | Set |
| 1 | 1 | ❌ | **Forbidden (undefined)** |

> **Exam trap:** S=R=1 is forbidden because both Q and Q' would be forced to 0 simultaneously, violating Q' = NOT Q.

### Why Latches Are Problematic
- The output can change **multiple times** during a single clock HIGH period → **glitches**
- During En=1, if D keeps changing, Q keeps following → **transparency problem**
- Hard to synchronize in complex systems
- Not suitable for synchronous design → **Flip-Flops solve this**

### Latch vs Flip-Flop — Intuition
Think of a latch like an open window: anything can pass through while open (En=1). A flip-flop is like a camera shutter: it only captures one instant (the clock edge), then freezes.

---

## 1.2 FLIP-FLOPS (FFs)

### What is a Flip-Flop?
A FF is an **edge-triggered** bistable device. The output changes **only at the active clock edge** (rising or falling). Between edges, output is frozen.

### Why Edge-Triggered Matters
Latches respond to levels → unstable. FFs respond to edges → **predictable, synchronous behavior**. This is essential for reliable digital systems.

**Hardware intuition:** The master-slave D-FF is literally two latches back-to-back with opposite enable signals. The first latch (master) captures on CLK=0, the second (slave) transfers to output on CLK=1. So Q only changes on the rising edge.

### The Three Main FF Types

#### D-FF (Data / Delay)
- **State equation:** Q⁺ = D
- **Behavior:** Output copies D at the clock edge. Simple, universal.
- **Use:** Registers, pipelines, state machines
- **Intuition:** D = "Data you want next"

| Q | D | Q⁺ |
|---|---|-----|
| 0 | 0 | 0  |
| 0 | 1 | 1  |
| 1 | 0 | 0  |
| 1 | 1 | 1  |

**Excitation table (what D must be to get desired Q⁺):**
| Q → Q⁺ | D |
|---------|---|
| 0 → 0  | 0 |
| 0 → 1  | 1 |
| 1 → 0  | 0 |
| 1 → 1  | 1 |

> D-FF excitation = trivially D = Q⁺. No don't cares. Simplest to use.

#### T-FF (Toggle)
- **State equation:** Q⁺ = Q ⊕ T
- **Behavior:** T=0 → Hold. T=1 → Toggle (flip state).
- **Use:** Counters (every FF is a ÷2 divider when T=1)
- **Intuition:** T = "Toggle me?"

| Q | T | Q⁺ |
|---|---|-----|
| 0 | 0 | 0  |
| 0 | 1 | 1  |
| 1 | 0 | 1  |
| 1 | 1 | 0  |

**Excitation table:**
| Q → Q⁺ | T |
|---------|---|
| 0 → 0  | 0 |
| 0 → 1  | 1 |
| 1 → 0  | 1 |
| 1 → 1  | 0 |

> T = Q ⊕ Q⁺. If state changes → T=1. If state stays → T=0.

#### JK-FF (Jack Kilby — most versatile)
- **State equation:** Q⁺ = K'Q + JQ'
- **Behavior:** J=K=0 → Hold. J=0,K=1 → Reset. J=1,K=0 → Set. J=K=1 → **Toggle**
- **Use:** Counters, flexible state machines
- **Intuition:** J = "Jump to 1", K = "Kill to 0". Both=1 → toggle

| J | K | Q⁺ | Mode |
|---|---|----|------|
| 0 | 0 | Q  | Hold |
| 0 | 1 | 0  | Reset |
| 1 | 0 | 1  | Set |
| 1 | 1 | Q' | Toggle |

**Excitation table:**
| Q → Q⁺ | J | K |
|---------|---|---|
| 0 → 0  | 0 | x |
| 0 → 1  | 1 | x |
| 1 → 0  | x | 1 |
| 1 → 1  | x | 0 |

> **Exam trap:** The "x" (don't care) entries make JK-FF excitation tables simpler → fewer gates than D-FF design!

**Why JK produces more don't cares than D-FF:**
- J only matters when Q=0 (K doesn't care what J is when Q=1, because K=1 resets regardless)
- K only matters when Q=1
- This gives half the entries as don't cares → smaller K-map groups → minimal logic

### Asynchronous Inputs: PR (Preset) and CLR (Clear)
- **PR** (Preset/Set): Forces Q=1 **immediately**, independent of clock
- **CLR** (Clear/Reset): Forces Q=0 **immediately**, independent of clock
- **Override synchronous inputs** — they act instantly
- Active LOW: asserted with 0, deasserted with 1
- Active HIGH: asserted with 1, deasserted with 0
- **Both PR and CLR must NEVER be active simultaneously**

> **Exam question:** "How do you preset a counter to state 5 (101) at any instant?" → Use PR on FF2 and FF0 (bits='1'), use CLR on FF1 (bit='0'). "At any instant" = **asynchronous** operation.

### Timing Constraints: Setup and Hold Time

```
              tsu   thd
         _____|_____|_____
    D:  ~~~~~ STABLE ~~~~~
                   ↑
              Clock edge
```

- **Setup time (tsu):** D must be stable **BEFORE** active clock edge
- **Hold time (thd):** D must remain stable **AFTER** active clock edge
- **Violation:** D changes during setup/hold window → **metastability** → unpredictable output that may never resolve to 0 or 1

> **Exam question:** "What happens if setup time is violated?" → The FF may enter a **metastable** state — neither 0 nor 1 — and may take an unpredictably long time to resolve. Can cause system failure.

**Performance note:** Setup time directly limits maximum clock frequency:
`fmax = 1 / (tpd_logic + tsu)`

### Master-Slave D-FF
- Two D-latches in series, opposite enables
- Master captures when Clk=0 (locked from feedback), Slave transfers when Clk=1
- Output Q changes **only at the rising edge**
- Efficient NAND implementation: 6 gates (edge-triggered), or 11 gates (master-slave)

### Converting Between FF Types
- **T-FF from D-FF:** D = Q ⊕ T
- **JK-FF from D-FF:** D = K'Q + JQ'
- **D-FF from T-FF:** T = Q ⊕ D
- **Method:** Equate state equations and solve for the input of the available FF

> **Why convert?** You may only have D-FFs available (common in FPGAs), but the design calls for T or JK behavior. The conversion equation tells you what logic to put in front of the D input.

### FF Comparison Table

| Feature | D-FF | T-FF | JK-FF |
|---------|------|------|-------|
| Inputs | 1 (D) | 1 (T) | 2 (J,K) |
| State equation | Q⁺ = D | Q⁺ = Q⊕T | Q⁺ = K'Q+JQ' |
| Excitation don't cares | None | None | Half |
| K-map simplification | Least | Medium | Most |
| Primary use | Registers | Counters | Counters, FSMs |
| Logic overhead | More gates | Medium | Fewer gates |

---

## 1.3 REGISTERS

### What is a Register?
A group of **n D-FFs with a common clock** used to store n-bit data. Fundamental building block for all synchronous sequential systems.

### PIPO (Parallel In, Parallel Out)
- All bits loaded simultaneously on clock edge
- State equation: Q(t+1) = I(t)
- Use: Temporary storage, data buses, pipeline stages
- **Exam intuition:** Snapshot of n-bit data on every clock edge

### SISO (Serial In, Serial Out)
- Chain of D-FFs — data shifts one position per clock
- Os(t+n) = Is(t) → **n-cycle delay line**
- Use: Delay lines, serial communication, DSP pipelines
- **Hardware intuition:** Data "bubbles" through the chain, one stage per clock

### SIPO / PISO
- **SIPO:** Serial in → Parallel out — receives serial bits, presents them in parallel (deserializer)
- **PISO:** Parallel in → Serial out — loads all bits at once, shifts out one at a time (serializer)
- Use: UART, SPI, I²C protocols

### Bidirectional Shift Register
- Control R/L: 1=Right shift, 0=Left shift
- Equations for stage i: `Di = Qi+1·(R/L) + Qi-1·(R/L)'`
- Right shift = divide by 2 (logical), Left shift = multiply by 2
- Implemented with 2:1 MUX at each FF input

### Universal Shift Register (USR)
Two control bits S1S0 select operation:

| S1 | S0 | Operation |
|----|----|-----------|
| 0  | 0  | Parallel load |
| 0  | 1  | Shift Left |
| 1  | 0  | Shift Right |
| 1  | 1  | Hold (Do-Nothing) |

Most flexible register — replaces PIPO, SISO, SIPO, PISO, and bidirectional.

### Special Counters (Shift Register with Feedback)

#### Ring Counter
- Output of last FF fed back to input of first FF
- Must be initialized with exactly **one '1'** (all others 0)
- All-zero state is **forbidden** (counter gets stuck at 0 forever)
- n-bit ring counter → **n states**, sequence length = n
- Called **"1-hot code"** — only one FF is '1' at a time
- **Advantage:** No decoder needed — each FF output IS the count detect signal

```
  D→[FF0]→[FF1]→[FF2]→[FF3]→┐
  └──────────────────────────┘
  Init: 1000 → 0100 → 0010 → 0001 → 1000...
```

#### Johnson (Twisted Ring) Counter
- **Inverted** output (Q') of last FF fed back to input of first FF
- CLR to initialize to 0000
- n-bit Johnson → **2n states** (sequence length = 2n)
- Generates a creeping code: 0000→1000→1100→1110→1111→0111→0011→0001→0000...

```
  D→[FF0]→[FF1]→[FF2]→[FF3]→┐(Q')
  └──────────────────────────┘
```

**Advantage over ring:** Double the states with same hardware. Easy to decode with 2-input AND gates.

#### LFSR (Linear Feedback Shift Register)
- XOR feedback from tapped positions (tap positions chosen to maximize length)
- Near-maximum length: **2ⁿ - 1 states** (all-zero is forbidden — once there, XOR of zeros is zero)
- Modified LFSR with AND gate detecting all-zeros → includes it → **2ⁿ states**
- Generates pseudo-random sequences
- **Use:** Built-in self-test (BIST), data scrambling, CRC generation

> **Comparison: Ring vs Johnson vs LFSR**
>
> | Type | States | Init | Forbidden | Use |
> |------|--------|------|-----------|-----|
> | Ring | n | 1-hot (one '1') | All-zeros | Sequencing, scanning |
> | Johnson | 2n | CLR to 0 | Other combinations | Wider sequence, easy decode |
> | LFSR | 2ⁿ-1 | Any non-zero | All-zeros | Pseudo-random, test |

---

## 1.4 COUNTERS

### Asynchronous (Ripple) Counters

**How they work:** T-FFs in toggle mode (T=1) chained in series. Each FF's Q output clocks the next FF. LSB toggles every clock; each subsequent bit toggles at half the rate.

**UP counter:** Qi-1 output clocks FFi (Q rising edge = carry)
**DOWN counter:** Q'i-1 output clocks FFi (Q falling edge from complement = borrow)
**UP/DOWN control:** `Clki = Qi-1·C' + Q'i-1·C` (MUX between Q and Q')

**Advantages:** Simple design, minimal gates, easy to understand
**Disadvantages:**
- **Propagation delay accumulates:** Total delay = n × tpd
- **Spurious (glitch) states** between transitions (briefly shows invalid codes)
- **Maximum frequency:** `fmax ≤ 1/(n × tpd)`

> **Example:** 10-bit counter, tpd=50ns → fmax ≤ 1/(10×50ns) = **2 MHz** — very slow for modern systems!

**Glitch explanation:** Counter transitions 7(111)→8(000):
1. FF0 toggles (briefly: 110)
2. FF1 toggles (briefly: 100)
3. FF2 toggles (finally: 000)

Combinational logic sees states 7→6→4→0. Any decoder attached to the output fires glitch pulses on outputs 6 and 4. **This is why async counters are avoided in critical systems.**

### Truncated Asynchronous UP Counter (Mod-N, N < 2k)
**Procedure:**
1. Determine number of FFs: p ≥ log₂N
2. Wire in UP ripple fashion (Q→CLK chain)
3. Find binary of N (NOT N-1; the NAND detects N and immediately resets)
4. NAND all FF outputs that are '1' at count N (active-LOW CLR)
5. Connect NAND output to all FF CLR inputs

The counter momentarily enters state N, the NAND fires, and CLR resets everything to 0. This "glitch state" is extremely brief (nanoseconds) but exists.

> **Example: Mod-5 UP:** 5 = 101₂ → NAND Q2 and Q0 → drives CLR of all 3 FFs
> Sequence: 0→1→2→3→4→(5 briefly)→0→1→...

### Truncated Asynchronous DOWN Counter (Mod-N)
Counts from N-1 down to 0, then reloads N-1.
**Procedure:**
1. Use ripple DOWN configuration (Q' drives next CLK)
2. NAND all **normal** (Q) outputs of all k FFs (detects state 2k-1 = all ones)
3. Connect NAND to PR/CLR to force counter to N-1

> **Example: Mod-5 DOWN (counts 4,3,2,1,0,4,...):**
> k=3 FFs, 5=101₂. Preset to 4=100₂: PR on FF2, CLR on FF1 and FF0.
> NAND(Q2,Q1,Q0) → when all ones (state 7) → force to 100

### Synchronous Counters

**How they work:** ALL FFs share the same clock. Combinational logic computes each FF input to produce the desired sequence. All FFs update simultaneously.

**Advantages:**
- No propagation delay accumulation — all FFs triggered simultaneously
- No spurious states
- Much higher fmax
- Can count in ANY sequence (not just binary up/down)

**Disadvantages:** More complex combinational logic (K-maps required)

**fmax for synchronous counter:**
`fmax = 1 / (tpd_combinational + tsu_FF)`
Not multiplied by n! Only the combinational logic delay matters.

**Performance comparison:**
| Counter Type | fmax Formula | Example (n=8, tpd=10ns, tsu=3ns) |
|---|---|---|
| Async ripple | 1/(n·tpd) | 1/(8×10ns) = 12.5 MHz |
| Synchronous | 1/(tpd_comb + tsu) | 1/(10+3ns) ≈ 77 MHz |

### Design Procedure for Synchronous Counters (Step-by-Step)

1. **Draw state diagram** (desired sequence as a cycle of circles)
2. **Determine number of FFs:** k ≥ log₂N for Mod-N (k = ⌈log₂N⌉)
3. **Select FF type** (D-FF: straightforward; JK-FF: fewer gates due to don't cares)
4. **Build transition table:** List all 2k states. Valid states: write PS → NS. Unused states: write "x x x" (don't care)
5. **Derive FF inputs** using excitation table for chosen FF type
6. **Minimize FF inputs** using K-maps (USE don't-cares for unused states!)
7. **Draw logic circuit**
8. **Check self-starting:** For each unused state, compute NS using minimized expressions → verify it eventually enters the valid sequence

**Self-starting (autonomous) counter:** Even if the counter powers up in a forbidden state, it will eventually enter the valid counting sequence on its own. This is a correctness requirement for reliable systems.

> **Why self-starting matters:** FPGAs power up in unknown states. If a counter can get stuck in a forbidden state loop, the system fails. A self-starting counter always recovers.

---

## 1.5 DECODERS

### What is a Decoder?
An n:2ⁿ combinational module. Given n-bit input X and Enable EN=1, exactly ONE of 2ⁿ outputs goes HIGH (the one matching binary value of X). All others LOW.

**Mathematical description:** `Yi = EN · mi(X)` — it's a **minterm generator**.

**Why useful:**
1. Implement any Boolean function by ORing selected outputs (no K-map!)
2. Address decoding in microprocessor memory maps
3. Enable/select subsystems (chip select)
4. Sequence detection

**Active-LOW outputs:** Selected output goes LOW; all others HIGH. NAND logic internally.

> **Exam tip:** To implement `f(a,b,c) = Σm(1,2,7)` using 3:8 decoder:
> Connect outputs Y1, Y2, Y7 to an OR gate. Done. No minimization needed!

### Active-LOW Outputs + NAND Gate Implementation
Decoder with active-LOW outputs + NAND gates = same as decoder with active-HIGH + OR gates.
By De Morgan: `NAND(Y'1, Y'2, Y'7) = OR(Y1, Y2, Y7)` ✓

### Hierarchical Expansion: 3:8 from two 2:4 Decoders

```
S2 ─────────────────┬────── EN of Decoder A (handles Y0-Y3) [EN = S2']
                    └── NOT ─ EN of Decoder B (handles Y4-Y7) [EN = S2]
S1, S0 ─────────────────────→ BOTH decoders (shared address inputs)
```

**Rule:** MSB selects which decoder is enabled. Lower bits select within the active decoder. Only one decoder is enabled at any time.

> **Why mutually exclusive enables?** Prevents two outputs from being active simultaneously, which would cause bus conflicts.

### Decoder Performance Notes
- Propagation delay: 1 gate level for enables + 1 gate level for AND/NAND = O(1)
- No ripple effect; delay independent of n
- Fan-out: each output drives only one gate internally — add buffers for heavy loads

---

## 1.6 MULTIPLEXERS (MUX)

### What is a MUX?
A 2ⁿ:1 MUX selects ONE of 2ⁿ data inputs and routes it to the single output, based on the n-bit select code.

**Mathematical description:** `Y = EN · Σ di·mi(S)`

Also called **Universal Logic Module (ULM)** because a 2ⁿ:1 MUX can implement **any Boolean function of n variables** (just wire the truth table values to data inputs).

### Implementing Boolean Functions with a MUX

**Method 1 — Direct (2ⁿ:1 MUX, n = number of variables):**
- Connect all input variables to select lines (MSB first)
- Connect function value (0 or 1) from truth table to each data input
- Example: `f(a,b,c) = Σm(0,2,3,5,6)` with 8:1 MUX → D0=1, D1=0, D2=1, D3=1, D4=0, D5=1, D6=1, D7=0

**Method 2 — With one extra variable (2ⁿ⁻¹:1 MUX):**
- Use n-1 variables as select lines (typically all except LSB)
- For each select combination, look at function value for both values of the remaining variable (LSB)
- Data input = 0, 1, LSB, or LSB' depending on the pair

| LSB=0 | LSB=1 | Data input |
|-------|-------|-----------|
| 0 | 0 | 0 |
| 1 | 1 | 1 |
| 0 | 1 | LSB |
| 1 | 0 | LSB' |

> **When to use Method 2?** When you have a 4:1 MUX but a 3-variable function. Reduces MUX size by half at cost of one inverter.

### MUX-based Waveform Generator
Counter (provides select address) + MUX (data inputs = pattern) = programmable waveform generator.
- Counter cycles through select codes 0..2ⁿ-1 repeatedly
- Each data input determines output at that time slot
- Change data inputs → change waveform

### MUX as PISO (Parallel to Serial Converter)
A counter drives the select lines of a MUX. Parallel inputs D0..Dn-1 are connected to MUX data inputs. As counter increments, MUX selects each bit sequentially.

### Hierarchical MUX: 8:1 from 4:1 MUXes

```
I0-I3 → [MUX A (4:1)] ─┐
             ↑            │
            S1,S0         ├→ [MUX C (2:1)] → Output
I4-I7 → [MUX B (4:1)] ─┘         ↑
             ↑                    S2
            S1,S0
```

- S2=0 → output of MUX A (selects I0-I3 via S1,S0)
- S2=1 → output of MUX B (selects I4-I7 via S1,S0)

> **Key difference from Decoder hierarchy:** Both first-level MUXes always compute their outputs. The final MUX just chooses which one to pass. Unlike decoders, you cannot "disable" a MUX's computation — only its output is gated.

### MUX vs Decoder for Boolean Function Implementation

| Criterion | MUX (2ⁿ:1) | Decoder (n:2ⁿ) + OR |
|-----------|-----------|---------------------|
| Hardware | 1 component | 2 components |
| Connection | Wire truth table to inputs | Select minterm outputs |
| Flexibility | Change function by rewiring inputs | Same |
| FPGA LUTs | Implemented as LUT (same thing) | Less efficient |
| Exam approach | Fast — read truth table → done | Also fast |

---

## 1.7 DEMULTIPLEXERS (DEMUX)

### What is a DEMUX?
Routes ONE data input to ONE of 2ⁿ outputs, selected by the control inputs. Inverse of MUX.

**Key insight:** A decoder with EN as the data input IS a DEMUX. EN carries the data; select lines choose the destination.

`Yi = I · EN · mi(S)` where I is the data input

### DEMUX Application: Time Division Multiplexing (TDM)

```
Ch0 ─┐                                ┌─ Ch0
Ch1 ─┤→ [8:1 MUX] ──single wire──→ [1:8 DEMUX] ─┤─ Ch1
...  │        ↑                              ↑  └─ ...
Ch7 ─┘   [Mod-8 Counter] ←─sync─→ [Mod-8 Counter]
                      (same clock, same start)
```

- Both counters must be **synchronized** (same clock frequency, same phase)
- At each clock: MUX sends one channel; DEMUX routes to matching output
- Multiplies wire usage by 8× → efficient serial transmission

**Critical:** If counters lose synchronization → channels get cross-routed → data corruption. Real systems use sync pulses or PLLs.

### Hierarchical DEMUX: 1:8 from two 1:4 DEMUXes
Same structure as decoder hierarchy, but data line I connects to BOTH sub-modules' data inputs. MSB selects which one is enabled.

---

## 1.8 ENCODERS

### Basic Binary Encoder (2ⁿ:n)
Inverse of decoder. One active input among 2ⁿ → outputs its n-bit binary index.

**Problems:**
1. Only ONE input may be asserted → otherwise output is OR-combination (wrong)
2. All-zeros output is ambiguous: X0=1 or no input both give output 0

### Priority Encoder (P_ENC) — The Solution
- Multiple inputs active simultaneously → outputs index of **highest-priority (highest index) active input**
- **GS (Group Signal):** GS=1 when ANY input is active. GS=0 → all inputs inactive. Distinguishes X0=1 from no input.

**4:2 P_ENC equations:**
- y1 = X3 + X2
- y0 = X3 + X2'·X1
- GS = X3 + X2 + X1 + X0

**Reading the equations:** y1 is 1 whenever X2 or X3 is active (both have index ≥ 2, so bit 1 of output is 1). y0 is 1 when X3 is active, OR when X2 is NOT active but X1 IS active (X1 overrides X0 only).

### Priority Encoder Applications
1. **Keyboard encoding:** 16 keys → 4-bit code + GS (GS=0 means no key pressed)
2. **Interrupt handling:** Multiple interrupt sources → CPU gets highest-priority interrupt number first

---

## 1.9 SYNCHRONOUS vs ASYNCHRONOUS — KEY COMPARISON

| Feature | Asynchronous Counter | Synchronous Counter |
|---------|---------------------|---------------------|
| Clock connection | Chained (Q → next CLK) | All FFs share same CLK |
| Propagation delay | Accumulates: n × tpd | Single combinational level |
| Spurious states | YES (glitches between valid states) | NO |
| Speed | Slow: fmax = 1/(n·tpd) | Fast: fmax = 1/(tcomb+tsu) |
| Design complexity | Simple (wire Q to next CLK) | More complex (K-maps) |
| Any sequence | Difficult | Yes, by design |
| Power | Lower logic count | More logic gates |

**When to use async:** Simple, low-speed frequency division only (e.g., divide 50 MHz by 1024 using 10 T-FFs — no decoding of intermediate states).
**When to use sync:** Any system that decodes counter outputs, controls other logic, or needs high speed.

---

## 1.10 CLOCK, FREQUENCY DIVISION, AND FPGA BASICS

### Why Does FPGA Have a 50 MHz Clock?
The DE1/DE2/similar boards have an onboard crystal oscillator generating 50 MHz. Standard frequency: fast enough for most digital designs, slow enough to be easily synthesized and routed. 50 MHz = 20 ns period.

### Why Can't We Observe 50 MHz Directly?
The human eye perceives changes up to ~24 Hz. At 50 MHz, an LED toggles 25 million times per second — persistence of vision makes it appear constantly ON (at ~50% brightness). **The blinking is completely invisible.**

### Clock Divider — Why It Is Needed
To drive visible outputs (LEDs, 7-segment displays) or slow peripherals, we divide the clock.

**How it works:**
- Counter counts from 0 to N-1, then resets
- Toggle output when counter reaches max → toggle method
- Output frequency = fClk / (2N) for toggle method, fClk / N for pulse method

**Example: 1 Hz from 50 MHz:**
- Need to divide by 50,000,000
- Use a 26-bit counter (2²⁶ = 67M > 50M)
- Count to 24,999,999 then toggle → 50MHz / (2 × 25,000,000) = **1 Hz**

### Duty Cycle
**Definition:** Duty cycle = (Time HIGH / Total Period) × 100%

- Symmetric (50%) clock → toggle method always gives exactly 50%
- Pulse method: generates 1-cycle HIGH every N cycles → duty cycle = 1/N × 100%

> **Exam question:** "A clock divider divides by 8 using toggle method. Duty cycle?" → **50%**
> "If it generates a 1-cycle pulse every 8 cycles?" → **12.5%**

**Hardware intuition for duty cycle:** Symmetry comes from toggling: you count N cycles HIGH, then N cycles LOW → equal halves.

### Why Clock Divider Uses a Counter
A binary counter's MSB toggles at fClk/2ⁿ naturally. For exact frequencies, use a comparator counter. FPGA synthesis maps integer comparisons to efficient hardware (carry chains).

### FPGA vs Real Hardware: Key Differences

| | Simulation | Real FPGA |
|---|---|---|
| Propagation delay | None (ideal) | Real routing delays exist |
| Metastability | Doesn't occur | Possible at async interfaces |
| Clock quality | Perfect | Slight jitter (ps range) |
| Setup/hold | Never violated (sim) | Must meet timing constraints |
| Power-up state | Specified (force 0/1) | Unknown → need reset |
| Clock distribution | No skew | Low-skew global clock networks |

> **Always route clocks on global clock networks (GCLK on Xilinx, GCLK on Altera).** Routing a clock on regular routing → high skew → timing violations.

---

# PART 2 — PROBLEM SOLVING STRATEGY

---

## 2.1 HOW TO DESIGN A SYNCHRONOUS COUNTER (Step-by-Step)

**Given:** Design a Mod-6 UP counter using D-FFs with async CLR (active LOW).

### Step 1: State Diagram
Draw circles: 0→1→2→3→4→5→0

### Step 2: Number of FFs
k ≥ log₂(6) = 2.58 → **3 FFs** (QA=MSB, QB, QC=LSB)
Unused states: 6=110, 7=111

### Step 3: Transition Table
| PS: QA QB QC | NS: Q⁺A Q⁺B Q⁺C | DA | DB | DC |
|---|---|---|---|---|
| 0 0 0 | 0 0 1 | 0 | 0 | 1 |
| 0 0 1 | 0 1 0 | 0 | 1 | 0 |
| 0 1 0 | 0 1 1 | 0 | 1 | 1 |
| 0 1 1 | 1 0 0 | 1 | 0 | 0 |
| 1 0 0 | 1 0 1 | 1 | 0 | 1 |
| 1 0 1 | 0 0 0 | 0 | 0 | 0 |
| 1 1 0 | x x x | x | x | x |
| 1 1 1 | x x x | x | x | x |

> For D-FF: Di = Q⁺i (trivially). This step is the same as reading the NS column.

### Step 4: K-Maps (3 variables: QA, QB, QC)
Fill each K-map with DA, DB, DC values. Treat rows 6,7 as don't cares (x). Group to minimize.

**K-map for DA (example):**
```
        QC=0  QC=1
QA=0, QB=0:  0     0
QA=0, QB=1:  0     1
QA=1, QB=0:  1     1   ← use x's for 1,1,x,x
QA=1, QB=1:  x     x
```
Minimized: DA = QA·QB' + QB·QC → (verify with your specific groupings)

### Step 5: Draw Logic Circuit
AND/OR/NOT gates + D-FFs with shared clock.

### Step 6: Self-Starting Check
For states 6=110 and 7=111, substitute into minimized DA, DB, DC equations to find the next state. If both eventually lead back into {0,1,2,3,4,5} → **self-starting** ✓

---

## 2.2 HOW TO DESIGN USING JK-FFs

After building the PS→NS transition table, derive JK inputs using the JK excitation table:

| Q→Q⁺ | J | K |
|------|---|---|
| 0→0 | 0 | x |
| 0→1 | 1 | x |
| 1→0 | x | 1 |
| 1→1 | x | 0 |

**Advantage:** More don't cares (x) → larger K-map groups → simpler final logic → fewer gates!

> **Exam strategy:** If the question says "minimize the logic," prefer JK-FF over D-FF. More don't cares = more simplification.

---

## 2.3 HOW TO READ A TIMING DIAGRAM

**Step-by-step:**
1. **Identify the clock** — note whether it's rising-edge or falling-edge triggered
2. **Identify async inputs** — check if CLR/PR changes (active LOW: signal going to 0 = asserted)
3. **Check FF outputs** — do they change on the correct clock edge only?
4. **For combinational logic** — does output change immediately when inputs change?
5. **Look for violations** — does D change too close to the clock edge? (metastability risk)
6. **Read the binary count sequence** — list Q2Q1Q0 at each clock edge

**Common trap:** An active-LOW CLR asserted (goes to 0) causes immediate reset regardless of clock position. The output changes at the exact moment CLR=0, not at the next clock edge.

**Timing diagram template for a 3-bit ripple counter:**
- QA (MSB) toggles every 4 clock cycles
- QB toggles every 2 clock cycles
- QC (LSB) toggles every clock cycle
- Note the brief glitches at transitions like 7→0 in async counters (Q2Q1Q0 briefly shows 6, 4)

---

## 2.4 HOW TO IMPLEMENT A BOOLEAN FUNCTION

### Using a Decoder
1. Write the function in minterm form: `f = Σm(...)`
2. Choose n:2ⁿ decoder (n = number of variables)
3. Connect selected minterm outputs to OR gate
4. No minimization needed!

**Example:** `f(a,b,c) = Σm(1,3,5,7)` → 3:8 decoder, OR Y1+Y3+Y5+Y7 → detects all odd inputs

### Using a MUX
1. Choose 2ⁿ:1 MUX (n = number of variables)
2. Connect variables to select lines (MSB = highest-order select)
3. Connect truth table values (0/1) to data inputs
4. Enable = 1

**Which is better?** If function has many minterms → decoder + OR is fewer connections. If function has fewer than half minterms active → MUX data inputs are mostly 0s → doesn't help. In practice, both methods are equally valid for exams.

---

## 2.5 HOW TO BUILD HIERARCHICAL SYSTEMS (Decoder/MUX/DEMUX Expansion)

**Universal Rule:**
- MSB of select = bank selector (drives EN of sub-modules with correct polarity)
- Lower bits = local address (fan out to ALL sub-modules simultaneously)
- For DEMUX: data I connects to ALL sub-modules' data inputs
- For MUX: add a final 2:1 MUX to select between sub-module outputs

**Verification Checklist:**
1. Enables mutually exclusive? (never both ON simultaneously) ✓
2. Every output covered by exactly one sub-module? ✓
3. MSB goes to EN with correct polarity? ✓
4. Lower bits fan out to ALL sub-modules? ✓
5. (DEMUX/MUX) Data reaches every sub-module? ✓

---

## 2.6 HOW TO IDENTIFY A CIRCUIT TYPE (Pattern Recognition)

| If you see... | It is... |
|---|---|
| D-FFs with chained clock (Q → next CLK) | Asynchronous ripple counter |
| All FFs share same CLK + combinational logic on D inputs | Synchronous counter |
| D-FFs in chain, input at one end, output at other | Shift register (SISO) |
| Last Q fed back to first D (same polarity) | Ring counter |
| Last Q' (inverted) fed back to first D | Johnson counter |
| XOR in feedback path of shift register | LFSR |
| n inputs → 2ⁿ outputs, exactly one active | Decoder |
| 2ⁿ inputs → 1 output, controlled by n select bits | MUX |
| 1 input → 2ⁿ outputs, controlled by n select bits | DEMUX |
| 2ⁿ inputs → n outputs (priority logic + GS) | Priority Encoder |
| Counter output → decoder input → LED/display | Scanning/sequencing system |
| Counter output → MUX select → output | Waveform generator |
| Two counters + MUX + DEMUX | TDM system |

---

## 2.7 EXAM PROBLEM-SOLVING METHODOLOGY

### "Design a Mod-N counter" — How to Start
1. Is it synchronous or asynchronous? (professor usually says; assume sync unless told async)
2. k = ⌈log₂N⌉ FFs
3. What FF type? D (straightforward) or JK (if asked to minimize)?
4. Write transition table including ALL 2k states
5. Don't-care the unused states (CRITICAL for minimization)
6. K-maps → minimized equations → circuit
7. Self-starting check (trace forbidden states)

### "Implement this function using a MUX/decoder" — How to Start
1. List the truth table
2. Identify minterms
3. For MUX: connect truth table values to data inputs
4. For decoder: OR the minterm outputs
5. Done — no K-map needed!

### "Analyze this timing diagram" — How to Start
1. Identify clock polarity (rising/falling edge)
2. Read each FF output AT the active clock edge
3. Identify the count sequence as a binary number
4. Check for async events (CLR/PR) between clock edges
5. Report the modulus (how many states) and sequence

### "Write VHDL for this circuit" — How to Start
1. Identify: combinational or sequential?
2. Combinational → concurrent assignments or process with full sensitivity list
3. Sequential → process with clock edge detection
4. Async reset? → Add to sensitivity list, check before clock edge
5. Internal state signal needed? → Yes if you need to read back an output port

---

# PART 3 — VHDL + FPGA SECTION

---

## 3.1 VHDL DESIGN STYLES

### Three Levels of Abstraction

| Style | How | When |
|-------|-----|------|
| **Dataflow** | Concurrent signal assignments | Simple combinational logic |
| **Behavioral** | Process blocks with if/case | Complex logic, sequential circuits |
| **Structural** | Component instantiation + port maps | System integration, hierarchical design |

### Behavioral Style — Process Block

```vhdl
process(sensitivity_list)
begin
    -- sequential statements (execute top to bottom)
end process;
```

**Key rules:**
- Process executes when ANY signal in sensitivity list changes
- Inside process: statements execute sequentially (like software)
- Signal assignments inside process take effect **AFTER** the process finishes (last assignment wins)
- Use `<=` for signals, `:=` for variables

**Sensitivity list rule:** Include ALL signals that the process reads (inputs). Omitting a signal = simulation differs from synthesis (synthesis infers a latch or always uses latest value).

### Clocked Process (Edge-Triggered FF)

```vhdl
process(Clk)
begin
    if rising_edge(Clk) then   -- or: Clk'event and Clk='1'
        Q <= D;
    end if;
end process;
```

### Clocked Process with Async Reset (Most Common Exam Question)

```vhdl
process(Clk, CLR)           -- BOTH in sensitivity list!
begin
    if CLR = '0' then       -- async active-LOW reset (check FIRST)
        state <= '0';
    elsif rising_edge(Clk) then
        state <= D;
    end if;
end process;
```

> **Exam rule:** Async inputs (CLR, PR) **MUST** be in the sensitivity list AND checked **BEFORE** the clock edge. If you check CLR inside the rising_edge block, it becomes synchronous reset — different behavior!

### Async vs Sync Reset — Critical Difference

```vhdl
-- ASYNC reset (acts immediately when CLR=0)
process(Clk, CLR)
begin
    if CLR='0' then Q <= '0';       -- fires ANY time CLR=0
    elsif rising_edge(Clk) then Q <= D;
    end if;
end process;

-- SYNC reset (acts only at clock edge when CLR=0)
process(Clk)
begin
    if rising_edge(Clk) then
        if CLR='0' then Q <= '0';   -- fires only at clock edge
        else Q <= D;
        end if;
    end if;
end process;
```

### `rising_edge()` vs `Clk'event`
Both work. `rising_edge(Clk)` is preferred — cleaner, safe for std_logic. `Clk'event and Clk='1'` fires on any 0→1 OR X→1 transition (not just 0→1 strictly).
- Negative edge: `falling_edge(Clk)` or `Clk'event and Clk='0'`

---

## 3.2 COMPONENT EXAMPLES FROM THE PROFESSOR

### D-FF (Negative Edge)

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity D_FF_1 is
    port(D, Clk: in std_logic;
         Q, Qn: out std_logic);
end D_FF_1;

architecture arch of D_FF_1 is
    signal state: std_logic;
begin
    process(Clk)
    begin
        if (Clk'event and Clk = '0') then  -- negative edge
            state <= D;
        end if;
    end process;
    Q  <= state;
    Qn <= not state;
end arch;
```

> **Why internal signal `state`?** Q is declared as OUT — you cannot READ an OUT port inside the architecture. Use an internal signal to store the state and drive Q from it.

### JK-FF with Async CLR and PR

```vhdl
process(Clk, PR, CLR)      -- async inputs MUST be in sensitivity list
begin
    if CLR = '0' then
        state <= '0';       -- async CLEAR (highest priority)
    elsif PR = '0' then
        state <= '1';       -- async PRESET
    elsif (Clk'event and Clk = '0') then
        case JK is
            when "00" => state <= state;       -- hold
            when "01" => state <= '0';         -- sync reset
            when "10" => state <= '1';         -- sync set
            when "11" => state <= not state;   -- toggle
            when others => state <= state;     -- safety
        end case;
    end if;
end process;
```

### T-FF from D-FF (Conversion in VHDL)

```vhdl
-- Convert T-FF behavior using D-FF equation: D = Q XOR T
process(Clk, CLR)
begin
    if CLR = '0' then
        state <= '0';
    elsif rising_edge(Clk) then
        if T = '1' then
            state <= not state;     -- toggle
        end if;
        -- if T='0', state stays (hold)
    end if;
end process;
Q <= state;
```

### 2:4 Decoder (Behavioral)

```vhdl
process(En, X1, X0)
begin
    if En = '1' then
        case (X1 & X0) is
            when "00" => Y <= "0001";
            when "01" => Y <= "0010";
            when "10" => Y <= "0100";
            when "11" => Y <= "1000";
            when others => Y <= "0000";
        end case;
    else
        Y <= "0000";   -- disabled
    end if;
end process;
```

### 4:1 MUX (Behavioral)

```vhdl
process(S, D)
begin
    case S is
        when "00" => Y <= D(0);
        when "01" => Y <= D(1);
        when "10" => Y <= D(2);
        when "11" => Y <= D(3);
        when others => Y <= '0';
    end case;
end process;
```

### 8:3 Priority Encoder (When-Else Dataflow Style)

```vhdl
Y <= "111" when W(7)='1' else
     "110" when W(6)='1' else
     "101" when W(5)='1' else
     "100" when W(4)='1' else
     "011" when W(3)='1' else
     "010" when W(2)='1' else
     "001" when W(1)='1' else
     "000";
GS <= '0' when W = "00000000" else '1';
```

> The `when-else` chain implements priority: first match wins (W(7) has highest priority).

### Mod-6 Synchronous Counter (Behavioral)

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Counter_Mod6 is
    port(Clk, CLR: in std_logic;
         Q: out std_logic_vector(2 downto 0));
end Counter_Mod6;

architecture behavioral of Counter_Mod6 is
    signal count: std_logic_vector(2 downto 0);
begin
    process(Clk, CLR)
    begin
        if CLR = '0' then               -- async active-LOW clear
            count <= "000";
        elsif rising_edge(Clk) then
            if count = "101" then       -- reached 5 (101)
                count <= "000";         -- wrap to 0
            else
                count <= count + 1;     -- increment
            end if;
        end if;
    end process;
    Q <= count;
end behavioral;
```

---

## 3.3 STRUCTURAL DESIGN STYLE

### Structure of a Structural VHDL File

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity TopLevel is
    port(A, B, Clk, CLR: in std_logic;
         Y: out std_logic);
end TopLevel;

architecture STRUCTURE of TopLevel is
    -- 1. Component declarations
    COMPONENT D_FF
        port(D, Clk, CLR: in std_logic;
             Q, Qn: out std_logic);
    END COMPONENT;

    COMPONENT AND_Gate
        port(x1, x2: in std_logic;
             y: out std_logic);
    END COMPONENT;

    -- 2. Internal signal declarations
    SIGNAL t1, t2: std_logic;

BEGIN
    -- 3. Component instantiations
    G1: AND_Gate PORT MAP(x1 => A, x2 => B, y => t1);   -- Named (preferred)
    G2: D_FF PORT MAP(t1, Clk, CLR, t2, open);           -- Positional (use 'open' for unused outputs)
    Y <= t2;
END STRUCTURE;
```

### Two Port Mapping Styles

**Positional (order matters — error-prone):**
```vhdl
G1: Gate_AND PORT MAP(a, b, output);
```

**Named/Nominal (explicit — preferred):**
```vhdl
G1: Gate_AND PORT MAP(x1 => a, x2 => b, y => output);
```

> **Exam advantage of Named mapping:** Connections can be in any order, self-documenting, no accidental swapping of ports. Always use named mapping in exams unless told otherwise.

### Component Definition Locations
1. In a **PACKAGE** (best practice — reusable across files)
2. Within the architecture's declarative region (after `architecture ... is`)
3. In separate VHDL files in the WORK library (file must be compiled first)

---

## 3.4 CLOCK DIVIDER IN VHDL

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ClkDiv is
    port(clk_in: in std_logic;
         clk_out: out std_logic);
end ClkDiv;

architecture behavioral of ClkDiv is
    signal count: integer range 0 to 24999999 := 0;
    signal clk_int: std_logic := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if count = 24999999 then
                count <= 0;
                clk_int <= not clk_int;    -- toggle → 50% duty cycle
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    clk_out <= clk_int;    -- internal signal to avoid reading OUT port
end behavioral;
```

**Why 24,999,999?** 50 MHz has 20 ns period. For 1 Hz: count 25,000,000 cycles then toggle → HIGH for 25M cycles (0.5s) + LOW for 25M cycles (0.5s) = 1 second period = 1 Hz. Duty cycle = 50%.

**Formula:** `count_max = (fclk / (2 × fout)) - 1`

| Desired fout | count_max |
|---|---|
| 1 Hz | 24,999,999 |
| 10 Hz | 2,499,999 |
| 100 Hz | 249,999 |
| 1 kHz | 24,999 |
| 1 MHz | 24 |

---

## 3.5 SYNTHESIZABLE vs NON-SYNTHESIZABLE VHDL

| Synthesizable ✅ | Not Synthesizable ❌ |
|---|---|
| `rising_edge(Clk)` | `wait for 10 ns;` (time delays) |
| `if/case/when` statements | File I/O (`textio`) |
| `std_logic`, `std_logic_vector` | `after` keyword in signal assignments |
| Concurrent signal assignments | `assert` statements (simulation only) |
| Component instantiation | Unbounded loops |
| Integer arithmetic with defined range | `time` type |

> **Key rule:** Synthesis tools generate hardware. Anything that has no hardware equivalent (delays, file access, time-based waits) cannot be synthesized. These constructs are for testbench/simulation only.

**Common student error:**
```vhdl
-- WRONG for synthesis (simulation only):
Q <= D after 5 ns;

-- CORRECT for synthesis:
process(Clk)
begin
    if rising_edge(Clk) then Q <= D; end if;
end process;
```

---

## 3.6 SIGNAL vs VARIABLE

| Feature | Signal | Variable |
|---|---|---|
| Scope | Architecture-wide (visible everywhere) | Local to process only |
| Update timing | After process completes (end of delta cycle) | **Immediately** |
| Assignment operator | `<=` | `:=` |
| Use | Represents hardware wire/net | Temporary computation within process |
| Visible in waveform viewer | Yes | No (must assign to signal to observe) |
| Multiple assignments | Last one wins (in same process) | Each takes effect immediately |

> **Exam trap:** In a process, if you write `A <= B; C <= A;` — C gets the **old** value of A (before this clock edge), not B. Signal updates are deferred. Use a variable if you need the updated value immediately within the same process.

```vhdl
-- Signal trap:
process(Clk)
begin
    if rising_edge(Clk) then
        A <= B;        -- A still has old value here
        C <= A;        -- C gets OLD A, not B!
    end if;
end process;

-- Variable fix:
process(Clk)
    variable A_var: std_logic;
begin
    if rising_edge(Clk) then
        A_var := B;    -- updates immediately
        C <= A_var;    -- C gets new value (= B) ✓
        A <= A_var;    -- drive signal from variable
    end if;
end process;
```

---

# PART 4 — SYSTEM DESIGN SECTION

---

## 4.1 COUNTER + DECODER SYSTEM

**Purpose:** Sequence through outputs one at a time (LED scanning, time-slot activation)

```
Clock → [Clock Divider] → [Mod-8 UP Counter] → [3:8 Decoder] → LED[0..7]
  50MHz        ↓ 1-10Hz       Q2,Q1,Q0                Y0..Y7
```

**Data flow:** Clock → Counter increments → Decoder activates one LED → Next clock edge → Next LED

**VHDL approach:**
```vhdl
signal count_out: std_logic_vector(2 downto 0);
signal slow_clk: std_logic;

-- Instantiate: ClkDiv, Counter, Decoder
-- Connect: slow_clk → Counter → count_out → Decoder inputs
```

**Optimization idea:** For 8 LEDs with simple scanning, a ring counter + no decoder is simpler (each FF drives one LED directly). Use decoder when you need to decode a binary-encoded count.

---

## 4.2 COUNTER + MUX SYSTEM (Waveform Generator)

**Purpose:** Generate any repeating pattern

```
[1kHz Clock] → [Mod-8 Counter] → [8:1 MUX select (S2,S1,S0)] → Output
                  Q2,Q1,Q0         D0-D7 = hardwired pattern (0 or 1)
```

**How to set up the pattern:**
- For `f(a,b,c) = Σm(0,1,2,4)` → D0=D1=D2=D4=1, D3=D5=D6=D7=0
- Counter cycles through 0→7→0, output follows data inputs
- Period = 8 clock cycles = 8ms at 1kHz

**Exam question:** "What is the output frequency if the counter is Mod-8 and clock is 1kHz?"
→ The waveform pattern repeats every 8 clock cycles → frequency = 1kHz/8 = **125 Hz**
But the duty cycle depends on the pattern! If 4 out of 8 inputs are 1 → 50% duty cycle.

---

## 4.3 DECODER + MUX COMBINED SYSTEM

**Purpose:** Function generator or address-mapped data routing

```
Input variables → [Decoder] → minterm outputs
                               ↓ (selected ones)
                           [OR gate] → f(inputs)
```

OR for more complex functions:

```
[Counter] → [Decoder] → [EN inputs of multiple MUXes]
                            ↓ (only one MUX active at a time)
                        MUX A, MUX B, MUX C...
```

**Why combine them?** Decoder selects WHICH subsystem is active (like a chip select). Only one downstream component is enabled at a time. The MUX routes data within the active subsystem.

---

## 4.4 REGISTER + COUNTER SYSTEM (PISO Serializer)

**Purpose:** Convert parallel data to serial stream (UART transmitter, SPI master)

```
[Parallel Data] → [PISO Shift Register] → [Serial Output]
                         ↑
              [Mod-N Counter] driving shift clock
```

**Operation:**
1. Load parallel data (PISO control = Load, 1 clock pulse)
2. Counter increments → shift clock → data shifts out bit by bit
3. After n shifts, load next word

**System-level insight:** This is how USB, Ethernet, and UART all work at the physical layer. Registers are the bridge between parallel (fast, wide) internal buses and serial (slow, single-wire) external lines.

---

## 4.5 TIME DIVISION MULTIPLEXING SYSTEM

**Full TDM System:**

```
Ch0 ─┐                                  ┌─ Ch0
Ch1 ─┤                                  ├─ Ch1
Ch2 ─┤→ [8:1 MUX] ──wire──→ [1:8 DEMUX]├─ Ch2
...  │        ↑                    ↑   └─ ...
Ch7 ─┘   [Mod-8 Counter] ←sync→ [Mod-8 Counter]
              ↑                       ↑
          (same clock, same initial state)
```

**Key design requirements:**
- Both counters must start at the same state (use shared CLR)
- Same clock frequency (same source)
- If clock frequency increases → more channels possible on same wire

**Synchronization problem:** In real systems, use a sync/frame pulse at the start of each cycle. The receiver detects the pulse and resets its counter to align.

---

## 4.6 DISPLAY SYSTEM (7-Segment)

**Single digit:**
```
[BCD Counter (Mod-10)] → [BCD-to-7seg Decoder] → 7-segment display
```

**Multi-digit multiplexed display:**
```
[Fast counter] → [2-bit digit select] → [1:4 DEMUX] → digit enable (common cathode)
                      ↓
              [MUX for data] → [BCD-to-7seg] → segment lines
```

At >100 Hz digit switching, all digits appear simultaneously (persistence of vision). This allows N digits with only N+7 wires instead of 7N wires.

**VHDL approach for 4-digit display:**
- 2-bit digit select counter (running at ~1kHz)
- Case statement: based on digit select → pick which digit's BCD data to display
- BCD-to-7seg conversion lookup table

---

## 4.7 FSM (Finite State Machine) — SYSTEM-LEVEL THINKING

Even if not explicitly called FSM, many counter problems are finite state machines. Key insight for the professor's system questions:

```
Sequential logic = State Register (FFs) + Next-State Logic (combinational) + Output Logic
```

**Moore machine:** Output depends only on current state
**Mealy machine:** Output depends on current state AND inputs

**For exam:** When you see "counter + combinational logic driving LEDs/outputs":
- The counter IS the state register
- The combinational logic IS the output logic
- The counter's next-state logic IS the state transition logic

---

# PART 5 — EXAM CHEATSHEET

---

## 5.1 CRITICAL FORMULAS

| Formula | Meaning |
|---|---|
| Q⁺ = D | D-FF state equation |
| Q⁺ = Q ⊕ T | T-FF state equation |
| Q⁺ = K'Q + JQ' | JK-FF state equation |
| D = Q ⊕ T | T-FF from D-FF conversion |
| D = K'Q + JQ' | JK-FF from D-FF conversion |
| T = Q ⊕ Q⁺ | JK excitation: T=1 if state changes |
| fmax ≤ 1/(n·tpd) | Max freq, asynchronous counter |
| fmax = 1/(tcomb+tsu) | Max freq, synchronous counter |
| fout = fclk/(2·N) | Clock divider (toggle method, count 0 to N-1) |
| count_max = fclk/(2·fout) - 1 | Count limit for target output frequency |
| Duty = (tHIGH/T)×100% | Duty cycle |
| Yi = EN·mi(X) | Decoder output equation |
| Y = EN·Σdi·mi(S) | MUX output equation |
| Johnson states = 2n | Johnson counter states for n FFs |
| LFSR states = 2ⁿ-1 | Near-max LFSR states |
| k = ⌈log₂N⌉ | FFs needed for Mod-N counter |

---

## 5.2 LATCH vs FLIP-FLOP

| | Latch | Flip-Flop |
|---|---|---|
| Trigger | Level-sensitive (while En=1) | Edge-triggered (only at active edge) |
| Output changes | Continuously while En=1 | Only at clock edge |
| Glitch risk | HIGH | None (frozen between edges) |
| Synchronous design | NOT suitable | YES |
| Schematic symbol | No clock arrow | Arrow (▷) on clock input |
| VHDL inference | Incomplete `if` in process | `rising_edge()` in process |
| Master-slave structure | Single latch | Two latches back-to-back |

---

## 5.3 FF TYPE COMPARISON

| | D-FF | T-FF | JK-FF |
|---|---|---|---|
| State equation | Q⁺ = D | Q⁺ = Q⊕T | Q⁺ = K'Q+JQ' |
| Don't cares in excitation | None | None | 50% |
| Logic after K-map | More | Medium | Less (recommended) |
| FPGA implementation | Always D-FF internally | D with XOR | D with mux |
| Best for | Registers, pipelines | Frequency division | Counters, FSMs |

---

## 5.4 SYNCHRONOUS vs ASYNCHRONOUS COUNTER

| | Async (Ripple) | Synchronous |
|---|---|---|
| Clock | Q → next CLK | All FFs share same CLK |
| Speed | 1/(n·tpd) | 1/(tcomb+tsu) — much faster |
| Glitches | YES (spurious states) | NO |
| Design | Simple | K-maps required |
| Arbitrary sequence | Difficult | Easy |
| Decoder attachment | Dangerous (glitches) | Safe |

---

## 5.5 MUX vs DECODER vs DEMUX

| | MUX | Decoder | DEMUX |
|---|---|---|---|
| Inputs | 2ⁿ data + n select | n address + 1 EN | 1 data + n select |
| Outputs | 1 | 2ⁿ (one active) | 2ⁿ (one receives data) |
| Function | Select one input | Activate one output | Route to one output |
| Boolean impl. | Yes (wire truth table) | Yes (OR minterms) | Via decoder (EN=data) |
| Alternative name | ULM | Minterm generator | — |

---

## 5.6 REGISTER TYPES

| Type | Load | Output | Use |
|---|---|---|---|
| PIPO | Parallel | Parallel | Storage, pipeline |
| SISO | Serial | Serial | Delay line |
| SIPO | Serial | Parallel | Deserializer (serial→parallel) |
| PISO | Parallel | Serial | Serializer (parallel→serial) |
| Bidirectional | Both | Both | Flexible shift |
| USR | Both | Both | Universal (S1S0 select) |

---

## 5.7 SPECIAL COUNTER COMPARISON

| Counter | Init State | States | Forbidden State | Feedback |
|---|---|---|---|---|
| Ring | 1-hot (one '1') | n | All-zeros | Q_last → D_first |
| Johnson | All zeros (CLR) | 2n | Others | Q'_last → D_first |
| LFSR | Non-zero seed | 2ⁿ-1 | All-zeros | XOR of taps → D_first |
| Modified LFSR | Any | 2ⁿ | None | XOR + AND detect all-zeros |

---

## 5.8 VHDL QUICK RULES

1. **Sensitivity list** = ALL signals that the process reads (not writes)
2. **Async inputs (CLR, PR)** → must be in sensitivity list AND checked BEFORE clock edge
3. **OUT port cannot be read** → use an internal signal alias, drive OUT from it
4. **Named port mapping** is safer than positional — use it always
5. **`rising_edge(Clk)`** preferred over `Clk'event and Clk='1'`
6. **Signal update** takes effect after process ends (not immediately) — use variable if you need immediate update
7. **`wait for` and `after`** → simulation ONLY, NOT synthesizable
8. **`case` statement** must cover ALL possible values → always add `when others`
9. **Async reset** → checked first in if-elsif chain, before clock edge
10. **Sync reset** → checked inside the clock edge block

---

## 5.9 "IF YOU SEE THIS → THINK ABOUT THIS"

| Clue in question | Think about |
|---|---|
| "At any instant of time" | Asynchronous operation (PR/CLR) |
| "On the next clock edge" | Synchronous operation |
| "Visible to human eye" | Need clock divider (50MHz → ~1-10Hz) |
| "Counter is too slow" | Async counter with too many FFs |
| "Spurious / glitch states" | Async counter propagation delay problem |
| "Self-starting / autonomous" | Check forbidden state transitions |
| "Implement Boolean function" | MUX or Decoder + OR gates |
| "Universal Logic Module" | MUX |
| "Minterm generator" | Decoder |
| "Data routing" | MUX (many→one) or DEMUX (one→many) |
| "Priority" | Priority Encoder |
| "GS output / Group Signal" | Priority Encoder — any input active? |
| "Pseudo-random sequence" | LFSR |
| "1-hot encoding" | Ring counter |
| "Creeping code" | Johnson counter |
| "Divide frequency by 2" | Single T-FF or D-FF in toggle mode |
| "Parallel ↔ Serial" | PISO or SIPO register |
| "Hold data" | Register (PIPO) |
| "Overrides the clock" | Asynchronous inputs (PR, CLR) |
| "Active LOW" | Asserted with 0, deasserted with 1 |
| "Duty cycle 50%" | Toggle-based clock divider |
| "Multiple inputs at once" | Priority encoder needed |
| "Which FF for minimal logic?" | JK-FF (most don't cares in excitation) |
| "Cannot read Q directly" | Use internal signal in VHDL |
| "All FFs same clock" | Synchronous design |
| "Chained clock" | Asynchronous / ripple design |

---

## 5.10 COMMON EXAM TRAPS

1. **Forgetting async inputs in sensitivity list** → simulation differs from hardware
2. **Reading an OUT port** in VHDL → use internal signal alias
3. **Setup/hold violation** → Q goes metastable → undefined behavior
4. **S=R=1 in SR-latch** → forbidden (both Q and Q' go to 0, violating Q'=NOT Q)
5. **All-zeros state in Ring counter** → forbidden (stuck forever — counter never escapes)
6. **Counting spurious states** from async counter timing diagrams as valid states
7. **Using don't-cares wrong** in K-maps — treat unused states as x to ENLARGE groups → better minimization
8. **Forgetting self-starting check** → professor loves this question
9. **Confusing divide-by-N with Mod-N** — Mod-N: counts 0 to N-1; divide-by-N: has N states (any sequence works)
10. **Preset to value X** → "preset to 5 (101)" = PR on FF2, PR on FF0, CLR on FF1 (asynchronous!)
11. **LFSR seed must be non-zero** → all-zeros is a forbidden state that never escapes (XOR of zeros = zero always)
12. **Clock divider formula** → toggle method: fout = fclk/(2×N); NOT fclk/N
13. **VHDL: last signal assignment wins** within same process — signal updates are deferred
14. **JK excitation don't cares** — J is don't-care when Q=1 (K resets regardless); K is don't-care when Q=0 (J sets regardless)
15. **Confusing async reset and sync reset** in VHDL → placement of reset check determines behavior

---

## 5.11 THE PROFESSOR'S FAVORITE QUESTIONS

1. **Draw state diagram + transition table for Mod-N counter → derive FF input equations** (D or JK)
2. **Is the counter self-starting? Justify.** → Trace forbidden states; show they reach valid sequence
3. **How do you preset a counter to value X at any instant?** → Async: PR/CLR on individual FFs
4. **Write behavioral VHDL for D-FF / JK-FF / T-FF with async PR and CLR**
5. **Implement f(a,b,c) = Σm(...) using decoder / MUX. Which is more efficient?**
6. **Design a system: Mod-8 counter + 3:8 decoder + 8 LEDs. Draw block diagram + explain operation**
7. **Maximum frequency of async counter with n FFs and tpd?** → fmax = 1/(n×tpd)
8. **Explain setup and hold time. What happens when violated?** → Metastability
9. **Compare Ring counter vs Johnson counter** — states, initialization, forbidden states, use cases
10. **Why do we need a clock divider on FPGA? How to implement in VHDL?** → 50MHz too fast for LEDs
11. **Explain structural vs behavioral VHDL. Advantages of each?**
12. **Write VHDL for 8:1 MUX with active-LOW strobe using CASE statement**
13. **How to build 3:8 decoder from two 2:4 decoders? Draw block diagram.**
14. **What is Priority Encoder? Difference from basic encoder? What is GS?**
15. **Convert FF: design a T-FF using D-FF. Show excitation tables and derivation.**
16. **Explain what happens in ripple counter when it transitions 7→0. Why is this a problem?**
17. **Design clock divider for 1 Hz from 50 MHz. How many bits needed? What is the count value?**
18. **What is duty cycle? How does toggle method guarantee 50%?**
19. **Explain why async signals must appear before clock check in VHDL process.**
20. **Signal vs variable in VHDL: when does the update take effect?**

---

## 5.12 SYSTEM DESIGN QUICK REFERENCE

### How to Analyze a Combined System in Exam (Fast Method)
1. **Identify the clock source** → What drives everything? (often 50MHz FPGA clock)
2. **Trace the clock path** → Divider? Counter? What frequency reaches each block?
3. **Identify the data path** → Where does data enter? Where does it exit?
4. **Identify the control path** → What enables, selects, or resets subsystems?
5. **Identify the counter's role** → Is it providing addresses (for decoder/MUX) or counting events?
6. **Identify the decoder/MUX role** → Selecting outputs? Implementing functions? Routing data?
7. **Calculate timing** → Period of output? Duty cycle? Latency?

### System = Clock + Data + Control
Every digital system can be decomposed into these three flows. Understanding which signals belong to which flow = understanding the system.

---

*End of Digital Systems 2 Exam Guide — Optimized & Complete. Good luck! 🎯*
