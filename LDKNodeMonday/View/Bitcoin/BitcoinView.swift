//
//  BitcoinView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/15/23.
//

import BitcoinUI
import SwiftUI

struct BitcoinView: View {
    @StateObject var viewModel: BitcoinViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingBitcoinViewErrorAlert = false
    @State private var isAddressSheetPresented = false
    @State private var isSendSheetPresented = false

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: UIColor.systemBackground)

                VStack {

                    List {

                        VStack(spacing: 20) {

                            HStack(spacing: 15) {
                                Spacer()
                                Image(systemName: "bitcoinsign")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .fontWeight(.thin)
                                Text(viewModel.totalBalance.formattedSatoshis())
                                    .contentTransition(.numericText())
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .redacted(
                                        reason: viewModel.isTotalBalanceFinished ? [] : .placeholder
                                    )
                                Text("sats")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .fontWeight(.thin)
                                Spacer()
                            }
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .animation(.spring(), value: viewModel.totalBalance)
                            .foregroundColor(.primary)

                            HStack(spacing: 5) {
                                Spacer()
                                Text(viewModel.spendableBalance)
                                    .contentTransition(.numericText())
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .redacted(
                                        reason: viewModel.isSpendableBalanceFinished
                                            ? [] : .placeholder
                                    )
                                Text("spendable")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.thin)
                                Spacer()
                            }
                            .lineLimit(1)
                            .animation(.spring(), value: viewModel.spendableBalance)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                            HStack {
                                Spacer()
                                Text(viewModel.satsPrice)
                                    .contentTransition(.numericText())
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .redacted(reason: viewModel.isPriceFinished ? [] : .placeholder)
                                Spacer()
                            }
                            .lineLimit(1)
                            .animation(.spring(), value: viewModel.satsPrice)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                            if !viewModel.isTotalBalanceFinished,
                                !viewModel.isSpendableBalanceFinished
                            {
                                Image(systemName: "slowmo")
                                    .symbolEffect(
                                        .variableColor.cumulative
                                    )
                                    .contentTransition(.symbolEffect(.replace.offUp))
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }

                        }
                        .listRowSeparator(.hidden)

                    }
                    .listStyle(.plain)
                    .padding(.top, 120.0)
                    .refreshable {
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getPrices()
                    }

                    Spacer()

                    HStack {

                        Button {
                            isSendSheetPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up")
                                Text("Send")
                            }
                            .frame(width: 100)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)

                        Button {
                            isAddressSheetPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.down")
                                Text("Receive")
                            }
                            .frame(width: 100)
                            .padding(.all, 8)
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .tint(viewModel.networkColor)
                        .padding(.horizontal)

                    }
                    .padding()

                }
                .padding()
                .navigationTitle("Balance")
                .tint(viewModel.networkColor)
                .alert(isPresented: $showingBitcoinViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.bitcoinViewError?.title ?? "Unknown"),
                        message: Text(viewModel.bitcoinViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.bitcoinViewError = nil
                        }
                    )
                }
                .onReceive(viewModel.$bitcoinViewError) { errorMessage in
                    if errorMessage != nil {
                        showingBitcoinViewErrorAlert = true
                    }
                }
                .onAppear {
                    Task {
                        await viewModel.getSpendableOnchainBalanceSats()
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getPrices()
                        viewModel.getColor()
                    }
                }
                .sheet(
                    isPresented: $isAddressSheetPresented,
                    onDismiss: {
                        Task {
                            await viewModel.getSpendableOnchainBalanceSats()
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getPrices()
                        }
                    }
                ) {
                    AddressView(viewModel: .init())
                        .presentationDetents([.medium])
                }
                .sheet(
                    isPresented: $isSendSheetPresented,
                    onDismiss: {
                        Task {
                            await viewModel.getSpendableOnchainBalanceSats()
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getPrices()
                        }
                    }
                ) {
                    SendBitcoinView(viewModel: .init(spendableBalance: viewModel.spendableBalance))
                        .presentationDetents([.medium])
                }

            }

        }

    }

}

struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BitcoinView(viewModel: .init(priceClient: .mock))
        BitcoinView(viewModel: .init(priceClient: .mock))
            .environment(\.colorScheme, .dark)
    }
}
