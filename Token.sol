// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20, Ownable {
  
  uint256 constant TOTAL_SUPPLY = 880000000 * 1 ether;
  uint256 constant PERCENT_DIVISOR = 1000;
  uint8 constant BURN_TAX = 100;
  uint8 constant ADMIN_TAX = 10;
  uint8 constant REWARD_TAX = 25;

  uint8 private burnTax;
  uint8 private adminTax;
  uint8 private rewardTax;
  
  address public rewardsPool;

  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeRewardsPool(address rewardsPool);
 
  constructor(string memory _name, string memory _symbol, address _owner) ERC20(_name, _symbol) Ownable(_owner) {
   _mint(_owner, TOTAL_SUPPLY);
   burnTax = BURN_TAX;
   adminTax = ADMIN_TAX;
   rewardTax = REWARD_TAX;
  }
 
  function setRewardsPool(address _rewardsPool) external onlyOwner {
    rewardsPool = _rewardsPool;
    emit changeRewardsPool(_rewardsPool);
  }

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(sender != receiver, "from and to can not be the same.");
    if(amount == 0)
	return;
    uint256 burnAmount = amount*burnTax/PERCENT_DIVISOR;
    uint256 adminAmount = amount*adminTax/PERCENT_DIVISOR;
    uint256 rewardAmount = amount*rewardTax/PERCENT_DIVISOR;

    super._burn(sender, burnAmount);
    super._transfer(sender, owner(), adminAmount);
    super._transfer(sender, rewardsPool, rewardAmount);
    super._transfer(sender, receiver, amount - burnAmount - adminAmount - rewardAmount);
  }

}
