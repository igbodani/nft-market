// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";
import "./NFT.sol";

contract NFTMarket is ReentrancyGuard {
    // Currently Listing Price is 3% of product price
    using Counters for Counters.Counter;

    Counters.Counter public  productsSold;
    Counters.Counter public productsIds;
    Counters.Counter public auctionIds;
    Counters.Counter public auctionsClosed;
    Counters.Counter public collectionNum;
    Counters.Counter public usersNum;
    uint256 public listingPercent = 3;
    address payable owner;
    address payable[] admins;
    Collection[] public collections;

    constructor() {
        owner = payable(msg.sender);
    }

// Struct begins
    // Product struct
    struct Product {
        uint256 id;
        address nftContract;
        uint256 tokenId;
        address payable creator;
        address payable seller;
        address payable owner;
        string collection;
        uint256 price;
        int256 auctionId;
        bool hide;
        bool sold;
    }

    // Auction struct
    struct Auction {
        uint256 id;
        uint256 productId;
        address payable seller;
        uint256 auctionTime; //seconds
        address payable highestBidder;
        uint256 highestBid;
        mapping(address => uint256) bidReturns;
        Bid[] bidList;
        uint256 bidNum;
        bool ended;
    }

    struct Bid {
        address bidder;
        uint256 amount;
    }

    struct Collection {
        address owner;
        string name;
    }

    // Struct end

    // Maps
    mapping(uint256 => Product) private productIdMap;
    mapping(uint256 => Auction) private auctionIdMap;
    mapping(address => string) private userMap;

    // Events

    event ProductCreated(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address creator,
        address seller,
        address owner,
        string collection,
        uint256 price,
        int256 auctionId,
        bool hide,
        bool sold
    );

    event ProductPriceUpdated(
        uint256 indexed productId,
        uint256 indexed oldPrice,
        uint256 indexed newPrice
    );

    event ProductRelisted(uint256 indexed productId);


    event AuctionStart(uint256 indexed id, address seller, uint256 auctionTime);

    event HighestBidIncrease(address highestBidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);


    event userProfileSaved(address user);

// Events End

// Modifiers

    modifier onlyProductSeller(uint256 id) {
        require(
            productIdMap[id].owner == address(0) &&
                productIdMap[id].seller == msg.sender,
            "Only the product seller can perform this operation"
        );
        _;
    }

    modifier onlyProductOwner(uint256 id) {
        require(
            productIdMap[id].owner == msg.sender,
            "Only product owner can  perform this operation"
        );
        _;
    }

    modifier onlyAdmin(address wallet) {
        require(isAdmin(wallet), "Only Admins can perform this operation");
        _;
    }

    // modifier OnlyBidOnce(address wallet, uint256 auctionId) {
    //     require(
    //         checkAddress(wallet, auctionId),
    //         "Unfortunatley, you have bid more than once"
    //     );
    //     _;
    // }

    // modifier ownerOfCollection(string memory collection){
    //     require(
    //         checkCollections(collection) == false, "Collection already exists"

    //     );
    //      _;
    // }

// Modifiers End

// Properties

    // Returns the listing price of the contract

    function isAdmin(address wallet) public view returns (bool) {
        bool check = false;
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == wallet) {
                check = true;
            }
        }
        return check;
    }

    // Return listing price
    function getListingPrice(uint256 price) public view returns (uint256) {
        uint256 temp = (listingPercent * price) / 100;
        return temp;
    }

    

    // Returns total number of active auctions
    function getCurrentNumOfAuction() public view returns (uint256) {
        return auctionIds.current() - auctionsClosed.current();
    }

   

    // Add address to admin array
    function addAddress(address payable wallet) public {
        admins.push(wallet);
    }

    // Change Owners address
    function changeOwner(address payable wallet) public onlyAdmin(wallet) {
        owner = wallet;
    }

    //this is to delete an address stored at a specific index in the array.
    //Once you delete the address the value in the array is set back to 0 for a address.
    function remove(uint256 index) public {
        delete admins[index];
    }

