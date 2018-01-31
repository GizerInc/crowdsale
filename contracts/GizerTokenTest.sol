pragma solidity ^0.4.16;

import 'GizerToken.sol';

contract GizerTokenTest is GizerToken {

  /*

  Introduces function setTestTime(uint)
  
  Overrides function atNow() to return testTime instead of now()

  */

  uint public testTime = 1;
  
  // Events ---------------------------

  event TestTimeSet(uint _now);

  // Functions ------------------------

  function GizerTokenTest() public {}

  function atNow() public constant returns (uint) {
      return testTime;
  }

  function setTestTime(uint _t) public onlyOwner {
    require( _t > testTime ); // to avoid errors during testing
    testTime = _t;
    TestTimeSet(_t);
  }  

}
