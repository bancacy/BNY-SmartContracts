pragma solidity 0.5.11;

import "../openzeppelin-eth/contracts/math/SafeMath.sol";
import "../openzeppelin-eth/contracts/ownership/Ownable.sol";
import "../openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";

import "./lib/SafeMathInt.sol";


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

    uint256 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_EUILIBRIUMS_SUPPLY = 50 * 10**6 * 10**DECIMALS;

    // TOTAL_FRACS is a multiple of INITIAL_EUILIBRIUMS_SUPPLY so that _fracsPerEquilibrium is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 private constant TOTAL_FRACS = MAX_UINT256 - (MAX_UINT256 % INITIAL_EUILIBRIUMS_SUPPLY);

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_FRACS + 1) - 1) / 2
    uint256 private constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 10

    uint256 private _totalSupply;
    uint256 private _fracsPerEquilibrium;
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

    /**
     * @dev Notifies Equilibriums contract about a new rebase cycle.
     * @param supplyDelta The number of new equilibrium tokens to add into circulation via expansion.
     * @return The total number of equilibriums after the supply adjustment.
     */
    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        whenRebaseNotPaused
        returns (uint256)
    {
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

    function initialize(address owner_)
        public
        initializer
    {
        ERC20Detailed.initialize("Bancacy", "BNY", uint8(DECIMALS));
        Ownable.initialize(owner_);

        rebasePaused = false;
        tokenPaused = false;

        _totalSupply = INITIAL_EQUILIBRIUMS_SUPPLY;
        _fracBalances[owner_] = TOTAL_FRACS;
        _fracsPerEquilibrium = TOTAL_FRACS.div(_totalSupply);

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