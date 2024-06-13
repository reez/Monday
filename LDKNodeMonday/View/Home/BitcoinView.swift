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
    @State private var isAddressSheetPresented = false
    @State private var isSendSheetPresented = false
    @State private var isPaymentsPresented = false
    @State private var showToast = false
    @State private var showingNodeIDView = false
    @StateObject var viewModel: BitcoinViewModel
    @StateObject private var eventService = EventService()

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

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

                                let date = Date(
                                    timeIntervalSince1970: TimeInterval(
                                        viewModel.status?.latestOnchainWalletSyncTimestamp
                                            ?? UInt64(0)
                                    )
                                )
                                Text(date.formattedDate())
                                    .lineLimit(1)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 20.0)
                                    .minimumScaleFactor(0.5)
                                    .redacted(
                                        reason: viewModel.isStatusFinished ? [] : .placeholder
                                    )
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

                                let date = Date(
                                    timeIntervalSince1970: TimeInterval(
                                        viewModel.status?.latestWalletSyncTimestamp ?? UInt64(0)
                                    )
                                )
                                Text(date.formattedDate())
                                    .lineLimit(1)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 20.0)
                                    .minimumScaleFactor(0.5)
                                    .redacted(
                                        reason: viewModel.isStatusFinished ? [] : .placeholder
                                    )
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

                        Button {
                            isSendSheetPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                    .minimumScaleFactor(0.5)
                                Text("Send")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(width: 100, height: 25)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)

                        Button {
                            isAddressSheetPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down")
                                Text("Receive")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            .frame(width: 100, height: 25)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)

                    }
                    .padding()

                }
                .padding()
                .tint(viewModel.networkColor)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingNodeIDView = true
                        }) {
                            Image(systemName: "person.circle.fill")
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
                    isPresented: $isAddressSheetPresented,
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
                    isPresented: $isSendSheetPresented,
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
                    AmountView(viewModel: .init(), spendableBalance: viewModel.spendableBalance)
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

        }

    }

}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BitcoinView(viewModel: .init(priceClient: .mock))
        BitcoinView(viewModel: .init(priceClient: .mock))
            .environment(\.sizeCategory, .accessibilityLarge)
        BitcoinView(viewModel: .init(priceClient: .mock))
            .environment(\.colorScheme, .dark)
    }
}
