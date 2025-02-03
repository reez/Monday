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
    @State private var isPaymentsPresented = false
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        ZStack {
            VStack(alignment: .center) {

                // List, enables pull to refresh
                List {
                    BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                        .padding(.top, 40)
                        .listRowSeparator(.hidden)
                    TransactionButtons(viewModel: viewModel)
                        .padding(.horizontal, 40)
                        .listRowSeparator(.hidden)

                    Button {
                        isPaymentsPresented = true
                    } label: {
                        Label("Activity", systemImage: "clock")
                    }
                    .tint(.accentColor)
                    .padding()
                    .listRowSeparator(.hidden)
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
                            viewModel: .init(
                                lightningClient: viewModel.walletClient.lightningClient
                            )
                        )
                        .presentationDetents([.medium, .large])
                    }
                    //Spacer()
                }
                .listStyle(.plain)
                .frame(maxHeight: .infinity)
                .refreshable {
                    await viewModel.getBalances()
                    await viewModel.getPrices()
                }

            }
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
    @Namespace private var animation

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
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                        }
                        HStack {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .contentTransition(.numericText())
                                .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                                .matchedGeometryEffect(id: "secondary", in: animation, isSource: true)
                            Text("sats")
                        }
                        .lineLimit(1)
                        .animation(.spring(), value: viewModel.isPriceFinished)
                        .foregroundColor(.secondary)
                    }
                case .unifiedBTC:
                    VStack {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(
                                    reason: viewModel.isBalanceDetailsFinished
                                        ? [] : .placeholder
                                )
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                            Text("sats")
                        }
                        Text("$\(viewModel.totalUSDValue.formatted())")
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                            .animation(.spring(), value: viewModel.isPriceFinished)
                            .foregroundColor(.secondary)
                            .matchedGeometryEffect(id: "secondary", in: animation, isSource: true)
                    }
                case .separateSats:
                    VStack {
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                                .redacted(
                                    reason: viewModel.isBalanceDetailsFinished
                                        ? [] : .placeholder
                                )
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                            Text("sats")
                        }
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "bitcoinsign").imageScale(.small)
                                    .foregroundColor(.secondary)
                                Text(viewModel.balanceDetails.totalOnchainBalanceSats.formatted(.number.notation(.automatic)))
                                    .contentTransition(.numericText())
                                    .foregroundColor(.secondary)
                                    .matchedGeometryEffect(id: "secondary", in: animation, isSource: true)
                            }
                            HStack {
                                Image(systemName: "bolt").imageScale(.small)
                                    .foregroundColor(.secondary)
                                Text(viewModel.balanceDetails.totalLightningBalanceSats.formatted(.number.notation(.automatic)))
                                    .contentTransition(.numericText())
                                    .foregroundColor(.secondary)
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

struct TransactionButtons: View {
    @ObservedObject var viewModel: BitcoinViewModel
    @State private var isReceiveSheetPresented = false

    var body: some View {
        HStack(alignment: .center) {
            // Send button
            Button("Send") {
                //
            }
            .buttonStyle(
                BitcoinFilled(
                    width: 100,
                    tintColor: .accent,
                    isCapsule: true
                )
            )
            .background(
                NavigationLink("", value: NavigationDestination.address)
                    .opacity(0) // This avoids the caret applied by List
            )
            .allowsHitTesting(false)  // Required to enable NavigationLink to work

            // Scan QR button
            Label("Scan QR", systemImage: "qrcode.viewfinder")
                .font(.title)
                .frame(height: 60, alignment: .center)
                .labelStyle(.iconOnly)
                .foregroundColor(.accentColor)
                .padding()
                .background(
                    NavigationLink("", value: NavigationDestination.address)
                        .opacity(0) // This avoids the caret applied by List
                )

            // Receive button
            Button("Receive") {
                isReceiveSheetPresented = true
            }
            .buttonStyle(
                BitcoinFilled(
                    width: 100,
                    tintColor: .accent,
                    isCapsule: true
                )
            )
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

class SharedNamespace: ObservableObject {
    let animation: Namespace.ID

    init(namespace: Namespace.ID) {
        self.animation = namespace
    }
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
