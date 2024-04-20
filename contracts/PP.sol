// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ApprovalQueue {
    address public trustedContract = 0xC0e970d9C1806FAD4e68a3078251DbE1CE37a663;
    address public owner;
    uint private balance;

    // Event declaration for logging
    event Received(address, uint);
    event Distributed(address, uint);
    event Withdrawn(address, uint);

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict function access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }
    // Modifier to restrict function access to only the approval queue trusted contract or ownwer
    modifier onlyTrustedContractOrOwner() {
        require(msg.sender == trustedContract || msg.sender == owner, "Caller is not the trusted contract or owner");
        _;
    }

    function updateTrustedContract(address _newTrustedContract) public onlyOwner {
        // Add onlyOwner or similar modifier to restrict who can call this function
        trustedContract = _newTrustedContract;
    }

    // Fallback function to accept incoming Ether payments
    receive() external payable {
        balance += msg.value;
        emit Received(msg.sender, msg.value);
    }

    // Additional helper function to check the contract's current balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Function to distribute funds based on your logic
    address[] private authorAddresses;
    function distribute() public {
        for (uint i = 0; i < keys.length; i++) {
            for(uint j = 0; j < papers[keys[i]].addresses.length; j++) {
                authorAddresses.push(papers[keys[i]].addresses[j]);
            }
        }
        if(authorAddresses.length==0) return;
        uint indivPayout = balance/authorAddresses.length;
        for(uint i = 0; i < authorAddresses.length; i++) {
            payable(authorAddresses[i]).transfer(indivPayout);
            emit Distributed(authorAddresses[i], indivPayout);
        }
        balance -= indivPayout * authorAddresses.length;
        delete authorAddresses;
    }

     function withdraw(uint _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance in contract.");
        payable(owner).transfer(_amount);
        balance -= _amount;
        emit Withdrawn(owner, _amount);
    }

    struct paper {
        string id;
        string[] citations;
        address[] addresses;
        uint cited_total;
        uint cited_payout;
    }

    // mapping(string => Entry) public entries;
    mapping(string => paper) private papers;
    mapping(string => bool) private papersExists;
    string[] private keys;

    // return all papers in an array
    function getPapers() public view returns (paper[] memory) {
        paper[] memory allPapers = new paper[](keys.length);
        for (uint i = 0; i < keys.length; i++) {
            allPapers[i] = papers[keys[i]];
        }
        return allPapers;
    }

    // get the details for one paper
    function getPaperDetails(string memory id) public view returns (paper memory) {
        require(papersExists[id], "the paper must exist");
        return papers[id];
    }
    
    // function to add an entry to the queue
    function addPaper(string memory id, string[] memory citations, address[] memory addresses) public onlyTrustedContractOrOwner {
        require(!papersExists[id], "Entry ID must be unique.");
        papers[id] = paper(id, citations, addresses, 0, 0);
        papersExists[id] = true;
        keys.push(id);
    }

    // get the total number of papers
    function getNumberOfPapers() public view returns (uint) {
        return keys.length;
    }
}
