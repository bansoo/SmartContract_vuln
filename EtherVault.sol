// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title EtherVault — 사용자별 이더 예치/출금 금고 (수정 버전)
/// @notice [수정] 재진입 방지 — 상태를 먼저 변경(CEI) + nonReentrant 가드 적용
contract EtherVault {
    mapping(address => uint256) public balances;

    // 재진입 방지 락
    uint256 private _locked = 1;
    modifier nonReentrant() {
        require(_locked == 1, "reentrancy");
        _locked = 2;
        _;
        _locked = 1;
    }

    /// 이더 예치
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// 이더 출금
    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "insufficient balance");

        // ✅ 수정: 잔액 차감(Effects)을 외부 호출(Interaction)보다 먼저 수행
        balances[msg.sender] -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
