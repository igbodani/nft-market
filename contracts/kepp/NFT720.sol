// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";
import "./Admin.sol";
import "hardhat/console.sol";

contract NFT720 is ERC721URIStorage, RoyaltiesV2Impl, Admin {
    using Counters for Counters.Counter;
    Counters.Counter private mintCount;
    address marketAddress;

    constructor(
        address market,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        marketAddress = market;
    }

    event TokensMinted(uint256[] tokenIdList);

    event TokenMinted(uint256);

    // The tokenURI is the metadata description of the
    // NFT

    function mintToken(
        uint256 id,
        string memory tokenURI,
        uint96 royalty
    ) public {
        

        _safeMint(msg.sender, id);
        _setTokenURI(id, tokenURI);
        mintCount.increment();

        // Set Royalties
        uint256[] memory idList = new uint256[](1);
        address[] memory tempAccount = new address[](1);
        uint96[] memory tempRoyalty = new uint96[](1);

        idList[0] = id;
        tempAccount[0] = msg.sender;
        tempRoyalty[0] = royalty;

        //Set royalties and approve for market sales

        setRoyalties(idList, tempAccount, tempRoyalty);

        setApprovalForAll(marketAddress, true);
        emit TokenMinted(id);
    }

    function mintCollection(
        uint256[] memory ids,
        string[] memory tokenList,
        address[] memory owners,
        uint96[] memory _royalties
    ) public {
        require(ids.length == tokenList.length);

        require(owners.length == _royalties.length, "");
        uint256[] memory idList = new uint256[](tokenList.length);

        for (uint256 i = 0; i < ids.length; i++) {
            mintCount.increment();
            uint256 newItemId = ids[i];

            _safeMint(msg.sender, newItemId);
            _setTokenURI(newItemId, tokenList[i]);
            idList[i] = newItemId;
        }

        //Set royalties and approve for market sales

        setRoyalties(idList, owners, _royalties);
        setApprovalForAll(marketAddress, true);

        emit TokensMinted(idList);
    }

    function setTokenURI(uint256 tokenId, string memory metadataURI) public {
        _setTokenURI(tokenId, metadataURI);
    }

    function transferToken(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(ownerOf(tokenId) == from, "N.T.O");
        _transfer(from, to, tokenId);
    }

    function burnToken(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "N.T.O");
        _burn(tokenId);
    }

    function setRoyalties(
        uint256[] memory tokenIdList,
        address[] memory owners,
        uint96[] memory percentageBasisPoints
    ) public {
        require(owners.length == percentageBasisPoints.length, "");

        uint256 size = owners.length + 1;

        LibPart.Part[] memory _royalties = new LibPart.Part[](size);

        for (uint256 i = 0; i < size - 1; i++) {
            _royalties[i].value = percentageBasisPoints[i];
            _royalties[i].account = payable(owners[i]);
        }
        _royalties[size - 1].value = 500;
        _royalties[size - 1].account = owner;

        for (uint256 i = 0; i < tokenIdList.length; i++) {
            _saveRoyalties(tokenIdList[i], _royalties);
        }
    }

    function gift(address to,   uint256[] memory tokenId) public {

        for(uint i = 0; i< tokenId.length; i++){
            transferToken(msg.sender, to, tokenId[i]);
        }


    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        if(interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }
}
