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
    @State private var displayBalanceType = DisplayBalanceType(rawValue: UserDefaults.standard.string(forKey: "displayBalanceType") ?? DisplayBalanceType.unifiedFiat.rawValue) ?? .unifiedFiat
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
                    await viewModel.getTotalOnchainBalanceSats()
                    await viewModel.getTotalLightningBalanceSats()
                    await viewModel.getPrices()
                    await viewModel.getSpendableOnchainBalanceSats()
                    await viewModel.getStatus()
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
                    Button(action: {
                        showingNodeIDView = true
                    }) {
                        Image(systemName: "person.crop.circle.dashed.circle")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.getTotalOnchainBalanceSats()
                    await viewModel.getTotalLightningBalanceSats()
                    await viewModel.getPrices()
                    viewModel.getColor()
                    await viewModel.getSpendableOnchainBalanceSats()
                    await viewModel.getStatus()
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
                    await viewModel.getTotalOnchainBalanceSats()
                    await viewModel.getTotalLightningBalanceSats()
                    await viewModel.getPrices()
                    await viewModel.getSpendableOnchainBalanceSats()
                    await viewModel.getStatus()
                }
            }
            .sheet(
                isPresented: $showingNodeIDView,
                onDismiss: {
                    Task {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getTotalLightningBalanceSats()
                        await viewModel.getPrices()
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getStatus()
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
                isPresented: $isReceiveSheetPresented,
                onDismiss: {
                    Task {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getTotalLightningBalanceSats()
                        await viewModel.getPrices()
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getStatus()
                    }
                }
            ) {
                ReceiveView(lightningClient: viewModel.lightningClient)
                    .presentationDetents([.large])
            }
            .sheet(
                isPresented: $isPaymentsPresented,
                onDismiss: {
                    Task {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getTotalLightningBalanceSats()
                        await viewModel.getPrices()
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getStatus()
                    }
                }
            ) {
                PaymentsView(viewModel: .init(lightningClient: viewModel.lightningClient))
                    .presentationDetents([.medium, .large])
            }

        }
        .navigationDestination(for: NavigationDestination.self) { destination in
            switch destination {
            case .address:
                AddressView(
                    navigationPath: $sendNavigationPath,
                    spendableBalance: viewModel.spendableBalance
                )
            case .amount(let address, let amount, let payment):
                AmountView(
                    viewModel: .init(lightningClient: viewModel.lightningClient),
                    address: address,
                    numpadAmount: amount,
                    payment: payment,
                    spendableBalance: viewModel.spendableBalance,
                    navigationPath: $sendNavigationPath
                )
                .onDisappear {
                    Task {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getTotalLightningBalanceSats()
                        await viewModel.getPrices()
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getStatus()
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
                            Text(viewModel.totalOnchainBalance.formatted(.number.notation(.automatic)))
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
                                    reason: viewModel.isTotalBalanceFinished
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
                        HStack(spacing: 5) {
                            Image(systemName: "bitcoinsign").imageScale(.small)
                            Text(viewModel.totalOnchainBalance.formatted(.number.notation(.automatic)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(
                                    reason: viewModel.isTotalBalanceFinished
                                        ? [] : .placeholder
                                )
                            Text("sats")
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "bolt").imageScale(.small)
                            Text(viewModel.totalLightningBalance.formatted(.number.notation(.automatic)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(
                                    reason: viewModel.isTotalLightningBalanceFinished
                                        ? [] : .placeholder
                                )
                            Text("sats")
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

#if DEBUG
    #Preview {
        BitcoinView(
            viewModel: .init(
                walletClient: .constant(WalletClient(keyClient: KeyClient.mock)),
                priceClient: .mock,
                lightningClient: .mock
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
