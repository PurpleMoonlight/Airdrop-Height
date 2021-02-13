pragma solidity 0.6.6;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";


contract AirdropBlockHeight is VRFConsumerBase {

    bytes32 internal keyHash;
    uint256 internal fee;
    
    address public owner;
    
    uint256 public blockHeightHigh;
    uint256 public blockHeightLow;
    
    mapping (uint256 => uint256) public airdropHeights;
    uint256 public airdropCount;
    
    uint256 public randomNumber;
 
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ) public
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        owner = msg.sender;
        airdropCount = 0;
    }
    
    
    // Checks if the function caller is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed, uint256 high, uint256 low) public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(high > low, "High must be larger than low.");
        blockHeightLow = low;
        blockHeightHigh = high;
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 spread = blockHeightHigh - blockHeightLow + 1; // inclusive on both sides
        uint256 mod = (randomness % spread);
        randomNumber = randomness;
        airdropHeights[airdropCount] = blockHeightLow + mod;
        airdropCount++;
    }
    
    
}
