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

    function getOutcome(Moves movaA, Moves movaB) private pure returns (Outcomes) {
        if (movaA == movaB) {
            return Outcomes.Draw;
        } else if ((movaA == Moves.Rock     && movaB == Moves.Scissors) ||
                   (movaA == Moves.Paper    && movaB == Moves.Rock)     ||
                   (movaA == Moves.Scissors && movaB == Moves.Paper)) {
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
            if (outcome == Outcomes.PlayerA) {
                playerA.transfer(address(this).balance);
            } else if (outcome == Outcomes.PlayerB) {
                playerB.transfer(address(this).balance);
            } else {
                playerA.transfer(address(this).balance / 2);
                playerB.transfer(address(this).balance);
            }
            return outcome;
        } else {
            return Outcomes.None;
        }
    }
}
