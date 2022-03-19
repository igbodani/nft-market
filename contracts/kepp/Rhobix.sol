// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "./NFT720.sol";
import "./NFT1155.sol";
import "./Admin.sol";

contract Rhobix is ReentrancyGuard, Admin, ERC1155Holder{
    using Counters for Counters.Counter;

    Counters.Counter public productsSold;
    Counters.Counter public auctionIds;
    Counters.Counter public auctionsClosed;
    address[] private userList;

    struct Product {
        uint256 id;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 amount;
        uint256 min_price;
        uint256 auctionId;
        uint256 biddingTime;
        bool sold;
    }

    struct Auction {
        uint256 id;
        uint256 productId;
        address payable seller;
        uint256 auctionTime;
        address payable highestBidder;
        uint256 highestBid;
        mapping(address => uint256) bidReturns;
        int256 numberOfBids;
        bool ended;
    }

    struct Bid {
        address buyer;
        uint256 bid;
    }

    mapping(uint256 => Product) private productIdMap;
    mapping(uint256 => Auction) private auctionIdMap;

    event ProductListed(
        uint256 indexed id,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 amount,
        uint256 min_price
    );

    event ProductSold(
        uint256 indexed id,
        address buyer,
        uint256 amount,
        uint256 price
    );

    event AuctionStart(uint256 indexed id, address seller, uint256 auctionTime);
    event ProductRelisted(uint256 indexed productId);

    event HighestBidIncrease(address highestBidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier onlyProductOwner(uint256 id) {
        require(
            productIdMap[id].owner == msg.sender,
            "Only product owner can  perform this operation"
        );
        _;
    }

    modifier onlyProductSeller(uint256 id) {
        require(
            (productIdMap[id].owner == address(0) ||
                productIdMap[id].owner == msg.sender) &&
                productIdMap[id].seller == msg.sender,
            "Only the product seller can perform this operation"
        );
        _;
    }

    function listProduct(
        uint256 id,
        address nftContract,
        uint256 tokenId,
        uint256 amount,
        uint256 min_price,
        uint256 auction,
        uint256 auctionTime,
        uint256 isErc7720
    ) public payable nonReentrant {
        require(tokenId > 0);
        require(min_price >= 0, "Price must be at least 1 wei");

        productIdMap[id] = Product(
            id,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            amount,
            min_price,
            auction,
            auctionTime,
            false
        );

        if (isErc7720 > 0 && amount == 1) {
            IERC721(nftContract).transferFrom(
                msg.sender,
                address(this),
                tokenId
            );
        } else {
            IERC1155(nftContract).safeTransferFrom(
                msg.sender,
                address(this),
                tokenId,
                amount,
                ""
            );
        }

        emit ProductListed(
            id,
            nftContract,
            tokenId,
            msg.sender,
            amount,
            min_price
        );

        if (auction > 0) {
            startAuction(id, auctionTime);
        }

        if (!checkAddress(msg.sender, userList)) {
            userList.push(msg.sender);
        }
    }

    function listProductCollection(
        uint256[] memory ids,
        address nftContract,
        uint256[] memory tokenIds,
        uint256 min_price,
        uint256 auction,
        uint256 auctionTime
    ) public payable nonReentrant {
        require(tokenIds.length > 0);
        require(min_price > 0, "Price must be at least 1 wei");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 id = ids[i];

            productIdMap[id] = Product(
                id,
                nftContract,
                tokenIds[i],
                payable(msg.sender),
                payable(address(0)),
                1,
                min_price,
                auction,
                auctionTime,
                false
            );

            IERC721(nftContract).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

            emit ProductListed(
                id,
                nftContract,
                tokenIds[i],
                msg.sender,
                1,
                min_price
            );

            if (auction > 0) {
                startAuction(id, auctionTime);
            }

            if (!checkAddress(msg.sender, userList)) {
                userList.push(msg.sender);
            }
        }
    }

    // Buy product
    function buy(
        address nftContract,
        uint256 productId,
        uint256 amount,
        uint256 isErc7720
    ) public payable nonReentrant {
        require(productIdMap[productId].auctionId == 0);

        uint256 price = productIdMap[productId].min_price;
        uint256 tokenId = productIdMap[productId].tokenId;

        console.log(price);
        console.log(msg.value);

        require(msg.value >= price);
        require(
            msg.sender != productIdMap[productId].seller,
            "You cannont buy your own product"
        );

        
        uint256 fee = getSalesPrice(msg.value);
        console.log("This is the fee--",fee);
        console.log("This is the value after fee --",msg.value - fee);

        if (
            payable(getOwner()).send(fee) &&
            productIdMap[productId].seller.send(msg.value - fee)
        ) {
            if (isErc7720 == 1 && amount == 1) {
                IERC721(nftContract).transferFrom(
                    address(this),
                    msg.sender,
                    tokenId
                );
            } else {
                
                IERC1155(nftContract).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenId,
                    amount,
                    ""
                );
                    NFT1155 nft = NFT1155(nftContract);
                     nft.approveOwner(address(this), msg.sender, true);

            }

            productIdMap[productId].owner = payable(msg.sender);
            productIdMap[productId].sold = true;
            productsSold.increment();

            if (!checkAddress(msg.sender, userList)) {
                userList.push(msg.sender);
            }
        }
    }

    

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
        productIdMap[productId].auctionId = newId;
        auction.seller = payable(msg.sender);
        auction.auctionTime = block.timestamp + biddingTime;
        auction.highestBidder = payable(address(0));
        auction.highestBid = 0;
        auction.numberOfBids = 0;
        auction.ended = false;

        emit AuctionStart(newId, auction.seller, auction.auctionTime);
    }



    // Place a bid for a product
    function bid(uint256 auctionId) public payable nonReentrant {
        require(
            msg.sender != auctionIdMap[auctionId].seller ||
                block.timestamp > auctionIdMap[auctionId].auctionTime ||
                msg.value <= auctionIdMap[auctionId].highestBid ||
                auctionIdMap[auctionId].ended,
            "Unfortunately, YCBAT"
        );

        if (auctionIdMap[auctionId].highestBid != 0) {
            address tempHighestBidder = auctionIdMap[auctionId].highestBidder;
            auctionIdMap[auctionId].bidReturns[
                tempHighestBidder
            ] += auctionIdMap[auctionId].highestBid;
        }

        auctionIdMap[auctionId].highestBidder = payable(msg.sender);
        auctionIdMap[auctionId].highestBid = msg.value;
        auctionIdMap[auctionId].numberOfBids += 1;

        emit HighestBidIncrease(msg.sender, msg.value);

         if (!checkAddress(msg.sender, userList)) {
            userList.push(msg.sender);
        }

    }

    // Withdraw from auction
    function withdraw(uint256 auctionId) public nonReentrant returns (bool) {
        uint256 amount = auctionIdMap[auctionId].bidReturns[msg.sender];

        if (amount > 0) {
            // Sets the amount to 0, to avoid reattempts

            auctionIdMap[auctionId].bidReturns[msg.sender] = 0;
            auctionIdMap[auctionId].numberOfBids += -1;

            //If the withdraw fails set the amount to previous value
            if (!payable(msg.sender).send(amount)) {
                auctionIdMap[auctionId].bidReturns[msg.sender] = amount;
                auctionIdMap[auctionId].numberOfBids += 1;
                return false;
            }
        }

       
        return true;
    }

    function acceptBid(uint256 auctionId, address buyer)
        public
        nonReentrant
        onlyProductSeller(auctionIdMap[auctionId].productId)
    {
        uint256 productId = auctionIdMap[auctionId].productId;
        uint256 price = 0;

        uint256 tokenId = productIdMap[productId].tokenId;
        address nftContract = productIdMap[productId].nftContract;

        if (payable(buyer) == auctionIdMap[auctionId].highestBidder) {
            price = auctionIdMap[auctionId].highestBid;
            auctionIdMap[auctionId].highestBid = 0;
            auctionIdMap[auctionId].highestBidder = payable(address(0));

        } else {
                price = auctionIdMap[auctionId].bidReturns[buyer];
                auctionIdMap[auctionId].bidReturns[buyer] = 0;
        }

        // sales fee
        uint256 fee = getSalesPrice(price);
        if (
            payable(getOwner()).send(fee) &&
            productIdMap[productId].seller.send(price - fee)
        ) {



            IERC721(nftContract).transferFrom(
                address(this),
                msg.sender,
                tokenId
            );
            
            productIdMap[productId].sold = true;
            auctionIdMap[auctionId].ended = true;
            productsSold.increment();
            auctionsClosed.increment();

        
            emit AuctionEnded(
              buyer,
                price
            );
        } else{

            if (payable(buyer) == auctionIdMap[auctionId].highestBidder) {
             auctionIdMap[auctionId].highestBid = price;

        } else {
                auctionIdMap[auctionId].bidReturns[buyer]  = price;
        }

        }
    }

    function getBidList(uint256 auctionId)
        public
        view
        returns (Bid[] memory)
    {
        Auction storage auction = auctionIdMap[auctionId];
        uint256 size = uint256(auction.numberOfBids);
        uint256 index = 0;

        Bid[] memory bidList = new Bid[](size);

        for (uint256 i = 0; i < userList.length; i++) {
            if (auctionIdMap[auctionId].bidReturns[userList[i]] > 0) {
                bidList[index] = Bid(
                    userList[i],
                    auctionIdMap[auctionId].bidReturns[userList[i]]
                );

                if (index <= size - 2) {
                    index += 1;
                }
            }
        }

        bidList[size - 1] = Bid(
            auctionIdMap[auctionId].highestBidder,
            auctionIdMap[auctionId].highestBid
        );

        return bidList;
    }
}
