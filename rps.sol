pragma solidity ^0.5.3;

contract RockPaperScissors {

    uint constant public BET_MIN = 1 finney;

    enum Moves {None, Rock, Paper, Scissors}
    enum Outcomes {None, PlayerA, PlayerB, Draw}

    address payable playerA;
    address payable playerB;

    Moves private movePlayerA;
    Moves private movePlayerB;

    modifier validBet() {
        require(msg.value >= BET_MIN);
        _;
    }

    modifier notAlreadyRegistered() {
        require(msg.sender != playerA && msg.sender != playerB);
        _;
    }

    function register() public payable validBet notAlreadyRegistered returns (uint) {
        if (playerA == address(0x0)) {
            playerA = msg.sender;
            return 1;
        } else if (playerB == address(0x0)) {
            playerB = msg.sender;
            return 2;
        } else {
            return 0;
        }
    }

    function getOutcome(Moves moveA, Moves moveB) private pure returns (Outcomes) {
        if (moveA == moveB) {
            return Outcomes.Draw;
        } else if ((moveA == Moves.Rock     && moveB == Moves.Scissors) ||
                   (moveA == Moves.Paper    && moveB == Moves.Rock)     ||
                   (moveA == Moves.Scissors && moveB == Moves.Paper)) {
            return Outcomes.PlayerA;
        } else {
            return Outcomes.PlayerB;
        }
    }

    modifier isRegistered() {
        require (msg.sender == playerA || msg.sender == playerB);
        _;
    }

    function play(Moves move) public isRegistered returns (Outcomes) {
        if (msg.sender == playerA) {
            movePlayerA = move;
        } else if (msg.sender == playerB) {
            movePlayerB = move;
        } else {
            return Outcomes.None;
        }

        if (movePlayerA != Moves.None && movePlayerB != Moves.None) {
            Outcomes outcome = getOutcome(movePlayerA, movePlayerB);
            pay(outcome);
            reset();
            return outcome;
        } else {
            return Outcomes.None;
        }
    }

    function pay(Outcomes outcome) private {
        if (outcome == Outcomes.PlayerA) {
            playerA.call.value(address(this).balance).gas(1000000)("");
        } else if (outcome == Outcomes.PlayerB) {
            playerB.call.value(address(this).balance).gas(1000000)("");
        } else {
            playerA.call.value(address(this).balance / 2).gas(1000000)("");
            playerB.call.value(address(this).balance).gas(1000000)("");
        }
    }

    function reset() private {
        playerA = address(0x0);
        playerB = address(0x0);
        movePlayerA = Moves.None;
        movePlayerB = Moves.None;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function whoAmI() public view returns (uint) {
        if (msg.sender == playerA) {
            return 1;
        } else if (msg.sender == playerB) {
            return 2;
        } else {
            return 0;
        }
    }
}
