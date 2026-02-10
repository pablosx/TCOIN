import os, json, secrets, requests
from datetime import datetime
from flask import Flask, jsonify
from wallet import load_wallet, save_wallet

LEDGER_FILE = "ledger.json"
PEERS_FILE = "peers.json"

app = Flask(__name__)
wallet = load_wallet()  # Phone 1 dev wallet

# ---------------- Ledger functions ----------------
def load_ledger():
    if not os.path.exists(LEDGER_FILE):
        ledger = {
            "meta": {
                "name": "TCOIN",
                "max_supply": 15000000,
                "genesis_time": datetime.utcnow().isoformat() + "Z",
                "dev_public_key": wallet["public_key"]
            },
            "balances": {wallet["public_key"]: 2000000},  # genesis
            "transactions": [
                {
                    "type": "genesis",
                    "to": wallet["public_key"],
                    "amount": 2000000,
                    "timestamp": datetime.utcnow().isoformat() + "Z"
                }
            ]
        }
        save_ledger(ledger)
    with open(LEDGER_FILE) as f:
        return json.load(f)

def save_ledger(ledger):
    with open(LEDGER_FILE, "w") as f:
        json.dump(ledger, f, indent=2)

def recalc_balances(ledger):
    balances = {}
    for tx in ledger["transactions"]:
        t_type = tx["type"]
        if t_type == "genesis":
            balances[tx["to"]] = balances.get(tx["to"], 0) + tx["amount"]
        elif t_type in ["transfer", "recovery"]:
            balances[tx["from"]] = balances.get(tx["from"], 0) - tx["amount"]
            balances[tx["to"]] = balances.get(tx["to"], 0) + tx["amount"]
    ledger["balances"] = balances
    return ledger

# ---------------- Peers ----------------
def load_peers():
    if not os.path.exists(PEERS_FILE):
        return []
    with open(PEERS_FILE) as f:
        return json.load(f).get("peers", [])

# ---------------- Sync from peers ----------------
def sync_from_peers():
    peers = load_peers()
    ledger = load_ledger()
    local_tx_ids = set((tx.get("timestamp"), tx.get("from"), tx.get("to"), tx.get("amount"))
                       for tx in ledger["transactions"])
    for peer in peers:
        try:
            r = requests.get(f"http://{peer}/ledger", timeout=2)
            peer_ledger = r.json()
            for tx in peer_ledger["transactions"]:
                id_tuple = (tx.get("timestamp"), tx.get("from"), tx.get("to"), tx.get("amount"))
                if id_tuple not in local_tx_ids:
                    ledger["transactions"].append(tx)
            ledger["meta"]["dev_public_key"] = peer_ledger["meta"].get("dev_public_key", wallet["public_key"])
        except:
            continue
    ledger = recalc_balances(ledger)
    save_ledger(ledger)
    wallet["balance"] = ledger["balances"].get(wallet["public_key"], 0)
    save_wallet(wallet)
    return ledger

# ---------------- Send TCOIN ----------------
def send(to, amount):
    ledger = sync_from_peers()
    sender = wallet["public_key"]
    if ledger["balances"].get(sender, 0) < amount:
        print("❌ Insufficient balance")
        return
    tx = {
        "type": "transfer",
        "from": sender,
        "to": to,
        "amount": amount,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    ledger["transactions"].append(tx)
    ledger = recalc_balances(ledger)
    save_ledger(ledger)
    wallet["balance"] = ledger["balances"].get(sender, 0)
    save_wallet(wallet)
    print(f"✅ Sent {amount} TCOIN to {to}")

# ---------------- Recovery (dev only) ----------------
def recover(from_key, amount):
    ledger = sync_from_peers()
    if wallet["public_key"] != ledger["meta"]["dev_public_key"]:
        print("❌ Only dev can recover")
        return
    if ledger["balances"].get(from_key, 0) < amount:
        print("❌ Insufficient balance to recover")
        return
    tx = {
        "type": "recovery",
        "from": from_key,
        "to": wallet["public_key"],
        "amount": amount,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    ledger["transactions"].append(tx)
    ledger = recalc_balances(ledger)
    save_ledger(ledger)
    wallet["balance"] = ledger["balances"].get(wallet["public_key"], 0)
    save_wallet(wallet)
    print(f"✅ Recovered {amount} TCOIN from {from_key}")

# ---------------- CLI ----------------
def cli():
    while True:
        ledger = sync_from_peers()
        peers = load_peers()
        print("\nTCOIN Node Online")
        print("Your public key:", wallet["public_key"])
        print("Your balance:", wallet["balance"])
        print("Peers:", peers)
        cmd = input("> ").strip()
        if cmd == "exit":
            break
        elif cmd.startswith("send"):
            parts = cmd.split()
            if len(parts) != 3:
                print("Usage: send <to_public_key> <amount>")
                continue
            send(parts[1], int(parts[2]))
        elif cmd.startswith("recover"):
            parts = cmd.split()
            if len(parts) != 3:
                print("Usage: recover <from_public_key> <amount>")
                continue
            recover(parts[1], int(parts[2]))
        else:
            print("Unknown command")

# ---------------- Flask API ----------------
@app.route("/ledger")
def get_ledger():
    return jsonify(sync_from_peers())

@app.route("/peers")
def get_peers():
    return jsonify({"peers": load_peers()})

@app.route("/balance/<pubkey>")
def balance(pubkey):
    ledger = sync_from_peers()
    return jsonify({"balance": ledger["balances"].get(pubkey, 0)})

# ---------------- Main ----------------
if __name__ == "__main__":
    from threading import Thread
    Thread(target=cli).start()
    app.run(host="0.0.0.0", port=5000)
