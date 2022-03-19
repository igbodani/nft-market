// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

abstract contract Admin {

    address payable  owner;
    address [] private admins;
    uint256 salesPrice = 2;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), owner);
    }



    function getSalesPrice(uint256 price) public view returns (uint256) {
        uint256 temp = (salesPrice * price) / 100;
        return temp;
    }



     /**
     * @dev Returns the address of the current owner.
     */
    function getOwner() public view virtual returns (address) {
        return owner;
    }

   


     /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(getOwner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

      modifier onlyAdmin(address wallet) {
        require(checkAddress(wallet, admins), "Only Admins can perform this operation");
        _;
    }



     // Add address to admin array
    function addAddress(address wallet) public {
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


     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

     function _transferOwnership(address  newOwner) internal virtual {
        address payable oldOwner = owner;
        owner = payable(newOwner);
        emit OwnershipTransferred(oldOwner, newOwner);
    }

     function checkAddress(address wallet, address[] memory list) public pure returns (bool) {
         
        bool check = false;

        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == wallet) {
                check = true;
            }
        }
        return check;
    }



}
