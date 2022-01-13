// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";
import "hardhat/console.sol";


contract NFT is ERC721URIStorage, RoyaltiesV2Impl{
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    address contractAddress;
    uint[] collectionIds;


    constructor(address marketplaceAddress) ERC721("Zero", "XX"){
        contractAddress = marketplaceAddress;

    }

     
    function getTokenIds() view public returns (uint[] memory) {
        return collectionIds;
    }


    // The tokenURI is the metadata description of the 
    // NFT

    function mintToken(string memory tokenURI, uint96 royalty) public returns(uint){
        tokenIds.increment();
        uint newItemId = tokenIds.current();

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
         setRoyalties(newItemId, royalty);

        setApprovalForAll(contractAddress, true);

        

        return newItemId;
    }


     function mintCollection(string[] memory tokenList,  uint96 royalty ) public{

        uint[] memory idList = new uint[](tokenList.length);

        for(uint i = 0; i < tokenList.length; i++){
            console.log(tokenList[i]);
            idList[i] = mintToken(tokenList[i], royalty);
            console.log( idList[i]);
        }

         collectionIds =  idList;
    }

    
    function transferToken(address from, address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == from, "From address must be token owner");
        _transfer(from, to, tokenId);
    }


     // Royalties functionality

    function setRoyalties(uint tokenId, uint96 percentageBasisPoints) public{
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = percentageBasisPoints;
        _royalties[0].account = payable(msg.sender);
        _saveRoyalties(tokenId, _royalties);
    }

   
   
                
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        if(interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        return super.supportsInterface(interfaceId); 
    }


   
} 




