# Rock-Paper-Scissors Smart Contract

## Contents

* [Description](#description)
* [Usage](#usage)
* [Implementation](#implementation)
* [Possible Improvements](#possible-improvements)
* [Screenshots](#screenshots)


## Description

This smart contract implements a secure Rock-Paper-Scissors game. This contract is *secure* in the sense that a player who has access to the blockchain and its content would still not be able to guess another player's move. The game follows these steps:
1. Two players register and place a bet.
2. Each participant picks a move and a password. They send the hash of the concatenation to the contract which stores it.
3. When the two players have committed their moves, they reveal what they've played. To do so, they send their move and password in clear. The contract verifies that the hash of the received input matches the one stored.
4. When both player have revealed their move, the contract determines the winner and sends him/her the total betting pool. If there is a draw, each player gets their bet back.
5. The game resets and can be played again by different players.

The contract never stores any of the players' move in clear, but only the hash of the move salted with a password only known to the player. Since a player cannot change his/her move during the reveal phase, this effectively ensures that an oponent could not cheat by looking at transaction data and playing accordingly. The implementation is detailed more thoroughly [here](#implementation).


## Usage

1. Register with function `register()`. You must send a bet greater than or equal to the minimum `BET_MIN` and to the first player's bet (if defined).
2. Commit a move with function `play(bytes32 encrMove)`. The format of the expected input is `"0xHASH"` where `HASH` is the sha256 hash of a string `move-password`. `move`is an integer ranging from 1 to 3 which correspond to rock, paper and scissors respectively and `password` is a string that should be kept secret.
3. Only when you and your opponent have played, you can reveal your move with `reveal(string memory clearMove)`. The format of the expected input is `"move-passord"`.
4. When both players have revealed their moves or when the reveal phase has ended, you can get the result and the reward via `getOutcome()`.

A python script `inputs.py` is provided to help generate expected inputs from an user choice move and password. The script works only with Python 3+.


## Implementation

### Registration Phase

Anyone can register provided that they're not already registered and that their bet is greater than an amount than a fixed minimum, currently at 1 finney. 

When a player has already been registered, a second player wishing to register must place a bet greater than or equal to the bet of that previous player. This is to prevent the strategy of always betting a smaller amount than the oponent and therefore minimizing risks while maximizing profits. Of course there are also no advantages of betting an amount strictly greater than the initial bet, but one should be free to waste his coins however he wants.

## Commit Phase

When a player has been registered successfully, he can play. As described previously, the player provides a hash of the concatenation of a move, represented by an integer, and a secret password. The contract stores this hash and nobody except the player has access to the actual move. Once such a hash has been committed, it cannot be modified.

## Reveal Phase

## Result Phase

## Helper Functions


## Possible Improvements


## Screenshots
