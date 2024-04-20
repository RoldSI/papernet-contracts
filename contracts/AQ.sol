// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ApprovalQueue {
    struct Entry {
        string id;
        string[] citations;
        address[] addresses;
        uint upvotes;
        uint downvotes;
    }

    // mapping(string => Entry) public entries;
    Entry[] public entries;

    function getEntries() public view returns (Entry[] memory) {
        return entries;
    }
    
    // Function to add an entry to the queue
    function addEntry(string memory id, string[] memory citations, address[] memory addresses) public {
        require(!entryExists(id), "Entry ID must be unique");
        entries.push(Entry(id, citations, addresses, 0, 0));
    }

    // Function to check if an entry exists
    function entryExists(string memory id) private view returns (bool) {
        bytes memory idBytes = bytes(id);
        for(uint i = 0; i < entries.length; i++) {
            if (keccak256(bytes(entries[i].id)) == keccak256(idBytes)) {
                return true;
            }
        }
        return false;
    }

    // Function to add a vote to an entry
    function vote(uint id, bool upvote) public {
        require(entries.length > id, "Entry does not exist");
        Entry storage entry = entries[id];

        if (upvote) {
            entry.upvotes++;
        } else {
            entry.downvotes++;
        }

        // Check if total votes reached 5, then remove the entry
        if (entry.upvotes + entry.downvotes == 5) {
            uint lastId = entries.length - 1;
            entries[id] = entries[lastId];
            entries.pop();
        }
    }

    // Function to get the entry ID with the least sum of up and downvotes
    function getLeastVotedEntryId() public view returns (uint) {
        if (entries.length == 0) return 99999;
        
        uint votedId = 0;
        uint threshold = entries[0].upvotes + entries[0].downvotes;

        for (uint i = 1; i < entries.length; i++) {
            if (entries[i].upvotes + entries[i].downvotes < threshold) {
                votedId = i;
                threshold = entries[i].upvotes + entries[i].downvotes;
            }
        }

        return votedId;
    }
}
