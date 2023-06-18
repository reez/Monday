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
    @State private var showingReceiveViewErrorAlert = false
    @State private var isKeyboardVisible = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Sats")
                            .bold()
                            .padding(.horizontal)
                        
                        ZStack {
                            TextField(
                                "125000",
                                text: $viewModel.amountMsat
                            )
                            .keyboardType(.numberPad)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32))
                            
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
                        .padding(.horizontal)
                        
                    }
                    .padding()
                    
                    Button {
                        Task {
                            let amountMsat = (UInt64(viewModel.amountMsat) ?? 0) * 1000
                            await viewModel.receivePayment(
                                amountMsat: amountMsat,
                                description: "LDKNodeMonday",
                                expirySecs: UInt32(3600)
                            )
                        }
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("Create Invoice")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.all, 8)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.networkColor)
                    .padding(.horizontal, 30.0)
                    .padding(.bottom)
                    
                    if viewModel.invoice != "" {
                        QRCodeViewLightning(invoice: viewModel.invoice)
                        
                        VStack {
                            
                            HStack(alignment: .center) {
                                
                                VStack(alignment: .leading, spacing: 5.0) {
                                    HStack {
                                        Text("Lightning Network")
                                            .font(.caption)
                                            .bold()
                                    }
                                    Text(viewModel.invoice)
                                        .font(.caption)
                                        .truncationMode(.middle)
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                        .redacted(reason: viewModel.invoice == "" ? .placeholder : [])
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
                                                .font(.title2)
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
                            .buttonBorderShape(.capsule)
                            .buttonStyle(.bordered)
                            .tint(viewModel.networkColor)
                            .padding()
                            
                        }
                        
                    }
                    
                }
                .padding()
                .alert(isPresented: $showingReceiveViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.receiveViewError?.title ?? "Unknown"),
                        message: Text(viewModel.receiveViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.receiveViewError = nil
                        }
                    )
                }
                .onReceive(viewModel.$receiveViewError) { errorMessage in
                    if errorMessage != nil {
                        showingReceiveViewErrorAlert = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    isKeyboardVisible = true
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    isKeyboardVisible = false
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
