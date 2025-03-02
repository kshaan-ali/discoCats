
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[ERC].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[ERC section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;


/**
 * @dev Required interface of an ERC-721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC-721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC-721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: BribeWars.sol


// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;





contract BribeWar is Ownable, ReentrancyGuard {
    uint256 public incentivizingPeriod;
    uint256 public votingPeriod;
    uint256 public projectCount = 0;
    address public nftContractAddress;
    // uint256 public winnerProjectId;
    struct Briber {
        address briberAddress;
        address tokenAddress;
        uint256 tokenAmnt;
        uint projectId;
    }
    struct NativeBriber {
        address briberAddress;
        uint256 tokenAmnt;
        uint projectId;
    }
    struct Project {
        string name;
        address projectOwner;
        address[] bribers;
        address[] nativeBribers;
        uint256 votes;
    }
    enum govtStatus {
        incentivising,
        voting,
        claiming
    }
    govtStatus internal status = govtStatus.incentivising;
    mapping(address => uint256) public addressVotes;
    uint briberCount = 0;
    uint nativeBriberCount = 0;
    mapping(address => Briber[]) public bribers;
    mapping(address => NativeBriber[]) public nativeBribers;
    uint256 public totalVotes = 0;
    uint256 public lastTokenId = 10;
    mapping(uint256 => bool) public tokenVoted;
    // address[] voterKeys;

    // Project[] public projects;
    mapping(uint256 => Project) public projects;

    // event ProjectIncentivized(uint indexed projectId, address indexed tokenAddress,uint amount);
    event VoteCasted(
        uint indexed projectId,
        address indexed voter,
        uint256 indexed tokenId
    );

    constructor(
        address initialOwner,
        uint256 _incentivizingPeriod,
        uint256 _votingPeriod
    ) Ownable(initialOwner) {
        incentivizingPeriod = block.timestamp + (_incentivizingPeriod * 60* 60 * 24); //* 60 * 24
        votingPeriod = incentivizingPeriod + (_votingPeriod * 60* 60 * 24); //* 60 * 24
    }

    //events
    event briberEvent(
        uint indexed projectId,
        address indexed briber,
        address indexed tokenAddress,
        uint amount
    );
    event nativeBriberEvent(
        uint indexed projectId,
        address indexed briber,
        uint amount
    );

    function initializeProject(string memory _name) public onlyOwner {
        // Project memory tempProject;

        // require(status == govtStatus.incentivising, "cant do it now");
        require(block.timestamp <= incentivizingPeriod, "cant do it now");
        projectCount++;
        //Project[projectCount];
        Project storage newProject = projects[projectCount];
        newProject.name = _name;
        newProject.projectOwner = msg.sender;
        newProject.votes = 0;
    }

    function incentiviseProject(
        uint256 id,
        address _tokenAddress,
        uint256 _tokenAmount
    ) public {
        // require(status == govtStatus.incentivising, "cant do it now");
        require(block.timestamp <= incentivizingPeriod, "cant do it now");

        require(_tokenAmount > 0, "Amount must be greater than 0");
        require(
            IERC20(_tokenAddress).balanceOf(msg.sender) >= _tokenAmount,
            "Insufficient token balance"
        );

        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            ),
            "transaction failed"
        );
        Project storage newProject = projects[id];
        Briber[] storage tempx = bribers[msg.sender];
        Briber memory temp;
        temp.briberAddress = msg.sender;
        temp.tokenAddress = _tokenAddress;
        temp.tokenAmnt = _tokenAmount;
        temp.projectId = id;
        tempx.push(temp);
        newProject.bribers.push(msg.sender);
        briberCount = briberCount + 1;
        emit briberEvent(id, msg.sender, _tokenAddress, _tokenAmount);
    }
    function incentiviseProject(uint256 id) public payable {
        // require(status == govtStatus.incentivising, "cant do it now");
        require(block.timestamp <= incentivizingPeriod, "cant do it now");

        require(msg.value > 0, "Amount must be greater than 0");
        Project storage newProject = projects[id];
        NativeBriber[] storage tempx = nativeBribers[msg.sender];
        NativeBriber memory temp;
        temp.briberAddress = msg.sender;
        // temp.tokenAddress = address("nativeToken");
        temp.tokenAmnt = msg.value;
        temp.projectId = id;
        tempx.push(temp);
        newProject.nativeBribers.push(msg.sender);
        nativeBriberCount = nativeBriberCount + 1;
        emit nativeBriberEvent(id, msg.sender, msg.value);
    }

    function vote(uint256 _projectId, uint256 tokenId) public {
        // require(status == govtStatus.voting, "cant do it now");
        require(
            block.timestamp >= incentivizingPeriod &&
                block.timestamp <= votingPeriod,
            "cant do it now"
        );

        require(projectCount >= _projectId, "aout of order no");
        require(
            IERC721(nftContractAddress).balanceOf(msg.sender) > 0,
            "dont own the nft"
        );

        Project storage newProject = projects[_projectId];
        require(
            addressVotes[msg.sender] <
                IERC721(nftContractAddress).balanceOf(msg.sender),
            "can cast more vote"
        );
        require(
            IERC721(nftContractAddress).ownerOf(tokenId) == msg.sender,
            "not owner of nft"
        );
        require(!tokenVoted[tokenId], "Token already voted");

        addressVotes[msg.sender]++;
        newProject.votes++;
        totalVotes++;
        tokenVoted[tokenId] = true;

        emit VoteCasted(_projectId, msg.sender, tokenId);
    }
    function changelastTokenId(uint256 _id) external onlyOwner {
        lastTokenId = _id;
    }

    function getStatus() external view returns (uint256 _status) {
        if (block.timestamp <= incentivizingPeriod) {
            return 0;
        } else if (
            block.timestamp >= incentivizingPeriod &&
            block.timestamp <= votingPeriod
        ) {
            return 1;
        } else {
            return 2;
        }
    }

    function setNftAddress(address _nftAddress) external onlyOwner {
        nftContractAddress = _nftAddress;
    }

    function claim(uint256 _projectId) public nonReentrant {
        // require(status == govtStatus.claiming, "cant do it now");
        require(block.timestamp >= votingPeriod, "cant do it now");

        require(
            _projectId != getWinnerProjectId(),
            "cant claim winner project"
        );

        Briber[] storage tempx = bribers[msg.sender];
        for (uint256 i = 0; i < tempx.length; i++) {
            if (tempx[i].projectId != getWinnerProjectId()) {
                require(
                    IERC20(tempx[i].tokenAddress).transfer(
                        msg.sender,
                        tempx[i].tokenAmnt
                    ),
                    "transaction failed"
                );
                tempx[i].tokenAmnt = 0;
            }
        }

        NativeBriber[] storage tempy = nativeBribers[msg.sender];
        for (uint256 i = 0; i < tempy.length; i++) {
            if (tempy[i].projectId != getWinnerProjectId()) {
                (bool success, ) = payable(tempy[i].briberAddress).call{
                    value: tempy[i].tokenAmnt
                }("");
                require(success, "Transfer failed");
                tempy[i].tokenAmnt = 0;
            }
        }
    }

    function withdrawWinnerProject(
        address _receiver,
        uint _start,
        uint _end
    ) public nonReentrant onlyOwner {
        // require(status == govtStatus.claiming, "cant do it now");
        require(block.timestamp >= votingPeriod, "cant do it now");
        // require(_projectId == winnerProjectId, " claim winner project");
        uint256 winnerId = getWinnerProjectId();
        Project storage newProject = projects[winnerId];
        for (uint256 i = _start; i < _end; i++) {
            Briber[] storage tempx = bribers[newProject.bribers[i]];

            for (uint256 j = 0; j < tempx.length; j++) {
                if (tempx[j].projectId == getWinnerProjectId()) {
                    require(
                        IERC20(tempx[j].tokenAddress).transfer(
                            _receiver,
                            tempx[j].tokenAmnt
                        ),
                        "transaction failed"
                    );
                    tempx[j].tokenAmnt = 0;
                }
            }
            // delete newProject.bribers[i];
        }
        for (uint256 i = _start; i < _end; i++) {
            NativeBriber[] storage tempx = nativeBribers[
                newProject.nativeBribers[i]
            ];

            for (uint256 j = 0; j < tempx.length; j++) {
                if (tempx[j].projectId == getWinnerProjectId()) {
                    require(payable(_receiver).send(tempx[j].tokenAmnt));

                    tempx[j].tokenAmnt = 0;
                }
            }
            // delete newProject.nativeBribers[i];
        }
    }

    // function changeState(uint256 _stateNumber) public onlyOwner {
    //     if (_stateNumber == 0) {
    //         status = govtStatus.incentivising;
    //     }
    //     if (_stateNumber == 1) {
    //         status = govtStatus.voting;
    //     }
    //     if (_stateNumber == 2) {

    //         status = govtStatus.claiming;
    //     }
    // }

    function getWinnerProjectId() public view returns (uint256 _id) {
        uint256 _winnerProjectId = 1;
        for (uint256 i = 1; i <= projectCount; i++) {
            if (projects[i].votes > projects[_winnerProjectId].votes) {
                _winnerProjectId = i;
            }
        }
        return _winnerProjectId;
    }
}
