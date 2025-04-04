# VDN - Professional Identity Vault

```
      ██╗   ██╗    ██████╗     ███╗   ██╗
      ██║   ██║    ██╔══██╗    ████╗  ██║
      ██║   ██║    ██║  ██║    ██╔██╗ ██║
      ╚██╗ ██╔╝    ██║  ██║    ██║╚██╗██║
       ╚████╔╝     ██████╔╝    ██║ ╚████║
        ╚═══╝      ╚═════╝     ╚═╝  ╚═══╝
    =======================================
     On-Chain Professional Identity Vault
    =======================================
```

## Overview

VDN is an ERC721-based smart contract that enables the storage of professional files and resumes as NFTs on the blockchain. Each token can represent a professional document with associated metadata, creating an on-chain professional identity vault.

Created by: Valerio Di Napoli  
Version: 1.0.0  
Date: March 8, 2025

## Features

- Mint NFTs representing professional documents
- Update document metadata
- On-chain metadata storage
- Document references via URLs
- Document visualization via image URLs

## Technical Details

### Contract Architecture

VDN inherits from:
- `ERC721` - OpenZeppelin's implementation of the ERC721 standard
- `Ownable` - OpenZeppelin's access control mechanism

### Data Structure

Each token has associated metadata stored in the `TokenData` struct:

```solidity
struct TokenData {
    uint64 timestamp;    // Last update timestamp
    bytes24 name;        // Document name (up to 24 UTF-8 characters)
    string description;  // Document description
    string fileUrl;      // URL to access the document
    string imageUrl;     // URL for document visualization
}
```

### Key Functions

#### `mintOrUpdate`

```solidity
function mintOrUpdate(
    uint256 tokenId,
    bytes24 name,
    string calldata description,
    string calldata imageUrl,
    string calldata fileUrl
) external onlyOwner returns (Operation)
```

Creates a new token or updates an existing one with professional document metadata. Only the contract owner can perform this operation.

Returns:
- `Operation.minted (0)` - A new token was created
- `Operation.updated (1)` - An existing token was updated

#### `tokenData`

```solidity
function tokenData(uint256 tokenId) 
    external 
    view 
    onlyExistent(tokenId) 
    returns (TokenData memory)
```

Retrieves the metadata associated with a specific token.

#### `burn`

```solidity
function burn(uint256 tokenId)
    external
    onlyExistent(tokenId)
```

Destroys a token and its associated metadata. Only the token owner or an approved address can burn tokens.

## Installation

This project uses [Foundry](https://book.getfoundry.sh/) for development, testing, and deployment.

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Setup

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd vdn
   ```

2. Install dependencies
   ```bash
   forge install
   ```

## Development

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Format

```bash
forge fmt
```

## Deployment

To deploy the contract:

```bash
forge script script/DeployVDN.s.sol --rpc-url <your-rpc-url> --private-key <your-private-key> --broadcast
```

## Usage Examples

### Creating a Professional Document NFT

```solidity
// Example: Minting a resume NFT
bytes24 name = "Professional Resume";
string memory description = "My professional resume showcasing skills and experience";
string memory imageUrl = "https://example.com/resume-preview.jpg";
string memory fileUrl = "https://example.com/resume.pdf";

// Token ID can be any unique number
uint256 tokenId = 1;

// Returns Operation.minted (0) for new tokens
Operation op = vdn.mintOrUpdate(tokenId, name, description, imageUrl, fileUrl);
```

### Updating a Document

```solidity
// Example: Updating an existing resume NFT
bytes24 name = "Updated Resume 2025";
string memory description = "My updated professional resume with recent experience";
string memory imageUrl = "https://example.com/resume-preview-2025.jpg";
string memory fileUrl = "https://example.com/resume-2025.pdf";

// Using the same token ID as before
uint256 tokenId = 1;

// Returns Operation.updated (1) for existing tokens
Operation op = vdn.mintOrUpdate(tokenId, name, description, imageUrl, fileUrl);
```

### Viewing Document Metadata

```solidity
// Retrieving metadata for a token
TokenData memory data = vdn.tokenData(1);

// The timestamp of the last update
uint64 lastUpdated = data.timestamp;

// The name of the document
bytes24 documentName = data.name;

// The document description
string memory documentDescription = data.description;

// URL to the document
string memory documentUrl = data.fileUrl;

// URL to the document image/preview
string memory previewUrl = data.imageUrl;
```

## License

This project is licensed under the MIT License.

## Security

For security concerns, please contact: vdn.directive894@passfwd.com

---

Built with [Foundry](https://book.getfoundry.sh/) and [OpenZeppelin](https://openzeppelin.com/contracts/) contracts.
