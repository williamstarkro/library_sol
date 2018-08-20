var Library = artifacts.require("./Library.sol");

contract('Library', function(accounts) {
  let catchRevert = require("./exceptions.js").catchRevert;
  
  it("should have owner as first librarian", function() {
    return Library.deployed().then(function(instance) {
      return instance.librarianCheck.call(accounts[0]);
    }).then(function(check) {
      assert.equal(check.valueOf(), true, "owner is not a librarian");
    });
  });
  it("should add a new librarian to the system", function() {
    var lib;

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.addRemoveLibrarian(accounts[1]);
    }).then(function() {
      return lib.librarianCheck.call(accounts[1]); 
    }).then(function(librarian) {
      assert.equal(librarian.valueOf(), true, "error occured");
    });
  });
  it("should add a new book to the system", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.addRemoveBook(book);
    }).then(function() {
      return lib.validBookCheck.call(book); 
    }).then(function(book) {
      assert.equal(book.valueOf(), true, "error occured");
    });
  });
  it("new book's owner should be owner of library", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.ownerOfBook.call(book); 
    }).then(function(owner) {
      assert.equal(owner.valueOf(), accounts[0], "error occured");
    });
  });
  it("new book's state should be true (good)", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.checkBookState.call(book); 
    }).then(function(state) {
      assert.equal(state.valueOf(), true, "error occured");
    });
  });
  it("transfer book from owner to account[1], state = true", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.changeBookOwnership(accounts[1], true, book);
    }).then(function() {
      return lib.ownerOfBook.call(book); 
    }).then(function(owner) {
      assert.equal(owner.valueOf(), accounts[1], "error occured");
    });
  });
  it("transfer book from owner to account[1], state = false - should revert", function() {
    var lib;
    var book = "The Little Prince";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.addRemoveBook(book);
    }).then(function() {
      return catchRevert(lib.changeBookOwnership(accounts[1], false, book));
    });
  });
  it("transfer book from account[1] to account[2], state = true", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.changeBookOwnership(accounts[2], true, book, {from: accounts[1]});
    }).then(function() {
      return lib.ownerOfBook.call(book); 
    }).then(function(owner) {
      assert.equal(owner.valueOf(), accounts[2], "error occured");
    });
  });
  it("transfer book from account[2] to account[0], state = false", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.changeBookOwnership(accounts[0], false, book, {from: accounts[2]});
    }).then(function() {
      return lib.ownerOfBook.call(book); 
    }).then(function(owner) {
      assert.equal(owner.valueOf(), accounts[0], "error occured");
    });
  });
  it("transfer book from account[0] to account[2], state = true - should revert (state is false", function() {
    var lib;
    var book = "Clifford";

    return Library.deployed().then(function(instance) {
      lib = instance;
      return lib.addRemoveBook(book);
    }).then(function() {
      return catchRevert(lib.changeBookOwnership(accounts[2], true, book));
    });
  });
});
