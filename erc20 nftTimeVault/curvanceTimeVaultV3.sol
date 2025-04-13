// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 0x7bde82f20000000000000000000000000000000000000000000000000000421515a234a800000000000000000000000053c02ddd9804e318472dbe5c4297834a7b80ba0e
//Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable
// contract nativeTimeVault is Ownable, ReentrancyGuard {
contract CurvanceTimeVault is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    address public nftAddress;
    uint256 public nftPrice;
    uint256 public nftLimitPerAddress;
    uint256 public activeFunds;
    uint256 public totalFunds;
    uint256 public yieldedFunds;
    uint256 public activeYieldedFunds;
    address public PartnerContract;
    address public erc20Address;
    uint256 public platformFees = 100; // 1%
    uint256 public totalFeeCollected;
    uint256 public joiningPeriod;
    uint256 public claimingPeriod;
    uint256 public CompoundCounter;
    uint256 public prejoinPeriod;
    uint256 public bribeCount;

    struct Vault {
        uint256 ethAmount;
        uint256 nftAmount;
    }
    struct Bribe {
        address tokenAddress;
        uint256 value;
    }

    mapping(address => Vault) public vaults;
    mapping(address => mapping(address => uint256)) public briber;
    mapping(address => uint256) public bribes;
    address[] public bribeTokenAddr;
    mapping(uint256 => bool) public nftClaimed;

    event FundsWithdrawn(address indexed receiver);
    event FeesCollected(uint256 amount);
    event ExternalFundsDeposited(uint256 amount);
    event VaultJoined(address indexed user, uint256 amount);
    event Compounded(uint256 amount);

    // constructor(
    //     uint256 _nftPrice,
    //     uint256 _nftLimitPerAddress,
    //     address initialOwner,
    //     uint256 _nftLimit,
    //     uint256 _joiningPeriod,
    //     uint256 _claimingPeriod,
    //     address _PartnerContract,
    //     address _erc20Address,
    //     uint256 _prejoinPeriod
    // ) Ownable(initialOwner) {
    //     nftPrice = _nftPrice;
    //     nftLimitPerAddress = _nftLimitPerAddress;
    //     TimeNft nftContract = new TimeNft(
    //         address(this),
    //         _nftLimit,
    //         initialOwner
    //     );
    //     nftAddress = address(nftContract);
    //     joiningPeriod = _joiningPeriod;
    //     claimingPeriod = _claimingPeriod;
    //     PartnerContract = _PartnerContract;
    //     erc20Address = _erc20Address;
    //     prejoinPeriod = _prejoinPeriod;
    // }
    function initialize(
        uint256 _nftPrice,
        uint256 _nftLimitPerAddress,
        address initialOwner,
        uint256 _nftLimit,
        uint256 _joiningPeriod,
        uint256 _claimingPeriod,
        address _PartnerContract,
        address _erc20Address,
        uint256 _prejoinPeriod
    ) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        nftPrice = _nftPrice;
        nftLimitPerAddress = _nftLimitPerAddress;
        TimeNft nftContract = new TimeNft(
            address(this),
            _nftLimit,
            initialOwner
        );
        nftAddress = address(nftContract);
        joiningPeriod = _joiningPeriod;
        claimingPeriod = _claimingPeriod;
        PartnerContract = _PartnerContract;
        erc20Address = _erc20Address;
        prejoinPeriod = _prejoinPeriod;
    }
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function joinVault(uint256 _nftAmount) public {
        require(getState() == 0, "Waiting period");
        require(
            getNftCount() + _nftAmount <= TimeNft(nftAddress).nftLimit(),
            "Exceeds NFT limit"
        );
        require(_nftAmount <= nftLimitPerAddress, "Cannot mint more");

        IERC20 erc20 = IERC20(erc20Address);
        uint256 amount = _nftAmount * nftPrice;

        require(erc20.balanceOf(msg.sender) >= amount, "insuffBalance");
        require(
            erc20.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        erc20.approve(PartnerContract, amount);

        (bool success, bytes memory data) = PartnerContract.call(
            abi.encodeWithSignature("mint(uint256)", amount)
        );
        require(success, string(data));

        Vault storage userVault = vaults[msg.sender];
        require(
            userVault.nftAmount + _nftAmount <= nftLimitPerAddress,
            "Limit exceeded"
        );

        TimeNft(nftAddress).safeMint(msg.sender, _nftAmount);
        userVault.ethAmount += amount;
        userVault.nftAmount += _nftAmount;
        activeFunds += amount;
        totalFunds += amount;

        emit VaultJoined(msg.sender, amount);
    }

    function automateCoumpounding() public {
        EnhancedERC4626 pContract = EnhancedERC4626(PartnerContract);
        IERC20 erc20 = IERC20(erc20Address);
        uint256 stakedBal = pContract.balanceOf(address(this));

        // require(pContract.redeem(), "Redemption failed");
        uint256 before = IERC20(erc20Address).balanceOf(address(this));
        (bool successV2, bytes memory dataV2) = PartnerContract.call(
            abi.encodeWithSignature(
                "redeem(uint256,address)",
                stakedBal,
                address(this)
            )
        );
        require(successV2, string(dataV2));

        uint256 redeemedAmount = IERC20(erc20Address).balanceOf(address(this)) -
            before;
        yieldedFunds = redeemedAmount;
        activeYieldedFunds = redeemedAmount;

        erc20.approve(PartnerContract, redeemedAmount);

        (bool success, bytes memory data) = PartnerContract.call(
            abi.encodeWithSignature("mint(uint256)", redeemedAmount)
        );
        require(success, string(data));
        // pContract.mint(redeemedAmount);
        CompoundCounter++;

        emit Compounded(redeemedAmount);
    }

    function claimBack() public nonReentrant {
        require(getState() == 2, "Wait for claim period");
        uint256 balance = TimeNft(nftAddress).balanceOf(msg.sender);
        require(balance > 0, "No NFTs");

        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = TimeNft(nftAddress).tokenOfOwnerByIndex(
                msg.sender,
                0
            );
            if (!nftClaimed[tokenId]) {
                uint256 total = yieldedFunds / getNftCount();
                uint256 fees = (total * platformFees) / 10000;
                uint256 claimAmount = total - fees;

                totalFeeCollected += fees;
                EnhancedERC4626 pContract = EnhancedERC4626(PartnerContract);

                // pContract.redeem();
                (bool successV2, bytes memory dataV2) = PartnerContract.call(
                    abi.encodeWithSignature(
                        "redeem(uint256,address)",
                        pContract.convertToShares(claimAmount),
                        msg.sender
                    )
                );
                require(successV2, string(dataV2));

                activeYieldedFunds -= claimAmount;
                nftClaimed[tokenId] = true;
                TimeNft(nftAddress).burn(tokenId);

                for (uint256 j = 0; j < bribeCount; j++) {
                    uint256 totalP = bribes[bribeTokenAddr[j]] / getNftCount();
                    IERC20 erc20 = IERC20(bribeTokenAddr[j]);
                    erc20.transfer(msg.sender, totalP);
                }
            }
        }
    }

    function changeTimePeriod(
        uint256 _joiningPeriod,
        uint256 _claimingPeriod,
        uint256 _prejoinPeriod
    ) external onlyOwner {
        joiningPeriod = _joiningPeriod;
        claimingPeriod = _claimingPeriod;
        prejoinPeriod = _prejoinPeriod;
    }

    function changeFees(uint256 _fee) external onlyOwner {
        platformFees = _fee;
    }

    function collectFee() external onlyOwner {
        uint256 total = yieldedFunds;
        uint256 fees = (total * platformFees) / 10000;
        totalFeeCollected += fees;

        EnhancedERC4626 pContract = EnhancedERC4626(PartnerContract);
        // pContract.redeem(pContract.convertToShares(fees), msg.sender);

        (bool successV2, bytes memory dataV2) = PartnerContract.call(
            abi.encodeWithSignature(
                "redeem(uint256,address)",
                pContract.convertToShares(fees),
                msg.sender
            )
        );
        require(successV2, string(dataV2));

        activeYieldedFunds -= fees;
        emit FeesCollected(fees);
    }

    // function withdrawAllFunds(address payable receiver) public onlyOwner {
    //     EnhancedERC4626 pContract = EnhancedERC4626(PartnerContract);
    //     uint256 stakedBal = pContract.balanceOf(address(this));
    //     require(pContract.redeem(stakedBal, address(this)), "Redemption failed");

    //     activeFunds = 0;
    //     totalFunds = 0;
    //     yieldedFunds = 0;
    //     activeYieldedFunds = 0;
    //     emit FundsWithdrawn(receiver);
    // }

    // function depositExternalFunds() public payable onlyOwner {
    //     yieldedFunds += msg.value;
    //     activeYieldedFunds += msg.value;
    //     emit ExternalFundsDeposited(msg.value);
    // }

    function bribe(uint256 _amnt, address _tknAddress) external {
        require(getState() != 2);
        require(_amnt > 0, "Amount must be positive");
        IERC20 erc20 = IERC20(_tknAddress);
        require(
            erc20.allowance(msg.sender, address(this)) >= _amnt,
            "Insufficient allowance"
        );
        erc20.transferFrom(msg.sender, address(this), _amnt);
        briber[msg.sender][_tknAddress] += _amnt;
        if (bribes[_tknAddress] == 0) {
            bribeCount++;
            bribeTokenAddr.push(_tknAddress);
        }
        bribes[_tknAddress] += _amnt;
    }

    function pauseNft() external onlyOwner {
        TimeNft(nftAddress).pause();
    }

    function canCompound()
        external
        view
        returns (bool canExec, bytes memory execPayload)
    {
        canExec = getState() == 1;
        execPayload = abi.encodeWithSelector(
            this.automateCoumpounding.selector
        );
    }

    function getState() public view returns (uint256) {
        if (block.timestamp < joiningPeriod && block.timestamp > prejoinPeriod)
            return 0;
        if (block.timestamp < claimingPeriod && block.timestamp > prejoinPeriod)
            return 1;
        if (block.timestamp < prejoinPeriod) return 3;
        return 2;
    }

    function getNftCount() public view returns (uint256) {
        return TimeNft(nftAddress).tokenIdCounter();
    }

    receive() external payable {}
}

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract TimeNft is
    ERC721,
    ERC721Pausable,
    ERC721Enumerable,
    Ownable,
    ERC721Burnable,
    IERC2981
{
    uint256 public tokenIdCounter = 0;
    string private _baseTokenURI;
    address public vaultAddress;
    uint256 public nftLimit;
    address public royaltyRecipient;
    uint256 public royaltyBps = 500;

    constructor(
        address initialOwner,
        // string memory baseURI,
        uint256 _nftLimit,
        address _royaltyRecipient
    )
        ERC721("MeowFi - Curvance & Fastlane Vault NFT", "MCF")
        Ownable(initialOwner)
    {
        _baseTokenURI = "https://plum-imaginative-guan-725.mypinata.cloud/ipfs/bafkreicdqcbrqsq44vqqiexxqgbziamdahlmvihuolecymqqzpn2ztztsa";

        nftLimit = _nftLimit;
        royaltyRecipient = _royaltyRecipient;
    }

    function setVaultAddress(address _vaultAddress) external onlyOwner {
        vaultAddress = _vaultAddress;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function nftCount() public view returns (uint256 _nftCount) {
        return tokenIdCounter;
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address, uint256)
    {
        return (royaltyRecipient, (salePrice * royaltyBps) / 10000);
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return _baseTokenURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 amount) public {
        require(nftLimit >= tokenIdCounter + amount);
        require(
            msg.sender == owner() || msg.sender == vaultAddress,
            "can mint"
        );
        for (uint256 i = 0; i < amount; i++) {
            tokenIdCounter++;
            uint256 tokenId = tokenIdCounter;
            _safeMint(to, tokenId);
        }
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}

interface EnhancedERC4626 is IERC4626 {
    /**
     * @dev New function to get vault utilization ratio
     * @return utilization Percentage of assets being used (0-10000 where 10000 = 100%)
     */

    // Optional: You can keep standard ERC4626 functions virtual for further overriding
    function redeem(uint256 assets, address receiver) external returns (bool);

    function mint(uint256 assets) external returns (bool);
}
