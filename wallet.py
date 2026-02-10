import json
import os
import secrets

WALLET_FILE = "wallet.json"
DEV_ROLE = "dev"

def create_wallet(is_dev=False, initial_balance=0):
    if os.path.exists(WALLET_FILE):
        return load_wallet()

    wallet = {
        "public_key": secrets.token_hex(32),
        "private_key": secrets.token_hex(64),
        "balance": initial_balance,
        "role": DEV_ROLE if is_dev else "user"
    }
    save_wallet(wallet)
    return wallet

def load_wallet():
    if not os.path.exists(WALLET_FILE):
        return create_wallet()
    with open(WALLET_FILE, "r") as f:
        return json.load(f)

def save_wallet(wallet):
    with open(WALLET_FILE, "w") as f:
        json.dump(wallet, f, indent=2)

def add_balance(amount):
    wallet = load_wallet()
    wallet["balance"] += amount
    save_wallet(wallet)

def subtract_balance(amount):
    wallet = load_wallet()
    if wallet["balance"] < amount:
        return False
    wallet["balance"] -= amount
    save_wallet(wallet)
    return True

def is_dev(wallet):
    return wallet.get("role") == DEV_ROLE

if __name__ == "__main__":
    w = create_wallet(is_dev=True, initial_balance=15000000)
    print("Wallet created!")
    print("Public key:", w["public_key"])
    print("Private key:", w["private_key"])
    print("Balance:", w["balance"])
    print("Role:", w["role"])
