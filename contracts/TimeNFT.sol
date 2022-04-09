// SPDX-License-Identifier: MIT

// Time NFT
// The NFT changes based on the time of day

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";


contract UsingNumbers
{
    string[] public numbers = [
        "zero",
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine"
    ];
}


contract TimeNFT is ERC721, Ownable, UsingNumbers
{
    using Strings for uint256;
    uint256 public totalTokens;
    uint256 public display;

    // Metadata
    string public baseTokenURI;

    constructor
    (
        string memory baseTokenURI_
    )
        ERC721("TimeNFT", "TIME")
    {
        baseTokenURI = baseTokenURI_;
    }

    function mintTokens()
        public
        payable
    {
        _safeMint(msg.sender, totalTokens);
        ++totalTokens;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // construct metdata from tokenId
        return constructTokenURI(tokenId);
    }

    function constructTokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // build tokenURI from randomNumber
        string memory dynTokenURI = string(abi.encodePacked(baseTokenURI, numbers[display], ".png"));

        // metadata
        string memory name = string(abi.encodePacked("Time token #", tokenId.toString()));
        string memory description = "A Time based NFT";

        // prettier-ignore
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', dynTokenURI, '"}')
                    )
                )
            )
        );
    }

    // helper functions
    function setBaseURI(string memory baseTokenURI_)
        public
        onlyOwner
    {
        baseTokenURI = baseTokenURI_;
    }

    function setTime(uint256 time_)
        public
        onlyOwner
    {
        display = time_;
    }

    function kill(address payable receiver_)
        public
        onlyOwner
    {
        selfdestruct(receiver_);
    }
}
