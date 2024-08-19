# ccip-transfer-usdc-estimate-gas

To verify homework result run:

1. Build the project.

```bash
forge build
```

2. Execute the test to display the console.log output of the gas used during the mock run.

```bash
forge test -vv --isolate
```

3. Find the "Gas used" log entry, then multiply this value by 1.1 to determine the final _gasLimit.

```shell
# Example test execution output:

Logs:
  Gas used: 332146

_gasLimit  = 332146 * 1.1
_gasLimit  = 365360.6 --round_up--> 365361
_gasLimit  = 365_361
```

