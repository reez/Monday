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
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @State private var isReceiveSheetPresented = false
    @State private var isSendSheetManualPresented = false
    @State private var isSendSheetCameraPresented = false
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        VStack {
            BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                .padding(.vertical, 40)

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

            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    isSendSheetManualPresented = true
                } label: {
                    Image(systemName: "arrow.up")
                }
                .disabled(viewModel.unifiedBalance == 0)

                Spacer()

                Button {
                    isSendSheetCameraPresented = true
                } label: {
                    Label("Scan QR", systemImage: "qrcode.viewfinder")
                        .labelStyle(.iconOnly)
                }
                .disabled(viewModel.unifiedBalance == 0)

                Spacer()

                Button {
                    isReceiveSheetPresented = true
                } label: {
                    Image(systemName: "arrow.down")
                }
                .sensoryFeedback(.increase, trigger: isReceiveSheetPresented)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
        .onAppear { viewModel.update() }
        .onChange(
            of: eventService.lastEvent,
            { _, _ in
                showToast = eventService.lastEvent != nil
                withAnimation {
                    isReceiveSheetPresented = false
                    isSendSheetManualPresented = false
                    isSendSheetCameraPresented = false
                }
            }
        )
        .onReceive(viewModel.$bitcoinViewError) { errorMessage in
            if errorMessage != nil {
                showingBitcoinViewErrorAlert = true
            }
        }
        .onReceive(eventService.$lastEvent) { _ in
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
            ),
            onDismiss: {
                self.eventService.lastEvent = nil
            }
        ) {
            EventItemView(event: eventService.lastEvent, price: viewModel.price)
                .padding(.horizontal, 40)
        }
        .sheet(
            isPresented: $isSendSheetManualPresented,
            onDismiss: {
                Task {
                    viewModel.update()
                }
            }
        ) {
            SendView(
                viewModel: SendViewModel.init(
                    lightningClient: viewModel.lightningClient,
                    sendViewState: .manualEntry,
                    price: viewModel.price,
                    balances: viewModel.balances
                )
            )
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
            SendView(
                viewModel: SendViewModel.init(
                    lightningClient: viewModel.lightningClient,
                    sendViewState: .scanAddress,
                    price: viewModel.price,
                    balances: viewModel.balances
                )
            )
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
        case .totalBip177:
            return "₿" + viewModel.unifiedBalance.formattedBip177()
        case .onchainBip177:
            return "₿" + viewModel.balances.totalOnchainBalanceSats.formattedBip177()
        case .lightningBip177:
            return "₿" + viewModel.balances.totalLightningBalanceSats.formattedBip177()
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
        case .totalSats, .totalBip177:
            return "Total"
        case .onchainSats, .onchainBip177:
            return "Onchain"
        case .lightningSats, .lightningBip177:
            return "Lightning"

        }
    }

    var unitValue: String {
        switch displayBalanceType {
        case .totalSats, .onchainSats, .lightningSats:
            return "sats"
        default:
            return ""
        }
    }
}

public enum DisplayBalanceType: String {
    case fiatSats
    case fiatBtc
    case btcFiat
    case totalSats
    case onchainSats
    case lightningSats
    case onchainBip177
    case lightningBip177
    case totalBip177
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
            self = .totalBip177
        case .totalBip177:
            self = .onchainBip177
        case .onchainBip177:
            self = .lightningBip177
        case .lightningBip177:
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
