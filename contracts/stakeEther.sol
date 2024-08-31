// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract StakeEth{

    uint256 public depositTime ;
    uint256 public withdrawalTime;
    uint256 public rewardRate;
    address public  owner;

    constructor(uint256 _withdrawDeadline, uint _rewardRate){
        depositTime = block.timestamp;
        withdrawalTime = block.timestamp + (_withdrawDeadline * 60);
        rewardRate = _rewardRate;
        owner = msg.sender;
    }


    mapping(address => uint) public balances;
    mapping(address => uint) public timeOfDeposit;

    modifier hasStakingPeriodEnded(bool){
        require(block.timestamp <= withdrawalTime, "No more Staking");
        _;
    }

    modifier withdrawTimeReached(bool hasReached){
        uint remainingTime = withdrawalTimeLeft();
        require(remainingTime == 0, "Withdrawal time has not yet reached");
        _;
    }

    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }

    event stakeSuccess(address indexed owner, uint amount);
    event withdrawSuccess(uint indexed amount);

    
    function withdrawalTimeLeft() public view returns(uint256){
        if(block.timestamp >= withdrawalTime){
            return (0);
        }else{
            return(withdrawalTime - block.timestamp);
        }
    }


    function stake() external payable hasStakingPeriodEnded(false) {
        require(msg.sender != address(0), "Zero address detected");
        require(msg.value > 0, "stake some amount");
        // require(timeAtDeposit[msg.sender] == depositTime, "Time doesnot match");
        timeOfDeposit[msg.sender] = block.timestamp;
        balances[msg.sender] += msg.value;
        emit stakeSuccess(msg.sender, msg.value);

    }

    function getBalance() external view returns(uint256){
        return balances[msg.sender];
    }

    function withdraw(uint256 _amount) external  onlyOwner returns(uint256) {
        require(msg.sender != address(0), "zero address detected");
        require(balances[msg.sender] >= _amount, "INSUFFICIENT FUNDS");
        
        uint withdrawAmount = balances[msg.sender] + ((withdrawalTime - timeOfDeposit[msg.sender] )*rewardRate);
        // balances[msg.sender]-= _amount;
        balances[msg.sender] = 0;
        uint totalWithdrawal = balances[msg.sender ]+= withdrawAmount;
        emit withdrawSuccess(totalWithdrawal);
        return totalWithdrawal; 

    }

      function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
