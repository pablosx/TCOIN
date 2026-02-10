TCOIN Canonical Rules

This document defines the canonical rules for the TCOIN repository. It ensures forks, contributors, and users know how to reference and maintain official TCOIN releases.


---

1. Canonical Repository

Official repo: https://github.com/pablosx/TCOIN

Only this repository is considered the authoritative source for TCOIN code, documentation, and releases.



---

2. Versioning & Tags

All official releases must be tagged with a v<major>.<minor>-<label> format.

Example: v0.1-genesis

Roadmap updates: v0.1-roadmap


Tags must never rewrite history.

Commits associated with tags should include ECONOMICS.md, ROADMAP.md, or other canonical documents.



---

3. Forking & Contributions

Forks are allowed but must clearly state the source as https://github.com/pablosx/TCOIN.

Changes that aim to alter canonical rules, token supply, or governance must not claim to be the official TCOIN.

Contributions to the main repo are accepted via pull requests, with review and approval by the developer.



---

4. Ledger & Wallets

Ledger format and wallet files are canonical only in this repo.

Developer wallet(s) have authority for recovery only.

Backups and forks must not modify ledger history for past transactions.



---

5. Documentation

ECONOMICS.md and ROADMAP.md are canonical references for supply, backing, and evolution.

CANONICAL.md defines the rules for future forks and official releases.



---

6. Governance Principles

Stability is a feature.

Power moves slowly.

Authority is explicit and traceable.



---

Usage

Forks, mirrors, or experimental versions must reference this repo and must not alter the canonical tag history.

Developers or contributors who violate these rules risk invalidating claims of official TCOIN compliance.
