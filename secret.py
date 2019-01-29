import hashlib

def main():
    print("***** Rock-Paper-Scissor Smart Contract *****\n")
    print("1. Rock")
    print("2. Paper")
    print("3. Scissors")
    print("0. Quit")

    while True:
        print("Your move: ", end="")
        move = input()
        if (move == "0"):
            return
        if (move in ["1", "2", "3"]):
            break
        print("Invalid move.")
    print("Your password: ", end="")
    password = input()
    print()

    secret      = move + "-" + password
    hash_secret = "\"0x" + hashlib.sha256(secret.encode()).hexdigest() + "\""
    secret      = "\"" + secret + "\""
    print("SECRET:", secret)
    print("HASH  :", hash_secret)

    print("\nSend HASH to method 'play' (quotation marks included)")
    print("Send SECRET to method 'reveal' (quotation marks included)")

main()
