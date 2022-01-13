const { expect } = require("chai");
const { ethers } = require("hardhat");



function waitfor(time) {
    console.log("wait")
    return new Promise(resolve => {
        setTimeout(() => { resolve('') }, time);
    })
}

describe("NFTMarket", function () {
    it("Should create and execute product sale", async function () {

        /* deploy the NFT-Market contract */
        const Market = await ethers.getContractFactory("NFTMarket")
        const market = await Market.deploy()
        await market.deployed()
        const marketAddress = market.address

        /* deploy the NFT contract */
        const NFT = await ethers.getContractFactory("NFT")
        const nft = await NFT.deploy(marketAddress)
        await nft.deployed()
        const nftAddress = nft.address

        const price = ethers.utils.parseUnits('1', 'ether')
        const price2 = ethers.utils.parseUnits('7', 'ether');


        /* Create NFT- Collection */
        const list = ["https://www.mytokenlocation.com",
            "https://www.mytokenlocation2.com",
            "https://www.mytokenlocation3.com"]


        // Create (mint) NFT collection {url, royalties}
        await nft.mintCollection(list, 1000)

        const tx = await nft.getTokenIds()  // retrive token ids 

        var newList = []

        // Add list of ids to newList
        for (let index = 0; index < tx.length; index++) {
            const element = tx[index];
            newList.push(tx[index])
            console.log(element.toNumber())

        }

        /* Total price of Collection  */
        collPrice = price * newList.length


        /* Listing price for Collection  */
        const temp = (3 * collPrice) / 100;
        const listingPrice = temp.toString();

        // List  NFT for sale on market  
        await market.createProductCollection(nftAddress, newList, "TEST", price, { value: listingPrice })


        /* End of creating Collection  */

        // Create NFT {url, royalties}
        await nft.mintToken("https://www.mytokenlocation.com", 9000);
        await nft.mintToken("https://www.mytokenlocation2.com", 1000);



        const temp1 = (3 * price) / 100;
        const listingPrice1 = temp1.toString()


        const temp2 = (3 * price2) / 100;
        const listingPrice2 = temp2.toString()


        //List Product for sale {nft-contract-address, nft tokenId, collection, price and listing price based of percentage}
        await market.createProduct(nftAddress, 4, "TEST", price, { value: listingPrice1 })
        await market.createProduct(nftAddress, 5, "", price2, { value: listingPrice2 })


        const [_, buyerAddress] = await ethers.getSigners()




        console.log(buyerAddress.getAddress())

        /* execute sale of token to another user */
        await market.connect(buyerAddress).buy(nftAddress, 1, { value: price })

        // Re-List product in market {nft-contract-address, product Id, price and listing price based of percentage}
        await market.connect(buyerAddress).relistProduct(
            nftAddress, 1, price, { value: listingPrice1 }
        )

        products = await market.getUnsoledProducts()
        products = await Promise.all(products.map(async (i, num) => {

            const tokenUri = await nft.tokenURI(i.tokenId)
            const ry = await nft.getRaribleV2Royalties(num + 1)
            royality = ry[0]
            rowner = ry[0][0]

            let product = {
                price: i.price.toString(),
                tokenId: i.tokenId.toString(),
                seller: i.seller,
                owner: i.owner,
                collection: i.collection,
                tokenUri,
                rowner,
                royality
            }

            return product
        }))

        console.log("products: ", products)



    });
});


describe("Auction", function () {
    it("should list product for an auction,buyers should bid, withdraw from the auction. Seller should end auction and ownership should be transferred", async function () {

        const Market = await ethers.getContractFactory("NFTMarket")
        const market = await Market.deploy()

        await market.deployed()
        const marketAddress = market.address

        /* deploy the NFT contract */
        const NFT = await ethers.getContractFactory("NFT")
        const nft = await NFT.deploy(marketAddress)
        await nft.deployed()
        const nftAddress = nft.address

         /* Bid values  */

        const price = ethers.utils.parseUnits('1', 'ether')
        const newprice = ethers.utils.parseUnits('2', 'ether')

         /* Bid values  */
        const bid = ethers.utils.parseUnits('7', 'ether')
        const bid1 = ethers.utils.parseUnits('8', 'ether')
        const bid2 = ethers.utils.parseUnits('9', 'ether')
        const bid3 = ethers.utils.parseUnits('6', 'ether')


        const temp1 = (3 * price) / 100;
        const listingPrice1 = temp1.toString()

        // Create NFT {url, royalties}
        await nft.mintToken("https://www.mytokenlocation.com", 9000);
        await market.createProduct(nftAddress, 1, "TEST", price, { value: listingPrice1 })

        // Change product price
        await market.setProductPrice(1, newprice)

        // Start Auction 
        await market.startAuction(1, 3)

        // Get list of accounts 
        const [_, buyerAddress1, buyerAddress2] = await ethers.getSigners()

        /* Bidding starts  */

        await market.connect(buyerAddress1).bid(1, { value: bid.toString() })

        console.log(" Bid 1 from Buyer 1 was successful, Thank you")

        await market.connect(buyerAddress2).bid(1, { value: bid1.toString() })

        console.log(" Bid 2 from Buyer 2 was successful, Thank you")

        let bidList = await market.getAuctionbids(1)

        console.log("Printing current Bid list")
        console.log(bidList)


        await market.connect(buyerAddress1).bid(1, { value: bid2.toString() })

        console.log(" Bid 3 from Buyer 1 was successful, Thank you")


        await market.connect(buyerAddress2).withdraw(1)
        console.log(" Buyer 2 was successfully able to withdraw, Thank you")

        bidList = await market.getAuctionbids(1)

        console.log(bidList)


        await waitfor(3000)

        // End auction 
        await market.endAuction(1)


        console.log(buyerAddress2.getAddress())



    })
})
