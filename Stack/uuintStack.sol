// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract uuintStack {
    
    error IndexOutOfBounds();
    uint256[] internal stack;

    //Pushes a new item on to the stack.
    //Array length will overflow if it exceeds 2^256-1.
    function stackPush(uint256 item) external {
        assembly {
            let size := sload(stack.slot)
            sstore(stack.slot, add(size, 1))
            mstore(0x00, stack.slot)
            sstore(add(keccak256(0x00, 0x20), size), item)
        }
    }

    //Removes the last item added to the stack.
    //Will revert IndexOutOfBounds() if the stack is empty.
    function stackPop() external {
        assembly {
            let size := sload(stack.slot)
            if iszero(size) {
                mstore(0x00, 0x4e23d035)
                revert(0x1c, 0x04)
            }
            sstore(stack.slot, sub(size, 1))
        }
    }

    //Returns the amount of items in the stack.
    function stackSize() external view returns (uint256 ret) {
        assembly {
            ret := sload(stack.slot)
        }
    }

    //Set the item at 'index' to 'value'.
    //Will revert IndexOutOfBounds() if the index is out of bounds, use push to grow the stack.
    function setStackIndex(uint256 index, uint256 value) external {
        assembly {
            if iszero(lt(index, sload(stack.slot))) {
                mstore(0x00, 0x4e23d035)
                revert(0x1c, 0x04)
            }
            mstore(0x00, stack.slot)
            sstore(add(keccak256(0x00, 0x20), index), value)
        }
    }

    //Get item at specified 'index' of the stack.
    //Will revert IndexOutOfBounds() if the index is out of bounds.
    function readStackIndex(uint256 index) external view returns (uint256 ret) {
        assembly {
            if iszero(lt(index, sload(stack.slot))) {
                mstore(0x00, 0x4e23d035)
                revert(0x1c, 0x04)
            }
            mstore(0x00, stack.slot)
            ret := sload(add(keccak256(0x00, 0x20), index))
        }
    }

    // Finds distance of 'value' from the top of the stack.
    // Returns 1 if 'value' is at the top of the stack.
    // Returns 0 if 'value' is not found.
    // Expensive, O(n); n = distance from top of stack.
    // Lookups deep in large stacks may run out of gas.
    function findDistance(uint256 value) external view returns (uint256 dist) {
        assembly {
            let size := sload(stack.slot)
            for {let i := sub(size, 1)} gt(size, i) {i := sub(i, 1)} {
                mstore(0x00, stack.slot)
                if eq(sload(add(keccak256(0x00, 0x20), i)), value) {
                    dist := sub(size, i)
                    break
                }
            }
        }
    }
}
