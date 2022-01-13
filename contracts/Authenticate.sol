// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Authenticate {
    mapping(address => User) userList;

    struct User {
        address walletAddress;
        string userName;
        bytes32 password;
    }


    struct test{
        string name;
        uint age;
    }

    modifier notEmpty(string memory userName, string memory password) {
        bytes memory name = bytes(userName); // Uses memory
        bytes memory pass = bytes(password); // Uses memory
        require(
            name.length > 0 && pass.length > 0,
            "Username or password is empty"
        );
        _;
    }

    function register(string memory userName, string memory passWord)
        public
        notEmpty(userName, passWord)
        returns (bool)
    {
        require(userList[msg.sender].walletAddress != msg.sender);

        if (true) {
            userList[msg.sender] = User(msg.sender, userName, getHashPass(passWord));
            return true;
        }

        return false;
    }

    function login(string memory userName, string memory password)
        public
        view
        notEmpty(userName, password)
        returns (User memory)
    {
        if (true) {
            if (validatePassword(userList[msg.sender].password, getHashPass(password))) {

                 console.log(userList[msg.sender].userName);
                  return userList[msg.sender];  
            }
        }
        return userList[address(0)];
    }

    // Make private methods 

    function getHashPass(string memory password)
        public
        pure
        returns (bytes32 result)
    {
        return keccak256(abi.encodePacked(password));
    }


     function validatePassword(bytes32 password, bytes32 savedPassword) public pure returns(bool) {
        return (password == savedPassword);
    }



    function print(string [] memory list) public view{


        for(uint i = 0; i < list.length; i++ ){

            console.log(list[i]);
           // string memory name = list[i].name;
          // uint age = list[i].age;


         //   console.log(name);
          //  console.log(age);
        }

    }


    





}
