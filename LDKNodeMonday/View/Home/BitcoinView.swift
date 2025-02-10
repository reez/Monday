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
                PaymentsView(viewModel: .init(lightningClient: viewModel.lightningClient))
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
    @Namespace private var animation

    var body: some View {
        VStack {
            HStack {
                Spacer()
                switch displayBalanceType {
                case .unifiedFiat:
                    HStack(spacing: 5) {
                        Text(viewModel.totalUSDValue)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                            .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                    }
                    .animation(.spring(), value: viewModel.isPriceFinished)
                case .unifiedBTC:
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(viewModel.unifiedBalance.formatted(.number.notation(.automatic)))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isBalanceDetailsFinished ? [] : .placeholder)
                            .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                        Text("sats")
                            .matchedGeometryEffect(id: "units", in: animation, isSource: true)
                    }
                    .animation(.spring(), value: viewModel.isBalanceDetailsFinished)
                case .onchainSats:
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(viewModel.balanceDetails.totalOnchainBalanceSats.formatted(.number.notation(.automatic)))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isBalanceDetailsFinished ? [] : .placeholder)
                            .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                        Image(systemName: "bitcoinsign").imageScale(.small)
                            .matchedGeometryEffect(id: "unitimage", in: animation, isSource: true)
                        Text("sats")
                            .matchedGeometryEffect(id: "units", in: animation, isSource: true)
                    }
                    .animation(.spring(), value: viewModel.isBalanceDetailsFinished)
                case .lightningSats:
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(viewModel.balanceDetails.totalLightningBalanceSats.formatted(.number.notation(.automatic)))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .redacted(reason: viewModel.isBalanceDetailsFinished ? [] : .placeholder)
                            .matchedGeometryEffect(id: "balance", in: animation, isSource: true)
                        Image(systemName: "bolt").imageScale(.small)
                            .matchedGeometryEffect(id: "unitimage", in: animation, isSource: true)
                        Text("sats")
                            .matchedGeometryEffect(id: "units", in: animation, isSource: true)
                    }
                    .animation(.spring(), value: viewModel.isBalanceDetailsFinished)
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
    case onchainSats
    case lightningSats
}

extension DisplayBalanceType {
    mutating func next() {
        switch self {
        case .unifiedFiat:
            self = .unifiedBTC
        case .unifiedBTC:
            self = .onchainSats
        case .onchainSats:
            self = .lightningSats
        case .lightningSats:
            self = .unifiedFiat
        }
    }

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
                walletClient: .constant(WalletClient(appMode: AppMode.mock)),
                priceClient: .mock,
                lightningClient: .mock
            ),
            sendNavigationPath: .constant(.init())
        )
    }
#endif
