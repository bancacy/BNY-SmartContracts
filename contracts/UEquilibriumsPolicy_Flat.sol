pragma solidity 0.5.11;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}
pragma solidity 0.5.11;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );



  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

pragma solidity 0.5.11;



/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is Initializable, IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string memory) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string memory) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }

  uint256[50] private ______gap;
}





pragma solidity 0.5.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}











pragma solidity 0.5.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function initialize(address sender) public initializer {
    _owner = sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}





/**
 * @title Select
 * @dev Median Selection Library
 */
library Select {
    using SafeMath for uint256;

    /**
     * @dev Sorts the input array up to the denoted size, and returns the median.
     * @param array Input array to compute its median.
     * @param size Number of elements in array to compute the median for.
     * @return Median of array.
     */
    function computeMedian(uint256[] memory array, uint256 size)
    
        internal
        view
        returns (uint256)
    {
        require(size > 0 && array.length >= size);
        for (uint256 i = 1; i < size; i++) {
            for (uint256 j = i; j > 0 && array[j-1]  > array[j]; j--) {
                uint256 tmp = array[j];
                array[j] = array[j-1];
                array[j-1] = tmp;
            }
        }
        if (size % 2 == 1) {
            return array[size / 2];
        } else {
            return array[size / 2].add(array[size / 2 - 1]) / 2;
        }
    }
}




pragma solidity 0.5.11;


