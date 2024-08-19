// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {CrossChainReceiver} from "../src/CrossChainReceiver.sol";
import {SwapTestnetUSDC} from "../src/SwapTestnetUSDC.sol";
import {NetworkDetails} from "./Types.sol";

contract DeploySepolia is Script {
    function run() external {
        NetworkDetails memory sepolia = NetworkDetails({
            name: "Sepolia",
            chainSelector: 16015286601757825753,
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            usdc: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            cUSDCv3: 0xAec1F48e02Cfb822Be958B68C7957156EB3F0b6e,
            cUSDCv3_fauceteer: 0x68793eA49297eB75DFB4610B68e076D2A5c7646C
        });

        vm.startBroadcast();

        SwapTestnetUSDC swapContract = new SwapTestnetUSDC(
            sepolia.usdc,
            sepolia.usdc,
            sepolia.cUSDCv3_fauceteer
        );

        CrossChainReceiver crossChainReceiver = new CrossChainReceiver(
            sepolia.router,
            sepolia.cUSDCv3,
            address(swapContract)
        );

        console.log(
            string(abi.encodePacked(sepolia.name, " SwapTestnetUSDC:")),
            address(swapContract)
        );
        console.log(
            string(abi.encodePacked(sepolia.name, " CrossChainReceiver:")),
            address(crossChainReceiver)
        );

        vm.stopBroadcast();
    }
}

// forge script ./script/DeploySepolia.s.sol:DeploySepolia  -vvv --broadcast --rpc-url ethereumSepolia --private-key $PRIVATE_KEY

/*
== Logs ==
  Sepolia SwapTestnetUSDC: 0xaF2Da3F4D0f7D4A582Fe4b49f380cc024911eC58
  Sepolia CrossChainReceiver: 0x020a88dCc9603f2127ADb0B8E3170E5498c06B61

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 10.721645706 gwei

Estimated total gas used for script: 2850291

Estimated amount required: 0.030559810261000446 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xa5e7bbfcebab4805fe0f87051c0cf0e01d1f62bbe0471eebb3108e13c75dd753
Contract Address: 0xaF2Da3F4D0f7D4A582Fe4b49f380cc024911eC58
Block: 6529577
Paid: 0.002468743119948738 ETH (460758 gas * 5.358003811 gwei)


##### sepolia
✅  [Success]Hash: 0xfce3fac4daff18e654fb0e4a8d9f57162865dd2547511987fe1a734e81c36a23
Contract Address: 0x020a88dCc9603f2127ADb0B8E3170E5498c06B61
Block: 6529577
Paid: 0.009282291530237376 ETH (1732416 gas * 5.358003811 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.011751034650186114 ETH (2193174 gas * avg 5.358003811 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
*/
