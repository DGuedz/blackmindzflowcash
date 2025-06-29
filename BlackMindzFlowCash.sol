// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title BlackMindzFlowCash
 * @dev Music NFT platform with streaming royalties on Scroll Network
 * @author Black Mindz Team
 * 
 * Transforme seu flow em $USD - Plataforma de tokenização musical
 * 
 * Features:
 * - Music NFT minting (ERC-721)
 * - USDT streaming payments
 * - Automatic royalty distribution (97.5% to artist)
 * - Artist analytics and earnings tracking
 * - Platform fee collection (2.5%)
 * - Pause/unpause functionality for emergency
 * - Comprehensive event logging
 */
contract BlackMindzFlowCash is 
    ERC721, 
    ERC721URIStorage, 
    ERC721Enumerable,
    ReentrancyGuard, 
    Pausable,
    Ownable 
{
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    // ========== STATE VARIABLES ==========
    
    // USDT contract interface
    IERC20 public immutable USDT;
    
    // Platform configuration
    uint256 public constant PLATFORM_FEE_BASIS_POINTS = 250; // 2.5%
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_PRICE_PER_STREAM = 1000000; // $1 USDT (6 decimals)
    uint256 public constant MIN_PRICE_PER_STREAM = 1000; // $0.001 USDT (6 decimals)
    
    // Counters
    Counters.Counter private _tokenIdCounter;
    
    // ========== STRUCTS ==========
    
    struct Track {
        uint256 tokenId;
        address payable artist;
        string title;
        string audioHash; // IPFS hash for audio file
        string coverArtHash; // IPFS hash for cover art
        uint256 pricePerStream; // Price in USDT (6 decimals)
        uint256 totalStreams;
        uint256 totalEarnings;
        uint256 createdAt;
        bool isActive;
        uint256 duration; // Track duration in seconds
        string genre;
        uint256 likes;
    }
    
    struct StreamPayment {
        uint256 trackId;
        address listener;
        uint256 streamCount;
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
    }
    
    struct ArtistStats {
        uint256 totalTracks;
        uint256 totalStreams;
        uint256 totalEarnings;
        uint256 totalLikes;
        uint256 joinedAt;
        bool isVerified;
    }

    // ========== MAPPINGS ==========
    
    mapping(uint256 => Track) public tracks;
    mapping(address => uint256[]) public artistTracks;
    mapping(address => ArtistStats) public artistStats;
    mapping(uint256 => StreamPayment[]) public trackStreamHistory;
    mapping(address => mapping(uint256 => bool)) public userLikedTrack;
    mapping(string => bool) public usedAudioHashes; // Prevent duplicate uploads
    
    // ========== EVENTS ==========
    
    event TrackMinted(
        uint256 indexed tokenId,
        address indexed artist,
        string title,
        uint256 pricePerStream,
        string audioHash,
        string genre
    );
    
    event StreamPurchased(
        uint256 indexed trackId,
        address indexed listener,
        address indexed artist,
        uint256 streamCount,
        uint256 totalAmount,
        uint256 artistAmount,
        uint256 platformFee
    );
    
    event TrackLiked(
        uint256 indexed trackId,
        address indexed user,
        uint256 totalLikes
    );
    
    event TrackUnliked(
        uint256 indexed trackId,
        address indexed user,
        uint256 totalLikes
    );
    
    event TrackStatusChanged(
        uint256 indexed trackId,
        bool isActive
    );
    
    event ArtistVerified(
        address indexed artist,
        bool verified
    );
    
    event PlatformFeesWithdrawn(
        address indexed owner,
        uint256 amount
    );
    
    event TrackPriceUpdated(
        uint256 indexed trackId,
        uint256 oldPrice,
        uint256 newPrice
    );

    // ========== MODIFIERS ==========
    
    modifier onlyTrackOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not track owner");
        _;
    }
    
    modifier validPrice(uint256 price) {
        require(
            price >= MIN_PRICE_PER_STREAM && price <= MAX_PRICE_PER_STREAM,
            "Invalid price range"
        );
        _;
    }
    
    modifier trackExists(uint256 tokenId) {
        require(_exists(tokenId), "Track does not exist");
        _;
    }

    // ========== CONSTRUCTOR ==========
    
    constructor(address _usdtAddress) 
        ERC721("Black Mindz Flow Cash", "BMFC") 
    {
        require(_usdtAddress != address(0), "Invalid USDT address");
        USDT = IERC20(_usdtAddress);
        _tokenIdCounter.increment(); // Start from token ID 1
    }

    // ========== MINTING FUNCTIONS ==========
    
    /**
     * @dev Mint a new music track NFT
     * @param artist Address of the artist (will own the NFT)
     * @param title Song title
     * @param audioHash IPFS hash of the audio file
     * @param coverArtHash IPFS hash of the cover art
     * @param metadataURI Complete metadata URI for the NFT
     * @param pricePerStream Price per stream in USDT (6 decimals)
     * @param duration Track duration in seconds
     * @param genre Music genre
     */
    function mintTrack(
        address payable artist,
        string memory title,
        string memory audioHash,
        string memory coverArtHash,
        string memory metadataURI,
        uint256 pricePerStream,
        uint256 duration,
        string memory genre
    ) 
        external 
        whenNotPaused
        validPrice(pricePerStream)
        returns (uint256) 
    {
        require(artist != address(0), "Invalid artist address");
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(audioHash).length > 0, "Audio hash cannot be empty");
        require(!usedAudioHashes[audioHash], "Audio already uploaded");
        require(duration > 0, "Duration must be greater than 0");
        require(bytes(genre).length > 0, "Genre cannot be empty");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        // Mint NFT to artist
        _safeMint(artist, tokenId);
        _setTokenURI(tokenId, metadataURI);
        
        // Create track record
        tracks[tokenId] = Track({
            tokenId: tokenId,
            artist: artist,
            title: title,
            audioHash: audioHash,
            coverArtHash: coverArtHash,
            pricePerStream: pricePerStream,
            totalStreams: 0,
            totalEarnings: 0,
            createdAt: block.timestamp,
            isActive: true,
            duration: duration,
            genre: genre,
            likes: 0
        });
        
        // Mark audio hash as used
        usedAudioHashes[audioHash] = true;
        
        // Update artist stats
        artistTracks[artist].push(tokenId);
        
        if (artistStats[artist].joinedAt == 0) {
            artistStats[artist].joinedAt = block.timestamp;
        }
        artistStats[artist].totalTracks++;
        
        emit TrackMinted(tokenId, artist, title, pricePerStream, audioHash, genre);
        return tokenId;
    }

    // ========== STREAMING FUNCTIONS ==========
    
    /**
     * @dev Purchase streams for a track
     * @param tokenId Track to stream
     * @param streamCount Number of streams to purchase
     */
    function purchaseStreams(uint256 tokenId, uint256 streamCount) 
        external 
        nonReentrant
        whenNotPaused
        trackExists(tokenId)
    {
        require(streamCount > 0, "Stream count must be greater than 0");
        require(streamCount <= 1000, "Max 1000 streams per transaction");
        
        Track storage track = tracks[tokenId];
        require(track.isActive, "Track is not active");
        
        // Calculate payments
        uint256 totalAmount = track.pricePerStream * streamCount;
        uint256 platformFee = (totalAmount * PLATFORM_FEE_BASIS_POINTS) / BASIS_POINTS;
        uint256 artistAmount = totalAmount - platformFee;
        
        // Transfer USDT from listener
        USDT.safeTransferFrom(msg.sender, address(this), totalAmount);
        
        // Pay artist immediately
        USDT.safeTransfer(track.artist, artistAmount);
        
        // Update track stats
        track.totalStreams += streamCount;
        track.totalEarnings += artistAmount;
        
        // Update artist stats
        artistStats[track.artist].totalStreams += streamCount;
        artistStats[track.artist].totalEarnings += artistAmount;
        
        // Record stream payment
        trackStreamHistory[tokenId].push(StreamPayment({
            trackId: tokenId,
            listener: msg.sender,
            streamCount: streamCount,
            amount: totalAmount,
            timestamp: block.timestamp,
            blockNumber: block.number
        }));
        
        emit StreamPurchased(
            tokenId,
            msg.sender,
            track.artist,
            streamCount,
            totalAmount,
            artistAmount,
            platformFee
        );
    }

    // ========== INTERACTION FUNCTIONS ==========
    
    /**
     * @dev Like a track
     * @param tokenId Track to like
     */
    function likeTrack(uint256 tokenId) 
        external 
        trackExists(tokenId) 
    {
        require(!userLikedTrack[msg.sender][tokenId], "Already liked");
        
        userLikedTrack[msg.sender][tokenId] = true;
        tracks[tokenId].likes++;
        artistStats[tracks[tokenId].artist].totalLikes++;
        
        emit TrackLiked(tokenId, msg.sender, tracks[tokenId].likes);
    }
    
    /**
     * @dev Unlike a track
     * @param tokenId Track to unlike
     */
    function unlikeTrack(uint256 tokenId) 
        external 
        trackExists(tokenId) 
    {
        require(userLikedTrack[msg.sender][tokenId], "Not liked yet");
        
        userLikedTrack[msg.sender][tokenId] = false;
        tracks[tokenId].likes--;
        artistStats[tracks[tokenId].artist].totalLikes--;
        
        emit TrackUnliked(tokenId, msg.sender, tracks[tokenId].likes);
    }

    // ========== ARTIST FUNCTIONS ==========
    
    /**
     * @dev Toggle track active status (artist only)
     * @param tokenId Track to toggle
     */
    function toggleTrackStatus(uint256 tokenId) 
        external 
        onlyTrackOwner(tokenId) 
    {
        tracks[tokenId].isActive = !tracks[tokenId].isActive;
        emit TrackStatusChanged(tokenId, tracks[tokenId].isActive);
    }
    
    /**
     * @dev Update track price (artist only)
     * @param tokenId Track to update
     * @param newPrice New price per stream
     */
    function updateTrackPrice(uint256 tokenId, uint256 newPrice) 
        external 
        onlyTrackOwner(tokenId)
        validPrice(newPrice)
    {
        uint256 oldPrice = tracks[tokenId].pricePerStream;
        tracks[tokenId].pricePerStream = newPrice;
        
        emit TrackPriceUpdated(tokenId, oldPrice, newPrice);
    }

    // ========== ADMIN FUNCTIONS ==========
    
    /**
     * @dev Verify an artist (owner only)
     * @param artist Artist address to verify
     * @param verified Verification status
     */
    function verifyArtist(address artist, bool verified) 
        external 
        onlyOwner 
    {
        artistStats[artist].isVerified = verified;
        emit ArtistVerified(artist, verified);
    }
    
    /**
     * @dev Withdraw platform fees (owner only)
     */
    function withdrawPlatformFees() 
        external 
        onlyOwner 
        nonReentrant 
    {
        uint256 balance = USDT.balanceOf(address(this));
        require(balance > 0, "No fees to withdraw");
        
        USDT.safeTransfer(owner(), balance);
        emit PlatformFeesWithdrawn(owner(), balance);
    }
    
    /**
     * @dev Pause contract (emergency)
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause contract
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    // ========== VIEW FUNCTIONS ==========
    
    /**
     * @dev Get track details
     */
    function getTrack(uint256 tokenId) 
        external 
        view 
        trackExists(tokenId)
        returns (Track memory) 
    {
        return tracks[tokenId];
    }
    
    /**
     * @dev Get tracks by artist
     */
    function getArtistTracks(address artist) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return artistTracks[artist];
    }
    
    /**
     * @dev Get artist statistics
     */
    function getArtistStats(address artist) 
        external 
        view 
        returns (ArtistStats memory) 
    {
        return artistStats[artist];
    }
    
    /**
     * @dev Get track stream history
     */
    function getTrackStreamHistory(uint256 tokenId) 
        external 
        view 
        returns (StreamPayment[] memory) 
    {
        return trackStreamHistory[tokenId];
    }
    
    /**
     * @dev Get platform stats
     */
    function getPlatformStats() 
        external 
        view 
        returns (
            uint256 totalTracks,
            uint256 totalStreams,
            uint256 totalEarnings,
            uint256 platformBalance
        ) 
    {
        totalTracks = _tokenIdCounter.current() - 1;
        
        // Note: These would be expensive to calculate on-chain for large datasets
        // In production, consider using events and off-chain indexing
        for (uint256 i = 1; i < _tokenIdCounter.current(); i++) {
            if (_exists(i)) {
                totalStreams += tracks[i].totalStreams;
                totalEarnings += tracks[i].totalEarnings;
            }
        }
        
        platformBalance = USDT.balanceOf(address(this));
    }
    
    /**
     * @dev Check if user liked a track
     */
    function hasUserLikedTrack(address user, uint256 tokenId) 
        external 
        view 
        returns (bool) 
    {
        return userLikedTrack[user][tokenId];
    }
    
    /**
     * @dev Get current token ID counter
     */
    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // ========== REQUIRED OVERRIDES ==========
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
    
    function _burn(uint256 tokenId) 
        internal 
        override(ERC721, ERC721URIStorage) 
    {
        super._burn(tokenId);
        
        // Clean up mappings
        string memory audioHash = tracks[tokenId].audioHash;
        if (bytes(audioHash).length > 0) {
            usedAudioHashes[audioHash] = false;
        }
        delete tracks[tokenId];
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// Principais Features do Contrato: Core Functionality:
ERC-721 NFTs para tokenização musical
Pagamentos em USDT por stream
Royalties automáticos (97.5% artista, 2.5% plataforma)
Sistema de likes e interações
Segurança:
ReentrancyGuard - Proteção contra ataques de reentrada
Pausable - Função de emergência para parar o contrato
SafeERC20 - Transfers seguros de USDT
Access Control - Funções restritas por papel
Analytics & Stats:
Estatísticas detalhadas por artista
Histórico completo de streams
Prevenção de duplicatas (hash de áudio único)
Sistema de verificação de artistas
Otimizações para Scroll:
Gas eficiente com Counters library
Batch operations suportadas
Events estruturados para indexação
Limits sensatos (max 1000 streams por tx)
