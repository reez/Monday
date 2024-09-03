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
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()
    @State private var sendNavigationPath = NavigationPath()

    var body: some View {

        NavigationStack(path: $sendNavigationPath) {

            ZStack {
                Color(uiColor: UIColor.systemBackground)
                    .ignoresSafeArea(.all)

                VStack {

                    List {

                        VStack(spacing: 20) {

                            VStack {
                                HStack(spacing: 15) {
                                    Spacer()
                                    Image(systemName: "bitcoinsign")
                                        .font(.title)
                                        .fontWeight(.thin)
                                    Text(viewModel.totalBalance.formattedSatoshis())
                                        .contentTransition(.numericText())
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .redacted(
                                            reason: viewModel.isTotalBalanceFinished
                                                ? [] : .placeholder
                                        )
                                    Text("sats")
                                        .font(.title)
                                        .fontWeight(.thin)
                                    Spacer()
                                }
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(.primary)

                                if let status = viewModel.status,
                                    let timestamp = status.latestOnchainWalletSyncTimestamp
                                {
                                    let date = Date(
                                        timeIntervalSince1970: TimeInterval(
                                            timestamp
                                        )
                                    )
                                    Text(date.formattedDate())
                                        .lineLimit(1)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 20.0)
                                        .minimumScaleFactor(0.5)
                                }

                            }

                            VStack {
                                HStack(spacing: 15) {
                                    Spacer()
                                    Image(systemName: "bolt")
                                        .font(.title)
                                        .fontWeight(.thin)
                                    Text(viewModel.totalLightningBalance.formattedSatoshis())
                                        .contentTransition(.numericText())
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .redacted(
                                            reason: viewModel.isTotalLightningBalanceFinished
                                                ? [] : .placeholder
                                        )
                                    Text("sats")
                                        .font(.title)
                                        .fontWeight(.thin)
                                    Spacer()
                                }
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .foregroundColor(.primary)

                                if let status = viewModel.status,
                                    let timestamp = status.latestOnchainWalletSyncTimestamp
                                {
                                    let date = Date(
                                        timeIntervalSince1970: TimeInterval(
                                            timestamp
                                        )
                                    )
                                    Text(date.formattedDate())
                                        .lineLimit(1)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 20.0)
                                        .minimumScaleFactor(0.5)
                                }
                            }

                            HStack {
                                Spacer()
                                Text(viewModel.totalUSDValue)
                                    .contentTransition(.numericText())
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                                Spacer()
                            }
                            .lineLimit(1)
                            .animation(.spring(), value: viewModel.isPriceFinished)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                            Spacer()

                        }
                        .listRowSeparator(.hidden)

                    }
                    .listStyle(.plain)
                    .padding(.top, 120.0)
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

                        Button(action: {
                            sendNavigationPath.append(NavigationDestination.address)
                        }) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title)
                                .foregroundColor(.primary)
                        }

                    }
                    .padding([.horizontal, .bottom])

                }
                .padding()
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
                    NodeIDView(viewModel: .init())
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
                    ReceiveView()
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
                    PaymentsView(viewModel: .init())
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
                        viewModel: .init(),
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

}

enum NavigationDestination: Hashable {
    case address
    case amount(address: String, amount: String, payment: Payment)
}

#if DEBUG
#Preview {
    BitcoinView(viewModel: .init(priceClient: .mock))
}
#endif
