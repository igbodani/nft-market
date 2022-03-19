// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Admin.sol";
import "./rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "./rarible/royalties/contracts/LibPart.sol";
import "./rarible/royalties/contracts/LibRoyaltiesV2.sol";
import "hardhat/console.sol";
 
contract NFT1155 is Admin, RoyaltiesV2Impl, ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private mintCount;
    string public name;
    string public symbol;
    address marketAddress;

    constructor(
        address market,
        string memory url,
        string memory _name,
        string memory _symbol
    ) ERC1155(url) {
        name = _name;
        symbol = _symbol;
        marketAddress = market;
    }

    event TokensMinted(uint256[] tokenIdList);

    event TokenMinted(uint256);

    function setURl(string memory newUri) public onlyOwner {
        _setURI(newUri);
    }

    function mintToken(
        uint256 id,
        uint256 amount,
        bytes memory data,
        uint96 _royalties
    ) public {


        _mint(msg.sender, id, amount, data);
        console.log(id);

        mintCount.increment();

        // Set Royalties arrays
        uint256[] memory idList = new uint256[](1);
        address[] memory tempAccount = new address[](1);
        uint96[] memory tempRoyalty = new uint96[](1);

        idList[0] = id;
        tempAccount[0] = msg.sender;
        tempRoyalty[0] = _royalties;

        //Set royalties and approve for market sales

        setRoyalties(idList, tempAccount, tempRoyalty);
        setApprovalForAll(marketAddress, true);

        emit TokenMinted(id);
    }

    function mintBatch(
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data,
        address[] memory owners,
        uint96[] memory _royalties
    ) public {

       require(owners.length == _royalties.length, "");

         address to = msg.sender;
        _mintBatch(to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            mintCount.increment();
        }

        //Set royalties and approve for market sales
        setRoyalties(ids, owners, _royalties);
        _setApprovalForAll(msg.sender, marketAddress, true);

        emit TokensMinted(ids);
    }

    function burnToken(
        uint256 tokenId,
        uint256 amount
    ) public {
        _burn(msg.sender, tokenId, amount);
    }


    function transferToken(address to,  uint256 tokenId, uint256 amount) public {
        safeTransferFrom(msg.sender, to, tokenId, amount, "");
        approveOwner(msg.sender, to, true);
    }

    function approveOwner(address from, address to, bool approve)  public {
         _setApprovalForAll(from, to, approve);
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



    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool) {
        if(interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }
}
