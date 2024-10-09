//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract VendingMachineContract {
   // Owner address
  address payable public owner;

  // The total balance obtained from sales. 
  uint public ownerBalance; 

  // Options on product categories
  enum ProductCategories { FOODS, DRINKS }

  // Product attributes
  struct Product {
      string name; 
      uint256 price;
      uint256 stock;
      string image;
  }

  // Transaction attributes
  struct Transaction {
      address buyer; 
      string productName;
      uint256 price;
  }

  // Customer bag attributes
  struct CustomerBag {
      string productName; 
      uint256 price;
      string image;
      uint256 buyDate;
  }

  // List of transaction
  Transaction[] public transactions;

  // List product by product category as a key
  mapping (ProductCategories => Product[]) public VendingMachine;

  // List customer bag by customer address as a key
  mapping (address => CustomerBag[]) public customerBags;

  constructor() {
      owner = payable(msg.sender);
  }

  modifier onlyOwner() {
      require(msg.sender == owner, "You dont have authorize");
      _;
  }

  event LogTransaction(address _buyer, string _productName, uint256 _price);


  function getProducts(ProductCategories _productType) public view returns(Product[] memory) {
     return VendingMachine[_productType];
  }

  function addProduct(
      ProductCategories _productType, 
      string memory _name, 
      uint256 _price, 
      uint256 _stock, 
      string memory _image
  ) public onlyOwner {
      VendingMachine[_productType].push(Product(_name, _price, _stock, _image));
  }

  function updateStock(
      ProductCategories _productType, 
      uint index, 
      uint256 _amount
  ) public onlyOwner {
      VendingMachine[_productType][index].stock = _amount;
  }

  function updatePrice(
      ProductCategories _productType, 
      uint index, 
      uint256 _price
  ) public onlyOwner {
      VendingMachine[_productType][index].price = _price;
  }

  function buyProduct(
      ProductCategories _productType, 
      uint index
  ) payable public {
      Product storage product = VendingMachine[_productType][index];
      require(product.stock > 0, "Insufficient stock");
      require(product.price == msg.value, "Input actual balance");
      product.stock -= 1;
      ownerBalance += msg.value; 
      transactions.push(Transaction(msg.sender, product.name, product.price));
      customerBags[msg.sender].push(CustomerBag(product.name, product.price, product.image, block.timestamp));
      emit LogTransaction(msg.sender, product.name, product.price);
  }

  function widthdrawBalance(uint256 _amount) public payable onlyOwner {
      require(_amount <= ownerBalance, "Insufficient balance");
      ownerBalance -= _amount;
      payable(owner).transfer(_amount);
  } 

  function getTransaction() public view returns (Transaction[] memory) {
      Transaction[] memory allTransactions = new Transaction[](transactions.length);
      for (uint i = 0; i < transactions.length; i++) {
          Transaction storage transaction = transactions[i];
          allTransactions[i] = transaction;
      }
      return allTransactions;
  }

  function getCustomerBag(address _customerAddress) public view returns (CustomerBag[] memory) {
      return customerBags[_customerAddress];
  }
}