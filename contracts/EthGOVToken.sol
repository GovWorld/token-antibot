// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

//Recommended code by 0xBull
abstract contract BPContract{
    function protect( address sender, address receiver, uint256 amount ) external virtual;
}

contract EthGOVToken is ERC20Upgradeable, OwnableUpgradeable {

    //Recommended code by 0xBull
    BPContract public BP;
    bool public bpEnabled;
    bool public BPDisabledForever = false;

    mapping(address => bool) public freezeList;

    uint256 public constant PRECISION = 1e18;

    /**
     * Setup the initial supply and types of vesting schemas
     **/
    function initialize() initializer public  {
        __Ownable_init();
        __ERC20_init("GOVToken", "GOV");
    }

    function getMaxTotalSupply() public pure returns (uint256) {
        return PRECISION * 1e8; // 100 million tokens with 18 decimals
    }

    function freeze(address user) external onlyOwner {
        freezeList[user] = true;
    }

    function unfreeze(address user) external onlyOwner {
        freezeList[user] = false;
    }

    function isFrozen(address sender) public view returns (bool) {
        if (freezeList[sender] == true) return false;
        return true;
    }

    // @override
    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable) {
        // Reject any transfers that are not allowed
        require(isFrozen(sender), "The account is frozen");
        super._beforeTokenTransfer(sender, recipient, amount);
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
}