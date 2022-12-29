// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../contracts/IWebpage.sol";

address constant ADDRESS_OPERATOR = 0x6221A9c005F6e47EB398fD867784CacfDcFFF4E7;

address constant ADDRESS_EMERGENCY = 0x9Bb098cB9987918120AcB6C30E086d84ab2516Dd;

address constant ADDRESS_SUBMITTER = 0x77A8bdc99112c4eC544D8cE46960683443f624f0;

contract WebpageTest is Test {
	IWebpage public webpage;

	function setUp() public {
		webpage = IWebpage(HuffDeployer.deploy("Webpage"));

		webpage.initialise(
			ADDRESS_OPERATOR,
			ADDRESS_SUBMITTER,
			ADDRESS_EMERGENCY
		);
	}

	function testOperator() public {
		assertEq(webpage.operator(), ADDRESS_OPERATOR);
	}

	function testEmergency() public {
		assertEq(webpage.emergency(), ADDRESS_EMERGENCY);
	}

	function testSubmitter() public {
		assertEq(webpage.submitter(), ADDRESS_SUBMITTER);
	}
}
