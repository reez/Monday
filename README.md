# Monday

## An experimental iOS app using [ldk-node](https://github.com/lightningdevkit/ldk-node)
*Swift/SwiftUI*

### Functionality
*Testnet/Regtest/Signet*

#### Implemented

- [x] Start Node `start`

- [x] Stop Node `stop`

- [x] Node ID `nodeId`

- [x] Wallet Address `newFundingAddress`

- [x] Spendable Balance `getSpendableOnchainBalanceSats`

- [x] Total Balance `getTotalOnchainBalanceSats`

- [x] Connect Peer `connect`

- [x] Disconnect Peer `disconnect`

- [x] Open Channel `connectOpenChannel`

- [x] Close Channel `closeChannel`

- [x] Send `sendPayment`

- [x] Receive `receivePayment`

- [x] List Peers `listPeers`

- [x] List Channels `listChannels`

#### Not Implemented

- [ ] Event Handling 

- [ ] All Payment variations

### Dependencies

- ldk-node (version 0.0.4) via [jurvis/ldk-node](https://github.com/jurvis/ldk-node)

- Bitcoin UI Kit via [WalletUI](https://github.com/reez/WalletUI)

- QR Code Scanner via [Code Scanner](https://github.com/twostraws/CodeScanner)

### Thanks

[@notmandatory](https://github.com/notmandatory) for getting this up and running with me on a Monday.

Most importantly [tnull](https://github.com/tnull) and the [Lightning Dev Kit](https://github.com/lightningdevkit) team/project.