// Properties End


// Market -- Functions

    // User Functions begin


    function saveUserProfile(string memory url) public {


        bytes memory emptyString = bytes( userMap[msg.sender]);
        if(emptyString.length ==  0){
             usersNum.increment();
        }
       
        userMap[msg.sender]  = url;
        
         console.log(url);
        emit userProfileSaved(msg.sender);

    }


    function getUserProfile() public view returns(string memory) {
     return userMap[msg.sender];
    }

    // User Functions end


    //Start Auction
    function startAuction(uint256 productId, uint256 biddingTime)
        public
        onlyProductSeller(productId)
       
    {
        require(productId > 0);
        require(biddingTime > 1);

        auctionIds.increment();
        uint256 newId = auctionIds.current();

        Auction storage auction = auctionIdMap[newId];
        auction.id = newId;
        auction.productId = productId;
        auction.seller = payable(msg.sender);
        auction.auctionTime = block.timestamp + biddingTime;
        auction.highestBidder = payable(address(0));
        auction.highestBid = 0;
        auction.bidNum = 0;
        auction.ended = false;
        productIdMap[productId].auctionId = int256(newId);


        emit AuctionStart(newId, auction.seller, auction.auctionTime);
    }

    // Place a bid for a product
    function bid(uint256 auctionId)
        public
        payable
        nonReentrant
    {
        require(msg.sender != auctionIdMap[auctionId].seller);

        if (block.timestamp > auctionIdMap[auctionId].auctionTime) {
            revert("Unfortunatley, The auction has already closed");
        }

        if (msg.value <= auctionIdMap[auctionId].highestBid) {
            revert("Unfortunatley, There is already a higher or equal bid");
        }

        if (auctionIdMap[auctionId].highestBid != 0) {
            address tempHighestBidder = auctionIdMap[auctionId].highestBidder;

            auctionIdMap[auctionId].bidReturns[tempHighestBidder] += auctionIdMap[auctionId].highestBid;

            
            // Add to return bid list 
            int256 index = checkAddress(auctionId, tempHighestBidder);

            if(index >= 0){
                 uint256 newindex = uint(index);
                 if(index == 0){

                auctionIdMap[auctionId].bidList.push(Bid(tempHighestBidder, auctionIdMap[auctionId].bidReturns[tempHighestBidder]));
   
                 }
                 auctionIdMap[auctionId].bidList[newindex] = Bid(tempHighestBidder, auctionIdMap[auctionId].bidReturns[tempHighestBidder]);
                   
            }else{
                  auctionIdMap[auctionId].bidList.push(Bid(tempHighestBidder, auctionIdMap[auctionId].bidReturns[tempHighestBidder]));

            }
           
        }

        auctionIdMap[auctionId].highestBidder = payable(msg.sender);
        auctionIdMap[auctionId].highestBid = msg.value;
        auctionIdMap[auctionId].bidNum += 1;
       
        emit HighestBidIncrease(msg.sender, msg.value);
    }

    // Withdraw from auction
    function withdraw(uint256 auctionId) public nonReentrant returns (bool) {
        uint256 amount = auctionIdMap[auctionId].bidReturns[msg.sender];
        uint256 index;

        if (amount > 0) {
            // Sets the amount to 0, to avoid reattempts
            int256 currentbidNum = int256(auctionIdMap[auctionId].bidNum);
            console.log(amount);
            auctionIdMap[auctionId].bidReturns[msg.sender] = 0;
            currentbidNum += -1;
            auctionIdMap[auctionId].bidNum = uint256(currentbidNum);

            for (
                uint256 i = 0;
                i < auctionIdMap[auctionId].bidList.length;
                i++
            ) {
                if (auctionIdMap[auctionId].bidList[i].bidder == msg.sender) {
                    auctionIdMap[auctionId].bidList[i].bidder = address(0);
                    index = i;
                }
            }

            //If the withdraw fails set the amount to previous value
            if (!payable(msg.sender).send(amount)) {
                auctionIdMap[auctionId].bidReturns[msg.sender] = amount;
                auctionIdMap[auctionId].bidNum += 1;
                if (
                    auctionIdMap[auctionId].bidList[index].bidder == address(0)
                ) {
                    auctionIdMap[auctionId].bidList[index].bidder = msg.sender;
                }

                return false;
            }
        }

        return true;
    }

    // Close auction
    function endAuction(uint256 auctionId)
        public
        onlyProductSeller(auctionIdMap[auctionId].productId)
    {
        if (block.timestamp < auctionIdMap[auctionId].auctionTime) {
            revert("The auction hasn't been closed");
        }

        if (auctionIdMap[auctionId].ended) {
            revert("Unfortunatley, The auction has closed");
        }

        // set end to true
        auctionIdMap[auctionId].ended = true;

        uint256 productId = auctionIdMap[auctionId].productId;
        uint256 price = productIdMap[productId].price;
        uint256 tokenId = productIdMap[productId].tokenId;
        address nftContract = productIdMap[productId].nftContract;

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        productIdMap[productId].owner = auctionIdMap[auctionId].highestBidder;
        productIdMap[productId].sold = true;
        productsSold.increment();
        auctionsClosed.increment();

        uint256 temp_listingPrice = getListingPrice(price);

        payable(owner).transfer(temp_listingPrice);

        emit AuctionEnded(
            auctionIdMap[auctionId].highestBidder,
            auctionIdMap[auctionId].highestBid
        );
    }

    function getAuctionbids(uint256 auctionId)
        public
        view
        returns (Bid[] memory)
    {
        require(auctionId > 0, "This auction does  not exist");

        uint256 len = auctionIdMap[auctionId].bidList.length;
         console.log(len);
        uint256 size = auctionIdMap[auctionId].bidNum;
        address highestBidder =  auctionIdMap[auctionId].highestBidder;
        uint256 amount = auctionIdMap[auctionId].highestBid;
      


        Bid[] memory list = new Bid[](size);

        for (uint256 i = 0; i < len; i++) {
            if (auctionIdMap[auctionId].bidList[i].bidder != address(0) && (auctionIdMap[auctionId].bidList[i].amount  != 0 )) {
                list[i] = auctionIdMap[auctionId].bidList[i];
                console.log(auctionIdMap[auctionId].bidList[i].bidder );
                console.log(auctionIdMap[auctionId].bidList[i].amount);
            }
        }

        console.log(len);

        console.log(list.length);
         console.log(size);

        list[size-1] = Bid(highestBidder, amount);
       

        return list;
    }
    // Auction functions end




    // Product Functions begin

    // Creates and Lists the product(NFT) of the sender
    function createProduct(
        address nftContract,
        uint256 tokenId,
        string memory collectionName,
        uint256 price
    ) public  payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == (3 * price) / 100,
            "Listing fee required"
        );

        bool found;
        uint index;

        (index, found) = checkCollections(collectionName);

          if( found  ==  false){
            collections.push(Collection( msg.sender, collectionName));
            collectionNum.increment();
        }else{
            require(msg.sender == collections[index].owner, "You can't add to this collection");
        }

        productsIds.increment();
        uint256 newProductId = productsIds.current();

        // Creates Product and saves it to the Map

        productIdMap[newProductId] = Product(
            newProductId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            collectionName,
            price,
            -1,
            false,
            false
        );
        // collectionNum.increment();
        // collections[collectionNum.current()] = collection;

        // Transfers ownership from seller to market
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

       
        emit ProductCreated(
            newProductId,
            nftContract,
            tokenId,
            msg.sender,
            msg.sender,
            address(0),
            collectionName,
            price,
            -1,
            false,
            false
        );

         // Pay lisitng fee
        uint256 temp_listingPrice = getListingPrice(price);
        payable(owner).transfer(temp_listingPrice);


        

 
    }

    function createProductCollection(
        address nftContract,
        uint256[] memory tokenIds,
        string memory collectionName,
        uint256 price
    ) public payable nonReentrant {
        // Gets price of the total collection
        uint256 newPrice = price * tokenIds.length;

        require(newPrice > 0, "Price must be at least 1 wei");
        require(
            msg.value == (3 * newPrice) / 100,
            "Listing fee required"
        );

        bool found;
        uint index;

        (index, found) = checkCollections(collectionName);

          if( found  ==  false){
            collections.push(Collection( msg.sender, collectionName));
            collectionNum.increment();
        }else{
            require(msg.sender == collections[index].owner, "You can't add to this collection");
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            productsIds.increment();
            uint256 newProductId = productsIds.current();

            // Creates Product and saves it to the Map

            productIdMap[newProductId] = Product(
                newProductId,
                nftContract,
                tokenIds[i],
                payable(msg.sender),
                payable(msg.sender),
                payable(address(0)),
                collectionName,
                price,
                -1,
                false,
                false
            );

            // Transfers ownership from seller to market
            IERC721(nftContract).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

           

            emit ProductCreated(
                newProductId,
                nftContract,
                tokenIds[i],
                msg.sender,
                msg.sender,
                address(0),
                collectionName,
                price,
                -1,
                false,
                false
            );
        }


         // Pay lisitng fee
            uint256 temp_listingPrice = getListingPrice(newPrice);
            payable(owner).transfer(temp_listingPrice);

      

       
    }


    // Update product price 
    function setProductPrice(uint256 productId, uint256 newPrice)
        public
        onlyProductSeller(productId)
    {
        require(newPrice > 0, "Price must be at least 1 wei");

        require(productId > 0, "This product does not exist ");

        // Get old value
        uint256 oldPrice = productIdMap[productId].price;

        //Change vaue
        productIdMap[productId].price = newPrice;

        emit ProductPriceUpdated(productId, oldPrice, newPrice);
    }

    function hideProduct(uint256 productId, bool state) public onlyProductOwner(productId){
        require(productId > 0, "This product does not exist ");

        productIdMap[productId].hide = state;

    }


    // Buy product
    function buy(address nftContract, uint256 productId)
        public
        payable
        nonReentrant
    {
        uint256 price = productIdMap[productId].price;
        uint256 tokenId = productIdMap[productId].tokenId;

        console.log(price);
        console.log(msg.value);

        require(msg.value == price);
        require(
            msg.sender != productIdMap[productId].seller,
            "You cannont buy your own product"
        );

        productIdMap[productId].seller.transfer(msg.value);

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        productIdMap[productId].owner = payable(msg.sender);
        productIdMap[productId].sold = true;
        productsSold.increment();
    }

    //ReLists Product for sale

    function relistProduct(
        address nftContract,
        uint256 productId,
        uint256 newPrice
    ) public payable nonReentrant onlyProductOwner(productId) {
        require(newPrice > 0, "Price must be at least 1 wei");
        require(
            msg.value == (3 * newPrice) / 100,
            "Listing fee required "
        );

        uint256 tokenId = productIdMap[productId].tokenId;
        //instantiate a NFT contract object with the matching type
        NFT tokenContract = NFT(nftContract);

        //call the custom transfer token method
        tokenContract.transferToken(msg.sender, address(this), tokenId);

        //Upadte Product values
        address payable oldOwner = productIdMap[productId].owner;
        productIdMap[productId].owner = payable(address(0));
        productIdMap[productId].seller = oldOwner;
        productIdMap[productId].price = newPrice;
        productIdMap[productId].sold = false;
        productIdMap[productId].auctionId = -1;
        productsSold.decrement();


        // Pay lisitng fee
        uint256 temp_listingPrice = getListingPrice(newPrice);
        payable(owner).transfer(temp_listingPrice);

        emit ProductRelisted(productId);
    }

    // Returns products available for sale/auction
    function getUnsoledProducts() public view returns (Product[] memory) {
        uint256 productCount = productsIds.current();
        uint256 unsoledProductCount = productsIds.current() -
            productsSold.current();
        uint256 currentIndex = 0;

        Product[] memory products = new Product[](unsoledProductCount);

        for (uint256 i = 0; i < productCount; i++) {
            if (productIdMap[i + 1].owner == address(0)) {
                uint256 currentProductId = i + 1;
                Product storage currentProduct = productIdMap[currentProductId];
                products[currentIndex] = currentProduct;
                currentIndex += 1;
            }
        }
        return products;
    }

    

    //Returns only products purchased by the address 
    function getMyProducts(address _owner)
        public
        view
        returns (Product[] memory)
    {
        uint256 totalProductCount = productsIds.current();
        uint256 productCount = 0;
        uint256 currentIndex = 0;

        console.log("this is the sender", msg.sender);

        for (uint256 i = 0; i < totalProductCount; i++) {
            console.log("productID ", productIdMap[i + 1].tokenId);
            console.log("productID Owner ", productIdMap[i + 1].owner);

            if (productIdMap[i + 1].owner == _owner) {
                productCount += 1;
            }
            console.log("number of products owned ", productCount);
        }

        Product[] memory products = new Product[](productCount);
        for (uint256 i = 0; i < totalProductCount; i++) {
            console.log("productID ", productIdMap[i + 1].tokenId);
            console.log("productID Owner ", productIdMap[i + 1].owner);

            if (productIdMap[i + 1].owner == _owner) {
                uint256 currentId = i + 1;
                Product storage currentProduct = productIdMap[currentId];
                products[currentIndex] = currentProduct;
                currentIndex += 1;
            }
        }

        return products;
    }

   
    // Returns the products created by the address 
    function getProductsCreated(address creator)
        public
        view
        returns (Product[] memory)
    {
        uint256 totalProductCount = productsIds.current();
        uint256 productCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalProductCount; i++) {
            if (productIdMap[i + 1].creator == creator) {
                console.log("productID ", productIdMap[i + 1].tokenId);
                console.log("productID Owner ", productIdMap[i + 1].creator);
                productCount += 1;
            }
        }

        Product[] memory products = new Product[](productCount);
        for (uint256 i = 0; i < totalProductCount; i++) {
            if (productIdMap[i + 1].creator == creator) {
                console.log("productID ", productIdMap[i + 1].tokenId);
                console.log("productID Owner ", productIdMap[i + 1].creator);
                uint256 currentId = i + 1;
                Product storage currentProduct = productIdMap[currentId];
                products[currentIndex] = currentProduct;
                currentIndex += 1;
            }
        }
        return products;
    }



    // Utility functions

    function checkCollections(string memory collection) internal view  returns(uint256, bool){
        if(collections.length == 0){
            return (0,false);
        }

         bool found;
         uint index = 0;
    
        for(uint i = 0; i < collections.length; i++){

          found =  compareStrings(collections[i].name, collection);   
          if(found){
              index = i;
          }
        }

        return (index, found);
    }

    function compareStrings(string memory word ,string memory word2 ) internal pure returns (bool){

        bool equal = false;

        if(keccak256(abi.encodePacked(word)) ==  keccak256(abi.encodePacked(word2)) ){
            equal = true;
        }

        return equal;
    }

     function checkAddress(uint256 auctionId, address wallet)
        internal
        view
        returns (int256)
    {

        if(auctionIdMap[auctionId].bidList.length == 0){
            return 0;
        }

        int256 index = -1;
        for (uint256 i = 0; i < auctionIdMap[auctionId].bidList.length; i++) {
            if (auctionIdMap[auctionId].bidList[i].bidder == wallet) {
                console.log(i);
                index = int(i);
            }
        }
        console.log(uint(index));
        return index;
    }

}
