//SPDX-License-Identifier: Unlicensed
// Crypto Devs Contract Address: 0xf942De4C32905Ee245c98C8F0c0372cD088FE789
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    string _baseTokenURI;
    uint256 public _price = 0.01 ether;
    uint256 public maxTokenIds = 20;
    uint256 public tokenIds;
    bool public _paused;
    bool public presaleStarted;
    uint256 public presaleEnded;

    IWhitelist whitelist;

    modifier onlyWhenNotPaused() {
        require(_paused, "Contract currently is paused.");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Crypto Dev", "CD")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "Presale is not Running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "You are not whitelisted."
        );
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Dev supply.");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp >= presaleEnded,
            "Presale is not ended"
        );
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Dev supply.");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}
