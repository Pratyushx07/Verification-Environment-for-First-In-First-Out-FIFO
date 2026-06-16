# Synchronous FIFO — UVM Verification Environment

UVM-based functional verification environment for a synchronous FIFO (depth 16, width 8-bit). Built on top of an existing layered-SV testbench, migrated to full UVM with sequences, constrained-random stimulus, scoreboard-based checking, and SVA protocol assertions.

---

## UVM Environment Architecture

```
uvm_test (fifo_rand_test / fifo_wr_rd_test / fifo_write_test)
  └── fifo_env
        ├── fifo_agent
        │     ├── uvm_sequencer  ←── fifo_seq (write / read / rand)
        │     ├── fifo_driver    ←── drives fifo_if signals
        │     └── fifo_monitor   ──► ap (analysis port)
        └── fifo_scoreboard  ◄── ap (analysis imp)
```

**Data flow:**
1. Test starts a sequence on the sequencer
2. Sequence creates and randomizes `fifo_tx` items, sends via `start_item/finish_item`
3. Driver receives items via `get_next_item`, drives DUT interface
4. Monitor observes interface independently, sends observed transactions via `ap.write()`
5. Scoreboard receives transactions, runs reference model (queue), compares expected vs actual

---

## Repository Structure

```
fifo-uvm-verification/
├── rtl/
│   └── fifo.sv                  # Synchronous FIFO RTL (DUT)
├── tb/
│   ├── fifo_if.sv               # Interface
│   ├── fifo_tx.sv               # UVM sequence item (transaction)
│   ├── fifo_seq.sv              # Sequences: write-only, read-only, random
│   ├── fifo_driver.sv           # UVM driver
│   ├── fifo_monitor.sv          # UVM monitor
│   ├── fifo_scoreboard.sv       # UVM scoreboard + reference model
│   ├── fifo_agent.sv            # UVM agent
│   ├── fifo_env.sv              # UVM environment
│   ├── fifo_test.sv             # UVM tests
│   └── tb_top.sv                # Top-level module (DUT + interface + run_test)
├── sva/
│   └── fifo_assertions.sv       # SVA protocol assertions + cover properties
└── sim/
    └── run_sim.tcl              # QuestaSim compile & simulate script
```

---

## Tests

| Test | Description |
|------|-------------|
| `fifo_write_test` | Write-only — fills FIFO to full (16 items) |
| `fifo_wr_rd_test` | Write all 16, then read all 16 — scoreboard verifies FIFO order |
| `fifo_rand_test` | 30 constrained-random write/read transactions |

---

## SVA Assertions

| Assertion | What it checks |
|-----------|---------------|
| `a_no_write_when_full` | Write to full FIFO does not corrupt state |
| `a_no_read_when_empty` | Read from empty FIFO does not corrupt state |
| `a_reset_empty` | FIFO is empty one cycle after reset |
| `a_reset_not_full` | FIFO is not full after reset |
| `a_full_empty_mutex` | full and empty never asserted simultaneously |
| `a_write_clears_empty` | Successful write always deasserts empty next cycle |

Cover properties: FIFO reaches full, FIFO drains to empty, simultaneous read+write.

---

## How to Run

```tcl
vsim -do sim/run_sim.tcl
```

To run a different test, change `+UVM_TESTNAME` in `run_sim.tcl`:
```
+UVM_TESTNAME=fifo_write_test
+UVM_TESTNAME=fifo_wr_rd_test
+UVM_TESTNAME=fifo_rand_test
```
