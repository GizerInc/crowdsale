pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
//
// GZR 'Gizer Gaming' token public sale contract
//
// For details, please visit: http://www.gizer.io
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
//
// SafeMath (division not needed)
//
// ----------------------------------------------------------------------------

library SafeMath {

  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require( c >= a );
  }

  function sub(uint a, uint b) internal pure returns (uint c) {
    require( b <= a );
    c = a - b;
  }

  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require( a == 0 || c / a == b );
  }

}


// ----------------------------------------------------------------------------
//
// Owned contract
//
// ----------------------------------------------------------------------------

contract Owned {

  address public owner;
  address public newOwner;

  // Events ---------------------------

  event OwnershipTransferProposed(address indexed _from, address indexed _to);
  event OwnershipTransferred(address indexed _to);

  // Modifier -------------------------

  modifier onlyOwner {
    require( msg.sender == owner );
    _;
  }

  // Functions ------------------------

  function Owned() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require( _newOwner != owner );
    require( _newOwner != address(0x0) );
    newOwner = _newOwner;
    OwnershipTransferProposed(owner, _newOwner);
  }

  function acceptOwnership() public {
    require( msg.sender == newOwner );
    owner = newOwner;
    OwnershipTransferred(owner);
  }

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
//
// ----------------------------------------------------------------------------

contract ERC20Interface {

  // Events ---------------------------

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  // Functions ------------------------

  function totalSupply() public view returns (uint);
  function balanceOf(address _owner) public view returns (uint balance);
  function transfer(address _to, uint _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);
  function approve(address _spender, uint _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint remaining);

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20
//
// ----------------------------------------------------------------------------

contract ERC20Token is ERC20Interface, Owned {
  
  using SafeMath for uint;

  uint public tokensIssuedTotal = 0;
  mapping(address => uint) balances;
  mapping(address => mapping (address => uint)) allowed;

  // Functions ------------------------

  /* Total token supply */

  function totalSupply() public view returns (uint) {
    return tokensIssuedTotal;
  }

  /* Get the account balance for an address */

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  /* Transfer the balance from owner's account to another account */

  function transfer(address _to, uint _amount) public returns (bool success) {
    // amount sent cannot exceed balance
    require( balances[msg.sender] >= _amount );

    // update balances
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to]        = balances[_to].add(_amount);

    // log event
    Transfer(msg.sender, _to, _amount);
    return true;
  }

  /* Allow _spender to withdraw from your account up to _amount */

  function approve(address _spender, uint _amount) public returns (bool success) {
    // approval amount cannot exceed the balance
    require( balances[msg.sender] >= _amount );
      
    // update allowed amount
    allowed[msg.sender][_spender] = _amount;
    
    // log event
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /* Spender of tokens transfers tokens from the owner's balance */
  /* Must be pre-approved by owner */

  function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
    // balance checks
    require( balances[_from] >= _amount );
    require( allowed[_from][msg.sender] >= _amount );

    // update balances and allowed amount
    balances[_from]            = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to]              = balances[_to].add(_amount);

    // log event
    Transfer(_from, _to, _amount);
    return true;
  }

  /* Returns the amount of tokens approved by the owner */
  /* that can be transferred by spender */

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


// ----------------------------------------------------------------------------
//
// GZR public token sale
//
// ----------------------------------------------------------------------------

