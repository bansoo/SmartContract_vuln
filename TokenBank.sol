// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title TokenBank — 이더 예치 은행 (취약 버전)
/// @notice [취약점] 접근 제어 누락(Access Control) — 관리자 전용이어야 할 인출 함수에 권한 검사 없음
contract TokenBank {
    address public owner;
    mapping(address => uint256) public deposits;

    constructor() {
        owner = msg.sender;
    }

    /// 이더 예치
    function deposit() external payable {
        deposits[msg.sender] += msg.value;
    }

    /// 컨트랙트에 모인 전체 잔액을 특정 주소로 인출
    /// ❌ 취약: onlyOwner 등 권한 검사가 없어 누구나 호출해 전체 자금을 탈취할 수 있음
    function withdrawAll(address payable to) external {
        to.transfer(address(this).balance);
    }

    /// 소유자 변경
    /// ❌ 취약: 권한 검사가 없어 누구나 자신을 소유자로 만들 수 있음
    function setOwner(address newOwner) external {
        owner = newOwner;
    }
}
