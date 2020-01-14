# Bancacy

[![Build Status](https://travis-ci.com/bancacy/uEquilibriums.svg?token=xxNsLhLrTiyG3pc78i5v&branch=master)](https://travis-ci.com/bancacy/uEquilibriums)&nbsp;&nbsp;[![Coverage Status](https://coveralls.io/repos/github/equprotocol/uEquilibriums/badge.svg?branch=master&t=GiWi8p)](https://coveralls.io/github/equprotocol/uEquilibriums?branch=master)

Bancacy (code name uEquilibriums) is a decentralized elastic supply protocol. It maintains a stable unit price by adjusting supply directly to and from wallet holders. You can read the [whitepaper](https://www.bancacy.org/paper/) for the motivation and a complete description of the protocol.

This repository is a collection of [smart contracts](http://bancacy.org/docs) that implement the Bancacy protocol on the Ethereum blockchain.

The official contract addresses are:
- ERC-20 Token: [0xD46bA6D942050d489DBd938a2C909A5d5039A161](https://etherscan.io/token/0xd46ba6d942050d489dbd938a2c909a5d5039a161)
- Supply Policy: [0x1B228a749077b8e307C5856cE62Ef35d96Dca2ea](https://etherscan.io/address/0x1b228a749077b8e307c5856ce62ef35d96dca2ea#contracts)

## Table of Contents

- [Install](#install)
- [Testing](#testing)
- [Contribute](#contribute)
- [License](#license)


## Install

```bash
# Install project dependencies
npm install

# Install ethereum local blockchain(s) and associated dependencies
npx setup-local-chains
```

## Testing

``` bash
# You can use the following command to start a local blockchain instance
npx start-chain [ganacheUnitTest|gethUnitTest]

# Run all unit tests
npm test

# Run unit tests in isolation
npx truffle --network ganacheUnitTest test test/unit/uEquilibriums.js
```

## Contribute

To report bugs within this package, please create an issue in this repository.
When submitting code ensure that it is free of lint errors and has 100% test coverage.

``` bash
# Lint code
npm run lint

# View code coverage
npm run coverage
```

## License

[GNU General Public License v3.0 (c) 2020 Equilibriums, Inc.](./LICENSE)