contract GizerToken is ERC20Token {

  /* Utility variables */
  
  uint constant E6  = 10**6;

  /* Basic token data */

  string public constant name     = "Gizer Gaming Token";
  string public constant symbol   = "GZR";
  uint8  public constant decimals = 6;

  /* Wallets */
  
  address public wallet;
  address public adminWallet;
  address public redemptionWallet;

  /* Crowdsale parameters (constants) */

  uint public DATE_ICO_START = 1517580000; // 02-Feb-2018 14:00 UTC 09:00 EST
  uint public DATE_ICO_END   = 1519826400; // 28-Feb-2010 14:00 UTC 09:00 EST

  uint public constant TOKEN_SUPPLY_TOTAL = 20000000 * E6; // 20,000,000 tokens
  uint public constant TOKEN_SUPPLY_OWNER =  5714112 * E6; //  5,714,112 tokens
  uint public constant TOKEN_SUPPLY_CROWD = 14285888 * E6; // 14,285,888 tokens  

  uint public constant MIN_CONTRIBUTION = 1 ether / 100;  
  
  uint public constant CENTS_PER_TOKEN = 125; // US$ 1.25 per token
  
  /* Crowdsale parameters (can be modified by owner) */

  uint public ethCents = 111500; // initial value, can be modified
  
  /* Crowdsale variables */

  uint public tokensIssuedCrowd = 0;
  uint public tokensIssuedOwner = 0;
  
  uint public etherReceived = 0;

  /* Keep track of Ether contributed and tokens received during Crowdsale */
  
  mapping(address => uint) public etherContributed;
  mapping(address => uint) public tokensReceived;
  
  // Events ---------------------------
  
  event WalletUpdated(address _newWallet);
  event AdminWalletUpdated(address _newAdminWallet);
  event RedemptionWalletUpdated(address _newRedemptionWallet);
  event EthCentsUpdated(uint _cents);
  event TokensIssuedCrowd(address indexed _recipient, uint _tokens, uint _ether);
  event TokensIssuedOwner(address indexed _recipient, uint _tokens);

  // Basic Functions ------------------

  /* Initialize */

  function GizerToken() public {
    require( TOKEN_SUPPLY_OWNER + TOKEN_SUPPLY_CROWD == TOKEN_SUPPLY_TOTAL );
    wallet = owner;
    adminWallet = owner;
    redemptionWallet = owner;
  }

  /* Fallback */
  
  function () public payable {
    buyTokens();
  }

  // Information Functions ------------
  
  /* What time is it? */
  
  function atNow() public view returns (uint) {
    return now;
  }

  /* Are tokens tradeable */
  
  function tradeable() public view returns (bool) {
    if (atNow() > DATE_ICO_END) return true ;
    return false;
  }
  
  /* Available to mint by owner */
  
  function availableToMint() public view returns (uint available) {
    if (atNow() <= DATE_ICO_END) {
      available = TOKEN_SUPPLY_OWNER.sub(tokensIssuedOwner);
    } else {
      available = TOKEN_SUPPLY_TOTAL.sub(tokensIssuedTotal);
    }
  }

  // Owner Functions ------------------
  
  /* set ETH/US$ cents exchange rate */

  function setEthCents(uint _cents) public {
    require( msg.sender == owner || msg.sender == adminWallet );
    require( _cents > 0 );
    ethCents = _cents;
    EthCentsUpdated(_cents);
  }
  
  /* Change the crowdsale wallet address */

  function setWallet(address _wallet) public onlyOwner {
    require( _wallet != address(0x0) );
    wallet = _wallet;
    WalletUpdated(_wallet);
  }

  /* Change the admin wallet address */

  function setAdminWallet(address _wallet) public onlyOwner {
    require( _wallet != address(0x0) );
    adminWallet = _wallet;
    AdminWalletUpdated(_wallet);
  }

  /* Change the redemption wallet address */

  function setRedemptionWallet(address _wallet) public onlyOwner {
    require( _wallet != address(0x0) );
    redemptionWallet = _wallet;
    RedemptionWalletUpdated(_wallet);
  }
  
  /* Minting of tokens by owner */

  function mintTokens(address _account, uint _tokens) public onlyOwner {
    // check token amount
    require( _tokens <= availableToMint() );
    
    // update
    balances[_account] = balances[_account].add(_tokens);
    tokensIssuedOwner  = tokensIssuedOwner.add(_tokens);
    tokensIssuedTotal  = tokensIssuedTotal.add(_tokens);
    
    // log event
    Transfer(0x0, _account, _tokens);
    TokensIssuedOwner(_account, _tokens);
  }

  /* Transfer out any accidentally sent ERC20 tokens */

  function transferAnyERC20Token(address tokenAddress, uint amount) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, amount);
  }

  // Private functions ----------------

  /* Accept ETH during crowdsale (called by default function) */

  function buyTokens() private {
    
    // basic checks
    require( atNow() > DATE_ICO_START && atNow() < DATE_ICO_END );
    require( msg.value >= MIN_CONTRIBUTION );
    
    // check token volume
    uint tokensAvailable = TOKEN_SUPPLY_CROWD.sub(tokensIssuedCrowd);
    uint tokens = ethCents.mul(msg.value) / CENTS_PER_TOKEN / E6 / E6;
    require( tokens <= tokensAvailable );
    
    // issue tokens
    balances[msg.sender] = balances[msg.sender].add(tokens);
    
    // update global tracking variables
    tokensIssuedCrowd  = tokensIssuedCrowd.add(tokens);
    tokensIssuedTotal  = tokensIssuedTotal.add(tokens);
    etherReceived      = etherReceived.add(msg.value);
    
    // update contributor tracking variables
    etherContributed[msg.sender] = etherContributed[msg.sender].add(msg.value);
    tokensReceived[msg.sender]   = tokensReceived[msg.sender].add(tokens);
    
    // transfer Ether out
    if (this.balance > 0) wallet.transfer(this.balance);

    // log token issuance
    TokensIssuedCrowd(msg.sender, tokens, msg.value);
    Transfer(0x0, msg.sender, tokens);
  }

  // ERC20 functions ------------------

  /* Override "transfer" */

  function transfer(address _to, uint _amount) public returns (bool success) {
    require( tradeable() );
    return super.transfer(_to, _amount);
  }
  
  /* Override "transferFrom" */

  function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
    require( tradeable() );
    return super.transferFrom(_from, _to, _amount);
  }

  // Bulk token transfer function -----

  /* Multiple token transfers from one address to save gas */

  function transferMultiple(address[] _addresses, uint[] _amounts) external {
    require( tradeable() );
    require( _addresses.length == _amounts.length );
    for (uint i = 0; i < _addresses.length; i++) {
      super.transfer(_addresses[i], _amounts[i]);
    }
  }  
  
}