# TCOIN — Canonical Specification (v0.1 Genesis)

## Status
This document defines the **canonical rules** of the TCOIN network.
Any implementation, fork, or derivative MUST comply with this document
to claim legitimacy as “TCOIN”.

Code may fork.
Ledgers may fork.
**Canon does not.**

---

## 1. Identity

- Name: **TCOIN**
- Symbol: **TCOIN**
- Version: **v0.1-genesis**
- Network Type: Peer-to-peer, IP-based
- Intended Environment: Termux-first, low-resource devices

---

## 2. Genesis

- Max Supply: **15,000,000 TCOIN**
- Genesis Allocation:
  - **15,000,000 TCOIN minted at genesis**
  - Allocated to **Developer Wallet**
- Genesis Timestamp: `2026-02-09T00:00:00Z`

The genesis event is final and non-repeatable.

---

## 3. Canonical Authority

The **Developer Wallet Public Key** is the canonical authority for v0.1.

This key:
- Defines genesis legitimacy
- May recover tokens in cases of theft or failed delivery
- May NOT mint beyond max supply
- May NOT be replaced in v0.1

Loss or rotation of this key constitutes a **new version**, not a patch.

---

## 4. Ledger Rules

- The ledger is append-only
- Every transaction MUST include:
  - Sender public key
  - Receiver public key
  - Amount
  - ISO-8601 UTC timestamp
  - Transaction type
- Balances are derived exclusively from the ledger

If two ledgers diverge, the canonical ledger is the one that:
1. Matches genesis rules
2. Honors max supply
3. Respects developer authority constraints

---

## 5. Peer Model

- Peers are identified by IP:PORT
- No DNS, no discovery layer required
- Trust is local-first
- Sync is pull-based (`/ledger`)

---

## 6. Fork Rules

Forks are **explicitly allowed**.

However:
- Forks MAY NOT claim to be canonical TCOIN
- Forks MUST change at least one of:
  - Name
  - Genesis allocation
  - Developer authority model

Forks that retain the name “TCOIN” without complying with this document
are considered **non-canonical derivatives**.

---

## 7. Philosophy

TCOIN is not speculative by default.
It is a **sovereign digital object** designed to exist without:
- Mining
- Staking
- Oracles
- Exchanges
- Hype dependence

Simplicity is a security feature.

---

## 8. Final Clause

This document supersedes all code.

If code and canon disagree, **canon wins**.
