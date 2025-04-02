# Monday Wallet

[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/reez/Monday/blob/master/LICENSE) 

An example iOS bitcoin wallet using [LDK Node](https://github.com/lightningdevkit/ldk-node).

<img width="2150" alt="image" src="https://github.com/user-attachments/assets/800b2de4-a886-4782-9259-03ba191fb4f7" />


## Functionality

*This app is an experimental work in progress and meant for learning and testing.*

Monday Wallet is a self-custodial bitcoin wallet with a lightning node on your iPhone.
It currently has the following functionality:

- Create a bitcoin wallet, or import from a recovery phrase
- Receive bitcoin with the following address formats: BIP21, onchain, Bolt11 (JIT if necessary), Bolt 12
- Send bitcoin to the same address formats
- Set and switch the network from the list of supported options, currently Signet and Testnet.
- Set and switch esplora server from the list of supported options
- Manually add peers and channels

## Swift Packages

- LDK Node via [ldk-node](https://github.com/lightningdevkit/ldk-node)

  *Note: Sometimes, a [local build of LDK Node](https://github.com/lightningdevkit/ldk-node/blob/main/scripts/uniffi_bindgen_generate_swift.sh) is used instead of the remote Swift package.*

- Bitcoin UI Kit via [BitcoinUI](https://github.com/reez/BitcoinUI)

- QR Code Scanner via [Code Scanner](https://github.com/twostraws/CodeScanner)

- Keychain via [Keychain Access](https://github.com/kishikawakatsumi/KeychainAccess)

## Thanks

[@notmandatory](https://github.com/notmandatory) for getting this up and running with me on a Monday.

[@tnull](https://github.com/tnull) most importantly for amazing work on LDK Node. 

The [Lightning Dev Kit](https://lightningdevkit.org) team/project and the [Bitcoin Dev Kit](https://bitcoindevkit.org/) team/project, LDK Node is built using both.

The [Bitcoin Design Community](https://bitcoin.design) and [Guide](https://bitcoin.design/guide/), on which much of the UX and design is based on. 

## Feedback

For any bugs or feature requests, please open an issue.

For discussion about work on the app, join the [#monday-wallet](https://discord.com/channels/903125802726596648/1356929537887441076) Discord channel on the Bitcoin Design Community server.
