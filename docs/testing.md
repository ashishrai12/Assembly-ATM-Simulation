# Testing Guide

We use a dual-layer testing approach: high-level logic validation via Python simulations and low-level confirmation via assembly automated builds.

## Python Simulation

The `simulator.py` script mimics the behavior of the ATM.

### Running Simulations
```bash
make sim
```
This command will:
1.  Initialize the mock ATM state.
2.  Run through a predefined set of user interactions (Login, Check Balance, etc.).
3.  Generate proper visual plots of the transaction distribution.

## Unit Tests

We use `pytest` to assert the correctness of the simulation logic.

```bash
make test
```

## Assembly Build Validation

Every commit triggers a CI job that compiles the assembly code using `sdcc`. This ensures that:
-   Syntax is correct.
-   Code fits within the 8051 memory constraints.
-   No invalid opcodes are used.
