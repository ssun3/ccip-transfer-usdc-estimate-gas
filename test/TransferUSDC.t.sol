// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

// Importing necessary components from the Chainlink and Forge Standard libraries for testing.
import {Test, console, Vm} from "forge-std/Test.sol";
import {BurnMintERC677} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import {MockCCIPRouter} from "@chainlink/contracts-ccip/src/v0.8/ccip/test/mocks/MockRouter.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";
import {TransferUSDC} from "../src/TransferUSDC.sol";
import {SwapTestnetUSDC} from "../src/SwapTestnetUSDC.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    uint256 constant INITIAL_SUPPLY = 1_000_000_000;

    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}

// taken from: https://github.com/compound-finance/comet/blob/f41fec9858ae7e53be6cde96c74c3fa16782fa2a/contracts/test/Fauceteer.sol#L16
contract MockFauceteer {
    /// @notice Mapping of user address -> asset address -> last time the user
    /// received that asset
    mapping(address => mapping(address => uint)) public lastReceived;

    /* errors */
    error BalanceTooLow();
    error RequestedTooFrequently();
    error TransferFailed();

    function drip(address token) public {
        uint balance = ERC20(token).balanceOf(address(this));
        if (balance <= 0) revert BalanceTooLow();

        // if (block.timestamp - lastReceived[msg.sender][token] < 1 days)
        //     revert RequestedTooFrequently();

        lastReceived[msg.sender][token] = block.timestamp;

        bool success = ERC20(token).transfer(msg.sender, balance / 1_000000); // 0.01%
        if (!success) revert TransferFailed();
    }
}

/// @title A test suite for Sender and Receiver contracts to estimate ccipReceive gas usage.
contract TransferUSDCTest is Test {
    // Declaration of contracts and variables used in the tests.
    TransferUSDC public sender;
    CrossChainReceiver public receiver;

    SwapTestnetUSDC public swap;
    MockERC20 public usdc;
    MockERC20 public compoundUsdc;
    MockFauceteer public fauceteer;

    BurnMintERC677 public link;
    MockCCIPRouter public router;

    // Sepolia Chain Selector
    uint64 public constant chainSelector = 16015286601757825753;
    uint64 public constant ONE_USDC = 1_000000;

    function setUp() public {
        router = new MockCCIPRouter();
        link = new BurnMintERC677("ChainLink Token", "LINK", 18, 10 ** 27);
        usdc = new MockERC20();
        compoundUsdc = new MockERC20();
        fauceteer = new MockFauceteer();

        // mint 100 compound usdc test tokens to faucet
        compoundUsdc.mint(address(fauceteer), 100 * ONE_USDC);

        swap = new SwapTestnetUSDC(
            address(usdc),
            address(compoundUsdc),
            address(fauceteer)
        );
        sender = new TransferUSDC(
            address(router),
            address(link),
            address(usdc)
        );
        receiver = new CrossChainReceiver(
            address(router),
            address(compoundUsdc),
            address(swap)
        );

        usdc.approve(address(sender), ONE_USDC);

        // Configuring allowlist settings for testing cross-chain interactions.
        sender.allowlistDestinationChain(chainSelector, true);
        receiver.allowlistSourceChain(chainSelector, true);
        receiver.allowlistSender(address(sender), true);
    }

    function test_transferUSDC() public {
        vm.recordLogs();
        uint64 gasLimit = 500_000; // hard-coded gas limit for the test
        sender.transferUsdc(
            chainSelector,
            address(receiver),
            ONE_USDC,
            gasLimit
        );

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 msgExecutedSignature = keccak256(
            "MsgExecuted(bool,bytes,uint256)"
        );

        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == msgExecutedSignature) {
                (, , uint256 gasUsed) = abi.decode(
                    logs[i].data,
                    (bool, bytes, uint256)
                );
                console.log("Gas used: %d", gasUsed);
            }
        }
    }
}

// forge test -vv --isolate

// Ran 1 test for test/TransferUSDC.t.sol:TransferUSDCTest
// [PASS] test_transferUSDC() (gas: 454317)
// Logs:
//   Gas used: 332146

// Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 8.81ms (2.18ms CPU time)

// Ran 1 test suite in 151.64ms (8.81ms CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)
