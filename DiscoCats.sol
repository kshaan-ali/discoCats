// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DiscoCats is Ownable {
    uint256 public incentivizingPeriod;
    uint256 public votingPeriod;
    uint256 public projectCount = 0;
    address public nftContractAddress;
    // uint256 public winnerProjectId;
    struct Briber {
        address briberAddress;
        address tokenAddress;
        uint256 tokenAmnt;
    }
    struct Project {
        string name;
        address projectOwner;
        Briber[] bribers;
        uint256 votes;
    }
    enum govtStatus {
        incentivising,
        voting,
        claiming
    }
    govtStatus internal status = govtStatus.incentivising;
    mapping(address => uint256) public voters;
    uint256 public totalVotes = 0;
    uint256 public lastTokenId = 10;
    mapping(uint256 => bool) public tokenVoted;
    // address[] voterKeys;

    // Project[] public projects;
    mapping(uint256 => Project) public projects;

    constructor(
        address initialOwner,
        uint256 _incentivizingPeriod,
        uint256 _votingPeriod
    ) Ownable(initialOwner) {
        incentivizingPeriod =
            block.timestamp +
            (_incentivizingPeriod * 60 );//* 60 * 24
        votingPeriod = incentivizingPeriod + (_votingPeriod * 60 );//* 60 * 24
    }

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
        Briber memory temp;
        temp.briberAddress = msg.sender;
        temp.tokenAddress = _tokenAddress;
        temp.tokenAmnt = _tokenAmount;
        newProject.bribers.push(temp);
        
    }

    function vote(uint256 _projectId) public {
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
            voters[msg.sender] <
                IERC721(nftContractAddress).balanceOf(msg.sender),
            "can cast more vote"
        );
        for (uint256 i = 0; i <= lastTokenId; i++) {
            // bool alreadyvoted=false;
            if (IERC721(nftContractAddress).ownerOf(i) == msg.sender) {
                if (tokenVoted[i] == false) {
                    voters[msg.sender]++;
                    newProject.votes++;
                    totalVotes++;
                    tokenVoted[i] = true;
                    break;
                }
            }
        }
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

    function briberInfo(uint256 _projectId)
        external
        view
        returns (Briber[] memory _bribers)
    {
        return projects[_projectId].bribers;
    }
    function briberTokenInfo(uint256 _projectId,address _tokenAddress)
        external
        view
        returns (uint number)
    {   uint totalTokenCount=0;
        Project storage newProject=projects[_projectId];
        for (uint i=0; i<newProject.bribers.length; i++) 
        {
            if(newProject.bribers[i].tokenAddress==_tokenAddress){
                totalTokenCount+=newProject.bribers[i].tokenAmnt;
            }
        }
        return totalTokenCount;
    }

    // function voyerInfo(address _voterAddr)
    //     external
    //     view
    //     returns (uint votes)
    // {
    //     return voters[_voterAddr];
    // }

    function setNftAddress(address _nftAddress) external onlyOwner {
        nftContractAddress = _nftAddress;
    }

    function claim(uint256 _projectId) public {
        // require(status == govtStatus.claiming, "cant do it now");
        require(block.timestamp >= votingPeriod, "cant do it now");

        require(
            _projectId != getWinnerProjectId(),
            "cant claim winner project"
        );
        // bool isBriber=false;
        Project storage newProject = projects[_projectId];
        for (uint256 i = 0; i < newProject.bribers.length; i++) {
            if (newProject.bribers[i].briberAddress == msg.sender) {
                require(
                    IERC20(newProject.bribers[i].tokenAddress).transfer(
                        msg.sender,
                        newProject.bribers[i].tokenAmnt
                    ),
                    "transaction failed"
                );
                newProject.bribers[i].tokenAmnt=0;
            }
        }
    }

    function withdrawWinnerProject(address _receiver) public onlyOwner {
        // require(status == govtStatus.claiming, "cant do it now");
        require(block.timestamp >= votingPeriod, "cant do it now");
        // require(_projectId == winnerProjectId, " claim winner project");
        uint256 winnerId = getWinnerProjectId();
        Project storage newProject = projects[winnerId];
        for (uint256 i = 0; i < newProject.bribers.length; i++) {
            require(
                IERC20(newProject.bribers[i].tokenAddress).transfer(
                    _receiver,
                    newProject.bribers[i].tokenAmnt
                ),
                "transaction failed"
            );
            newProject.bribers[i].tokenAmnt=0;
        }
    }

    function changeState(uint256 _stateNumber) public onlyOwner {
        if (_stateNumber == 0) {
            status = govtStatus.incentivising;
        }
        if (_stateNumber == 1) {
            status = govtStatus.voting;
        }
        if (_stateNumber == 2) {
            // for (uint256 i = 1; i <= projectCount; i++) {
            //     if (projects[i].votes > winnerProjectId) {
            //         winnerProjectId = i;
            //     }
            // }
            status = govtStatus.claiming;
        }
    }

    function getWinnerProjectId() public view returns (uint256 _id) {
        uint256 _winnerProjectId = 1;
        for (uint256 i = 1; i <= projectCount; i++) {
            if (projects[i].votes > _winnerProjectId) {
                _winnerProjectId = i;
            }
        }
        return _winnerProjectId;
    }
}
