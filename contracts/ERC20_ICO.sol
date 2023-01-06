// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20_ICO is ERC20 {
  address contractOwner;
  address[] whiteList;
  uint publicationTime;
 
  constructor() ERC20 ("MyERC20_ICO", "MEI") {
    contractOwner = msg.sender;
    publicationTime = block.timestamp; 
  }

  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  function transfer(address to, uint256 amount) public override returns (bool) {
    require(amount < 1e60, "too many amount");
    address owner = _msgSender();
    uint rate = getRate();

    require(checkICOStillOpen(rate), "ERC20: sale time is over");
    require(findAddressInWhiteList(owner), "ERC20: transfer available only to addresses from the white list");

    _transfer(owner, to, amount);
    return true;
  }

  function addToWhitelist(address addrToList) public onlyOwner {
    whiteList.push(addrToList);
  }

  function getRate() public view returns(uint) {
    uint rate = 0;
    uint secondsPassed = block.timestamp - publicationTime;
    
    if (secondsPassed < 259200)
      rate = 42;
    else if (secondsPassed < 2592000)
      rate = 21;
    else if (secondsPassed < 3801600)
      rate = 8;  

    return rate;
  }

  function findAddressInWhiteList(address searchedAddr) private view returns(bool) {
    bool found = false;
    for(uint i = 0; i < whiteList.length; i++) {
      if (whiteList[i] == searchedAddr) {
        found = true;
        break;
      }
    }
    return found;
  }

  function buyTokens() public payable returns (bool) {
    uint rate = getRate();
    require(checkICOStillOpen(rate), "ERC20: sale time is over");

    uint tokenAmount = msg.value / 1 ether * rate;
    require(tokenAmount > 0, "ERC20: not enough funds");

    address owner = _msgSender();
    _mint(owner, tokenAmount);
    return true;
  }

  function checkICOStillOpen(uint price) private pure returns (bool) {
    if (price > 0)
      return true;
    else 
      return false;   
  }
}