// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Script, console2} from "forge-std/Script.sol";

contract Deploy is Script {
    function compile(string memory fileName) public returns (bytes memory bytecode) {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --yul yul/', string.concat(fileName, ".yul --bin | tail -1)")
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    ///@notice Compiles a Yul contract and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param bytecode - Yul contract's bytecode
    ///@return deployedAddress - The address that the contract was deployed to

    function deployContract(bytes memory bytecode) public returns (address) {
        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(deployedAddress != address(0), "YulDeployer could not deploy contract");

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    function run() public {
        bytes memory bytecode = compile("Example");
        vm.broadcast();
        address addr = deployContract(bytecode);
        console2.logAddress(addr);
    }
}
