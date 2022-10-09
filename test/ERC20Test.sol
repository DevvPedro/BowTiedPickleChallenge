// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import "forge-std/Test.sol";
import "../src/ERC20Special.sol";

contract ERC20Test is Test {
    ERC20SPECIAL erc20Special;

    address bobby = address(1);
    address victor = address(2);
    address saul = address(3);

    function setUp() public {
        vm.prank(bobby);
        erc20Special = new ERC20SPECIAL();
    }

    function testInitialStateShouldPass() public {
        assertEq(erc20Special._CAP(),1000000000);
        assertEq(erc20Special._MAX_MINT(), 10000);
        assertEq(erc20Special._owner(), bobby);
        assertEq(erc20Special.pause(), false);
    }

    function testTransferAddressZeroFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_CannotBeZero()'));
        erc20Special.transfer(address(0),10);
    }

    function testApproveAddressZeroFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_CannotBeZero()'));
        erc20Special.approve(address(0),10);
    }

    function testTransferFromShouldFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_InsufficientAllowance()'));
        erc20Special.transferFrom(bobby,victor,10000);
    }

    function testIncreaseAllowanceShouldFail() public {
     vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_InsufficientAllowance()'));
     erc20Special.increaseAllowance(victor,1000);
    }

    function testDecreaseAllowanceShouldFail() public {
     vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_InsufficientAllowance()'));
     erc20Special.decreaseAllowance(victor,1000);
    }
    
    function testPausesedShouldFailNotOwner() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_NotOwner()'));
        erc20Special.paused();
    }

    function testUnpauseShouldFailNotOwner() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_NotOwner()'));
        erc20Special.unPause();
    }

    function testMintShouldFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_Maxmint()'));
        erc20Special.mint(20000);
    }

    function testMintShouldFailPaused() public {
        vm.prank(bobby);
        erc20Special.paused();
         vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_Paused()'));
         erc20Special.mint(100);
    }

    function testBurnShouldFailPaused() public {
        vm.prank(bobby);
        erc20Special.paused();
         vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_Paused()'));
         erc20Special.burn(100);
    }

    
    function testUnpauseShouldFail() public {
        vm.prank(bobby);
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAL_NotPaused()'));
        erc20Special.unPause();
    }

    function testBurnShouldFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAl_InsufficientBalance()'));
        erc20Special.burn(1100);
    }

    function testTransferShouldFail() public {
        vm.expectRevert(abi.encodeWithSignature('ERC20SPECIAl_InsufficientBalance()'));
        erc20Special.transfer(victor,1000);
    }

    function testMintShouldPass() public {
        vm.prank(bobby);
        erc20Special.mint(100);
        assertEq(erc20Special.totalSupply(), 100);
        assertEq(erc20Special.balanceOf(bobby), 100);
    }

    function testBurnShouldPass() public {
        vm.startPrank(bobby);
        erc20Special.mint(100);
        erc20Special.burn(100);
        vm.stopPrank();
        assertEq(erc20Special.totalSupply(), 0);
        assertEq(erc20Special.balanceOf(bobby),0);
    }

    function testTransferShouldPassWithTax() public {
        vm.startPrank(saul);
        erc20Special.mint(10000);
        erc20Special.transfer(victor,10000);
        vm.stopPrank();
        assertEq(erc20Special.balanceOf(saul),0);
        assertEq(erc20Special.balanceOf(victor), 9998);
        assertEq(erc20Special.balanceOf(bobby),2);
    }

    function testApprovalShouldPass() public {
        vm.startPrank(bobby);
        erc20Special.mint(100);
        erc20Special.approve(victor,100);
        vm.stopPrank();
        assertEq(erc20Special.allowance(bobby,victor),100);
    }

    function testTransferFromShouldPassWithTax() public {
        vm.startPrank(saul);
        erc20Special.mint(8000);
        erc20Special.approve(victor,7000);
        erc20Special.transferFrom(saul,victor,7000);
         vm.stopPrank();
        assertEq(erc20Special.allowance(bobby,victor), 0);
        assertEq(erc20Special.balanceOf(saul),1000);
        assertEq(erc20Special.balanceOf(victor),6999);
        assertEq(erc20Special.balanceOf(bobby), 1);
    }

    function testIncreaseAllowanceShouldPass() public {
        vm.startPrank(bobby);
        erc20Special.mint(200);
        erc20Special.approve(victor,100);
        erc20Special.increaseAllowance(victor,100);
        vm.stopPrank();
        assertEq(erc20Special.allowance(bobby, victor), 200);
    }

    function testDecreaseAllowanceShouldPass() public {
        vm.startPrank(bobby);
        erc20Special.mint(200);
        erc20Special.approve(victor,100);
        erc20Special.decreaseAllowance(victor,80);
        vm.stopPrank();
        assertEq(erc20Special.allowance(bobby, victor), 20);
    }

    function testPauseShouldPass() public {
     vm.prank(bobby);
      erc20Special.paused();
      assertEq(erc20Special.pause(), true);
    }

    function testUnpauseShouldPass() public {
        vm.startPrank(bobby);
        erc20Special.paused();
        erc20Special.unPause();
        vm.stopPrank();
        assertEq(erc20Special.pause(), false);
    }
}


