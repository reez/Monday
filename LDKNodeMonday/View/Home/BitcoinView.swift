//
//  BitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/15/23.
//

import BitcoinUI
import SimpleToast
import SwiftUI

struct BitcoinView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingBitcoinViewErrorAlert = false
    @State private var showReceiveViewWithOption: ReceiveOption?
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        VStack {
            BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                .padding(.vertical, 40)

            TransactionButtons(viewModel: viewModel)
                .padding(.horizontal, 40)

            PaymentsListView(
                payments: $viewModel.payments,
                displayBalanceType: $displayBalanceType,
                price: viewModel.price
            )
            .refreshable { viewModel.update() }
            .sensoryFeedback(.increase, trigger: viewModel.isStatusFinished)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(
                    destination: SettingsView(
                        viewModel: .init(
                            walletClient: viewModel.$walletClient,
                            lightningClient: viewModel.lightningClient
                        )
                    )
                ) {
                    HStack {
                        Text(
                            viewModel.walletClient.appMode == .mock
                                ? "Mock data /" : ""
                        )
                        Text(viewModel.walletClient.network.description.capitalized)
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
        .onAppear { viewModel.update() }
        .onChange(
            of: eventService.lastMessage,
            { _, _ in
                showToast = eventService.lastMessage != nil
            }
        )
        .onReceive(viewModel.$bitcoinViewError) { errorMessage in
            if errorMessage != nil {
                showingBitcoinViewErrorAlert = true
            }
        }
        .onReceive(eventService.$lastMessage) { _ in
            viewModel.update()
        }
        .alert(isPresented: $showingBitcoinViewErrorAlert) {
            Alert(
                title: Text(viewModel.bitcoinViewError?.title ?? "Unknown"),
                message: Text(viewModel.bitcoinViewError?.detail ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.bitcoinViewError = nil
                }
            )
        }
        .simpleToast(
            isPresented: $showToast,
            options: .init(
                hideAfter: 5.0,
                animation: .spring,
                modifierType: .slide
            )
        ) {
            Text(eventService.lastMessage ?? "")
                .padding()
                .background(
                    Capsule()
                        .foregroundColor(
                            Color(
                                uiColor:
                                    colorScheme == .dark
                                    ? .secondarySystemBackground : .systemGray6
                            )
                        )
                )
                .foregroundColor(Color.primary)
                .font(.caption2)
        }
        .sheet(
            item: $showReceiveViewWithOption,
            onDismiss: { viewModel.update() }
        ) { receiveOption in
            ReceiveView(
                viewModel: .init(lightningClient: viewModel.lightningClient)
            )
        }
//        .navigationDestination(for: NavigationDestination.self) { destination in
//            switch destination {
//            case .address:
//                AddressView(
//                    navigationPath: $sendNavigationPath,
//                    spendableBalance: viewModel.balances.spendableOnchainBalanceSats
//                )
//            case .amount(let address, let amount, let payment):
//                AmountView(
//                    viewModel: .init(lightningClient: viewModel.lightningClient),
//                    address: address,
//                    numpadAmount: amount,
//                    payment: payment,
//                    spendableBalance: viewModel.balances.spendableOnchainBalanceSats,
//                    navigationPath: $sendNavigationPath
//                )
//                .onDisappear {
//                    viewModel.update()
//
//                }
//
//            }
//
//        }.sensoryFeedback(.increase, trigger: sendNavigationPath)

    }

}

struct BalanceHeader: View {
    @Binding var displayBalanceType: DisplayBalanceType
    @ObservedObject var viewModel: BitcoinViewModel

    var body: some View {
        VStack {
            Text(balanceValue)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
            HStack(spacing: 5) {
                Text(secondaryValue)
                    .contentTransition(.interpolate)
                Text(unitValue)
                    .contentTransition(.interpolate)
            }
            .foregroundColor(.secondary)
            .font(.system(.headline, design: .rounded, weight: .medium))
        }
        .animation(.spring(), value: viewModel.isPriceFinished)
        .sensoryFeedback(.increase, trigger: displayBalanceType)
        .onTapGesture {
            withAnimation {
                displayBalanceType.next()
            }
            UserDefaults.standard.set(displayBalanceType.rawValue, forKey: "displayBalanceType")
        }
    }

    var balanceValue: String {
        switch displayBalanceType {
        case .fiatSats:
            return viewModel.totalUSDValue
        case .fiatBtc:
            return viewModel.totalUSDValue
        case .btcFiat:
            return "₿" + viewModel.unifiedBalance.formattedSatsAsBtc()
        case .totalSats:
            return viewModel.unifiedBalance.formatted(.number.notation(.automatic))
        case .onchainSats:
            return viewModel.balances.totalOnchainBalanceSats.formatted(
                .number.notation(.automatic)
            )
        case .lightningSats:
            return viewModel.balances.totalLightningBalanceSats.formatted(
                .number.notation(.automatic)
            )
        }
    }

    var secondaryValue: String {
        switch displayBalanceType {
        case .fiatSats:
            return viewModel.unifiedBalance.formatted(.number.notation(.automatic))
        case .fiatBtc:
            return "₿" + viewModel.unifiedBalance.formattedSatsAsBtc()
        case .btcFiat:
            return viewModel.totalUSDValue
        case .totalSats:
            return "Total"
        case .onchainSats:
            return "Onchain"
        case .lightningSats:
            return "Lightning"
        }
    }

    var unitValue: String {
        switch displayBalanceType {
        case .fiatBtc:
            return ""
        case .btcFiat:
            return ""
        default:
            return "sats"
        }
    }
}

struct TransactionButtons: View {
    @ObservedObject var viewModel: BitcoinViewModel
    @State private var isReceiveSheetPresented = false
    @State private var isSendSheetManualPresented = false
    @State private var isSendSheetCameraPresented = false

    var body: some View {
        HStack(alignment: .center) {

            // Send button
            Button {
                isSendSheetManualPresented = true
            } label: {
                Text("Send")
            }.buttonStyle(
                BitcoinFilled(
                    width: 120,
                    tintColor: .accent,
                    isCapsule: true
                )
            )//.disabled(viewModel.unifiedBalance == 0)

            Spacer()

            // Scan QR button
            Button {
                isSendSheetCameraPresented = true
            } label: {
                Label("Scan QR", systemImage: "qrcode.viewfinder")
                    .font(.title)
                    .frame(height: 60, alignment: .center)
                    .labelStyle(.iconOnly)
                    .foregroundColor(.accentColor)
                    .padding()
            }//.disabled(viewModel.unifiedBalance == 0)

            Spacer()

            // Receive button
            Button("Receive") {
                isReceiveSheetPresented = true
            }
            .sensoryFeedback(.increase, trigger: isReceiveSheetPresented)
            .buttonStyle(
                BitcoinFilled(
                    width: 120,
                    tintColor: .accent,
                    isCapsule: true
                )
            )
            .sheet(
                isPresented: $isSendSheetManualPresented,
                onDismiss: {
                    Task {
                        viewModel.update()
                    }
                }
            ) {
                SendView(viewModel: SendViewModel.init(lightningClient: viewModel.lightningClient), sendViewState: .manual)
                    .presentationDetents([.large])
            }
            .sheet(
                isPresented: $isSendSheetCameraPresented,
                onDismiss: {
                    Task {
                        viewModel.update()
                    }
                }
            ) {
                SendView(viewModel: SendViewModel.init(lightningClient: viewModel.lightningClient), sendViewState: .camera)
                    .presentationDetents([.large])
            }
            .sheet(
                isPresented: $isReceiveSheetPresented,
                onDismiss: {
                    Task {
                        viewModel.update()
                    }
                }
            ) {
                ReceiveView(viewModel: .init(lightningClient: viewModel.lightningClient))
                    .presentationDetents([.large])
            }

        }
    }
}

enum NavigationDestination: Hashable {
    case address
    case amount(address: String, amount: String, payment: PaymentType)
}

public enum DisplayBalanceType: String {
    case fiatSats
    case fiatBtc
    case btcFiat
    case totalSats
    case onchainSats
    case lightningSats
}

extension DisplayBalanceType {
    mutating func next() {
        switch self {
        case .fiatSats:
            self = .fiatBtc
        case .fiatBtc:
            self = .btcFiat
        case .btcFiat:
            self = .totalSats
        case .totalSats:
            self = .onchainSats
        case .onchainSats:
            self = .lightningSats
        case .lightningSats:
            self = .fiatSats
        }
    }

    static let userDefaults: DisplayBalanceType =
        DisplayBalanceType(
            rawValue: UserDefaults.standard.string(forKey: "displayBalanceType")
                ?? DisplayBalanceType.fiatBtc.rawValue
        ) ?? DisplayBalanceType.fiatBtc
}

#if DEBUG
    #Preview {
        BitcoinView(
            viewModel: .init(
                walletClient: .constant(WalletClient(appMode: AppMode.mock)),
                priceClient: .mock,
                lightningClient: .mock
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
