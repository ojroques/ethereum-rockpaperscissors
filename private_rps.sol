pragma solidity ^0.5.1;

contract RockPaperScissors {

    uint constant public BET_MIN        = 1 finney;
    uint constant public REVEAL_TIMEOUT = 10 minutes;
    uint private firstReveal;

    enum Moves {None, Rock, Paper, Scissors}
    enum Outcomes {None, PlayerA, PlayerB, Draw}

    address payable playerA;
    address payable playerB;

    bytes32 private encrMovePlayerA;
    bytes32 private encrMovePlayerB;

    Moves private movePlayerA;
    Moves private movePlayerB;


    /* REGISTRATION PHASE */

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
        }
        return 0;
    }


    /* COMMIT PHASE */

    modifier isRegistered() {
        require (msg.sender == playerA || msg.sender == playerB);
        _;
    }

    function play(bytes32 encrMove) public isRegistered returns (bool) {
        if (msg.sender == playerA && encrMovePlayerA == 0x0) {
            encrMovePlayerA = encrMove;
        } else if (msg.sender == playerB && encrMovePlayerB == 0x0) {
            encrMovePlayerB = encrMove;
        } else {
            return false;
        }
        return true;
    }


    /* REVEAL PHASE */

    modifier commitPhaseEnded() {
        require(encrMovePlayerA != 0x0 && encrMovePlayerB != 0x0);
        _;
    }

    function reveal(string memory clearMove) public isRegistered commitPhaseEnded returns (Moves) {
        bytes32 encrMove = sha256(abi.encodePacked(clearMove));
        Moves move       = Moves(getFirstChar(clearMove));

        if (move == Moves.None) {
            return Moves.None;
        }

        if (msg.sender == playerA && encrMove == encrMovePlayerA) {
            movePlayerA = move;
        } else if (msg.sender == playerB && encrMove == encrMovePlayerB) {
            movePlayerB = move;
        } else {
            return Moves.None;
        }

        if (firstReveal == 0) {
            firstReveal = now;
        }

        return move;
    }

    function getFirstChar(string memory str) private pure returns (uint) {
        byte firstByte = bytes(str)[0];
        if (firstByte == 0x31) {
            return 1;
        } else if (firstByte == 0x32) {
            return 2;
        } else if (firstByte == 0x33) {
            return 3;
        } else {
            return 0;
        }
    }


    /* RESULT PHASE */

    modifier revealPhaseEnded() {
        require((movePlayerA != Moves.None && movePlayerB != Moves.None) ||
                (now > firstReveal + REVEAL_TIMEOUT));
        _;
    }

    function getOutcome() public revealPhaseEnded returns (Outcomes) {
        Outcomes outcome;

        if (movePlayerA == movePlayerB) {
            outcome = Outcomes.Draw;
        } else if ((movePlayerA == Moves.Rock     && movePlayerB == Moves.Scissors) ||
                   (movePlayerA == Moves.Paper    && movePlayerB == Moves.Rock)     ||
                   (movePlayerA == Moves.Scissors && movePlayerB == Moves.Paper)    ||
                   (movePlayerA != Moves.None     && movePlayerB == Moves.None)) {
            outcome = Outcomes.PlayerA;
        } else {
            outcome = Outcomes.PlayerB;
        }

        pay(outcome);
        reset();

        return outcome;
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
        firstReveal     = 0;
        playerA         = address(0x0);
        playerB         = address(0x0);
        encrMovePlayerA = 0x0;
        encrMovePlayerB = 0x0;
        movePlayerA     = Moves.None;
        movePlayerB     = Moves.None;
    }


    /* HELPER FUNCTIONS */

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

    function bothPlayed() public view returns (bool) {
        return (encrMovePlayerA != 0x0 && encrMovePlayerB != 0x0);
    }

    function bothRevealed() public view returns (bool) {
        return (movePlayerA != Moves.None && movePlayerB != Moves.None);
    }

    function revealTimeLeft() public view returns (int) {
        if (firstReveal != 0) {
            return int((REVEAL_TIMEOUT + firstReveal) - now);
        }
        return 0;
    }
}