/**
 * @title SafeMathInt
 * @dev Math operations for int256 with overflow safety checks.
 */
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b)
        internal
        pure
        returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a)
        internal
        pure
        returns (int256)
    {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IOracle {
    function getData() external returns (uint256, bool,address[] memory);
}
/**
 * @title Median Oracle
 *
 * @notice Provides a value onchain that's aggregated from a whitelisted set of
 *         providers.
 */
contract MedianOracle is Ownable, IOracle {
    using SafeMath for uint256;

    struct Report {
        uint256 timestamp;
        uint256 payload;
        
    }
    // uEquils address hardcoded
    address public uEquils;

    // Equilib address hardcoded
    address public Equilib;

    // Addresses of providers authorized to push reports.
    address[] public providers;

    // Addresses of the main providers.
    address[] public mainProviders;

    // Reports indexed by provider address. Report[0].timestamp > 0
    // indicates provider existence.
    mapping (address => Report[2]) public providerReports;

    event ProviderAdded(address provider);
    event ProviderRemoved(address provider);
    event ReportTimestampOutOfRange(address provider);
    event ProviderReportPushed(address indexed provider, uint256 payload, uint256 timestamp);

    // The number of seconds after which the report is deemed expired.
    uint256 public reportExpirationTimeSec;
 
    // The number of seconds since reporting that has to pass before a report
    // is usable. /// Time between reports
    uint256 public reportDelaySec;

    // The minimum number of providers with valid reports to consider the
    // aggregate report valid.
    uint256 public minimumProviders = 1;

    // Timestamp of 1 is used to mark uninitialized and invalidated data.
    // This is needed so that timestamp of 1 is always considered expired.
    uint256 private constant MAX_REPORT_EXPIRATION_TIME = 520 weeks;

    /**
    * @param reportExpirationTimeSec_ The number of seconds after which the
    *                                 report is deemed expired.
    * @param reportDelaySec_ The number of seconds since reporting that has to
    *                        pass before a report is usable
    * @param minimumProviders_ The minimum number of providers with valid
    *                          reports to consider the aggregate report valid.
    */
    constructor(uint256 reportExpirationTimeSec_,
                uint256 reportDelaySec_,
                uint256 minimumProviders_)
        public
    {
        require(reportExpirationTimeSec_ <= MAX_REPORT_EXPIRATION_TIME);
        require(minimumProviders_ > 0);
        reportExpirationTimeSec = reportExpirationTimeSec_;
        reportDelaySec = reportDelaySec_;
        minimumProviders = minimumProviders_;
    }

     /**
     * @notice Sets the report expiration period.
     * @param reportExpirationTimeSec_ The number of seconds after which the
     *        report is deemed expired.
     */
    function setReportExpirationTimeSec(uint256 reportExpirationTimeSec_)
        external
        onlyOwner
    {
        require(reportExpirationTimeSec_ <= MAX_REPORT_EXPIRATION_TIME);
        reportExpirationTimeSec = reportExpirationTimeSec_;
    }

    /**
    * @notice Sets the time period since reporting that has to pass before a
    *         report is usable.
    * @param reportDelaySec_ The new delay period in seconds.
    */
    function setReportDelaySec(uint256 reportDelaySec_)
        external
        onlyOwner
    {
        reportDelaySec = reportDelaySec_;
    }

    /**
    * @notice Sets the minimum number of providers with valid reports to
    *         consider the aggregate report valid.
    * @param minimumProviders_ The new minimum number of providers.
    */
    function setMinimumProviders(uint256 minimumProviders_)
        external
        onlyOwner
    {
        require(minimumProviders_ > 0);
        minimumProviders = minimumProviders_;
    }

    /**
     * @notice Pushes a report for the calling provider.
     * @param payload is expected to be 18 decimal fixed point number.
     */
    
    function pushReport(uint256 payload) external
    {
        require(payload > 0 ,"price must be positive");

        address providerAddress = msg.sender;
        Report[2] storage reports = providerReports[providerAddress];
        uint256[2] memory timestamps = [reports[0].timestamp, reports[1].timestamp];

        require(timestamps[0] > 0);

        uint8 index_recent = timestamps[0] >= timestamps[1] ? 0 : 1;
        uint8 index_past = 1 - index_recent;

        // Check that the push is not too soon after the last one.
        require(timestamps[index_recent].add(reportDelaySec) <= now);

        reports[index_past].timestamp = now;
        reports[index_past].payload = payload;
        

        emit ProviderReportPushed(providerAddress, payload, now);
    }

    /**
    * @notice Invalidates the reports of the calling provider.
    */
    function purgeReports() external
    {
        address providerAddress = msg.sender;
        require (providerReports[providerAddress][0].timestamp > 0);
        providerReports[providerAddress][0].timestamp=1;
        providerReports[providerAddress][1].timestamp=1;
    }

    /**
    * @notice Computes median of provider reports whose timestamps are in the
    *         valid timestamp range.
    * @return AggregatedValue: Median of providers reported values.
    *         valid: Boolean indicating an aggregated value was computed successfully.
    */
    
            
            
        uint256 public index = 0;
        uint256 public mainCount =0;
         uint256 public regularNodes;
        uint256  public size ;
        address public nodeAddress;
        address public MainAddress;
        address[] public validReportsOwners;
        uint256 public nodeIndex;
        uint256[]  public  validReports;


    function getData()
        external
        returns (uint256, bool,address[] memory)

    {

        require(mainProviders.length > 0, "min 1 mainProvider");
        require(providers.length > 1, "min 2 Providers (1 main 1 reg)");

        size=0;
        MainAddress=address(0);
        regularNodes=0;
        validReports.length = 0;
        validReportsOwners.length = 0;
        nodeAddress= address(0);
        nodeIndex=0;
        mainCount =0;
        index=0;
        

        uint256   reportsCount = providers.length;
        
        uint256 minValidTimestamp =  now.sub(reportExpirationTimeSec);
        uint256 maxValidTimestamp =  now.sub(reportDelaySec);

        for (uint256 i = 0; i < reportsCount; i++) {
            address providerAddress = providers[i];
            Report[2] memory reports = providerReports[providerAddress];

            uint8 index_recent = reports[0].timestamp >= reports[1].timestamp ? 0 : 1;
            uint8 index_past = 1 - index_recent;
            uint256 reportTimestampRecent = reports[index_recent].timestamp;
            if (reportTimestampRecent > maxValidTimestamp) {
                // Recent report is too recent.
                
                uint256 reportTimestampPast = providerReports[providerAddress][index_past].timestamp;
                if (reportTimestampPast < minValidTimestamp) {
                    // Past report is too old.
                    
                    emit ReportTimestampOutOfRange(providerAddress);
                } else if (reportTimestampPast > maxValidTimestamp) {
                    // Past report is too recent.
                    
                    emit ReportTimestampOutOfRange(providerAddress);
                } else { 
                    // Using past report.
                    validReportsOwners.push(providerAddress);
                    validReports.push(providerReports[providerAddress][index_past].payload);
                    size++;
                    for (uint256 j = 0; j < mainProviders.length; j++) {
                        if(mainProviders[j] == providerAddress){
                        MainAddress  = mainProviders[j];
                        index = index_past;
                        mainCount++;
                        }
                        if(mainProviders[j] != providerAddress){
                         nodeAddress  = providerAddress;
                         nodeIndex = index_past;
                        }
                        
                    }
                    
                }
            } else { 
                // Recent report is not too recent.
                if (reportTimestampRecent < minValidTimestamp) { 
                    // Recent report is too old.
                    emit ReportTimestampOutOfRange(providerAddress);
                } else {
                    // Using recent report.
                    validReportsOwners.push(providerAddress);
                    validReports.push(providerReports[providerAddress][index_recent].payload);
                    size++;
                    for (uint256 j = 0; j < mainProviders.length; j++) {
                        if(mainProviders[j] == providerAddress){
                        MainAddress  = mainProviders[j];
                        index = index_recent;
                        mainCount++;
                        }
                        if(mainProviders[j] != providerAddress){
                         nodeAddress  = providerAddress;
                         nodeIndex = index_recent;
                        }
                        
                    }
                }
            }
        }

        if (size < minimumProviders) {
            return (0, false,validReportsOwners);
        }
        

         regularNodes = validReports.length - mainCount;
        if(regularNodes == 0 || mainCount == 0 )
        {
          return (0, false,validReportsOwners);
        }
         if((regularNodes - 1) == mainCount){
         return (Select.computeMedian(validReports, size), true,validReportsOwners);

         }
        if(regularNodes != mainCount){

         while((regularNodes - 1) > mainCount){
        validReports.push(providerReports[mainProviders[0]][index].payload);
        size++;
        mainCount++;

        }

        while((regularNodes - 1) < mainCount){
        validReports.push(providerReports[nodeAddress][nodeIndex].payload);
        size++;
        regularNodes++;

        }
        return (Select.computeMedian(validReports, size), true,validReportsOwners);
        }

        validReports.push(providerReports[nodeAddress][nodeIndex].payload);
        size++;
        return (Select.computeMedian(validReports, size), true,validReportsOwners);
    }

    function setEquils(address Equilis_, address EquilibAddress)
        external
        onlyOwner
    {
        Equilib = EquilibAddress;
        uEquils = Equilis_;
    }


    /**
     * @notice Authorizes a provider.
     * @param provider Address of the provider.
     */
    function addProvider(address provider)
        external  
    {   
        require(msg.sender == Equilib, "Only Equilib can add providers");
        require(providerReports[provider][0].timestamp == 0);
        providers.push(provider);
        providerReports[provider][0].timestamp = 1;
        emit ProviderAdded(provider);
    }
    function addMainProvider(address provider)
        external
        onlyOwner
    {
        mainProviders.push(provider);
        emit ProviderAdded(provider);
    }

    /**
     * @notice Revokes provider authorization.
     * @param provider Address of the provider.
     */
    function removeProvider(address provider)
        external
        onlyOwner
    {
        delete providerReports[provider];
        for (uint256 i = 0; i < providers.length; i++) {
            if (providers[i] == provider) {
                if (i + 1  != providers.length) {
                    providers[i] = providers[providers.length-1];
                }
                providers.length--;
                emit ProviderRemoved(provider);
                break;
            }
        }
    }

    /**
     * @return The number of authorized providers.
     */
    function providersSize()
        external
        view
        returns (uint256)
    {
        return providers.length;
    }
}





pragma solidity 0.5.11;




/**
 * @title Equilibrium ER20 token
 * @dev This is part of an implementation of the Equilibrium Stablecoin protocol.
 *      Equilibrium is a normal ERC20 token, but its supply can be adjusted by splitting and
 *      combining tokens proportionally across all wallets.
 *
 *      Equilibrium balances are internally represented with a hidden denomination, 'fracs'.
 *      We support splitting the currency in expansion and combining the currency on contraction by
 *      changing the exchange rate between the hidden 'fracs' and the public 'Equilibriums'.
 */
contract Equilibrium is ERC20Detailed, Ownable {
    // PLEASE READ BEFORE CHANGING ANY ACCOUNTING OR MATH
    // Anytime there is division, there is a risk of numerical instability from rounding errors. In
    // order to minimize this risk, we adhere to the following guidelines:
    // 1) The conversion rate adopted is the number of fracs that equals 1 Equilibrium.
    //    The inverse rate must not be used--TOTAL_FRACS is always the numerator and _totalSupply is
    //    always the denominator. (i.e. If you want to convert fracs to Equilibriums instead of
    //    multiplying by the inverse rate, you should divide by the normal rate)
    // 2) Frac balances converted into Equilibriums are always rounded down (truncated).
    //
    // We make the following guarantees:
    // - If address 'A' transfers x Equilibriums to address 'B'. A's resulting external balance will
    //   be decreased by precisely x Equilibriums, and B's external balance will be precisely
    //   increased by x Equilibriums.
    //
    // We do not guarantee that the sum of all balances equals the result of calling totalSupply().
    // This is because, for any conversion function 'f()' that has non-zero rounding error,
    // f(x0) + f(x1) + ... + f(xn) is not always equal to f(x0 + x1 + ... xn).
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogRebasePaused(bool paused);
    event LogTokenPaused(bool paused);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);
    event nodeAdd(address user, uint256 price);

    // Used for authentication
    address public monetaryPolicy;

    modifier onlyMonetaryPolicy() {
        require(msg.sender == monetaryPolicy);
        _;
    }

    // Precautionary emergency controls.
    bool public rebasePaused;
    bool public tokenPaused;

    modifier whenRebaseNotPaused() {
        require(!rebasePaused);
        _;
    }

    modifier whenTokenNotPaused() {
        require(!tokenPaused);
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    MedianOracle public MedianO;
    sapOracle public SapO;
    
    address public thisAddress;

    uint256 public nodePrice = 50000 * 10**DECIMALS;
    uint256 public rebaseReward = 10000 * 10**DECIMALS;
    uint256 public deploymentTime;

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_EQUILIBRIUMS_SUPPLY = 7 * 10**6 * 10**DECIMALS;

    // TOTAL_FRACS is a multiple of INITIAL_EQUILIBRIUMS_SUPPLY so that _fracsPerEquilibrium is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private constant TOTAL_FRACS = MAX_UINT256 - (MAX_UINT256 % INITIAL_EQUILIBRIUMS_SUPPLY);

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_FRACS + 1) - 1) / 2
    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 10

    uint256 private _totalSupply;
    // Missing supply, to get the right total supply, this amount should be added to _totalSupply.
    uint256 public _missingSupply;
    uint256 public _fracsPerEquilibrium;
    mapping(address => uint256) private _fracBalances;

    // This is denominated in Equilibriums, because the fracs-Equilibriums conversion might change before
    // it's fully paid.
    mapping (address => mapping (address => uint256)) private _allowedEquilibriums;

    /**
     * @param monetaryPolicy_ The address of the monetary policy contract to use for authentication.
     */
    function setMonetaryPolicy(address monetaryPolicy_)
        external
        onlyOwner
    {
        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    /**
     * @dev Pauses or unpauses the execution of rebase operations.
     * @param paused Pauses rebase operations if this is true.
     */
    function setRebasePaused(bool paused)
        external
        onlyOwner
    {
        rebasePaused = paused;
        emit LogRebasePaused(paused);
    }
    



    /**
     * @dev Pauses or unpauses execution of ERC-20 transactions.
     * @param paused Pauses ERC-20 transactions if this is true.
     */
    function setTokenPaused(bool paused)
        external
        onlyOwner
    {
        tokenPaused = paused;
        emit LogTokenPaused(paused);
    }

    function rewardHalving()
        external
    {
        require(now  > deploymentTime.add(90 days), "once in 3 months");
        deploymentTime = now;
        rebaseReward = rebaseReward.div(2);
    }



    /**
     * @dev Notifies Equilibriums contract about a new rebase cycle.
     * @param supplyDelta The number of new equilibrium tokens to add into circulation via expansion.
     * @return The total number of equilibriums after the supply adjustment.
     */
    function rebase(uint256 epoch, int256 supplyDelta, address[] calldata providers,address[] calldata providers2)
        external
        onlyMonetaryPolicy
        whenRebaseNotPaused
        returns (uint256)
    {

        uint256 RewardFrac = rebaseReward.div(_fracsPerEquilibrium);
        uint256 fracValueReward = RewardFrac.mul(_fracsPerEquilibrium);

        uint256 fracRewardValue = ((fracValueReward.div(2)).div(providers.length));
        uint256 i = 0;
        uint256 rewardPlain = (RewardFrac.div(2)).div(providers.length);
        
      
        _missingSupply = _missingSupply.add(rewardPlain.mul(providers2.length));
        _missingSupply = _missingSupply.add(rewardPlain.mul(providers.length));

        while(providers.length > i){
         
          _fracBalances[providers[i]] = _fracBalances[providers[i]].add(fracRewardValue);
          emit Transfer(
            thisAddress,
            providers[i],
            rewardPlain
        );
          i++;
        }

        fracRewardValue = ((fracValueReward.div(2)).div(providers2.length));
        rewardPlain = (RewardFrac.div(2)).div(providers2.length);
        
        i = 0;
        while(providers2.length > i){

          _fracBalances[providers2[i]] = _fracBalances[providers2[i]].add(fracRewardValue);
         
          emit Transfer(
            thisAddress,
            providers2[i],
            rewardPlain
        );
          i++;
        }





        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _fracsPerEquilibrium = TOTAL_FRACS.div(_totalSupply);

        

        // From this point forward, _fracsPerEquilibrium is taken as the source of truth.
        // We recalculate a new _totalSupply to be in agreement with the _fracsPerEquilibrium
        // conversion rate.
        // This means our applied supplyDelta can deviate from the requested supplyDelta,
        // but this deviation is guaranteed to be < (_totalSupply^2)/(TOTAL_FRACS - _totalSupply).
        //
        // In the case of _totalSupply <= MAX_UINT128 (our current supply cap), this
        // deviation is guaranteed to be < 1, so we can omit this step. If the supply cap is
        // ever increased, it must be re-included.
        // _totalSupply = TOTAL_FRACS.div(_fracsPerEquilibrium)

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function initialize(address owner_, MedianOracle MedianAddress, sapOracle sapAddress, address thisContractAddress)
        public
        initializer
    {
        ERC20Detailed.initialize("Bancacy", "BNY", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePaused = false;
        tokenPaused = false;
        
        thisAddress = thisContractAddress;
        deploymentTime = now;
        _totalSupply = INITIAL_EQUILIBRIUMS_SUPPLY;
        _missingSupply = 0;
        _fracBalances[owner_] = TOTAL_FRACS;
        _fracsPerEquilibrium = TOTAL_FRACS.div(_totalSupply);
        nodePrice = nodePrice.mul(_fracsPerEquilibrium);
        rebaseReward = rebaseReward.mul(_fracsPerEquilibrium);
        MedianO = MedianAddress;
        SapO = sapAddress;
        
        emit Transfer(address(0x0), owner_, _totalSupply);
    }

    /**
     * @return The total number of equilibriums.
     */
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who)
        public
        view
        returns (uint256)
    {
        return _fracBalances[who].div(_fracsPerEquilibrium);
    }


    
   
    function   () external payable{
    
    
    uint256 nodePriceFrac = nodePrice.div(_fracsPerEquilibrium);
    uint256 fracValueNode = nodePriceFrac.mul(_fracsPerEquilibrium);

    require(_fracBalances[msg.sender] >= fracValueNode, "You dont have enought BNY");
   _fracBalances[msg.sender] = _fracBalances[msg.sender].sub(fracValueNode);
   _missingSupply = _missingSupply.sub(uint256(nodePriceFrac));
   

    
    MedianO.addProvider(msg.sender);
    SapO.addProvider(msg.sender);
    emit nodeAdd(msg.sender, nodePriceFrac);
    
    
    }






    function BNY_AssetSolidification(address _user, uint256 _value, address[] calldata providers, uint256 reward)
    external
    returns (bool success) {

        require(msg.sender == monetaryPolicy, "No Permission");
        uint256 fracValue = _value.mul(_fracsPerEquilibrium);
        uint256 fracRewardValue = reward.mul(_fracsPerEquilibrium);
        require(_fracBalances[_user] >= fracValue, "User have incufficent balance");
        require(_value > 0, "Cant < 0");
        require(reward > 0, "Cant < 0");

        _fracBalances[_user] = _fracBalances[_user].sub(fracValue);
       
        _missingSupply = _missingSupply.sub(uint256(_value.sub(reward.mul(providers.length))));

        uint256 i = 0;
        while(providers.length > i){
           
          _fracBalances[providers[i]] = _fracBalances[providers[i]].add(fracRewardValue);
          emit Transfer(
            _user,
            providers[i],
            reward
        );
          i++;
        }
       

        
        emit Transfer(
            _user,
            address(0),
            _value
        );
        return true;
    }

    function BNY_AssetLiquidation(address _user,uint256 _value ,address[] calldata providers, uint256 reward)
    external
    returns (bool success) {
      
        require(msg.sender == monetaryPolicy, "No Permission");
        uint256 fracValue = _value.mul(_fracsPerEquilibrium);
        uint256 fracRewardValue = reward.mul(_fracsPerEquilibrium);
        require(_value > 0, "Cant < 0");
        require(reward > 0, "Cant < 0");

        _fracBalances[_user] = _fracBalances[_user].add(fracValue);
       
        _missingSupply = _missingSupply.add(_value.add(reward.mul(providers.length)));

        uint256 i = 0;
        while(providers.length > i){
           
          _fracBalances[providers[i]] = _fracBalances[providers[i]].add(fracRewardValue);
          emit Transfer(
            _user,
            providers[i],
            reward
        );
          i++;
        }

        emit Transfer(
            thisAddress,
            _user,
            _value
        );
        return true;
    }


    




   






    

 

   













    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value)
        public
        validRecipient(to)
        whenTokenNotPaused
        returns (bool)
    {
        uint256 fracValue = value.mul(_fracsPerEquilibrium);
        _fracBalances[msg.sender] = _fracBalances[msg.sender].sub(fracValue);
        _fracBalances[to] = _fracBalances[to].add(fracValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender)
        public
        view
        returns (uint256)
    {
        return _allowedEquilibriums[owner_][spender];
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value)
        public
        validRecipient(to)
        whenTokenNotPaused
        returns (bool)
    {
        _allowedEquilibriums[from][msg.sender] = _allowedEquilibriums[from][msg.sender].sub(value);

        uint256 fracValue = value.mul(_fracsPerEquilibrium);
        _fracBalances[from] = _fracBalances[from].sub(fracValue);
        _fracBalances[to] = _fracBalances[to].add(fracValue);
        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
        public
        whenTokenNotPaused
        returns (bool)
    {
        _allowedEquilibriums[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {
        _allowedEquilibriums[msg.sender][spender] =
            _allowedEquilibriums[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedEquilibriums[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        whenTokenNotPaused
        returns (bool)
    {
        uint256 oldValue = _allowedEquilibriums[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedEquilibriums[msg.sender][spender] = 0;
        } else {
            _allowedEquilibriums[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedEquilibriums[msg.sender][spender]);
        return true;
    }
}


pragma solidity 0.5.11;


/**
 * @title Various utilities useful for uint256.
 */
library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    /**
     * @dev Safely converts a uint256 to an int256.
     */
    function toInt256Safe(uint256 a)
        internal
        pure
        returns (int256)
    {
        require(a <= MAX_INT256);
        return int256(a);
    }
}









/**
 * @title sap Oracle
 *
 * @notice Provides a value onchain that's aggregated from a whitelisted set of
 *         providers.
 */
contract sapOracle is Ownable, IOracle {
    using SafeMath for uint256;

    struct Report {
        uint256 timestamp;
        uint256 payload;
        
    }
    // uEquils address hardcoded
    address public uEquils;

    // Equilib address hardcoded
    address public Equilib;

    // Addresses of providers authorized to push reports.
    address[] public providers;

    // Addresses of the main providers.
    address[] public mainProviders;

    // Reports indexed by provider address. Report[0].timestamp > 0
    // indicates provider existence.
    mapping (address => Report[2]) public providerReports;

    event ProviderAdded(address provider);
    event ProviderRemoved(address provider);
    event ReportTimestampOutOfRange(address provider);
    event ProviderReportPushed(address indexed provider, uint256 payload, uint256 timestamp);

    // The number of seconds after which the report is deemed expired.
    uint256 public reportExpirationTimeSec;
 
    // The number of seconds since reporting that has to pass before a report
    // is usable. /// Time between reports
    uint256 public reportDelaySec;

    // The minimum number of providers with valid reports to consider the
    // aggregate report valid.
    uint256 public minimumProviders = 1;

    // Timestamp of 1 is used to mark uninitialized and invalidated data.
    // This is needed so that timestamp of 1 is always considered expired.
    uint256 private constant MAX_REPORT_EXPIRATION_TIME = 520 weeks;

    /**
    * @param reportExpirationTimeSec_ The number of seconds after which the
    *                                 report is deemed expired.
    * @param reportDelaySec_ The number of seconds since reporting that has to
    *                        pass before a report is usable
    * @param minimumProviders_ The minimum number of providers with valid
    *                          reports to consider the aggregate report valid.
    */
    constructor(uint256 reportExpirationTimeSec_,
                uint256 reportDelaySec_,
                uint256 minimumProviders_)
        public
    {
        require(reportExpirationTimeSec_ <= MAX_REPORT_EXPIRATION_TIME);
        require(minimumProviders_ > 0);
        reportExpirationTimeSec = reportExpirationTimeSec_;
        reportDelaySec = reportDelaySec_;
        minimumProviders = minimumProviders_;
    }

     /**
     * @notice Sets the report expiration period.
     * @param reportExpirationTimeSec_ The number of seconds after which the
     *        report is deemed expired.
     */
    function setReportExpirationTimeSec(uint256 reportExpirationTimeSec_)
        external
        onlyOwner
    {
        require(reportExpirationTimeSec_ <= MAX_REPORT_EXPIRATION_TIME);
        reportExpirationTimeSec = reportExpirationTimeSec_;
    }

    /**
    * @notice Sets the time period since reporting that has to pass before a
    *         report is usable.
    * @param reportDelaySec_ The new delay period in seconds.
    */
    function setReportDelaySec(uint256 reportDelaySec_)
        external
        onlyOwner
    {
        reportDelaySec = reportDelaySec_;
    }

    /**
    * @notice Sets the minimum number of providers with valid reports to
    *         consider the aggregate report valid.
    * @param minimumProviders_ The new minimum number of providers.
    */
    function setMinimumProviders(uint256 minimumProviders_)
        external
        onlyOwner
    {
        require(minimumProviders_ > 0);
        minimumProviders = minimumProviders_;
    }

    /**
     * @notice Pushes a report for the calling provider.
     * @param payload is expected to be 18 decimal fixed point number.
     */
    
    function pushReport(uint256 payload) external
    {
        require(payload > 0 ,"price must be positive");

        address providerAddress = msg.sender;
        Report[2] storage reports = providerReports[providerAddress];
        uint256[2] memory timestamps = [reports[0].timestamp, reports[1].timestamp];

        require(timestamps[0] > 0);

        uint8 index_recent = timestamps[0] >= timestamps[1] ? 0 : 1;
        uint8 index_past = 1 - index_recent;

        // Check that the push is not too soon after the last one.
        require(timestamps[index_recent].add(reportDelaySec) <= now);

        reports[index_past].timestamp = now;
        reports[index_past].payload = payload;
        

        emit ProviderReportPushed(providerAddress, payload, now);
    }

    /**
    * @notice Invalidates the reports of the calling provider.
    */
    function purgeReports() external
    {
        address providerAddress = msg.sender;
        require (providerReports[providerAddress][0].timestamp > 0);
        providerReports[providerAddress][0].timestamp=1;
        providerReports[providerAddress][1].timestamp=1;
    }

    /**
    * @notice Computes median of provider reports whose timestamps are in the
    *         valid timestamp range.
    * @return AggregatedValue: Median of providers reported values.
    *         valid: Boolean indicating an aggregated value was computed successfully.
    */
    
            
          
        uint256 public index = 0;
        uint256 public mainCount =0;
         uint256 public regularNodes;
        uint256  public size ;
        address public nodeAddress;
        address public MainAddress;
        address[] public validReportsOwners;
        uint256 public nodeIndex;
        uint256[]  public  validReports;


    function getData()
        external
        returns (uint256, bool,address[] memory)

    {

        require(mainProviders.length > 0, "min 1 mainProvider");
        require(providers.length > 1, "min 2 Providers (1 main 1 reg)");

        size=0;
        MainAddress=address(0);
        regularNodes=0;
        validReports.length = 0;
        validReportsOwners.length = 0;
        nodeAddress= address(0);
        nodeIndex=0;
        mainCount =0;
        index=0;
        

        uint256   reportsCount = providers.length;
        
        uint256 minValidTimestamp =  now.sub(reportExpirationTimeSec);
        uint256 maxValidTimestamp =  now.sub(reportDelaySec);

        for (uint256 i = 0; i < reportsCount; i++) {
            address providerAddress = providers[i];
            Report[2] memory reports = providerReports[providerAddress];

            uint8 index_recent = reports[0].timestamp >= reports[1].timestamp ? 0 : 1;
            uint8 index_past = 1 - index_recent;
            uint256 reportTimestampRecent = reports[index_recent].timestamp;
            if (reportTimestampRecent > maxValidTimestamp) {
                // Recent report is too recent.
                
                uint256 reportTimestampPast = providerReports[providerAddress][index_past].timestamp;
                if (reportTimestampPast < minValidTimestamp) {
                    // Past report is too old.
                   
                    emit ReportTimestampOutOfRange(providerAddress);
                } else if (reportTimestampPast > maxValidTimestamp) {
                    // Past report is too recent.
                    
                    emit ReportTimestampOutOfRange(providerAddress);
                } else { 
                    // Using past report.
                    validReportsOwners.push(providerAddress);
                    validReports.push(providerReports[providerAddress][index_past].payload);
                    size++;
                    for (uint256 j = 0; j < mainProviders.length; j++) {
                        if(mainProviders[j] == providerAddress){
                        MainAddress  = mainProviders[j];
                        index = index_past;
                        mainCount++;
                        }
                        if(mainProviders[j] != providerAddress){
                         nodeAddress  = providerAddress;
                         nodeIndex = index_past;
                        }
                        
                    }
                    
                }
            } else { 
                // Recent report is not too recent.
                if (reportTimestampRecent < minValidTimestamp) { 
                    // Recent report is too old.
                    emit ReportTimestampOutOfRange(providerAddress);
                } else {
                    // Using recent report.
                    validReportsOwners.push(providerAddress);
                    validReports.push(providerReports[providerAddress][index_recent].payload);
                    size++;
                    for (uint256 j = 0; j < mainProviders.length; j++) {
                        if(mainProviders[j] == providerAddress){
                        MainAddress  = mainProviders[j];
                        index = index_recent;
                        mainCount++;
                        }
                        if(mainProviders[j] != providerAddress){
                         nodeAddress  = providerAddress;
                         nodeIndex = index_recent;
                        }
                        
                    }
                }
            }
        }

        if (size < minimumProviders) {
            return (0, false,validReportsOwners);
        }
        

         regularNodes = validReports.length - mainCount;
        if(regularNodes == 0 || mainCount == 0 )
        {
          return (0, false,validReportsOwners);
        }
         if((regularNodes - 1) == mainCount){
         return (Select.computeMedian(validReports, size), true,validReportsOwners);

         }
        if(regularNodes != mainCount){

         while((regularNodes - 1) > mainCount){
        validReports.push(providerReports[mainProviders[0]][index].payload);
        size++;
        mainCount++;

        }

        while((regularNodes - 1) < mainCount){
        validReports.push(providerReports[nodeAddress][nodeIndex].payload);
        size++;
        regularNodes++;

        }
        return (Select.computeMedian(validReports, size), true,validReportsOwners);
        }

        validReports.push(providerReports[nodeAddress][nodeIndex].payload);
        size++;
        return (Select.computeMedian(validReports, size), true,validReportsOwners);
    }

    function setEquils(address Equilis_,address EquilibAddress)
        external
        onlyOwner
    {
        Equilib = EquilibAddress;
        uEquils = Equilis_;
    }


    /**
     * @notice Authorizes a provider.
     * @param provider Address of the provider.
     */
    function addProvider(address provider)
        external  
    {   
        require(msg.sender == Equilib, "Only Equilib can add providers");
        require(providerReports[provider][0].timestamp == 0);
        providers.push(provider);
        providerReports[provider][0].timestamp = 1;
        emit ProviderAdded(provider);
    }
    function addMainProvider(address provider)
        external
        onlyOwner
    {
        mainProviders.push(provider);
        emit ProviderAdded(provider);
    }

    /**
     * @notice Revokes provider authorization.
     * @param provider Address of the provider.
     */
    function removeProvider(address provider)
        external
        onlyOwner
    {
        delete providerReports[provider];
        for (uint256 i = 0; i < providers.length; i++) {
            if (providers[i] == provider) {
                if (i + 1  != providers.length) {
                    providers[i] = providers[providers.length-1];
                }
                providers.length--;
                emit ProviderRemoved(provider);
                break;
            }
        }
    }

    /**
     * @return The number of authorized providers.
     */
    function providersSize()
        external
        view
        returns (uint256)
    {
        return providers.length;
    }
}













pragma solidity 0.5.11;

    

      contract XBNY is Ownable { 

    using SafeMath for uint256;

    string  public name = "BANCACY";
    string  public symbol = "XBNY";
    string  public standard = "XBNY Token";
    uint256 public decimals = 9 ;
    uint256 public totalSupply;
    address public UEquilibriumsPolicy;
    
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor ()  public {
        totalSupply = 0;
        balanceOf[msg.sender] = 0;
        emit Transfer(address(0x0), msg.sender, totalSupply);
    }

    

    function setEquilibriumsPolicy(address EquilibriumsPolicy)
        external
        onlyOwner
    {
        UEquilibriumsPolicy = EquilibriumsPolicy;
    }
    

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value,"You dont have sufficent amount of tokens");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from],"");
        require(_value <= allowance[_from][msg.sender],"");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function reduceXBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == UEquilibriumsPolicy,"No Premission");
        require(balanceOf[user] >= value, "User have incufficent balance");

        balanceOf[user] = balanceOf[user].sub(value);
        totalSupply = totalSupply.sub(value);

        emit Transfer(user, address(2), value);

        return true;
    }
    function increaseXBNY(address user,uint256 value) public returns (bool success) {
        require(msg.sender == UEquilibriumsPolicy,"No Premission");
        
        
        balanceOf[user] = balanceOf[user].add(value);
        totalSupply = totalSupply.add(value);

        emit Transfer(address(2), user, value);

        return true;
    }     

    function GetbalanceOf(address user) public returns (uint256 balance) {
        require(msg.sender == UEquilibriumsPolicy,"No Premission");
        
        return balanceOf[user];
    }


}




























pragma solidity 0.5.11;






/**
 * @title uEquilibriums Monetary Supply Policy
 * @dev This is an implementation of the uEquilibriums Stablecoin protocol.
 *      uEquilibriums operates symmetrically on expansion and contraction. It will both split and
 *      combine coins to maintain a stable unit price.
 *
 *      This component regulates the token supply of the uEquilibriums ERC20 token in response to
 *      market oracles.
 */
contract UEquilibriumsPolicy is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using UInt256Lib for uint256;

    
    
      event Price_req(bool state);

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        uint256 sap,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );

    Equilibrium public uEquils;
    XBNY public xBNY;


    address public BNYaddress;
    address public XBNYaddress;

    // Provides the current sap, as an 18 decimal fixed point number.
    IOracle public sapOracle;

    // Market oracle provides the token/USD exchange rate as an 18 decimal fixed point number.
    // (eg) An oracle value of 1.5e18 it would mean 1 BNY is trading for $1.50.
    IOracle public marketOracle;

    // If the current exchange rate is within this fractional distance from the target, no supply
    // update is performed. Fixed point number--same format as the rate.
    // (ie) abs(rate - targetRate) / targetRate < deviationThreshold, then no supply change.
    // DECIMALS Fixed point number.
    uint256 public deviationThreshold;

    // The rebase lag parameter, used to dampen the applied supply adjustment by 1 / rebaseLag
    // Check setRebaseLag comments for more details.
    // Natural number, no decimal places.
    uint256 public rebaseLag;

    // More than this much time must pass between rebase operations.
    uint256 public minRebaseTimeIntervalSec;

    // Block timestamp of last rebase operation
    uint256 public lastRebaseTimestampSec;

    // The rebase window begins this many seconds into the minRebaseTimeInterval period.
    // For example if minRebaseTimeInterval is 24hrs, it represents the time of day in seconds.
    uint256 public rebaseWindowOffsetSec;

    // The length of the time window where a rebase operation is allowed to execute, in seconds.
    uint256 public rebaseWindowLengthSec;

    // The number of rebase cycles since inception
    uint256 public epoch;

    uint256 private constant DECIMALS = 18;

    // Due to the expression in computeSupplyDelta(), MAX_RATE * MAX_SUPPLY must fit into an int256.
    // Both are 18 decimals fixed point numbers.
    uint256 private constant MAX_RATE = 10**6 * 10**DECIMALS;
    // MAX_SUPPLY = MAX_INT256 / MAX_RATE
    uint256 private constant MAX_SUPPLY = ~(uint256(1) << 255) / MAX_RATE;

    /**
     * @notice Anyone can call this function to initiate a new rebase operation, provided more than
     *         the minimum time period has elapsed.
     * @dev The supply adjustment equals (_totalSupply * DeviationFromTargetRate) / rebaseLag
     *      Where DeviationFromTargetRate is (MarketOracleRate - targetRate) / targetRate
     *      and targetRate is SapOracleRate / baseSap
     */
    function rebase() external {
        require(inRebaseWindow());

        // This comparison also ensures there is no reentrancy.
        require(lastRebaseTimestampSec.add(minRebaseTimeIntervalSec) < now);

        // Snap the rebase time to the start of this window.
        lastRebaseTimestampSec = now.sub(
            now.mod(minRebaseTimeIntervalSec)).add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        uint256 sap;
        bool sapValid;
        address[] memory reporters1;
        (sap, sapValid, reporters1) = sapOracle.getData();
        require(sapValid);

        

        uint256 exchangeRate;
        bool rateValid;
        address[] memory reporters2;
        (exchangeRate, rateValid, reporters2) = marketOracle.getData();
        require(rateValid);

        if (exchangeRate > MAX_RATE) {
            exchangeRate = MAX_RATE;
        }

        uint256 targetRate = exchangeRate;

        int256 supplyDelta = computeSupplyDelta(targetRate,sap);

        // Apply the Dampening factor.
        supplyDelta = supplyDelta.div(rebaseLag.toInt256Safe());

        if (supplyDelta > 0 && uEquils.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(uEquils.totalSupply())).toInt256Safe();
        }

        uint256 supplyAfterRebase = uEquils.rebase(epoch, supplyDelta,reporters1 ,reporters2);
        assert(supplyAfterRebase <= MAX_SUPPLY);
        emit LogRebase(epoch, exchangeRate, sap, supplyDelta, now);
    }

    /**
     * @notice Sets the reference to the sap oracle.
     * @param sapOracle_ The address of the sap oracle contract.
     */
    function setSapOracle(IOracle sapOracle_)
        external
        onlyOwner
    {
        sapOracle = sapOracle_;
    }

    /**
     * @notice Sets the reference to the market oracle.
     * @param marketOracle_ The address of the market oracle contract.
     */
    function setMarketOracle(IOracle marketOracle_)
        external
        onlyOwner
    {
        marketOracle = marketOracle_;
    }

    /**
     * @notice Sets the deviation threshold fraction. If the exchange rate given by the market
     *         oracle is within this fractional distance from the targetRate, then no supply
     *         modifications are made. DECIMALS fixed point number.
     * @param deviationThreshold_ The new exchange rate threshold fraction.
     */
    function setDeviationThreshold(uint256 deviationThreshold_)
        external
        onlyOwner
    {
        deviationThreshold = deviationThreshold_;
    }

    /**
     * @notice Sets the rebase lag parameter.
               It is used to dampen the applied supply adjustment by 1 / rebaseLag
               If the rebase lag R, equals 1, the smallest value for R, then the full supply
               correction is applied on each rebase cycle.
               If it is greater than 1, then a correction of 1/R of is applied on each rebase.
     * @param rebaseLag_ The new rebase lag parameter.
     */
    function setRebaseLag(uint256 rebaseLag_)
        external
        onlyOwner
    {
        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }

    /**
     * @notice Sets the parameters which control the timing and frequency of
     *         rebase operations.
     *         a) the minimum time period that must elapse between rebase cycles.
     *         b) the rebase window offset parameter.
     *         c) the rebase window length parameter.
     * @param minRebaseTimeIntervalSec_ More than this much time must pass between rebase
     *        operations, in seconds.
     * @param rebaseWindowOffsetSec_ The number of seconds from the beginning of
              the rebase interval, where the rebase window begins.
     * @param rebaseWindowLengthSec_ The length of the rebase window in seconds.
     */
    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_)
        external
        onlyOwner
    {
        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }

    /**
     * @dev ZOS upgradable contract initialization method.
     *      It is called at the time of contract creation to invoke parent class initializers and
     *      initialize the contract's state variables.
     */
    function initialize(address owner_, Equilibrium uEquils_,XBNY xBNY_)
        public
        initializer
    {
        Ownable.initialize(owner_);

        // deviationThreshold = 0.05e18 = 5e16
        deviationThreshold = 5 * 10 ** (DECIMALS-2);

        rebaseLag = 40;
        // minRebaseTimeIntervalSec = 6 hours;
        minRebaseTimeIntervalSec = 10 seconds;
        rebaseWindowOffsetSec = 0 minutes; 
         rebaseWindowLengthSec = 10 seconds;
        // rebaseWindowLengthSec = 15 minutes;
        lastRebaseTimestampSec = 0;
        epoch = 0;
        
       
        xBNY = xBNY_;
        uEquils = uEquils_;
    
    }

    /**
     * @return If the latest block timestamp is within the rebase time window it, returns true.
     *         Otherwise, returns false.
     */
    function inRebaseWindow() public view returns (bool) {
        return (
            now.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            now.mod(minRebaseTimeIntervalSec) < (rebaseWindowOffsetSec.add(rebaseWindowLengthSec))
        );
    }

    /**
     * @return Computes the total supply adjustment in response to the exchange rate
     *         and the targetRate.
     */
    function computeSupplyDelta(uint256 rate, uint256 targetRate)
        private
        view
        returns (int256)
    {
        if (withinDeviationThreshold(rate, targetRate)) {
            return 0;
        }

        // supplyDelta = totalSupply * (rate - targetRate) / targetRate
        int256 targetRateSigned = targetRate.toInt256Safe();
        return uEquils.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    /**
     * @param rate The current exchange rate, an 18 decimal fixed point number.
     * @param targetRate The target exchange rate, an 18 decimal fixed point number.
     * @return If the rate is within the deviation threshold from the target rate, returns true.
     *         Otherwise, returns false.
     */
    function withinDeviationThreshold(uint256 rate, uint256 targetRate)
        private
        view
        returns (bool)
    {
        uint256 absoluteDeviationThreshold = targetRate.mul(deviationThreshold)
            .div(10 ** DECIMALS);

        return (rate >= targetRate && rate.sub(targetRate) < absoluteDeviationThreshold)
            || (rate < targetRate && targetRate.sub(rate) < absoluteDeviationThreshold);
    }
    

    // Pre asset solidification or liquidation, Nodes are listening to this event.
    // Nodes push thier report on this function call, then the user can call solidifyBNY or liquidateBNY.
    uint256 public delay = 0;
    function init() public {

        require(now >= delay.add(600), 'Can be called once in 10 min');

        delay = now;
        emit Price_req(true);
    }



    // BNY erc-20 token amount to convert into XBNY, function will cheack balance of sender and call
    //  marketOracle to get the protocol price, if valid, it will exchange BNY to XBNY by calling:
    //  uEquils.BNY_AssetSolidification and xBNY.increaseXBNY.

    function solidifyBNY(uint256 BNYamount) public {
        
        uint256 userBalance = uEquils.balanceOf(msg.sender);

        require(userBalance >= BNYamount, "Insufficent BNY");
        

        uint256 exchangeRate;
        bool rateValid;
        address[] memory reporters1;
        (exchangeRate, rateValid,reporters1) = marketOracle.getData();
        require(rateValid);

        uint256 j =0;
        while(j < reporters1.length){
            require(reporters1[j] != msg.sender,"nodes cant send");
            j++;
        }
        
        
        uint256 reward = (BNYamount.mul(5)).div(1000);
        uEquils.BNY_AssetSolidification(msg.sender,BNYamount,reporters1,reward.div(reporters1.length));

        BNYamount = BNYamount.sub(reward);
        xBNY.increaseXBNY(msg.sender,(BNYamount.mul(exchangeRate).div(10 ** DECIMALS)));
    
   }




    // XBNY erc-20 token amount to convert into BNY, function will cheack balance of sender and call
    //  marketOracle to get the protocol price, if valid, it will exchange XBNY to BNY by calling:
    //  uEquils.BNY_AssetLiquidation and xBNY.reduceXBNY
    function liquidateBNY(uint256 XBNYamount) public {
        
        uint256 userBalance = xBNY.GetbalanceOf(msg.sender);
        require(userBalance >= XBNYamount, "Insufficent XBNY");
        
        uint256 exchangeRate;
        bool rateValid;
        address[] memory reporters1;
        (exchangeRate, rateValid,reporters1) = marketOracle.getData();
        require(rateValid);

        uint256 j =0;
        while(j < reporters1.length){
            require(reporters1[j] != msg.sender,"nodes cant send");
            j++;
        }
        
        uint256 reward = (XBNYamount.mul(10 ** DECIMALS).div(exchangeRate)).mul(5).div(1000); // total reward in bny for all the nodes
        

     
        xBNY.reduceXBNY(msg.sender,XBNYamount);
        uEquils.BNY_AssetLiquidation(msg.sender,((XBNYamount.mul(10 ** DECIMALS).div(exchangeRate)).sub(reward)),reporters1,reward.div(reporters1.length));
        
    }
}



















 

    
    