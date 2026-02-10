TCOIN Network Model

Overview

TCOIN is designed as phone-to-phone digital cash.

The network prioritizes:

Local-first communication

Human-scale trust

Resilience in unstable or offline environments


TCOIN does not depend on:

Mining

Global consensus

Cloud infrastructure

Permanent internet access



---

Node Identity

Each node is identified by:

A wallet public key

An IP address (local or public)


Nodes are:

Equal by default

Self-hosted

Disposable if compromised


There are no permanent node IDs beyond cryptographic keys.


---

Peer Discovery

Peers are discovered through:

Manual IP entry

Local network scanning

Direct sharing (QR, message, voice)


Example:

192.168.0.1:3000

Peers are stored locally in peers.json.

There is no global peer registry.


---

Ledger Synchronization

Nodes synchronize by:

Requesting /ledger from known peers

Comparing transaction history

Accepting the longest valid ledger


Conflicts are resolved by:

Timestamp order

Explicit recovery transactions (v0.1)


Ledger sync is:

Opportunistic

Pull-based

Human-auditable



---

Local-First Operation

TCOIN works best when:

Devices are on the same LAN

Phones are physically nearby

Trust is contextual and social


This enables:

Markets

Barter

Mutual aid

Disaster scenarios



---

Internet & Cellular Use

TCOIN can operate over:

Wi-Fi LAN

Mobile hotspots

Public internet

Cellular IP connections


There is no dependency on:

DNS

Stable IPs

NAT traversal services


Nodes may appear and disappear freely.


---

MAC Addresses & Device Identity

TCOIN does not rely on MAC addresses.

Reasons:

MACs are mutable

MACs leak privacy

MACs break across networks


All identity is cryptographic.


---

Offline Reality

If all peers go offline:

Wallets remain valid

Ledger files remain intact

Balances are preserved


Synchronization resumes when peers reconnect.

TCOIN tolerates delay.


---

Scaling Philosophy

TCOIN does not attempt to scale globally in v0.1.

Instead it scales:

Socially

Geographically

Federatively via forks


Global scale is optional, not assumed.


---

Forked Networks

Forks may:

Change networking rules

Add discovery layers

Add relays or bridges


Forked networks:

Must rename

Must not impersonate canonical TCOIN


See CANONICAL.md.


---

Design Principle

> Cash works because people can hand it to each other.



TCOIN keeps that property.
