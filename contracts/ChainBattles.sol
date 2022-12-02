// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct Character{
        uint256 id;
        uint256 level;
        uint256 hp;
        uint256 strength;
        uint256 agility;
    }
    
    mapping(uint256 => Character) public tokenIdToChars;

    constructor() ERC721("Chain Battles", "CBTLS"){}

    function generateCharacter(uint256 tokenId) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: purple; font-family: serif; font-size: 18px; }</style>',
            '<rect width="100%" height="100%" fill="gray" />',
            '<img src=',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">Daddrake </text>',
            getStats(tokenId), '</svg>'
        );    
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevels(uint256 tokenId) public view returns(string memory){
        uint256 levels = tokenIdToChars[tokenId].level;
        return levels.toString();
    }

    function getStats(uint256 tokenID) public view returns(string memory){
        string memory res = string(
            abi.encodePacked(
                '<text x="20%" y="30%" class="base" dominant-baseline="left" text-anchor="left">ID: ', tokenIdToChars[tokenID].id.toString(), '</text>',
                '<text x="20%" y="40%" class="base" dominant-baseline="left" text-anchor="left">Level: ', tokenIdToChars[tokenID].level.toString(),'</text>',
                '<text x="20%" y="50%" class="base" dominant-baseline="left" text-anchor="left">HP: ', tokenIdToChars[tokenID].hp.toString(),'</text>',
                '<text x="20%" y="60%" class="base" dominant-baseline="left" text-anchor="left">Strength: ', tokenIdToChars[tokenID].strength.toString(),'</text>',
                '<text x="20%" y="70%" class="base" dominant-baseline="left" text-anchor="left">Speed: ', tokenIdToChars[tokenID].agility.toString(),'</text>'                      
        ));
        return res;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    
    function mint() public {
        _tokenIds.increment();
        uint256 tokenid = _tokenIds.current();
        _safeMint(msg.sender, tokenid);
        tokenIdToChars[tokenid].id = tokenid;
        tokenIdToChars[tokenid].level = 1; 
        tokenIdToChars[tokenid].hp = random(100);
        tokenIdToChars[tokenid].strength = random(10);
        tokenIdToChars[tokenid].agility = random(10);
        _setTokenURI(tokenid, getTokenURI(tokenid));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
        tokenIdToChars[tokenId].level += 1;
        tokenIdToChars[tokenId].hp += 50;
        tokenIdToChars[tokenId].strength += 5;
        tokenIdToChars[tokenId].agility += 5;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function random(uint256 number) public view returns(uint256){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }
}