//
//  ReceiveView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 5/1/23.
//

import SwiftUI
import WalletUI

struct ReceiveView: View {
    @ObservedObject var viewModel: ReceiveViewModel
    @State private var isCopied = false
    @State private var showCheckmark = false
    @State private var showingErrorAlert = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Amount (mSat)")
                            .bold()
                        
                        ZStack {
                            TextField("125000", text: $viewModel.amountMsat)
                                .frame(height: 48)
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 32))
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 1.0)
                                        .foregroundColor(.secondary)
                                )
                            if !viewModel.amountMsat.isEmpty {
                                HStack {
                                    Spacer()
                                    Button {
                                        self.viewModel.amountMsat = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        }
                        
                    }
                    .padding()
                    
                    Button("Create Invoice") {
                        Task {
                            await viewModel.receivePayment(
                                amountMsat: UInt64(viewModel.amountMsat) ?? 0,
                                description: "LDKNodeMonday",
                                expirySecs: UInt32(3600)
                            )
                        }
                    }
                    .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                    .padding(.bottom, 100.0)
                    
                    if viewModel.invoice != "" {
                        
                        HStack(alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 50.0, height: 50.0)
                                    .foregroundColor(viewModel.networkColor)
                                Image(systemName: "bolt.fill")
                                    .font(.title)
                                    .foregroundColor(Color(uiColor: .systemBackground))
                                    .bold()
                            }
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text("Lightning Network")
                                    .font(.caption)
                                    .bold()
                                Text(viewModel.invoice)
                                    .font(.caption)
                                    .truncationMode(.middle)
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                UIPasteboard.general.string = viewModel.invoice
                                isCopied = true
                                showCheckmark = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isCopied = false
                                    showCheckmark = false
                                }
                            } label: {
                                HStack {
                                    withAnimation {
                                        Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                                            .font(.subheadline)
                                    }
                                }
                                .bold()
                                .foregroundColor(viewModel.networkColor)
                            }
                            
                        }
                        .padding()
                        
                        Button("Clear Invoice") {
                            viewModel.clearInvoice()
                        }
                        .buttonStyle(BitcoinOutlined(tintColor: viewModel.networkColor))
                        .padding()
                        
                    }
                    
                }
                .padding()
                .alert(isPresented: $showingErrorAlert) {
                    Alert(
                        title: Text(viewModel.errorMessage?.title ?? "Unknown"),
                        message: Text(viewModel.errorMessage?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.errorMessage = nil
                        }
                    )
                }
                .onReceive(viewModel.$errorMessage) { errorMessage in
                    if errorMessage != nil {
                        showingErrorAlert = true
                    }
                }
                .onAppear {
                    viewModel.getColor()
                }
                
            }
            .ignoresSafeArea()
            
        }
        
    }
    
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView(viewModel: .init())
        ReceiveView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
