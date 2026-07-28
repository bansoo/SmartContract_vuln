// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title EtherVault — 사용자별 이더 예치/출금 금고 (취약 버전)
/// @notice [취약점] 재진입(Reentrancy) — 외부 호출이 상태 변경보다 먼저 실행됨
contract EtherVault {
    mapping(address => uint256) public balances;

    /// 이더 예치
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// 이더 출금
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");

        // ❌ 취약: 외부 호출(call)을 잔액 차감보다 먼저 수행 (Checks-Effects-Interactions 위반)
        //    호출된 컨트랙트가 fallback에서 withdraw를 재진입해 잔액을 반복 인출할 수 있음
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] -= amount;
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
