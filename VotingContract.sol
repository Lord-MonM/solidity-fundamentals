// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract VotingSystem {
    address private voter_addr;
    string public  message;
    struct Voter{
        string name;
        uint age;
        bool vote;
        bool hasVoted;
    }

    struct Candidate{
        string name;
        string[] votes;
    }

    Voter private voter;
    Candidate private candidate;

    mapping(address => Voter) private  voter_details;
    mapping(string => Candidate) private  candidate_details;

  // Uses modifier to check age
    modifier AgeCheck(address addr){
        require(voter_details[addr].age > 18, "You are not eligible! try again in few years");
        _;
    }
    

//	Uses a modifier to restrict voting to registered users.
    modifier ToRegister(address addr){
        require(!voter_details[addr].hasVoted, "You have been registered");
        _;
    }

    event CastVote(address indexed addr, bool _vote);
    event DeclareWinner(string indexed c_name, string message);

	// Emits event CastVote when a vote is cast.
    function registerVoter(string memory _name, uint256 _age, bool _vote) public AgeCheck(msg.sender) ToRegister(msg.sender) returns (string memory)  {
        string memory val;
        if(_vote == true){
        val = "yes";
        
        candidate_details[_name].votes.push(val);
        }
        if(_vote == false){
            val = "no";
            
            candidate_details[_name].votes.push(val);
        }
        voter_details[msg.sender] = Voter(_name, _age, _vote, voter_details[msg.sender].hasVoted = true);
         emit CastVote(msg.sender, _vote);
        return val;
    }


// Emits event DeclareWinner when a winner is declared.
    function declare_winner(string memory _name) public returns(string memory){
        uint256 yes_votes = 0;
        uint256 no_votes = 0;
        for (uint256 i=0; i < candidate_details[_name].votes.length ; i++) {
            if(keccak256(abi.encodePacked(candidate_details[_name].votes[i]))==keccak256(abi.encodePacked("yes"))){
                yes_votes++;
            }
            if(keccak256(abi.encodePacked(candidate_details[_name].votes[i]))==keccak256(abi.encodePacked("no"))){
                no_votes++;
            }
        }
        emit DeclareWinner(_name, message);   
        if (yes_votes > no_votes){
            message = string(abi.encodePacked( _name, " has been declared winner"));
        }else if (yes_votes < no_votes){
            message = string(abi.encodePacked( _name, "lost"));           
        }else {
        message = " ended in a tie";
        }
        emit DeclareWinner(_name, message);   
        return string(abi.encodePacked( _name, message));
    }
}