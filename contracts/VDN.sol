// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 *      ██╗   ██╗    ██████╗     ███╗   ██╗
 *      ██║   ██║    ██╔══██╗    ████╗  ██║
 *      ██║   ██║    ██║  ██║    ██╔██╗ ██║
 *      ╚██╗ ██╔╝    ██║  ██║    ██║╚██╗██║
 *       ╚████╔╝     ██████╔╝    ██║ ╚████║
 *        ╚═══╝      ╚═════╝     ╚═╝  ╚═══╝
 *    =======================================
 *     On-Chain Professional Identity Vault
 *    =======================================
 */

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title VDN
 * @author Valerio Di Napoli
 * @notice ERC721 contract for storing resume and other professional
 * files as NFTs
 * @dev Implements: IERC721, IERC165. Inherits: Ownable.
 * @custom:security-contact vdn.directive894@passfwd.com
 * @custom:version 1.0.0
 * @custom:date-created 2025-03-08
 */
contract VDN is ERC721, Ownable {

    using Strings for uint256;

    /**
     * @dev Represents the data attached to a token
     * @param timestamp The timestamp of the last update
     * @param name The name of the file (bytes24 for gas efficiency,
     *             supports up to 24 UTF-8 characters)
     * @param description A description of the file
     * @param fileUrl A URL pointing to the file
     * @param imageUrl A URL pointing to an image representing the file
     */
    struct TokenData {
        uint64 timestamp;
        bytes24 name;
        string description;
        string fileUrl;
        string imageUrl;
    }

    /**
     * @dev Represents the operation that was performed on a token
     * @param minted Token was newly created
     * @param updated Existing token was updated
     */
    enum Operation {
        minted,
        updated
    }

    /**
     * @dev Emitted when a token's data is updated
     * @param tokenId The ID of the updated token
     */
    event DataUpdated(
        uint256 indexed tokenId
    ); // 0x7f7c5356

    /// @dev Thrown if a token does not exist
    error NonExistentToken(uint256 tokenId); // 0x38077a2b

    /// @dev Token Id => Token Data
    mapping (uint256 => TokenData) private _tokenData;

    /// @dev Modifier to revert if the token does not exist
    modifier onlyExistent(uint256 tokenId) {
        if(!_exists(tokenId)) revert NonExistentToken(tokenId);
        _;
    }

    /**
     * @dev Initializes the contract by setting a name and a symbol to
     * the token collection
     */
    constructor() ERC721("VDN", "VDN") Ownable(msg.sender) {}

    /**
     * @notice Returns the Uniform Resource Identifier (URI) for
     * `tokenId` token.
     * @param tokenId The ID of the token to query
     * @return The token URI
     */
    function tokenURI(uint256 tokenId) 
        public 
        view  
        override 
        returns (string memory) 
    {
        return _assembleTokenURI(tokenId);
    }

    /**
     * @notice Returns the data for a specific token
     * @param tokenId The ID of the token to query
     * @return The token data
     * @dev Reverts with `NonExistentToken` if the token does not exist
     */
    function tokenData(uint256 tokenId) 
        external 
        view 
        onlyExistent(tokenId) 
        returns (TokenData memory) 
    {
        return _tokenData[tokenId];
    }

    /**
     * @notice Mints a new token or updates an existing one. Only the
     * contract owner can mint new tokens.
     * @param tokenId The ID of the token to mint or update
     * @param name The name of the file attached to the token
     * @param description A description of the file
     * @param imageUrl A URL pointing to an image representing the file
     * @param fileUrl A URL pointing to the file
     * @return operation The operation that was performed:
     *         Operation.minted (0) if a new token was created
     *         Operation.updated (1) if an existing token was updated
     */
    function mintOrUpdate(
        uint256 tokenId,
        bytes24 name,
        string calldata description,
        string calldata imageUrl,
        string calldata fileUrl
    )
        external
        onlyOwner
        returns (Operation)
    {
        _setTokenData(
            tokenId,
            TokenData({
                name: name,
                description: description,
                imageUrl: imageUrl,
                fileUrl: fileUrl,
                timestamp: uint64(block.timestamp)
            })
        );
        if (!_exists(tokenId)) {
            _safeMint(msg.sender, tokenId);
            return Operation.minted;
        }
        return Operation.updated;
    }

    /**
     * @notice Burns (destroys) a specific token. Only the token owner
     * or an approved address can burn tokens (this is natively enforced
     * by the _update function, hence no additional checks are needed).
     * @param tokenId The ID of the token to burn
     * @dev Uses direct _update call rather than _burn to save gas.
     */
    function burn(uint256 tokenId)
        external
        onlyExistent(tokenId)
    {
        delete _tokenData[tokenId];
        _update(address(0), tokenId, _msgSender());
    }

    // ===================== Private functions =====================

    /**
     * @dev Sets the data for a token and emits the DataUpdated event.
     * Gas optimization: Performs a single SSTORE (storage write)
     * @param tokenId The ID of the token to set data for
     * @param data The data to set for the token
     */
    function _setTokenData(
        uint256 tokenId,
        TokenData memory data
    ) private {
        _tokenData[tokenId] = data;
        emit DataUpdated(tokenId);
    }

    /**
     * @dev Generates a base64 encoded data URI containing the token
     * metadata
     * @param tokenId The ID of the token to generate metadata for
     * @return A data URI with base64 encoded JSON metadata
     */
    function _assembleTokenURI(uint256 tokenId)
        private
        view
        onlyExistent(tokenId)
        returns (string memory)
    {    
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name":"', _tokenData[tokenId].name, '",',
                '"description":"', _tokenData[tokenId].description, '",',
                '"external_url":"', _tokenData[tokenId].fileUrl, '",',
                '"image":"', _tokenData[tokenId].imageUrl, '",',
                '"attributes": [{',
                    '"display_type": "number",',
                    '"trait_type": "Timestamp",',
                    '"value": ', uint256(_tokenData[tokenId].timestamp).toString(),
                '}]',
            '}'
        );

        return string.concat(
            "data:application/json;base64,",
            Base64.encode(dataURI)
        );
    }
    
    /**
     * @dev Checks if a token exists
     * @param tokenId The ID of the token to check
     * @return bool indicating whether the token exists
     */
    function _exists(uint256 tokenId) private view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}