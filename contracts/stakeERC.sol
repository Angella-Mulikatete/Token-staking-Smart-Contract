// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
pragma solidity ^0.8.20;
// import "./IERC20.sol";

contract StakeERC20{

    using SafeERC20 for IERC20;

    address public tokenAddress;
    address public owner;
    uint256 public stakingDuration; //The duration for which tokens must be staked to receive full rewards

    struct Stake {
        uint256 amount;
        uint256 depositTime;
        uint256 rewardClaimed;
    }

   
    constructor(address _tokenAddress, uint256 _stakingDuration) {
        tokenAddress = _tokenAddress;
        // rewardRate = _rewardRate;
        stakingDuration = _stakingDuration * 60;
        owner = msg.sender;
    }

    address[] public stakeHolders;
   
    mapping(address => Stake) public stakes;
    mapping(address => uint256) private stakeholderIndex;
    mapping(address => bool) private isStakeholder;
    mapping(address => uint) balances;
    mapping(address => uint) timeOfDeposit;

    event stakedSuccessfully(uint256 indexed amount, uint256 indexed depositTime );

    modifier checkAddress(address _address){
         require(_address != address(0), "Address zero detected");
         _;
    }

    //checking if an address is a stakeholder
    function isStakeHolder(address _address) public view checkAddress(_address) returns(bool){
        return isStakeholder[_address];
    }

    //add stakeholder
    function addStakeHolder(address _stakeHolder) public checkAddress(_stakeHolder) {
        if(!isStakeHolder(_stakeHolder)){
            stakeHolders.push(_stakeHolder);
            stakeholderIndex[_stakeHolder] = stakeHolders.length - 1;
        }
    }

    //remove stakeHolder
    function removeStakeHolder(address _stakeHolder) public {
        require(_stakeHolder != address(0), "Address zero detected");
        
        if(isStakeholder[_stakeHolder]){
            uint256 index = stakeholderIndex[_stakeHolder];
            stakeHolders[index] = stakeHolders[stakeHolders.length - 1];
            stakeholderIndex[stakeHolders[index]] = index;
            stakeHolders.pop();
            isStakeholder[_stakeHolder] = false;

        }
    }

    //check your balance 

    function getMyBalance() external view returns(uint256) {
        return balances[msg.sender];
    }

    function deposit(uint _amount) external {
        require(msg.sender != address(0), "address zero detected");
        require(_amount > 0, "cant deposit zero amount");

        uint256 stakeHolderBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(stakeHolderBalance >= _amount, "INSUFFICIENT FUNDS");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount); 
        balances[msg.sender] += _amount;
    }

    //stake your tokens
    function stakeToken(uint256 _amount) external {
        require(_amount > 0, "stake higher than zero");
        require(msg.sender != address(0), "address zero detected");
        if(isStakeHolder(msg.sender)){
            addStakeHolder(msg.sender);
        }

        uint stakeHolderBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(stakeHolderBalance > 0, "INSUFFICIENT FUNDS");

        Stake memory stakeHolderStake = stakes[msg.sender];

        timeOfDeposit[msg.sender] = block.timestamp;
        balances[msg.sender] += _amount;

        stakeHolderStake.amount += _amount;
        stakeHolderStake.depositTime = block.timestamp;

        emit stakedSuccessfully( stakeHolderStake.amount, stakeHolderStake.depositTime);

    }

    function calculateReward(address _staker) public  view returns(uint256){
        Stake memory stakeHolderStake = stakes[_staker];

        uint256 stakingTime = block.timestamp - stakeHolderStake.depositTime;

        if(stakingTime > stakingDuration){
            stakingTime = stakingDuration;
        }

        uint256 rewardRate = (stakeHolderStake.amount)/(stakingDuration);

        uint reward = (stakeHolderStake.amount * rewardRate * stakingTime) / (stakingDuration * 100);
        return reward;

    }

    function depositTime() public view returns(uint256){
        Stake memory sstakes = stakes[msg.sender];
        return (sstakes.depositTime);
    }

    function withdrawTime() external view returns(uint256){
        Stake memory stakeHolderStake = stakes[msg.sender];

        if((stakeHolderStake.depositTime *60) > stakingDuration){
            return 0;
        }else{
            return (block.timestamp - (stakeHolderStake.depositTime *60));
        }
    }

    function withdraw(uint256 _amount) external payable{
        require(_amount > 0, "Cant withdraw zero tokens");
        Stake memory stakeHolderStake = stakes[msg.sender];

        stakeHolderStake.rewardClaimed = calculateReward(msg.sender);
        uint256 reward = stakeHolderStake.rewardClaimed;
        uint256 totalAmount = stakeHolderStake.amount += reward;
        
        IERC20(tokenAddress).safeTransfer(msg.sender, totalAmount);

    }

    function updateStakingDuration(uint _newStakingDuration) internal {
        stakingDuration = _newStakingDuration;
    }

    function getStakes(address Staker) external view returns(uint256 _amount, uint256 _depositTime) {
        Stake memory _stakes = stakes[Staker];
        return(_stakes.amount, _stakes.depositTime);
    }

    function getAllStakesInContract() internal view returns(uint256){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

}