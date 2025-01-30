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
    @State private var isReceiveSheetPresented = false
    @State private var isPaymentsPresented = false
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)
                .ignoresSafeArea(.all)

            VStack {

                List {

                    BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                        .listRowSeparator(.hidden)

                }
                .listStyle(.plain)
                .padding(.top, 220.0)
                .padding(.horizontal, -20)
                .refreshable {
                    await viewModel.getBalances()
                    await viewModel.getPrices()
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
                        isReceiveSheetPresented = true
                    }) {
                        Image(systemName: "qrcode")
                            .font(.title)
                            .foregroundColor(.primary)
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
                    Button(
                        action: {
                            showingNodeIDView = true
                        },
                        label: {
                            HStack(spacing: 5) {
                                Text(
                                    viewModel.walletClient.network.description
                                        .capitalized
                                )
                                Image(systemName: "gearshape")
                            }
                        }
                    ).sheet(
                        isPresented: $showingNodeIDView,
                        onDismiss: {
                            Task {
                                await viewModel.getBalances()
                                await viewModel.getPrices()
                            }
                        }
                    ) {
                        SettingsView(
                            viewModel: .init(
                                walletClient: viewModel.$walletClient,
                                lightningClient: viewModel.walletClient.lightningClient
                            )
                        )
                    }
                }
            }
            .onAppear {
                Task {
                    viewModel.getColor()
                    await viewModel.getBalances()
                    await viewModel.getPrices()
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
                    await viewModel.getBalances()
                    await viewModel.getPrices()
                }
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
                isPresented: $isReceiveSheetPresented,
                onDismiss: {
                    Task {
                        await viewModel.getBalances()
                        await viewModel.getPrices()
                    }
                }
            ) {
                ReceiveView(lightningClient: viewModel.walletClient.lightningClient)
                    .presentationDetents([.large])
            }
            .sheet(
                isPresented: $isPaymentsPresented,
                onDismiss: {
                    Task {
                        await viewModel.getBalances()
                        await viewModel.getPrices()
                    }
                }
            ) {
                PaymentsView(
                    viewModel: .init(lightningClient: viewModel.walletClient.lightningClient)
                )
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
                    viewModel: .init(lightningClient: viewModel.walletClient.lightningClient),
                    address: address,
                    numpadAmount: amount,
                    payment: payment,
                    spendableBalance: viewModel.balanceDetails.spendableOnchainBalanceSats,
                    navigationPath: $sendNavigationPath
                )
                .onDisappear {
                    Task {
                        await viewModel.getBalances()
                        await viewModel.getPrices()
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
            HStack {
                Spacer()
                switch displayBalanceType {
                case .unifiedFiat:
                    VStack {
                        HStack(spacing: 5) {
                            Text("$\(viewModel.totalUSDValue.formatted())")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                                .animation(.spring(), value: viewModel.isPriceFinished)
                        }
                        HStack {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .contentTransition(.numericText())
                                .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                            Text("sats")
                        }
                        .lineLimit(1)
                        .animation(.spring(), value: viewModel.isPriceFinished)
                        .foregroundColor(.secondary)
                    }
                case .unifiedBTC:
                    VStack {
                        HStack(spacing: 5) {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(
                                    reason: viewModel.isBalanceDetailsFinished
                                        ? [] : .placeholder
                                )
                            Text("sats")
                        }
                        Text("$\(viewModel.totalUSDValue.formatted())")
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                            .animation(.spring(), value: viewModel.isPriceFinished)
                            .foregroundColor(.secondary)
                    }
                case .separateSats:
                    HStack(spacing: 40) {
                        VStack(spacing: 5) {
                            Text(
                                viewModel.balanceDetails.totalOnchainBalanceSats.formatted(
                                    .number.notation(.automatic)
                                )
                            )
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(
                                reason: viewModel.isBalanceDetailsFinished
                                    ? [] : .placeholder
                            )
                            HStack(spacing: 5) {
                                Image(systemName: "bitcoinsign").imageScale(.small)
                                Text("sats")
                            }
                        }
                        VStack(spacing: 5) {
                            Text(
                                viewModel.balanceDetails.totalLightningBalanceSats.formatted(
                                    .number.notation(.automatic)
                                )
                            )
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(
                                reason: viewModel.isBalanceDetailsFinished
                                    ? [] : .placeholder
                            )
                            HStack(spacing: 5) {
                                Image(systemName: "bolt").imageScale(.small)
                                Text("sats")
                            }
                        }
                    }
                }
                Spacer()
            }.onTapGesture {
                withAnimation {
                    displayBalanceType.next()
                }
                UserDefaults.standard.set(displayBalanceType.rawValue, forKey: "displayBalanceType")
            }
        }
    }
}

enum NavigationDestination: Hashable {
    case address
    case amount(address: String, amount: String, payment: Payment)
}

public enum DisplayBalanceType: String {
    case unifiedFiat
    case unifiedBTC
    case separateSats
}

extension DisplayBalanceType {
    mutating func next() {
        switch self {
        case .unifiedFiat:
            self = .unifiedBTC
        case .unifiedBTC:
            self = .separateSats
        case .separateSats:
            self = .unifiedFiat
        }
    }
}

extension DisplayBalanceType {
    static let userDefaults: DisplayBalanceType =
        DisplayBalanceType(
            rawValue: UserDefaults.standard.string(forKey: "displayBalanceType")
                ?? DisplayBalanceType.unifiedFiat.rawValue
        ) ?? DisplayBalanceType.unifiedFiat
}

#if DEBUG
    #Preview {
        BitcoinView(
            viewModel: .init(
                walletClient: .constant(WalletClient(keyClient: KeyClient.mock)),
                priceClient: .mock
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
