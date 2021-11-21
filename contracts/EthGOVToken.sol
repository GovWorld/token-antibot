// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Recommended code by 0xBull
abstract contract BPContract{
    function protect( address sender, address receiver, uint256 amount ) external virtual;
}

contract EthGOVToken is ERC20, Ownable {

    //Recommended code by 0xBull
    BPContract public BP;
    bool public bpEnabled;
    bool public BPDisabledForever = false;

    uint256 public constant PRECISION = 1e18;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    function getMaxTotalSupply() public pure returns (uint256) {
        return 1e8 * PRECISION; // 100 million tokens with 18 decimals
    }

    //** Following implementtations are recommended by 0xBull */
    function setBPAddrss(address _bp) external onlyOwner { 
        require(address(BP)== address(0), "Can only be initialized once"); 
        BP = BPContract(_bp);
    }

    function setBpEnabled(bool _enabled) external onlyOwner {
        bpEnabled = _enabled; 
    }
    function setBotProtectionDisableForever() external onlyOwner{
        require(BPDisabledForever == false);
        BPDisabledForever = true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) override internal virtual {
        if (bpEnabled && !BPDisabledForever){
            BP.protect(sender, recipient, amount);
        }
       super._transfer(sender, recipient, amount);
    }
}