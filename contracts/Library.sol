pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Library is Ownable {
    address owner;
	// mapping of librarian to bool (basically permissioned librarian)
    mapping(address => bool) librarianList;
	// does book exist in library
	// book functionality could be improved into being ERC721 tokens
    mapping(string => bool) bookList;
	// full ownership history of each book
    mapping(string => address[]) bookToOwnerLog;
	// book state (1 represents good condition/ 0 represents needs repaired)
	// if a book is 0, it is not allowed to be sent out from library
	// but it can be transfered between owners outside of library and returned
    mapping(string => bool) bookState;

    event librarianChange(
		address indexed _librarian,
        bool _change
    );

    event bookChange(
        bool _inLibrary
    );

    event bookOwnershipChange(
        address indexed _from,
        address _to,
        bool _state
    );

    event bookStateChange(
        bool _state
    );

	// bool return on if sender is librarian
    function validLibrarian(address sender) private view returns (bool) {
        return librarianList[sender];
    }

	// bool return on if book is in library
    function validBook(string book) private view returns (bool) {
        return bookList[book];
    }

	// bool return on state of book
    function validBookState(string book) private view returns (bool) {
        return bookState[book];
    }

	// initializer of library contract
	// sender address set to owner
	// sender address also set to the first and only librarian of library
    constructor() public {
        owner = msg.sender;
        librarianList[msg.sender] = true;
    }

	// add/remove function of librarian
	// first checks if sender is owner
	// then checks whether librarian exists
	// if they don't, they are added
	// if they do, they are removed
    function addRemoveLibrarian(address _librarian) public onlyOwner {

        if (librarianList[_librarian] == false) {
            librarianList[_librarian] = true;
            emit librarianChange(_librarian, librarianList[_librarian]);
		} else if (_librarian != owner) {
            librarianList[_librarian] = false;
            emit librarianChange(_librarian, librarianList[_librarian]);   
		}
    }

	// add/remove function for a book (string type)
	// first checks that sender is library
	// then checks whether book exists
	// if it doesn't, add the book, push the owner(library) as the owner, and set book state to 1
	// if it does, remove the book, and set book state to 0 (just a precaution)
    function addRemoveBook(string name) public {
        
        require(validLibrarian(msg.sender));
        
        if (bookList[name] == false) {
            bookList[name] = true;
            bookToOwnerLog[name].push(owner);
            bookState[name] = true;
            emit bookChange(bookList[name]);
		} else {
            bookList[name] = false;
            bookState[name] = false;
            emit bookChange(bookList[name]);
		}
    }

	// main book ownership change function
	// requires the receiver address, the book state (basically a check on what state it is in), and book name
	// first makes sure it is a valid book, then we pull the current owner of the book
    function changeBookOwnership(address receiver, bool state, string name) public {
    
        require(validBook(name));
        // update book state
        bookState[name] = state;

        address[] memory log = bookToOwnerLog[name];

		// first if is whether the current owner is the library owner (owned by library)
		// AND that the receiver is not the owner (we don't want someone sending it to themself)
		// this case is basically someone checking out a book
        if (log[log.length-1] == owner && receiver != owner) {
            // make sure it is only checked out by librarian
            require(validLibrarian(msg.sender));
			// make sure it is in good condition before checking out
            require(validBookState(name));
			// append ownership log to include the new recipient
            bookToOwnerLog[name].push(receiver);
            emit bookOwnershipChange(msg.sender, receiver, state);
		} 
		// second if is whether the current owner is NOT the library owner (owned by another person)
		// AND the receiver is the owner (checking a book back in) 
		else if (receiver == owner && log[log.length-1] != owner) {
			// append ownership log to give it back to library
			bookToOwnerLog[name].push(receiver);
            emit bookOwnershipChange(msg.sender, receiver, state);
		} 
		else if (receiver != owner && log[log.length-1] != owner) {
            // make sure sender is book owner
			require(msg.sender == log[log.length-1]);
			// append ownership log to transfer between people
			bookToOwnerLog[name].push(receiver);
            emit bookOwnershipChange(msg.sender, receiver, state);
		}
    }

	// fixes book state (repairs a book)
	// only runs if it's currently in disrepair
    function fixBookState(string name) public {

        require(!validBookState(name));
        bookState[name] = true;
        emit bookStateChange( bookState[name]);
    }

	// common view to check if the book is checked out
	// basically returns true if the last address in bookLog is 
	// something other than owner of contract
    function isBookCheckedOut(string name) public view returns (bool) {
        
        require(validBook(name));
        address[] memory log = bookToOwnerLog[name];
        address lastOwner = log[log.length - 1];
        return lastOwner != owner;
    }

	// returns who the current owner is of the book
    function ownerOfBook(string name) public view returns (address) {
        
        require(validBook(name));
        address[] memory log = bookToOwnerLog[name];
        address lastOwner = log[log.length - 1];
        return lastOwner;
    }

	// returns full ownership history of the book as an array
    function returnFullHistoryOfBook(string name) public view returns (address[]) {
        
        require(validBook(name));
        address[] memory log = bookToOwnerLog[name];
        return log;
    }

	// check condition of book
    function checkBookState(string name) public view returns (bool) {
		
        require(validBook(name));
        return bookState[name];
    }

	// checks if book actually exists in library (not that useful)
    function validBookCheck(string name) public view returns (bool) {

        return bookList[name];
    }

    function librarianCheck(address librarian) public view returns (bool) {
        return librarianList[librarian];
    }
}
