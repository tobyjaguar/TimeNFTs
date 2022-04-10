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
    address public Registry;
    uint256 public display;
    uint256 public lastUpdate;
    uint256 public totalTokens;

    // Metadata
    string public baseTokenURI;

    constructor
    (
        address registry_,
        string memory baseTokenURI_
    )
        ERC721("TimeNFT", "TIME")
    {
        Registry = registry_;
        baseTokenURI = baseTokenURI_;
    }

    modifier onlyRegistry()
    {
        require(msg.sender == Registry, "Sender is not Registry");
        _;
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

    // keepers functions
    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (lastUpdate < (block.timestamp + 1 minutes));
    }

    function performUpkeep(bytes calldata /* performData */)
        external
        onlyRegistry
    {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if (lastUpdate < (block.timestamp + 1 minutes)) {
            lastUpdate = block.timestamp;
            display = ((block.timestamp % 60) % 10);
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
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

    function setRegistry(address address_)
        public
        onlyOwner
    {
        Registry = address_;
    }

    function kill(address payable receiver_)
        public
        onlyOwner
    {
        selfdestruct(receiver_);
    }
}
