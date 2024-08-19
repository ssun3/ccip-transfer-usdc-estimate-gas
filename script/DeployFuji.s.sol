// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import {TransferUSDC} from "../src/TransferUSDC.sol";
import {NetworkDetails} from "./Types.sol";

contract DeployFuji is Script {
    function run() external {
        NetworkDetails memory fuji = NetworkDetails({
            name: "Fuji",
            chainSelector: 14767482510784806043,
            router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            usdc: 0x5425890298aed601595a70AB815c96711a31Bc65,
            cUSDCv3: 0x59BF4753899C20EA152dEefc6f6A14B2a5CC3021,
            cUSDCv3_fauceteer: 0x45D3465046B72D319ef0090b431678b160B1e628
        });

        vm.startBroadcast();

        TransferUSDC transferContract = new TransferUSDC(
            fuji.router,
            fuji.link,
            fuji.usdc
        );

        console.log(
            string(abi.encodePacked(fuji.name, " TransferUSDC:")),
            address(transferContract)
        );

        vm.stopBroadcast();
    }
}

// forge script ./script/DeployFuji.s.sol:DeployFuji -vvv --broadcast --rpc-url avalancheFuji --private-key $PRIVATE_KEY

/*
== Logs ==
  Fuji TransferUSDC: 0xB71bcBF6404834880c792b46320a023C0d504bf2

## Setting up 1 EVM.

==========================

Chain 43113

Estimated gas price: 51.5 gwei

Estimated total gas used for script: 1214188

Estimated amount required: 0.062530682 ETH

==========================

##### fuji
✅  [Success]Hash: 0xc67c383613f098d2f0bf37bf57ec49be098db1d185452ae780ab3ab2e13dac81
Contract Address: 0xB71bcBF6404834880c792b46320a023C0d504bf2
Block: 35453151
Paid: 0.0247584995 ETH (934283 gas * 26.5 gwei)

✅ Sequence #1 on fuji | Total Paid: 0.0247584995 ETH (934283 gas * avg 26.5 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
*/
