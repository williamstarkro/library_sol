pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Library.sol";

contract TestLibrary {

    Library lib = Library(DeployedAddresses.Library());
    string book = "The Little Prince";

    function testBookThrow() public {
        ThrowProxy throwproxy = new ThrowProxy(address(lib)); 
        Library(address(throwproxy)).addRemoveBook(book);
        bool r = throwproxy.execute.gas(200000)(); 
        Assert.isFalse(r, "Should be false because address is not a listed librarian");
    }
}

// Proxy contract for testing throws
contract ThrowProxy {
    address public target;
    bytes data;

    constructor(address _target) public {
        target = _target;
    }

    //prime the data using the fallback function.
    function() public {
        data = msg.data;
    }

    function execute() public returns (bool) {
        return target.call(data);
    }
}