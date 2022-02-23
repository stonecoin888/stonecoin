// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Token is ERC20, Ownable {
  
  uint256 constant TOTAL_SUPPLY = 880_000_000 * 1 ether;
  uint256 constant PERCENT_DIVISOR = 1000;
  uint256 constant MIN_BUY_LIMIT = 350_000;
  uint256 constant MAX_BUY_LIMIT  = 500_000;
  uint8 constant BURN_TAX = 100;
  uint8 constant ADMIN_TAX = 10;
  uint8 constant REWARD_TAX = 25;
  uint256 constant BUY_LIMIT = 1000;

  uint8 private immutable burnTax;
  uint8 private immutable adminTax;
  uint8 private immutable rewardTax;
  
  uint256 public launchedAtTime;
  uint256 public startAtTime;
  uint256 public keepProtectTime = 3 days;
  uint256 public startPendingTime = 5 hours;
  uint256 public buyTotalUSDT;
  bool public isBuyPending;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;
  address public uniswapV2BNBPair;
  address public rewardsPool;
  address public usdt = 0x55d398326f99059fF775485246999027B3197955;
  address public tech = 0x940A9210ff9a6547D9aFA0887AEF7C9A5Ae6100e;
  address public community = 0xF8a96Ff943C4Ef69d3967E212981559B501A5e1B;

  mapping (address => uint256) public usdtBalanceByAddr;
  mapping (address => bool) public pairs;

  event changeTax(uint8 _sellTax, uint8 _buyTax, uint8 _transferTax);
  event changeLiquidityPoolStatus(address lpAddress, bool status);
  event changeRewardsPool(address rewardsPool);
  event changeUniswapPair(address uniswapV2Pair, address uniswapV2BNBPair);
 
  constructor(string memory _name, string memory _symbol, address _owner) ERC20(_name, _symbol) Ownable(_owner) {
   _mint(_owner, TOTAL_SUPPLY);
   burnTax = BURN_TAX;
   adminTax = ADMIN_TAX;
   rewardTax = REWARD_TAX;
   launchedAtTime = block.timestamp;
   startAtTime = block.timestamp + 30 days;
   isBuyPending = false;
   buyTotalUSDT = 0;
   uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  }
 
  function setRewardsPool(address _rewardsPool) external onlyOwner {
    require(_rewardsPool != address(0), "address is 0x0");
    rewardsPool = _rewardsPool;
    emit changeRewardsPool(_rewardsPool);
  }

  function setUniswapPairs(address _uniswapV2Pair, address _uniswapV2BNBPair) external onlyOwner {
    require(_uniswapV2Pair != address(0), "uniswapV2Pair address is 0x0");
    require(_uniswapV2BNBPair!= address(0), "uniswapV2BNBPair address is 0x0");
    uniswapV2Pair = _uniswapV2Pair;
    uniswapV2BNBPair = _uniswapV2BNBPair;
    pairs[uniswapV2Pair] = true;
    pairs[uniswapV2BNBPair] = true;
    emit changeUniswapPair(uniswapV2Pair, uniswapV2BNBPair);
  }

  function isBuy(address sender, address receiver)
        internal 
        view 
        returns (bool)
  {
        receiver;
        return pairs[sender];
  }
  //owner, tech, community are all in base whitelist
  function isInBaseWhitelist(address account)
        public  
        view 
        returns (bool)
  {
	if(account == owner() || account == tech || account == rewardsPool)
		return true;
	else
		return false;
  }

  function _tokenToUsdtValue(
        address sender,
        address receiver,
        uint256 tokenAmount
        ) public view returns (uint256) {
        if (sender == uniswapV2BNBPair) {
            address[] memory _path = new address[](3);
            _path[0] = address(this);
            _path[1] = uniswapV2Router.WETH();
            _path[2] = usdt;
            uint[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, _path);
            if (amounts.length > 0) {
                uint256 usdtValue = amounts[amounts.length - 1];
                return usdtValue;
            }
        } else {
            address[] memory _path = new address[](2);
            _path[0] = address(this);
            _path[1] = usdt;
            uint[] memory amounts = uniswapV2Router.getAmountsOut(tokenAmount, _path);
            if (amounts.length > 0) {
                uint256 usdtValue = amounts[amounts.length - 1];
                return usdtValue;
            }
        }
        receiver;
        return 0;
  }

  function _transfer(address sender, address receiver, uint256 amount) internal virtual override {
    require(sender != receiver, "from and to can not be the same.");
    bool _isBuy = isBuy(sender, receiver);
    if(_isBuy)
    {
	require((startAtTime < block.timestamp) || isInBaseWhitelist(receiver) || (receiver == community), "not start");
	if((receiver == community) && (startAtTime > block.timestamp))
	{
		uint256 usdt_amount = _tokenToUsdtValue(sender, receiver, amount);
		require(buyTotalUSDT + usdt_amount <= MAX_BUY_LIMIT * (10** IERC20Metadata(usdt).decimals()), "community whitelist over max limit");
		buyTotalUSDT = buyTotalUSDT + usdt_amount;
		if(!isBuyPending)
		{
			if(buyTotalUSDT > MIN_BUY_LIMIT * (10** IERC20Metadata(usdt).decimals()))
			{
				//when reach the MIN_BUY_LIMIT, starts trading 5 hours later
				startAtTime = block.timestamp + startPendingTime;
				isBuyPending = true;
			}
		}
	}
	if(!isInBaseWhitelist(receiver) && (receiver != community) && (launchedAtTime + keepProtectTime >= block.timestamp))
	{
            uint256 usdtBalance = _tokenToUsdtValue(sender, receiver, amount);
            usdtBalanceByAddr[receiver] = usdtBalanceByAddr[receiver] + usdtBalance;
            require(usdtBalanceByAddr[receiver] <= BUY_LIMIT * (10** IERC20Metadata(usdt).decimals()), "Protect time max 1000 USDT");
	}
    }

    uint256 burnAmount = amount*burnTax/PERCENT_DIVISOR;
    uint256 adminAmount = amount*adminTax/PERCENT_DIVISOR;
    uint256 rewardAmount = amount*rewardTax/PERCENT_DIVISOR;

    super._burn(sender, burnAmount);
    super._transfer(sender, owner(), adminAmount);
    super._transfer(sender, rewardsPool, rewardAmount);
    super._transfer(sender, receiver, amount - burnAmount - adminAmount - rewardAmount);
  }

}
