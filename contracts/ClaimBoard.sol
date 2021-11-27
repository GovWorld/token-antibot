// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;
struct VestingWallet {
    address wallet;
    uint256 totalAmount;
    uint256 monthAmount;
    uint256 startDay;
    uint256 cliff;
}

/**
 * monthlyRate:       the monthly amount of tokens to give access to,
 *                  this is a percentage * 1000000000000000000
 *                  this value is ignored if nonlinear is true
 * cliff:       vesting cliff, dont allow any withdrawal before these days expired
 * nonlinear:       non linear vesting, used for SEED/STRATEGIC/PRIVATE sales
 **/

struct VestingType {
    uint256 monthlyRate;
    uint256 cliff;
    bool nonLinear;
}
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimBoard is Ownable {
    IERC20 govToken;
    mapping(uint => mapping(address => VestingWallet)) public vestingWallets;
    VestingType[] public vestingTypes;
    uint256 totalAllocations = 0;

    uint256 public constant PRECISION = 1e18;
    uint256 public constant ONE_HUNDRED_PERCENT = PRECISION * 100;

    // Non linear unlocks [vesting type => ][i,j] i% per day for j days
    mapping(uint => uint256[][]) public nonLinearUnlocks;

    //tokens already claimed out of allocations.
    mapping(address => uint256) claimed;

    /**
     * Setup the initial supply and types of vesting schemas
     **/
    constructor(address _govToken) {
        //The vesting schedule below is a temporary set of values which is bound to change according to the tokenomics
        govToken = IERC20(_govToken);
        //SEED ROUND
        nonLinearUnlocks[1] = [
            [uint256(0), 14], //14 Day cliff
            [uint256(1000000000000000000), 1], //10% at cliff end 
            [uint256(0), 45], //0 till Month 2 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %
            [uint256(0), 29], //0 till Month 3 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %            
            [uint256(0), 29], //0 till Month 4 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %
            [uint256(0), 29], //0 till Month 5 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %
            [uint256(0), 29], //0 till Month 6 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %
            [uint256(0), 29], //0 till Month 7 
            [uint256(1125000000000000000), 1], //month 2-8 11.25 %
            [uint256(0), 29], //0 till Month 8 
            [uint256(1125000000000000000), 1] //month 2-8 11.25 %
        ];
        //STRATEGIC ROUND
         nonLinearUnlocks[2] = [
            [uint256(0), 7], //14 Day cliff
            [uint256(1000000000000000000), 1], //10% at cliff end 
            [uint256(0), 45], //0 till Month 2 
            [uint256(1500000000000000000), 1], //month 2-7 15%
            [uint256(0), 29], //0 till Month 3 
            [uint256(1500000000000000000), 1], //month 2-7 15%
            [uint256(0), 29], //0 till Month 4 
            [uint256(1500000000000000000), 1], //month 2-7 15%
            [uint256(0), 29], //0 till Month 5 
            [uint256(1500000000000000000), 1], //month 2-7 15%
            [uint256(0), 29], //0 till Month 6 
            [uint256(1500000000000000000), 1], //month 2-7 15%
            [uint256(0), 29], //0 till Month 7 
            [uint256(1500000000000000000), 1] //month 2-7 15%
        ];
        //PRIVATE ROUND
         nonLinearUnlocks[3] = [
            [uint256(500000000000000000), 1], //5% at TGE
            [uint256(0), 29], //1 Month after TGE
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 45], //0 till Month 2 
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 29], //0 till Month 3 
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 29], //0 till Month 4 
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 29], //0 till Month 5 
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 29], //0 till Month 6 
            [uint256(1500000000000000000), 1], //15% for 6 months
            [uint256(0), 29], //0 till Month 7 
            [uint256(500000000000000000), 1] //5% for 7 months
        ];
        // 0: Angel 7%, 7,000,000 - 21 days cliff, At cliff end 10% for 10 months
        vestingTypes.push(VestingType(10000000000000000000, 21 days, false));

        // 1: Seed 8.00%, 8,000,000, 14 days cliff, non linear schedule defined above
        vestingTypes.push(VestingType(0, 14 days, true));

        // 2: Strategic 10%, 10,000,000, 7 Days LOCK, non linear schedule defined above
        vestingTypes.push(VestingType(0, 7 days, true));

        // 3: Pivate 10%, 10,000,000, 1 Days LOCK,  non linear schedule defined above
        vestingTypes.push(VestingType(0, 0 days, true));

        // 4: Team 7%, 7,000,000, 6 Month LOCK, 18 months @ rate of 5.5% per month 
        vestingTypes.push(VestingType(277777777777777800, 180 days, false));

        // 5: Early advisor 2.25%, 2,250,000, 28 days LOCK, 12 months @ rate of 8.33% per month 
        vestingTypes.push(VestingType(277777777777777800, 28 days, false));

        // 6: Future advisor 2.25%, 2,250,000, 28 days LOCK, 12 months @ rate of 8.33% per month 
        vestingTypes.push(VestingType(277777777777777800, 28 days, false));
        
        // 7: GOV Genius rewards 1.50%, 1,500,000 3 days LOCK, 24 months @ rate of 4.16% per month
        vestingTypes.push(VestingType(138888888888888900, 3 days, false));

        // 8: Marketting  10.00%, 10,000,000, 24 months @ rate of 4.16% per month 
        vestingTypes.push(VestingType(138888888888888900, 1 days, false));

        // 9: Ecosystem  10.00%, 10,000,000 36 months 1,080 days 2.7% per month
        vestingTypes.push(VestingType(92592592590000000, 4 days, false));
    }

    // Vested tokens wont be available before the listing time
    function getListingTime() public pure returns (uint256) {
        //return 1631554591;
        return 1640977200;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) private pure returns (uint256) {
        return (x*y)/z;
    }

    function addAllocations(
        address[] memory addresses,
        uint256[] memory totalAmounts,
        uint256 vestingTypeIndex
    ) external onlyOwner returns (bool) {
        require(
            addresses.length == totalAmounts.length,
            "Address and totalAmounts length must be same"
        );
        require(
            vestingTypeIndex < vestingTypes.length,
            "Vesting type isnt found"
        );

        VestingType memory vestingType = vestingTypes[vestingTypeIndex];
        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; i++) {
            address _address = addresses[i];
            uint256 totalAmount = totalAmounts[i];
            // We add 1 to round up, this prevents small amounts from never vesting
            uint256 monthAmount =
                mulDiv(
                    totalAmounts[i],
                    vestingType.monthlyRate,
                    ONE_HUNDRED_PERCENT
                );
            uint256 afterDay = vestingType.cliff;
            addVestingWallet(
                _address,
                totalAmount,
                monthAmount,
                afterDay,
                vestingTypeIndex
            );
            totalAllocations += totalAmount;
        }
        require(govToken.balanceOf(address(this)) > totalAllocations, "Not enough contract balance.");
        return true;
    }

    function addVestingWallet(
        address wallet,
        uint256 totalAmount,
        uint256 monthAmount,
        uint256 cliff,
        uint256 vestingTypeIndex
    ) internal {

        require(
            vestingWallets[vestingTypeIndex][wallet].totalAmount == 0,
            "Vesting wallet already created for this address and type"
        );

        uint256 releaseTime = getListingTime();

        // Create vesting wallets
        VestingWallet memory vestingWallet =
            VestingWallet(
                wallet,
                totalAmount,
                monthAmount,
                releaseTime+cliff,
                cliff
            );

        vestingWallets[vestingTypeIndex][wallet] = vestingWallet;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * Returns the amount of days or months passed with vesting
     * @param cliff lock period 
     * @param isMonth if true returns months passed if false returns days
     */

    function getMonthsOrDays(uint256 cliff, bool isMonth) external view returns (uint256) {
        uint256 releaseTime = getListingTime();
        uint256 time = releaseTime+cliff;

        if (block.timestamp < time) {
            return 0;
        }

        uint256 diff = block.timestamp-time;
        if(isMonth)
            return (diff/30 days);
        else
            return (diff/1 days)+1;
    }

    function isStarted(uint256 startDay) external view returns (bool) {
        uint256 releaseTime = getListingTime();

        if (block.timestamp < releaseTime || block.timestamp < startDay) {
            return false;
        }

        return true;
    }


    // Calculate the amount of unlocked tokens after X days for a given amount, nonlinear
    function calculateNonLinear(uint256 _days, uint256 amount, uint vestingTypeIndex)
        external
        view
        returns (uint256)
    {
        require(vestingTypeIndex == 4 || vestingTypeIndex == 2 || vestingTypeIndex == 3, "Invalid vesting type");
        

        uint256 unlocked = 0;
        uint256 _days_remainder = 0;
        uint256[][] memory _nonLinearUnlocks  = nonLinearUnlocks[vestingTypeIndex];
        for (uint256 i = 0; i < _nonLinearUnlocks.length; i++) {
            if (_days <= _days_remainder) break;

            if (_days-_days_remainder >= _nonLinearUnlocks[i][1]) {
                unlocked = unlocked+(
                    mulDiv(amount, _nonLinearUnlocks[i][0], ONE_HUNDRED_PERCENT)
                        *(_nonLinearUnlocks[i][1])
                );
            }

            if (_days-_days_remainder < _nonLinearUnlocks[i][1]) {
                unlocked = unlocked+(
                    mulDiv(amount, _nonLinearUnlocks[i][0], ONE_HUNDRED_PERCENT)
                        *(_days-(_days_remainder))
                );
            }
            _days_remainder += _nonLinearUnlocks[i][1];
        }

        if (unlocked > amount) {
            unlocked = amount;
        }

        return unlocked;
    }

    // Returns the amount of tokens unlocked by vesting so far
    function getUnlockedVestingAmountByType(address sender, uint256 vestingType)
        external
        view
        returns (uint256)
    {
        if (vestingWallets[vestingType][sender].totalAmount == 0) {
            return 0;
        }

        if (!this.isStarted(vestingWallets[vestingType][sender].cliff)) {
            return 0;
        }

        uint256 transferableAmountNow = 0;
        //fetch number of days of vesting
        uint256 trueMonths = this.getMonthsOrDays(vestingWallets[vestingType][sender].cliff, true);
        
        if (vestingTypes[vestingType].nonLinear == true) {
            uint256 trueDays =   this.getMonthsOrDays(vestingWallets[vestingType][sender].cliff, false);
            transferableAmountNow = this.calculateNonLinear(
                trueDays,
                vestingWallets[vestingType][sender].totalAmount,
                vestingType
            );
        } else {
            transferableAmountNow = vestingWallets[vestingType][sender].monthAmount*(
                trueMonths
            );

        }

        if (transferableAmountNow > vestingWallets[vestingType][sender].totalAmount) {
            return vestingWallets[vestingType][sender].totalAmount;
        }

        return transferableAmountNow;
    }
    // Returns the amount of tokens unlocked by vesting so far
    function getUnlockedVestingAmount(address sender)
        external
        view
        returns (uint256)
    {
        uint256 totalAmount = 0;
        uint256 totalDailyTransferableAmount = 0;
        for(uint256 i = 0; i < vestingTypes.length;  i++){
            totalAmount+= vestingWallets[i][sender].totalAmount;
            totalDailyTransferableAmount = totalDailyTransferableAmount + this.getUnlockedVestingAmountByType(sender,i);
        }
        if (totalDailyTransferableAmount > totalAmount) {
            totalDailyTransferableAmount = totalAmount;
        }
        return totalDailyTransferableAmount;
    }

    /**
     * Returns amount of tokens yet to be unlocked
     * @param sender a vesting wallet.
     */    
     function getRestAmount(address sender) external view returns (uint256) {
        uint256 totalAmount = 0;
        for(uint256 i = 0; i < vestingTypes.length;  i++){
            totalAmount += vestingWallets[i][sender].totalAmount;
        }
        return totalAmount - this.getUnlockedVestingAmount(sender);
    }

    /**
     * returns the number of tokens available for claim.
     * @param sender a vesting wallet.
     */
    function getunclaimed(address sender) external view returns (uint256) {
        return this.getUnlockedVestingAmount(sender) - claimed[sender];
    }

    /**
     * determine if the amount passed is available to sender to claim
     * @param sender a vesting wallet.
     * @param amount number of tokens to be claimed.
     */    
     function canClaim(address sender, uint256 amount)
        public
        view
        returns (bool)
    {
        // Treat as a normal coin if this is not a vested wallet
        uint256 totalAmount = 0;
        bool isStart = false;
        for(uint256 i = 0; i < vestingTypes.length; i++){
            totalAmount = totalAmount + vestingWallets[i][sender].totalAmount;
            if (
                this.isStarted(vestingWallets[i][sender].startDay)
            ) {
                isStart = true;
            }
        }
        require(totalAmount > 0, "0 Vesting Balance");
        // Don't allow vesting if the period has not started yet or if you are below allowance
        if (
            !isStart ||
            amount > this.getunclaimed(sender) 
            ) {
                return false;
            }

        return true;
    }

    function claim(uint256 amount) external {
        require(
            this.canClaim(msg.sender, amount),
            "Unable to transfer, not unlocked yet."
        );
        govToken.approve(msg.sender,amount);
        govToken.transfer(msg.sender,amount);
        claimed[msg.sender] = claimed[msg.sender] + amount;
    }
}