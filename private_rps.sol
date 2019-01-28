pragma solidity ^0.5.3;

contract RockPaperScissors {

    uint constant public BET_MIN        = 1 finney;
    uint constant public REVEAL_TIMEOUT = 10 minutes;
    uint public firstReveal;

    enum Moves {None, Rock, Paper, Scissors}
    enum Outcomes {None, PlayerA, PlayerB, Draw}

    address payable playerA;
    address payable playerB;

    bytes32 private hashedMovePlayerA;
    bytes32 private hashedMovePlayerB;

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
        } else {
            return 0;
        }
    }


    /* COMMIT PHASE */

    modifier isRegistered() {
        require (msg.sender == playerA || msg.sender == playerB);
        _;
    }

    function play(bytes32 hashedMove) public isRegistered returns (bool) {
        if (msg.sender == playerA && hashedMovePlayerA == 0x0) {
            hashedMovePlayerA = hashedMove;
        } else if (msg.sender == playerB && hashedMovePlayerB == 0x0) {
            hashedMovePlayerB = hashedMove;
        } else {
            return false;
        }
        return true;
    }


    /* REVEAL PHASE */

    modifier commitPhaseEnded() {
        require(hashedMovePlayerA != 0x0 && hashedMovePlayerB != 0x0);
        _;
    }

    function reveal(bytes32 move) public isRegistered commitPhaseEnded returns (Moves) {
        bytes32 hashedMove = sha256(abi.encode(move));
        if (msg.sender == playerA && hashedMove == hashedMovePlayerA) {
            movePlayerA = Moves(uint(uint8(move[0])));
        } else if (msg.sender == playerB && hashedMove == hashedMovePlayerB) {
            movePlayerB = Moves(uint(uint8(move[0])));
        } else {
            return Moves.None;
        }

        if (firstReveal == 0) {
            firstReveal = now;
        }
    }

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

    
    /* END GAME */

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
        firstReveal       = 0;
        playerA           = address(0x0);
        playerB           = address(0x0);
        hashedMovePlayerA = 0x0;
        hashedMovePlayerB = 0x0;
        movePlayerA       = Moves.None;
        movePlayerB       = Moves.None;
    }


    /* INFORMATION FUNCTION */

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
