TCOIN Security Model

Overview

TCOIN v0.1 is an experimental digital cash system. Security is designed to be explicit, transparent, and understandable, not magical.

There are no hidden assumptions. There are no invisible authorities.


---

Threat Model

TCOIN assumes the following real-world risks:

Lost or stolen devices

User error (wrong address, wrong amount)

Early-network bugs

Incomplete peer synchronization


TCOIN does not assume:

Perfect users

Perfect software

Adversarial nation-states (yet)



---

Wallet Security

Each wallet consists of:

A private key (secret)

A public key (your address)


Rules:

Anyone with the private key controls the funds

Lost private keys mean lost access

Wallet files must be backed up by the user


There is no password recovery. There is no blockchain rollback.


---

Ledger Integrity

The ledger is human-readable JSON

Every transaction includes:

Sender

Receiver

Amount

Timestamp

Signature (where applicable)



Ledger tampering is detectable by comparison with peers.


---

Developer Wallet Authority (v0.1 ONLY)

Version v0.1 includes a Developer Wallet with limited, explicit authority.

What the Developer Wallet CAN do

Recover funds in cases of:

Proven theft

Failed or duplicated sends

Ledger corruption


Correct balance inconsistencies

Protect early users during testing


What the Developer Wallet CANNOT do

Create new TCOIN beyond max supply

Change balances invisibly

Modify history without leaving a record


All recovery actions are:

Logged in the ledger

Timestamped

Publicly visible



---

Why This Authority Exists

TCOIN v0.1 prioritizes user protection over ideology.

Pretending there is no authority does not remove authority — it hides it.

This model makes trust:

Explicit

Auditable

Version-bound


Future versions may reduce or remove this authority.


---

Fork Safety

Forks may:

Remove developer authority

Change recovery rules


Such forks:

Must rename

Are not canonical TCOIN


See FORK.md and CANONICAL.md.


---

User Responsibility

By using TCOIN v0.1, you acknowledge:

This is experimental software

Funds may be lost

You are responsible for backups


Do not store value you cannot afford to test.


---

Reporting Issues

Security issues should be disclosed responsibly via GitHub Issues.

Critical vulnerabilities may be addressed immediately and transparently.


---

Final Note

> Security is not the absence of power. It is knowing where power exists.



TCOIN chooses honesty.
