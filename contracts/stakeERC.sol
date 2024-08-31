// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
pragma solidity ^0.8.20;
// import "./IERC20.sol";

contract StakeERC20{

    using SafeERC20 for IERC20;

    address public tokenAddress;
    address public owner;
   

    // uint256 public initialTimestamp;//deposit
    // bool public timestampSet;
    uint256 public stakePeriod;
    uint256 public withdrawalDeadline;
    uint256 public depositTime;
     

   
    constructor(address _tokenAddress, uint256 _withdrawDeadline) {
        depositTime = block.timestamp;
        require(tokenAddress != address(0),"Invalid address");
        tokenAddress = _tokenAddress;
        withdrawalDeadline = block.timestamp + (_withdrawDeadline * 60);
        owner = msg.sender;
    }

    address[] public stakeHolders;
   
    // mapping(address => Stake) public stakes;
    mapping(address => uint256) private stakeholderIndex;
    mapping(address => bool) private isStakeholder;

    mapping(address => uint) balances;
    mapping(address => uint) timeOfDeposit;

    event stakedSuccessfully(address indexed addressFrom, uint256 indexed amount );

    modifier hasStakingPeriodEnded(bool){
        require(block.timestamp <= withdrawalDeadline, "No more Staking");
        _;
    }

    modifier checkAddress(address _address){
         require(_address != address(0), "Address zero detected");
         _;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "Only owner");
        _;
    }

    //stake your tokens
    function stakeToken(uint256 _amount) external hasStakingPeriodEnded(false) {
        require(_amount > 0, "stake higher than zero");
        require(msg.sender != address(0), "address zero detected");

        uint stakeHolderBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(stakeHolderBalance > 0, "INSUFFICIENT FUNDS");

        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), _amount); 
        balances[msg.sender] += _amount;

        emit stakedSuccessfully( msg.sender, _amount);

    }

    function calculateReward( uint256 _amount) private  view returns(uint256){
        uint256 stakingTime = withdrawalDeadline - timeOfDeposit[msg.sender];

        if(stakingTime > withdrawalDeadline){
            return 0;
        }

        uint256 rewardRate = (_amount)/(stakingTime);
        uint reward = (_amount * rewardRate * stakingTime) / (stakingTime * 100);
        return reward;

    }

    function withdrawTime() external view returns(uint256){

        if(( timeOfDeposit[msg.sender] *60) > withdrawalDeadline){
            return 0;
        }else{
            return (block.timestamp - (timeOfDeposit[msg.sender] * 60));
        }
    }

    function withdraw(uint256 _amount) external payable{
        require(_amount > 0, "Cant withdraw zero tokens");
        require(balances[msg.sender] >= _amount, "INSUFFICIENT FUNDS");

        uint rewardClaimed = calculateReward(_amount);
        uint256 totalAmount = _amount += rewardClaimed;
        
        IERC20(tokenAddress).safeTransfer(msg.sender, totalAmount);

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
    function removeStakeHolder(address _stakeHolder) public onlyOwner{
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


    function updateStakingDuration(uint _newStakingDuration) internal {
        stakePeriod = _newStakingDuration;
    }

    function getAllStakesInContract() internal view onlyOwner returns(uint256){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

}