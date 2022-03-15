// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    constructor() payable {
        seed = (block.timestamp + block.difficulty) % 100;
    }

    event NewWave(address from, uint256 timestamp, string message);

    struct wave {
        address waver;
        uint256 timestamp;
        string message;
    }
    wave[] waves;
    mapping(address => uint256) public lastWavedAt;

    function createWave(string memory message) public {
        require(
            lastWavedAt[msg.sender] + 10 seconds < block.timestamp,
            "Must wait 10 seconds before waving again."
        );
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);
        waves.push(wave(msg.sender, block.timestamp, message));
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        emit NewWave(msg.sender, block.timestamp, message);
    }

    function getCount() public view returns (uint256) {
        return totalWaves;
    }

    function getTotalWaves() public view returns (wave[] memory) {
        return waves;
    }
}
