//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {

constructor()ERC20("DegenToken", "DGT") {
}

mapping(address => bool) private  isWhitelisted;
function mint(address to, uint256 amount) public onlyOwner{
    _mint(to, amount);
}
mapping (address=>uint256) public DGT_Gold_balance;
mapping (address=>uint256) public DGT_Diamond_balance;

function transfertokens(address to, uint256 amount) external {
    require(isWhitelisted[msg.sender] || msg.sender == to, "Only whitelisted addresses or sender can transfer tokens");
    require(balanceOf(msg.sender)>=amount,"Not enough balance");
     _transfer(msg.sender, to, amount);
}

function burn(uint256 amount) public {
    require(balanceOf(msg.sender)>=amount,"Not enough balance");
    _burn(msg.sender, amount);
}

function checkBalance(address account) public view returns (uint256) {
    return balanceOf(account);
}

function Redeem(uint256 choice, uint256 number) external{
    require(isWhitelisted[msg.sender], "Only whitelisted addresses can redeem tokens");
    if(choice==1){
        require(balanceOf(msg.sender)>=number*100,"Not enough balance");
       _burn(msg.sender,number*100);
       DGT_Gold_balance[msg.sender]+=number;
    }
    if(choice==2){
        require(balanceOf(msg.sender)>=number*1000,"Not enough balance");
        _burn(msg.sender, number*1000);
        DGT_Diamond_balance[msg.sender]+=number;
    }
}

function Store(uint256 choice) public pure returns(string memory) {
    if(choice==1){
        return "You have entered choice 1:DGT gold of worth 100 DGT";
    }
    else if(choice==2)
    return "You have entered choice 2: DGT diamond, worth 1000 DGT";
    else 
    return "Invalid Input choose between 1 and 2";
}

function addWhitelistedAddress(address addressk) public onlyOwner {
    isWhitelisted[addressk] = true;
}

function removeWhitelistedAddress(address addressk) public onlyOwner {
    isWhitelisted[addressk] = false;
}
}
