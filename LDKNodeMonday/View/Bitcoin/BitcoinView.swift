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

                        VStack(spacing: 10) {

                            HStack {
                                if viewModel.isTotalBalanceFinished {
                                    withAnimation {
                                        HStack(spacing: 15) {
                                            Image(systemName: "bitcoinsign")
                                                .foregroundColor(.secondary)
                                                .font(.title)
                                                .fontWeight(.thin)
                                            Text(viewModel.totalBalance)
                                                .contentTransition(.numericText())
                                                .fontWeight(.semibold)
                                                .fontDesign(.rounded)
                                            Text("sats")
                                                .foregroundColor(.secondary)
                                                .fontWeight(.thin)
                                        }
                                        .font(.largeTitle)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    }
                                } else {
                                    ProgressView()
                                        .padding(.all, 5)
                                }
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .animation(.spring(), value: viewModel.totalBalance)

                            HStack(spacing: 4) {
                                if viewModel.isSpendableBalanceFinished {
                                    withAnimation {
                                        HStack(spacing: 5) {
                                            Image(systemName: "bitcoinsign")
                                                .foregroundColor(.secondary)
                                                .fontWeight(.thin)
                                            Text(viewModel.spendableBalance)
                                                .contentTransition(.numericText())
                                                .fontWeight(.semibold)
                                                .fontDesign(.rounded)
                                            Text("sats spendable")
                                                .foregroundColor(.secondary)
                                                .fontWeight(.thin)
                                        }
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    }
                                } else {
                                    ProgressView()
                                        .padding(.all, 5)
                                }
                            }
                            .lineLimit(1)
                            .animation(.spring(), value: viewModel.spendableBalance)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        }
                        .listRowSeparator(.hidden)

                    }
                    .listStyle(.plain)
                    .padding(.top, 120.0)
                    .refreshable {
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getSpendableOnchainBalanceSats()
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
                        await viewModel.getTotalOnchainBalanceSats()
                        await viewModel.getSpendableOnchainBalanceSats()
                        viewModel.getColor()
                    }
                }
                .sheet(
                    isPresented: $isAddressSheetPresented,
                    onDismiss: {
                        Task {
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getSpendableOnchainBalanceSats()
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
                            await viewModel.getTotalOnchainBalanceSats()
                            await viewModel.getSpendableOnchainBalanceSats()
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
        BitcoinView(viewModel: .init())
        BitcoinView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
