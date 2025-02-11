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
    @State private var isPaymentsPresented = false
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        ZStack {

            VStack {

                List {
                    BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                        .frame(maxWidth: .infinity)  // centers the view horizontally
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .padding(.top, 220.0)
                .refreshable {
                    await viewModel.update()
                }

                Spacer()

                Button {
                    isPaymentsPresented = true
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("View Payments")
                    }
                }
                .tint(viewModel.networkColor)
                .padding()

                HStack {

                    Button(action: {
                        showReceiveViewWithOption = .bip21
                    }) {
                        Image(systemName: "qrcode")
                            .font(.title)
                            .foregroundColor(.primary)
                    }.contextMenu {
                        Button {
                            showReceiveViewWithOption = .bip21
                        } label: {
                            Label("Unified BIP21", systemImage: "bitcoinsign")
                        }

                        Button {
                            showReceiveViewWithOption = .bolt11JIT
                        } label: {
                            Label("JIT Bolt11", systemImage: "bolt")
                        }
                    }

                    Spacer()

                    NavigationLink(value: NavigationDestination.address) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title)
                            .foregroundColor(.primary)
                    }

                }
                .padding([.horizontal, .bottom])

            }
            .padding()
            .padding(.bottom, 20.0)
            .tint(viewModel.networkColor)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNodeIDView = true
                    }) {
                        Image(systemName: "person.crop.circle.dashed.circle")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Sets max dynamic size for all Text
            .onAppear {
                Task {
                    await viewModel.update()
                }
            }
            .onChange(
                of: eventService.lastMessage,
                { oldValue, newValue in
                    showToast = eventService.lastMessage != nil
                }
            )
            .onReceive(viewModel.$bitcoinViewError) { errorMessage in
                if errorMessage != nil {
                    showingBitcoinViewErrorAlert = true
                }
            }
            .onReceive(eventService.$lastMessage) { _ in
                Task {
                    await viewModel.update()
                }
            }
            .sheet(
                isPresented: $showingNodeIDView,
                onDismiss: {
                    Task {
                        await viewModel.update()
                    }
                }
            ) {
                SettingsView(
                    viewModel: .init(
                        walletClient: viewModel.$walletClient,
                        lightningClient: viewModel.lightningClient
                    )
                )
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
                onDismiss: {
                    Task {
                        await viewModel.update()
                    }
                }
            ) { receiveOption in
                ReceiveView(
                    lightningClient: viewModel.lightningClient,
                    selectedOption: receiveOption
                )
                .presentationDetents([.large])
            }
            .sheet(
                isPresented: $isPaymentsPresented,
                onDismiss: {
                    Task {
                        await viewModel.update()
                    }
                }
            ) {
                PaymentsView(transactions: $viewModel.transactions)
                    .presentationDetents([.medium, .large])
            }

        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .address:
                AddressView(
                    navigationPath: $sendNavigationPath,
                    spendableBalance: viewModel.balanceDetails.spendableOnchainBalanceSats
                )
            case .amount(let address, let amount, let payment):
                AmountView(
                    viewModel: .init(lightningClient: viewModel.lightningClient),
                    address: address,
                    numpadAmount: amount,
                    payment: payment,
                    spendableBalance: viewModel.balanceDetails.spendableOnchainBalanceSats,
                    navigationPath: $sendNavigationPath
                )
                .onDisappear {
                    Task {
                        await viewModel.update()
                    }
                }

            }

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
            return "₿" + viewModel.unifiedBalance.formattedSatoshis()
        case .totalSats:
            return viewModel.unifiedBalance.formatted(.number.notation(.automatic))
        case .onchainSats:
            return viewModel.balanceDetails.totalOnchainBalanceSats.formatted(
                .number.notation(.automatic)
            )
        case .lightningSats:
            return viewModel.balanceDetails.totalLightningBalanceSats.formatted(
                .number.notation(.automatic)
            )
        }
    }

    var secondaryValue: String {
        switch displayBalanceType {
        case .fiatSats:
            return viewModel.unifiedBalance.formatted(.number.notation(.automatic))
        case .fiatBtc:
            return "₿" + viewModel.unifiedBalance.formattedSatoshis()
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

enum NavigationDestination: Hashable {
    case address
    case amount(address: String, amount: String, payment: Payment)
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
