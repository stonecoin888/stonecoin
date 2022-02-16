//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./Ownable.sol";

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) =
        target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
    {
        return
        functionStaticCall(
            target,
            data,
            "Address: low-level static call failed"
        );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return
        functionDelegateCall(
            target,
            data,
            "Address: low-level delegate call failed"
        );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata =
        address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }


    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }


    function paused() public view returns (bool) {
        return _paused;
    }


    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }


    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract LPStake is Ownable, ReentrancyGuard, Pausable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    address public lpAddress;
    address public stAddress;

    uint256 constant BLOCKS_PER_MONTH = 864000;
    uint256 constant NUMBER_DIVISOR = 10;
    uint256 constant REWARD_SHARE_MULTIPLIER = 1e12;

    uint256 public initRewardBlock;  // Initial block number that Token distribution occurs.
    uint256 public lastStakeBlock;  // Last block number that Token distribution occurs.
    uint256 public accRewardTokenPerShare;  // Accumulated Token per share, times 1e12. See below.

    uint256 public lpLockedTotal; //lp amount locked
    uint256 public stRewardTotal; //STONE reward total

    struct User {
	    uint256 amount;	// How many LP the user has provided.
            uint256 rewardDebt; // Reward debt. See explanation below.
            uint256 rewardTotal; // Reward total.
            uint256 rewardPayout; // Reward payout.
	    bool isUsed;          // flag
        //
        // We do some fancy math here. Basically, any point in time, the amount of tokens 
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRewardTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP to a pool. Here's what happens:
        //   1. The pool's `accRewardTokenPerShare` (and `lastStakeBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.

    }
    mapping (address => User) private users;
    uint256 [] reward_tiers = [100,90,80,70,60,50,40,30,20,10,9,8,7,6,5,4];

    event LPStaked(address indexed account, uint256 amount);
    event LPUnstaked(address indexed account, uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);
    event SystemPaused(address indexed owner);
    event SystemUnpaused(address indexed owner);

    constructor(
        address _stAddress,
        address _lpAddress,
	address _init_owner
    ) Ownable (_init_owner){
        lpAddress = _lpAddress;
	stAddress = _stAddress;
	lpLockedTotal = 0;
	stRewardTotal = 0;
	initRewardBlock = block.number;
	lastStakeBlock = initRewardBlock;
    }

    //get acc reward from last reward block 
    function getAccReward() internal view returns (uint256)
    {
	uint256 accReward = 0;
	uint i = (lastStakeBlock - initRewardBlock)/BLOCKS_PER_MONTH;
	uint j = (block.number - initRewardBlock)/BLOCKS_PER_MONTH;
	require(j>=i, "i is greater than j");
	uint len = reward_tiers.length;
	if(i == j && i < len)
	{
		accReward = (block.number - lastStakeBlock)*reward_tiers[i]*1e18/NUMBER_DIVISOR;	
	}else if(i >= len)
	{
		accReward = (block.number - lastStakeBlock)*reward_tiers[15]*1e18/NUMBER_DIVISOR;	
	}
	return accReward;
    }
    //stake LP
    function stake(uint256 _lpAmt)
    public
    whenNotPaused
    returns (uint256)
    {
	require(_lpAmt>0, "_lpAmt is 0");
        IERC20(lpAddress).safeTransferFrom(
            address(msg.sender),
            address(this),
            _lpAmt
        );

        lpLockedTotal = lpLockedTotal.add(_lpAmt);

	emit LPStaked(msg.sender, _lpAmt);
	lastStakeBlock = block.number;

	User storage user = users[msg.sender];
	if(user.isUsed == true)
	{
		uint256 accReward = getAccReward();
		if(lpLockedTotal > 0)
			accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
		uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
		user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
		user.rewardTotal = user.rewardTotal.add(reward);
		user.amount = user.amount.add(_lpAmt);
		return accReward;
	}else
	{
		addUser(msg.sender, _lpAmt);
		return 0;
	}
    }
    //unstake LP
    function unstake(uint256 _lpAmt)
    public
    whenNotPaused
    returns (uint256)
    {
	User storage user = users[msg.sender];
	require(user.isUsed == true, "account no exists.");
	require(user.amount >= _lpAmt, "invalid lpAmt");
	require(_lpAmt > 0, "_lpAmt is 0");

        lastStakeBlock = block.number;

	uint256 accReward = getAccReward();
	if(lpLockedTotal > 0)
		accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
	user.rewardTotal = user.rewardTotal.add(reward);

        lpLockedTotal = lpLockedTotal.sub(_lpAmt);
	user.amount = user.amount.sub(_lpAmt);
	user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
	IERC20(lpAddress).transfer(msg.sender, _lpAmt);
	if(user.amount == 0)
		removeUser(msg.sender);
	emit LPUnstaked(msg.sender, _lpAmt);
        return accReward;
    }

    //claim STONE
    function claimReward()
    public
    nonReentrant
    returns (uint256)
    {
	User storage user = users[msg.sender];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal > 0)
		accRewardTokenPerShare = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
	user.rewardDebt = user.amount.mul(accRewardTokenPerShare).div(REWARD_SHARE_MULTIPLIER);
	user.rewardTotal = user.rewardTotal.add(reward);

	uint256 realReward = user.rewardTotal.sub(user.rewardPayout);
        uint256 stAmt = IERC20(stAddress).balanceOf(address(this));
        if (realReward> stAmt) {
            realReward = stAmt;
        }
	stRewardTotal = stRewardTotal.add(realReward);

        IERC20(stAddress).transfer(msg.sender, realReward);
	user.rewardPayout = user.rewardPayout.add(realReward);
	emit RewardClaimed(msg.sender, realReward);

        return realReward;
    }

    function addUser(address _account, uint256 _lpAmt) internal {
    	User memory user = users[_account];
	require(user.isUsed == false, "account already exists");
	require(_lpAmt > 0, "_lpAmt is 0");
	users[_account] = User(_lpAmt, 0, 0, 0,  true);
    }

    function removeUser(address account) internal {
    	User memory user = users[account];
	require(user.isUsed == true, "account no exists");
	delete users[account];
    }

    function pause() public onlyOwner {
        _pause();
	emit SystemPaused(msg.sender);
    }

    function unpause() public onlyOwner {
        _unpause();
	emit SystemUnpaused(msg.sender);
    }


    //call functions
    function getTotalLockedLP() public view returns (uint256){
    	return lpLockedTotal;
    }

    // Reward available
    function getPendingReward(address account) public view returns (uint256){
	User memory user = users[account];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal == 0)
		return user.rewardTotal.sub(user.rewardPayout);

	uint256 accr = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accr).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
    	return user.rewardTotal.add(reward).sub(user.rewardPayout);
    }
 
    // Reward mined
    function getTotalReward(address account) public view returns (uint256){
	User memory user = users[account];
	require(user.isUsed == true, "account no exists.");
	uint256 accReward = getAccReward();
	if(lpLockedTotal == 0)
		return user.rewardTotal;
	uint256 accr = accRewardTokenPerShare.add(accReward.mul(REWARD_SHARE_MULTIPLIER).div(lpLockedTotal));
	uint256 reward = user.amount.mul(accr).div(REWARD_SHARE_MULTIPLIER).sub(user.rewardDebt);
    	return user.rewardTotal.add(reward);
    }
 
    // UserInfo
    function getUserInfo(address account) public view returns(uint256, uint256, uint256){
	    User memory user = users[account];
	    require(user.isUsed == true, "account no exists.");
	    return(user.amount, user.rewardTotal, user.rewardPayout);
    }
}
