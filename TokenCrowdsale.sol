// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TokenCrowdsale — ETH로 토큰을 구매하는 크라우드세일 (취약 버전)
/// @notice [취약점] 산술 오버플로(Arithmetic) — unchecked 블록에서 곱셈 오버플로 검사 우회
contract TokenCrowdsale {
    mapping(address => uint256) public tokenBalance;
    uint256 public constant RATE = 1000; // 1 wei 당 1000 토큰

    /// ETH를 보내 토큰 구매
    function buy() external payable {
        // ❌ 취약: unchecked 안에서 곱셈이 uint256 최대치를 넘으면 wrap-around 발생
        //    공격자가 매우 큰 msg.value로 tokens를 오버플로시켜 잔액을 왜곡할 수 있음
        unchecked {
            uint256 tokens = msg.value * RATE;
            tokenBalance[msg.sender] += tokens;
        }
    }

    /// 보유 토큰 사용(소각)
    function redeem(uint256 amount) external {
        require(tokenBalance[msg.sender] >= amount, "not enough tokens");
        // ❌ 취약: 여기서도 unchecked 차감이라 잘못된 상태를 그대로 이어감
        unchecked {
            tokenBalance[msg.sender] -= amount;
        }
    }
}
