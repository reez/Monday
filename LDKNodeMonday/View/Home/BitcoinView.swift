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
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingBitcoinViewErrorAlert = false
    @State private var isPaymentsPresented = false
    @State private var showToast = false
    @State private var showSettingsView = false
    @State private var displayBalanceType = DisplayBalanceType.userDefaults
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @Binding var sendNavigationPath: NavigationPath

    var body: some View {

        ZStack {
            VStack(alignment: .center) {

                BalanceHeader(displayBalanceType: $displayBalanceType, viewModel: viewModel)
                    .padding(.vertical, 40)

                PaymentsView(
                    walletClient: $viewModel.walletClient
                )

                TransactionButtons(viewModel: viewModel)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            showSettingsView = true
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
                        isPresented: $showSettingsView,
                        onDismiss: {
                            Task {
                                //await viewModel.getBalances()
                                //await viewModel.getPrices()
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
                    //await viewModel.getBalances()
                    //await viewModel.getPrices()
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
                                    uiColor: .systemGray4
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
                        //await viewModel.getBalances()
                        //await viewModel.getPrices()
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
                                //.redacted(reason: viewModel.walletClient.price == 0.00 ? [] : .placeholder)
                                .animation(.spring(), value: viewModel.walletClient.price)
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                        }
                        HStack {
                            Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                                .contentTransition(.numericText())
                                //.redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                                .matchedGeometryEffect(
                                    id: "secondary",
                                    in: animation,
                                    isSource: true
                                )
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
//                                .redacted(
//                                    reason: viewModel.isBalanceDetailsFinished
//                                        ? [] : .placeholder
//                                )
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                            Text("sats")
                        }
                        Text("$\(viewModel.totalUSDValue.formatted())")
                            .contentTransition(.numericText())
                            //.redacted(reason: viewModel.walletClient.price == 0.00 ? [] : .placeholder)
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
//                                .redacted(
//                                    reason: viewModel.isBalanceDetailsFinished
//                                        ? [] : .placeholder
//                                )
                                .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                            Text("sats")
                        }
                        HStack(spacing: 20) {
                            HStack {
                                Image(systemName: "bitcoinsign").imageScale(.small)
                                    .foregroundColor(.secondary)
                                Text(
                                    viewModel.balanceDetails.totalOnchainBalanceSats.formatted(
                                        .number.notation(.automatic)
                                    )
                                )
                                .contentTransition(.numericText())
                                .foregroundColor(.secondary)
                                .matchedGeometryEffect(
                                    id: "secondary",
                                    in: animation,
                                    isSource: true
                                )
                            }
                            HStack {
                                Image(systemName: "bolt").imageScale(.small)
                                    .foregroundColor(.secondary)
                                Text(
                                    viewModel.balanceDetails.totalLightningBalanceSats.formatted(
                                        .number.notation(.automatic)
                                    )
                                )
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
            // Only show send buttons if user has balance
            if viewModel.walletClient.unifiedBalance > 0 {
                // Send button
                NavigationLink(value: NavigationDestination.address) {
                    Button {
                        // Optional button action if needed
                    } label: {
                        Text("Send")
                    }.buttonStyle(
                        BitcoinFilled(
                            width: 120,
                            tintColor: .accent,
                            isCapsule: true
                        )
                    ).allowsHitTesting(false)  // Required to enable NavigationLink to work
                }

                Spacer()

                // Scan QR button
                NavigationLink(value: NavigationDestination.address) {
                    Label("Scan QR", systemImage: "qrcode.viewfinder")
                        .font(.title)
                        .frame(height: 60, alignment: .center)
                        .labelStyle(.iconOnly)
                        .foregroundColor(.accentColor)
                        .padding()
                }

                Spacer()
            }

            // Receive button
            Button("Receive") {
                isReceiveSheetPresented = true
            }
            .buttonStyle(
                BitcoinFilled(
                    width: 120,
                    tintColor: .accent,
                    isCapsule: true
                )
            )
            .sheet(
                isPresented: $isReceiveSheetPresented,
                onDismiss: {
                    Task {
                        //await viewModel.getBalances()
                        //await viewModel.getPrices()
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
                walletClient: .constant(
                    WalletClient(mode: .mock)
                ),
                priceClient: .mock
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
