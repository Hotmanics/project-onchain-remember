//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "forge-std/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

// consider decentralized governance to burn bad actor NFTs
// use case:
// bad actor mints inappropriate NFT.
// group of "admins" get together to work on
contract REMember is AccessControl, ERC721URIStorage {
    uint256 s_mintCount;
    uint256 s_burnThreshold;

    bytes32 public constant RIGHTER_ROLE = keccak256("RIGHTER_ROLE");

    mapping(uint256 tokenId => uint256) s_burnCount;

    constructor(address admin) ERC721("REMember", "REM") {
        grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function mint(
        address target,
        string memory tokenURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(target, s_mintCount);
        _setTokenURI(s_mintCount, tokenURI);
        s_mintCount++;
    }

    function changeBurnThreshold(
        uint256 amount
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        s_burnThreshold = amount;
    }

    function commitToBurn(
        uint256[] memory tokenIds
    ) external onlyRole(RIGHTER_ROLE) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            s_burnCount[tokenIds[i]]++;

            if (s_burnCount[tokenIds[i]] >= s_burnThreshold) {
                _burn(tokenIds[i]);
            }
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getBurnThreshold() external view returns (uint256) {
        return s_burnThreshold;
    }
}
